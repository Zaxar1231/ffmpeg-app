import 'package:flutter/material.dart' show ThemeMode;

import '../components/catalog.dart';

enum AccentSource { system, custom }

enum ComponentUpdatePolicy { automatic, ask, never }

enum FfmpegSourcePref { btbn, gyan }

/// Release channel of the app itself (beta = GitHub pre-releases too).
enum AppChannel { stable, beta }

/// All user settings. Persisted as flat keys in shared_preferences.
/// Defaults live here and are the single source of truth for "Reset".
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.accentSource = AccentSource.system,
    this.accentColor = 0xFF6750A4,
    this.locale,
    this.advancedMode = false,
    this.maxParallelJobs = 1,
    this.retryCount = 0,
    this.useHwAccel = true,
    this.ffmpegThreads = 0,
    this.outputDir,
    this.outputNextToSource = false,
    this.customFfmpegPath,
    this.customFfprobePath,
    this.customYtdlpPath,
    this.ffmpegSource = FfmpegSourcePref.btbn,
    this.ffmpegLicense = FfmpegLicense.gpl,
    this.gyanFlavor = GyanFlavor.full,
    this.ffmpegChannel = UpdateChannel.stable,
    this.ytdlpChannel = UpdateChannel.stable,
    this.ffmpegUpdatePolicy = ComponentUpdatePolicy.ask,
    this.ytdlpUpdatePolicy = ComponentUpdatePolicy.automatic,
    this.otherUpdatePolicy = ComponentUpdatePolicy.ask,
    this.keepPreviousVersions = 2,
    this.ytdlpConcurrentFragments = 4,
    this.ytdlpUseAria2 = false,
    this.notifyOnFinish = true,
    this.showCommandBeforeRun = false,
    this.appUpdateCheck = true,
    this.appChannel = AppChannel.stable,
    this.appUpdateHours = 12,
    this.appUpdateAutoDownload = true,
    this.skippedAppVersion,
    this.closeToTray = true,
    this.preventSleep = true,
  });

  final ThemeMode themeMode;
  final AccentSource accentSource;
  final int accentColor;

  /// null → follow system locale (ru if available, else en).
  final String? locale;
  final bool advancedMode;

  final int maxParallelJobs;
  final int retryCount;
  final bool useHwAccel;

  /// `-threads` for ffmpeg; 0 = automatic.
  final int ffmpegThreads;

  final String? outputDir;

  /// Save results next to the source file instead of [outputDir].
  final bool outputNextToSource;
  final String? customFfmpegPath;
  final String? customFfprobePath;
  final String? customYtdlpPath;

  final FfmpegSourcePref ffmpegSource;
  final FfmpegLicense ffmpegLicense;
  final GyanFlavor gyanFlavor;
  final UpdateChannel ffmpegChannel;
  final UpdateChannel ytdlpChannel;
  final ComponentUpdatePolicy ffmpegUpdatePolicy;
  final ComponentUpdatePolicy ytdlpUpdatePolicy;
  final ComponentUpdatePolicy otherUpdatePolicy;
  final int keepPreviousVersions;

  final int ytdlpConcurrentFragments;

  /// Use aria2c as yt-dlp's external downloader when available.
  final bool ytdlpUseAria2;
  final bool notifyOnFinish;
  final bool showCommandBeforeRun;

  /// Check GitHub Releases for a new version of the app.
  final bool appUpdateCheck;
  final AppChannel appChannel;

  /// Hours between update checks while the app is running.
  final int appUpdateHours;

  /// Download an update in the background as soon as it is found.
  final bool appUpdateAutoDownload;

  /// Version the user chose to skip (no reminder for it).
  final String? skippedAppVersion;

  /// Closing the window hides it to the tray while jobs are running.
  final bool closeToTray;

  /// Keep the computer awake while jobs are running.
  final bool preventSleep;

  ComponentUpdatePolicy policyFor(ComponentId id) => switch (id) {
    ComponentId.ffmpeg => ffmpegUpdatePolicy,
    ComponentId.ytdlp => ytdlpUpdatePolicy,
    _ => otherUpdatePolicy,
  };

  AppSettings copyWith({
    ThemeMode? themeMode,
    AccentSource? accentSource,
    int? accentColor,
    String? Function()? locale,
    bool? advancedMode,
    int? maxParallelJobs,
    int? retryCount,
    bool? useHwAccel,
    int? ffmpegThreads,
    String? Function()? outputDir,
    bool? outputNextToSource,
    String? Function()? customFfmpegPath,
    String? Function()? customFfprobePath,
    String? Function()? customYtdlpPath,
    FfmpegSourcePref? ffmpegSource,
    FfmpegLicense? ffmpegLicense,
    GyanFlavor? gyanFlavor,
    UpdateChannel? ffmpegChannel,
    UpdateChannel? ytdlpChannel,
    ComponentUpdatePolicy? ffmpegUpdatePolicy,
    ComponentUpdatePolicy? ytdlpUpdatePolicy,
    ComponentUpdatePolicy? otherUpdatePolicy,
    int? keepPreviousVersions,
    int? ytdlpConcurrentFragments,
    bool? ytdlpUseAria2,
    bool? notifyOnFinish,
    bool? showCommandBeforeRun,
    bool? appUpdateCheck,
    AppChannel? appChannel,
    int? appUpdateHours,
    bool? appUpdateAutoDownload,
    String? Function()? skippedAppVersion,
    bool? closeToTray,
    bool? preventSleep,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    accentSource: accentSource ?? this.accentSource,
    accentColor: accentColor ?? this.accentColor,
    locale: locale != null ? locale() : this.locale,
    advancedMode: advancedMode ?? this.advancedMode,
    maxParallelJobs: maxParallelJobs ?? this.maxParallelJobs,
    retryCount: retryCount ?? this.retryCount,
    useHwAccel: useHwAccel ?? this.useHwAccel,
    ffmpegThreads: ffmpegThreads ?? this.ffmpegThreads,
    outputDir: outputDir != null ? outputDir() : this.outputDir,
    outputNextToSource: outputNextToSource ?? this.outputNextToSource,
    customFfmpegPath: customFfmpegPath != null ? customFfmpegPath() : this.customFfmpegPath,
    customFfprobePath: customFfprobePath != null ? customFfprobePath() : this.customFfprobePath,
    customYtdlpPath: customYtdlpPath != null ? customYtdlpPath() : this.customYtdlpPath,
    ffmpegSource: ffmpegSource ?? this.ffmpegSource,
    ffmpegLicense: ffmpegLicense ?? this.ffmpegLicense,
    gyanFlavor: gyanFlavor ?? this.gyanFlavor,
    ffmpegChannel: ffmpegChannel ?? this.ffmpegChannel,
    ytdlpChannel: ytdlpChannel ?? this.ytdlpChannel,
    ffmpegUpdatePolicy: ffmpegUpdatePolicy ?? this.ffmpegUpdatePolicy,
    ytdlpUpdatePolicy: ytdlpUpdatePolicy ?? this.ytdlpUpdatePolicy,
    otherUpdatePolicy: otherUpdatePolicy ?? this.otherUpdatePolicy,
    keepPreviousVersions: keepPreviousVersions ?? this.keepPreviousVersions,
    ytdlpConcurrentFragments: ytdlpConcurrentFragments ?? this.ytdlpConcurrentFragments,
    ytdlpUseAria2: ytdlpUseAria2 ?? this.ytdlpUseAria2,
    notifyOnFinish: notifyOnFinish ?? this.notifyOnFinish,
    showCommandBeforeRun: showCommandBeforeRun ?? this.showCommandBeforeRun,
    appUpdateCheck: appUpdateCheck ?? this.appUpdateCheck,
    appChannel: appChannel ?? this.appChannel,
    appUpdateHours: appUpdateHours ?? this.appUpdateHours,
    appUpdateAutoDownload: appUpdateAutoDownload ?? this.appUpdateAutoDownload,
    skippedAppVersion: skippedAppVersion != null ? skippedAppVersion() : this.skippedAppVersion,
    closeToTray: closeToTray ?? this.closeToTray,
    preventSleep: preventSleep ?? this.preventSleep,
  );

  Map<String, Object?> toMap() => {
    'themeMode': themeMode.name,
    'accentSource': accentSource.name,
    'accentColor': accentColor,
    'locale': locale,
    'advancedMode': advancedMode,
    'maxParallelJobs': maxParallelJobs,
    'retryCount': retryCount,
    'useHwAccel': useHwAccel,
    'ffmpegThreads': ffmpegThreads,
    'outputDir': outputDir,
    'outputNextToSource': outputNextToSource,
    'customFfmpegPath': customFfmpegPath,
    'customFfprobePath': customFfprobePath,
    'customYtdlpPath': customYtdlpPath,
    'ffmpegSource': ffmpegSource.name,
    'ffmpegLicense': ffmpegLicense.name,
    'gyanFlavor': gyanFlavor.name,
    'ffmpegChannel': ffmpegChannel.name,
    'ytdlpChannel': ytdlpChannel.name,
    'ffmpegUpdatePolicy': ffmpegUpdatePolicy.name,
    'ytdlpUpdatePolicy': ytdlpUpdatePolicy.name,
    'otherUpdatePolicy': otherUpdatePolicy.name,
    'keepPreviousVersions': keepPreviousVersions,
    'ytdlpConcurrentFragments': ytdlpConcurrentFragments,
    'ytdlpUseAria2': ytdlpUseAria2,
    'notifyOnFinish': notifyOnFinish,
    'showCommandBeforeRun': showCommandBeforeRun,
    'appUpdateCheck': appUpdateCheck,
    'appChannel': appChannel.name,
    'appUpdateHours': appUpdateHours,
    'appUpdateAutoDownload': appUpdateAutoDownload,
    'skippedAppVersion': skippedAppVersion,
    'closeToTray': closeToTray,
    'preventSleep': preventSleep,
  };

  /// Tolerant: unknown/invalid values fall back to defaults.
  factory AppSettings.fromMap(Map<String, Object?> m) {
    const d = AppSettings();
    T e<T extends Enum>(List<T> values, Object? v, T def) => values.where((x) => x.name == v).firstOrNull ?? def;
    int i(Object? v, int def, {int min = -1 << 31, int max = 1 << 31}) => v is int ? v.clamp(min, max) : def;
    bool b(Object? v, bool def) => v is bool ? v : def;
    String? s(Object? v) => v is String && v.isNotEmpty ? v : null;
    return AppSettings(
      themeMode: e(ThemeMode.values, m['themeMode'], d.themeMode),
      accentSource: e(AccentSource.values, m['accentSource'], d.accentSource),
      accentColor: i(m['accentColor'], d.accentColor, min: 0, max: 0xFFFFFFFF),
      locale: s(m['locale']),
      advancedMode: b(m['advancedMode'], d.advancedMode),
      maxParallelJobs: i(m['maxParallelJobs'], d.maxParallelJobs, min: 1, max: 16),
      retryCount: i(m['retryCount'], d.retryCount, min: 0, max: 5),
      useHwAccel: b(m['useHwAccel'], d.useHwAccel),
      ffmpegThreads: i(m['ffmpegThreads'], d.ffmpegThreads, min: 0, max: 128),
      outputDir: s(m['outputDir']),
      outputNextToSource: b(m['outputNextToSource'], d.outputNextToSource),
      customFfmpegPath: s(m['customFfmpegPath']),
      customFfprobePath: s(m['customFfprobePath']),
      customYtdlpPath: s(m['customYtdlpPath']),
      ffmpegSource: e(FfmpegSourcePref.values, m['ffmpegSource'], d.ffmpegSource),
      ffmpegLicense: e(FfmpegLicense.values, m['ffmpegLicense'], d.ffmpegLicense),
      gyanFlavor: e(GyanFlavor.values, m['gyanFlavor'], d.gyanFlavor),
      ffmpegChannel: e(UpdateChannel.values, m['ffmpegChannel'], d.ffmpegChannel),
      ytdlpChannel: e(UpdateChannel.values, m['ytdlpChannel'], d.ytdlpChannel),
      ffmpegUpdatePolicy: e(ComponentUpdatePolicy.values, m['ffmpegUpdatePolicy'], d.ffmpegUpdatePolicy),
      ytdlpUpdatePolicy: e(ComponentUpdatePolicy.values, m['ytdlpUpdatePolicy'], d.ytdlpUpdatePolicy),
      otherUpdatePolicy: e(ComponentUpdatePolicy.values, m['otherUpdatePolicy'], d.otherUpdatePolicy),
      keepPreviousVersions: i(m['keepPreviousVersions'], d.keepPreviousVersions, min: 0, max: 5),
      ytdlpConcurrentFragments: i(m['ytdlpConcurrentFragments'], d.ytdlpConcurrentFragments, min: 1, max: 32),
      notifyOnFinish: b(m['notifyOnFinish'], d.notifyOnFinish),
      ytdlpUseAria2: b(m['ytdlpUseAria2'], d.ytdlpUseAria2),
      showCommandBeforeRun: b(m['showCommandBeforeRun'], d.showCommandBeforeRun),
      appUpdateCheck: b(m['appUpdateCheck'], d.appUpdateCheck),
      appChannel: e(AppChannel.values, m['appChannel'], d.appChannel),
      appUpdateHours: i(m['appUpdateHours'], d.appUpdateHours, min: 1, max: 168),
      appUpdateAutoDownload: b(m['appUpdateAutoDownload'], d.appUpdateAutoDownload),
      skippedAppVersion: s(m['skippedAppVersion']),
      closeToTray: b(m['closeToTray'], d.closeToTray),
      preventSleep: b(m['preventSleep'], d.preventSleep),
    );
  }
}
