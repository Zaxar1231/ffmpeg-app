import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/error_translator.dart';
import '../../core/engine/process_runner.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/setting_tile.dart';
import '../edit/graphs.dart';
import '../edit/ui/edit_widgets.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'analysis_ops.dart';

// ================================================================== runner

/// Runs one ffmpeg analysis inside a page: progress, cancel, every log line.
mixin _AnalysisRun<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  RunHandle? _handle;
  double? _fraction;
  String? _runError;
  bool get running => _handle != null;

  Future<List<String>?> runFfmpeg(List<String> args, {Duration? total, void Function(String line)? onLine}) async {
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null) return null;
    final lines = <String>[];
    final h = await ref
        .read(processRunnerProvider)
        .start(ToolInvocation(executable: ffmpeg, args: args, totalDuration: total));
    setState(() {
      _handle = h;
      _fraction = 0;
      _runError = null;
    });
    final ps = h.progress.listen((p) {
      if (mounted) setState(() => _fraction = p.fraction);
    });
    final ls = h.logLines.listen((l) {
      lines.add(l);
      onLine?.call(l);
    });
    final r = await h.done;
    await ps.cancel();
    await ls.cancel();
    if (!mounted) return null;
    setState(() => _handle = null);
    if (r.canceled) return null;
    if (!r.success) {
      final e = translateToolError(r.log, startError: r.startError);
      setState(
        () => _runError = e.kind == ToolErrorKind.unknown
            ? r.log.lastOrNull
            : toolErrorText(context.l10n, e.kind, e.detail),
      );
      return null;
    }
    return lines;
  }

  @override
  void dispose() {
    unawaited(_handle?.cancel());
    super.dispose();
  }

  Widget runBar({required String label, required VoidCallback? onRun, IconData icon = Icons.play_arrow}) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (running)
                OutlinedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: Text(l.cancel),
                  onPressed: () => _handle?.cancel(),
                )
              else
                FilledButton.icon(icon: Icon(icon), label: Text(label), onPressed: onRun),
              const SizedBox(width: 16),
              if (running) Expanded(child: LinearProgressIndicator(value: _fraction)),
              if (running && _fraction != null)
                Padding(padding: const EdgeInsets.only(left: 12), child: Text('${(_fraction! * 100).round()}%')),
            ],
          ),
          if (_runError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_runError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
    );
  }
}

