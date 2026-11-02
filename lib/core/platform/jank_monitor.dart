/// Records UI freezes to `logs/jank.log`: frames that took longer than
/// [frameLimit] to build or draw, and stalls of the UI thread longer than
/// [stallLimit] (a heartbeat timer that fires late). Each line names the
/// screen that was open, so a report says where the app hangs.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:path/path.dart' as p;

class JankMonitor {
  JankMonitor._(this.file);

  static JankMonitor? instance;

  final File file;

  /// What is on screen (set by the shell): page and tool.
  static String where = 'start';

  static const frameLimit = Duration(milliseconds: 250);
  static const stallLimit = Duration(seconds: 1);
  static const _beat = Duration(milliseconds: 200);
  static const _maxBytes = 512 * 1024;

  int events = 0;
  final _pending = <String>[];
  Timer? _flush;

  static void start(String logsDir) {
    final m = JankMonitor._(File(p.join(logsDir, 'jank.log')));
    instance = m;
    try {
      // Keep the log small: start over when it grows too big.
      if (m.file.existsSync() && m.file.lengthSync() > _maxBytes) m.file.deleteSync();
    } catch (_) {}
    SchedulerBinding.instance.addTimingsCallback(m._onTimings);
    var last = DateTime.now();
    Timer.periodic(_beat, (_) {
      final now = DateTime.now();
      final late = now.difference(last) - _beat;
      last = now;
      if (late > stallLimit) m._add('stall ${late.inMilliseconds} ms');
    });
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      if (t.buildDuration > frameLimit || t.rasterDuration > frameLimit) {
        _add('slow frame: build ${t.buildDuration.inMilliseconds} ms, draw ${t.rasterDuration.inMilliseconds} ms');
      }
    }
  }

  void _add(String what) {
    events++;
    _pending.add('${DateTime.now().toIso8601String()}  [$where]  $what');
    _flush ??= Timer(const Duration(seconds: 2), () {
      _flush = null;
      final lines = _pending.join('\n');
      _pending.clear();
      file.parent
          .create(recursive: true)
          .then((_) => file.writeAsString('$lines\n', mode: FileMode.append))
          .catchError((Object _) => file);
    });
  }
}
