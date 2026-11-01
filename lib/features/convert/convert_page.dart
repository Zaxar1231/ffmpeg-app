import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/presets/preset_repository.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/util/format.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/media_preview.dart';
import '../../ui/widgets/setting_tile.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'builtin_presets.dart';
import 'convert_params.dart';
import 'labels.dart';

/// Convert & Compress tool (one screen, different starting presets).
class ConvertPage extends ConsumerWidget {
  const ConvertPage({super.key, required this.toolId, this.path, this.presetId});
  final String toolId;
  final String? path;
  final String? presetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: toolId,
    path: path,
    builder: (info) => _ConvertForm(
      key: ValueKey(info.path),
      toolId: toolId,
      info: info,
      presetId: presetId ?? (toolId == 'compress' ? 'compress' : null),
    ),
  );
}

class _ConvertForm extends ConsumerStatefulWidget {
  const _ConvertForm({super.key, required this.toolId, required this.info, this.presetId});
  final String toolId;
  final MediaInfo info;
  final String? presetId;

  @override
  ConsumerState<_ConvertForm> createState() => _ConvertFormState();
}

class _ConvertFormState extends ConsumerState<_ConvertForm> {
  late ConvertParams _p;
  String? _presetId;
  String? _output;

  @override
  void initState() {
    super.initState();
    _presetId = widget.presetId;
    _p = builtinPresetById(_presetId ?? '')?.params ?? _defaultsFor(widget.info);
    if (_presetId != null && _presetId!.startsWith('user:')) {
      _loadUserPreset(_presetId!.substring(5));
    }
  }

  Future<void> _loadUserPreset(String id) async {
    final up = await ref.read(presetRepositoryProvider).byId(id);
    if (up != null && mounted) setState(() => _p = ConvertParams.fromJson(up.params));
  }

  static ConvertParams _defaultsFor(MediaInfo info) {
    if (info.videoStreams.isEmpty) {
      return const ConvertParams(container: 'mp3', video: VideoCodecChoice.none, audio: AudioCodecChoice.mp3);
    }
    return const ConvertParams();
  }

  void _set(ConvertParams p, {bool keepPreset = false}) => setState(() {
    _p = p;
    if (!keepPreset) _presetId = null;
  });

  String get _out => _output ?? defaultOutput(ref, widget.info.path, ext: _p.container, suffix: '_kadra');

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final env = ref.watch(encodeEnvProvider);
    final advanced = ref.watch(settingsProvider.select((s) => s.advancedMode));
    final info = widget.info;
    final out = withExtension(_out, _p.container);
    final plan = planConvert(info: info, output: out, p: _p, env: env);
    final c = containerFor(_p.container);
    final enc = plan.encoder;
    final hasVideo = info.videoStreams.isNotEmpty && !c.audioOnly;
    final encoding = enc != null;

    final problems = [for (final i in plan.issues) convertIssueText(l, i)];
    final warnings = [
      for (final i in plan.warnings) convertIssueText(l, i),
      if (encoding && (info.videoStreams.first.hdr.index > 0) && !_p.tenBit) l.warnHdrSource,
    ];

    final est = plan.estimatedBytes == null
        ? (encoding ? l.estimateDependsOnContent : null)
        : (_p.rateMode == RateMode.targetSize
              ? l.estimateAtMost(formatBytes(plan.estimatedBytes, units: byteUnits(l)))
              : l.estimateSize(formatBytes(plan.estimatedBytes, units: byteUnits(l))));
    final encoderNote = enc == null ? '' : '  ·  ${l.encoderLabel(enc.name)}${enc.hardware ? ' ⚡' : ''}';

    final userPresets = ref.watch(userPresetsProvider('convert')).value ?? const <UserPreset>[];

