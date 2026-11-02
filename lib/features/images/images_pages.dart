import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/media_preview.dart';
import '../../ui/widgets/setting_tile.dart';
import '../edit/graphs.dart' show fnum;
import '../edit/ui/cut_pages.dart' show transitionName;
import '../edit/ui/edit_widgets.dart';
import '../tools/tool_catalog.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'images_ops.dart';

const _imageTypes = [
  XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'tif', 'tiff', 'avif', 'jxl']),
];

/// Format + quality controls shared by image outputs.
class _ImageFormatGroup extends ConsumerWidget {
  const _ImageFormatGroup({
    required this.format,
    required this.quality,
    required this.onFormat,
    required this.onQuality,
  });
  final ImageFormat format;
  final int quality;
  final ValueChanged<ImageFormat> onFormat;
  final ValueChanged<int> onQuality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final caps = ref.watch(capabilitiesProvider).value;
    bool has(ImageFormat f) => caps == null || caps.version == null || caps.hasEncoder(imageEncoder(f));
    return ParamGroup(
      title: l.groupImageFormat,
      children: [
        SettingTile(
          title: l.pImageFormat,
          hint: switch (format) {
            ImageFormat.png => l.imgPngHint,
            ImageFormat.jpg => l.imgJpgHint,
            ImageFormat.webp => l.imgWebpHint,
            ImageFormat.avif => l.imgAvifHint,
            ImageFormat.jxl => l.imgJxlHint,
          },
          controlBelow: true,
          control: SegmentedButton<ImageFormat>(
            segments: [
              for (final f in ImageFormat.values)
                ButtonSegment(value: f, label: Text(f.name.toUpperCase()), enabled: has(f)),
            ],
            selected: {format},
            onSelectionChanged: (v) => onFormat(v.first),
          ),
        ),
        if (format != ImageFormat.png)
          ValueSlider(
            title: l.pImageQuality,
            hint: l.pImageQualityHint,
            value: quality.toDouble(),
            min: 10,
            max: 100,
            divisions: 18,
            format: (v) => v >= 100 ? l.lossless : '${v.round()}',
            onChanged: (v) => onQuality(v.round()),
          ),
      ],
    );
  }
}

Future<void> _submit(
  BuildContext context,
  WidgetRef ref,
  String toolId,
  MediaInfo info,
  List<JobStep> steps,
  String out,
  bool now, {
  Duration? total,
}) {
  final l = context.l10n;
  return submitJob(
    context,
    ref,
    JobRequest(
      kind: toolId,
      title: '${toolTitle(l, toolId)}: ${p.basename(info.path)}',
      tool: JobTool.ffmpeg,
      steps: steps,
      inputPath: info.path,
      outputPath: out,
      totalDuration: total,
    ),
    now: now,
  );
}

// ================================================================= frames

class FramesPage extends ConsumerWidget {
  const FramesPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'frames',
    path: path,
    builder: (i) => _FramesForm(key: ValueKey(i.path), info: i),
  );
}

class _FramesForm extends ConsumerStatefulWidget {
  const _FramesForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_FramesForm> createState() => _FramesFormState();
}

