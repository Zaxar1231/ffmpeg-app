import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/engine/encoders.dart';
import '../../../core/engine/progress.dart' show parseFfmpegTime;
import '../../../core/probe/media_info.dart';
import '../../../core/providers.dart';
import '../../../core/queue/job_steps.dart';
import '../../../core/queue/queue_models.dart';
import '../../../core/util/format.dart';
import '../../../core/util/output_paths.dart';
import '../../../ui/l10n.dart';
import '../../../ui/widgets/setting_tile.dart';
import '../../convert/convert_params.dart';
import '../../convert/labels.dart';
import '../../tools/tool_catalog.dart';
import '../../tools/tool_infra.dart';
import '../../tools/tool_scaffold.dart';
import '../edit_encode.dart';
import '../graphs.dart';

// ======================================================== output settings

class EditOutputGroup extends StatelessWidget {
  const EditOutputGroup({super.key, required this.value, required this.onChanged, this.containers = editContainers});
  final EditOutput value;
  final ValueChanged<EditOutput> onChanged;
  final List<String> containers;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ParamGroup(
      title: l.groupEditOutput,
      children: [
        SettingTile(
          title: l.pContainer,
          hint: l.pEditContainerHint,
          control: DropdownButton<String>(
            value: containers.contains(value.ext) ? value.ext : containers.first,
            onChanged: (v) => onChanged(value.copyWith(ext: v)),
            items: [for (final c in containers) DropdownMenuItem(value: c, child: Text(c.toUpperCase()))],
          ),
        ),
        SettingTile(
          title: l.pEditQuality,
          hint: l.pEditQualityHint,
          help: l.pEditQualityHelp,
          controlBelow: true,
          control: SegmentedButton<EditQuality>(
            segments: [
              ButtonSegment(value: EditQuality.high, label: Text(l.editQualityHigh)),
              ButtonSegment(value: EditQuality.balanced, label: Text(l.editQualityBalanced)),
              ButtonSegment(value: EditQuality.small, label: Text(l.editQualitySmall)),
            ],
            selected: {value.quality},
            onSelectionChanged: (v) => onChanged(value.copyWith(quality: v.first)),
          ),
        ),
        SettingTile(
          title: l.pSpeed,
          hint: l.pEditSpeedHint,
          control: DropdownButton<SpeedPreset>(
            value: value.speed,
            onChanged: (v) => onChanged(value.copyWith(speed: v)),
            items: [for (final s in SpeedPreset.values) DropdownMenuItem(value: s, child: Text(speedLabel(l, s)))],
          ),
        ),
      ],
    );
  }
}

// ============================================================== scaffold

/// Standard layout of an editing tool: preview + parameters + output
/// format; builds the job from [graph] (or [customSteps]).
class EditScaffold extends ConsumerStatefulWidget {
  const EditScaffold({
    super.key,
    required this.toolId,
    required this.info,
    required this.params,
    this.graph,
    this.customSteps,
    this.preview,
    this.preSteps = const [],
    this.workingDirectory,
    this.eightBit = false,
    this.suffix = '_edit',
    this.problems = const [],
    this.warnings = const [],
    this.estimate,
    this.fixedExt,
    this.inputCount = 1,
    this.compare = false,
  });

  /// Offer the A/B comparison (single-input tools that keep timing).
  final bool compare;

  final String toolId;
  final MediaInfo info;
  final List<Widget> params;
  final Widget? preview;

  /// Null (with [customSteps] null) = parameters are not ready.
  final EditGraph? graph;

  /// Stream-copy paths: steps for the chosen output path.
  final List<JobStep> Function(String output, EditOutput out)? customSteps;
  final List<JobStep> preSteps;
  final String? workingDirectory;
  final bool eightBit;
  final String suffix;
  final List<String> problems;
  final List<String> warnings;
  final String? estimate;

  /// Output container fixed (stream copy keeps the source's).
  final String? fixedExt;

  /// For the job title ("+2").
  final int inputCount;

  @override
  ConsumerState<EditScaffold> createState() => _EditScaffoldState();
}