    return ToolScaffold(
      toolId: widget.toolId,
      info: info,
      compare: true,
      preview: info.videoStreams.isNotEmpty || info.audioStreams.isNotEmpty
          ? MediaPreview(path: info.path, aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9)
          : null,
      outputPath: out,
      outputExt: _p.container,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: plan.ok ? plan.steps : null,
      problems: problems,
      warnings: warnings,
      estimate: est == null ? null : '$est$encoderNote',
      onSubmit: (now) => submitJob(
        context,
        ref,
        convertJob(plan, info: info, output: out, title: '${l.toolConvert}: ${p.basename(info.path)}'),
        now: now,
      ),
      params: [
        // ------------------------------------------------ presets
        ParamGroup(
          title: l.presetsTitle,
          trailing: TextButton.icon(
            icon: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: Text(l.savePreset),
            onPressed: () => _savePreset(context),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final bp in builtinPresets)
                    if (bp.params.video == VideoCodecChoice.none || hasVideo)
                      Tooltip(
                        message: presetDescription(l, bp.id),
                        child: ChoiceChip(
                          label: Text(presetName(l, bp.id)),
                          selected: _presetId == bp.id,
                          onSelected: (_) => setState(() {
                            _presetId = bp.id;
                            _p = bp.params;
                          }),
                        ),
                      ),
                  for (final up in userPresets)
                    ChoiceChip(
                      avatar: const Icon(Icons.person_outline, size: 16),
                      label: Text(up.name),
                      selected: _presetId == 'user:${up.id}',
                      onSelected: (_) => setState(() {
                        _presetId = 'user:${up.id}';
                        _p = ConvertParams.fromJson(up.params);
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
        // ------------------------------------------------ format
        ParamGroup(
          title: l.groupFormat,
          children: [
            SettingTile(
              title: l.pContainer,
              hint: l.pContainerHint,
              help: l.pContainerHelp,
              control: DropdownButton<String>(
                value: _p.container,
                onChanged: (v) => v == null ? null : _set(_fitCodecs(_p.copyWith(container: v))),
                items: [
                  for (final e in containers.keys)
                    if (hasVideo || containers[e]!.audioOnly) DropdownMenuItem(value: e, child: Text(e.toUpperCase())),
                ],
              ),
            ),
            if (hasVideo)
              SettingTile(
                title: l.pVideoCodec,
                hint: l.pVideoCodecHint,
                help: l.pVideoCodecHelp,
                control: DropdownButton<VideoCodecChoice>(
                  value: _p.video,
                  onChanged: (v) => v == null
                      ? null
                      : _set(
                          _p.copyWith(video: v, quality: () => null, profile: () => null, encoderOverride: () => null),
                        ),
                  items: [
                    for (final v in [...c.video, VideoCodecChoice.copy, VideoCodecChoice.none])
                      DropdownMenuItem(value: v, child: Text(videoCodecLabel(l, v))),
                  ],
                ),
              ),
            if (info.audioStreams.isNotEmpty)
              SettingTile(
                title: l.pAudioCodec,
                hint: l.pAudioCodecHint,
                control: DropdownButton<AudioCodecChoice>(
                  value: _p.audio,
                  onChanged: (v) => v == null ? null : _set(_p.copyWith(audio: v, audioKbps: () => null)),
                  items: [
                    for (final a in [...c.audio, AudioCodecChoice.copy, if (!c.audioOnly) AudioCodecChoice.none])
                      DropdownMenuItem(value: a, child: Text(audioCodecLabel(l, a))),
                  ],
                ),
              ),
            if (_p.video == VideoCodecChoice.copy || (_p.audio == AudioCodecChoice.copy && !hasVideo))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TagChip(l.losslessTag, icon: Icons.bolt, color: Theme.of(context).colorScheme.tertiaryContainer),
              ),
          ],
        ),
        // ------------------------------------------------ video
        if (encoding) _videoGroup(context, enc, advanced, env.hw != null),
        // ------------------------------------------------ audio
        if (info.audioStreams.isNotEmpty && audioEncoders[_p.audio]?.defaultKbps != null)
          _audioGroup(context, advanced),
        // ------------------------------------------------ other
        if (advanced || c.subtitles || c.faststart)
          ParamGroup(
            title: l.groupOther,
            children: [
              if (c.faststart)
                SettingTile(
                  title: l.pFaststart,
                  hint: l.pFaststartHint,
                  help: l.pFaststartHelp,
                  control: Switch(
                    value: _p.faststart,
                    onChanged: (v) => _set(_p.copyWith(faststart: v)),
                  ),
                ),
              if (c.subtitles && info.subtitleStreams.isNotEmpty)
                SettingTile(
                  title: l.pKeepSubs,
                  hint: l.pKeepSubsHint,
                  control: Switch(
                    value: _p.keepSubtitles,
                    onChanged: (v) => _set(_p.copyWith(keepSubtitles: v)),
                  ),
                ),
              if (advanced)
                SettingTile(
                  title: l.pKeepMetadata,
                  hint: l.pKeepMetadataHint,
                  control: Switch(
                    value: _p.keepMetadata,
                    onChanged: (v) => _set(_p.copyWith(keepMetadata: v)),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// After a container change, pick codecs the container accepts.
  ConvertParams _fitCodecs(ConvertParams p) {
    final c = containerFor(p.container);
    var v = p.video;
    var a = p.audio;
    if (v != VideoCodecChoice.copy && v != VideoCodecChoice.none && !c.video.contains(v)) {
      v = c.video.isEmpty ? VideoCodecChoice.none : c.video.first;
    }
    if (c.audioOnly) v = VideoCodecChoice.none;
    if (!c.audioOnly && v == VideoCodecChoice.none && widget.info.videoStreams.isNotEmpty) v = c.video.first;
    if (a != AudioCodecChoice.copy && a != AudioCodecChoice.none && !c.audio.contains(a)) a = c.audio.first;
    return p.copyWith(video: v, audio: a, quality: v == p.video ? null : () => null);
  }

  Widget _videoGroup(BuildContext context, VideoEncoderSpec enc, bool advanced, bool hwKnown) {
    final l = context.l10n;
    final env = ref.read(encodeEnvProvider);
    final q = (_p.quality ?? enc.qualityDefault).clamp(enc.qualityMin, enc.qualityMax);
    final alternatives = availableEncodersFor(_p.video, env.caps);
    return ParamGroup(
      title: l.groupVideo,
      children: [
        if (enc.choice == VideoCodecChoice.h264 ||
            enc.choice == VideoCodecChoice.hevc ||
            enc.choice == VideoCodecChoice.av1)
          SettingTile(
            title: l.pHardware,
            hint: enc.hardware ? l.pHardwareOn(enc.name) : l.pHardwareOff(enc.name),
            help: l.pHardwareHelp,
            control: Switch(
              value: _p.useHardware,
              onChanged: (v) => _set(_p.copyWith(useHardware: v, quality: () => null, encoderOverride: () => null)),
            ),
          ),
        if (advanced && alternatives.length > 1)
          SettingTile(
            title: l.pEncoder,
            hint: l.pEncoderHint,
            control: DropdownButton<String?>(
              value: _p.encoderOverride,
              onChanged: (v) => _set(_p.copyWith(encoderOverride: () => v, quality: () => null)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.auto)),
                for (final e in alternatives) DropdownMenuItem(value: e.name, child: Text(e.name)),
              ],
            ),
          ),
        if (enc.profiles.isNotEmpty && !enc.hasQuality)
          SettingTile(
            title: l.pProfile,
            hint: l.pIntermediateProfileHint,
            help: l.pIntermediateProfileHelp,
            control: DropdownButton<String>(
              value: enc.profiles.contains(_p.profile) ? _p.profile : (enc.name == 'prores_ks' ? 'hq' : 'dnxhr_hq'),
              onChanged: (v) => _set(_p.copyWith(profile: () => v)),
              items: [for (final pr in enc.profiles) DropdownMenuItem(value: pr, child: Text(pr))],
            ),
          ),
        if (enc.hasBitrate)
          SettingTile(
            title: l.pRateMode,
            hint: l.pRateModeHint,
            help: l.pRateModeHelp,
            controlBelow: true,
            control: SegmentedButton<RateMode>(
              showSelectedIcon: false,
              segments: [
                for (final m in RateMode.values)
                  if (advanced || m != RateMode.cbr) ButtonSegment(value: m, label: Text(rateModeLabel(l, m))),
              ],
              selected: {_p.rateMode},
              onSelectionChanged: (v) => _set(_p.copyWith(rateMode: v.first)),
            ),
          ),
        if (enc.hasQuality && (_p.rateMode == RateMode.quality || !enc.hasBitrate))
          SettingTile(
            title: l.pQuality(
              enc.name.contains('nvenc')
                  ? 'CQ'
                  : (enc.name.contains('x26') ||
                            enc.name.contains('svt') ||
                            enc.name.contains('vpx') ||
                            enc.name.contains('aom')
                        ? 'CRF'
                        : 'QP'),
            ),
            hint: l.pQualityHint,
            help: l.pQualityHelp(enc.qualityDefault),
            isDefault: _p.quality == null,
            onReset: () => _set(_p.copyWith(quality: () => null), keepPreset: true),
            controlBelow: true,
            control: ZonedSlider(
              value: q.toDouble(),
              min: enc.qualityMin.toDouble(),
              max: enc.qualityMax.toDouble(),
              divisions: enc.qualityMax - enc.qualityMin,
              leftLabel: l.zoneBetterQuality,
              rightLabel: l.zoneSmallerFile,
              onChanged: (v) => _set(_p.copyWith(quality: () => v.round())),
            ),
          ),
        if (_p.rateMode == RateMode.bitrate || _p.rateMode == RateMode.cbr)
          SettingTile(
            title: l.pVideoBitrate,
            hint: l.pVideoBitrateHint,
            help: l.pVideoBitrateHelp,
            control: _NumberField(
              value: _p.videoKbps.toDouble(),
              suffix: l.unitKbps,
              onChanged: (v) => _set(_p.copyWith(videoKbps: v.round().clamp(50, 500000))),
            ),
          ),
        if (_p.rateMode == RateMode.targetSize)
          SettingTile(
            title: l.pTargetSize,
            hint: l.pTargetSizeHint,
            help: l.pTargetSizeHelp,
            control: _NumberField(
              value: _p.targetSizeMb,
              suffix: l.unitMB,
              decimals: true,
              onChanged: (v) => _set(_p.copyWith(targetSizeMb: v.clamp(0.1, 100000))),
            ),
          ),
        if (advanced &&
            (_p.rateMode == RateMode.bitrate || _p.rateMode == RateMode.targetSize) &&
            enc.twoPass != TwoPassStyle.none)
          SettingTile(
            title: l.pTwoPass,
            hint: l.pTwoPassHint,
            help: l.pTwoPassHelp,
            control: Switch(
              value: _p.twoPass,
              onChanged: (v) => _set(_p.copyWith(twoPass: v)),
            ),
          ),
        if (enc.presets.isNotEmpty)
          SettingTile(
            title: l.pSpeed,
            hint: l.pSpeedHint,
            help: l.pSpeedHelp,
            controlBelow: true,
            control: SegmentedButton<SpeedPreset>(
              showSelectedIcon: false,
              segments: [for (final s in SpeedPreset.values) ButtonSegment(value: s, label: Text(speedLabel(l, s)))],
              selected: {_p.speed},
              onSelectionChanged: (v) => _set(_p.copyWith(speed: v.first)),
            ),
          ),
        SettingTile(
          title: l.pResolution,
          hint: l.pResolutionHint,
          help: l.pResolutionHelp,
          control: DropdownButton<int?>(
            value: _p.maxHeight,
            onChanged: (v) => _set(_p.copyWith(maxHeight: () => v)),
            items: [
              DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
              for (final h in const [2160, 1440, 1080, 720, 480, 360]) DropdownMenuItem(value: h, child: Text('${h}p')),
            ],
          ),
        ),
        SettingTile(
          title: l.pFps,
          hint: l.pFpsHint,
          control: DropdownButton<double?>(
            value: _p.fps,
            onChanged: (v) => _set(_p.copyWith(fps: () => v)),
            items: [
              DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
              for (final f in const [60.0, 50.0, 30.0, 25.0, 24.0])
                DropdownMenuItem(value: f, child: Text(formatFps(f))),
            ],
          ),
        ),
        if (enc.supportsTenBit && (advanced || _p.tenBit))
          SettingTile(
            title: l.pTenBit,
            hint: l.pTenBitHint,
            help: l.pTenBitHelp,
            control: Switch(
              value: _p.tenBit,
              onChanged: (v) => _set(_p.copyWith(tenBit: v)),
            ),
          ),
        if (advanced && enc.profiles.isNotEmpty && enc.hasQuality)
          SettingTile(
            title: l.pProfile,
            hint: l.pProfileHint,
            control: DropdownButton<String?>(
              value: enc.profiles.contains(_p.profile) ? _p.profile : null,
              onChanged: (v) => _set(_p.copyWith(profile: () => v)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.auto)),
                for (final pr in enc.profiles) DropdownMenuItem(value: pr, child: Text(pr)),
              ],
            ),
          ),
        if (advanced && enc.tunes.isNotEmpty)
          SettingTile(
            title: l.pTune,
            hint: l.pTuneHint,
            help: l.pTuneHelp,
            control: DropdownButton<String?>(
              value: enc.tunes.contains(_p.tune) ? _p.tune : null,
              onChanged: (v) => _set(_p.copyWith(tune: () => v)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.none)),
                for (final t in enc.tunes) DropdownMenuItem(value: t, child: Text(t)),
              ],
            ),
          ),
        if (advanced)
          SettingTile(
            title: l.pKeyint,
            hint: l.pKeyintHint,
            help: l.pKeyintHelp,
            control: DropdownButton<double?>(
              value: _p.keyframeSeconds,
              onChanged: (v) => _set(_p.copyWith(keyframeSeconds: () => v)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.auto)),
                for (final s in const [0.5, 1.0, 2.0, 5.0, 10.0])
                  DropdownMenuItem(value: s, child: Text(l.secondsShort(formatFps(s)))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _audioGroup(BuildContext context, bool advanced) {
    final l = context.l10n;
    final def = audioEncoders[_p.audio]!.defaultKbps!;
    return ParamGroup(
      title: l.groupAudio,
      children: [
        SettingTile(
          title: l.pAudioBitrate,
          hint: l.pAudioBitrateHint,
          help: l.pAudioBitrateHelp,
          control: DropdownButton<int>(
            value: _p.audioKbps ?? def,
            onChanged: (v) => _set(_p.copyWith(audioKbps: () => v)),
            items: [
              for (final k in {64, 96, 128, 160, 192, 256, 320, 448, 640, def}.toList()..sort())
                DropdownMenuItem(value: k, child: Text('$k ${l.unitKbps}')),
            ],
          ),
        ),
        SettingTile(
          title: l.pChannels,
          hint: l.pChannelsHint,
          control: DropdownButton<int?>(
            value: _p.audioChannels,
            onChanged: (v) => _set(_p.copyWith(audioChannels: () => v)),
            items: [
              DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
              DropdownMenuItem(value: 2, child: Text(l.stereo)),
              DropdownMenuItem(value: 1, child: Text(l.mono)),
            ],
          ),
        ),
        if (advanced)
          SettingTile(
            title: l.pSampleRate,
            hint: l.pSampleRateHint,
            control: DropdownButton<int?>(
              value: _p.sampleRate,
              onChanged: (v) => _set(_p.copyWith(sampleRate: () => v)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                for (final r in const [48000, 44100, 32000, 22050])
                  DropdownMenuItem(value: r, child: Text('$r ${l.unitHz}')),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _savePreset(BuildContext context) async {
    final l = context.l10n;
    final name = await promptText(context, title: l.savePreset, label: l.presetNameLabel);
    if (name == null || name.trim().isEmpty) return;
    final id = await ref.read(presetRepositoryProvider).save(toolId: 'convert', name: name.trim(), params: _p.toJson());
    if (mounted) setState(() => _presetId = 'user:$id');
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({required this.value, required this.onChanged, this.suffix, this.decimals = false});
  final double value;
  final ValueChanged<double> onChanged;
  final String? suffix;
  final bool decimals;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _c = TextEditingController(text: _fmt(widget.value));

  String _fmt(double v) => widget.decimals ? formatFps(v) : v.round().toString();

  @override
  void didUpdateWidget(covariant _NumberField old) {
    super.didUpdateWidget(old);
    final cur = double.tryParse(_c.text.replaceAll(',', '.'));
    if (cur != widget.value) _c.text = _fmt(widget.value);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: TextField(
      controller: _c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(isDense: true, suffixText: widget.suffix),
      onChanged: (t) {
        final v = double.tryParse(t.replaceAll(',', '.'));
        if (v != null && v > 0) widget.onChanged(v);
      },
    ),
  );
}

/// Simple text prompt dialog.
Future<String?> promptText(BuildContext context, {required String title, required String label, String initial = ''}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(ctx.l10n.save)),
      ],
    ),
  );
}
