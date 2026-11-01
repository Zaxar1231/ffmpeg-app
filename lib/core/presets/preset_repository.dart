import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../providers.dart';

class UserPreset {
  const UserPreset({
    required this.id,
    required this.toolId,
    required this.name,
    required this.params,
    required this.createdAt,
  });
  final String id;
  final String toolId;
  final String name;
  final Map<String, Object?> params;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {'tool': toolId, 'name': name, 'params': params};
}

/// Export format: `{"kadra": "presets", "version": 1, "presets": [...]}`.
const presetExportVersion = 1;

String exportPresets(List<UserPreset> presets) => const JsonEncoder.withIndent('  ')
    .convert({'kadra': 'presets', 'version': presetExportVersion, 'presets': presets.map((p) => p.toJson()).toList()});

/// Parses an export file. Throws [FormatException] on foreign/broken files.
List<({String toolId, String name, Map<String, Object?> params})> parsePresetExport(String text) {
  final Object? j;
  try {
    j = jsonDecode(text);
  } on FormatException {
    rethrow;
  }
  if (j is! Map || j['kadra'] != 'presets' || j['presets'] is! List) {
    throw const FormatException('Not a Kadra presets file');
  }
  return [
    for (final p in j['presets'] as List)
      if (p is Map && p['tool'] is String && p['name'] is String && p['params'] is Map)
        (toolId: p['tool'] as String, name: p['name'] as String, params: (p['params'] as Map).cast<String, Object?>()),
  ];
}

class PresetRepository {
  PresetRepository(this._db);
  final AppDatabase _db;

  Stream<List<UserPreset>> watch({String? toolId}) {
    final q = _db.select(_db.presets)..orderBy([(p) => OrderingTerm.asc(p.name)]);
    if (toolId != null) q.where((p) => p.toolId.equals(toolId));
    return q.watch().map((rows) => rows.map(_map).toList());
  }

  Future<List<UserPreset>> all() async => (await _db.select(_db.presets).get()).map(_map).toList();

  Future<String> save({
    required String toolId,
    required String name,
    required Map<String, Object?> params,
    String? id,
  }) async {
    final pid = id ?? const Uuid().v4();
    await _db
        .into(_db.presets)
        .insertOnConflictUpdate(
          PresetsCompanion.insert(
            id: pid,
            toolId: toolId,
            name: name,
            paramsJson: jsonEncode(params),
            createdAt: DateTime.now(),
          ),
        );
    return pid;
  }

  Future<void> rename(String id, String name) =>
      (_db.update(_db.presets)..where((p) => p.id.equals(id))).write(PresetsCompanion(name: Value(name)));

  Future<void> delete(String id) => (_db.delete(_db.presets)..where((p) => p.id.equals(id))).go();

  Future<UserPreset?> byId(String id) async {
    final row = await (_db.select(_db.presets)..where((p) => p.id.equals(id))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  Future<int> importText(String text) async {
    final items = parsePresetExport(text);
    for (final i in items) {
      await save(toolId: i.toolId, name: i.name, params: i.params);
    }
    return items.length;
  }

  UserPreset _map(Preset r) => UserPreset(
    id: r.id,
    toolId: r.toolId,
    name: r.name,
    params: (jsonDecode(r.paramsJson) as Map).cast<String, Object?>(),
    createdAt: r.createdAt,
  );
}

final presetRepositoryProvider = Provider<PresetRepository>((ref) => PresetRepository(ref.watch(databaseProvider)));

final userPresetsProvider = StreamProvider.family<List<UserPreset>, String?>(
  (ref, toolId) => ref.watch(presetRepositoryProvider).watch(toolId: toolId),
);
