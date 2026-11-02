/// Desktop integration (stage 6): system notifications and keeping the
/// computer awake; the tray and close handling are in
/// `features/shell/desktop_integration.dart`.
library;

import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:flutter/material.dart' show Size;
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart' as wm;

/// Set in `main()`; widget tests run without native windows, tray or timers.
bool desktopIntegration = false;

Future<void> initDesktop() async {
  desktopIntegration = true;
  try {
    await localNotifier.setup(appName: 'Kadra', shortcutPolicy: ShortcutPolicy.requireCreate);
  } catch (_) {}
  try {
    wm.WindowManager.instance.getCurrent()?.minimumSize = const Size(480, 560).toNative();
  } catch (_) {}
}

/// Whether a tray icon will actually be shown. Linux needs a
/// StatusNotifierItem host (KDE, most panels; GNOME only with the
/// AppIndicator extension); without one, hiding the window would lose it.
Future<bool> trayHostAvailable() async {
  if (!Platform.isLinux) return true;
  try {
    final r = await Process.run('gdbus', [
      'call', '--session', '--dest', 'org.freedesktop.DBus', '--object-path', '/org/freedesktop/DBus', //
      '--method', 'org.freedesktop.DBus.NameHasOwner', 'org.kde.StatusNotifierWatcher',
    ]);
    return r.exitCode == 0 && '${r.stdout}'.contains('true');
  } catch (_) {
    return false;
  }
}

Future<void> showSystemNotification(String title, String body) async {
  if (!desktopIntegration) return;
  try {
    await LocalNotification(title: title, body: body).show();
  } catch (_) {}
}

/// Keeps the computer from sleeping while held. Windows:
/// `SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED)`; Linux:
/// `systemd-inhibit` around a process that ends together with the app.
class SleepInhibitor {
  bool _held = false;
  Process? _linux;

  static const _esContinuous = 0x80000000;
  static const _esSystemRequired = 0x00000001;

  void set(bool on, {String why = 'Kadra'}) {
    if (on == _held) return;
    _held = on;
    if (Platform.isWindows) {
      try {
        final f = ffi.DynamicLibrary.open('kernel32.dll')
            .lookupFunction<ffi.Uint32 Function(ffi.Uint32), int Function(int)>('SetThreadExecutionState');
        f(on ? _esContinuous | _esSystemRequired : _esContinuous);
      } catch (_) {}
    } else if (Platform.isLinux) {
      if (on) {
        unawaited(() async {
          try {
            final p = await Process.start('systemd-inhibit', [
              '--what=sleep:idle',
              '--who=Kadra',
              '--why=$why',
              '--mode=block',
              // Ends by itself if the app is killed.
              'tail', '--pid=$pid', '-f', '/dev/null',
            ]);
            if (_held) {
              _linux = p;
            } else {
              p.kill();
            }
          } catch (_) {}
        }());
      } else {
        _linux?.kill();
        _linux = null;
      }
    }
  }
}
