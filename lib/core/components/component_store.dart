/// Persistent record of installed component versions (components/state.json).
///
/// Layout on disk:
///   `components/<id>/<installKey>/` (extracted files)
/// Several installs are kept so the user can roll back.
library;

import 'dart:convert';
import 'dart:io';

import 'catalog.dart';

class InstalledVersion {
  const InstalledVersion({
    required this.key,
    required this.source,
    required this.channel,
    required this.installedAt,
    required this.binaries,
    this.variant,
    this.version,
    this.sha256,
    this.fileName,
  });

  /// Folder name under components/<id>/.
  final String key;
  final ComponentSource source;
  final UpdateChannel channel;
  final String? variant;

  /// Version reported by the binary itself (e.g. `n8.1-11-g...`, `2026.10.22`).
  final String? version;
  final String? sha256;
  final String? fileName;
  final DateTime installedAt;

  /// binary name -> path relative to the install folder.
  final Map<String, String> binaries;

  Map<String, Object?> toJson() => {
        'key': key,
        'source': source.name,
        'channel': channel.name,
        'variant': variant,
        'version': version,
        'sha256': sha256,
        'fileName': fileName,
        'installedAt': installedAt.toIso8601String(),
        'binaries': binaries,
      };

  factory InstalledVersion.fromJson(Map<String, dynamic> j) => InstalledVersion(
        key: j['key'] as String,
        source: ComponentSource.values.byName(j['source'] as String),
        channel: UpdateChannel.values.byName(j['channel'] as String? ?? 'stable'),
        variant: j['variant'] as String?,
        version: j['version'] as String?,
        sha256: j['sha256'] as String?,
        fileName: j['fileName'] as String?,
        installedAt: DateTime.tryParse(j['installedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        binaries: (j['binaries'] as Map? ?? const {}).cast<String, String>(),
      );
}

class ComponentRecord {
  const ComponentRecord({this.active, this.installs = const []});

  /// Key of the active install, or null.
  final String? active;

  /// Newest first.
  final List<InstalledVersion> installs;

  InstalledVersion? get activeInstall => installs.where((i) => i.key == active).firstOrNull;

  /// Installs that can be rolled back to (all except the active one).
  List<InstalledVersion> get previous => installs.where((i) => i.key != active).toList();

  ComponentRecord copyWith({String? active, List<InstalledVersion>? installs, bool clearActive = false}) =>
      ComponentRecord(active: clearActive ? null : (active ?? this.active), installs: installs ?? this.installs);

  Map<String, Object?> toJson() => {'active': active, 'installs': installs.map((i) => i.toJson()).toList()};

  factory ComponentRecord.fromJson(Map<String, dynamic> j) => ComponentRecord(
        active: j['active'] as String?,
        installs: [
          for (final i in (j['installs'] as List? ?? const []))
            InstalledVersion.fromJson((i as Map).cast<String, dynamic>()),
        ],
      );
}

class ComponentStore {
  ComponentStore(this.path);
  final String path;

  Future<Map<ComponentId, ComponentRecord>> load() async {
    final f = File(path);
    if (!await f.exists()) return {};
    try {
      final j = (jsonDecode(await f.readAsString()) as Map).cast<String, dynamic>();
      return {
        for (final e in j.entries)
          if (ComponentId.values.any((c) => c.name == e.key))
            ComponentId.values.byName(e.key): ComponentRecord.fromJson((e.value as Map).cast<String, dynamic>()),
      };
    } catch (_) {
      // Corrupt state: keep a copy for diagnostics, start fresh.
      await f.copy('$path.corrupt');
      return {};
    }
  }

  /// Atomic write (temp file + rename).
  Future<void> save(Map<ComponentId, ComponentRecord> state) async {
    final f = File(path);
    await f.parent.create(recursive: true);
    final tmp = File('$path.tmp');
    await tmp.writeAsString(const JsonEncoder.withIndent('  ').convert({
      for (final e in state.entries) e.key.name: e.value.toJson(),
    }));
    await tmp.rename(path);
  }
}
