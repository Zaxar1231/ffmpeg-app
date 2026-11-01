import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;

import '../../../core/engine/containers.dart';
import '../../../core/probe/media_info.dart';
import '../../../core/util/format.dart';
import '../../../ui/l10n.dart';
import '../../../ui/widgets/common.dart';
import '../../../ui/widgets/media_preview.dart';
import '../../../ui/widgets/setting_tile.dart';
import '../../convert/convert_params.dart';
import '../../tools/tool_scaffold.dart';
import '../copy_ops.dart';
import '../graphs.dart';
import 'edit_widgets.dart';

/// Source container when stream copy can keep it.
String copyExtFor(MediaInfo info) {
  final e = p.extension(info.path).replaceFirst('.', '').toLowerCase();
  return containers.containsKey(e) ? e : 'mkv';
}

// ================================================================ cut/join

class CutJoinPage extends ConsumerWidget {
  const CutJoinPage({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'cutJoin',
    path: path,
    builder: (info) => _CutJoinForm(key: ValueKey(info.path), info: info),
  );
}

class _CutJoinForm extends StatefulWidget {
  const _CutJoinForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_CutJoinForm> createState() => _CutJoinFormState();
}

class _CutJoinFormState extends State<_CutJoinForm> {
  final _ranges = <(Duration, Duration)>[];
  bool _removeMarked = true;
  bool _lossless = false;
  Duration? _pendingStart;
  Player? _player;
  Duration _pos = Duration.zero;
  StreamSubscription<Duration>? _sub;

  Duration get _total => widget.info.duration ?? Duration.zero;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<(Duration, Duration)> get _keep {
    final sorted = [..._ranges]..sort((a, b) => a.$1.compareTo(b.$1));
    return _removeMarked ? invertRanges(sorted, _total) : sorted;
  }

  void _markStart() => setState(() => _pendingStart = _pos);

  void _markEnd() {
    final s = _pendingStart ?? Duration.zero;
    if (_pos <= s) return;
    setState(() {
      _ranges.add((s, _pos));
      _pendingStart = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final keep = _keep;
    final valid = keep.isNotEmpty && _ranges.isNotEmpty;
    final preview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MediaPreview(
          path: info.path,
          aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9,
          onPlayer: (pl) {
            _player = pl;
            _sub = pl.stream.position.listen((d) {
              if (mounted) setState(() => _pos = d);
            });
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: LayoutBuilder(
            builder: (context, c) => GestureDetector(
              onTapDown: (d) {
                final t = _total * (d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0);
                _player?.seek(t);
              },
              child: CustomPaint(
                size: Size(c.maxWidth, 34),
                painter: _RangesPainter(
                  total: _total,
                  ranges: _ranges,
                  removeMarked: _removeMarked,
                  pos: _pos,
                  pending: _pendingStart,
                  keepColor: Theme.of(context).colorScheme.primary,
                  removeColor: Theme.of(context).colorScheme.error,
                  track: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.first_page),
              label: Text(l.markFragmentStart(formatDuration(_pos, millis: true))),
              onPressed: _markStart,
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.last_page),
              label: Text(l.markFragmentEnd(formatDuration(_pos, millis: true))),
              onPressed: _pos > (_pendingStart ?? Duration.zero) ? _markEnd : null,
            ),
          ],
        ),
      ],
    );
    return EditScaffold(
      toolId: 'cutJoin',
      info: info,
      preview: preview,
      suffix: '_edit',
      graph: valid && !_lossless ? cutGraph(info, keep) : null,
      customSteps: valid && _lossless ? (out, _) => planCutCopy(info, keep, out) : null,
      fixedExt: _lossless ? copyExtFor(info) : null,
      estimate: valid
          ? l.resultLength(
              formatDuration(keep.fold<Duration>(Duration.zero, (t, r) => t + (r.$2 - r.$1)), millis: true),
            )
          : null,
      problems: [if (_ranges.isEmpty) l.cutNoRanges else if (keep.isEmpty) l.cutNothingLeft],
      params: [
        ParamGroup(
          title: l.groupFragments,
          children: [
            SettingTile(
              title: l.pCutMode,
              hint: _removeMarked ? l.cutModeRemoveHint : l.cutModeKeepHint,
              controlBelow: true,
              control: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, icon: const Icon(Icons.content_cut), label: Text(l.cutModeRemove)),
                  ButtonSegment(value: false, icon: const Icon(Icons.check), label: Text(l.cutModeKeep)),
                ],
                selected: {_removeMarked},
                onSelectionChanged: (v) => setState(() => _removeMarked = v.first),
              ),
            ),
            if (_ranges.isEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.cutHowTo)),
            for (var i = 0; i < _ranges.length; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('${i + 1}.')),
                    DurationField(
                      value: _ranges[i].$1,
                      onChanged: (d) => setState(() => _ranges[i] = (d ?? Duration.zero, _ranges[i].$2)),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('—')),
                    DurationField(
                      value: _ranges[i].$2,
                      onChanged: (d) => setState(() => _ranges[i] = (_ranges[i].$1, d ?? _total)),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: l.playFragment,
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        _player?.seek(_ranges[i].$1);
                        _player?.play();
                      },
                    ),
                    IconButton(
                      tooltip: l.removeFromList,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _ranges.removeAt(i)),
                    ),
                  ],
                ),
              ),
            SettingTile(
              title: l.pLosslessCut,
              hint: _lossless ? l.losslessCutOnHint : l.losslessCutOffHint,
              help: l.pLosslessCutHelp,
              control: Switch(value: _lossless, onChanged: (v) => setState(() => _lossless = v)),
            ),
            if (_lossless)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TagChip(l.losslessTag, icon: Icons.bolt, color: Theme.of(context).colorScheme.tertiaryContainer),
              ),
          ],
        ),
      ],
    );
  }
}

