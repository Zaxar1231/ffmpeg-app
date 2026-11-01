import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' show Media, Player, PlaylistMode;
import 'package:path/path.dart' as p;

import '../../core/components/models.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/media_preview.dart';
import '../../ui/widgets/setting_tile.dart';
import '../audio_editor/engine/effects.dart';
import '../audio_editor/ui/dialogs.dart' show FxParamEditor;
import '../audio_editor/ui/fx_labels.dart';
import '../edit/graphs.dart' show fnum;
import '../edit/ui/edit_widgets.dart';
import '../shell/app_shell.dart';
import '../tools/tool_catalog.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'audio_chain.dart';

// ================================================================== models

/// Install/remove model files (RNNoise, Whisper). Also shown in Components.
class ModelsCard extends ConsumerWidget {
  const ModelsCard({super.key, required this.kind, this.dense = false});
  final ModelKind kind;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final st = ref.watch(modelsProvider);
    final c = ref.read(modelsProvider.notifier);
    final t = Theme.of(context);
    final tiles = [
      for (final m in modelCatalog.where((m) => m.kind == kind))
        ListTile(
          dense: dense,
          title: Text(modelName(l, m.id)),
          subtitle: Text(
            [
              modelNote(l, m.id),
              formatBytes(m.size, units: byteUnits(l)),
              if (st.errors[m.id] != null) st.errors[m.id]!,
            ].join(' · '),
            style: st.errors[m.id] != null ? TextStyle(color: t.colorScheme.error) : null,
          ),
          trailing: st.progress.containsKey(m.id)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 80, child: LinearProgressIndicator(value: st.progress[m.id])),
                    IconButton(tooltip: l.cancel, icon: const Icon(Icons.close), onPressed: () => c.cancel(m.id)),
                  ],
                )
              : st.installed.containsKey(m.id)
              ? TextButton(onPressed: () => c.remove(m), child: Text(l.remove))
              : OutlinedButton(onPressed: () => c.install(m), child: Text(l.install)),
        ),
    ];
    if (dense) return Column(children: tiles);
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                kind == ModelKind.rnnoise ? l.modelsRnnoise : l.modelsWhisper,
                style: t.textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                kind == ModelKind.rnnoise ? l.modelsRnnoiseHint : l.modelsWhisperHint,
                style: t.textTheme.bodySmall,
              ),
            ),
            ...tiles,
          ],
        ),
      ),
    );
  }
}

String modelName(AppLocalizations l, String id) => switch (id) {
  'rnnSh' => l.modelRnnSh,
  'rnnBd' => l.modelRnnBd,
  'rnnCb' => l.modelRnnCb,
  'rnnLq' => l.modelRnnLq,
  'rnnMp' => l.modelRnnMp,
  'whisperTiny' => 'Whisper Tiny',
  'whisperBase' => 'Whisper Base',
  'whisperSmall' => 'Whisper Small',
  'whisperMedium' => 'Whisper Medium (Q5)',
  'whisperTurbo' => 'Whisper Large v3 Turbo (Q5)',
  _ => id,
};

String modelNote(AppLocalizations l, String id) => switch (id) {
  'rnnSh' => l.modelRnnShNote,
  'rnnBd' => l.modelRnnBdNote,
  'rnnCb' => l.modelRnnCbNote,
  'rnnLq' => l.modelRnnLqNote,
  'rnnMp' => l.modelRnnMpNote,
  'whisperTiny' => l.modelWhisperTinyNote,
  'whisperBase' => l.modelWhisperBaseNote,
  'whisperSmall' => l.modelWhisperSmallNote,
  'whisperMedium' => l.modelWhisperMediumNote,
  _ => l.modelWhisperTurboNote,
};

// ================================================================ A/B audio

/// Before/after listening: renders the same short fragment with and without
/// the chain and plays both in sync; the toggle switches which one is heard.
class AudioAbPreview extends ConsumerStatefulWidget {
  const AudioAbPreview({super.key, required this.info, required this.filters, this.stream = 0});
  final MediaInfo info;
  final List<String> filters;
  final int stream;

  @override
  ConsumerState<AudioAbPreview> createState() => _AudioAbPreviewState();
}

