import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/features/audio_editor/engine/dsp.dart';
import 'package:kadra/features/audio_editor/engine/native_dsp.dart';
import 'package:kadra/features/audio_editor/engine/peaks.dart';
import 'package:kadra/features/audio_editor/engine/wav.dart';
import 'package:path/path.dart' as p;

/// The Rust DSP (native/kadra_dsp) must give the same results as the Dart
/// code it replaces. Build it with `cargo build --release` in native/kadra_dsp.
void main() {
  final lib = NativeDsp.candidates().where((c) => File(c).existsSync()).firstOrNull;
  final skip = lib == null ? 'kadra_dsp is not built (cargo build --release in native/kadra_dsp)' : null;
  late Directory dir;
  late String f32, i16;
  const sr = 48000;

  T timed<T>(String name, bool native, T Function() f) {
    useNativeDsp = native;
    final sw = Stopwatch()..start();
    final r = f();
    // ignore: avoid_print
    print('$name ${native ? 'rust' : 'dart'}: ${sw.elapsedMilliseconds} ms');
    useNativeDsp = true;
    return r;
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_native');
    final rnd = math.Random(1);
    const n = sr * 60;
    final l = Float32List(n), r = Float32List(n);
    for (var i = 0; i < n; i++) {
      final t = i / sr;
      final env = (i ~/ (sr ~/ 2)).isEven ? 1.0 : 0.02; // sound/quiet every 0.5 s
      l[i] = (env * (0.6 * math.sin(2 * math.pi * 440 * t) + 0.2 * (rnd.nextDouble() - 0.5))).toDouble();
      r[i] = (env * 0.5 * math.sin(2 * math.pi * 1000 * t)).toDouble();
    }
    for (var i = sr * 10; i < sr * 10 + 50; i++) {
      l[i] = 1.0; // clipping
    }
    f32 = p.join(dir.path, 'f32.wav');
    await writeWavFloat(f32, [l, r], sr);
    // 16-bit integer PCM, mono.
    i16 = p.join(dir.path, 'i16.wav');
    final bd = ByteData(44 + n * 2)
      ..setUint32(0, 0x46464952, Endian.little)
      ..setUint32(4, 36 + n * 2, Endian.little)
      ..setUint32(8, 0x45564157, Endian.little)
      ..setUint32(12, 0x20746d66, Endian.little)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, 1, Endian.little)
      ..setUint32(24, sr, Endian.little)
      ..setUint32(28, sr * 2, Endian.little)
      ..setUint16(32, 2, Endian.little)
      ..setUint16(34, 16, Endian.little)
      ..setUint32(36, 0x61746164, Endian.little)
      ..setUint32(40, n * 2, Endian.little);
    for (var i = 0; i < n; i++) {
      bd.setInt16(44 + i * 2, (l[i] * 32767).round().clamp(-32768, 32767), Endian.little);
    }
    await File(i16).writeAsBytes(bd.buffer.asUint8List());
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  test('library loads', () {
    expect(NativeDsp.instance, isNotNull, reason: lib);
  }, skip: skip);

  for (final name in ['f32', 'i16']) {
    test('waveform peaks match ($name)', () {
      final path = name == 'f32' ? f32 : i16;
      final d = timed('peaks', false, () => computePeaks(path));
      final r = timed('peaks', true, () => computePeaks(path));
      expect(r.frames, d.frames);
      expect(r.channels, d.channels);
      for (var c = 0; c < d.channels; c++) {
        expect(r.min[c], d.min[c]);
        expect(r.max[c], d.max[c]);
      }
    }, skip: skip);

    test('stats, envelope and clipping match ($name)', () {
      final path = name == 'f32' ? f32 : i16;
      final d = timed('stats', false, () => analyzeStats(path, start: 1000, end: sr * 30));
      final r = timed('stats', true, () => analyzeStats(path, start: 1000, end: sr * 30));
      for (var c = 0; c < d.length; c++) {
        expect(
          [r[c].peak, r[c].rms, r[c].dc, r[c].min, r[c].max, r[c].clipped],
          [d[c].peak, d[c].rms, d[c].dc, d[c].min, d[c].max, d[c].clipped],
        );
      }
      expect(timed('envelope', true, () => rmsEnvelope(path)), timed('envelope', false, () => rmsEnvelope(path)));
      final clipD = timed('clipping', false, () => findClipping(path));
      expect(timed('clipping', true, () => findClipping(path)), clipD);
      if (name == 'f32') expect(clipD, [(sr * 10, sr * 10 + 50)]);
    }, skip: skip);
  }

  test('spectrum matches', () {
    final d = timed('spectrum', false, () => averageSpectrum(f32, fftSize: 4096));
    final r = timed('spectrum', true, () => averageSpectrum(f32, fftSize: 4096));
    expect(r.length, d.length);
    for (var i = 0; i < d.length; i++) {
      expect(r[i], closeTo(d[i], 1e-6));
    }
  }, skip: skip);

  test('effects match', () {
    final x = [Float32List(sr * 5), Float32List(sr * 5)];
    for (var i = 0; i < x[0].length; i++) {
      x[0][i] = 0.5 * math.sin(i * 0.05);
      x[1][i] = 0.3 * math.sin(i * 0.11);
    }
    List<Float32List> both(String name, List<Float32List> Function() f, {double tol = 1e-5}) {
      final d = timed(name, false, f), r = timed(name, true, f);
      expect(r.length, d.length);
      for (var c = 0; c < d.length; c++) {
        expect(r[c].length, d[c].length, reason: name);
        if (tol >= 0) {
          var worst = 0.0;
          for (var i = 0; i < d[c].length; i++) {
            worst = math.max(worst, (r[c][i] - d[c][i]).abs());
          }
          expect(worst, lessThan(tol), reason: name);
        }
      }
      return r;
    }

    both('wahwah', () => wahwah(x, sr, lfoHz: 1.5, depth: 0.7, resonance: 2.5, offset: 0.3));
    both('slidingSpeed', () => slidingSpeed(x, fromPct: -20, toPct: 50));
    // Random phases differ: same length and loudness.
    final st = both('paulstretch', () => paulstretch(x, sr, stretch: 4, windowSec: 0.25), tol: -1);
    double rms(Float32List v) => math.sqrt(v.fold<double>(0, (s, e) => s + e * e) / v.length);
    expect(rms(st[0]), closeTo(rms(x[0]), 0.02));
  }, skip: skip);
}
