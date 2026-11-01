import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/model.dart';
import '../engine/peaks.dart';

/// Mapping between pixels and project frames for the visible window.
class TimeView {
  const TimeView({required this.start, required this.spp, required this.sampleRate});

  /// First visible frame.
  final double start;

  /// Samples (frames) per pixel.
  final double spp;
  final int sampleRate;

  double xOf(num frame) => (frame - start) / spp;
  int frameAt(double x) => (start + x * spp).round();
}

/// One track lane: waveform (min/max per pixel), selection, cursor, playhead,
/// and the volume envelope when the envelope tool is active.
class WaveformPainter extends CustomPainter {
  WaveformPainter({
    required this.view,
    required this.track,
    required this.peaks,
    required this.color,
    required this.selectionColor,
    required this.lineColor,
    this.selection,
    this.cursor,
    this.playhead,
    this.showEnvelope = false,
    this.spectrogram,
    this.selected = false,
  });

  final TimeView view;
  final AudioTrack track;
  final Peaks? peaks;
  final Color color;
  final Color selectionColor;
  final Color lineColor;
  final SampleRange? selection;
  final int? cursor;
  final int? playhead;
  final bool showEnvelope;

  /// Pre-rendered spectrogram of the whole track (showspectrumpic).
  final ui.Image? spectrogram;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final clipStart = view.xOf(track.offset).clamp(-1.0, w + 1);
    final clipEnd = view.xOf(track.end).clamp(-1.0, w + 1);
    // Clip body.
    canvas.drawRect(
      Rect.fromLTRB(clipStart, 0, clipEnd, h),
      Paint()..color = color.withValues(alpha: selected ? 0.16 : 0.08),
    );
    final sel = selection;
    final img = spectrogram;
    if (img != null) {
      // The image spans the whole track horizontally.
      final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dst = Rect.fromLTRB(view.xOf(track.offset), 0, view.xOf(track.end), h);
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, w, h));
      canvas.drawImageRect(img, src, dst, Paint()..filterQuality = FilterQuality.medium);
      canvas.restore();
    } else if (peaks != null) {
      _drawWave(canvas, size);
    }
    // Selection on top of waveform/spectrogram (translucent).
    if (sel != null) {
      canvas.drawRect(
        Rect.fromLTRB(view.xOf(sel.start).clamp(0, w), 0, view.xOf(sel.end).clamp(0, w), h),
        Paint()..color = selectionColor,
      );
    }
    if (showEnvelope) _drawEnvelope(canvas, size);
    final c = cursor;
    if (c != null && sel == null) {
      final x = view.xOf(c);
      if (x >= 0 && x <= w) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, h),
          Paint()
            ..color = lineColor
            ..strokeWidth = 1,
        );
      }
    }
    final ph = playhead;
    if (ph != null) {
      final x = view.xOf(ph);
      if (x >= 0 && x <= w) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, h),
          Paint()
            ..color = Colors.green.shade600
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _drawWave(Canvas canvas, Size size) {
    final pk = peaks!;
    final ch = pk.channels;
    final laneH = size.height / ch;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final mid = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final x0 = math.max(0, view.xOf(track.offset).floor());
    final x1 = math.min(size.width, view.xOf(track.end).ceil().toDouble());
    for (var c = 0; c < ch; c++) {
      final top = c * laneH;
      final cy = top + laneH / 2;
      final amp = laneH / 2 * 0.95;
      canvas.drawLine(Offset(x0.toDouble(), cy), Offset(x1, cy), mid);
      final pts = Float32List(((x1 - x0).ceil() + 1).clamp(0, 100000) * 4);
      var n = 0;
      for (var x = x0; x < x1; x++) {
        final a = view.frameAt(x.toDouble()) - track.offset;
        final b = view.frameAt(x + 1.0) - track.offset;
        if (b <= 0 || a >= track.frames) continue;
        final (lo, hi) = pk.range(c, math.max(0, a), math.max(a + 1, b));
        final yTop = cy - hi.clamp(-1.0, 1.0) * amp;
        final yBot = cy - lo.clamp(-1.0, 1.0) * amp;
        pts[n++] = x + 0.5;
        pts[n++] = yTop;
        pts[n++] = x + 0.5;
        pts[n++] = math.max(yBot, yTop + 1);
      }
      canvas.drawRawPoints(ui.PointMode.lines, Float32List.sublistView(pts, 0, n), paint);
    }
  }

  void _drawEnvelope(Canvas canvas, Size size) {
    final pts = [...track.envelope]..sort((a, b) => a.time.compareTo(b.time));
    double yOf(double g) => size.height * (1 - (g / 2).clamp(0.0, 1.0));
    double xOfT(double t) => view.xOf(track.offset + t * view.sampleRate);
    final line = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (pts.isEmpty) {
      path
        ..moveTo(view.xOf(track.offset), yOf(1))
        ..lineTo(view.xOf(track.end), yOf(1));
    } else {
      path.moveTo(view.xOf(track.offset), yOf(pts.first.gain));
      for (final p in pts) {
        path.lineTo(xOfT(p.time), yOf(p.gain));
      }
      path.lineTo(view.xOf(track.end), yOf(pts.last.gain));
    }
    canvas.drawPath(path, line);
    for (final p in pts) {
      canvas.drawCircle(Offset(xOfT(p.time), yOf(p.gain)), 5, Paint()..color = Colors.deepOrange);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter o) =>
      o.view.start != view.start ||
      o.view.spp != view.spp ||
      o.track != track ||
      o.peaks != peaks ||
      o.selection != selection ||
      o.cursor != cursor ||
      o.playhead != playhead ||
      o.showEnvelope != showEnvelope ||
      o.spectrogram != spectrogram ||
      o.selected != selected ||
      o.color != color;
}

