/// Typed model of an ffmpeg command line.
///
/// Features build an [FfmpegCommand] from their parameter models; the engine
/// turns it into an argument list (no shell involved, so no quoting issues).
/// [toDisplayString] produces a copy-pasteable command for the expert view.
library;

import 'shell_quote.dart';

/// One `-i` input with the options that must precede it.
class FfmpegInput {
  const FfmpegInput(this.path, {this.seek, this.to, this.duration, this.format, this.hwaccel, this.options = const []});

  final String path;

  /// `-ss` before `-i`: fast (keyframe) seek on the input.
  final Duration? seek;

  /// `-to` before `-i`: stop reading the input at this position.
  final Duration? to;

  /// `-t` before `-i`: read at most this much of the input.
  final Duration? duration;

  /// `-f` before `-i` (e.g. `lavfi`, `concat`).
  final String? format;

  /// `-hwaccel` before `-i` (e.g. `cuda`, `qsv`, `d3d11va`, `vaapi`).
  final String? hwaccel;

  /// Any extra raw options placed before `-i`.
  final List<String> options;

  List<String> toArgs() => [
    if (hwaccel != null) ...['-hwaccel', hwaccel!],
    if (seek != null) ...['-ss', formatTimestamp(seek!)],
    if (to != null) ...['-to', formatTimestamp(to!)],
    if (duration != null) ...['-t', formatTimestamp(duration!)],
    if (format != null) ...['-f', format!],
    ...options,
    '-i',
    path,
  ];
}

/// One output file with everything that applies to it.
class FfmpegOutput {
  const FfmpegOutput(
    this.path, {
    this.maps = const [],
    this.videoCodec,
    this.audioCodec,
    this.subtitleCodec,
    this.noVideo = false,
    this.noAudio = false,
    this.noSubtitles = false,
    this.videoFilters = const [],
    this.audioFilters = const [],
    this.format,
    this.seek,
    this.duration,
    this.to,
    this.metadata = const {},
    this.options = const [],
  });

  final String path;

  /// `-map` specifiers, e.g. `0:v:0`, `1:a`, `[v]`.
  final List<String> maps;
  final String? videoCodec;
  final String? audioCodec;
  final String? subtitleCodec;
  final bool noVideo;
  final bool noAudio;
  final bool noSubtitles;

  /// Joined with `,` into `-vf`.
  final List<String> videoFilters;

  /// Joined with `,` into `-af`.
  final List<String> audioFilters;

  /// `-f` for the output (e.g. `null`, `mp4`, `segment`).
  final String? format;

  /// `-ss` after `-i`: frame-accurate (decoding) seek.
  final Duration? seek;
  final Duration? duration;
  final Duration? to;

  /// Global `-metadata key=value`.
  final Map<String, String> metadata;

  /// Raw output options (codec params etc.), placed before the path.
  final List<String> options;

  List<String> toArgs() => [
    for (final m in maps) ...['-map', m],
    if (seek != null) ...['-ss', formatTimestamp(seek!)],
    if (to != null) ...['-to', formatTimestamp(to!)],
    if (duration != null) ...['-t', formatTimestamp(duration!)],
    if (noVideo) '-vn',
    if (noAudio) '-an',
    if (noSubtitles) '-sn',
    if (videoCodec != null) ...['-c:v', videoCodec!],
    if (audioCodec != null) ...['-c:a', audioCodec!],
    if (subtitleCodec != null) ...['-c:s', subtitleCodec!],
    if (videoFilters.isNotEmpty) ...['-vf', videoFilters.join(',')],
    if (audioFilters.isNotEmpty) ...['-af', audioFilters.join(',')],
    for (final e in metadata.entries) ...['-metadata', '${e.key}=${e.value}'],
    ...options,
    if (format != null) ...['-f', format!],
    path,
  ];
}

class FfmpegCommand {
  const FfmpegCommand({
    required this.inputs,
    required this.outputs,
    this.filterComplex,
    this.globalOptions = const [],
    this.overwrite = true,
    this.logLevel = 'error',
    this.reportProgress = true,
  });

  final List<FfmpegInput> inputs;
  final List<FfmpegOutput> outputs;

  /// `-filter_complex` graph.
  final String? filterComplex;

  /// Extra global options placed before the inputs.
  final List<String> globalOptions;

  /// `-y` (true) or `-n` (false).
  final bool overwrite;

  /// `-v` level. `error` keeps stderr small but still informative;
  /// `info` is used when the caller needs filter output (e.g. detectors).
  final String logLevel;

  /// Adds `-progress pipe:1 -nostats` so the engine can parse progress.
  final bool reportProgress;

  List<String> toArgs() => [
    '-hide_banner',
    '-nostdin',
    overwrite ? '-y' : '-n',
    '-v',
    logLevel,
    if (reportProgress) ...['-progress', 'pipe:1', '-nostats'],
    ...globalOptions,
    for (final i in inputs) ...i.toArgs(),
    if (filterComplex != null) ...['-filter_complex', filterComplex!],
    for (final o in outputs) ...o.toArgs(),
  ];

  /// Human-readable command for the "Show command" button.
  String toDisplayString({String executable = 'ffmpeg', bool windows = false}) =>
      quoteCommand([executable, ...toArgs()], windows: windows);
}

/// `HH:MM:SS.mmm`, the format ffmpeg accepts for every time option.
String formatTimestamp(Duration d) {
  final negative = d.isNegative;
  final abs = d.abs();
  final h = abs.inHours;
  final m = abs.inMinutes.remainder(60);
  final s = abs.inSeconds.remainder(60);
  final ms = abs.inMilliseconds.remainder(1000);
  String two(int v) => v.toString().padLeft(2, '0');
  return '${negative ? '-' : ''}${two(h)}:${two(m)}:${two(s)}.${ms.toString().padLeft(3, '0')}';
}

/// Escapes a value for use inside a filtergraph option (`key=value`).
///
/// Filtergraph escaping has two levels: characters special to the option
/// parser (`\`, `'`, `:`) and to the graph parser (`,`, `;`, `[`, `]`).
/// Windows paths like `C:\fonts\a.ttf` are the common real-world case.
String escapeFilterValue(String value) {
  final level1 = value.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(':', r'\:');
  // The graph parser also honours quotes, so `'` is escaped again here.
  return level1
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(',', r'\,')
      .replaceAll(';', r'\;')
      .replaceAll('[', r'\[')
      .replaceAll(']', r'\]');
}
