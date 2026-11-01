import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/components_controller.dart';
import 'components/toolchain.dart';
import 'db/database.dart';
import 'engine/capabilities.dart';
import 'engine/hwaccel.dart';
import 'engine/process_runner.dart';
import 'platform/app_paths.dart';
import 'probe/probe_service.dart';
import 'queue/queue_controller.dart';
import 'settings/app_settings.dart';

/// Overridden in main() after async initialization.
final appPathsProvider = Provider<AppPaths>((ref) => throw UnimplementedError('appPathsProvider'));
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('sharedPrefsProvider'));
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider'));

final processRunnerProvider = Provider<ProcessRunner>((ref) => const ProcessRunner());

class SettingsController extends Notifier<AppSettings> {
  static const _key = 'settings.v1';

  @override
  AppSettings build() {
    final raw = ref.watch(sharedPrefsProvider).getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromMap((jsonDecode(raw) as Map).cast<String, Object?>());
    } catch (_) {
      return const AppSettings();
    }
  }

  void update(AppSettings Function(AppSettings) f) {
    state = f(state);
    ref.read(sharedPrefsProvider).setString(_key, jsonEncode(state.toMap()));
  }

  void reset() => update((_) => const AppSettings());
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

final componentsProvider = NotifierProvider<ComponentsController, ComponentsState>(ComponentsController.new);

final toolchainProvider = Provider<Toolchain>((ref) {
  final settings = ref.watch(settingsProvider);
  final records = ref.watch(componentsProvider.select((s) => s.records));
  return Toolchain.resolve(
    settings: settings,
    records: records,
    componentsRoot: ref.watch(appPathsProvider).components,
  );
});

final probeServiceProvider = Provider<ProbeService?>((ref) {
  final path = ref.watch(toolchainProvider.select((t) => t.ffprobe.path));
  if (path == null) return null;
  return ProbeService(runner: ref.watch(processRunnerProvider), ffprobePath: path);
});

/// Everything the active ffmpeg build supports. Re-evaluated when the
/// ffmpeg binary changes (install, update, rollback, custom path).
final capabilitiesProvider = FutureProvider<FfmpegCapabilities>((ref) async {
  final ffmpeg = ref.watch(toolchainProvider.select((t) => t.ffmpeg.path));
  if (ffmpeg == null) return FfmpegCapabilities.empty;
  final runner = ref.watch(processRunnerProvider);
  Future<String> q(String flag) async => (await runner.capture(ffmpeg, ['-hide_banner', flag])).stdout;
  final results = await Future.wait([
    runner.capture(ffmpeg, ['-version']).then((r) => r.stdout),
    q('-encoders'),
    q('-decoders'),
    q('-filters'),
    q('-muxers'),
    q('-hwaccels'),
  ]);
  final v = parseVersionOutput(results[0]);
  return FfmpegCapabilities(
    version: v.version,
    configuration: v.configuration,
    encoders: parseCodecList(results[1]),
    decoders: parseCodecList(results[2]),
    filters: parseFilterList(results[3]),
    muxers: parseMuxerList(results[4]),
    hwaccels: parseHwaccels(results[5]),
  );
});

/// Hardware acceleration report. Cached per ffmpeg binary (trial encodes
/// take a few seconds); `ref.read(hwAccelProvider.notifier).redetect()`
/// forces a new run.
class HwAccelController extends AsyncNotifier<HwAccelReport> {
  @override
  Future<HwAccelReport> build() async {
    final ffmpeg = ref.watch(toolchainProvider.select((t) => t.ffmpeg.path));
    if (ffmpeg == null) return HwAccelReport.none;
    final caps = await ref.watch(capabilitiesProvider.future);
    final cacheFile = File(ref.read(appPathsProvider).hwCache);
    final cacheKey = '$ffmpeg|${caps.version}';
    try {
      if (await cacheFile.exists()) {
        final j = (jsonDecode(await cacheFile.readAsString()) as Map).cast<String, Object?>();
        if (j['key'] == cacheKey) {
          return HwAccelReport.fromJson((j['report'] as Map).cast<String, Object?>());
        }
      }
    } catch (_) {}
    return _detect(ffmpeg, caps, cacheFile, cacheKey);
  }

  Future<HwAccelReport> _detect(String ffmpeg, FfmpegCapabilities caps, File cacheFile, String key) async {
    final report = await detectHwAccel(runner: ref.read(processRunnerProvider), ffmpegPath: ffmpeg, caps: caps);
    await cacheFile.writeAsString(jsonEncode({'key': key, 'report': report.toJson()}));
    return report;
  }

  Future<void> redetect() async {
    final cacheFile = File(ref.read(appPathsProvider).hwCache);
    if (await cacheFile.exists()) await cacheFile.delete();
    ref.invalidateSelf();
  }
}

final hwAccelProvider = AsyncNotifierProvider<HwAccelController, HwAccelReport>(HwAccelController.new);

final queueProvider = NotifierProvider<QueueController, QueueState>(QueueController.new);