/// Time ruler with adaptive tick spacing.
class RulerPainter extends CustomPainter {
  RulerPainter({required this.view, required this.color, required this.textStyle, this.selection});
  final TimeView view;
  final Color color;
  final TextStyle textStyle;
  final SampleRange? selection;

  static const _steps = [0.001, 0.005, 0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10, 15, 30, 60, 120, 300, 600, 1800, 3600];

  @override
  void paint(Canvas canvas, Size size) {
    final sel = selection;
    if (sel != null) {
      canvas.drawRect(
        Rect.fromLTRB(view.xOf(sel.start), 0, view.xOf(sel.end), size.height),
        Paint()..color = color.withValues(alpha: 0.15),
      );
    }
    final secPerPx = view.spp / view.sampleRate;
    final step = _steps.firstWhere((s) => s / secPerPx >= 90, orElse: () => 7200).toDouble();
    final t0 = (view.start / view.sampleRate / step).floor() * step;
    final paint = Paint()..color = color;
    for (var t = t0; ; t += step) {
      final x = view.xOf(t * view.sampleRate);
      if (x > size.width) break;
      if (x < -100) continue;
      canvas.drawLine(Offset(x, size.height - 8), Offset(x, size.height), paint);
      final minor = step / 5;
      for (var k = 1; k < 5; k++) {
        final xm = view.xOf((t + minor * k) * view.sampleRate);
        canvas.drawLine(Offset(xm, size.height - 4), Offset(xm, size.height), paint);
      }
      final tp = TextPainter(
        text: TextSpan(text: formatTimecode(t, step), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 3, 2));
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter o) =>
      o.view.start != view.start || o.view.spp != view.spp || o.selection != selection;
}

/// `m:ss`, `m:ss.s`, `m:ss.mmm` depending on the tick step.
String formatTimecode(double seconds, [double step = 1]) {
  final neg = seconds < 0;
  final s = seconds.abs();
  final m = s ~/ 60;
  final rest = s - m * 60;
  final digits = step >= 1 ? 0 : (step >= 0.1 ? 1 : 3);
  final sec = rest.toStringAsFixed(digits).padLeft(digits == 0 ? 2 : 3 + digits, '0');
  final h = m ~/ 60;
  final mm = h > 0 ? '$h:${(m % 60).toString().padLeft(2, '0')}' : '$m';
  return '${neg ? '-' : ''}$mm:$sec';
}

/// Average spectrum plot (Plot Spectrum): log frequency axis, dB scale.
class SpectrumPainter extends CustomPainter {
  SpectrumPainter({
    required this.db,
    required this.sampleRate,
    required this.color,
    required this.gridColor,
    required this.textStyle,
  });
  final Float64List db;
  final int sampleRate;
  final Color color;
  final Color gridColor;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const fMin = 20.0;
    final fMax = sampleRate / 2;
    const dbMin = -100.0, dbMax = 0.0;
    double xOf(double f) => size.width * (math.log(f / fMin) / math.log(fMax / fMin));
    double yOf(double d) => size.height * (1 - ((d - dbMin) / (dbMax - dbMin)).clamp(0.0, 1.0));
    final grid = Paint()..color = gridColor;
    for (final f in [50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000]) {
      if (f > fMax) break;
      final x = xOf(f.toDouble());
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      (TextPainter(
        text: TextSpan(text: f >= 1000 ? '${f ~/ 1000}k' : '$f', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout()).paint(canvas, Offset(x + 2, size.height - 14));
    }
    for (var d = dbMin; d <= dbMax; d += 20) {
      final y = yOf(d);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      (TextPainter(
        text: TextSpan(text: '${d.round()} dB', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout()).paint(canvas, Offset(2, y + 1));
    }
    final n = db.length;
    final path = Path();
    var started = false;
    for (var i = 1; i < n; i++) {
      final f = i * sampleRate / ((n - 1) * 2);
      if (f < fMin) continue;
      final p = Offset(xOf(f), yOf(db[i]));
      if (!started) {
        path.moveTo(p.dx, p.dy);
        started = true;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant SpectrumPainter o) => o.db != db;
}
