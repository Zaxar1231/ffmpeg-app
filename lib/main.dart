import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/db/database.dart';
import 'core/platform/app_paths.dart';
import 'core/platform/desktop.dart';
import 'core/platform/jank_monitor.dart';
import 'core/providers.dart';

/// `kadra <file>` opens the file on the Home screen ("Open with…").
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await initDesktop();
  final paths = await AppPaths.resolve();
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase.open(paths.database);
  JankMonitor.start(paths.logs);
  runApp(
    ProviderScope(
      overrides: [
        appPathsProvider.overrideWithValue(paths),
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: KadraApp(initialFile: args.where((a) => !a.startsWith('-')).firstOrNull),
    ),
  );
}