class _EditScaffoldState extends ConsumerState<EditScaffold> {
  late EditOutput _out = EditOutput(ext: editExtFor(widget.info));
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final env = ref.watch(encodeEnvProvider);
    final ext = widget.fixedExt ?? _out.ext;
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: widget.suffix), ext);
    List<JobStep>? steps;
    final problems = [...widget.problems];
    final warnings = [...widget.warnings];
    Duration? total = info.duration;
    if (widget.customSteps != null) {
      steps = widget.customSteps!(out, _out.copyWith(ext: ext));
    } else if (widget.graph != null) {
      final plan = planEdit(
        info: info,
        output: out,
        graph: widget.graph!,
        out: _out.copyWith(ext: ext),
        env: env,
        workingDirectory: widget.workingDirectory,
        eightBit: widget.eightBit,
      );
      problems.addAll(plan.issues.map((i) => convertIssueText(l, i)));
      warnings.addAll(plan.warnings.map((i) => convertIssueText(l, i)));
      steps = [...widget.preSteps, ...plan.steps];
      total = widget.graph!.duration ?? info.duration;
    }
    return ToolScaffold(
      toolId: widget.toolId,
      info: info,
      compare: widget.compare,
      preview: widget.preview,
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: problems,
      warnings: warnings,
      estimate: widget.estimate ?? (total == null ? null : l.resultLength(formatDuration(total, millis: true))),
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: widget.toolId,
          title:
              '${toolTitle(l, widget.toolId)}: ${p.basename(info.path)}'
              '${widget.inputCount > 1 ? ' +${widget.inputCount - 1}' : ''}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: total,
        ),
        now: now,
      ),
      params: [
        ...widget.params,
        if (widget.fixedExt == null) EditOutputGroup(value: _out, onChanged: (v) => setState(() => _out = v)),
      ],
    );
  }
}

// ========================================================= frame preview

enum _PreviewMode { result, original, split }

/// One frame of the source with the tool's graph applied (rendered by
/// ffmpeg), with before/after comparison and optional rectangle editing
/// in source pixel coordinates.
class FramePreview extends ConsumerStatefulWidget {
  const FramePreview({
    super.key,
    required this.info,
    this.graph,
    this.rects,
    this.onRectsChanged,
    this.maxRects = 1,
    this.initialTime,
    this.onTimeChanged,
  });

  final MediaInfo info;

  /// Null = show the original only.
  final EditGraph? graph;

  /// Editable rectangles (source pixels). While editing, the original
  /// frame is shown so coordinates match the source.
  final List<CropRect>? rects;
  final ValueChanged<List<CropRect>>? onRectsChanged;
  final int maxRects;
  final Duration? initialTime;
  final ValueChanged<Duration>? onTimeChanged;

  @override
  ConsumerState<FramePreview> createState() => _FramePreviewState();
}

class _FramePreviewState extends ConsumerState<FramePreview> {
  late Duration _at = widget.initialTime ?? _defaultTime();
  _PreviewMode _mode = _PreviewMode.result;
  Uint8List? _result;
  Uint8List? _original;
  String? _error;
  bool _busy = false;
  Timer? _debounce;
  Directory? _tmp;
  int _seq = 0;
  String? _lastKey;
  double _split = 0.5;

  Duration _defaultTime() {
    final d = widget.info.duration ?? Duration.zero;
    return d > const Duration(seconds: 2) ? d * 0.25 : Duration.zero;
  }

