import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/containers.dart';
import '../../core/engine/progress.dart' show parseFfmpegTime;
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/media_preview.dart';
import '../../ui/widgets/setting_tile.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'trim.dart';

class TrimPage extends ConsumerWidget {
  const TrimPage({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'trim',
    path: path,
    builder: (info) => _TrimForm(key: ValueKey(info.path), info: info),
  );
}

class _TrimForm extends ConsumerStatefulWidget {
  const _TrimForm({super.key, required this.info});
  final MediaInfo info;

  @override
  ConsumerState<_TrimForm> createState() => _TrimFormState();
}

class _TrimFormState extends ConsumerState<_TrimForm> {
  late Duration _start = Duration.zero;
  late Duration _end = widget.info.duration ?? Duration.zero;
  TrimMode _mode = TrimMode.fast;
  String? _output;
  Player? _player;
  Duration _pos = Duration.zero;
  StreamSubscription<Duration>? _posSub;

  /// Fast mode: where the cut really starts (previous keyframe).
  Duration? _keyframeStart;
  Timer? _kfDebounce;

  Duration get _total => widget.info.duration ?? Duration.zero;

  /// Keep the source container so stream copy always fits.
  String get _ext {
    final e = p.extension(widget.info.path).replaceFirst('.', '').toLowerCase();
    return containers.containsKey(e) ? e : 'mkv';
  }

  @override
  void initState() {
    super.initState();
    _updateKeyframe();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _kfDebounce?.cancel();
    super.dispose();
  }

  void _onPlayer(Player pl) {
    _player = pl;
    _posSub = pl.stream.position.listen((d) {
      if (mounted) setState(() => _pos = d);
    });
  }

  void _setRange(Duration s, Duration e) {
    setState(() {
      _start = s < Duration.zero ? Duration.zero : s;
      _end = e > _total ? _total : e;
      if (_end <= _start) _end = _start + const Duration(milliseconds: 100);
    });
    _updateKeyframe();
  }

