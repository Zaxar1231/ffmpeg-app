import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/error_translator.dart';
import '../../core/engine/ffmpeg_command.dart' show formatTimestamp;
import '../../core/engine/progress.dart' show parseFfmpegTime;
import '../../core/engine/process_runner.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';

/// Rewrites a job so it encodes only [length] from [start] into [fragment]:
/// `-ss` goes before the main input, `-t` before every output.
/// Returns null when the job cannot be cut this way (stream copy, segment
/// muxer, several outputs of the main file…).
List<JobStep>? fragmentSteps(
  List<JobStep> steps, {
  required String mainPath,
  required String output,
  required String fragment,
  required Duration start,
  required Duration length,
}) {
  final out = <JobStep>[];
  for (final s in steps) {
    if (s.tool != JobTool.ffmpeg) return null;
    final a = List<String>.of(s.args);
    if (a.contains('segment') || a.contains('-filter_complex') && a.any((x) => x.contains('trim='))) return null;
    final i = a.indexWhere((x) => x == mainPath);
    if (i < 1 || a[i - 1] != '-i') return null;
    a.insertAll(i - 1, ['-ss', formatTimestamp(start)]);
    final last = a.length - 1;
    if (a[last] == output) {
      a[last] = fragment;
    } else if (a[last] != '-') {
      return null;
    }
    a.insertAll(a.length - 1, ['-t', formatTimestamp(length)]);
    out.add(
      JobStep(
        args: a,
        tool: s.tool,
        label: s.label,
        weight: s.weight,
        workingDirectory: s.workingDirectory,
        files: s.files,
        totalDuration: length,
      ),
    );
  }
  return out;
}

/// "Compare A/B" button: renders a short fragment with the current settings
/// and shows it next to the original (curtain, side by side, or toggle).
class AbCompareButton extends ConsumerWidget {
  const AbCompareButton({super.key, required this.info, required this.steps, required this.output});
  final MediaInfo info;
  final List<JobStep> steps;
  final String output;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final ok =
        info.videoStreams.isNotEmpty &&
        fragmentSteps(
              steps,
              mainPath: info.path,
              output: output,
              fragment: 'x',
              start: Duration.zero,
              length: Duration.zero,
            ) !=
            null;
    if (!ok) return const SizedBox.shrink();
    return TextButton.icon(
      icon: const Icon(Icons.compare),
      label: Text(l.abCompare),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => _AbDialog(info: info, steps: steps, output: output),
      ),
    );
  }
}

enum _AbMode { curtain, sideBySide, toggle }

class _AbDialog extends ConsumerStatefulWidget {
  const _AbDialog({required this.info, required this.steps, required this.output});
  final MediaInfo info;
  final List<JobStep> steps;
  final String output;

  @override
  ConsumerState<_AbDialog> createState() => _AbDialogState();
}

class _AbDialogState extends ConsumerState<_AbDialog> {
  late Duration _start = _defaultStart();
  int _seconds = 5;
  Directory? _tmp;
  RunHandle? _handle;
  double? _fraction;
  String? _error;
  String? _fragment;
  int? _fragmentSize;
  int _seq = 0;

  final _a = Player(), _b = Player();
  late final _va = VideoController(_a), _vb = VideoController(_b);
  _AbMode _mode = _AbMode.curtain;
  double _split = 0.5;
  bool _showB = true;
  Timer? _sync;

  Duration _defaultStart() {
    final d = widget.info.duration ?? Duration.zero;
    return d > const Duration(seconds: 20) ? d * 0.3 : Duration.zero;
  }

  @override
  void dispose() {
    _sync?.cancel();
    unawaited(_handle?.cancel());
    _a.dispose();
    _b.dispose();
    final t = _tmp;
    if (t != null) unawaited(t.delete(recursive: true).catchError((_) => t));
    super.dispose();
  }

