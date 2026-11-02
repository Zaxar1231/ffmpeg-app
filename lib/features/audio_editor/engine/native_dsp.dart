/// Rust implementation of the audio editor's DSP (`native/kadra_dsp`),
/// loaded through dart:ffi. Every function returns null when the library is
/// missing or reports an error; callers then use the Dart implementation,
/// so the app works the same without it, only slower on long files.
library;

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;

import 'dsp.dart' show ChannelStats;
import 'peaks.dart' show Peaks;

/// Set to false to force the Dart implementation (tests compare both).
bool useNativeDsp = true;

typedef _InfoC = Int64 Function(Pointer<Utf8>, Pointer<Int64>);
typedef _InfoD = int Function(Pointer<Utf8>, Pointer<Int64>);
typedef _PeaksC = Int64 Function(Pointer<Utf8>, Int64, Pointer<Float>, Pointer<Float>, Int64);
typedef _PeaksD = int Function(Pointer<Utf8>, int, Pointer<Float>, Pointer<Float>, int);
typedef _StatsC = Int64 Function(Pointer<Utf8>, Int64, Int64, Double, Pointer<Double>, Int64);
typedef _StatsD = int Function(Pointer<Utf8>, int, int, double, Pointer<Double>, int);
typedef _SpecC = Int64 Function(Pointer<Utf8>, Int64, Int64, Int64, Pointer<Double>);
typedef _SpecD = int Function(Pointer<Utf8>, int, int, int, Pointer<Double>);
typedef _EnvC = Int64 Function(Pointer<Utf8>, Int64, Int64, Int64, Pointer<Double>, Int64);
typedef _EnvD = int Function(Pointer<Utf8>, int, int, int, Pointer<Double>, int);
typedef _ClipC = Int64 Function(Pointer<Utf8>, Double, Int64, Pointer<Int64>, Int64);
typedef _ClipD = int Function(Pointer<Utf8>, double, int, Pointer<Int64>, int);
typedef _LenC = Int64 Function(Int64, Double);
typedef _LenD = int Function(int, double);
typedef _Len2C = Int64 Function(Int64, Double, Double);
typedef _Len2D = int Function(int, double, double);
typedef _PaulC = Int64 Function(Pointer<Float>, Int64, Int64, Int64, Double, Double, Pointer<Float>);
typedef _PaulD = int Function(Pointer<Float>, int, int, int, double, double, Pointer<Float>);
typedef _WahC = Int64 Function(Pointer<Float>, Int64, Int64, Int64, Double, Double, Double, Double, Pointer<Float>);
typedef _WahD = int Function(Pointer<Float>, int, int, int, double, double, double, double, Pointer<Float>);
typedef _SlideC = Int64 Function(Pointer<Float>, Int64, Int64, Double, Double, Pointer<Float>);
typedef _SlideD = int Function(Pointer<Float>, int, int, double, double, Pointer<Float>);

class NativeDsp {
  NativeDsp._(DynamicLibrary l)
    : _info = l.lookupFunction<_InfoC, _InfoD>('kd_wav_info'),
      _peaks = l.lookupFunction<_PeaksC, _PeaksD>('kd_peaks'),
      _stats = l.lookupFunction<_StatsC, _StatsD>('kd_stats'),
      _spectrum = l.lookupFunction<_SpecC, _SpecD>('kd_spectrum'),
      _env = l.lookupFunction<_EnvC, _EnvD>('kd_rms_envelope'),
      _clip = l.lookupFunction<_ClipC, _ClipD>('kd_find_clipping'),
      _paulLen = l.lookupFunction<_LenC, _LenD>('kd_paulstretch_len'),
      _paul = l.lookupFunction<_PaulC, _PaulD>('kd_paulstretch'),
      _wah = l.lookupFunction<_WahC, _WahD>('kd_wahwah'),
      _slideLen = l.lookupFunction<_Len2C, _Len2D>('kd_sliding_speed_len'),
      _slide = l.lookupFunction<_SlideC, _SlideD>('kd_sliding_speed');

