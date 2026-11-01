import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/settings/app_settings.dart';
import 'features/home/current_file.dart';
import 'features/shell/app_shell.dart';
import 'ui/l10n.dart';
import 'ui/theme.dart';

class KadraApp extends ConsumerStatefulWidget {
  const KadraApp({super.key, this.initialFile});

  /// File passed on the command line; opened once at startup.
  final String? initialFile;

  @override
  ConsumerState<KadraApp> createState() => _KadraAppState();
}

class _KadraAppState extends ConsumerState<KadraApp> {
  @override
  void initState() {
    super.initState();
    final f = widget.initialFile;
    if (f != null) {
      // Wait for the component state so the right ffprobe is used.
      ref.listenManual(componentsProvider.select((s) => s.loaded), (_, loaded) {
        if (loaded) ref.read(currentFileProvider.notifier).open(f);
      }, fireImmediately: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // dynamic_color returns its own ColorScheme type (package:material_ui),
        // so only the system accent is taken and the MD3 scheme is built from it.
        // On Windows the system only provides an accent color anyway.
        final systemAccent = settings.accentSource == AccentSource.system ? lightDynamic?.primary : null;
        final seed = systemAccent ?? Color(settings.accentColor);
        return MaterialApp(
          onGenerateTitle: (ctx) => ctx.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: buildTheme(seed, Brightness.light),
          darkTheme: buildTheme(seed, Brightness.dark),
          locale: settings.locale == null ? null : Locale(settings.locale!),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Russian is the primary language; English for everyone else.
          localeResolutionCallback: (locale, supported) {
            if (locale != null && supported.any((l) => l.languageCode == locale.languageCode)) {
              return Locale(locale.languageCode);
            }
            return const Locale('en');
          },
          home: const AppShell(),
        );
      },
    );
  }
}
