/// Pure-Dart DSP for what ffmpeg cannot do (Paulstretch, Wah-wah, sliding
/// speed) and for analysis (stats, spectrum, clipping, sound/silence and
/// beat finders). All functions are synchronous and meant to run in an
/// isolate (`Isolate.run`).
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'wav.dart';

// ---------------------------------------------------------------- FFT

/// In-place iterative radix-2 complex FFT. [re]/[im] length must be 2^k.
void fft(Float64List re, Float64List im, {bool inverse = false}) {
  final n = re.length;
  for (var i = 1, j = 0; i < n; i++) {
    var bit = n >> 1;
    for (; j & bit != 0; bit >>= 1) {
      j ^= bit;
    }
    j ^= bit;
    if (i < j) {
      final tr = re[i];
      re[i] = re[j];
      re[j] = tr;
      final ti = im[i];
      im[i] = im[j];
      im[j] = ti;
    }
  }
  for (var len = 2; len <= n; len <<= 1) {
    final ang = 2 * math.pi / len * (inverse ? 1 : -1);
    final wr = math.cos(ang);
    final wi = math.sin(ang);
    for (var i = 0; i < n; i += len) {
      var cr = 1.0, ci = 0.0;
      for (var k = 0; k < len ~/ 2; k++) {
        final ar = re[i + k + len ~/ 2] * cr - im[i + k + len ~/ 2] * ci;
        final ai = re[i + k + len ~/ 2] * ci + im[i + k + len ~/ 2] * cr;
        re[i + k + len ~/ 2] = re[i + k] - ar;
        im[i + k + len ~/ 2] = im[i + k] - ai;
        re[i + k] += ar;
        im[i + k] += ai;
        final ncr = cr * wr - ci * wi;
        ci = cr * wi + ci * wr;
        cr = ncr;
      }
    }
  }
  if (inverse) {
    for (var i = 0; i < n; i++) {
      re[i] /= n;
      im[i] /= n;
    }
  }
}

int nextPow2(int n) {
  var p = 1;
  while (p < n) {
    p <<= 1;
  }
  return p;
}

Float64List hann(int n) =>
    Float64List.fromList([for (var i = 0; i < n; i++) 0.5 - 0.5 * math.cos(2 * math.pi * i / n)]);

// ---------------------------------------------------------------- effects

/// Paulstretch (Nasca Octavian Paul): extreme time stretching by
/// overlap-adding windowed spectra with randomized phases.
List<Float32List> paulstretch(
  List<Float32List> input,
  int sampleRate, {
  required double stretch,
  required double windowSec,
}) {
  final win = math.max(256, nextPow2((windowSec * sampleRate).round()));
  final half = win ~/ 2;
  final w = hann(win);
  final inLen = input.first.length;
  final outLen = (inLen * stretch).round() + win;
  final rnd = math.Random(42);
  final out = [for (final _ in input) Float32List(outLen)];
  final hopOut = half;
  final hopIn = half / stretch;
  final re = Float64List(win);
  final im = Float64List(win);
  var posIn = 0.0;
  for (var posOut = 0; posOut + win <= outLen; posOut += hopOut) {
    final start = posIn.floor();
    for (var c = 0; c < input.length; c++) {
      final src = input[c];
      for (var i = 0; i < win; i++) {
        final idx = start + i;
        re[i] = (idx < inLen ? src[idx] : 0) * w[i];
        im[i] = 0;
      }
      fft(re, im);
      for (var i = 0; i < win; i++) {
        final mag = math.sqrt(re[i] * re[i] + im[i] * im[i]);
        final ph = rnd.nextDouble() * 2 * math.pi;
        re[i] = mag * math.cos(ph);
        im[i] = mag * math.sin(ph);
      }
      fft(re, im, inverse: true);
      final dst = out[c];
      for (var i = 0; i < win; i++) {
        dst[posOut + i] += (re[i] * w[i]).toDouble();
      }
    }
    posIn += hopIn;
    if (posIn >= inLen) break;
  }
  // Random phases change the overlap-add gain, so match the input loudness.
  final keep = math.min(outLen, (inLen * stretch).round());
  double rms(Float32List x, int n) {
    var s = 0.0;
    for (var i = 0; i < n; i++) {
      s += x[i] * x[i];
    }
    return n == 0 ? 0 : math.sqrt(s / n);
  }

  final rIn = input.map((c) => rms(c, inLen)).fold<double>(0, math.max);
  final rOut = out.map((c) => rms(c, keep)).fold<double>(0, math.max);
  final g = rOut <= 0 ? 1.0 : rIn / rOut;
  return [
    for (final ch in out) Float32List.fromList([for (var i = 0; i < keep; i++) ch[i] * g]),
  ];
}

