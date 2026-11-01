import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../platform/host.dart';
import '../providers.dart';
import '../settings/app_settings.dart';
import 'catalog.dart';
import 'component_store.dart';
import 'downloader.dart';
import 'installer.dart';
import 'resolver.dart';

enum TaskPhase { resolving, downloading, verifying, extracting, testing }

class ComponentTask {
  const ComponentTask(this.phase, {this.progress, this.bytesPerSecond});
  final TaskPhase phase;
  final double? progress;
  final double? bytesPerSecond;
}

class ComponentsState {
  const ComponentsState({
    this.loaded = false,
    this.records = const {},
    this.tasks = const {},
    this.latest = const {},
    this.errors = const {},
    this.checking = false,
    this.lastCheck,
  });

  final bool loaded;
  final Map<ComponentId, ComponentRecord> records;
  final Map<ComponentId, ComponentTask> tasks;
  final Map<ComponentId, PackageSpec> latest;
  final Map<ComponentId, String> errors;
  final bool checking;
  final DateTime? lastCheck;

  bool isBusy(ComponentId id) => tasks.containsKey(id);

  bool updateAvailable(ComponentId id) {
    final l = latest[id];
    final a = records[id]?.activeInstall;
    if (l == null || a == null) return false;
    if (a.source != l.source || a.variant != l.variant || a.channel != l.channel) return true;
    if (l.sha256 != null && a.sha256 != null) return l.sha256 != a.sha256;
    return l.fileName != a.fileName;
  }

  ComponentsState copyWith({
    bool? loaded,
    Map<ComponentId, ComponentRecord>? records,
    Map<ComponentId, ComponentTask>? tasks,
    Map<ComponentId, PackageSpec>? latest,
    Map<ComponentId, String>? errors,
    bool? checking,
    DateTime? lastCheck,
  }) => ComponentsState(
    loaded: loaded ?? this.loaded,
    records: records ?? this.records,
    tasks: tasks ?? this.tasks,
    latest: latest ?? this.latest,
    errors: errors ?? this.errors,
    checking: checking ?? this.checking,
    lastCheck: lastCheck ?? this.lastCheck,
  );
}

/// Installs, updates, rolls back and removes external tools.
class ComponentsController extends Notifier<ComponentsState> {
  final _cancelTokens = <ComponentId, CancelToken>{};
  late ComponentStore _store;
  late ComponentResolver _resolver;

  @override
  ComponentsState build() {
    final paths = ref.watch(appPathsProvider);
    _store = ComponentStore(paths.componentState);
    _resolver = ComponentResolver();
    ref.onDispose(_resolver.close);
    Future.microtask(_load);
    return const ComponentsState();
  }

  String get _root => ref.read(appPathsProvider).components;
  AppSettings get _settings => ref.read(settingsProvider);

  Future<void> _load() async {
    final records = await _store.load();
    if (!ref.mounted) return;
    state = state.copyWith(loaded: true, records: records);
    unawaited(_startupUpdates());
  }

  /// Honors per-component update policy once at startup.
  Future<void> _startupUpdates() async {
    final installed = state.records.entries.where((e) => e.value.activeInstall != null).map((e) => e.key).toList();
    if (installed.isEmpty) return;
    final s = _settings;
    final toCheck = installed.where((id) => s.policyFor(id) != ComponentUpdatePolicy.never).toList();
    if (toCheck.isEmpty) return;
    await checkUpdates(only: toCheck);
    for (final id in toCheck) {
      if (!ref.mounted) return;
      if (s.policyFor(id) == ComponentUpdatePolicy.automatic && state.updateAvailable(id)) {
        await install(id, spec: state.latest[id]);
      }
    }
  }

  Future<PackageSpec> resolve(ComponentId id) {
    final s = _settings;
    switch (id) {
      case ComponentId.ffmpeg:
        if (s.ffmpegSource == FfmpegSourcePref.gyan && HostPlatform.current.isWindows) {
          return _resolver.resolveFfmpegGyan(flavor: s.gyanFlavor);
        }
        return _resolver.resolveFfmpegBtbn(license: s.ffmpegLicense, channel: s.ffmpegChannel);
      case ComponentId.ytdlp:
        return _resolver.resolveYtdlp(channel: s.ytdlpChannel);
      case ComponentId.deno:
        return _resolver.resolveDeno();
      case ComponentId.aria2:
        return _resolver.resolveAria2();
    }
  }

  Future<void> checkUpdates({List<ComponentId>? only}) async {
    if (state.checking) return;
    state = state.copyWith(checking: true);
    final latest = Map.of(state.latest);
    final errors = Map.of(state.errors);
    final ids = only ?? ComponentId.values;
    await Future.wait(
      ids.map((id) async {
        try {
          latest[id] = await resolve(id);
          errors.remove(id);
        } catch (e) {
          // A missing build for this platform (e.g. aria2 on Linux) is not an
          // error worth shouting about unless the component is installed.
          if (state.records[id]?.activeInstall != null) errors[id] = e.toString();
        }
      }),
    );
    if (!ref.mounted) return;
    state = state.copyWith(checking: false, latest: latest, errors: errors, lastCheck: DateTime.now());
  }

  void _setTask(ComponentId id, ComponentTask? t) {
    final tasks = Map.of(state.tasks);
    if (t == null) {
      tasks.remove(id);
    } else {
      tasks[id] = t;
    }
    state = state.copyWith(tasks: tasks);
  }

