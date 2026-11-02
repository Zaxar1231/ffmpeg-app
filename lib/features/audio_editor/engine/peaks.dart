import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'native_dsp.dart';
import 'wav.dart';

/// Waveform overview: min/max per bucket of [bucket] frames, per channel.
/// Drawing at any zoom combines buckets; 1 h of 48 kHz audio at 128-frame
/// buckets is ~22 k buckets per minute (≈10 MB for an hour, stereo).
class Peaks {
  const Peaks({required this.bucket, required this.frames, required this.min, required this.max});
  final int bucket;
  final int frames;

  /// Per channel.
  final List<Float32List> min;
  final List<Float32List> max;

  int get channels => min.length;
  int get buckets => min.isEmpty ? 0 : min.first.length;

  /// Min/max of channel [ch] over frames `[a, b)`.
  (double, double) range(int ch, int a, int b) {
    var lo = 0.0, hi = 0.0;
    final i0 = (a ~/ bucket).clamp(0, buckets);
    final i1 = ((b + bucket - 1) ~/ bucket).clamp(0, buckets);
    if (i1 <= i0) return (0, 0);
    lo = double.infinity;
    hi = double.negativeInfinity;
    final mn = min[ch], mx = max[ch];
    for (var i = i0; i < i1; i++) {
      if (mn[i] < lo) lo = mn[i];
      if (mx[i] > hi) hi = mx[i];
    }
    return (lo, hi);
  }
}

Peaks computePeaks(String wavPath, {int bucket = 128}) {
  final fast = NativeDsp.instance?.peaks(wavPath, bucket: bucket);
  if (fast != null) return fast;
  final f = File(wavPath).openSync();
  try {
    final info = readWavInfo(f);
    final n = (info.frames + bucket - 1) ~/ bucket;
    final mins = [for (var c = 0; c < info.channels; c++) Float32List(n)];
    final maxs = [for (var c = 0; c < info.channels; c++) Float32List(n)];
    var frame = 0;
    for (final block in readBlocks(f, info, block: bucket * 512)) {
      final len = block.first.length;
      for (var c = 0; c < info.channels; c++) {
        final d = block[c];
        for (var i = 0; i < len; i += bucket) {
          var lo = 1e9, hi = -1e9;
          final end = math.min(len, i + bucket);
          for (var k = i; k < end; k++) {
            final v = d[k];
            if (v < lo) lo = v;
            if (v > hi) hi = v;
          }
          final b = (frame + i) ~/ bucket;
          mins[c][b] = lo;
          maxs[c][b] = hi;
        }
      }
      frame += len;
    }
    return Peaks(bucket: bucket, frames: info.frames, min: mins, max: maxs);
  } finally {
    f.closeSync();
  }
}