/// Wah-wah: a resonant band-pass (state-variable filter) swept by an LFO.
List<Float32List> wahwah(
  List<Float32List> input,
  int sampleRate, {
  required double lfoHz,
  required double depth,
  required double resonance,
  required double offset,
}) {
  const fMin = 300.0, fMax = 3000.0;
  final q = 1 / resonance.clamp(0.1, 10);
  return [
    for (final src in input)
      () {
        final dst = Float32List(src.length);
        var low = 0.0, band = 0.0;
        for (var i = 0; i < src.length; i++) {
          final lfo = 0.5 + 0.5 * math.sin(2 * math.pi * lfoHz * i / sampleRate);
          final pos = (offset + depth * (lfo - 0.5)).clamp(0.0, 1.0);
          final fc = fMin * math.pow(fMax / fMin, pos);
          final f = 2 * math.sin(math.pi * fc / sampleRate);
          final high = src[i] - low - q * band;
          band += f * high;
          low += f * band;
          // Mix the swept band with some dry signal, like a pedal.
          dst[i] = (0.3 * src[i] + 0.9 * band).clamp(-4.0, 4.0).toDouble();
        }
        return dst;
      }(),
  ];
}

/// Varispeed with a linear ramp from [fromPct] to [toPct] (speed and pitch
/// change together, like turning a record player's speed knob).
List<Float32List> slidingSpeed(List<Float32List> input, {required double fromPct, required double toPct}) {
  final n = input.first.length;
  final r0 = 1 + fromPct / 100;
  final r1 = 1 + toPct / 100;
  // Output length from integrating 1/rate over the input.
  final positions = <double>[];
  var pos = 0.0;
  while (pos < n - 1) {
    positions.add(pos);
    final t = pos / n;
    pos += (r0 + (r1 - r0) * t).clamp(0.05, 10);
  }
  return [
    for (final src in input)
      Float32List.fromList([
        for (final x in positions)
          () {
            final i = x.floor();
            final f = x - i;
            return src[i] * (1 - f) + src[math.min(i + 1, n - 1)] * f;
          }(),
      ]),
  ];
}

// ---------------------------------------------------------------- analysis

class ChannelStats {
  const ChannelStats({
    required this.peak,
    required this.rms,
    required this.dc,
    required this.clipped,
    this.min = 0,
    this.max = 0,
  });
  final double peak;

  /// Lowest and highest sample values.
  final double min;
  final double max;
  final double rms;
  final double dc;
  final int clipped;
  double get peakDb => peak <= 0 ? -double.infinity : 20 * math.log(peak) / math.ln10;
  double get rmsDb => rms <= 0 ? -double.infinity : 20 * math.log(rms) / math.ln10;
}

/// Peak, RMS, DC offset and clipped-sample count per channel of a range.
List<ChannelStats> analyzeStats(String wavPath, {int start = 0, int? end, double clipLevel = 0.9999}) {
  final f = File(wavPath).openSync();
  try {
    final info = readWavInfo(f);
    final ch = info.channels;
    final peak = List.filled(ch, 0.0), sum = List.filled(ch, 0.0), sq = List.filled(ch, 0.0);
    final lo = List.filled(ch, 0.0), hi = List.filled(ch, 0.0);
    final clip = List.filled(ch, 0);
    var n = 0;
    for (final block in readBlocks(f, info, start: start, end: end)) {
      for (var c = 0; c < ch; c++) {
        final d = block[c];
        for (var i = 0; i < d.length; i++) {
          final v = d[i];
          final a = v.abs();
          if (a > peak[c]) peak[c] = a;
          if (v < lo[c]) lo[c] = v;
          if (v > hi[c]) hi[c] = v;
          if (a >= clipLevel) clip[c]++;
          sum[c] += v;
          sq[c] += v * v;
        }
      }
      n += block.first.length;
    }
    return [
      for (var c = 0; c < ch; c++)
        ChannelStats(
          peak: peak[c],
          rms: n == 0 ? 0 : math.sqrt(sq[c] / n),
          dc: n == 0 ? 0 : sum[c] / n,
          clipped: clip[c],
          min: lo[c],
          max: hi[c],
        ),
    ];
  } finally {
    f.closeSync();
  }
}