  Future<void> _render() async {
    final tc = ref.read(toolchainProvider);
    final ffmpeg = tc.ffmpeg.path;
    if (ffmpeg == null) return;
    _tmp ??= await Directory.systemTemp.createTemp('kadra_ab');
    final jobTmp = await Directory(p.join(_tmp!.path, 'job${_seq++}')).create();
    final frag = p.join(_tmp!.path, 'b$_seq${p.extension(widget.output)}');
    final len = Duration(seconds: _seconds);
    final steps = fragmentSteps(
      widget.steps,
      mainPath: widget.info.path,
      output: widget.output,
      fragment: frag,
      start: _start,
      length: len,
    )!;
    setState(() {
      _error = null;
      _fraction = 0;
      _fragment = null;
    });
    await _a.stop();
    await _b.stop();
    final vars = {'tmp': jobTmp.path};
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      for (final f in s.files.entries) {
        await File(substitute([f.key], vars).single).writeAsString(substitute([f.value], vars).single);
      }
      final h = await ref
          .read(processRunnerProvider)
          .start(
            ToolInvocation(
              executable: ffmpeg,
              args: substitute(s.args, vars),
              workingDirectory: substituteOpt(s.workingDirectory, vars),
              totalDuration: len,
            ),
          );
      _handle = h;
      final sub = h.progress.listen((pr) {
        if (mounted && pr.fraction != null) setState(() => _fraction = (i + pr.fraction!) / steps.length);
      });
      final r = await h.done;
      await sub.cancel();
      _handle = null;
      if (!mounted) return;
      if (r.canceled) {
        setState(() => _fraction = null);
        return;
      }
      if (!r.success) {
        final e = translateToolError(r.log, startError: r.startError);
        setState(() {
          _fraction = null;
          _error = e.kind == ToolErrorKind.unknown ? r.log.lastOrNull : toolErrorText(context.l10n, e.kind, e.detail);
        });
        return;
      }
    }
    final size = await File(frag).length();
    setState(() {
      _fraction = null;
      _fragment = frag;
      _fragmentSize = size;
    });
    await _a.open(Media(widget.info.path, start: _start, end: _start + len), play: false);
    await _b.open(Media(frag), play: false);
    await _a.setPlaylistMode(PlaylistMode.loop);
    await _b.setPlaylistMode(PlaylistMode.loop);
    await _a.setVolume(0);
    await _play();
    if (mounted) setState(() {});
  }

  Future<void> _play() async {
    await _a.seek(_start);
    await _b.seek(Duration.zero);
    await _a.play();
    await _b.play();
    _sync?.cancel();
    // Keep the original in step with the fragment (drift > 80 ms).
    _sync = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!_b.state.playing) return;
      final want = _start + _b.state.position;
      if ((_a.state.position - want).abs() > const Duration(milliseconds: 80)) unawaited(_a.seek(want));
    });
  }

  Future<void> _togglePlay() async {
    if (_b.state.playing) {
      await _a.pause();
      await _b.pause();
    } else {
      await _a.play();
      await _b.play();
    }
    setState(() {});
  }

  Widget _video(VideoController c) => Video(controller: c, controls: NoVideoControls, fill: Colors.black);

  Widget _labeled(Widget v, String label, Alignment a) => Stack(
    fit: StackFit.expand,
    children: [
      v,
      Align(
        alignment: a,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: Colors.black54,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final v = widget.info.videoStreams.first;
    final aspect = (v.width ?? 16) / (v.height ?? 9);
    final full = widget.info.duration;
    final estimate = _fragmentSize != null && full != null
        ? (_fragmentSize! * full.inMicroseconds / Duration(seconds: _seconds).inMicroseconds).round()
        : null;

    Widget view;
    if (_fragment == null) {
      view = Center(
        child: _fraction != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 280, child: LinearProgressIndicator(value: _fraction)),
                  const SizedBox(height: 8),
                  Text(l.abRendering, style: const TextStyle(color: Colors.white70)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error ?? l.abIntro,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _error != null ? t.colorScheme.error : Colors.white70),
                ),
              ),
      );
    } else {
      view = switch (_mode) {
        _AbMode.sideBySide => Row(
          children: [
            Expanded(child: _labeled(_video(_va), l.abOriginal, Alignment.topLeft)),
            const SizedBox(width: 4),
            Expanded(child: _labeled(_video(_vb), l.abResult, Alignment.topRight)),
          ],
        ),
        _AbMode.toggle => GestureDetector(
          onTap: () => setState(() => _showB = !_showB),
          child: _labeled(
            Stack(
              fit: StackFit.expand,
              children: [
                Offstage(offstage: _showB, child: _video(_va)),
                Offstage(offstage: !_showB, child: _video(_vb)),
              ],
            ),
            _showB ? l.abResult : l.abOriginal,
            Alignment.topLeft,
          ),
        ),
        _AbMode.curtain => LayoutBuilder(
          builder: (context, c) => GestureDetector(
            onHorizontalDragUpdate: (d) => setState(() => _split = (d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
            onTapDown: (d) => setState(() => _split = (d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _labeled(_video(_vb), l.abResult, Alignment.topRight),
                  ClipRect(clipper: _Left(_split), child: _labeled(_video(_va), l.abOriginal, Alignment.topLeft)),
                  Positioned(
                    left: c.maxWidth * _split - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      };
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.abTitle, style: t.textTheme.titleLarge)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: Colors.black,
                    child: AspectRatio(aspectRatio: _mode == _AbMode.sideBySide ? aspect * 2 : aspect, child: view),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l.abFrom),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: formatDuration(_start, millis: true),
                      decoration: const InputDecoration(isDense: true),
                      onFieldSubmitted: (s) {
                        final d = parseFfmpegTime(s);
                        if (d != null) setState(() => _start = d);
                      },
                    ),
                  ),
                  DropdownButton<int>(
                    value: _seconds,
                    onChanged: (v) => setState(() => _seconds = v!),
                    items: [
                      for (final s in const [3, 5, 10, 20])
                        DropdownMenuItem(value: s, child: Text('$s ${l.unitSecond}')),
                    ],
                  ),
                  if (_handle != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: Text(l.cancel),
                      onPressed: () => _handle?.cancel(),
                    )
                  else
                    FilledButton.icon(
                      icon: const Icon(Icons.movie_filter_outlined),
                      label: Text(_fragment == null ? l.abRender : l.abRerender),
                      onPressed: _render,
                    ),
                  if (_fragment != null) ...[
                    IconButton(
                      tooltip: l.pause,
                      icon: Icon(_b.state.playing ? Icons.pause : Icons.play_arrow),
                      onPressed: _togglePlay,
                    ),
                    SegmentedButton<_AbMode>(
                      segments: [
                        ButtonSegment(value: _AbMode.curtain, label: Text(l.previewSplit)),
                        ButtonSegment(value: _AbMode.sideBySide, label: Text(l.abSideBySide)),
                        ButtonSegment(value: _AbMode.toggle, label: Text(l.abToggle)),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (v) => setState(() => _mode = v.first),
                    ),
                  ],
                ],
              ),
              if (_fragmentSize != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l.abSizeNote(
                      formatBytes(_fragmentSize, units: byteUnits(l)),
                      estimate == null ? '—' : formatBytes(estimate, units: byteUnits(l)),
                    ),
                    style: t.textTheme.bodySmall,
                  ),
                ),
              if (_mode == _AbMode.toggle && _fragment != null) Text(l.abToggleHint, style: t.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Left extends CustomClipper<Rect> {
  _Left(this.f);
  final double f;
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * f, size.height);
  @override
  bool shouldReclip(covariant _Left old) => old.f != f;
}