  bool get _editing => widget.rects != null;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant FramePreview old) {
    super.didUpdateWidget(old);
    _schedule();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final t = _tmp;
    if (t != null) unawaited(t.delete(recursive: true).catchError((_) => t));
    super.dispose();
  }

  void _schedule() {
    final key = '${_at.inMilliseconds}|${widget.graph?.complex}|${widget.graph?.inputs.map((i) => i.path).join()}';
    if (key == _lastKey) return;
    _lastKey = key;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _render);
  }

  Future<Uint8List?> _frame({required bool original}) async {
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null) return null;
    _tmp ??= await Directory.systemTemp.createTemp('kadra_prev');
    final out = p.join(_tmp!.path, 'f${_seq++}.png');
    final args = previewFrameArgs(info: widget.info, at: _at, output: out, graph: widget.graph, original: original);
    final r = await ref.read(processRunnerProvider).capture(ffmpeg, args, timeout: const Duration(seconds: 40));
    final f = File(out);
    if (!r.ok || !f.existsSync()) {
      if (mounted) setState(() => _error = r.stderr.trim().split('\n').where((s) => s.trim().isNotEmpty).lastOrNull);
      return null;
    }
    final bytes = await f.readAsBytes();
    unawaited(f.delete().catchError((_) => f));
    return bytes;
  }

  Future<void> _render() async {
    if (!mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final key = _lastKey;
    final orig = await _frame(original: true);
    final res = widget.graph == null ? orig : await _frame(original: false);
    if (!mounted || key != _lastKey) return;
    setState(() {
      _busy = false;
      _original = orig ?? _original;
      _result = res ?? (widget.graph == null ? orig : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final total = widget.info.duration ?? Duration.zero;
    final (sw, sh) = displaySize(widget.info);
    final showOriginal = _editing || widget.graph == null || _mode == _PreviewMode.original;
    final img = showOriginal ? _original : _result;
    Widget picture;
    if (img == null) {
      picture = Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(color: cs.error),
                  textAlign: TextAlign.center,
                ),
              )
            : const CircularProgressIndicator(),
      );
    } else if (!showOriginal && _mode == _PreviewMode.split && _original != null) {
      picture = _SplitView(before: _original!, after: img, split: _split, onSplit: (v) => setState(() => _split = v));
    } else {
      picture = Image.memory(img, gaplessPlayback: true, fit: BoxFit.contain);
      if (_editing && sw > 0 && sh > 0) {
        picture = _RectEditor(
          width: sw,
          height: sh,
          rects: widget.rects!,
          maxRects: widget.maxRects,
          onChanged: widget.onRectsChanged ?? (_) {},
          child: picture,
        );
      }
    }
    final shown = img == null ? null : _pngSize(img);
    final aspect = shown != null ? shown.$1 / shown.$2 : (sw > 0 && sh > 0 ? sw / sh : 16 / 9);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: aspect.clamp(0.75, 3.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  picture,
                  if (_busy)
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 92,
              child: Text(formatDuration(_at, millis: true), style: Theme.of(context).textTheme.labelMedium),
            ),
            Expanded(
              child: Slider(
                value: _at.inMilliseconds.toDouble().clamp(0, math.max(1, total.inMilliseconds).toDouble()),
                max: math.max(1, total.inMilliseconds).toDouble(),
                onChanged: total == Duration.zero
                    ? null
                    : (v) {
                        setState(() => _at = Duration(milliseconds: v.round()));
                        widget.onTimeChanged?.call(_at);
                        _schedule();
                      },
              ),
            ),
          ],
        ),
        if (widget.graph != null && !_editing)
          Center(
            child: SegmentedButton<_PreviewMode>(
              segments: [
                ButtonSegment(value: _PreviewMode.original, label: Text(l.previewBefore)),
                ButtonSegment(value: _PreviewMode.split, label: Text(l.previewSplit)),
                ButtonSegment(value: _PreviewMode.result, label: Text(l.previewAfter)),
              ],
              selected: {_mode},
              onSelectionChanged: (v) => setState(() => _mode = v.first),
            ),
          ),
        if (_editing)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.maxRects == 1 ? l.rectHintOne : l.rectHintMany,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

/// Width and height from a PNG header (IHDR).
(int, int)? _pngSize(Uint8List b) {
  if (b.length < 24 || b[1] != 0x50 || b[2] != 0x4E || b[3] != 0x47) return null;
  final d = ByteData.sublistView(b);
  final w = d.getUint32(16), h = d.getUint32(20);
  return w > 0 && h > 0 ? (w, h) : null;
}