class _RangesPainter extends CustomPainter {
  _RangesPainter({
    required this.total,
    required this.ranges,
    required this.removeMarked,
    required this.pos,
    required this.pending,
    required this.keepColor,
    required this.removeColor,
    required this.track,
  });
  final Duration total;
  final List<(Duration, Duration)> ranges;
  final bool removeMarked;
  final Duration pos;
  final Duration? pending;
  final Color keepColor, removeColor, track;

  @override
  void paint(Canvas canvas, Size size) {
    if (total == Duration.zero) return;
    double x(Duration d) => size.width * (d.inMicroseconds / total.inMicroseconds).clamp(0.0, 1.0);
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(0, 6, size.width, size.height - 12), const Radius.circular(6));
    canvas.drawRRect(r, Paint()..color = removeMarked ? keepColor.withValues(alpha: 0.35) : track);
    for (final (s, e) in ranges) {
      canvas.drawRect(
        Rect.fromLTRB(x(s), 6, x(e), size.height - 6),
        Paint()..color = removeMarked ? removeColor.withValues(alpha: 0.75) : keepColor.withValues(alpha: 0.85),
      );
    }
    if (pending != null) {
      canvas.drawRect(
        Rect.fromLTRB(x(pending!), 2, x(pos).clamp(x(pending!), size.width), size.height - 2),
        Paint()
          ..color = keepColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawLine(
      Offset(x(pos), 0),
      Offset(x(pos), size.height),
      Paint()
        ..color = Colors.green.shade600
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _RangesPainter o) => true;
}

// ================================================================== concat

enum _JoinSize { first, p1080, p720, vertical }

class ConcatPage extends ConsumerWidget {
  const ConcatPage({super.key, this.path, this.transitions = false});
  final String? path;
  final bool transitions;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: transitions ? 'transitions' : 'concat',
    path: path,
    builder: (info) => _ConcatForm(key: ValueKey(info.path), first: info, transitions: transitions),
  );
}

class _ConcatForm extends StatefulWidget {
  const _ConcatForm({super.key, required this.first, required this.transitions});
  final MediaInfo first;
  final bool transitions;
  @override
  State<_ConcatForm> createState() => _ConcatFormState();
}

class _ConcatFormState extends State<_ConcatForm> {
  late List<MediaInfo> _clips = [widget.first];
  bool _lossless = false;
  _JoinSize _size = _JoinSize.first;
  String _transition = 'fade';
  double _xfade = 1;
  double _fadeIn = 0;
  double _fadeOut = 0;

