/// App self-update controller: checks GitHub Releases at startup and every
/// N hours, downloads the update in the background (SHA-256 checked), and
/// installs it on "Restart and update".
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../components/downloader.dart';
import '../components/installer.dart';
import '../components/catalog.dart' show ArchiveType, parseChecksums;
import '../platform/desktop.dart';
import '../platform/host.dart';
import '../providers.dart';
import '../settings/app_settings.dart';
import 'app_update.dart';

enum UpdatePhase { idle, checking, upToDate, available, downloading, ready, installing, error }

class AppUpdateState {
  const AppUpdateState({
    this.phase = UpdatePhase.idle,
    this.releases = const [],
    this.progress,
    this.error,
    this.lastCheck,
    this.manual = false,
  });
  final UpdatePhase phase;

  /// Newer releases, newest first (the first is the update).
  final List<AppRelease> releases;
  final DownloadProgress? progress;
  final String? error;
  final DateTime? lastCheck;

  /// The last check was started by the user (show "up to date").
  final bool manual;

  AppRelease? get update => releases.firstOrNull;

  AppUpdateState copy({
    UpdatePhase? phase,
    List<AppRelease>? releases,
    DownloadProgress? Function()? progress,
    String? Function()? error,
    DateTime? lastCheck,
    bool? manual,
  }) => AppUpdateState(
    phase: phase ?? this.phase,
    releases: releases ?? this.releases,
    progress: progress != null ? progress() : this.progress,
    error: error != null ? error() : this.error,
    lastCheck: lastCheck ?? this.lastCheck,
    manual: manual ?? this.manual,
  );
}

class AppUpdateController extends Notifier<AppUpdateState> {
  Timer? _timer;
  CancelToken? _cancel;

  /// Where the update is ready to be installed: the downloaded installer or
  /// AppImage, or the unpacked app folder.
  String? _ready;

  /// Overridable for tests and for the "relaunch" step.
  static Future<void> Function(int code) exitApp = (c) async => exit(c);

  String get exeDir => p.dirname(Platform.resolvedExecutable);
  InstallKind get kind => detectInstallKind(host: HostPlatform.current, exeDir: exeDir);

  @override
  AppUpdateState build() {
    final enabled = ref.watch(settingsProvider.select((s) => s.appUpdateCheck));
    final hours = ref.watch(settingsProvider.select((s) => s.appUpdateHours));
    ref.onDispose(() => _timer?.cancel());
    if (enabled && desktopIntegration) {
      // First check shortly after start, then every N hours.
      _timer = Timer(const Duration(seconds: 20), () {
        unawaited(check());
        _timer = Timer.periodic(Duration(hours: hours), (_) => unawaited(check()));
      });
    }
    if (desktopIntegration) unawaited(_cleanup());
    return const AppUpdateState();
  }

  Future<void> _cleanup() async {
    try {
      await cleanupOldFiles(exeDir);
      final dir = Directory(_updatesDir);
      if (dir.existsSync() && state.phase == UpdatePhase.idle) await dir.delete(recursive: true);
    } catch (_) {}
  }

  String get _updatesDir => p.join(ref.read(appPathsProvider).root, 'tmp', 'update');