/// Before/after curtain: the left part shows [before].
class _SplitView extends StatelessWidget {
  const _SplitView({required this.before, required this.after, required this.split, required this.onSplit});
  final Uint8List before;
  final Uint8List after;
  final double split;
  final ValueChanged<double> onSplit;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => GestureDetector(
      onHorizontalDragUpdate: (d) => onSplit((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
      onTapDown: (d) => onSplit((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(after, gaplessPlayback: true, fit: BoxFit.contain),
            ClipRect(
              clipper: _LeftClipper(split),
              child: Image.memory(before, gaplessPlayback: true, fit: BoxFit.contain),
            ),
            Positioned(
              left: c.maxWidth * split - 1,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.f);
  final double f;
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * f, size.height);
  @override
  bool shouldReclip(covariant _LeftClipper old) => old.f != f;
}

/// Draw/move/resize rectangles over a picture of [width]×[height] source px.
class _RectEditor extends StatefulWidget {
  const _RectEditor({
    required this.width,
    required this.height,
    required this.rects,
    required this.maxRects,
    required this.onChanged,
    required this.child,
  });
  final int width;
  final int height;
  final List<CropRect> rects;
  final int maxRects;
  final ValueChanged<List<CropRect>> onChanged;
  final Widget child;

  @override
  State<_RectEditor> createState() => _RectEditorState();
}

enum _Drag { create, move, resize }

class _RectEditorState extends State<_RectEditor> {
  _Drag? _drag;
  int _index = -1;
  Offset _start = Offset.zero;
  CropRect? _orig;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      // The picture is letterboxed by BoxFit.contain.
      final scale = math.min(c.maxWidth / widget.width, c.maxHeight / widget.height);
      final ox = (c.maxWidth - widget.width * scale) / 2;
      final oy = (c.maxHeight - widget.height * scale) / 2;
      Offset toSrc(Offset o) => Offset(
        ((o.dx - ox) / scale).clamp(0, widget.width.toDouble()),
        ((o.dy - oy) / scale).clamp(0, widget.height.toDouble()),
      );
      Rect toView(CropRect r) => Rect.fromLTWH(ox + r.x * scale, oy + r.y * scale, r.w * scale, r.h * scale);

      return GestureDetector(
        onPanStart: (d) {
          final pos = d.localPosition;
          _start = toSrc(pos);
          _drag = _Drag.create;
          _index = -1;
          for (var i = widget.rects.length - 1; i >= 0; i--) {
            final v = toView(widget.rects[i]);
            if ((pos - v.bottomRight).distance < 14) {
              _drag = _Drag.resize;
              _index = i;
              break;
            }
            if (v.contains(pos)) {
              _drag = _Drag.move;
              _index = i;
              break;
            }
          }
          _orig = _index >= 0 ? widget.rects[_index] : null;
        },
        onPanUpdate: (d) {
          final now = toSrc(d.localPosition);
          final rects = [...widget.rects];
          switch (_drag) {
            case _Drag.create:
              final r = CropRect(
                math.min(_start.dx, now.dx).round(),
                math.min(_start.dy, now.dy).round(),
                math.max(2, (now.dx - _start.dx).abs().round()),
                math.max(2, (now.dy - _start.dy).abs().round()),
              );
              if (_index < 0) {
                if (rects.length >= widget.maxRects) rects.removeAt(0);
                rects.add(r);
                _index = rects.length - 1;
              } else {
                rects[_index] = r;
              }
            case _Drag.move:
              final o = _orig!;
              final dx = (now.dx - _start.dx).round(), dy = (now.dy - _start.dy).round();
              rects[_index] = CropRect(
                (o.x + dx).clamp(0, widget.width - o.w),
                (o.y + dy).clamp(0, widget.height - o.h),
                o.w,
                o.h,
              );
            case _Drag.resize:
              final o = _orig!;
              rects[_index] = CropRect(o.x, o.y, math.max(4, now.dx.round() - o.x), math.max(4, now.dy.round() - o.y));
            case null:
              return;
          }
          widget.onChanged(rects);
        },
        onPanEnd: (_) => _drag = null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            CustomPaint(painter: _RectPainter([for (final r in widget.rects) toView(r)])),
          ],
        ),
      );
    },
  );
}

class _RectPainter extends CustomPainter {
  _RectPainter(this.rects);
  final List<Rect> rects;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final r in rects) {
      canvas.drawRect(r, Paint()..color = Colors.yellowAccent.withValues(alpha: 0.12));
      canvas.drawRect(r, stroke);
      canvas.drawRect(
        Rect.fromCenter(center: r.bottomRight, width: 10, height: 10),
        Paint()..color = Colors.yellowAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RectPainter old) => true;
}