/// Two-column layout: settings left, results right (stacked when narrow).
class _AnalysisLayout extends StatelessWidget {
  const _AnalysisLayout({required this.toolId, required this.info, required this.left, required this.right});
  final String toolId;
  final MediaInfo info;
  final List<Widget> left;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) => ToolFrame(
    toolId: toolId,
    subtitle: '${p.basename(info.path)} · ${formatDuration(info.duration)}',
    child: LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 980) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 12, 24), children: left),
              ),
              Expanded(
                flex: 6,
                child: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 24, 24), children: right),
              ),
            ],
          );
        }
        return ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: [...left, ...right]);
      },
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.note, this.color});
  final String label;
  final String value;
  final String? note;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SizedBox(
      width: 190,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
            Text(value, style: t.textTheme.headlineSmall?.copyWith(color: color)),
            if (note != null) Text(note!, style: t.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

String _fmtDb(double? v, String unit) => v == null ? '—' : '${v.toStringAsFixed(1)} $unit';

// ================================================================ loudness

class LoudnessPage extends ConsumerWidget {
  const LoudnessPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'loudness',
    path: path,
    builder: (i) => _LoudnessView(key: ValueKey(i.path), info: i),
  );
}

class _LoudnessView extends ConsumerStatefulWidget {
  const _LoudnessView({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_LoudnessView> createState() => _LoudnessViewState();
}

class _LoudnessViewState extends ConsumerState<_LoudnessView> with _AnalysisRun {
  int _stream = 0;
  LoudnessReport? _report;
  final _live = <LoudnessPoint>[];
  int _target = 0;

  Future<void> _run() async {
    _live.clear();
    setState(() => _report = null);
    final summary = <String>[];
    var inSummary = false;
    final lines = await runFfmpeg(
      loudnessArgs(widget.info.path, stream: _stream),
      total: widget.info.duration,
      onLine: (l) {
        final pt = parseLoudness([l]).points;
        if (pt.isNotEmpty) {
          _live.add(pt.first);
        } else if (l.contains('Summary:') || inSummary) {
          inSummary = true;
          summary.add(l);
        }
      },
    );
    if (lines == null || !mounted) return;
    final s = parseLoudness(summary);
    setState(() {
      _report = LoudnessReport(
        points: List.of(_live),
        integrated: s.integrated,
        range: s.range,
        truePeak: s.truePeak,
        lraLow: s.lraLow,
        lraHigh: s.lraHigh,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final t = Theme.of(context);
    final r = _report;
    final (name, target, tpLimit) = loudnessTargets[_target];
    return _AnalysisLayout(
      toolId: 'loudness',
      info: info,
      left: [
        ParamGroup(
          title: l.groupMeasure,
          children: [
            if (info.audioStreams.length > 1)
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
                        child: Text(
                          '#${i + 1} ${info.audioStreams.elementAt(i).tags['language'] ?? ''} ${info.audioStreams.elementAt(i).codecName ?? ''}',
                        ),
                      ),
                  ],
                ),
              ),
            SettingTile(
              title: l.pLoudnessTarget,
              hint: l.pLoudnessTargetHint,
              control: DropdownButton<int>(
                value: _target,
                onChanged: (v) => setState(() => _target = v!),
                items: [
                  for (var i = 0; i < loudnessTargets.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('${loudnessTargets[i].$1} (${fnum(loudnessTargets[i].$2)} LUFS)'),
                    ),
                ],
              ),
            ),
            if (info.audioStreams.isEmpty)
              Padding(padding: const EdgeInsets.all(16), child: Text(l.issueNoAudio))
            else
              runBar(label: l.measure, onRun: _run, icon: Icons.graphic_eq),
          ],
        ),
        ParamGroup(
          title: l.groupWhatIsLufs,
          children: [Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.lufsExplained))],
        ),
      ],
      right: [
        if (r != null || _live.isNotEmpty)
          ParamGroup(
            title: l.groupResults,
            children: [
              if (r != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    children: [
                      _Stat(l.statIntegrated, _fmtDb(r.integrated, 'LUFS'), note: l.statIntegratedNote),
                      _Stat(
                        l.statTruePeak,
                        _fmtDb(r.truePeak, 'dBTP'),
                        note: l.statTruePeakNote,
                        color: (r.truePeak ?? -99) > tpLimit ? t.colorScheme.error : null,
                      ),
                      _Stat(l.statLra, _fmtDb(r.range, 'LU'), note: l.statLraNote),
                      _Stat(l.statMaxMomentary, _fmtDb(r.maxMomentary, 'LUFS')),
                      _Stat(l.statMaxShort, _fmtDb(r.maxShortTerm, 'LUFS')),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SizedBox(
                  height: 220,
                  child: CustomPaint(
                    painter: _LoudnessChart(
                      points: r?.points ?? _live,
                      total: (info.duration?.inMilliseconds ?? 0) / 1000,
                      integrated: r?.integrated,
                      target: target,
                      grid: t.colorScheme.outlineVariant,
                      text: t.textTheme.labelSmall!.copyWith(color: t.colorScheme.onSurfaceVariant),
                      momentary: t.colorScheme.primary.withValues(alpha: 0.45),
                      shortTerm: t.colorScheme.primary,
                      targetColor: t.colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l.loudnessLegend, style: t.textTheme.bodySmall),
              ),
              if (r?.integrated != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    _verdict(l, name, r!.integrated!, target, r.truePeak, tpLimit),
                    style: t.textTheme.bodyLarge,
                  ),
                ),
              if (r?.integrated != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.equalizer),
                      label: Text(l.openNormalize),
                      onPressed: () => ref.read(openToolProvider.notifier).open(OpenTool('normalize', path: info.path)),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  String _verdict(AppLocalizations l, String name, double i, double target, double? tp, double tpLimit) {
    final d = i - target;
    final parts = <String>[
      if (d.abs() <= 1)
        l.loudnessOnTarget(name)
      else if (d > 0)
        l.loudnessTooLoud(name, d.toStringAsFixed(1))
      else
        l.loudnessTooQuiet(name, (-d).toStringAsFixed(1)),
      if (tp != null && tp > tpLimit) l.truePeakOver(tp.toStringAsFixed(1), fnum(tpLimit)),
    ];
    return parts.join(' ');
  }
}

class _LoudnessChart extends CustomPainter {
  _LoudnessChart({
    required this.points,
    required this.total,
    required this.integrated,
    required this.target,
    required this.grid,
    required this.text,
    required this.momentary,
    required this.shortTerm,
    required this.targetColor,
  });
  final List<LoudnessPoint> points;
  final double total;
  final double? integrated;
  final double target;
  final Color grid, momentary, shortTerm, targetColor;
  final TextStyle text;

  @override
  void paint(Canvas canvas, Size size) {
    const lo = -60.0, hi = 0.0;
    const left = 44.0;
    final w = size.width - left;
    final tMax = math.max(total, points.isEmpty ? 1 : points.last.t);
    double x(double t) => left + w * (t / tMax).clamp(0.0, 1.0);
    double y(double v) => size.height * (1 - ((v - lo) / (hi - lo)).clamp(0.0, 1.0));
    final gp = Paint()..color = grid;
    for (var v = lo; v <= hi; v += 10) {
      canvas.drawLine(Offset(left, y(v)), Offset(size.width, y(v)), gp);
      (TextPainter(
        text: TextSpan(text: '${v.round()}', style: text),
        textDirection: TextDirection.ltr,
      )..layout()).paint(canvas, Offset(0, y(v) - 7));
    }
    void line(double Function(LoudnessPoint) f, Color c, double width) {
      if (points.length < 2) return;
      final path = Path();
      var started = false;
      // At most ~2 points per pixel.
      final step = math.max(1, points.length ~/ (w * 2).round());
      for (var i = 0; i < points.length; i += step) {
        final pt = points[i];
        final o = Offset(x(pt.t), y(f(pt)));
        if (!started) {
          path.moveTo(o.dx, o.dy);
          started = true;
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }

    line((p) => p.momentary, momentary, 1);
    line((p) => p.shortTerm, shortTerm, 2);
    final tp = Paint()
      ..color = targetColor
      ..strokeWidth = 1.5;
    for (var xx = left; xx < size.width; xx += 10) {
      canvas.drawLine(Offset(xx, y(target)), Offset(xx + 5, y(target)), tp);
    }
    if (integrated != null) {
      canvas.drawLine(
        Offset(left, y(integrated!)),
        Offset(size.width, y(integrated!)),
        Paint()
          ..color = shortTerm.withValues(alpha: 0.6)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoudnessChart o) => true;
}

// ============================================================ waveform pic

class WaveformPicPage extends ConsumerWidget {
  const WaveformPicPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'waveform',
    path: path,
    builder: (i) => _WaveformView(key: ValueKey(i.path), info: i),
  );
}

class _WaveformView extends ConsumerStatefulWidget {
  const _WaveformView({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_WaveformView> createState() => _WaveformViewState();
}

class _WaveformViewState extends ConsumerState<_WaveformView> {
  PicParams _p = const PicParams();
  Uint8List? _png;
  bool _busy = false;
  String? _error;
  Timer? _debounce;
  Directory? _tmp;
  int _seq = 0;

  static const _sizes = [(1280, 240), (1920, 480), (3840, 720), (1920, 1080)];
  static const _colors = [
    ('0x4FC3F7', 'colorBlue'),
    ('0xFFFFFF', 'colorWhite'),
    ('0x000000', 'colorBlack'),
    ('0xFFB300', 'colorYellow'),
    ('0xEF5350', 'colorRed'),
  ];

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final t = _tmp;
    if (t != null) unawaited(t.delete(recursive: true).catchError((_) => t));
    super.dispose();
  }

  void _set(PicParams p) {
    setState(() => _p = p);
    _schedule();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _render);
  }

  Future<void> _render() async {
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null || widget.info.audioStreams.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    _tmp ??= await Directory.systemTemp.createTemp('kadra_pic');
    final out = p.join(_tmp!.path, 'pic${_seq++}.png');
    final r = await ref
        .read(processRunnerProvider)
        .capture(ffmpeg, picArgs(widget.info.path, out, _p), timeout: const Duration(minutes: 10));
    if (!mounted) return;
    final f = File(out);
    if (r.ok && f.existsSync()) {
      final bytes = await f.readAsBytes();
      setState(() {
        _png = bytes;
        _busy = false;
      });
    } else {
      setState(() {
        _busy = false;
        _error = r.stderr.trim().split('\n').lastOrNull;
      });
    }
  }

  Future<void> _save() async {
    final png = _png;
    if (png == null) return;
    final l = context.l10n;
    final suggested = '${p.basenameWithoutExtension(widget.info.path)}_${_p.kind.name}.png';
    final loc = await getSaveLocation(
      initialDirectory: outputDirFor(ref, widget.info.path),
      suggestedName: suggested,
      confirmButtonText: l.save,
    );
    if (loc == null) return;
    final path = p.extension(loc.path).isEmpty ? '${loc.path}.png' : loc.path;
    await File(path).writeAsBytes(png);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.savedTo(path))));
  }

  PicParams _copy({
    PicKind? kind,
    (int, int)? size,
    bool? split,
    String? color,
    WaveScale? scale,
    SpectrumColor? spectrumColor,
    bool? logFreq,
    bool? legend,
  }) => PicParams(
    kind: kind ?? _p.kind,
    width: size?.$1 ?? _p.width,
    height: size?.$2 ?? _p.height,
    splitChannels: split ?? _p.splitChannels,
    color: color ?? _p.color,
    waveScale: scale ?? _p.waveScale,
    spectrumColor: spectrumColor ?? _p.spectrumColor,
    logFrequency: logFreq ?? _p.logFrequency,
    legend: legend ?? _p.legend,
  );

  String _colorName(AppLocalizations l, String key) => switch (key) {
    'colorBlue' => l.colorBlue,
    'colorWhite' => l.colorWhite,
    'colorBlack' => l.colorBlack,
    'colorYellow' => l.colorYellow,
    _ => l.colorRed,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final wave = _p.kind == PicKind.waveform;
    return _AnalysisLayout(
      toolId: 'waveform',
      info: info,
      left: [
        ParamGroup(
          title: l.groupPicture,
          children: [
            SettingTile(
              title: l.pPicKind,
              hint: wave ? l.picWaveHint : l.picSpectrumHint,
              controlBelow: true,
              control: SegmentedButton<PicKind>(
                segments: [
                  ButtonSegment(value: PicKind.waveform, icon: const Icon(Icons.waves), label: Text(l.picWave)),
                  ButtonSegment(
                    value: PicKind.spectrogram,
                    icon: const Icon(Icons.gradient),
                    label: Text(l.picSpectrum),
                  ),
                ],
                selected: {_p.kind},
                onSelectionChanged: (v) => _set(_copy(kind: v.first)),
              ),
            ),
            SettingTile(
              title: l.pPicSize,
              hint: l.pPicSizeHint,
              control: DropdownButton<(int, int)>(
                value: (_p.width, _p.height),
                onChanged: (v) => _set(_copy(size: v)),
                items: [for (final s in _sizes) DropdownMenuItem(value: s, child: Text('${s.$1}×${s.$2}'))],
              ),
            ),
            SettingTile(
              title: l.pSplitChannels,
              hint: l.pSplitChannelsHint,
              control: Switch(
                value: _p.splitChannels,
                onChanged: (v) => _set(_copy(split: v)),
              ),
            ),
            if (wave) ...[
              SettingTile(
                title: l.pFontColor,
                hint: l.pWaveColorHint,
                control: DropdownButton<String>(
                  value: _p.color,
                  onChanged: (v) => _set(_copy(color: v)),
                  items: [for (final (c, n) in _colors) DropdownMenuItem(value: c, child: Text(_colorName(l, n)))],
                ),
              ),
              SettingTile(
                title: l.pWaveScale,
                hint: l.pWaveScaleHint,
                control: DropdownButton<WaveScale>(
                  value: _p.waveScale,
                  onChanged: (v) => _set(_copy(scale: v)),
                  items: [
                    DropdownMenuItem(value: WaveScale.lin, child: Text(l.scaleLinear)),
                    DropdownMenuItem(value: WaveScale.log, child: Text(l.scaleLog)),
                    DropdownMenuItem(value: WaveScale.sqrt, child: Text(l.scaleSqrt)),
                    DropdownMenuItem(value: WaveScale.cbrt, child: Text(l.scaleCbrt)),
                  ],
                ),
              ),
            ] else ...[
              SettingTile(
                title: l.pSpectrumColors,
                hint: l.pSpectrumColorsHint,
                control: DropdownButton<SpectrumColor>(
                  value: _p.spectrumColor,
                  onChanged: (v) => _set(_copy(spectrumColor: v)),
                  items: [for (final c in SpectrumColor.values) DropdownMenuItem(value: c, child: Text(c.name))],
                ),
              ),
              SettingTile(
                title: l.pLogFrequency,
                hint: l.pLogFrequencyHint,
                control: Switch(
                  value: _p.logFrequency,
                  onChanged: (v) => _set(_copy(logFreq: v)),
                ),
              ),
              SettingTile(
                title: l.pLegend,
                hint: l.pLegendHint,
                control: Switch(
                  value: _p.legend,
                  onChanged: (v) => _set(_copy(legend: v)),
                ),
              ),
            ],
          ],
        ),
      ],
      right: [
        if (info.audioStreams.isEmpty)
          Text(l.issueNoAudio)
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: _p.width / _p.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_png != null) Image.memory(_png!, gaplessPlayback: true, fit: BoxFit.contain),
                    if (_busy) const Center(child: CircularProgressIndicator()),
                    if (_error != null)
                      Center(
                        child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              icon: const Icon(Icons.save_alt),
              label: Text(l.savePng),
              onPressed: _png == null || _busy ? null : _save,
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================== detectors

class DetectPage extends ConsumerWidget {
  const DetectPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'detect',
    path: path,
    builder: (i) => _DetectView(key: ValueKey(i.path), info: i),
  );
}

class _DetectView extends ConsumerStatefulWidget {
  const _DetectView({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_DetectView> createState() => _DetectViewState();
}

class _DetectViewState extends ConsumerState<_DetectView> with _AnalysisRun {
  late DetectKind _kind = widget.info.videoStreams.isEmpty ? DetectKind.silence : DetectKind.scenes;
  double _silenceDb = -35, _min = 0.5, _black = 0.1, _freezeDb = -60, _scene = 10;
  List<Finding>? _found;
  CropRect? _crop;
  DetectKind? _foundKind;

  DetectParams get _params => DetectParams(
    kind: _kind,
    silenceDb: _silenceDb,
    minDuration: _min,
    blackThreshold: _black,
    freezeDb: _freezeDb,
    sceneThreshold: _scene,
  );

  Future<void> _run() async {
    final info = widget.info;
    setState(() {
      _found = null;
      _crop = null;
    });
    final kind = _kind;
    // cropdetect logs every frame: only the last value is kept.
    String? lastCrop;
    final lines = await runFfmpeg(
      detectArgs(info.path, _params),
      total: info.duration,
      onLine: kind == DetectKind.crop ? (l) => l.contains('crop=') ? lastCrop = l : null : null,
    );
    if (lines == null || !mounted) return;
    setState(() {
      _foundKind = kind;
      if (kind == DetectKind.crop) {
        _crop = lastCrop == null ? null : parseCropdetect([lastCrop!]);
        _found = const [];
      } else {
        _found = parseFindings(kind, lines, total: info.duration);
      }
    });
  }

  bool _needs(DetectKind k) =>
      k == DetectKind.silence ? widget.info.audioStreams.isNotEmpty : widget.info.videoStreams.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final t = Theme.of(context);
    final found = _found;
    final kind = _foundKind;
    return _AnalysisLayout(
      toolId: 'detect',
      info: info,
      left: [
        ParamGroup(
          title: l.groupDetect,
          children: [
            SettingTile(
              title: l.pDetectKind,
              hint: switch (_kind) {
                DetectKind.silence => l.detectSilenceHint,
                DetectKind.black => l.detectBlackHint,
                DetectKind.freeze => l.detectFreezeHint,
                DetectKind.scenes => l.detectScenesHint,
                DetectKind.crop => l.detectCropHint,
              },
              controlBelow: true,
              control: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in DetectKind.values)
                    ChoiceChip(
                      label: Text(switch (k) {
                        DetectKind.silence => l.detectSilence,
                        DetectKind.black => l.detectBlack,
                        DetectKind.freeze => l.detectFreeze,
                        DetectKind.scenes => l.detectScenes,
                        DetectKind.crop => l.detectCrop,
                      }),
                      selected: _kind == k,
                      onSelected: _needs(k) && !running ? (_) => setState(() => _kind = k) : null,
                    ),
                ],
              ),
            ),
            if (_kind == DetectKind.silence)
              ValueSlider(
                title: l.pSilenceLevel,
                hint: l.pSilenceLevelHint,
                value: _silenceDb,
                min: -80,
                max: -10,
                divisions: 70,
                defaultValue: -35,
                format: (v) => '${v.round()} dB',
                onChanged: (v) => setState(() => _silenceDb = v),
              ),
            if (_kind == DetectKind.black)
              ValueSlider(
                title: l.pBlackLevel,
                hint: l.pBlackLevelHint,
                value: _black,
                min: 0.02,
                max: 0.4,
                divisions: 38,
                defaultValue: 0.1,
                onChanged: (v) => setState(() => _black = v),
              ),
            if (_kind == DetectKind.freeze)
              ValueSlider(
                title: l.pFreezeNoise,
                hint: l.pFreezeNoiseHint,
                value: _freezeDb,
                min: -90,
                max: -30,
                divisions: 60,
                defaultValue: -60,
                format: (v) => '${v.round()} dB',
                onChanged: (v) => setState(() => _freezeDb = v),
              ),
            if (_kind == DetectKind.scenes)
              ValueSlider(
                title: l.pSceneThreshold,
                hint: l.pSceneThresholdHint,
                value: _scene,
                min: 2,
                max: 50,
                divisions: 48,
                defaultValue: 10,
                format: (v) => v.round().toString(),
                onChanged: (v) => setState(() => _scene = v),
              ),
            if (_kind == DetectKind.silence || _kind == DetectKind.black || _kind == DetectKind.freeze)
              ValueSlider(
                title: l.pMinDuration,
                hint: l.pMinDurationHint,
                value: _min,
                min: 0.1,
                max: 10,
                divisions: 99,
                defaultValue: 0.5,
                format: (v) => '${fnum(v, 1)} ${l.unitSecond}',
                onChanged: (v) => setState(() => _min = v),
              ),
            runBar(label: l.detectRun, onRun: _needs(_kind) ? _run : null, icon: Icons.manage_search),
          ],
        ),
      ],
      right: [
        if (found != null && kind == DetectKind.crop)
          ParamGroup(
            title: l.groupResults,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _crop == null
                      ? l.cropNothingFound
                      : l.cropFound('${_crop!.w}×${_crop!.h}', '${_crop!.x}', '${_crop!.y}'),
                  style: t.textTheme.titleMedium,
                ),
              ),
              if (_crop != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.crop),
                      label: Text(l.openCropTool),
                      onPressed: () => ref
                          .read(openToolProvider.notifier)
                          .open(OpenTool('cropScale', path: info.path, extra: _crop)),
                    ),
                  ),
                ),
            ],
          ),
        if (found != null && kind != DetectKind.crop)
          ParamGroup(
            title: l.foundCount(found.length),
            trailing: found.isEmpty
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l.copy,
                        icon: const Icon(Icons.copy),
                        onPressed: () => Clipboard.setData(ClipboardData(text: findingsCsv(found))),
                      ),
                      IconButton(
                        tooltip: l.saveCsv,
                        icon: const Icon(Icons.save_alt),
                        onPressed: () async {
                          final loc = await getSaveLocation(
                            initialDirectory: outputDirFor(ref, info.path),
                            suggestedName: '${p.basenameWithoutExtension(info.path)}_${kind!.name}.csv',
                          );
                          if (loc != null) await File(loc.path).writeAsString(findingsCsv(found));
                        },
                      ),
                    ],
                  ),
            children: [
              if (found.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (kind != DetectKind.scenes)
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.content_cut),
                          label: Text(l.cutFound),
                          onPressed: () => ref
                              .read(openToolProvider.notifier)
                              .open(
                                OpenTool(
                                  'cutJoin',
                                  path: info.path,
                                  extra: CutRanges([for (final f in found) (f.start, f.end ?? f.start)]),
                                ),
                              ),
                        ),
                      if (kind == DetectKind.scenes || kind == DetectKind.black || kind == DetectKind.silence)
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.call_split),
                          label: Text(l.splitAtFound),
                          onPressed: () => ref
                              .read(openToolProvider.notifier)
                              .open(
                                OpenTool(
                                  'split',
                                  path: info.path,
                                  extra: SplitTimes([
                                    for (final f in found)
                                      // Cut in the middle of a pause / black gap.
                                      f.end == null ? f.start : f.start + (f.end! - f.start) ~/ 2,
                                  ]),
                                ),
                              ),
                        ),
                    ],
                  ),
                ),
              if (found.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text(l.nothingFound)),
              for (var i = 0; i < math.min(found.length, 500); i++)
                ListTile(
                  dense: true,
                  leading: Text('${i + 1}'),
                  title: Text(
                    found[i].end == null
                        ? formatDuration(found[i].start, millis: true)
                        : '${formatDuration(found[i].start, millis: true)} — ${formatDuration(found[i].end, millis: true)}',
                  ),
                  trailing: Text(
                    found[i].length != null
                        ? formatDuration(found[i].length, millis: true)
                        : (found[i].score == null ? '' : l.sceneScore(fnum(found[i].score!, 1))),
                  ),
                ),
              if (found.length > 500)
                Padding(padding: const EdgeInsets.all(16), child: Text(l.moreFound(found.length - 500))),
            ],
          ),
      ],
    );
  }
}

