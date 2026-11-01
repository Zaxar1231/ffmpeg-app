import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/containers.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/media_preview.dart';
import '../../ui/widgets/setting_tile.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'audio_ops.dart';

String _streamLabel(AppLocalizations l, StreamInfo s) =>
    '#${s.index} · ${s.codecName ?? '?'}'
    '${s.channels != null ? ' · ${s.channels} ch' : ''}'
    '${s.language != null ? ' · ${s.language}' : ''}'
    '${s.title != null ? ' · ${s.title}' : ''}';

String _sourceExt(MediaInfo info) {
  final e = p.extension(info.path).replaceFirst('.', '').toLowerCase();
  return containers.containsKey(e) ? e : 'mkv';
}

// =============================================================== extract

class ExtractAudioPage extends ConsumerWidget {
  const ExtractAudioPage({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'extractAudio',
    path: path,
    builder: (info) => _ExtractForm(key: ValueKey(info.path), info: info),
  );
}

class _ExtractForm extends ConsumerStatefulWidget {
  const _ExtractForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_ExtractForm> createState() => _ExtractFormState();
}

class _ExtractFormState extends ConsumerState<_ExtractForm> {
  ExtractFormat _format = ExtractFormat.copy;
  late int _stream = widget.info.audioStreams.firstOrNull?.index ?? -1;
  int _kbps = 192;
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final src = info.audioStreams.where((s) => s.index == _stream).firstOrNull;
    final ext = extractExtension(_format, sourceCodec: src?.codecName);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext), ext);
    final steps = src == null
        ? null
        : planExtractAudio(info: info, output: out, streamIndex: _stream, format: _format, kbps: _kbps);
    final lossy = _format == ExtractFormat.mp3 || _format == ExtractFormat.aac || _format == ExtractFormat.opus;
    return ToolScaffold(
      toolId: 'extractAudio',
      info: info,
      preview: MediaPreview(path: info.path),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (src == null) l.issueNoAudio],
      estimate: info.duration == null || !lossy
          ? null
          : l.estimateSize(formatBytes(_kbps * 125 * info.duration!.inSeconds, units: byteUnits(l))),
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'extractAudio',
          title: '${l.toolExtractAudio}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: info.duration,
        ),
        now: now,
      ),
      params: [
        ParamGroup(
          title: l.groupAudio,
          children: [
            if (info.audioStreams.length > 1)
              SettingTile(
                title: l.pTrack,
                hint: l.pTrackHint,
                control: DropdownButton<int>(
                  value: _stream,
                  onChanged: (v) => setState(() => _stream = v ?? _stream),
                  items: [
                    for (final s in info.audioStreams)
                      DropdownMenuItem(value: s.index, child: Text(_streamLabel(l, s))),
                  ],
                ),
              ),
            SettingTile(
              title: l.pExtractFormat,
              hint: _format == ExtractFormat.copy ? l.extractCopyHint(ext) : l.pExtractFormatHint,
              help: l.pExtractFormatHelp,
              control: DropdownButton<ExtractFormat>(
                value: _format,
                onChanged: (v) => setState(() => _format = v ?? _format),
                items: [
                  DropdownMenuItem(value: ExtractFormat.copy, child: Text(l.extractAsIs)),
                  const DropdownMenuItem(value: ExtractFormat.mp3, child: Text('MP3')),
                  const DropdownMenuItem(value: ExtractFormat.aac, child: Text('AAC (M4A)')),
                  const DropdownMenuItem(value: ExtractFormat.opus, child: Text('Opus')),
                  DropdownMenuItem(value: ExtractFormat.flac, child: Text(l.codecFlac)),
                  const DropdownMenuItem(value: ExtractFormat.wav, child: Text('WAV')),
                ],
              ),
            ),
            if (_format == ExtractFormat.copy)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TagChip(l.losslessTag, icon: Icons.bolt, color: Theme.of(context).colorScheme.tertiaryContainer),
              ),
            if (lossy)
              SettingTile(
                title: l.pAudioBitrate,
                hint: l.pAudioBitrateHint,
                help: l.pAudioBitrateHelp,
                control: DropdownButton<int>(
                  value: _kbps,
                  onChanged: (v) => setState(() => _kbps = v ?? _kbps),
                  items: [
                    for (final k in const [96, 128, 160, 192, 256, 320])
                      DropdownMenuItem(value: k, child: Text('$k ${l.unitKbps}')),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// =============================================================== tracks

class AudioTracksPage extends ConsumerWidget {
  const AudioTracksPage({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'replaceAudio',
    path: path,
    builder: (info) => _TracksForm(key: ValueKey(info.path), info: info),
  );
}

class _TracksForm extends ConsumerStatefulWidget {
  const _TracksForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_TracksForm> createState() => _TracksFormState();
}

class _TracksFormState extends ConsumerState<_TracksForm> {
  TrackMode _mode = TrackMode.replace;
  String? _audioPath;
  bool _shortest = true;
  String? _lang;
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = _sourceExt(info);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_audio'), ext);
    final needsAudio = _mode != TrackMode.remove;
    final audioInfo = _audioPath == null ? null : ref.watch(mediaInfoProvider(_audioPath!));
    final ai = audioInfo?.value;
    final problems = [
      if (needsAudio && _audioPath == null) l.issueChooseAudio,
      if (needsAudio && ai != null && ai.audioStreams.isEmpty) l.issueNoAudio,
      if (audioInfo?.hasError ?? false) l.probeFailed,
    ];
    final steps = problems.isEmpty && (!needsAudio || ai != null)
        ? planAudioTracks(
            video: info,
            audio: ai,
            output: out,
            mode: _mode,
            ext: ext,
            shortest: _shortest,
            language: _lang,
          )
        : null;
    return ToolScaffold(
      toolId: 'replaceAudio',
      info: info,
      preview: MediaPreview(path: info.path),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: problems,
      estimate: l.videoCopiedNote,
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'audioTracks',
          title: '${l.toolReplaceAudio}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: info.duration,
        ),
        now: now,
      ),
      params: [
        ParamGroup(
          title: l.groupAudio,
          children: [
            SettingTile(
              title: l.pTrackMode,
              hint: switch (_mode) {
                TrackMode.replace => l.trackReplaceHint,
                TrackMode.add => l.trackAddHint,
                TrackMode.remove => l.trackRemoveHint,
              },
              controlBelow: true,
              control: SegmentedButton<TrackMode>(
                segments: [
                  ButtonSegment(value: TrackMode.replace, label: Text(l.trackReplace)),
                  ButtonSegment(value: TrackMode.add, label: Text(l.trackAdd)),
                  ButtonSegment(value: TrackMode.remove, label: Text(l.trackRemove)),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() => _mode = v.first),
              ),
            ),
            if (needsAudio) ...[
              SettingTile(
                title: l.pAudioFile,
                hint: _audioPath == null ? l.pAudioFileHint : p.basename(_audioPath!),
                control: OutlinedButton.icon(
                  icon: const Icon(Icons.audio_file_outlined),
                  label: Text(l.choose),
                  onPressed: () async {
                    final f = await pickInputFile();
                    if (f != null) setState(() => _audioPath = f);
                  },
                ),
              ),
              SettingTile(
                title: l.pShortest,
                hint: l.pShortestHint,
                control: Switch(value: _shortest, onChanged: (v) => setState(() => _shortest = v)),
              ),
              SettingTile(
                title: l.pLanguage,
                hint: l.pLanguageHint,
                control: DropdownButton<String?>(
                  value: _lang,
                  onChanged: (v) => setState(() => _lang = v),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.notSet)),
                    for (final c in const ['rus', 'eng', 'ukr', 'deu', 'fra', 'spa', 'jpn'])
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TagChip(
                l.losslessVideoTag,
                icon: Icons.bolt,
                color: Theme.of(context).colorScheme.tertiaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================== normalize

class NormalizePage extends ConsumerWidget {
  const NormalizePage({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'normalize',
    path: path,
    builder: (info) => _NormalizeForm(key: ValueKey(info.path), info: info),
  );
}

class _NormalizeForm extends ConsumerStatefulWidget {
  const _NormalizeForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_NormalizeForm> createState() => _NormalizeFormState();
}

class _NormalizeFormState extends ConsumerState<_NormalizeForm> {
  LoudnessTarget _target = loudnessTargets.first;
  bool _twoPass = true;
  String? _output;

  String _targetLabel(AppLocalizations l, LoudnessTarget t) => switch (t.id) {
    'streaming' => l.loudStreaming,
    'podcast' => l.loudPodcast,
    'broadcast' => l.loudBroadcast,
    'apple' => l.loudApple,
    _ => t.id,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = _sourceExt(info);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_norm'), ext);
    final ok = info.audioStreams.isNotEmpty;
    final steps = ok ? planNormalize(info: info, output: out, target: _target, ext: ext, twoPass: _twoPass) : null;
    final codec = ok ? audioChoiceFor(ext, sourceCodec: info.audioStreams.first.codecName).name : '';
    return ToolScaffold(
      toolId: 'normalize',
      info: info,
      preview: MediaPreview(path: info.path, aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (!ok) l.issueNoAudio],
      estimate: ok ? l.normalizeNote(codec) : null,
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'normalize',
          title: '${l.toolNormalize}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: info.duration,
        ),
        now: now,
      ),
      params: [
        ParamGroup(
          title: l.groupLoudness,
          children: [
            SettingTile(
              title: l.pLoudTarget,
              hint: l.pLoudTargetHint(_target.integrated.toStringAsFixed(0), _target.truePeak.toStringAsFixed(1)),
              help: l.pLoudTargetHelp,
              controlBelow: true,
              control: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in loudnessTargets)
                    ChoiceChip(
                      label: Text('${_targetLabel(l, t)} (${t.integrated.toStringAsFixed(0)} LUFS)'),
                      selected: _target == t,
                      onSelected: (_) => setState(() => _target = t),
                    ),
                ],
              ),
            ),
            SettingTile(
              title: l.pTwoPassLoud,
              hint: _twoPass ? l.pTwoPassLoudOn : l.pTwoPassLoudOff,
              help: l.pTwoPassLoudHelp,
              control: Switch(value: _twoPass, onChanged: (v) => setState(() => _twoPass = v)),
            ),
            if (info.videoStreams.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TagChip(
                  l.losslessVideoTag,
                  icon: Icons.bolt,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
