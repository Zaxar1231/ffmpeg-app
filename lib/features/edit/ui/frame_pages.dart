import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/engine/ffmpeg_command.dart';
import '../../../core/probe/media_info.dart';
import '../../../core/providers.dart';
import '../../../core/util/format.dart';
import '../../../ui/l10n.dart';
import '../../../ui/widgets/media_preview.dart';
import '../../../ui/widgets/setting_tile.dart';
import '../../tools/tool_scaffold.dart';
import '../../../core/queue/job_steps.dart';
import '../graphs.dart';
import 'edit_widgets.dart';

ToolInputLoader _loader(String id, String? path, Widget Function(MediaInfo) b) =>
    ToolInputLoader(toolId: id, path: path, builder: b);

String _deg(double v) => '${fnum(v, 1)}°';

// ============================================================ crop & scale

const _aspects = <String, double?>{
  'orig': null,
  '16:9': 16 / 9,
  '9:16': 9 / 16,
  '1:1': 1,
  '4:5': 4 / 5,
  '4:3': 4 / 3,
  '21:9': 21 / 9,
};

class CropScalePage extends ConsumerWidget {
  const CropScalePage({super.key, this.path, this.initialCrop});
  final String? path;
  final CropRect? initialCrop;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('cropScale', path, (i) => _CropScaleForm(key: ValueKey(i.path), info: i, initialCrop: initialCrop));
}

class _CropScaleForm extends ConsumerStatefulWidget {
  const _CropScaleForm({super.key, required this.info, this.initialCrop});
  final MediaInfo info;
  final CropRect? initialCrop;
  @override
  ConsumerState<_CropScaleForm> createState() => _CropScaleFormState();
}

class _CropScaleFormState extends ConsumerState<_CropScaleForm> {
  late CropRect? _crop = widget.initialCrop;
  bool _editCrop = false;
  int _rotate = 0;
  double _angle = 0;
  bool _hflip = false, _vflip = false;
  String _aspect = 'orig';
  int? _height;
  FitMode _fit = FitMode.fit;
  bool _detecting = false;
  Duration? _at;

  CropScaleParams get _p => CropScaleParams(
    crop: _crop,
    rotate: _rotate,
    angle: _angle,
    hflip: _hflip,
    vflip: _vflip,
    aspect: _aspects[_aspect],
    height: _height,
    fit: _fit,
  );