class _AudioAbPreviewState extends ConsumerState<AudioAbPreview> {
  late Duration _start = _default();
  Duration _len = const Duration(seconds: 10);
  final _a = Player(), _b = Player();
  bool _processed = true;
  bool _busy = false;
  bool _playing = false;
  String? _error;
  Directory? _tmp;
  String? _renderedFor;
  int _seq = 0;

  Duration _default() {
    final d = widget.info.duration ?? Duration.zero;
    return d > const Duration(seconds: 30) ? d * 0.2 : Duration.zero;
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    final t = _tmp;
    if (t != null) unawaited(t.delete(recursive: true).catchError((_) => t));
    super.dispose();
  }

  String get _key => '${_start.inMilliseconds}|${_len.inMilliseconds}|${widget.filters.join(',')}';

  Future<void> _play() async {
    if (_playing) {
      await _a.pause();
      await _b.pause();
      setState(() => _playing = false);
      return;
    }
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null) return;
    if (_renderedFor != _key) {
      setState(() {
        _busy = true;
        _error = null;
      });
      _tmp ??= await Directory.systemTemp.createTemp('kadra_ab');
      final n = _seq++;
      final orig = p.join(_tmp!.path, 'a$n.wav'), proc = p.join(_tmp!.path, 'b$n.wav');
      final runner = ref.read(processRunnerProvider);
      Future<bool> render(String out, List<String> f) async {
        final r = await runner.capture(
          ffmpeg,
          audioPreviewArgs(
            info: widget.info,
            output: out,
            start: _start,
            length: _len,
            filters: f,
            stream: widget.stream,
          ),
          timeout: const Duration(minutes: 2),
        );
        if (!r.ok && mounted) setState(() => _error = r.stderr.trim().split('\n').lastOrNull);
        return r.ok;
      }

      final ok = await render(orig, const []) && await render(proc, widget.filters);
      if (!mounted) return;
      setState(() => _busy = false);
      if (!ok) return;
      await _a.open(Media(orig), play: false);
      await _b.open(Media(proc), play: false);
      await _a.setPlaylistMode(PlaylistMode.single);
      await _b.setPlaylistMode(PlaylistMode.single);
      _renderedFor = _key;
    }
    await _applyMute();
    await _a.seek(Duration.zero);
    await _b.seek(Duration.zero);
    await _a.play();
    await _b.play();
    setState(() => _playing = true);
  }

  Future<void> _applyMute() async {
    await _a.setVolume(_processed ? 0 : 100);
    await _b.setVolume(_processed ? 100 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final total = widget.info.duration ?? Duration.zero;
    return ParamGroup(
      title: l.groupListen,
      children: [
        SettingTile(
          title: l.pListenFrom,
          hint: l.pListenFromHint,
          control: DurationField(value: _start, onChanged: (d) => setState(() => _start = d ?? Duration.zero)),
        ),
        SettingTile(
          title: l.pListenLength,
          hint: l.pListenLengthHint,
          control: DropdownButton<int>(
            value: _len.inSeconds,
            onChanged: (v) => setState(() => _len = Duration(seconds: v!)),
            items: [
              for (final s in const [5, 10, 20, 30]) DropdownMenuItem(value: s, child: Text('$s ${l.unitSecond}')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                icon: _busy
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(_playing ? Icons.pause : Icons.play_arrow),
                label: Text(_playing ? l.pause : l.listen),
                onPressed: _busy || total == Duration.zero ? null : _play,
              ),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(l.previewBefore)),
                  ButtonSegment(value: true, label: Text(l.previewAfter)),
                ],
                selected: {_processed},
                onSelectionChanged: (v) {
                  setState(() => _processed = v.first);
                  unawaited(_applyMute());
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            _error ?? l.abListenHint,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: _error != null ? Theme.of(context).colorScheme.error : null),
          ),
        ),
      ],
    );
  }
}

// ============================================================ chain pages

/// Denoise (`denoise`) and audio effects (`audioFx`) on a whole file.
class AudioChainPage extends ConsumerWidget {
  const AudioChainPage({super.key, required this.toolId, this.path});
  final String toolId;
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: toolId,
    path: path,
    builder: (i) => _ChainForm(key: ValueKey(i.path), info: i, denoise: toolId == 'denoise'),
  );
}

