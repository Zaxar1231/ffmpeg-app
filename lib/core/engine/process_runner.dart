import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'progress.dart';

enum ProgressKind { ffmpeg, ytdlp, none }

/// What to run. External tools are always separate processes.
class ToolInvocation {
  const ToolInvocation({
    required this.executable,
    required this.args,
    this.workingDirectory,
    this.totalDuration,
    this.progress = ProgressKind.ffmpeg,
    this.environment,
  });

  final String executable;
  final List<String> args;
  final String? workingDirectory;

  /// Expected output duration, for percent/ETA.
  final Duration? totalDuration;

  /// How to read progress from stdout.
  final ProgressKind progress;
  final Map<String, String>? environment;
}

class RunResult {
  const RunResult({
    required this.exitCode,
    required this.log,
    required this.elapsed,
    this.canceled = false,
    this.startError,
  });

  final int exitCode;

  /// stderr (and non-progress stdout) lines, capped to the last N lines.
  final List<String> log;
  final Duration elapsed;
  final bool canceled;

  /// Set when the process could not be started at all (binary missing...).
  final String? startError;

  bool get success => exitCode == 0 && !canceled && startError == null;
  String get logText => log.join('\n');
}

/// A running process with progress, cancel and (on POSIX) pause.
class RunHandle {
  RunHandle._(this._process, this.invocation, int maxLogLines) : _maxLogLines = maxLogLines;

  final Process? _process;
  final ToolInvocation invocation;
  final int _maxLogLines;
  final _progress = StreamController<FfmpegProgress>.broadcast();
  final _logLines = StreamController<String>.broadcast();
  final _done = Completer<RunResult>();
  final _log = ListQueue<String>();
  final _stopwatch = Stopwatch();
  bool _canceled = false;
  bool _paused = false;

  Stream<FfmpegProgress> get progress => _progress.stream;
  Stream<String> get logLines => _logLines.stream;
  Future<RunResult> get done => _done.future;
  int? get pid => _process?.pid;
  bool get isPaused => _paused;

  /// SIGSTOP/SIGCONT work on Linux/macOS. Windows has no portable way
  /// to suspend a process without FFI, so pause is reported unsupported.
  static bool get canPause => !Platform.isWindows;

  void _addLog(String line) {
    if (line.isEmpty) return;
    _log.add(line);
    while (_log.length > _maxLogLines) {
      _log.removeFirst();
    }
    _logLines.add(line);
  }

  /// Sends text to the process (e.g. `q` to stop an ffmpeg recording cleanly).
  void writeStdin(String text) {
    try {
      _process?.stdin.write(text);
      _process?.stdin.flush();
    } catch (_) {
      // Process already gone.
    }
  }

  bool pause() {
    if (!canPause || _process == null || _paused) return false;
    _paused = Process.killPid(_process.pid, ProcessSignal.sigstop);
    if (_paused) _stopwatch.stop();
    return _paused;
  }

  bool resume() {
    if (!_paused || _process == null) return false;
    final ok = Process.killPid(_process.pid, ProcessSignal.sigcont);
    if (ok) {
      _paused = false;
      _stopwatch.start();
    }
    return ok;
  }

  /// Graceful stop: SIGINT lets ffmpeg finalize; hard kill after [grace].
  Future<void> cancel({Duration grace = const Duration(seconds: 4)}) async {
    final p = _process;
    if (p == null || _done.isCompleted) return;
    _canceled = true;
    if (_paused) resume();
    if (Platform.isWindows) {
      p.kill();
    } else {
      p.kill(ProcessSignal.sigint);
      unawaited(
        Future<void>.delayed(grace).then((_) {
          if (!_done.isCompleted) p.kill(ProcessSignal.sigkill);
        }),
      );
    }
    await done;
  }
}

class ProcessRunner {
  const ProcessRunner({this.maxLogLines = 400});

  final int maxLogLines;

  /// Starts a long-running tool. Never throws: start failures complete
  /// [RunHandle.done] with [RunResult.startError].
  Future<RunHandle> start(ToolInvocation inv) async {
    Process process;
    try {
      process = await Process.start(
        inv.executable,
        inv.args,
        workingDirectory: inv.workingDirectory,
        environment: inv.environment,
        runInShell: false,
      );
    } on ProcessException catch (e) {
      final handle = RunHandle._(null, inv, maxLogLines);
      handle._done.complete(
        RunResult(exitCode: -1, log: [e.message], elapsed: Duration.zero, startError: '${e.executable}: ${e.message}'),
      );
      unawaited(handle._progress.close());
      unawaited(handle._logLines.close());
      return handle;
    }

    final handle = RunHandle._(process, inv, maxLogLines).._stopwatch.start();
    final parser = ProgressParser(totalDuration: inv.totalDuration);

    final stdoutDone = process.stdout
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .listen((line) {
          switch (inv.progress) {
            case ProgressKind.ffmpeg:
              final snap = parser.addLine(line);
              if (snap != null) handle._progress.add(snap);
              // Progress lines are key=value; anything else is real output.
              if (!line.contains('=')) handle._addLog(line);
            case ProgressKind.ytdlp:
              final snap = parseYtdlpProgressLine(line);
              if (snap != null) {
                handle._progress.add(snap);
              } else {
                handle._addLog(line);
              }
            case ProgressKind.none:
              handle._addLog(line);
          }
        })
        .asFuture<void>();

    final stderrDone = process.stderr
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .listen((line) {
          // yt-dlp may print progress on stderr in quiet mode.
          final snap = inv.progress == ProgressKind.ytdlp ? parseYtdlpProgressLine(line) : null;
          if (snap != null) {
            handle._progress.add(snap);
          } else {
            handle._addLog(line);
          }
        })
        .asFuture<void>();

    unawaited(() async {
      final code = await process.exitCode;
      await Future.wait([stdoutDone, stderrDone]).catchError((_) => <void>[]);
      handle._stopwatch.stop();
      handle._done.complete(
        RunResult(
          exitCode: code,
          log: List.of(handle._log),
          elapsed: handle._stopwatch.elapsed,
          canceled: handle._canceled,
        ),
      );
      await handle._progress.close();
      await handle._logLines.close();
    }());

    return handle;
  }

  /// Short-lived query (version, -encoders, ffprobe...). Captures output.
  Future<CapturedResult> capture(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 60),
    String? workingDirectory,
  }) async {
    try {
      final p = await Process.start(executable, args, workingDirectory: workingDirectory);
      final out = p.stdout.transform(const Utf8Decoder(allowMalformed: true)).join();
      final err = p.stderr.transform(const Utf8Decoder(allowMalformed: true)).join();
      await p.stdin.close();
      final code = await p.exitCode.timeout(
        timeout,
        onTimeout: () {
          p.kill(ProcessSignal.sigkill);
          return -2;
        },
      );
      return CapturedResult(code, await out, await err);
    } on ProcessException catch (e) {
      return CapturedResult(-1, '', '${e.executable}: ${e.message}', startFailed: true);
    }
  }
}

class CapturedResult {
  const CapturedResult(this.exitCode, this.stdout, this.stderr, {this.startFailed = false});
  final int exitCode;
  final String stdout;
  final String stderr;
  final bool startFailed;
  bool get ok => exitCode == 0;
  bool get timedOut => exitCode == -2;
}
