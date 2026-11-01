import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/progress.dart' show parseFfmpegTime;
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/media_preview.dart';
import '../../ui/widgets/setting_tile.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'gif.dart';

class GifPage extends ConsumerWidget {
  const GifPage({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'gif',
    path: path,
    builder: (info) => _GifForm(key: ValueKey(info.path), info: info),
  );
}

class _GifForm extends ConsumerStatefulWidget {
  const _GifForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_GifForm> createState() => _GifFormState();
}

class _GifFormState extends ConsumerState<_GifForm> {
  late GifParams _g = GifParams(
    // Never upscale by default.
    width: (widget.info.videoStreams.firstOrNull?.width ?? 0) > 480 ? 480 : null,
    duration: widget.info.duration != null && widget.info.duration! > const Duration(seconds: 10)
        ? const Duration(seconds: 5)
        : null,
  );
  String? _output;
  late final TextEditingController _startC = TextEditingController(text: formatDuration(Duration.zero, millis: true));
  late final TextEditingController _durC = TextEditingController(
    text: _g.duration == null ? '' : formatDuration(_g.duration, millis: true),
  );

  @override
  void dispose() {
    _startC.dispose();
    _durC.dispose();
    super.dispose();
  }

  GifParams _copy({
    AnimFormat? format,
    Duration? start,
    Duration? Function()? duration,
    int? fps,
    int? Function()? width,
    Dither? dither,
    bool? staticBackground,
    bool? loop,
    int? webpQuality,
  }) => GifParams(
    format: format ?? _g.format,
    start: start ?? _g.start,
    duration: duration != null ? duration() : _g.duration,
    fps: fps ?? _g.fps,
    width: width != null ? width() : _g.width,
    dither: dither ?? _g.dither,
    staticBackground: staticBackground ?? _g.staticBackground,
    loop: loop ?? _g.loop,
    webpQuality: webpQuality ?? _g.webpQuality,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final advanced = ref.watch(settingsProvider.select((s) => s.advancedMode));
    final caps = ref.watch(capabilitiesProvider).value;
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: _g.ext), _g.ext);
    final webpMissing = _g.format == AnimFormat.webp && caps?.version != null && !caps!.hasEncoder('libwebp_anim');
    final steps = info.videoStreams.isEmpty ? null : planGif(info: info, output: out, g: _g);
    final len = _g.duration ?? (info.duration == null ? null : info.duration! - _g.start);
    return ToolScaffold(
      toolId: 'gif',
      info: info,
      preview: MediaPreview(path: info.path),
      outputPath: out,
      outputExt: _g.ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo, if (webpMissing) l.errEncoderMissing('libwebp_anim')],
      warnings: [if (len != null && len > const Duration(seconds: 20) && _g.format == AnimFormat.gif) l.warnLongGif],
      estimate: len == null ? null : l.gifFrames((len.inMilliseconds * _g.fps / 1000).round()),
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'gif',
          title: '${l.toolGif}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: len,
        ),
        now: now,
      ),
      params: [
        ParamGroup(
          title: l.groupAnimation,
          children: [
            SettingTile(
              title: l.pAnimFormat,
              hint: l.pAnimFormatHint,
              help: l.pAnimFormatHelp,
              controlBelow: true,
              control: SegmentedButton<AnimFormat>(
                segments: const [
                  ButtonSegment(value: AnimFormat.gif, label: Text('GIF')),
                  ButtonSegment(value: AnimFormat.webp, label: Text('WebP')),
                  ButtonSegment(value: AnimFormat.apng, label: Text('APNG')),
                ],
                selected: {_g.format},
                onSelectionChanged: (v) => setState(() => _g = _copy(format: v.first)),
              ),
            ),
            SettingTile(
              title: l.pStart,
              hint: l.pStartHint,
              control: SizedBox(
                width: 140,
                child: TextField(
                  controller: _startC,
                  decoration: const InputDecoration(isDense: true),
                  onChanged: (t) {
                    final d = parseFfmpegTime(t);
                    if (d != null) setState(() => _g = _copy(start: d));
                  },
                ),
              ),
            ),
            SettingTile(
              title: l.pDuration,
              hint: l.pDurationHint,
              control: SizedBox(
                width: 140,
                child: TextField(
                  controller: _durC,
                  decoration: InputDecoration(isDense: true, hintText: l.toEnd),
                  onChanged: (t) =>
                      setState(() => _g = _copy(duration: () => t.trim().isEmpty ? null : parseFfmpegTime(t))),
                ),
              ),
            ),
            SettingTile(
              title: l.pGifFps,
              hint: l.pGifFpsHint,
              controlBelow: true,
              control: ZonedSlider(
                value: _g.fps.toDouble(),
                min: 5,
                max: 30,
                divisions: 25,
                leftLabel: l.zoneSmallerFile,
                rightLabel: l.zoneSmoother,
                onChanged: (v) => setState(() => _g = _copy(fps: v.round())),
              ),
            ),
            SettingTile(
              title: l.pGifWidth,
              hint: l.pGifWidthHint,
              control: DropdownButton<int?>(
                value: _g.width,
                onChanged: (v) => setState(() => _g = _copy(width: () => v)),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                  for (final w in const [240, 320, 480, 640, 800, 1080])
                    DropdownMenuItem(value: w, child: Text('$w px')),
                ],
              ),
            ),
            if (_g.format == AnimFormat.gif) ...[
              SettingTile(
                title: l.pDither,
                hint: l.pDitherHint,
                help: l.pDitherHelp,
                control: DropdownButton<Dither>(
                  value: _g.dither,
                  onChanged: (v) => setState(() => _g = _copy(dither: v)),
                  items: const [
                    DropdownMenuItem(value: Dither.sierra2_4a, child: Text('Sierra 2-4A')),
                    DropdownMenuItem(value: Dither.floydSteinberg, child: Text('Floyd–Steinberg')),
                    DropdownMenuItem(value: Dither.bayer, child: Text('Bayer')),
                    DropdownMenuItem(value: Dither.none, child: Text('—')),
                  ],
                ),
              ),
              if (advanced)
                SettingTile(
                  title: l.pStaticBg,
                  hint: l.pStaticBgHint,
                  control: Switch(
                    value: _g.staticBackground,
                    onChanged: (v) => setState(() => _g = _copy(staticBackground: v)),
                  ),
                ),
            ],
            if (_g.format == AnimFormat.webp)
              SettingTile(
                title: l.pWebpQuality,
                hint: l.pWebpQualityHint,
                controlBelow: true,
                control: ZonedSlider(
                  value: _g.webpQuality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 18,
                  leftLabel: l.zoneSmallerFile,
                  rightLabel: l.zoneBetterQuality,
                  onChanged: (v) => setState(() => _g = _copy(webpQuality: v.round())),
                ),
              ),
            SettingTile(
              title: l.pLoop,
              hint: l.pLoopHint,
              control: Switch(
                value: _g.loop,
                onChanged: (v) => setState(() => _g = _copy(loop: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
