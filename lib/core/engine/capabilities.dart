/// What the installed ffmpeg build can do, parsed from its own listings:
/// `-version`, `-encoders`, `-decoders`, `-filters`, `-muxers`, `-hwaccels`.
library;

class FfmpegCapabilities {
  const FfmpegCapabilities({
    required this.version,
    required this.configuration,
    required this.encoders,
    required this.decoders,
    required this.filters,
    required this.muxers,
    required this.hwaccels,
  });

  static const empty = FfmpegCapabilities(
    version: null,
    configuration: [],
    encoders: {},
    decoders: {},
    filters: {},
    muxers: {},
    hwaccels: {},
  );

  /// e.g. `8.1`, `N-121000-g1234abcd`, `6.1.1-3ubuntu5`.
  final String? version;
  final List<String> configuration;
  final Map<String, CodecEntry> encoders;
  final Map<String, CodecEntry> decoders;
  final Map<String, FilterEntry> filters;
  final Map<String, String> muxers;
  final Set<String> hwaccels;

  bool hasEncoder(String name) => encoders.containsKey(name);
  bool hasDecoder(String name) => decoders.containsKey(name);
  bool hasFilter(String name) => filters.containsKey(name);
  bool hasMuxer(String name) => muxers.containsKey(name);
  bool isEnabled(String lib) => configuration.contains('--enable-$lib');

  /// Major version number for numbered releases, null for git/master builds.
  int? get majorVersion {
    final m = RegExp(r'^n?(\d+)\.').firstMatch(version ?? '');
    return m == null ? null : int.parse(m.group(1)!);
  }

  bool get isGpl => configuration.contains('--enable-gpl');
}

enum MediaKind { video, audio, subtitle, data, attachment, unknown }

class CodecEntry {
  const CodecEntry(this.name, this.kind, this.description);
  final String name;
  final MediaKind kind;
  final String description;
}

class FilterEntry {
  const FilterEntry(
    this.name,
    this.io,
    this.description, {
    this.timeline = false,
    this.sliceThreads = false,
    this.commands = false,
  });
  final String name;

  /// e.g. `V->V`, `A->A`, `VV->V`, `N->V`, `|->A`.
  final String io;
  final String description;
  final bool timeline;
  final bool sliceThreads;
  final bool commands;
}

MediaKind _kindFromFlag(String c) => switch (c) {
  'V' => MediaKind.video,
  'A' => MediaKind.audio,
  'S' => MediaKind.subtitle,
  'D' => MediaKind.data,
  'T' => MediaKind.attachment,
  _ => MediaKind.unknown,
};

/// Parses `ffmpeg -version` → (version, configure flags).
({String? version, List<String> configuration}) parseVersionOutput(String out) {
  final m = RegExp(r'^ffmpeg version (\S+)', multiLine: true).firstMatch(out);
  final c = RegExp(r'^configuration:(.*)$', multiLine: true).firstMatch(out);
  final config = c == null ? <String>[] : c.group(1)!.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  return (version: m?.group(1), configuration: config);
}

/// Parses `ffmpeg -encoders` / `-decoders`. Data lines look like
/// ` V....D libx264              libx264 H.264 / AVC / MPEG-4 AVC ...`
/// and come after the ` ------` separator.
Map<String, CodecEntry> parseCodecList(String out) {
  final result = <String, CodecEntry>{};
  var started = false;
  final re = RegExp(r'^\s([VASDT.])[A-Z.]{5}\s+(\S+)\s+(.*)$');
  for (final line in out.split('\n')) {
    if (!started) {
      if (line.trim().startsWith('------')) started = true;
      continue;
    }
    final m = re.firstMatch(line.trimRight());
    if (m == null) continue;
    final name = m.group(2)!;
    result[name] = CodecEntry(name, _kindFromFlag(m.group(1)!), m.group(3)!.trim());
  }
  return result;
}

/// Parses `ffmpeg -filters`. Data lines: ` TSC name   V->V   description`.
/// Older builds print only `TS`/`TSC` flag columns of width 3; newer add
/// none. We accept 2–3 flag characters.
Map<String, FilterEntry> parseFilterList(String out) {
  final result = <String, FilterEntry>{};
  final re = RegExp(r'^\s([T.])([S.])([C.])?\s+(\S+)\s+(\S+->\S+)\s+(.*)$');
  for (final line in out.split('\n')) {
    final m = re.firstMatch(line.trimRight());
    if (m == null) continue;
    final name = m.group(4)!;
    result[name] = FilterEntry(
      name,
      m.group(5)!,
      m.group(6)!.trim(),
      timeline: m.group(1) == 'T',
      sliceThreads: m.group(2) == 'S',
      commands: m.group(3) == 'C',
    );
  }
  return result;
}

/// Parses `ffmpeg -muxers` (`  E mp4  MP4 ...`, or ` .E. mp4` in 7.x where a
/// third `d` column marks devices). Comma-separated names are split.
Map<String, String> parseMuxerList(String out) {
  final result = <String, String>{};
  var started = false;
  final re = RegExp(r'^\s[D.\s]E[d.\s]?\s+(\S+)\s+(.*)$');
  for (final line in out.split('\n')) {
    if (!started) {
      if (line.trim().startsWith('--')) started = true;
      continue;
    }
    final m = re.firstMatch(line.trimRight());
    if (m == null) continue;
    for (final n in m.group(1)!.split(',')) {
      result[n] = m.group(2)!.trim();
    }
  }
  return result;
}

/// Parses `ffmpeg -hwaccels`.
Set<String> parseHwaccels(String out) {
  final lines = out.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  final idx = lines.indexWhere((l) => l.startsWith('Hardware acceleration methods'));
  if (idx < 0) return {};
  return lines.sublist(idx + 1).where((l) => RegExp(r'^[a-z0-9_]+$').hasMatch(l)).toSet();
}