class _FramesFormState extends ConsumerState<_FramesForm> {
  FramesMode _mode = FramesMode.single;
  late Duration _at = (widget.info.duration ?? Duration.zero) * 0.25;
  Duration _every = const Duration(seconds: 10);
  int _count = 12;
  double _scene = 0.3;
  ImageFormat _format = ImageFormat.jpg;
  int _quality = 90;
  int? _width;
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = imageExt(_format);
    final suffix = _mode == FramesMode.single ? '_${formatDuration(_at).replaceAll(':', '-')}' : '_frames';
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: suffix), ext);
    final f = FramesParams(
      mode: _mode,
      at: _at,
      every: _every,
      count: _count,
      sceneThreshold: _scene,
      format: _format,
      quality: _quality,
      width: _width,
    );
    final steps = info.videoStreams.isEmpty ? null : planFrames(info: info, output: out, f: f);
    final d = info.duration ?? Duration.zero;
    final n = switch (_mode) {
      FramesMode.single || FramesMode.best => 1,
      FramesMode.every => _every.inMilliseconds == 0 ? 0 : (d.inMilliseconds / _every.inMilliseconds).ceil(),
      FramesMode.count => _count,
      FramesMode.scenes => null,
    };
    return ToolScaffold(
      toolId: 'frames',
      info: info,
      preview: info.videoStreams.isEmpty
          ? null
          : FramePreview(info: info, initialTime: _at, onTimeChanged: (t) => setState(() => _at = t)),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      estimate: n == null ? l.framesSceneCount : l.framesCount(n),
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo],
      onSubmit: (now) => _submit(context, ref, 'frames', info, steps!, out, now, total: f.single ? null : d),
      params: [
        ParamGroup(
          title: l.groupFrames,
          children: [
            SettingTile(
              title: l.pFramesMode,
              hint: switch (_mode) {
                FramesMode.single => l.framesSingleHint,
                FramesMode.best => l.framesBestHint,
                FramesMode.every => l.framesEveryHint,
                FramesMode.count => l.framesCountHint,
                FramesMode.scenes => l.framesScenesHint,
              },
              controlBelow: true,
              control: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final m in FramesMode.values)
                    ChoiceChip(
                      label: Text(switch (m) {
                        FramesMode.single => l.framesSingle,
                        FramesMode.best => l.framesBest,
                        FramesMode.every => l.framesEvery,
                        FramesMode.count => l.framesN,
                        FramesMode.scenes => l.framesScenes,
                      }),
                      selected: _mode == m,
                      onSelected: (_) => setState(() => _mode = m),
                    ),
                ],
              ),
            ),
            if (_mode == FramesMode.single)
              SettingTile(
                title: l.pFrameAt,
                hint: l.pFrameAtHint,
                control: DurationField(value: _at, onChanged: (v) => setState(() => _at = v ?? Duration.zero)),
              ),
            if (_mode == FramesMode.every)
              SettingTile(
                title: l.pFramesInterval,
                hint: l.pStartHint,
                control: DurationField(value: _every, onChanged: (v) => setState(() => _every = v ?? _every)),
              ),
            if (_mode == FramesMode.count)
              ValueSlider(
                title: l.pFramesNumber,
                hint: l.pFramesNumberHint,
                value: _count.toDouble(),
                min: 2,
                max: 100,
                divisions: 98,
                format: (v) => '${v.round()}',
                onChanged: (v) => setState(() => _count = v.round()),
              ),
            if (_mode == FramesMode.scenes)
              ValueSlider(
                title: l.pSceneThreshold,
                hint: l.pSceneThresholdHint,
                value: _scene,
                min: 0.05,
                max: 0.8,
                divisions: 15,
                defaultValue: 0.3,
                onChanged: (v) => setState(() => _scene = v),
              ),
            SettingTile(
              title: l.pImageWidth,
              hint: l.pImageWidthHint,
              control: DropdownButton<int?>(
                value: _width,
                onChanged: (v) => setState(() => _width = v),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                  for (final w in const [320, 640, 1280, 1920]) DropdownMenuItem(value: w, child: Text('$w px')),
                ],
              ),
            ),
          ],
        ),
        _ImageFormatGroup(
          format: _format,
          quality: _quality,
          onFormat: (v) => setState(() => _format = v),
          onQuality: (v) => setState(() => _quality = v),
        ),
      ],
    );
  }
}

// =========================================================== contact sheet

class ContactSheetPage extends ConsumerWidget {
  const ContactSheetPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'contactSheet',
    path: path,
    builder: (i) => _SheetForm(key: ValueKey(i.path), info: i),
  );
}

class _SheetForm extends ConsumerStatefulWidget {
  const _SheetForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_SheetForm> createState() => _SheetFormState();
}

