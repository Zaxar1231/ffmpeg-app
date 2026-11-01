import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/app.dart';
import 'package:kadra/core/components/toolchain.dart';
import 'package:kadra/core/db/database.dart';
import 'package:kadra/core/platform/app_paths.dart';
import 'package:kadra/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the whole app with in-memory storage and walks every destination.
void main() {
  testWidgets('app starts and every section renders (ru)', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'settings.v1': '{"locale":"ru"}'});
    final prefs = await SharedPreferences.getInstance();
    final dir = Directory.systemTemp.createTempSync('kadra_smoke');
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPathsProvider.overrideWithValue(AppPaths(dir.path)),
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          // No external processes in widget tests.
          toolchainProvider.overrideWithValue(
            const Toolchain(
              ffmpeg: ToolPath.missing,
              ffprobe: ToolPath.missing,
              ytdlp: ToolPath.missing,
              deno: ToolPath.missing,
              aria2c: ToolPath.missing,
            ),
          ),
        ],
        child: const KadraApp(),
      ),
    );
    // Let real file/database I/O of the startup loaders complete.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Перетащите файл сюда'), findsOneWidget);
    expect(find.text('ffmpeg не найден'), findsOneWidget, reason: 'missing-ffmpeg banner');
    for (final label in ['Инструменты', 'Загрузки', 'Очередь', 'Пресеты', 'Компоненты', 'Настройки', 'Главная']) {
      await tester.tap(find.text(label).first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: label);
    }

    await tester.tap(find.text('Инструменты').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Проверка целостности'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'gif');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('GIF и анимации'), findsOneWidget);
    expect(find.text('Проверка целостности'), findsNothing);

    // Let pending timers (startup tasks) settle before teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