/// Average magnitude spectrum (Hann window, 50% overlap), mono-summed.
/// Returns dB values for bins 0..fftSize/2.
Float64List averageSpectrum(String wavPath, {int start = 0, int? end, int fftSize = 4096}) {
  final f = File(wavPath).openSync();
  try {
    final info = readWavInfo(f);
    final stop = math.min(end ?? info.frames, info.frames);
    final w = hann(fftSize);
    final acc = Float64List(fftSize ~/ 2 + 1);
    final re = Float64List(fftSize), im = Float64List(fftSize);
    var frames = 0;
    // Analyze at most ~2000 windows spread over the range for speed.
    final hop = math.max(fftSize ~/ 2, ((stop - start) / 2000).floor());
    for (var s = start; s + fftSize <= stop; s += hop) {
      final block = readFrames(f, info, s, fftSize);
      for (var i = 0; i < fftSize; i++) {
        var v = 0.0;
        for (final c in block) {
          v += c[i];
        }
        re[i] = v / block.length * w[i];
        im[i] = 0;
      }
      fft(re, im);
      for (var i = 0; i < acc.length; i++) {
        acc[i] += math.sqrt(re[i] * re[i] + im[i] * im[i]);
      }
      frames++;
    }
    final norm = frames == 0 ? 1 : frames * fftSize / 4;
    return Float64List.fromList([
      for (final a in acc) a <= 0 ? -120.0 : math.max(-120.0, 20 * math.log(a / norm) / math.ln10),
    ]);
  } finally {
    f.closeSync();
  }
}

/// Short-term RMS (dB) in windows of [windowMs].
Float64List rmsEnvelope(String wavPath, {int windowMs = 10, int start = 0, int? end}) {
  final f = File(wavPath).openSync();
  try {
    final info = readWavInfo(f);
    final win = math.max(1, info.sampleRate * windowMs ~/ 1000);
    final out = <double>[];
    var acc = 0.0;
    var cnt = 0;
    for (final block in readBlocks(f, info, start: start, end: end, block: win * 64)) {
      final n = block.first.length;
      for (var i = 0; i < n; i++) {
        var v = 0.0;
        for (final c in block) {
          v = math.max(v, c[i].abs());
        }
        acc += v * v;
        if (++cnt == win) {
          out.add(acc <= 0 ? -120 : 10 * math.log(acc / cnt) / math.ln10);
          acc = 0;
          cnt = 0;
        }
      }
    }
    return Float64List.fromList(out);
  } finally {
    f.closeSync();
  }
}

/// Regions above (sounds) or below (silence) [thresholdDb] lasting at least
/// [minMs]; returns frame ranges as (start, end).
List<(int, int)> findRegions(
  Float64List env,
  int windowFrames, {
  required double thresholdDb,
  required int minWindows,
  required bool sounds,
}) {
  final out = <(int, int)>[];
  int? s;
  for (var i = 0; i <= env.length; i++) {
    final hit = i < env.length && (sounds ? env[i] >= thresholdDb : env[i] < thresholdDb);
    if (hit && s == null) s = i;
    if (!hit && s != null) {
      if (i - s >= minWindows) out.add((s * windowFrames, i * windowFrames));
      s = null;
    }
  }
  return out;
}

/// Runs of samples at or above [level] (clipping); (start, end) frames.
List<(int, int)> findClipping(String wavPath, {double level = 0.9999, int minRun = 3}) {
  final f = File(wavPath).openSync();
  final out = <(int, int)>[];
  try {
    final info = readWavInfo(f);
    var pos = 0;
    int? s;
    for (final block in readBlocks(f, info)) {
      final n = block.first.length;
      for (var i = 0; i < n; i++) {
        var hit = false;
        for (final c in block) {
          if (c[i].abs() >= level) hit = true;
        }
        if (hit) {
          s ??= pos + i;
        } else if (s != null) {
          if (pos + i - s >= minRun) out.add((s, pos + i));
          s = null;
        }
      }
      pos += n;
    }
    if (s != null && pos - s >= minRun) out.add((s, pos));
    return out;
  } finally {
    f.closeSync();
  }
}

/// Simple onset/beat finder: energy jumps in 10 ms windows above
/// [thresholdDb] and at least [minGapMs] apart. Returns frame positions.
List<int> findBeats(
  Float64List env,
  int windowFrames, {
  required double thresholdDb,
  int minGapMs = 150,
  int windowMs = 10,
}) {
  final out = <int>[];
  final gap = (minGapMs / windowMs).ceil();
  var last = -gap;
  for (var i = 0; i < env.length; i++) {
    final rise = env[i] - (i == 0 ? -120.0 : env[i - 1]);
    if (env[i] >= thresholdDb && rise > 6 && i - last >= gap) {
      out.add(i * windowFrames);
      last = i;
    }
  }
  return out;
}