class _SheetFormState extends ConsumerState<_SheetForm> {
  int _cols = 4, _rows = 4, _thumb = 320;
  bool _timestamps = true;
  String _bg = 'black';
  ImageFormat _format = ImageFormat.jpg;
  int _quality = 90;
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = imageExt(_format);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_sheet'), ext);
    final s = SheetParams(
      columns: _cols,
      rows: _rows,
      thumbWidth: _thumb,
      timestamps: _timestamps,
      background: _bg,
      format: _format,
      quality: _quality,
    );
    final steps = info.videoStreams.isEmpty || info.duration == null
        ? null
        : planContactSheet(info: info, output: out, s: s);
    return ToolScaffold(
      toolId: 'contactSheet',
      info: info,
      preview: MediaPreview(path: info.path),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      estimate: l.sheetSize('${_cols * _thumb + (_cols - 1) * 4 + 16} px', '${s.count}'),
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo, if (info.duration == null) l.issueDurationUnknown],
      onSubmit: (now) => _submit(context, ref, 'contactSheet', info, steps!, out, now, total: info.duration),
      params: [
        ParamGroup(
          title: l.groupSheet,
          children: [
            ValueSlider(
              title: l.pColumns,
              hint: l.pColumnsHint,
              value: _cols.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              format: (v) => '${v.round()}',
              onChanged: (v) => setState(() => _cols = v.round()),
            ),
            ValueSlider(
              title: l.pRows,
              hint: l.pRowsHint,
              value: _rows.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              format: (v) => '${v.round()}',
              onChanged: (v) => setState(() => _rows = v.round()),
            ),
            SettingTile(
              title: l.pThumbWidth,
              hint: l.pThumbWidthHint,
              control: DropdownButton<int>(
                value: _thumb,
                onChanged: (v) => setState(() => _thumb = v!),
                items: [
                  for (final w in const [160, 240, 320, 480, 640]) DropdownMenuItem(value: w, child: Text('$w px')),
                ],
              ),
            ),
            SettingTile(
              title: l.pTimestamps,
              hint: l.pTimestampsHint,
              control: Switch(value: _timestamps, onChanged: (v) => setState(() => _timestamps = v)),
            ),
            SettingTile(
              title: l.pBackground,
              hint: l.pBackgroundHint,
              control: DropdownButton<String>(
                value: _bg,
                onChanged: (v) => setState(() => _bg = v!),
                items: [
                  DropdownMenuItem(value: 'black', child: Text(l.colorBlack)),
                  DropdownMenuItem(value: 'white', child: Text(l.colorWhite)),
                  DropdownMenuItem(value: '0x303030', child: Text(l.colorGray)),
                ],
              ),
            ),
          ],
        ),
        _ImageFormatGroup(
          format: _format,
          quality: _quality,
          onFormat: (v) => setState(() => _format = v),
          onQuality: (v) => setState(() => _quality = v),
        ),
      ],
    );
  }
}

// ============================================================== slideshow

class SlideshowPage extends ConsumerWidget {
  const SlideshowPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'slideshow',
    path: path,
    builder: (i) => _SlideshowForm(key: ValueKey(i.path), first: i),
  );
}

const _frameSizes = [(1920, 1080), (1280, 720), (1080, 1920), (1080, 1080), (3840, 2160)];

class _SlideshowForm extends ConsumerStatefulWidget {
  const _SlideshowForm({super.key, required this.first});
  final MediaInfo first;
  @override
  ConsumerState<_SlideshowForm> createState() => _SlideshowFormState();
}