  /// ffprobe the keyframes just before the start (only keyframes are decoded).
  void _updateKeyframe() {
    _kfDebounce?.cancel();
    if (_mode != TrimMode.fast || widget.info.videoStreams.isEmpty) {
      setState(() => _keyframeStart = null);
      return;
    }
    _kfDebounce = Timer(const Duration(milliseconds: 350), () async {
      final ffprobe = ref.read(toolchainProvider).ffprobe.path;
      if (ffprobe == null) return;
      final s = _start.inMilliseconds / 1000;
      final from = (s - 15).clamp(0, double.infinity);
      final r = await ref.read(processRunnerProvider).capture(ffprobe, [
        '-v', 'error', '-select_streams', 'v:0', '-skip_frame', 'nokey', //
        '-show_entries', 'frame=pts_time', '-of', 'csv=p=0',
        '-read_intervals', '${from.toStringAsFixed(3)}%${(s + 0.05).toStringAsFixed(3)}',
        widget.info.path,
      ]);
      final times = r.stdout
          .split('\n')
          .map((l) => double.tryParse(l.trim().split(',').first))
          .whereType<double>()
          .where((t) => t <= s + 0.001)
          .toList();
      if (!mounted || times.isEmpty) return;
      final kf = times.reduce((a, b) => a > b ? a : b);
      final start = widget.info.format.startTime ?? Duration.zero;
      setState(() => _keyframeStart = Duration(microseconds: (kf * 1e6).round()) - start);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final env = ref.watch(encodeEnvProvider);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: _ext, suffix: '_cut'), _ext);
    final t = TrimParams(start: _start, end: _end, mode: _mode);
    final steps = _total == Duration.zero ? null : planTrim(info: info, output: out, t: t, ext: _ext, env: env);
    final totalMs = _total.inMilliseconds.toDouble();
    final kfShift = _keyframeStart != null && (_start - _keyframeStart!).inMilliseconds > 40;
    final size = info.format.size;
    final estimate = _mode == TrimMode.fast && size != null && _total > Duration.zero
        ? l.estimateSize(
            formatBytes((size * t.length.inMicroseconds / _total.inMicroseconds).round(), units: byteUnits(l)),
          )
        : null;

    final preview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MediaPreview(path: info.path, aspectRatio: info.videoStreams.isEmpty ? 16 / 5 : 16 / 9, onPlayer: _onPlayer),
        const SizedBox(height: 12),
        if (totalMs > 0)
          RangeSlider(
            values: RangeValues(_start.inMilliseconds.toDouble(), _end.inMilliseconds.toDouble().clamp(0, totalMs)),
            min: 0,
            max: totalMs,
            labels: RangeLabels(formatDuration(_start, millis: true), formatDuration(_end, millis: true)),
            onChanged: (v) {
              final s = Duration(milliseconds: v.start.round());
              final e = Duration(milliseconds: v.end.round());
              if (s != _start) _player?.seek(s);
              if (e != _end) _player?.seek(e);
              _setRange(s, e);
            },
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.first_page),
              label: Text(l.setStartHere(formatDuration(_pos, millis: true))),
              onPressed: () => _setRange(_pos, _end),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.last_page),
              label: Text(l.setEndHere(formatDuration(_pos, millis: true))),
              onPressed: () => _setRange(_start, _pos),
            ),
          ],
        ),
      ],
    );

    return ToolScaffold(
      toolId: 'trim',
      info: info,
      preview: preview,
      outputPath: out,
      outputExt: _ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (_total == Duration.zero) l.issueDurationUnknown],
      estimate: [l.trimLength(formatDuration(t.length, millis: true)), ?estimate].join('  ·  '),
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'trim',
          title: '${l.toolTrim}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: t.length,
        ),
        now: now,
      ),
      params: [
        ParamGroup(
          title: l.groupTrim,
          children: [
            SettingTile(
              title: l.pTrimMode,
              hint: _mode == TrimMode.fast ? l.trimFastHint : l.trimPreciseHint,
              help: l.pTrimModeHelp,
              controlBelow: true,
              control: SegmentedButton<TrimMode>(
                segments: [
                  ButtonSegment(value: TrimMode.fast, icon: const Icon(Icons.bolt), label: Text(l.trimFast)),
                  ButtonSegment(
                    value: TrimMode.precise,
                    icon: const Icon(Icons.precision_manufacturing_outlined),
                    label: Text(l.trimPrecise),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (v) {
                  setState(() => _mode = v.first);
                  _updateKeyframe();
                },
              ),
            ),
            if (_mode == TrimMode.fast)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TagChip(l.losslessTag, icon: Icons.bolt, color: Theme.of(context).colorScheme.tertiaryContainer),
              ),
            SettingTile(
              title: l.pStart,
              hint: kfShift ? l.keyframeStartHint(formatDuration(_keyframeStart, millis: true)) : l.pStartHint,
              control: _TimeField(value: _start, onChanged: (d) => _setRange(d, _end)),
            ),
            SettingTile(
              title: l.pEnd,
              hint: l.pEndHint(formatDuration(_total, millis: true)),
              control: _TimeField(value: _end, onChanged: (d) => _setRange(_start, d)),
            ),
          ],
        ),
      ],
    );
  }
}

/// `H:MM:SS.mmm` editor.
class _TimeField extends StatefulWidget {
  const _TimeField({required this.value, required this.onChanged});
  final Duration value;
  final ValueChanged<Duration> onChanged;

  @override
  State<_TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<_TimeField> {
  late final TextEditingController _c = TextEditingController(text: formatDuration(widget.value, millis: true));
  final _focus = FocusNode();

  @override
  void didUpdateWidget(covariant _TimeField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus) _c.text = formatDuration(widget.value, millis: true);
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final d = parseFfmpegTime(_c.text);
    if (d != null) widget.onChanged(d);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 140,
    child: TextField(
      controller: _c,
      focusNode: _focus,
      decoration: const InputDecoration(isDense: true),
      onSubmitted: (_) => _commit(),
      onTapOutside: (_) {
        _commit();
        _focus.unfocus();
      },
    ),
  );
}