// ============================================================== clip list

/// Ordered list of input clips (probed); the first one is the tool's file.
class ClipList extends ConsumerWidget {
  const ClipList({super.key, required this.clips, required this.onChanged, this.min = 2, this.max = 50});
  final List<MediaInfo> clips;
  final ValueChanged<List<MediaInfo>> onChanged;
  final int min;
  final int max;

  Future<void> _add(WidgetRef ref, BuildContext context) async {
    final files = await openFiles();
    final probe = ref.read(probeServiceProvider);
    if (probe == null || files.isEmpty) return;
    final added = <MediaInfo>[];
    for (final f in files) {
      try {
        added.add(await probe.probe(f.path));
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.l10n.probeFailed}: ${f.name}')));
        }
      }
    }
    onChanged([...clips, ...added].take(max).toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: clips.length,
          onReorderItem: (a, b) {
            final list = [...clips];
            final it = list.removeAt(a);
            list.insert(b, it);
            onChanged(list);
          },
          itemBuilder: (context, i) {
            final c = clips[i];
            final v = c.videoStreams.firstOrNull;
            return ListTile(
              key: ValueKey('${c.path}#$i'),
              dense: true,
              leading: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_indicator)),
              title: Text('${i + 1}. ${p.basename(c.path)}', maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                [
                  formatDuration(c.duration),
                  if (v != null) '${v.width}×${v.height}',
                  if (v != null) v.codecName ?? '',
                  if (c.audioStreams.isEmpty) l.noAudioTag,
                ].join(' · '),
                style: t.textTheme.bodySmall,
              ),
              trailing: IconButton(
                tooltip: l.removeFromList,
                icon: const Icon(Icons.close),
                onPressed: clips.length <= 1 ? null : () => onChanged([...clips]..removeAt(i)),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l.addFiles),
                onPressed: clips.length >= max ? null : () => _add(ref, context),
              ),
              const SizedBox(width: 12),
              if (clips.length < min)
                Expanded(
                  child: Text(l.needMoreClips(min), style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.error)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================ time field

/// `H:MM:SS.mmm` editor (commits on Enter / focus loss).
class DurationField extends StatefulWidget {
  const DurationField({super.key, required this.value, required this.onChanged, this.width = 130, this.hint});
  final Duration? value;
  final ValueChanged<Duration?> onChanged;
  final double width;
  final String? hint;

  @override
  State<DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<DurationField> {
  late final TextEditingController _c = TextEditingController(text: _fmt(widget.value));
  final _focus = FocusNode();

  String _fmt(Duration? d) => d == null ? '' : formatDuration(d, millis: true);

  @override
  void didUpdateWidget(covariant DurationField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus) _c.text = _fmt(widget.value);
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final t = _c.text.trim();
    if (t.isEmpty) return widget.onChanged(null);
    final d = parseFfmpegTime(t);
    if (d != null) widget.onChanged(d);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    child: TextField(
      controller: _c,
      focusNode: _focus,
      decoration: InputDecoration(isDense: true, hintText: widget.hint),
      onSubmitted: (_) => _commit(),
      onTapOutside: (_) {
        if (_focus.hasFocus) {
          _commit();
          _focus.unfocus();
        }
      },
    ),
  );
}

/// Labeled numeric slider row used by many tools.
class ValueSlider extends StatelessWidget {
  const ValueSlider({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.format,
    this.help,
    this.defaultValue,
  });
  final String title;
  final String hint;
  final String? help;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? format;
  final ValueChanged<double> onChanged;
  final double? defaultValue;

  @override
  Widget build(BuildContext context) => SettingTile(
    title: title,
    hint: hint,
    help: help,
    controlBelow: true,
    isDefault: defaultValue == null || (value - defaultValue!).abs() < 1e-9,
    onReset: defaultValue == null ? null : () => onChanged(defaultValue!),
    control: ZonedSlider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      valueLabel: format ?? (v) => fnum(v, 2),
      onChanged: onChanged,
    ),
  );
}
