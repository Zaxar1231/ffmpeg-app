/// Locale-independent number formatting helpers for the UI.
/// Units are passed in so they can be localized by the caller.
library;

String formatBytes(int? bytes, {List<String> units = const ['B', 'KB', 'MB', 'GB', 'TB']}) {
  if (bytes == null) return '—';
  double v = bytes.toDouble();
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  final digits = i == 0 ? 0 : (v >= 100 ? 0 : (v >= 10 ? 1 : 2));
  return '${v.toStringAsFixed(digits)} ${units[i]}';
}

/// `1:02:03`, `2:03`, `0:05`; with [millis] adds `.250`.
String formatDuration(Duration? d, {bool millis = false}) {
  if (d == null) return '—';
  final neg = d.isNegative;
  final a = d.abs();
  final h = a.inHours;
  final m = a.inMinutes.remainder(60);
  final s = a.inSeconds.remainder(60);
  String two(int x) => x.toString().padLeft(2, '0');
  var out = h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
  if (millis) out += '.${a.inMilliseconds.remainder(1000).toString().padLeft(3, '0')}';
  return neg ? '-$out' : out;
}

String formatBitrate(num? bitsPerSecond, {String kbps = 'kb/s', String mbps = 'Mb/s'}) {
  if (bitsPerSecond == null || bitsPerSecond <= 0) return '—';
  if (bitsPerSecond >= 1e6) return '${(bitsPerSecond / 1e6).toStringAsFixed(bitsPerSecond >= 1e7 ? 1 : 2)} $mbps';
  return '${(bitsPerSecond / 1e3).round()} $kbps';
}

String formatFps(double? fps) {
  if (fps == null) return '—';
  final r = fps.roundToDouble();
  return (fps - r).abs() < 0.005 ? r.toStringAsFixed(0) : fps.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
}