  Future<void> _detect() async {
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null) return;
    setState(() => _detecting = true);
    final d = widget.info.duration ?? Duration.zero;
    final start = d > const Duration(seconds: 20) ? d * 0.2 : Duration.zero;
    final r = await ref.read(processRunnerProvider).capture(ffmpeg, [
      '-hide_banner', '-nostdin', '-ss', formatTimestamp(start), '-i', widget.info.path, //
      '-t', '10', '-map', '0:v:0', '-vf', 'cropdetect=round=2', '-f', 'null', '-',
    ]);
    final c = parseCropdetect(r.stderr.split('\n'));
    if (!mounted) return;
    setState(() {
      _detecting = false;
      final (w, h) = displaySize(widget.info);
      if (c != null && (c.w < w || c.h < h)) {
        _crop = c;
      }
    });
    if (c == null || _crop != c) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.cropNothingFound)));
    }
  }

  void _vertical() => setState(() {
    _aspect = '9:16';
    _height = 1920;
    _fit = FitMode.blur;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final params = _p;
    final graph = params.isIdentity ? null : cropScaleGraph(info, params);
    final (fw, fh) = frameSize(info, params);
    final (sw, sh) = displaySize(info);
    return EditScaffold(
      toolId: 'cropScale',
      compare: true,
      info: info,
      suffix: '_${fw}x$fh',
      graph: graph,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo, if (params.isIdentity) l.nothingChanged],
      estimate: l.frameSizeResult('$sw×$sh', '$fw×$fh'),
      preview: info.videoStreams.isEmpty
          ? null
          : FramePreview(
              info: info,
              graph: graph,
              initialTime: _at,
              onTimeChanged: (t) => _at = t,
              rects: _editCrop ? [?_crop] : null,
              onRectsChanged: (r) => setState(() => _crop = r.lastOrNull),
            ),
      params: [
        ParamGroup(
          title: l.groupCrop,
          children: [
            SettingTile(
              title: l.pCropEdit,
              hint: _crop == null
                  ? l.pCropEditHint
                  : l.cropRectLabel('${_crop!.w}×${_crop!.h}', '${_crop!.x}', '${_crop!.y}'),
              control: Switch(value: _editCrop, onChanged: (v) => setState(() => _editCrop = v)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: _detecting
                        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome),
                    label: Text(l.cropAutodetect),
                    onPressed: _detecting ? null : _detect,
                  ),
                  if (_crop != null)
                    TextButton.icon(
                      icon: const Icon(Icons.close),
                      label: Text(l.cropReset),
                      onPressed: () => setState(() => _crop = null),
                    ),
                ],
              ),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupRotate,
          children: [
            SettingTile(
              title: l.pRotate,
              hint: l.pRotateHint,
              controlBelow: true,
              control: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('0°')),
                  ButtonSegment(value: 90, icon: Icon(Icons.rotate_right), label: Text('90°')),
                  ButtonSegment(value: 180, label: Text('180°')),
                  ButtonSegment(value: 270, icon: Icon(Icons.rotate_left), label: Text('270°')),
                ],
                selected: {_rotate},
                onSelectionChanged: (v) => setState(() => _rotate = v.first),
              ),
            ),
            SettingTile(
              title: l.pFlipH,
              hint: l.pFlipHHint,
              control: Switch(value: _hflip, onChanged: (v) => setState(() => _hflip = v)),
            ),
            SettingTile(
              title: l.pFlipV,
              hint: l.pFlipVHint,
              control: Switch(value: _vflip, onChanged: (v) => setState(() => _vflip = v)),
            ),
            ValueSlider(
              title: l.pAngle,
              hint: l.pAngleHint,
              value: _angle,
              min: -45,
              max: 45,
              divisions: 180,
              defaultValue: 0,
              format: _deg,
              onChanged: (v) => setState(() => _angle = v),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupFrame,
          trailing: TextButton.icon(
            icon: const Icon(Icons.stay_current_portrait),
            label: Text(l.makeVertical),
            onPressed: _vertical,
          ),
          children: [
            SettingTile(
              title: l.pAspect,
              hint: l.pAspectHint,
              control: DropdownButton<String>(
                value: _aspect,
                onChanged: (v) => setState(() => _aspect = v!),
                items: [
                  for (final a in _aspects.keys)
                    DropdownMenuItem(value: a, child: Text(a == 'orig' ? l.keepOriginal : a)),
                ],
              ),
            ),
            SettingTile(
              title: l.pFrameHeight,
              hint: l.pFrameHeightHint,
              control: DropdownButton<int?>(
                value: _height,
                onChanged: (v) => setState(() => _height = v),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                  for (final h in const [2160, 1920, 1440, 1080, 720, 480, 360])
                    DropdownMenuItem(value: h, child: Text('$h')),
                ],
              ),
            ),
            if (_aspect != 'orig')
              SettingTile(
                title: l.pFit,
                hint: switch (_fit) {
                  FitMode.fit => l.fitFitHint,
                  FitMode.fill => l.fitFillHint,
                  FitMode.stretch => l.fitStretchHint,
                  FitMode.blur => l.fitBlurHint,
                },
                controlBelow: true,
                control: SegmentedButton<FitMode>(
                  segments: [
                    ButtonSegment(value: FitMode.fit, label: Text(l.fitFit)),
                    ButtonSegment(value: FitMode.fill, label: Text(l.fitFill)),
                    ButtonSegment(value: FitMode.blur, label: Text(l.fitBlur)),
                    ButtonSegment(value: FitMode.stretch, label: Text(l.fitStretch)),
                  ],
                  selected: {_fit},
                  onSelectionChanged: (v) => setState(() => _fit = v.first),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// =================================================================== speed

class SpeedPage extends ConsumerWidget {
  const SpeedPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('speed', path, (i) => _SpeedForm(key: ValueKey(i.path), info: i));
}

class _SpeedForm extends StatefulWidget {
  const _SpeedForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_SpeedForm> createState() => _SpeedFormState();
}

class _SpeedFormState extends State<_SpeedForm> {
  SpeedParams _s = const SpeedParams();

  SpeedParams _copy({double? factor, SpeedAudio? audio, bool? reverse, double? Function()? fps, bool? interpolate}) =>
      SpeedParams(
        factor: factor ?? _s.factor,
        audio: audio ?? _s.audio,
        reverse: reverse ?? _s.reverse,
        fps: fps != null ? fps() : _s.fps,
        interpolate: interpolate ?? _s.interpolate,
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final unchanged = _s.factor == 1 && !_s.reverse && _s.fps == null && !_s.interpolate && _s.audio != SpeedAudio.mute;
    final long = (info.duration ?? Duration.zero) > const Duration(minutes: 2);
    return EditScaffold(
      toolId: 'speed',
      info: info,
      suffix: _s.reverse ? '_reverse' : '_x${fnum(_s.factor, 2)}',
      preview: MediaPreview(path: info.path, aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9),
      graph: unchanged ? null : speedGraph(info, _s),
      problems: [if (unchanged) l.nothingChanged],
      warnings: [
        if (_s.reverse && long) l.reverseMemoryWarning,
        if (_s.interpolate) l.interpolateSlowWarning,
        if (_s.audio == SpeedAudio.keepPitch && (_s.factor < 0.5 || _s.factor > 2)) l.atempoQualityNote,
      ],
      params: [
        ParamGroup(
          title: l.groupSpeed,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final f in const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 4.0, 8.0])
                    ChoiceChip(
                      label: Text('×${fnum(f, 2)}'),
                      selected: _s.factor == f,
                      onSelected: (_) => setState(() => _s = _copy(factor: f)),
                    ),
                ],
              ),
            ),
            ValueSlider(
              title: l.pSpeedFactor,
              hint: l.pSpeedFactorHint,
              value: _s.factor,
              min: 0.1,
              max: 10,
              divisions: 198,
              defaultValue: 1,
              format: (v) => '×${fnum(v, 2)}',
              onChanged: (v) => setState(() => _s = _copy(factor: double.parse(v.toStringAsFixed(2)))),
            ),
            if (info.audioStreams.isNotEmpty)
              SettingTile(
                title: l.pSpeedAudio,
                hint: switch (_s.audio) {
                  SpeedAudio.keepPitch => l.speedAudioKeepHint,
                  SpeedAudio.changePitch => l.speedAudioPitchHint,
                  SpeedAudio.mute => l.speedAudioMuteHint,
                },
                controlBelow: true,
                control: SegmentedButton<SpeedAudio>(
                  segments: [
                    ButtonSegment(value: SpeedAudio.keepPitch, label: Text(l.speedAudioKeep)),
                    ButtonSegment(value: SpeedAudio.changePitch, label: Text(l.speedAudioPitch)),
                    ButtonSegment(value: SpeedAudio.mute, label: Text(l.speedAudioMute)),
                  ],
                  selected: {_s.audio},
                  onSelectionChanged: (v) => setState(() => _s = _copy(audio: v.first)),
                ),
              ),
            SettingTile(
              title: l.pReverse,
              hint: l.pReverseHint,
              control: Switch(
                value: _s.reverse,
                onChanged: (v) => setState(() => _s = _copy(reverse: v)),
              ),
            ),
          ],
        ),
        if (info.videoStreams.isNotEmpty)
          ParamGroup(
            title: l.groupFrameRate,
            children: [
              SettingTile(
                title: l.pSpeedFps,
                hint: l.pSpeedFpsHint(fnum(fpsOf(info), 2)),
                control: DropdownButton<double?>(
                  value: _s.fps,
                  onChanged: (v) => setState(() => _s = _copy(fps: () => v)),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                    for (final f in const [15.0, 24.0, 25.0, 30.0, 50.0, 60.0, 120.0])
                      DropdownMenuItem(value: f, child: Text('${fnum(f)} ${l.unitFps}')),
                  ],
                ),
              ),
              SettingTile(
                title: l.pInterpolate,
                hint: l.pInterpolateHint,
                help: l.pInterpolateHelp,
                control: Switch(
                  value: _s.interpolate,
                  onChanged: (v) => setState(() => _s = _copy(interpolate: v)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ================================================================= restore

class RestorePage extends ConsumerWidget {
  const RestorePage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('restore', path, (i) => _RestoreForm(key: ValueKey(i.path), info: i));
}

class _RestoreForm extends ConsumerStatefulWidget {
  const _RestoreForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_RestoreForm> createState() => _RestoreFormState();
}

class _RestoreFormState extends ConsumerState<_RestoreForm> {
  late RestoreParams _r = RestoreParams(deinterlace: _interlaced ? Deinterlace.bwdif : Deinterlace.off);

  bool get _interlaced {
    final fo = widget.info.videoStreams.firstOrNull?.fieldOrder;
    return fo != null && fo != 'progressive' && fo != 'unknown';
  }

  RestoreParams _copy({
    Deinterlace? deinterlace,
    Denoise? denoise,
    Sharpen? sharpen,
    bool? stabilize,
    int? shakiness,
    int? smoothing,
  }) => RestoreParams(
    deinterlace: deinterlace ?? _r.deinterlace,
    denoise: denoise ?? _r.denoise,
    sharpen: sharpen ?? _r.sharpen,
    stabilize: stabilize ?? _r.stabilize,
    shakiness: shakiness ?? _r.shakiness,
    smoothing: smoothing ?? _r.smoothing,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final caps = ref.watch(capabilitiesProvider).value;
    final vidstab = caps == null || caps.version == null || caps.hasFilter('vidstabdetect');
    final r = RestoreParams(
      deinterlace: _r.deinterlace,
      denoise: _r.denoise,
      sharpen: _r.sharpen,
      stabilize: _r.stabilize,
      shakiness: _r.shakiness,
      smoothing: _r.smoothing,
      useVidstab: vidstab,
    );
    final unchanged =
        r.deinterlace == Deinterlace.off && r.denoise == Denoise.off && r.sharpen == Sharpen.off && !r.stabilize;
    final twoPass = r.stabilize && vidstab;
    // The preview cannot run the stabilizer (it needs pass 1).
    final previewGraph = restoreGraph(info, _copy(stabilize: false));
    return EditScaffold(
      toolId: 'restore',
      compare: true,
      info: info,
      suffix: '_restored',
      graph: unchanged ? null : restoreGraph(info, r),
      preSteps: twoPass
          ? [
              JobStep(
                args: vidstabDetectArgs(info, r),
                workingDirectory: '{{tmp}}',
                label: l.stepAnalyzeMotion,
                weight: 0.4,
                totalDuration: info.duration,
              ),
            ]
          : const [],
      workingDirectory: twoPass ? '{{tmp}}' : null,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo, if (unchanged) l.nothingChanged],
      warnings: [if (r.stabilize && !vidstab) l.vidstabMissing, if (r.denoise == Denoise.nlmeans) l.nlmeansSlowWarning],
      preview: info.videoStreams.isEmpty ? null : FramePreview(info: info, graph: previewGraph),
      params: [
        ParamGroup(
          title: l.groupRestore,
          children: [
            SettingTile(
              title: l.pDeinterlace,
              hint: _interlaced ? l.deinterlaceDetected : l.pDeinterlaceHint,
              help: l.pDeinterlaceHelp,
              control: DropdownButton<Deinterlace>(
                value: _r.deinterlace,
                onChanged: (v) => setState(() => _r = _copy(deinterlace: v)),
                items: [
                  DropdownMenuItem(value: Deinterlace.off, child: Text(l.off)),
                  const DropdownMenuItem(value: Deinterlace.bwdif, child: Text('bwdif')),
                  const DropdownMenuItem(value: Deinterlace.yadif, child: Text('yadif')),
                ],
              ),
            ),
            SettingTile(
              title: l.pVideoDenoise,
              hint: l.pVideoDenoiseHint,
              help: l.pVideoDenoiseHelp,
              control: DropdownButton<Denoise>(
                value: _r.denoise,
                onChanged: (v) => setState(() => _r = _copy(denoise: v)),
                items: [
                  DropdownMenuItem(value: Denoise.off, child: Text(l.off)),
                  DropdownMenuItem(value: Denoise.light, child: Text(l.levelLight)),
                  DropdownMenuItem(value: Denoise.medium, child: Text(l.levelMedium)),
                  DropdownMenuItem(value: Denoise.strong, child: Text(l.levelStrong)),
                  DropdownMenuItem(value: Denoise.nlmeans, child: Text(l.denoiseNlmeans)),
                ],
              ),
            ),
            SettingTile(
              title: l.pSharpen,
              hint: l.pSharpenHint,
              control: DropdownButton<Sharpen>(
                value: _r.sharpen,
                onChanged: (v) => setState(() => _r = _copy(sharpen: v)),
                items: [
                  DropdownMenuItem(value: Sharpen.off, child: Text(l.off)),
                  DropdownMenuItem(value: Sharpen.light, child: Text(l.levelLight)),
                  DropdownMenuItem(value: Sharpen.medium, child: Text(l.levelMedium)),
                  DropdownMenuItem(value: Sharpen.strong, child: Text(l.levelStrong)),
                  DropdownMenuItem(value: Sharpen.cas, child: Text(l.sharpenCas)),
                ],
              ),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupStabilize,
          children: [
            SettingTile(
              title: l.pStabilize,
              hint: vidstab ? l.pStabilizeHint : l.pStabilizeDeshakeHint,
              help: l.pStabilizeHelp,
              control: Switch(
                value: _r.stabilize,
                onChanged: (v) => setState(() => _r = _copy(stabilize: v)),
              ),
            ),
            if (_r.stabilize && vidstab) ...[
              ValueSlider(
                title: l.pShakiness,
                hint: l.pShakinessHint,
                value: _r.shakiness.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                defaultValue: 5,
                format: (v) => '${v.round()}',
                onChanged: (v) => setState(() => _r = _copy(shakiness: v.round())),
              ),
              ValueSlider(
                title: l.pSmoothing,
                hint: l.pSmoothingHint,
                value: _r.smoothing.toDouble(),
                min: 2,
                max: 60,
                divisions: 58,
                defaultValue: 15,
                format: (v) => '${v.round()}',
                onChanged: (v) => setState(() => _r = _copy(smoothing: v.round())),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// =================================================================== color

class ColorPage extends ConsumerWidget {
  const ColorPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('color', path, (i) => _ColorForm(key: ValueKey(i.path), info: i));
}

class _ColorForm extends StatefulWidget {
  const _ColorForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_ColorForm> createState() => _ColorFormState();
}

class _ColorFormState extends State<_ColorForm> {
  double _brightness = 0, _contrast = 1, _saturation = 1, _gamma = 1, _hue = 0, _temperature = 6500, _lutMix = 1;
  ColorLook _look = ColorLook.none;
  bool _vignette = false;
  String? _lut;

  ColorParams get _c => ColorParams(
    brightness: _brightness,
    contrast: _contrast,
    saturation: _saturation,
    gamma: _gamma,
    hue: _hue,
    temperature: _temperature,
    look: _look,
    vignette: _vignette,
    lutPath: _lut,
    lutMix: _lutMix,
  );

  void _reset() => setState(() {
    _brightness = 0;
    _contrast = 1;
    _saturation = 1;
    _gamma = 1;
    _hue = 0;
    _temperature = 6500;
    _look = ColorLook.none;
    _vignette = false;
    _lut = null;
    _lutMix = 1;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final c = _c;
    final unchanged = colorFilters(c).isEmpty;
    final graph = unchanged ? null : colorGraph(info, c);
    return EditScaffold(
      toolId: 'color',
      compare: true,
      info: info,
      suffix: '_color',
      graph: graph,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo, if (unchanged) l.nothingChanged],
      preview: info.videoStreams.isEmpty ? null : FramePreview(info: info, graph: graph),
      params: [
        ParamGroup(
          title: l.groupColorBasic,
          trailing: TextButton(onPressed: unchanged ? null : _reset, child: Text(l.resetTooltip)),
          children: [
            ValueSlider(
              title: l.pBrightness,
              hint: l.pBrightnessHint,
              value: _brightness,
              min: -0.5,
              max: 0.5,
              divisions: 100,
              defaultValue: 0,
              onChanged: (v) => setState(() => _brightness = v),
            ),
            ValueSlider(
              title: l.pContrast,
              hint: l.pContrastHint,
              value: _contrast,
              min: 0.5,
              max: 2,
              divisions: 75,
              defaultValue: 1,
              onChanged: (v) => setState(() => _contrast = v),
            ),
            ValueSlider(
              title: l.pSaturation,
              hint: l.pSaturationHint,
              value: _saturation,
              min: 0,
              max: 3,
              divisions: 60,
              defaultValue: 1,
              onChanged: (v) => setState(() => _saturation = v),
            ),
            ValueSlider(
              title: l.pGamma,
              hint: l.pGammaHint,
              value: _gamma,
              min: 0.5,
              max: 2,
              divisions: 75,
              defaultValue: 1,
              onChanged: (v) => setState(() => _gamma = v),
            ),
            ValueSlider(
              title: l.pHue,
              hint: l.pHueHint,
              value: _hue,
              min: -180,
              max: 180,
              divisions: 72,
              defaultValue: 0,
              format: _deg,
              onChanged: (v) => setState(() => _hue = v),
            ),
            ValueSlider(
              title: l.pTemperature,
              hint: l.pTemperatureHint,
              value: _temperature,
              min: 2000,
              max: 12000,
              divisions: 100,
              defaultValue: 6500,
              format: (v) => '${v.round()} K',
              onChanged: (v) => setState(() => _temperature = v),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupLook,
          children: [
            SettingTile(
              title: l.pLook,
              hint: l.pLookHint,
              control: DropdownButton<ColorLook>(
                value: _look,
                onChanged: (v) => setState(() => _look = v!),
                items: [for (final k in ColorLook.values) DropdownMenuItem(value: k, child: Text(lookName(l, k)))],
              ),
            ),
            SettingTile(
              title: l.pVignette,
              hint: l.pVignetteHint,
              control: Switch(value: _vignette, onChanged: (v) => setState(() => _vignette = v)),
            ),
            SettingTile(
              title: l.pLut,
              hint: _lut == null ? l.pLutHint : p.basename(_lut!),
              help: l.pLutHelp,
              control: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_lut != null)
                    IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _lut = null)),
                  OutlinedButton(
                    onPressed: () async {
                      final f = await openFile(
                        acceptedTypeGroups: const [
                          XTypeGroup(label: 'LUT', extensions: ['cube', '3dl', 'dat', 'm3d', 'csp']),
                        ],
                      );
                      if (f != null) setState(() => _lut = f.path);
                    },
                    child: Text(l.choose),
                  ),
                ],
              ),
            ),
            if (_lut != null)
              ValueSlider(
                title: l.pLutMix,
                hint: l.pLutMixHint,
                value: _lutMix,
                min: 0.05,
                max: 1,
                divisions: 19,
                defaultValue: 1,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _lutMix = v),
              ),
          ],
        ),
      ],
    );
  }
}

String lookName(AppLocalizations l, ColorLook k) => switch (k) {
  ColorLook.none => l.none,
  ColorLook.grayscale => l.lookGrayscale,
  ColorLook.sepia => l.lookSepia,
  ColorLook.vintage => l.lookVintage,
  ColorLook.crossProcess => l.lookCrossProcess,
  ColorLook.negative => l.lookNegative,
  ColorLook.strongContrast => l.lookStrongContrast,
  ColorLook.lighter => l.lookLighter,
  ColorLook.darker => l.lookDarker,
};

String cornerName(AppLocalizations l, Corner c) => switch (c) {
  Corner.topLeft => l.cornerTopLeft,
  Corner.top => l.cornerTop,
  Corner.topRight => l.cornerTopRight,
  Corner.left => l.cornerLeft,
  Corner.center => l.cornerCenter,
  Corner.right => l.cornerRight,
  Corner.bottomLeft => l.cornerBottomLeft,
  Corner.bottom => l.cornerBottom,
  Corner.bottomRight => l.cornerBottomRight,
};

Widget _cornerPicker(AppLocalizations l, Corner value, ValueChanged<Corner> onChanged) => DropdownButton<Corner>(
  value: value,
  onChanged: (v) => onChanged(v!),
  items: [for (final c in Corner.values) DropdownMenuItem(value: c, child: Text(cornerName(l, c)))],
);

// ================================================================= overlay

class OverlayPage extends ConsumerWidget {
  const OverlayPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('overlay', path, (i) => _OverlayForm(key: ValueKey(i.path), info: i));
}

class _OverlayForm extends StatefulWidget {
  const _OverlayForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_OverlayForm> createState() => _OverlayFormState();
}

class _OverlayFormState extends State<_OverlayForm> {
  String? _image;
  double _imageScale = 0.15, _imageOpacity = 1;
  Corner _imageCorner = Corner.bottomRight;
  final _text = TextEditingController();
  Corner _textCorner = Corner.bottom;
  double _fontSize = 0.05;
  String _fontColor = 'white';
  bool _box = true;
  String? _font;
  bool _timecode = false;
  Corner _tcCorner = Corner.topLeft;
  double _margin = 0.03;
  Duration? _from, _to;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  OverlayParams get _o => OverlayParams(
    imagePath: _image,
    imageScale: _imageScale,
    imageOpacity: _imageOpacity,
    imageCorner: _imageCorner,
    text: _text.text,
    textCorner: _textCorner,
    fontSize: _fontSize,
    fontColor: _fontColor,
    textBox: _box,
    fontFile: _font,
    timecode: _timecode,
    timecodeCorner: _tcCorner,
    margin: _margin,
    from: _from,
    to: _to,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final o = _o;
    final graph = o.isEmpty ? null : overlayGraph(info, o);
    return EditScaffold(
      toolId: 'overlay',
      compare: true,
      info: info,
      suffix: '_overlay',
      graph: graph,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo, if (o.isEmpty) l.overlayEmpty],
      preview: info.videoStreams.isEmpty ? null : FramePreview(info: info, graph: graph),
      params: [
        ParamGroup(
          title: l.groupWatermark,
          children: [
            SettingTile(
              title: l.pWatermarkImage,
              hint: _image == null ? l.pWatermarkImageHint : p.basename(_image!),
              control: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_image != null)
                    IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _image = null)),
                  OutlinedButton(
                    onPressed: () async {
                      final f = await openFile(
                        acceptedTypeGroups: const [
                          XTypeGroup(label: 'Image', extensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp']),
                        ],
                      );
                      if (f != null) setState(() => _image = f.path);
                    },
                    child: Text(l.choose),
                  ),
                ],
              ),
            ),
            if (_image != null) ...[
              SettingTile(
                title: l.pPosition,
                hint: l.pPositionHint,
                control: _cornerPicker(l, _imageCorner, (v) => setState(() => _imageCorner = v)),
              ),
              ValueSlider(
                title: l.pWatermarkSize,
                hint: l.pWatermarkSizeHint,
                value: _imageScale,
                min: 0.03,
                max: 0.6,
                divisions: 57,
                defaultValue: 0.15,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _imageScale = v),
              ),
              ValueSlider(
                title: l.pOpacity,
                hint: l.pOpacityHint,
                value: _imageOpacity,
                min: 0.1,
                max: 1,
                divisions: 18,
                defaultValue: 1,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _imageOpacity = v),
              ),
            ],
          ],
        ),
        ParamGroup(
          title: l.groupText,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _text,
                decoration: InputDecoration(labelText: l.pOverlayText, hintText: l.pOverlayTextHint),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (_text.text.trim().isNotEmpty || _timecode) ...[
              if (_text.text.trim().isNotEmpty)
                SettingTile(
                  title: l.pPosition,
                  hint: l.pPositionHint,
                  control: _cornerPicker(l, _textCorner, (v) => setState(() => _textCorner = v)),
                ),
              ValueSlider(
                title: l.pFontSize,
                hint: l.pFontSizeHint,
                value: _fontSize,
                min: 0.02,
                max: 0.2,
                divisions: 36,
                defaultValue: 0.05,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _fontSize = v),
              ),
              SettingTile(
                title: l.pFontColor,
                hint: l.pFontColorHint,
                control: DropdownButton<String>(
                  value: _fontColor,
                  onChanged: (v) => setState(() => _fontColor = v!),
                  items: [
                    for (final (c, n) in [
                      ('white', l.colorWhite),
                      ('black', l.colorBlack),
                      ('yellow', l.colorYellow),
                      ('red', l.colorRed),
                      ('0x00C8FF', l.colorBlue),
                    ])
                      DropdownMenuItem(value: c, child: Text(n)),
                  ],
                ),
              ),
              SettingTile(
                title: l.pTextBox,
                hint: l.pTextBoxHint,
                control: Switch(value: _box, onChanged: (v) => setState(() => _box = v)),
              ),
              SettingTile(
                title: l.pFontFile,
                hint: _font == null ? l.pFontFileHint : p.basename(_font!),
                control: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_font != null)
                      IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _font = null)),
                    OutlinedButton(
                      onPressed: () async {
                        final f = await openFile(
                          acceptedTypeGroups: const [
                            XTypeGroup(label: 'Font', extensions: ['ttf', 'otf', 'ttc']),
                          ],
                        );
                        if (f != null) setState(() => _font = f.path);
                      },
                      child: Text(l.choose),
                    ),
                  ],
                ),
              ),
            ],
            SettingTile(
              title: l.pTimecode,
              hint: l.pTimecodeHint,
              control: Switch(value: _timecode, onChanged: (v) => setState(() => _timecode = v)),
            ),
            if (_timecode)
              SettingTile(
                title: l.pTimecodePosition,
                hint: l.pPositionHint,
                control: _cornerPicker(l, _tcCorner, (v) => setState(() => _tcCorner = v)),
              ),
          ],
        ),
        ParamGroup(
          title: l.groupWhen,
          children: [
            ValueSlider(
              title: l.pMargin,
              hint: l.pMarginHint,
              value: _margin,
              min: 0,
              max: 0.15,
              divisions: 30,
              defaultValue: 0.03,
              format: (v) => '${(v * 100).round()}%',
              onChanged: (v) => setState(() => _margin = v),
            ),
            SettingTile(
              title: l.pShowFrom,
              hint: l.pShowFromHint,
              control: DurationField(value: _from, hint: '0:00', onChanged: (d) => setState(() => _from = d)),
            ),
            SettingTile(
              title: l.pShowTo,
              hint: l.pShowToHint,
              control: DurationField(value: _to, hint: l.toEnd, onChanged: (d) => setState(() => _to = d)),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================================================================== blur

class BlurPage extends ConsumerWidget {
  const BlurPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('blur', path, (i) => _BlurForm(key: ValueKey(i.path), info: i));
}

class _BlurForm extends StatefulWidget {
  const _BlurForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_BlurForm> createState() => _BlurFormState();
}

class _BlurFormState extends State<_BlurForm> {
  final _regions = <BlurRegion>[];
  BlurMode _mode = BlurMode.blur;
  double _strength = 0.6;
  bool _whole = false;
  bool _edit = true;
  Duration? _at;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final b = BlurParams(regions: _regions, mode: _mode, strength: _strength, wholeFrame: _whole);
    final empty = !_whole && _regions.isEmpty;
    final graph = empty ? null : blurGraph(info, b);
    final editing = _edit && !_whole;
    return EditScaffold(
      toolId: 'blur',
      compare: true,
      info: info,
      suffix: '_blur',
      graph: graph,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo, if (empty) l.blurNoRegions],
      preview: info.videoStreams.isEmpty
          ? null
          : FramePreview(
              info: info,
              graph: graph,
              initialTime: _at,
              onTimeChanged: (t) => _at = t,
              maxRects: 12,
              rects: editing ? [for (final r in _regions) r.rect] : null,
              onRectsChanged: (rects) => setState(() {
                final old = [..._regions];
                _regions
                  ..clear()
                  ..addAll([
                    for (var i = 0; i < rects.length; i++)
                      BlurRegion(
                        rects[i],
                        from: i < old.length ? old[i].from : null,
                        to: i < old.length ? old[i].to : null,
                      ),
                  ]);
              }),
            ),
      params: [
        ParamGroup(
          title: l.groupBlur,
          children: [
            SettingTile(
              title: l.pBlurMode,
              hint: switch (_mode) {
                BlurMode.blur => l.blurModeBlurHint,
                BlurMode.pixelate => l.blurModePixelHint,
                BlurMode.delogo => l.blurModeDelogoHint,
                BlurMode.box => l.blurModeBoxHint,
              },
              controlBelow: true,
              control: SegmentedButton<BlurMode>(
                segments: [
                  ButtonSegment(value: BlurMode.blur, label: Text(l.blurModeBlur)),
                  ButtonSegment(value: BlurMode.pixelate, label: Text(l.blurModePixel)),
                  ButtonSegment(value: BlurMode.delogo, label: Text(l.blurModeDelogo)),
                  ButtonSegment(value: BlurMode.box, label: Text(l.blurModeBox)),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() => _mode = v.first),
              ),
            ),
            if (_mode == BlurMode.blur || _mode == BlurMode.pixelate || _whole)
              ValueSlider(
                title: l.pStrength,
                hint: l.pBlurStrengthHint,
                value: _strength,
                min: 0,
                max: 1,
                divisions: 20,
                defaultValue: 0.6,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _strength = v),
              ),
            SettingTile(
              title: l.pBlurWhole,
              hint: l.pBlurWholeHint,
              control: Switch(value: _whole, onChanged: (v) => setState(() => _whole = v)),
            ),
            if (!_whole)
              SettingTile(
                title: l.pEditRegions,
                hint: l.pEditRegionsHint,
                control: Switch(value: _edit, onChanged: (v) => setState(() => _edit = v)),
              ),
          ],
        ),
        if (!_whole && _regions.isNotEmpty)
          ParamGroup(
            title: l.groupRegions,
            children: [
              for (var i = 0; i < _regions.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text('${i + 1}. ${_regions[i].rect.w}×${_regions[i].rect.h}'),
                      DurationField(
                        value: _regions[i].from,
                        width: 110,
                        hint: '0:00',
                        onChanged: (d) =>
                            setState(() => _regions[i] = BlurRegion(_regions[i].rect, from: d, to: _regions[i].to)),
                      ),
                      const Text('—'),
                      DurationField(
                        value: _regions[i].to,
                        width: 110,
                        hint: '…',
                        onChanged: (d) =>
                            setState(() => _regions[i] = BlurRegion(_regions[i].rect, from: _regions[i].from, to: d)),
                      ),
                      IconButton(
                        tooltip: l.removeFromList,
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _regions.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l.regionTimeHint, style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
      ],
    );
  }
}

// =================================================================== stack

class StackPage extends ConsumerWidget {
  const StackPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('stack', path, (i) => _StackForm(key: ValueKey(i.path), first: i));
}

class _StackForm extends StatefulWidget {
  const _StackForm({super.key, required this.first});
  final MediaInfo first;
  @override
  State<_StackForm> createState() => _StackFormState();
}

class _StackFormState extends State<_StackForm> {
  late List<MediaInfo> _clips = [widget.first];
  StackParams _s = const StackParams();

  StackParams _copy({StackLayout? layout, StackAudio? audio, Corner? pipCorner, double? pipScale, bool? shortest}) =>
      StackParams(
        layout: layout ?? _s.layout,
        audio: audio ?? _s.audio,
        pipCorner: pipCorner ?? _s.pipCorner,
        pipScale: pipScale ?? _s.pipScale,
        shortest: shortest ?? _s.shortest,
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ok = _clips.length >= 2 && _clips.every((c) => c.videoStreams.isNotEmpty);
    final graph = ok ? stackGraph(_clips, _s) : null;
    return EditScaffold(
      toolId: 'stack',
      info: _clips.first,
      inputCount: _clips.length,
      suffix: '_stack',
      graph: graph,
      problems: [
        if (_clips.length < 2) l.needMoreClips(2),
        if (_clips.any((c) => c.videoStreams.isEmpty)) l.issueNoVideo,
      ],
      preview: graph == null ? null : FramePreview(info: _clips.first, graph: graph),
      params: [
        ParamGroup(
          title: l.groupClips,
          children: [ClipList(clips: _clips, max: 4, onChanged: (v) => setState(() => _clips = v))],
        ),
        ParamGroup(
          title: l.groupLayout,
          children: [
            SettingTile(
              title: l.pLayout,
              hint: l.pLayoutHint,
              controlBelow: true,
              control: SegmentedButton<StackLayout>(
                segments: [
                  ButtonSegment(
                    value: StackLayout.sideBySide,
                    icon: const Icon(Icons.view_column),
                    label: Text(l.layoutSide),
                  ),
                  ButtonSegment(
                    value: StackLayout.topBottom,
                    icon: const Icon(Icons.view_agenda),
                    label: Text(l.layoutTop),
                  ),
                  ButtonSegment(value: StackLayout.grid, icon: const Icon(Icons.grid_view), label: Text(l.layoutGrid)),
                  ButtonSegment(
                    value: StackLayout.pip,
                    icon: const Icon(Icons.picture_in_picture_alt),
                    label: Text(l.layoutPip),
                  ),
                ],
                selected: {_s.layout},
                onSelectionChanged: (v) => setState(() => _s = _copy(layout: v.first)),
              ),
            ),
            if (_s.layout == StackLayout.pip) ...[
              SettingTile(
                title: l.pPosition,
                hint: l.pPipPositionHint,
                control: _cornerPicker(l, _s.pipCorner, (v) => setState(() => _s = _copy(pipCorner: v))),
              ),
              ValueSlider(
                title: l.pPipSize,
                hint: l.pPipSizeHint,
                value: _s.pipScale,
                min: 0.1,
                max: 0.6,
                divisions: 50,
                defaultValue: 0.3,
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _s = _copy(pipScale: v)),
              ),
            ],
            SettingTile(
              title: l.pStackAudio,
              hint: l.pStackAudioHint,
              control: DropdownButton<StackAudio>(
                value: _s.audio,
                onChanged: (v) => setState(() => _s = _copy(audio: v)),
                items: [
                  DropdownMenuItem(value: StackAudio.first, child: Text(l.stackAudioFirst)),
                  DropdownMenuItem(value: StackAudio.mix, child: Text(l.stackAudioMix)),
                  DropdownMenuItem(value: StackAudio.none, child: Text(l.stackAudioNone)),
                ],
              ),
            ),
            if (_s.layout != StackLayout.grid)
              SettingTile(
                title: l.pShortest,
                hint: _s.shortest ? l.shortestOnHint : l.shortestOffHint,
                control: Switch(
                  value: _s.shortest,
                  onChanged: (v) => setState(() => _s = _copy(shortest: v)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ==================================================================== loop

class LoopPage extends ConsumerWidget {
  const LoopPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('loop', path, (i) => _LoopForm(key: ValueKey(i.path), info: i));
}

class _LoopForm extends StatefulWidget {
  const _LoopForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_LoopForm> createState() => _LoopFormState();
}

class _LoopFormState extends State<_LoopForm> {
  LoopMode _mode = LoopMode.repeat;
  int _times = 3;
  bool _audio = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final long = (info.duration ?? Duration.zero) > const Duration(seconds: 30);
    final graph = info.videoStreams.isEmpty
        ? null
        : loopGraph(info, LoopParams(mode: _mode, times: _times, boomerangAudio: _audio));
    return EditScaffold(
      toolId: 'loop',
      info: info,
      suffix: _mode == LoopMode.boomerang ? '_boomerang' : '_x$_times',
      graph: graph,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo],
      warnings: [if (_mode == LoopMode.boomerang && long) l.reverseMemoryWarning],
      preview: MediaPreview(path: info.path, aspectRatio: 16 / 9),
      params: [
        ParamGroup(
          title: l.groupLoop,
          children: [
            SettingTile(
              title: l.pLoopMode,
              hint: _mode == LoopMode.repeat ? l.loopRepeatHint : l.loopBoomerangHint,
              controlBelow: true,
              control: SegmentedButton<LoopMode>(
                segments: [
                  ButtonSegment(value: LoopMode.repeat, icon: const Icon(Icons.repeat), label: Text(l.loopRepeat)),
                  ButtonSegment(
                    value: LoopMode.boomerang,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(l.loopBoomerang),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() => _mode = v.first),
              ),
            ),
            ValueSlider(
              title: l.pLoopTimes,
              hint: l.pLoopTimesHint,
              value: _times.toDouble(),
              min: _mode == LoopMode.repeat ? 2 : 1,
              max: 20,
              divisions: _mode == LoopMode.repeat ? 18 : 19,
              format: (v) => '×${v.round()}',
              onChanged: (v) => setState(() => _times = v.round()),
            ),
            if (_mode == LoopMode.boomerang && info.audioStreams.isNotEmpty)
              SettingTile(
                title: l.pBoomerangAudio,
                hint: l.pBoomerangAudioHint,
                control: Switch(value: _audio, onChanged: (v) => setState(() => _audio = v)),
              ),
          ],
        ),
      ],
    );
  }
}

// ============================================================== HDR → SDR

class HdrToSdrPage extends ConsumerWidget {
  const HdrToSdrPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _loader('hdrToSdr', path, (i) => _HdrForm(key: ValueKey(i.path), info: i));
}

class _HdrForm extends ConsumerStatefulWidget {
  const _HdrForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_HdrForm> createState() => _HdrFormState();
}

class _HdrFormState extends ConsumerState<_HdrForm> {
  ToneMap _curve = ToneMap.hable;
  double _desat = 0;
  bool _placebo = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final caps = ref.watch(capabilitiesProvider).value;
    final hasPlacebo = caps?.hasFilter('libplacebo') ?? false;
    final v = info.videoStreams.firstOrNull;
    final graph = v == null ? null : hdrToSdrGraph(info, curve: _curve, desat: _desat, placebo: _placebo && hasPlacebo);
    return EditScaffold(
      toolId: 'hdrToSdr',
      compare: true,
      info: info,
      suffix: '_sdr',
      graph: graph,
      eightBit: true,
      problems: [if (v == null) l.issueNoVideo],
      warnings: [if (v != null && !isHdr(info)) l.notHdrWarning(v.colorTransfer ?? '—')],
      // libplacebo needs a Vulkan GPU; the preview uses the CPU path.
      preview: graph == null
          ? null
          : FramePreview(
              info: info,
              graph: hdrToSdrGraph(info, curve: _curve, desat: _desat),
            ),
      params: [
        ParamGroup(
          title: l.groupToneMap,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l.hdrSourceInfo(v?.colorTransfer ?? '—', v?.colorPrimaries ?? '—', '${v?.bitDepth ?? 8}'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            SettingTile(
              title: l.pToneCurve,
              hint: switch (_curve) {
                ToneMap.hable => l.toneHableHint,
                ToneMap.mobius => l.toneMobiusHint,
                ToneMap.reinhard => l.toneReinhardHint,
                ToneMap.bt2390 => l.toneBt2390Hint,
              },
              help: l.pToneCurveHelp,
              control: DropdownButton<ToneMap>(
                value: _curve,
                onChanged: (v) => setState(() => _curve = v!),
                items: [
                  const DropdownMenuItem(value: ToneMap.hable, child: Text('Hable')),
                  const DropdownMenuItem(value: ToneMap.mobius, child: Text('Möbius')),
                  const DropdownMenuItem(value: ToneMap.reinhard, child: Text('Reinhard')),
                  if (_placebo && hasPlacebo) const DropdownMenuItem(value: ToneMap.bt2390, child: Text('BT.2390')),
                ],
              ),
            ),
            if (!_placebo)
              ValueSlider(
                title: l.pDesat,
                hint: l.pDesatHint,
                value: _desat,
                min: 0,
                max: 2,
                divisions: 20,
                defaultValue: 0,
                onChanged: (v) => setState(() => _desat = v),
              ),
            if (hasPlacebo)
              SettingTile(
                title: l.pPlacebo,
                hint: l.pPlaceboHint,
                control: Switch(
                  value: _placebo,
                  onChanged: (v) => setState(() {
                    _placebo = v;
                    if (!v && _curve == ToneMap.bt2390) _curve = ToneMap.hable;
                  }),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Formats used by the frame-based tools' estimates.
String formatAt(Duration d) => formatDuration(d, millis: true);