class _SlideshowFormState extends ConsumerState<_SlideshowForm> {
  late List<MediaInfo> _images = [widget.first];
  (int, int) _size = _frameSizes.first;
  double _per = 4, _trans = 0.8;
  String? _transition = 'fade';
  bool _kenBurns = true, _fit = true, _fitToAudio = false;
  MediaInfo? _audio;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = SlideshowParams(
      width: _size.$1,
      height: _size.$2,
      perImage: Duration(milliseconds: (_per * 1000).round()),
      transition: _transition,
      transitionLength: Duration(milliseconds: (_trans * 1000).round()),
      kenBurns: _kenBurns,
      fit: _fit,
      audio: _audio?.path,
      audioDuration: _audio?.duration,
      fitToAudio: _fitToAudio && _audio != null,
    );
    final notImages = _images.where(
      (i) => i.videoStreams.isEmpty || (i.duration ?? Duration.zero) > const Duration(seconds: 1),
    );
    final tooShort = _transition != null && slideDuration(_images.length, s) <= s.transitionLength;
    final ok = notImages.isEmpty && !tooShort;
    return EditScaffold(
      toolId: 'slideshow',
      info: _images.first,
      inputCount: _images.length,
      suffix: '_slideshow',
      graph: ok ? slideshowGraph([for (final i in _images) i.path], s) : null,
      estimate: l.resultLength(formatDuration(slideshowLength(_images.length, s), millis: true)),
      problems: [
        if (notImages.isNotEmpty) l.slideshowOnlyImages(p.basename(notImages.first.path)),
        if (tooShort) l.clipShorterThanTransition,
      ],
      params: [
        ParamGroup(
          title: l.groupImages,
          children: [ClipList(clips: _images, min: 1, max: 500, onChanged: (v) => setState(() => _images = v))],
        ),
        ParamGroup(
          title: l.groupSlides,
          children: [
            SettingTile(
              title: l.pFrameSize,
              hint: l.pFrameSizeHint,
              control: DropdownButton<(int, int)>(
                value: _size,
                onChanged: (v) => setState(() => _size = v!),
                items: [for (final s in _frameSizes) DropdownMenuItem(value: s, child: Text('${s.$1}×${s.$2}'))],
              ),
            ),
            if (!(_fitToAudio && _audio != null))
              ValueSlider(
                title: l.pPerImage,
                hint: l.pPerImageHint,
                value: _per,
                min: 1,
                max: 15,
                divisions: 28,
                format: (v) => '${fnum(v, 1)} ${l.unitSecond}',
                onChanged: (v) => setState(() => _per = v),
              ),
            SettingTile(
              title: l.pTransition,
              hint: l.pTransitionHint,
              control: DropdownButton<String?>(
                value: _transition,
                onChanged: (v) => setState(() => _transition = v),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.hardCut)),
                  for (final t in slideTransitions) DropdownMenuItem(value: t, child: Text(transitionName(l, t))),
                ],
              ),
            ),
            if (_transition != null)
              ValueSlider(
                title: l.pTransitionDuration,
                hint: l.pTransitionDurationHint,
                value: _trans,
                min: 0.2,
                max: 3,
                divisions: 28,
                format: (v) => '${fnum(v, 1)} ${l.unitSecond}',
                onChanged: (v) => setState(() => _trans = v),
              ),
            SettingTile(
              title: l.pKenBurns,
              hint: l.pKenBurnsHint,
              control: Switch(value: _kenBurns, onChanged: (v) => setState(() => _kenBurns = v)),
            ),
            SettingTile(
              title: l.pFit,
              hint: _fit ? l.fitFitHint : l.fitFillHint,
              control: Switch(value: _fit, onChanged: (v) => setState(() => _fit = v)),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupMusic,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(_audio == null ? l.musicFile : p.basename(_audio!.path)),
              subtitle: Text(_audio == null ? l.slideshowMusicHint : formatDuration(_audio!.duration)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_audio != null)
                    IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _audio = null)),
                  OutlinedButton(
                    onPressed: () async {
                      final f = await openFile();
                      final probe = ref.read(probeServiceProvider);
                      if (f == null || probe == null) return;
                      final i = await probe.probe(f.path);
                      if (mounted && i.audioStreams.isNotEmpty) setState(() => _audio = i);
                    },
                    child: Text(l.choose),
                  ),
                ],
              ),
            ),
            if (_audio != null)
              SettingTile(
                title: l.pFitToAudio,
                hint: l.pFitToAudioHint,
                control: Switch(value: _fitToAudio, onChanged: (v) => setState(() => _fitToAudio = v)),
              ),
          ],
        ),
      ],
    );
  }
}

// ========================================================= audio → video

class AudioToVideoPage extends ConsumerWidget {
  const AudioToVideoPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'audioToVideo',
    path: path,
    builder: (i) => _AudioVideoForm(key: ValueKey(i.path), info: i),
  );
}

class _AudioVideoForm extends StatefulWidget {
  const _AudioVideoForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_AudioVideoForm> createState() => _AudioVideoFormState();
}