class _ChainForm extends ConsumerStatefulWidget {
  const _ChainForm({super.key, required this.info, required this.denoise});
  final MediaInfo info;
  final bool denoise;
  @override
  ConsumerState<_ChainForm> createState() => _ChainFormState();
}

class _ChainFormState extends ConsumerState<_ChainForm> {
  final _items = <ChainItem>[];
  int _stream = 0;
  String? _output;
  int? _expanded;

  static const _denoiseExtras = [
    'noiseReduction',
    'nlmDenoise',
    'clickRemoval',
    'clipFix',
    'highPass',
    'humRemoval',
    'deesser',
    'speechNormalizer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.denoise) {
      final rnn = ref.read(modelsProvider).installedOf(ModelKind.rnnoise).firstOrNull;
      _items.add(
        rnn != null
            ? ChainItem.rnnoise(ref.read(modelsProvider).pathOf(rnn.id))
            : ChainItem.fx('noiseReduction', fxById('noiseReduction').defaults()),
      );
      _expanded = 0;
    }
  }

  List<FxDef> _available() {
    final hasVideo = widget.info.videoStreams.isNotEmpty;
    final all = fxCatalog.where((d) => fxUsableOnFile(d, hasVideo: hasVideo));
    if (!widget.denoise) return all.toList();
    return [for (final id in _denoiseExtras) ...all.where((d) => d.id == id)];
  }

  Future<void> _addMenu(BuildContext context) async {
    final l = context.l10n;
    final caps = ref.read(capabilitiesProvider).value;
    final models = ref.read(modelsProvider);
    final rnn = models.installedOf(ModelKind.rnnoise);
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.addEffect),
        children: [
          if (caps?.hasFilter('arnndn') ?? true)
            SimpleDialogOption(
              onPressed: rnn.isEmpty ? null : () => Navigator.pop(ctx, ChainItem.rnnoiseId),
              child: ListTile(
                title: Text(l.fxRnnoise),
                subtitle: Text(rnn.isEmpty ? l.rnnoiseNeedsModel : l.fxRnnoiseDesc),
                enabled: rnn.isNotEmpty,
              ),
            ),
          for (final cat in FxCategory.values) ...[
            if (_available().any((d) => d.category == cat))
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Text(fxCategoryName(l, cat), style: Theme.of(ctx).textTheme.labelLarge),
              ),
            for (final d in _available().where((d) => d.category == cat))
              SimpleDialogOption(
                onPressed: d.filters.every((f) => caps?.version == null || caps!.hasFilter(f))
                    ? () => Navigator.pop(ctx, d.id)
                    : null,
                child: ListTile(dense: true, title: Text(fxName(l, d.id)), subtitle: Text(fxDescription(l, d.id))),
              ),
          ],
        ],
      ),
    );
    if (picked == null) return;
    setState(() {
      if (picked == ChainItem.rnnoiseId) {
        _items.add(ChainItem.rnnoise(models.pathOf(rnn.first.id)));
      } else {
        _items.add(ChainItem.fx(picked, fxById(picked).defaults()));
      }
      _expanded = _items.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final models = ref.watch(modelsProvider);
    final ext = audioFxExt(info);
    final out = withExtension(
      _output ?? defaultOutput(ref, info.path, ext: ext, suffix: widget.denoise ? '_clean' : '_fx'),
      ext,
    );
    final ctx = fileFxContext(info, stream: _stream);
    final filters = chainFilters(_items, ctx);
    final keep = chainKeepsLength(_items);
    final steps = _items.isEmpty || info.audioStreams.isEmpty
        ? null
        : planAudioChain(info: info, output: out, filters: filters, stream: _stream, keepLength: keep);
    final rnnModels = models.installedOf(ModelKind.rnnoise);
    final toolId = widget.denoise ? 'denoise' : 'audioFx';
    return ToolScaffold(
      toolId: toolId,
      info: info,
      preview: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MediaPreview(path: info.path, aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9),
          const SizedBox(height: 12),
          if (_items.isNotEmpty && info.audioStreams.isNotEmpty)
            AudioAbPreview(info: info, filters: filters, stream: _stream),
        ],
      ),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (info.audioStreams.isEmpty) l.issueNoAudio, if (_items.isEmpty) l.chainEmpty],
      warnings: [if (widget.denoise && rnnModels.isEmpty) l.rnnoiseSuggest],
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: toolId,
          title: '${toolTitle(l, toolId)}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: info.duration,
        ),
        now: now,
      ),
      params: [
        if (info.audioStreams.length > 1)
          ParamGroup(
            title: l.pAudioTrack,
            children: [
              SettingTile(
                title: l.pAudioTrack,
                hint: l.pAudioTrackHint,
                control: DropdownButton<int>(
                  value: _stream,
                  onChanged: (v) => setState(() => _stream = v!),
                  items: [
                    for (var i = 0; i < info.audioStreams.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text('#${i + 1} ${info.audioStreams.elementAt(i).codecName ?? ''}'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ParamGroup(
          title: l.groupChain,
          trailing: TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l.addEffect),
            onPressed: () => _addMenu(context),
          ),
          children: [
            if (_items.isEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.chainHowTo)),
            for (var i = 0; i < _items.length; i++) ...[
              ListTile(
                leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                title: Text(_items[i].isRnnoise ? l.fxRnnoise : fxName(l, _items[i].fxId)),
                subtitle: Text(
                  _items[i].isRnnoise ? l.fxRnnoiseDesc : fxDescription(l, _items[i].fxId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => setState(() => _expanded = _expanded == i ? null : i),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l.moveUp,
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: i == 0
                          ? null
                          : () => setState(() {
                              final it = _items.removeAt(i);
                              _items.insert(i - 1, it);
                              _expanded = i - 1;
                            }),
                    ),
                    IconButton(
                      tooltip: l.removeFromList,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _items.removeAt(i);
                        _expanded = null;
                      }),
                    ),
                  ],
                ),
              ),
              if (_expanded == i)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: _items[i].isRnnoise
                      ? Column(
                          children: [
                            SettingTile(
                              title: l.pRnnoiseModel,
                              hint: l.pRnnoiseModelHint,
                              control: DropdownButton<String>(
                                value: rnnModels.any((m) => models.pathOf(m.id) == _items[i].rnnoiseModel)
                                    ? _items[i].rnnoiseModel
                                    : null,
                                onChanged: (v) => setState(() => _items[i] = ChainItem.rnnoise(v, mix: _items[i].mix)),
                                items: [
                                  for (final m in rnnModels)
                                    DropdownMenuItem(value: models.pathOf(m.id), child: Text(modelName(l, m.id))),
                                ],
                              ),
                            ),
                            ValueSlider(
                              title: l.pStrength,
                              hint: l.pRnnoiseMixHint,
                              value: _items[i].mix,
                              min: 0.1,
                              max: 1,
                              divisions: 18,
                              defaultValue: 1,
                              format: (v) => '${(v * 100).round()}%',
                              onChanged: (v) =>
                                  setState(() => _items[i] = ChainItem.rnnoise(_items[i].rnnoiseModel, mix: v)),
                            ),
                          ],
                        )
                      : FxParamEditor(
                          fxId: _items[i].fxId,
                          params: fxById(_items[i].fxId).params,
                          values: _items[i].values,
                          onChanged: (v) => setState(() => _items[i] = ChainItem.fx(_items[i].fxId, v)),
                        ),
                ),
            ],
          ],
        ),
        if (widget.denoise)
          ParamGroup(
            title: l.modelsRnnoise,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(l.modelsRnnoiseHint, style: Theme.of(context).textTheme.bodySmall),
              ),
              const ModelsCard(kind: ModelKind.rnnoise, dense: true),
            ],
          ),
      ],
    );
  }
}