  void _setError(ComponentId id, String? e) {
    final errors = Map.of(state.errors);
    if (e == null) {
      errors.remove(id);
    } else {
      errors[id] = e;
    }
    state = state.copyWith(errors: errors);
  }

  void cancel(ComponentId id) => _cancelTokens[id]?.cancel();

  /// Downloads, verifies (SHA-256), extracts, tests and activates a package.
  Future<bool> install(ComponentId id, {PackageSpec? spec}) async {
    if (state.isBusy(id)) return false;
    final token = CancelToken();
    _cancelTokens[id] = token;
    _setError(id, null);
    _setTask(id, const ComponentTask(TaskPhase.resolving));
    final paths = ref.read(appPathsProvider);
    String? archivePath;
    String? stagingDir;
    try {
      final pkg = spec ?? await resolve(id);
      if (token.isCanceled) throw DownloadCanceled();
      archivePath = p.join(paths.downloadsTemp, pkg.fileName);
      _setTask(id, const ComponentTask(TaskPhase.downloading, progress: 0));
      final sha = await downloadFile(
        pkg.url,
        archivePath,
        expectedSha256: pkg.sha256,
        cancel: token,
        onProgress: (pr) {
          if (!ref.mounted) return;
          _setTask(id, ComponentTask(TaskPhase.downloading, progress: pr.fraction, bytesPerSecond: pr.bytesPerSecond));
        },
      );
      if (!ref.mounted) return false;

      _setTask(id, const ComponentTask(TaskPhase.extracting));
      final key = '${DateTime.now().millisecondsSinceEpoch}-${_slug(pkg.versionLabel ?? pkg.channel.name)}';
      final finalDir = p.join(_root, id.name, key);
      stagingDir = '$finalDir.partial';
      final desc = componentCatalog[id]!;
      if (pkg.archive == ArchiveType.raw) {
        await Directory(stagingDir).create(recursive: true);
        await File(archivePath).copy(p.join(stagingDir, HostPlatform.current.exe(desc.binaries.first)));
      } else {
        await extractArchive(archivePath, stagingDir, pkg.archive);
      }
      final bins = locateBinaries(stagingDir, desc.binaries);
      final missing = desc.binaries.where((b) => !bins.containsKey(b)).toList();
      if (missing.isNotEmpty) throw InstallException('Not found in package: ${missing.join(', ')}');
      for (final rel in bins.values) {
        await makeExecutable(p.join(stagingDir, rel));
      }

      _setTask(id, const ComponentTask(TaskPhase.testing));
      final version = await probeComponentVersion(id, p.join(stagingDir, bins[desc.binaries.first]!));
      await Directory(stagingDir).rename(finalDir);
      stagingDir = null;

      final inst = InstalledVersion(
        key: key,
        source: pkg.source,
        channel: pkg.channel,
        variant: pkg.variant,
        version: version ?? pkg.versionLabel,
        sha256: sha,
        fileName: pkg.fileName,
        installedAt: DateTime.now(),
        binaries: bins,
      );
      final old = state.records[id] ?? const ComponentRecord();
      var installs = [inst, ...old.installs];
      final keep = 1 + _settings.keepPreviousVersions;
      final pruned = installs.skip(keep).toList();
      installs = installs.take(keep).toList();
      for (final x in pruned) {
        await _deleteDir(p.join(_root, id.name, x.key));
      }
      await _commit(id, ComponentRecord(active: key, installs: installs));
      return true;
    } on DownloadCanceled {
      return false;
    } catch (e) {
      if (ref.mounted) _setError(id, e.toString());
      return false;
    } finally {
      _cancelTokens.remove(id);
      if (archivePath != null) {
        final f = File(archivePath);
        if (await f.exists()) await f.delete();
      }
      if (stagingDir != null) await _deleteDir(stagingDir);
      if (ref.mounted) _setTask(id, null);
    }
  }

  Future<void> activate(ComponentId id, String key) async {
    final rec = state.records[id];
    if (rec == null || !rec.installs.any((i) => i.key == key)) return;
    await _commit(id, rec.copyWith(active: key));
  }

  /// Switches to the most recent previous install.
  Future<bool> rollback(ComponentId id) async {
    final prev = state.records[id]?.previous ?? const [];
    if (prev.isEmpty) return false;
    await activate(id, prev.first.key);
    return true;
  }

  Future<void> removeVersion(ComponentId id, String key) async {
    final rec = state.records[id];
    if (rec == null) return;
    final installs = rec.installs.where((i) => i.key != key).toList();
    await _deleteDir(p.join(_root, id.name, key));
    final active = rec.active == key ? installs.firstOrNull?.key : rec.active;
    await _commit(id, ComponentRecord(active: active, installs: installs));
  }

  Future<void> uninstall(ComponentId id) async {
    await _deleteDir(p.join(_root, id.name));
    final records = Map.of(state.records)..remove(id);
    await _store.save(records);
    if (ref.mounted) state = state.copyWith(records: records);
  }

  Future<void> _commit(ComponentId id, ComponentRecord rec) async {
    final records = Map.of(state.records)..[id] = rec;
    await _store.save(records);
    if (ref.mounted) state = state.copyWith(records: records);
  }

  static Future<void> _deleteDir(String path) async {
    final d = Directory(path);
    if (await d.exists()) {
      try {
        await d.delete(recursive: true);
      } on FileSystemException {
        // In use (Windows locks running .exe files); leave it for next start.
      }
    }
  }

  static String _slug(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
