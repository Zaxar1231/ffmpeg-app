/// Tray icon, closing to the tray while jobs run, a notification when the
/// queue finishes, and keeping the computer awake during work.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart' as tray;
import 'package:window_manager/window_manager.dart' as wm;

import '../../core/platform/desktop.dart';
import '../../core/providers.dart';
import '../../core/queue/queue_controller.dart';
import '../../core/queue/queue_models.dart';
import '../../ui/l10n.dart';
import '../capture/capture_controller.dart';
import 'app_shell.dart';

/// Wraps the app shell: tray, close handling, notifications, sleep.
class DesktopIntegration extends ConsumerStatefulWidget {
  const DesktopIntegration({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<DesktopIntegration> createState() => _DesktopIntegrationState();
}

class _DesktopIntegrationState extends ConsumerState<DesktopIntegration> {
  final _sleep = SleepInhibitor();
  wm.Window? _window;
  tray.TrayIcon? _tray;
  tray.MenuItem? _status;
  bool _allowClose = false;

  /// The tray icon is really visible (see [trayHostAvailable]).
  bool _trayHost = false;
  bool _hiddenNoticeShown = false;
  String? _trayText;

  /// Jobs finished since the queue last became busy.
  int _done = 0, _failed = 0;
  String? _lastTitle;

  @override
  void initState() {
    super.initState();
    if (!desktopIntegration) return;
    try {
      _window = wm.WindowManager.instance.getCurrent();
      _window?.addListener(_onWindowEvent);
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTray());
  }

  @override
  void dispose() {
    _sleep.set(false);
    _tray?.dispose();
    super.dispose();
  }

  bool get _busy => ref.read(queueProvider).activeCount > 0 || ref.read(liveProvider).running;

  void _onWindowEvent(wm.WindowEvent e) {
    if (e is! wm.WindowCloseRequestedEvent || _allowClose || !_busy) return;
    e.request.cancel();
    if (ref.read(settingsProvider).closeToTray && _tray != null && _trayHost) {
      _window?.hide();
      if (!_hiddenNoticeShown) {
        _hiddenNoticeShown = true;
        final l = context.l10n;
        unawaited(showSystemNotification(l.appTitle, l.hiddenToTray));
      }
    } else {
      unawaited(_confirmQuit());
    }
  }

  void _showWindow() {
    _window?.show();
    _window?.focus();
  }

  Future<void> _confirmQuit() async {
    _showWindow();
    final l = context.l10n;
    final n = ref.read(queueProvider).activeCount + (ref.read(liveProvider).running ? 1 : 0);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.quitBusyTitle),
        content: Text(l.quitBusyBody(n)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.quitAnyway)),
        ],
      ),
    );
    if (ok == true) await quit();
  }

  /// Stops running work (so no ffmpeg is left behind) and closes the app.
  Future<void> quit() async {
    final q = ref.read(queueProvider.notifier);
    await Future.wait([
      for (final i in ref.read(queueProvider).items)
        if (i.isActive) q.cancel(i.id),
      if (ref.read(liveProvider).running) ref.read(liveProvider.notifier).stop(),
    ]);
    _sleep.set(false);
    _allowClose = true;
    _tray?.dispose();
    _tray = null;
    if (_window != null) {
      _window!.close();
    } else {
      exit(0);
    }
  }

  void _syncTray() {
    if (!desktopIntegration || !mounted) return;
    final want = ref.read(settingsProvider).closeToTray;
    try {
      if (want && _tray == null) {
        final l = context.l10n;
        final t = tray.TrayIcon.create();
        final menu = tray.Menu.create();
        if (t == null || menu == null) return;
        t.icon = tray.ImageAsset.fromAsset('assets/icons/tray.png');
        t.setTooltip(l.appTitle);
        tray.MenuItem? item(String label, void Function() onClick) {
          final i = tray.MenuItem.createWithLabelAndType(label, tray.MenuItemType.normal);
          if (i == null) return null;
          i.addListener((ev) {
            if (ev is tray.MenuItemClickedEvent) onClick();
          });
          menu.addItem(i);
          return i;
        }

        item(l.trayOpen, _showWindow);
        _status = item(l.trayIdle, _openQueue);
        menu.addSeparator();
        item(l.trayQuit, () => unawaited(_busy ? _confirmQuit() : quit()));
        t.setContextMenu(menu);
        t.setContextMenuTrigger(tray.ContextMenuTrigger.rightClicked);
        t.addListener((ev) {
          if (ev is tray.TrayIconClickedEvent || ev is tray.TrayIconDoubleClickedEvent) _showWindow();
        });
        _tray = t;
        unawaited(trayHostAvailable().then((v) => _trayHost = v));
      } else if (!want && _tray != null) {
        _tray!.dispose();
        _tray = null;
      }
    } catch (_) {
      _tray = null;
    }
  }

  void _openQueue() {
    _showWindow();
    ref.read(navProvider.notifier).go(Destination.queue);
  }

  void _onQueue(QueueState? prev, QueueState next) {
    final before = {for (final i in prev?.items ?? const <QueueItem>[]) i.id: i.status};
    for (final i in next.items) {
      final was = before[i.id];
      if (was == null || was == i.status) continue;
      if (was == JobStatus.running || was == JobStatus.paused || was == JobStatus.queued) {
        if (i.status == JobStatus.completed) {
          _done++;
          _lastTitle = i.job.title;
        } else if (i.status == JobStatus.failed) {
          _failed++;
          _lastTitle = i.job.title;
        }
      }
    }
    final busy = next.activeCount + next.pendingCount > 0;
    final wasBusy = prev != null && prev.activeCount + prev.pendingCount > 0;
    // The panel may have changed since start (e.g. an extension enabled).
    if (busy && !wasBusy && _tray != null) unawaited(trayHostAvailable().then((v) => _trayHost = v));
    _sleep.set(ref.read(settingsProvider).preventSleep && (busy || ref.read(liveProvider).running));
    _updateTrayStatus(next);
    if (!busy && (_done + _failed) > 0) {
      final done = _done, failed = _failed, title = _lastTitle;
      _done = _failed = 0;
      unawaited(_notifyFinished(done, failed, title));
    }
  }

  void _updateTrayStatus(QueueState q) {
    final s = _status;
    if (s == null || !mounted) return;
    final l = context.l10n;
    final active = q.items.where((i) => i.isActive).toList();
    String text;
    if (active.isEmpty && q.pendingCount == 0) {
      text = l.trayIdle;
    } else {
      final fr = [for (final i in active) i.progress?.fraction ?? 0.0];
      final pct = fr.isEmpty ? 0 : (fr.reduce((a, b) => a + b) / fr.length * 100).round();
      text = l.trayBusy(active.length + q.pendingCount, pct);
    }
    if (text == _trayText) return;
    _trayText = text;
    try {
      s.label = text;
      _tray?.setTooltip('${l.appTitle} — $text');
    } catch (_) {}
  }

  Future<void> _notifyFinished(int done, int failed, String? title) async {
    if (!mounted || !ref.read(settingsProvider).notifyOnFinish) return;
    // No pop-up while the user is looking at the app.
    try {
      final w = _window;
      if (w != null && w.isVisible && w.isFocused) return;
    } catch (_) {}
    final l = context.l10n;
    final total = done + failed;
    final body = total == 1 && title != null
        ? (failed == 0 ? l.notifyOneDone(title) : l.notifyOneFailed(title))
        : (failed == 0 ? l.notifyManyDone(total) : l.notifyManyFailed(total, failed));
    await showSystemNotification(l.appTitle, body);
  }

  @override
  Widget build(BuildContext context) {
    if (desktopIntegration) {
      ref.listen(queueProvider, _onQueue);
      ref.listen(liveProvider.select((s) => s.running), (_, running) {
        _sleep.set(ref.read(settingsProvider).preventSleep && (running || ref.read(queueProvider).activeCount > 0));
      });
      ref.listen(settingsProvider.select((s) => s.closeToTray), (_, _) => _syncTray());
      ref.listen(settingsProvider.select((s) => s.preventSleep), (_, on) {
        if (!on) _sleep.set(false);
      });
    }
    return widget.child;
  }
}