  static const _abiVersion = 1;

  final _InfoD _info;
  final _PeaksD _peaks;
  final _StatsD _stats;
  final _SpecD _spectrum;
  final _EnvD _env;
  final _ClipD _clip;
  final _LenD _paulLen;
  final _PaulD _paul;
  final _WahD _wah;
  final _Len2D _slideLen;
  final _SlideD _slide;

  static NativeDsp? _instance;
  static bool _tried = false;

  /// The loaded library (once per isolate), or null.
  static NativeDsp? get instance {
    if (!useNativeDsp) return null;
    if (_tried) return _instance;
    _tried = true;
    for (final path in candidates()) {
      if (!File(path).existsSync()) continue;
      try {
        final lib = DynamicLibrary.open(path);
        final version = lib.lookupFunction<Int64 Function(), int Function()>('kd_version')();
        if (version != _abiVersion) continue;
        return _instance = NativeDsp._(lib);
      } catch (_) {}
    }
    return null;
  }

  static String get libraryName => Platform.isWindows
      ? 'kadra_dsp.dll'
      : Platform.isMacOS
      ? 'libkadra_dsp.dylib'
      : 'libkadra_dsp.so';

  /// Where the library is looked for: `KADRA_DSP_LIB`, next to the app
  /// (Windows: beside the exe, Linux: `lib/`), then the cargo output of a
  /// source checkout (for `flutter test` and `flutter run`).
  static List<String> candidates() {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return [
      ?Platform.environment['KADRA_DSP_LIB'],
      p.join(exeDir, libraryName),
      p.join(exeDir, 'lib', libraryName),
      p.join(Directory.current.path, 'native', 'kadra_dsp', 'target', 'release', libraryName),
    ];
  }

  // ---------------------------------------------------------------- files

  T? _withPath<T>(String path, T? Function(Pointer<Utf8>) f) {
    final s = path.toNativeUtf8();
    try {
      return f(s);
    } finally {
      malloc.free(s);
    }
  }

  /// (sampleRate, channels, frames)
  (int, int, int)? wavInfo(String path) => _withPath(path, (s) {
    final out = malloc<Int64>(3);
    try {
      if (_info(s, out) < 0) return null;
      return (out[0], out[1], out[2]);
    } finally {
      malloc.free(out);
    }
  });

  Peaks? peaks(String path, {int bucket = 128}) {
    final info = wavInfo(path);
    if (info == null) return null;
    final (_, ch, frames) = info;
    final cap = (frames + bucket - 1) ~/ bucket;
    return _withPath(path, (s) {
      final mins = malloc<Float>(ch * cap + 1), maxs = malloc<Float>(ch * cap + 1);
      try {
        final n = _peaks(s, bucket, mins, maxs, cap);
        if (n < 0 || n > cap) return null;
        return Peaks(
          bucket: bucket,
          frames: frames,
          min: [
            for (var c = 0; c < ch; c++) Float32List.fromList(mins.asTypedList(ch * cap).sublist(c * n, c * n + n)),
          ],
          max: [
            for (var c = 0; c < ch; c++) Float32List.fromList(maxs.asTypedList(ch * cap).sublist(c * n, c * n + n)),
          ],
        );
      } finally {
        malloc.free(mins);
        malloc.free(maxs);
      }
    });
  }

  List<ChannelStats>? stats(String path, {int start = 0, int? end, double clipLevel = 0.9999}) => _withPath(path, (s) {
    const cap = 64;
    final out = malloc<Double>(cap * 6);
    try {
      final n = _stats(s, start, end ?? -1, clipLevel, out, cap);
      if (n < 0 || n > cap) return null;
      final ints = out.cast<Int64>();
      return [
        for (var c = 0; c < n; c++)
          ChannelStats(
            peak: out[c * 6],
            rms: out[c * 6 + 1],
            dc: out[c * 6 + 2],
            min: out[c * 6 + 3],
            max: out[c * 6 + 4],
            clipped: ints[c * 6 + 5],
          ),
      ];
    } finally {
      malloc.free(out);
    }
  });