class _AudioVideoFormState extends State<_AudioVideoForm> {
  late CoverSource _cover = widget.info.coverArt != null ? CoverSource.embedded : CoverSource.color;
  String? _image;
  (int, int) _size = _frameSizes.first;
  bool _blur = true, _wave = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final a = AudioVideoParams(
      cover: _cover,
      image: _image,
      width: _size.$1,
      height: _size.$2,
      blurBackground: _blur,
      waveform: _wave,
    );
    final ok = info.audioStreams.isNotEmpty && (_cover != CoverSource.file || _image != null);
    return EditScaffold(
      toolId: 'audioToVideo',
      info: info,
      suffix: '_video',
      graph: ok ? audioVideoGraph(info, a) : null,
      problems: [
        if (info.audioStreams.isEmpty) l.issueNoAudio,
        if (_cover == CoverSource.file && _image == null) l.chooseCoverImage,
      ],
      preview: MediaPreview(path: info.path, aspectRatio: 16 / 9),
      params: [
        ParamGroup(
          title: l.groupPicture,
          children: [
            SettingTile(
              title: l.pCoverSource,
              hint: l.pCoverSourceHint,
              controlBelow: true,
              control: SegmentedButton<CoverSource>(
                segments: [
                  ButtonSegment(
                    value: CoverSource.embedded,
                    label: Text(l.coverEmbedded),
                    enabled: info.coverArt != null,
                  ),
                  ButtonSegment(value: CoverSource.file, label: Text(l.coverFile)),
                  ButtonSegment(value: CoverSource.color, label: Text(l.coverColor)),
                ],
                selected: {_cover},
                onSelectionChanged: (v) => setState(() => _cover = v.first),
              ),
            ),
            if (_cover == CoverSource.file)
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(_image == null ? l.chooseCoverImage : p.basename(_image!)),
                trailing: OutlinedButton(
                  onPressed: () async {
                    final f = await openFile(acceptedTypeGroups: _imageTypes);
                    if (f != null) setState(() => _image = f.path);
                  },
                  child: Text(l.choose),
                ),
              ),
            SettingTile(
              title: l.pFrameSize,
              hint: l.pFrameSizeHint,
              control: DropdownButton<(int, int)>(
                value: _size,
                onChanged: (v) => setState(() => _size = v!),
                items: [for (final s in _frameSizes) DropdownMenuItem(value: s, child: Text('${s.$1}×${s.$2}'))],
              ),
            ),
            if (_cover != CoverSource.color)
              SettingTile(
                title: l.fitBlur,
                hint: l.fitBlurHint,
                control: Switch(value: _blur, onChanged: (v) => setState(() => _blur = v)),
              ),
            SettingTile(
              title: l.pWaveOverlay,
              hint: l.pWaveOverlayHint,
              control: Switch(value: _wave, onChanged: (v) => setState(() => _wave = v)),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================= visualizer

class VisualizerPage extends ConsumerWidget {
  const VisualizerPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'visualizer',
    path: path,
    builder: (i) => _VisualForm(key: ValueKey(i.path), info: i),
  );
}

class _VisualForm extends StatefulWidget {
  const _VisualForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_VisualForm> createState() => _VisualFormState();
}

class _VisualFormState extends State<_VisualForm> {
  VisualKind _kind = VisualKind.waves;
  (int, int) _size = (1280, 720);
  String _color = '0x4FC3F7';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final graph = info.audioStreams.isEmpty
        ? null
        : visualizerGraph(info, VisualParams(kind: _kind, width: _size.$1, height: _size.$2, color: _color));
    return EditScaffold(
      toolId: 'visualizer',
      info: info,
      suffix: '_${_kind.name}',
      graph: graph,
      problems: [if (info.audioStreams.isEmpty) l.issueNoAudio],
      preview: MediaPreview(path: info.path, aspectRatio: 16 / 9),
      params: [
        ParamGroup(
          title: l.groupVisual,
          children: [
            SettingTile(
              title: l.pVisualKind,
              hint: switch (_kind) {
                VisualKind.waves => l.visWavesHint,
                VisualKind.spectrum => l.visSpectrumHint,
                VisualKind.vectorscope => l.visScopeHint,
                VisualKind.cqt => l.visCqtHint,
              },
              controlBelow: true,
              control: SegmentedButton<VisualKind>(
                segments: [
                  ButtonSegment(value: VisualKind.waves, label: Text(l.visWaves)),
                  ButtonSegment(value: VisualKind.spectrum, label: Text(l.picSpectrum)),
                  ButtonSegment(value: VisualKind.vectorscope, label: Text(l.visScope)),
                  ButtonSegment(value: VisualKind.cqt, label: Text(l.visCqt)),
                ],
                selected: {_kind},
                onSelectionChanged: (v) => setState(() => _kind = v.first),
              ),
            ),
            SettingTile(
              title: l.pFrameSize,
              hint: l.pFrameSizeHint,
              control: DropdownButton<(int, int)>(
                value: _size,
                onChanged: (v) => setState(() => _size = v!),
                items: [
                  for (final s in const [(1280, 720), (1920, 1080), (1080, 1080)])
                    DropdownMenuItem(value: s, child: Text('${s.$1}×${s.$2}')),
                ],
              ),
            ),
            if (_kind == VisualKind.waves)
              SettingTile(
                title: l.pFontColor,
                hint: l.pWaveColorHint,
                control: DropdownButton<String>(
                  value: _color,
                  onChanged: (v) => setState(() => _color = v!),
                  items: [
                    DropdownMenuItem(value: '0x4FC3F7', child: Text(l.colorBlue)),
                    DropdownMenuItem(value: '0xFFFFFF', child: Text(l.colorWhite)),
                    DropdownMenuItem(value: '0xFFB300', child: Text(l.colorYellow)),
                    DropdownMenuItem(value: '0xEF5350', child: Text(l.colorRed)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ========================================================== image convert

class ImageConvertPage extends ConsumerWidget {
  const ImageConvertPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'imageConvert',
    path: path,
    builder: (i) => _ImageConvertForm(key: ValueKey(i.path), info: i),
  );
}

class _ImageConvertForm extends ConsumerStatefulWidget {
  const _ImageConvertForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_ImageConvertForm> createState() => _ImageConvertFormState();
}

class _ImageConvertFormState extends ConsumerState<_ImageConvertForm> {
  ImageFormat _format = ImageFormat.webp;
  int _quality = 85;
  int? _maxSide;
  bool _strip = true;
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = imageExt(_format);
    final same = p.extension(info.path).replaceFirst('.', '').toLowerCase() == ext;
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: same ? '_small' : ''), ext);
    final steps = info.videoStreams.isEmpty
        ? null
        : planImageConvert(
            info: info,
            output: out,
            c: ImageConvertParams(format: _format, quality: _quality, maxSide: _maxSide, stripMetadata: _strip),
          );
    return ToolScaffold(
      toolId: 'imageConvert',
      info: info,
      preview: info.videoStreams.isEmpty ? null : FramePreview(info: info, initialTime: Duration.zero),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo],
      onSubmit: (now) => _submit(context, ref, 'imageConvert', info, steps!, out, now),
      params: [
        _ImageFormatGroup(
          format: _format,
          quality: _quality,
          onFormat: (v) => setState(() => _format = v),
          onQuality: (v) => setState(() => _quality = v),
        ),
        ParamGroup(
          title: l.groupFrame,
          children: [
            SettingTile(
              title: l.pMaxSide,
              hint: l.pMaxSideHint,
              control: DropdownButton<int?>(
                value: _maxSide,
                onChanged: (v) => setState(() => _maxSide = v),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                  for (final w in const [640, 1024, 1280, 1920, 2560, 3840])
                    DropdownMenuItem(value: w, child: Text('$w px')),
                ],
              ),
            ),
            SettingTile(
              title: l.pStripMetadata,
              hint: l.pStripMetadataHint,
              control: Switch(value: _strip, onChanged: (v) => setState(() => _strip = v)),
            ),
          ],
        ),
      ],
    );
  }
}