  JoinFrame get _frame {
    final f = JoinFrame.of(_clips.first);
    return switch (_size) {
      _JoinSize.first => f,
      _JoinSize.p1080 => JoinFrame(width: 1920, height: 1080, fps: f.fps),
      _JoinSize.p720 => JoinFrame(width: 1280, height: 720, fps: f.fps),
      _JoinSize.vertical => JoinFrame(width: 1080, height: 1920, fps: f.fps),
    };
  }

  Duration _d(double s) => Duration(milliseconds: (s * 1000).round());

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tr = widget.transitions;
    final mismatches = _clips.length > 1 ? concatMismatches(_clips) : const <String>[];
    final noVideo = _clips.any((c) => c.videoStreams.isEmpty);
    final minClips = tr ? 1 : 2;
    final tooShort = tr && _clips.length > 1 && _clips.any((c) => (c.duration ?? Duration.zero) <= _d(_xfade) * 2);
    final ok = _clips.length >= minClips && !noVideo && !tooShort;
    final lossless = !tr && _lossless;
    EditGraph? graph;
    if (ok && !lossless) {
      graph = tr
          ? (_clips.length == 1
                ? fadeGraph(_clips.first, _d(_fadeIn), _d(_fadeOut))
                : transitionGraph(
                    _clips,
                    _frame,
                    transition: _transition,
                    d: _d(_xfade),
                    fadeIn: _d(_fadeIn),
                    fadeOut: _d(_fadeOut),
                  ))
          : concatGraph(_clips, _frame);
    }
    return EditScaffold(
      toolId: tr ? 'transitions' : 'concat',
      info: _clips.first,
      inputCount: _clips.length,
      suffix: tr ? '_fx' : '_joined',
      preview: tr && _clips.length == 1 && graph != null ? FramePreview(info: _clips.first, graph: graph) : null,
      graph: graph,
      customSteps: ok && lossless ? (out, _) => planConcatCopy(_clips, out) : null,
      fixedExt: lossless ? copyExtFor(_clips.first) : null,
      problems: [
        if (_clips.length < minClips) l.needMoreClips(minClips),
        if (noVideo) l.issueNoVideo,
        if (tooShort) l.clipShorterThanTransition,
      ],
      warnings: [
        if (lossless && mismatches.isNotEmpty) l.concatMismatch(mismatches.map((m) => _mismatch(l, m)).join(', ')),
      ],
      params: [
        ParamGroup(
          title: l.groupClips,
          children: [ClipList(clips: _clips, min: minClips, onChanged: (v) => setState(() => _clips = v))],
        ),
        if (!tr)
          ParamGroup(
            title: l.groupJoin,
            children: [
              SettingTile(
                title: l.pLosslessJoin,
                hint: _lossless ? l.losslessJoinOnHint : l.losslessJoinOffHint,
                help: l.pLosslessJoinHelp,
                control: Switch(value: _lossless, onChanged: (v) => setState(() => _lossless = v)),
              ),
            ],
          ),
        if (tr && _clips.length > 1)
          ParamGroup(
            title: l.groupTransition,
            children: [
              SettingTile(
                title: l.pTransition,
                hint: l.pTransitionHint,
                control: DropdownButton<String>(
                  value: _transition,
                  onChanged: (v) => setState(() => _transition = v!),
                  items: [
                    for (final t in xfadeTransitions) DropdownMenuItem(value: t, child: Text(transitionName(l, t))),
                  ],
                ),
              ),
              ValueSlider(
                title: l.pTransitionDuration,
                hint: l.pTransitionDurationHint,
                value: _xfade,
                min: 0.2,
                max: 3,
                divisions: 28,
                format: (v) => '${fnum(v, 1)} ${l.unitSecond}',
                onChanged: (v) => setState(() => _xfade = v),
              ),
            ],
          ),
        if (tr)
          ParamGroup(
            title: l.groupFades,
            children: [
              ValueSlider(
                title: l.pFadeIn,
                hint: l.pFadeInHint,
                value: _fadeIn,
                min: 0,
                max: 5,
                divisions: 50,
                format: (v) => v == 0 ? l.off : '${fnum(v, 1)} ${l.unitSecond}',
                onChanged: (v) => setState(() => _fadeIn = v),
              ),
              ValueSlider(
                title: l.pFadeOut,
                hint: l.pFadeOutHint,
                value: _fadeOut,
                min: 0,
                max: 5,
                divisions: 50,
                format: (v) => v == 0 ? l.off : '${fnum(v, 1)} ${l.unitSecond}',
                onChanged: (v) => setState(() => _fadeOut = v),
              ),
            ],
          ),
        if (!lossless && (_clips.length > 1))
          ParamGroup(
            title: l.groupFrame,
            children: [
              SettingTile(
                title: l.pJoinSize,
                hint: l.pJoinSizeHint,
                control: DropdownButton<_JoinSize>(
                  value: _size,
                  onChanged: (v) => setState(() => _size = v!),
                  items: [
                    DropdownMenuItem(
                      value: _JoinSize.first,
                      child: Text(
                        l.joinSizeFirst('${JoinFrame.of(_clips.first).width}×${JoinFrame.of(_clips.first).height}'),
                      ),
                    ),
                    const DropdownMenuItem(value: _JoinSize.p1080, child: Text('1920×1080')),
                    const DropdownMenuItem(value: _JoinSize.p720, child: Text('1280×720')),
                    DropdownMenuItem(value: _JoinSize.vertical, child: Text('1080×1920 (${l.vertical})')),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

String _mismatch(AppLocalizations l, String m) => switch (m) {
  'codec' => l.mismatchCodec,
  'size' => l.mismatchSize,
  'pixfmt' => l.mismatchPixfmt,
  'audio' => l.mismatchAudio,
  'audioCodec' => l.mismatchAudioCodec,
  _ => l.mismatchVideo,
};

String transitionName(AppLocalizations l, String t) => switch (t) {
  'fade' => l.xfFade,
  'dissolve' => l.xfDissolve,
  'fadeblack' => l.xfFadeBlack,
  'fadewhite' => l.xfFadeWhite,
  'wipeleft' => l.xfWipe('←'),
  'wiperight' => l.xfWipe('→'),
  'wipeup' => l.xfWipe('↑'),
  'wipedown' => l.xfWipe('↓'),
  'slideleft' => l.xfSlide('←'),
  'slideright' => l.xfSlide('→'),
  'slideup' => l.xfSlide('↑'),
  'slidedown' => l.xfSlide('↓'),
  'smoothleft' => l.xfSmooth('←'),
  'smoothright' => l.xfSmooth('→'),
  'circleopen' => l.xfCircleOpen,
  'circleclose' => l.xfCircleClose,
  'circlecrop' => l.xfCircleCrop,
  'rectcrop' => l.xfRectCrop,
  'radial' => l.xfRadial,
  'pixelize' => l.xfPixelize,
  'distance' => l.xfDistance,
  'hblur' => l.xfBlur,
  'zoomin' => l.xfZoom,
  'diagtl' => l.xfDiagonal('↖'),
  'diagbr' => l.xfDiagonal('↘'),
  'squeezeh' => l.xfSqueeze('↔'),
  'squeezev' => l.xfSqueeze('↕'),
  'horzopen' => l.xfOpen('↔'),
  'vertopen' => l.xfOpen('↕'),
  _ => t,
};

// =================================================================== split

class SplitPage extends ConsumerWidget {
  const SplitPage({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'split',
    path: path,
    builder: (info) => _SplitForm(key: ValueKey(info.path), info: info),
  );
}

class _SplitForm extends StatefulWidget {
  const _SplitForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_SplitForm> createState() => _SplitFormState();
}

class _SplitFormState extends State<_SplitForm> {
  late SplitMode _mode = widget.info.chapters.length > 1 ? SplitMode.chapters : SplitMode.every;
  Duration _every = const Duration(minutes: 1);
  int _parts = 2;
  final _times = <Duration>[];
  bool _precise = false;
  Duration _pos = Duration.zero;
  StreamSubscription<Duration>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final s = SplitParams(mode: _mode, every: _every, parts: _parts, times: _times, precise: _precise);
    final count = splitCount(info, s);
    final noPoints = _mode != SplitMode.every && splitPoints(info, s).isEmpty;
    return EditScaffold(
      toolId: 'split',
      info: info,
      suffix: '',
      preview: MediaPreview(
        path: info.path,
        aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9,
        onPlayer: (pl) {
          _sub = pl.stream.position.listen((d) {
            if (mounted) setState(() => _pos = d);
          });
        },
      ),
      customSteps: noPoints ? null : (out, o) => planSplit(info: info, s: s, output: out, out: o),
      fixedExt: _precise ? null : copyExtFor(info),
      estimate: l.splitFiles(count),
      problems: [if (noPoints) l.splitNoPoints],
      warnings: [if (!_precise) l.splitKeyframeNote],
      params: [
        ParamGroup(
          title: l.groupSplit,
          children: [
            SettingTile(
              title: l.pSplitMode,
              hint: l.pSplitModeHint,
              controlBelow: true,
              control: SegmentedButton<SplitMode>(
                segments: [
                  ButtonSegment(value: SplitMode.every, label: Text(l.splitEvery)),
                  ButtonSegment(value: SplitMode.parts, label: Text(l.splitParts)),
                  ButtonSegment(
                    value: SplitMode.chapters,
                    label: Text(l.splitChapters),
                    enabled: info.chapters.length > 1,
                  ),
                  ButtonSegment(value: SplitMode.times, label: Text(l.splitTimes)),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() => _mode = v.first),
              ),
            ),
            if (_mode == SplitMode.every)
              SettingTile(
                title: l.pSplitEvery,
                hint: l.pStartHint,
                control: DurationField(value: _every, onChanged: (d) => setState(() => _every = d ?? _every)),
              ),
            if (_mode == SplitMode.parts)
              ValueSlider(
                title: l.pSplitParts,
                hint: l.pSplitPartsHint,
                value: _parts.toDouble(),
                min: 2,
                max: 20,
                divisions: 18,
                format: (v) => '${v.round()}',
                onChanged: (v) => setState(() => _parts = v.round()),
              ),
            if (_mode == SplitMode.chapters)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text([for (final c in info.chapters) '${formatDuration(c.start)}  ${c.title ?? ''}'].join('\n')),
              ),
            if (_mode == SplitMode.times) ...[
              for (var i = 0; i < _times.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                  child: Row(
                    children: [
                      SizedBox(width: 28, child: Text('${i + 1}.')),
                      DurationField(
                        value: _times[i],
                        onChanged: (d) => setState(() => d == null ? _times.removeAt(i) : _times[i] = d),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l.removeFromList,
                        onPressed: () => setState(() => _times.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l.addCutPoint(formatDuration(_pos, millis: true))),
                    onPressed: _pos > Duration.zero ? () => setState(() => _times.add(_pos)) : null,
                  ),
                ),
              ),
            ],
            SettingTile(
              title: l.pSplitPrecise,
              hint: _precise ? l.splitPreciseOnHint : l.splitPreciseOffHint,
              help: l.pLosslessCutHelp,
              control: Switch(value: _precise, onChanged: (v) => setState(() => _precise = v)),
            ),
          ],
        ),
      ],
    );
  }
}