  Float64List? spectrum(String path, {int start = 0, int? end, int fftSize = 4096}) => _withPath(path, (s) {
    final out = malloc<Double>(fftSize ~/ 2 + 1);
    try {
      final n = _spectrum(s, start, end ?? -1, fftSize, out);
      if (n < 0) return null;
      return Float64List.fromList(out.asTypedList(n));
    } finally {
      malloc.free(out);
    }
  });

  Float64List? rmsEnvelope(String path, {int windowMs = 10, int start = 0, int? end}) {
    final info = wavInfo(path);
    if (info == null) return null;
    final (rate, _, frames) = info;
    final win = (rate * windowMs ~/ 1000).clamp(1, 1 << 40);
    final cap = frames ~/ win + 1;
    return _withPath(path, (s) {
      final out = malloc<Double>(cap);
      try {
        final n = _env(s, windowMs, start, end ?? -1, out, cap);
        if (n < 0 || n > cap) return null;
        return Float64List.fromList(out.asTypedList(n));
      } finally {
        malloc.free(out);
      }
    });
  }

  List<(int, int)>? findClipping(String path, {double level = 0.9999, int minRun = 3}) => _withPath(path, (s) {
    var cap = 4096;
    while (true) {
      final out = malloc<Int64>(cap * 2);
      try {
        final n = _clip(s, level, minRun, out, cap);
        if (n < 0) return null;
        if (n > cap) {
          cap = n;
          continue;
        }
        return [for (var k = 0; k < n; k++) (out[2 * k], out[2 * k + 1])];
      } finally {
        malloc.free(out);
      }
    }
  });

  // ---------------------------------------------------------------- effects

  List<Float32List>? _process(List<Float32List> input, int outLen, int Function(Pointer<Float>, Pointer<Float>) run) {
    if (input.isEmpty) return null;
    final len = input.first.length;
    final ch = input.length;
    final inp = malloc<Float>(ch * len + 1), out = malloc<Float>(ch * outLen + 1);
    try {
      final view = inp.asTypedList(ch * len);
      for (var c = 0; c < ch; c++) {
        view.setRange(c * len, c * len + len, input[c]);
      }
      final n = run(inp, out);
      if (n < 0 || n > outLen) return null;
      final o = out.asTypedList(ch * outLen);
      return [for (var c = 0; c < ch; c++) Float32List.fromList(o.sublist(c * n, c * n + n))];
    } finally {
      malloc.free(inp);
      malloc.free(out);
    }
  }

  List<Float32List>? paulstretch(
    List<Float32List> input,
    int sampleRate, {
    required double stretch,
    required double windowSec,
  }) {
    if (input.isEmpty) return null;
    final len = input.first.length;
    return _process(
      input,
      _paulLen(len, stretch),
      (i, o) => _paul(i, input.length, len, sampleRate, stretch, windowSec, o),
    );
  }

  List<Float32List>? wahwah(
    List<Float32List> input,
    int sampleRate, {
    required double lfoHz,
    required double depth,
    required double resonance,
    required double offset,
  }) {
    if (input.isEmpty) return null;
    final len = input.first.length;
    return _process(input, len, (i, o) => _wah(i, input.length, len, sampleRate, lfoHz, depth, resonance, offset, o));
  }

  List<Float32List>? slidingSpeed(List<Float32List> input, {required double fromPct, required double toPct}) {
    if (input.isEmpty || input.first.length < 2) return null;
    final len = input.first.length;
    return _process(input, _slideLen(len, fromPct, toPct), (i, o) => _slide(i, input.length, len, fromPct, toPct, o));
  }
}