  Future<void> check({bool manual = false}) async {
    if (const [UpdatePhase.checking, UpdatePhase.downloading, UpdatePhase.installing].contains(state.phase)) return;
    if (state.phase == UpdatePhase.ready && !manual) return;
    final s = ref.read(settingsProvider);
    state = state.copy(phase: UpdatePhase.checking, manual: manual, error: () => null);
    try {
      final resp = await http
          .get(
            // KADRA_UPDATE_API points the check at a test server.
            Uri.parse(
              Platform.environment['KADRA_UPDATE_API'] ??
                  'https://api.github.com/repos/$kReleasesRepo/releases?per_page=30',
            ),
            headers: {'User-Agent': 'Kadra/$kAppVersion', 'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) throw HttpException('HTTP ${resp.statusCode}');
      final newer = newerReleases(parseReleases(resp.body), AppVersion.current, beta: s.appChannel == AppChannel.beta);
      if (!ref.mounted) return;
      final skipped = !manual && newer.isNotEmpty && newer.first.version.toString() == s.skippedAppVersion;
      if (newer.isEmpty || skipped) {
        state = state.copy(phase: UpdatePhase.upToDate, releases: const [], lastCheck: DateTime.now());
        return;
      }
      if (_ready != null && state.update?.tag == newer.first.tag) {
        state = state.copy(phase: UpdatePhase.ready, releases: newer, lastCheck: DateTime.now());
        return;
      }
      state = state.copy(phase: UpdatePhase.available, releases: newer, lastCheck: DateTime.now());
      if (s.appUpdateAutoDownload && newer.first.asset(assetName(kind, newer.first.tag)) != null) {
        unawaited(download());
      }
    } catch (e) {
      if (ref.mounted) state = state.copy(phase: UpdatePhase.error, error: () => '$e', lastCheck: DateTime.now());
    }
  }

  /// Whether this copy can update itself (otherwise the release page is
  /// opened).
  bool get canSelfUpdate {
    final r = state.update;
    if (r == null || r.asset(assetName(kind, r.tag)) == null) return false;
    return switch (kind) {
      InstallKind.windowsInstaller => true,
      InstallKind.appImage => canWriteTo(p.dirname(Platform.environment['APPIMAGE']!)),
      _ => canWriteTo(exeDir),
    };
  }

  Future<void> download() async {
    final r = state.update;
    if (r == null || state.phase == UpdatePhase.downloading) return;
    final asset = r.asset(assetName(kind, r.tag));
    if (asset == null) return;
    final dir = p.join(_updatesDir, r.tag);
    final cancel = _cancel = CancelToken();
    state = state.copy(phase: UpdatePhase.downloading, progress: () => null, error: () => null);
    try {
      String? expected;
      final sums = r.asset(checksumsAsset);
      if (sums != null) {
        final text = await http.read(Uri.parse(sums.url), headers: {'User-Agent': 'Kadra/$kAppVersion'});
        expected = parseChecksums(text)[asset.name];
      }
      final file = p.join(dir, asset.name);
      await downloadFile(
        asset.url,
        file,
        expectedSha256: expected,
        cancel: cancel,
        userAgent: 'Kadra/$kAppVersion',
        onProgress: (pr) {
          if (ref.mounted) state = state.copy(progress: () => pr);
        },
      );
      switch (kind) {
        case InstallKind.windowsInstaller || InstallKind.appImage:
          _ready = file;
        case InstallKind.windowsPortable || InstallKind.linuxBundle:
          final staging = p.join(dir, 'unpacked');
          if (Directory(staging).existsSync()) await Directory(staging).delete(recursive: true);
          await extractArchive(file, staging, kind == InstallKind.linuxBundle ? ArchiveType.tarGz : ArchiveType.zip);
          final app = findAppDir(staging, p.basename(Platform.resolvedExecutable));
          if (app == null) throw const FormatException('app folder not found in the archive');
          _ready = app;
      }
      if (ref.mounted) state = state.copy(phase: UpdatePhase.ready, progress: () => null);
    } catch (e) {
      if (!ref.mounted) return;
      state = cancel.isCanceled
          ? state.copy(phase: UpdatePhase.available, progress: () => null)
          : state.copy(phase: UpdatePhase.error, error: () => '$e', progress: () => null);
    }
  }

  void cancelDownload() => _cancel?.cancel();

  void skip() {
    final v = state.update?.version.toString();
    if (v == null) return;
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(skippedAppVersion: () => v));
    state = state.copy(phase: UpdatePhase.upToDate, releases: const []);
  }

  /// Installs the downloaded update and restarts the app.
  Future<void> install() async {
    final ready = _ready;
    if (ready == null) return;
    state = state.copy(phase: UpdatePhase.installing, error: () => null);
    try {
      switch (kind) {
        case InstallKind.windowsInstaller:
          // The installer waits for the app to close (restart manager), then
          // relaunches it.
          await Process.start(ready, installerArgs, mode: ProcessStartMode.detached);
          await exitApp(0);
        case InstallKind.appImage:
          final target = Platform.environment['APPIMAGE']!;
          final tmp = '$target.new';
          await File(ready).copy(tmp);
          await Process.run('chmod', ['755', tmp]);
          await File(tmp).rename(target);
          await Process.start(target, const [], mode: ProcessStartMode.detached);
          await exitApp(0);
        case InstallKind.windowsPortable || InstallKind.linuxBundle:
          await replaceTree(ready, exeDir);
          await Process.start(
            Platform.resolvedExecutable,
            const [],
            workingDirectory: exeDir,
            mode: ProcessStartMode.detached,
          );
          await exitApp(0);
      }
    } catch (e) {
      if (ref.mounted) state = state.copy(phase: UpdatePhase.error, error: () => '$e');
    }
  }
}

final appUpdateProvider = NotifierProvider<AppUpdateController, AppUpdateState>(AppUpdateController.new);
