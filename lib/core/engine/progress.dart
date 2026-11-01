/// Parsing of `ffmpeg -progress pipe:1` output.
///
/// ffmpeg writes blocks of `key=value` lines, each block terminated by a
/// `progress=continue` or `progress=end` line.
library;

class FfmpegProgress {
  const FfmpegProgress({
    this.frame,
    this.fps,
    this.bitrateKbps,
    this.totalSize,
    this.outTime,
    this.speed,
    this.dupFrames,
    this.dropFrames,
    this.fraction,
    this.eta,
    this.ended = false,
  });

  final int? frame;
  final double? fps;
  final double? bitrateKbps;
  final int? totalSize;
  final Duration? outTime;

  /// Realtime multiplier, e.g. `2.5` for `speed=2.5x`.
  final double? speed;
  final int? dupFrames;
  final int? dropFrames;

  /// 0..1 when the total duration is known.
  final double? fraction;
  final Duration? eta;
  final bool ended;

  Map<String, Object?> toJson() => {
        'frame': frame,
        'fps': fps,
        'bitrateKbps': bitrateKbps,
        'totalSize': totalSize,
        'outTimeUs': outTime?.inMicroseconds,
        'speed': speed,
        'fraction': fraction,
        'etaMs': eta?.inMilliseconds,
        'ended': ended,
      };

  factory FfmpegProgress.fromJson(Map<String, Object?> j) => FfmpegProgress(
        frame: j['frame'] as int?,
        fps: (j['fps'] as num?)?.toDouble(),
        bitrateKbps: (j['bitrateKbps'] as num?)?.toDouble(),
        totalSize: j['totalSize'] as int?,
        outTime: j['outTimeUs'] == null ? null : Duration(microseconds: j['outTimeUs'] as int),
        speed: (j['speed'] as num?)?.toDouble(),
        fraction: (j['fraction'] as num?)?.toDouble(),
        eta: j['etaMs'] == null ? null : Duration(milliseconds: j['etaMs'] as int),
        ended: j['ended'] as bool? ?? false,
      );
}

/// Stateful line consumer; emits a snapshot at the end of each block.
class ProgressParser {
  ProgressParser({this.totalDuration});

  /// Expected output duration (from ffprobe and trim settings); enables
  /// [FfmpegProgress.fraction] and [FfmpegProgress.eta].
  final Duration? totalDuration;

  final Map<String, String> _block = {};

  /// Feeds one line. Returns a snapshot when a block completes.
  FfmpegProgress? addLine(String rawLine) {
    final line = rawLine.trim();
    final eq = line.indexOf('=');
    if (eq <= 0) return null;
    final key = line.substring(0, eq).trim();
    final value = line.substring(eq + 1).trim();
    if (key != 'progress') {
      _block[key] = value;
      return null;
    }
    final snapshot = _build(ended: value == 'end');
    _block.clear();
    return snapshot;
  }

  FfmpegProgress _build({required bool ended}) {
    final outTime = _parseOutTime();
    final speed = _parseSpeed(_block['speed']);
    double? fraction;
    Duration? eta;
    final total = totalDuration;
    if (ended) {
      fraction = 1;
      eta = Duration.zero;
    } else if (total != null && total > Duration.zero && outTime != null) {
      fraction = (outTime.inMicroseconds / total.inMicroseconds).clamp(0.0, 1.0);
      if (speed != null && speed > 0) {
        final remainingUs = (total - outTime).inMicroseconds / speed;
        eta = Duration(microseconds: remainingUs.clamp(0, double.maxFinite).round());
      }
    }
    return FfmpegProgress(
      frame: int.tryParse(_block['frame'] ?? ''),
      fps: double.tryParse(_block['fps'] ?? ''),
      bitrateKbps: _parseBitrate(_block['bitrate']),
      totalSize: int.tryParse(_block['total_size'] ?? ''),
      outTime: outTime,
      speed: speed,
      dupFrames: int.tryParse(_block['dup_frames'] ?? ''),
      dropFrames: int.tryParse(_block['drop_frames'] ?? ''),
      fraction: fraction,
      eta: eta,
      ended: ended,
    );
  }

  Duration? _parseOutTime() {
    // out_time_us is authoritative; out_time_ms is (historically) also in µs.
    final us = int.tryParse(_block['out_time_us'] ?? '') ?? int.tryParse(_block['out_time_ms'] ?? '');
    if (us != null && us >= 0) return Duration(microseconds: us);
    final t = _block['out_time'];
    if (t != null) return parseFfmpegTime(t);
    return null;
  }

  static double? _parseSpeed(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll('x', '').trim());
  }

  static double? _parseBitrate(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll('kbits/s', '').trim());
  }
}

/// Parses `HH:MM:SS(.frac)`, `MM:SS`, or plain seconds. Returns null on N/A.
Duration? parseFfmpegTime(String value) {
  final v = value.trim();
  if (v.isEmpty || v == 'N/A') return null;
  final negative = v.startsWith('-');
  final body = negative ? v.substring(1) : v;
  final parts = body.split(':');
  double seconds = 0;
  for (final p in parts) {
    final n = double.tryParse(p);
    if (n == null) return null;
    seconds = seconds * 60 + n;
  }
  final d = Duration(microseconds: (seconds * 1e6).round());
  return negative ? -d : d;
}