// ================================================================ quality

class CompareQualityPage extends ConsumerWidget {
  const CompareQualityPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'compareQuality',
    path: path,
    builder: (i) => _QualityView(key: ValueKey(i.path), reference: i),
  );
}

class _QualityView extends ConsumerStatefulWidget {
  const _QualityView({super.key, required this.reference});
  final MediaInfo reference;
  @override
  ConsumerState<_QualityView> createState() => _QualityViewState();
}

class _QualityViewState extends ConsumerState<_QualityView> with _AnalysisRun {
  MediaInfo? _distorted;
  QualityReport? _report;

  Future<void> _pick() async {
    final f = await openFile();
    final probe = ref.read(probeServiceProvider);
    if (f == null || probe == null) return;
    try {
      final info = await probe.probe(f.path);
      setState(() {
        _distorted = info;
        _report = null;
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.probeFailed)));
    }
  }

  Future<void> _run(bool vmaf) async {
    final d = _distorted;
    if (d == null) return;
    setState(() => _report = null);
    final ref0 = widget.reference;
    final threads = math.max(1, Platform.numberOfProcessors - 1);
    final total = [
      ref0.duration,
      d.duration,
    ].whereType<Duration>().fold<Duration?>(null, (a, b) => a == null || b < a ? b : a);
    final lines = await runFfmpeg(
      qualityArgs(reference: ref0, distorted: d, vmaf: vmaf, threads: threads),
      total: total,
    );
    if (lines == null || !mounted) return;
    setState(() => _report = parseQuality(lines));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final caps = ref.watch(capabilitiesProvider).value;
    final vmaf = caps?.hasFilter('libvmaf') ?? false;
    final d = _distorted;
    final r = _report;
    final t = Theme.of(context);
    final sizeDiff = d != null && (displaySize(d) != displaySize(widget.reference));
    return _AnalysisLayout(
      toolId: 'compareQuality',
      info: widget.reference,
      left: [
        ParamGroup(
          title: l.groupCompare,
          children: [
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(l.referenceFile),
              subtitle: Text(p.basename(widget.reference.path)),
            ),
            ListTile(
              leading: const Icon(Icons.compare),
              title: Text(l.distortedFile),
              subtitle: Text(d == null ? l.distortedFileHint : p.basename(d.path)),
              trailing: OutlinedButton(onPressed: running ? null : _pick, child: Text(l.choose)),
            ),
            if (sizeDiff)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l.qualityScaledNote, style: t.textTheme.bodySmall),
              ),
            if (!vmaf)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l.vmafMissing, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.tertiary)),
              ),
            runBar(label: l.compareRun, onRun: d == null ? null : () => _run(vmaf), icon: Icons.compare),
          ],
        ),
        ParamGroup(
          title: l.groupWhatMetrics,
          children: [Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.metricsExplained))],
        ),
      ],
      right: [
        if (r != null)
          ParamGroup(
            title: l.groupResults,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  children: [
                    if (r.vmaf != null) _Stat('VMAF', r.vmaf!.toStringAsFixed(1), note: _vmafWord(l, r.vmaf!)),
                    _Stat(
                      'PSNR',
                      r.psnr == null ? '—' : '${r.psnr!.toStringAsFixed(2)} dB',
                      note: r.psnrMin == null ? null : l.psnrMin(r.psnrMin!.toStringAsFixed(1)),
                    ),
                    _Stat(
                      'SSIM',
                      r.ssim == null ? '—' : r.ssim!.toStringAsFixed(4),
                      note: r.ssimDb == null ? null : '${r.ssimDb!.toStringAsFixed(1)} dB',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  r.vmaf != null ? _vmafVerdict(l, r.vmaf!) : _psnrVerdict(l, r.psnr),
                  style: t.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _vmafWord(AppLocalizations l, double v) => v >= 93
      ? l.qualityExcellent
      : v >= 80
      ? l.qualityGood
      : v >= 60
      ? l.qualityFair
      : l.qualityPoor;

  String _vmafVerdict(AppLocalizations l, double v) => v >= 93
      ? l.vmafVerdictExcellent
      : v >= 80
      ? l.vmafVerdictGood
      : v >= 60
      ? l.vmafVerdictFair
      : l.vmafVerdictPoor;

  String _psnrVerdict(AppLocalizations l, double? v) => v == null
      ? ''
      : v >= 40
      ? l.vmafVerdictExcellent
      : v >= 35
      ? l.vmafVerdictGood
      : v >= 30
      ? l.vmafVerdictFair
      : l.vmafVerdictPoor;
}
