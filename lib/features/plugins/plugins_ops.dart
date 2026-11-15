/// Plugin effects through ffmpeg: frei0r video filters (`frei0r`) and LV2
/// audio plugins (`lv2`), when the ffmpeg build has those filters.
///
/// frei0r modules are looked up by ffmpeg in `FREI0R_PATH`, then
/// `~/.frei0r-1/lib`, then `/usr/(local/)lib(64)/frei0r-1` (vf_frei0r.c);
/// Kadra adds its own folder (`components/frei0r`) to `FREI0R_PATH`, which
/// is where Windows users put the frei0r DLLs.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/engine/ffmpeg_command.dart' show escapeFilterValue;
import '../../core/probe/media_info.dart';
import '../convert/convert_params.dart' show EditGraph;

class Frei0rPlugin {
  const Frei0rPlugin(this.name, this.dir);

  /// `filter_name` (file name without extension).
  final String name;
  final String dir;

  @override
  bool operator ==(Object other) => other is Frei0rPlugin && other.name == name;
  @override
  int get hashCode => name.hashCode;
}

/// Folders ffmpeg searches, in its order, plus [own] first.
List<String> frei0rDirs({required String own, Map<String, String>? env, bool windows = false}) {
  final e = env ?? Platform.environment;
  final sep = windows ? ';' : ':';
  return [
    own,
    ...?e['FREI0R_PATH']?.split(sep).where((s) => s.isNotEmpty),
    if (e['HOME'] != null) p.join(e['HOME']!, '.frei0r-1', 'lib'),
    if (!windows) ...[
      '/usr/local/lib/frei0r-1',
      '/usr/lib/frei0r-1',
      '/usr/local/lib64/frei0r-1',
      '/usr/lib64/frei0r-1',
    ],
  ];
}

/// Modules in [dirs] (first one wins for a name), sorted by name.
List<Frei0rPlugin> scanFrei0r(List<String> dirs, {bool windows = false}) {
  final ext = windows ? '.dll' : '.so';
  final found = <String, Frei0rPlugin>{};
  for (final d in dirs) {
    final dir = Directory(d);
    if (!dir.existsSync()) continue;
    for (final f in dir.listSync().whereType<File>()) {
      if (p.extension(f.path).toLowerCase() != ext) continue;
      final name = p.basenameWithoutExtension(f.path);
      found.putIfAbsent(name, () => Frei0rPlugin(name, d));
    }
  }
  return found.values.toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

/// `FREI0R_PATH` for ffmpeg: Kadra's folder plus what the user already set.
Map<String, String> frei0rEnv(String own, {Map<String, String>? env, bool windows = false}) {
  final e = env ?? Platform.environment;
  final existing = e['FREI0R_PATH'];
  return {
    'FREI0R_PATH': [own, if (existing != null && existing.isNotEmpty) existing].join(windows ? ';' : ':'),
  };
}

/// Plugin info from `-v verbose` (vf_frei0r prints name, author,
/// explanation and the number of parameters).
({String? explanation, String? author, int? params}) parseFrei0rInfo(String log) {
  final m = RegExp(r"name:(.*?) author:'(.*?)' explanation:'(.*?)' .*num_params:(\d+)").firstMatch(log);
  if (m == null) return (explanation: null, author: null, params: null);
  return (explanation: m.group(3), author: m.group(2), params: int.parse(m.group(4)!));
}

/// Plugin URIs from `lv2ls`.
List<String> parseLv2ls(String out) => [
  for (final l in out.split('\n'))
    if (RegExp(r'^[a-z][a-z0-9+.-]*:\S+$').hasMatch(l.trim())) l.trim(),
];

/// Video through a frei0r module; audio is copied.
/// [params] is frei0r's `filter_params` (values separated by `|`).
EditGraph frei0rGraph(MediaInfo info, String name, {String params = ''}) {
  final opts = [
    'filter_name=${escapeFilterValue(name)}',
    if (params.trim().isNotEmpty) 'filter_params=${escapeFilterValue(params.trim())}',
  ];
  return EditGraph(
    complex: '[0:v:0]frei0r=${opts.join(':')},format=yuv420p[v]',
    video: 'v',
    audio: info.audioStreams.isEmpty ? null : '0:a',
  );
}

/// An `lv2` audio filter; [controls] is `lv2`'s `controls`
/// (`name=value|name=value`).
String lv2Filter(String uri, {String controls = ''}) {
  final opts = [
    'plugin=${escapeFilterValue(uri)}',
    if (controls.trim().isNotEmpty) 'controls=${escapeFilterValue(controls.trim())}',
  ];
  return 'lv2=${opts.join(':')}';
}