// =================================================================== music

class MusicPage extends ConsumerWidget {
  const MusicPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'mix',
    path: path,
    builder: (i) => _MusicForm(key: ValueKey(i.path), info: i),
  );
}

class _MusicForm extends ConsumerStatefulWidget {
  const _MusicForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_MusicForm> createState() => _MusicFormState();
}

class _MusicFormState extends ConsumerState<_MusicForm> {
  MediaInfo? _music;
  MusicParams _m = const MusicParams();
  String? _output;

  MusicParams _copy({
    double? volumeDb,
    bool? loop,
    bool? duck,
    double? duckAmount,
    Duration? fadeOut,
    Duration? offset,
    bool? keep,
  }) => MusicParams(
    volumeDb: volumeDb ?? _m.volumeDb,
    loop: loop ?? _m.loop,
    duck: duck ?? _m.duck,
    duckAmount: duckAmount ?? _m.duckAmount,
    fadeOut: fadeOut ?? _m.fadeOut,
    offset: offset ?? _m.offset,
    keepOriginal: keep ?? _m.keepOriginal,
  );

  Future<void> _pick() async {
    final f = await openFile();
    final probe = ref.read(probeServiceProvider);
    if (f == null || probe == null) return;
    try {
      final i = await probe.probe(f.path);
      if (mounted) setState(() => _music = i);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.probeFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = audioFxExt(info);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_music'), ext);
    final music = _music;
    final steps = music == null || music.audioStreams.isEmpty
        ? null
        : planMusic(main: info, music: music, output: out, m: _m);
    final hasVoice = info.audioStreams.isNotEmpty && _m.keepOriginal;
    return ToolScaffold(
      toolId: 'mix',
      info: info,
      preview: MediaPreview(path: info.path, aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (music == null) l.musicChoose, if (music != null && music.audioStreams.isEmpty) l.issueNoAudio],
      estimate: info.duration == null ? null : l.resultLength(formatDuration(info.duration, millis: true)),
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'mix',
          title: '${l.toolMix}: ${p.basename(info.path)}',
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
          title: l.groupMusic,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(music == null ? l.musicFile : p.basename(music.path)),
              subtitle: Text(music == null ? l.musicFileHint : formatDuration(music.duration)),
              trailing: OutlinedButton(onPressed: _pick, child: Text(l.choose)),
            ),
            ValueSlider(
              title: l.pMusicVolume,
              hint: l.pMusicVolumeHint,
              value: _m.volumeDb,
              min: -40,
              max: 6,
              divisions: 46,
              defaultValue: -12,
              format: (v) => '${v.round()} dB',
              onChanged: (v) => setState(() => _m = _copy(volumeDb: v)),
            ),
            SettingTile(
              title: l.pMusicLoop,
              hint: l.pMusicLoopHint,
              control: Switch(
                value: _m.loop,
                onChanged: (v) => setState(() => _m = _copy(loop: v)),
              ),
            ),
            SettingTile(
              title: l.pMusicOffset,
              hint: l.pMusicOffsetHint,
              control: DurationField(
                value: _m.offset,
                onChanged: (d) => setState(() => _m = _copy(offset: d ?? Duration.zero)),
              ),
            ),
            ValueSlider(
              title: l.pMusicFadeOut,
              hint: l.pMusicFadeOutHint,
              value: _m.fadeOut.inMilliseconds / 1000,
              min: 0,
              max: 10,
              divisions: 20,
              defaultValue: 3,
              format: (v) => v == 0 ? l.off : '${fnum(v, 1)} ${l.unitSecond}',
              onChanged: (v) => setState(() => _m = _copy(fadeOut: Duration(milliseconds: (v * 1000).round()))),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupOriginalAudio,
          children: [
            if (info.audioStreams.isNotEmpty)
              SettingTile(
                title: l.pKeepOriginalAudio,
                hint: l.pKeepOriginalAudioHint,
                control: Switch(
                  value: _m.keepOriginal,
                  onChanged: (v) => setState(() => _m = _copy(keep: v)),
                ),
              ),
            if (hasVoice) ...[
              SettingTile(
                title: l.pDuck,
                hint: l.pDuckHint,
                help: l.pDuckHelp,
                control: Switch(
                  value: _m.duck,
                  onChanged: (v) => setState(() => _m = _copy(duck: v)),
                ),
              ),
              if (_m.duck)
                ValueSlider(
                  title: l.pDuckAmount,
                  hint: l.pDuckAmountHint,
                  value: _m.duckAmount,
                  min: 2,
                  max: 20,
                  divisions: 18,
                  defaultValue: 8,
                  format: (v) => '1:${v.round()}',
                  onChanged: (v) => setState(() => _m = _copy(duckAmount: v)),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

// ============================================================ transcription

class TranscribePage extends ConsumerWidget {
  const TranscribePage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'transcribe',
    path: path,
    builder: (i) => _TranscribeForm(key: ValueKey(i.path), info: i),
  );
}

class _TranscribeForm extends ConsumerStatefulWidget {
  const _TranscribeForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_TranscribeForm> createState() => _TranscribeFormState();
}

class _TranscribeFormState extends ConsumerState<_TranscribeForm> {
  String? _modelId;
  String _lang = 'auto';
  TranscriptFormat _format = TranscriptFormat.srt;
  bool _gpu = true;
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final models = ref.watch(modelsProvider);
    final caps = ref.watch(capabilitiesProvider).value;
    final hasFilter = caps == null || caps.version == null || caps.hasFilter('whisper');
    final installed = models.installedOf(ModelKind.whisper);
    final modelId = installed.any((m) => m.id == _modelId) ? _modelId : installed.lastOrNull?.id;
    final ext = transcriptExt(_format);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext), ext);
    final steps = modelId == null || !hasFilter || info.audioStreams.isEmpty
        ? null
        : planTranscribe(
            info: info,
            model: models.pathOf(modelId)!,
            output: out,
            language: _lang,
            format: _format,
            useGpu: _gpu,
          );
    return ToolScaffold(
      toolId: 'transcribe',
      info: info,
      preview: MediaPreview(path: info.path, aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [
        if (!hasFilter) l.whisperFilterMissing,
        if (installed.isEmpty) l.whisperNeedsModel,
        if (info.audioStreams.isEmpty) l.issueNoAudio,
      ],
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'transcribe',
          title: '${l.toolTranscribe}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: info.duration,
        ),
        now: now,
      ),
      params: [
        if (!hasFilter)
          ParamGroup(
            title: l.groupNeedsBuild,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), child: Text(l.whisperFilterHelp)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.extension),
                    label: Text(l.openComponents),
                    onPressed: () => ref.read(navProvider.notifier).go(Destination.components),
                  ),
                ),
              ),
            ],
          ),
        ParamGroup(
          title: l.groupRecognition,
          children: [
            SettingTile(
              title: l.pWhisperModel,
              hint: l.pWhisperModelHint,
              help: l.pWhisperModelHelp,
              control: DropdownButton<String>(
                value: modelId,
                hint: Text(l.notSet),
                onChanged: (v) => setState(() => _modelId = v),
                items: [for (final m in installed) DropdownMenuItem(value: m.id, child: Text(modelName(l, m.id)))],
              ),
            ),
            SettingTile(
              title: l.pLanguage,
              hint: l.pLanguageHint,
              control: DropdownButton<String>(
                value: _lang,
                onChanged: (v) => setState(() => _lang = v!),
                items: [
                  for (final c in whisperLanguages)
                    DropdownMenuItem(value: c, child: Text(c == 'auto' ? l.languageAuto : c)),
                ],
              ),
            ),
            SettingTile(
              title: l.pTranscriptFormat,
              hint: l.pTranscriptFormatHint,
              controlBelow: true,
              control: SegmentedButton<TranscriptFormat>(
                segments: [
                  ButtonSegment(value: TranscriptFormat.srt, label: Text(l.formatSrt)),
                  ButtonSegment(value: TranscriptFormat.text, label: Text(l.formatText)),
                  const ButtonSegment(value: TranscriptFormat.json, label: Text('JSON')),
                ],
                selected: {_format},
                onSelectionChanged: (v) => setState(() => _format = v.first),
              ),
            ),
            SettingTile(
              title: l.pUseGpu,
              hint: l.pUseGpuHint,
              control: Switch(value: _gpu, onChanged: (v) => setState(() => _gpu = v)),
            ),
          ],
        ),
        ParamGroup(
          title: l.modelsWhisper,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(l.modelsWhisperHint, style: Theme.of(context).textTheme.bodySmall),
            ),
            const ModelsCard(kind: ModelKind.whisper, dense: true),
          ],
        ),
      ],
    );
  }
}
