import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../engine/error_translator.dart';
import '../engine/process_runner.dart';
import '../engine/progress.dart';
import '../providers.dart';
import 'queue_models.dart';

class QueueState {
  const QueueState({this.items = const [], this.loaded = false});
  final List<QueueItem> items;
  final bool loaded;

  int get activeCount => items.where((i) => i.isActive).length;
  int get pendingCount => items.where((i) => i.status == JobStatus.queued).length;
  QueueItem? byId(String id) => items.where((i) => i.id == id).firstOrNull;
}

/// Persistent job queue with configurable parallelism, priorities and retries.
class QueueController extends Notifier<QueueState> {
  final _handles = <String, RunHandle>{};
  final _starting = <String>{};
  final _lastUiUpdate = <String, int>{};

  AppDatabase get _db => ref.read(databaseProvider);

  @override
  QueueState build() {
    // Re-schedule when parallelism changes.
    ref.listen(settingsProvider.select((s) => s.maxParallelJobs), (_, _) => _schedule());
    ref.onDispose(() {
      for (final h in _handles.values) {
        h.cancel();
      }
    });
    Future.microtask(_load);
    return const QueueState();
  }

  Future<void> _load() async {
    await _db.recoverInterrupted();
    final jobs = await _db.allJobs();
    if (!ref.mounted) return;
    state = QueueState(items: [for (final j in jobs) QueueItem(job: j)], loaded: true);
    _schedule();
  }

  Future<String> enqueue(JobRequest r) async {
    final id = const Uuid().v4();
    final job = Job(
      id: id,
      kind: r.kind,
      title: r.title,
      tool: r.tool.name,
      argsJson: jsonEncode(r.args),
      inputPath: r.inputPath,
      outputPath: r.outputPath,
      durationUs: r.totalDuration?.inMicroseconds,
      status: JobStatus.queued.name,
      priority: r.priority,
      attempts: 0,
      maxRetries: r.maxRetries ?? ref.read(settingsProvider).retryCount,
      createdAt: DateTime.now(),
      extraJson: r.logIsResult ? jsonEncode({'logIsResult': true}) : null,
    );
    await _db.upsertJob(job.toCompanion(true));
    state = QueueState(
      items: [
        ...state.items,
        QueueItem(job: job),
      ],
      loaded: state.loaded,
    );
    _schedule();
    return id;
  }

  void _replace(String id, QueueItem Function(QueueItem) f) {
    state = QueueState(items: [for (final i in state.items) i.id == id ? f(i) : i], loaded: state.loaded);
  }

  Future<void> _saveJob(Job job) async {
    _replace(job.id, (i) => i.copyWith(job: job));
    await _db.upsertJob(job.toCompanion(true));
  }

  void _schedule() {
    if (!state.loaded) return;
    final max = ref.read(settingsProvider).maxParallelJobs;
    while (state.activeCount + _starting.length < max) {
      final next = pickNext(state.items.where((i) => !_starting.contains(i.id)));
      if (next == null) return;
      _starting.add(next.id);
      unawaited(
        _run(next).whenComplete(() {
          _starting.remove(next.id);
          if (ref.mounted) _schedule();
        }),
      );
    }
  }

  String? _executableFor(JobTool tool) {
    final tc = ref.read(toolchainProvider);
    return switch (tool) {
      JobTool.ffmpeg => tc.ffmpeg.path,
      JobTool.ffprobe => tc.ffprobe.path,
      JobTool.ytdlp => tc.ytdlp.path,
    };
  }

  Future<void> _run(QueueItem item) async {
    var job = item.job.copyWith(
      status: JobStatus.running.name,
      attempts: item.job.attempts + 1,
      startedAt: Value(DateTime.now()),
      finishedAt: const Value(null),
      errorKind: const Value(null),
      errorDetail: const Value(null),
    );
    await _saveJob(job);
    _replace(job.id, (i) => i.copyWith(progress: () => null, attemptLog: const []));

    final exe = _executableFor(item.tool);
    if (exe == null) {
      await _finish(job, JobStatus.failed, error: const ToolError(ToolErrorKind.toolMissing), log: const []);
      return;
    }
    final out = job.outputPath;
    if (out != null) {
      await Directory(File(out).parent.path).create(recursive: true);
    }

    final handle = await ref
        .read(processRunnerProvider)
        .start(
          ToolInvocation(
            executable: exe,
            args: item.args,
            totalDuration: item.totalDuration,
            parseFfmpegProgress: item.tool == JobTool.ffmpeg,
          ),
        );
    _handles[job.id] = handle;
    final progressSub = handle.progress.listen((p) => _onProgress(job.id, p));
    final logSub = handle.logLines.listen((l) {
      final cur = state.byId(job.id);
      if (cur == null) return;
      final log = [...cur.attemptLog, l];
      _replace(job.id, (i) => i.copyWith(attemptLog: log.length > 200 ? log.sublist(log.length - 200) : log));
    });
    final result = await handle.done;
    await progressSub.cancel();
    await logSub.cancel();
    _handles.remove(job.id);
    if (!ref.mounted) return;

    // Status may have changed (e.g. canceled) while running.
    job = state.byId(job.id)?.job ?? job;
    final logIsResult = (QueueItem(job: job).extra['logIsResult'] as bool?) ?? false;

    if (result.canceled) {
      await _deletePartial(out);
      await _finish(job, JobStatus.canceled, log: result.log);
    } else if (result.success) {
      int? size;
      if (out != null && await File(out).exists()) size = await File(out).length();
      await _finish(
        job,
        JobStatus.completed,
        log: result.log,
        outputSize: size,
        findings: logIsResult ? result.log.length : null,
      );
    } else {
      final err = translateToolError(result.log, startError: result.startError);
      if (job.attempts <= job.maxRetries && err.kind != ToolErrorKind.toolMissing) {
        await _saveJob(job.copyWith(status: JobStatus.queued.name, log: Value(result.logText)));
      } else {
        await _deletePartial(out);
        await _finish(job, JobStatus.failed, error: err, log: result.log);
      }
    }
  }

  void _onProgress(String id, FfmpegProgress p) {
    // Throttle UI rebuilds to ~6/s per job.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!p.ended && now - (_lastUiUpdate[id] ?? 0) < 160) return;
    _lastUiUpdate[id] = now;
    _replace(id, (i) => i.copyWith(progress: () => p));
  }

  Future<void> _finish(
    Job job,
    JobStatus status, {
    ToolError? error,
    required List<String> log,
    int? outputSize,
    int? findings,
  }) async {
    final extra = {...QueueItem(job: job).extra, 'findings': ?findings};
    await _saveJob(
      job.copyWith(
        status: status.name,
        finishedAt: Value(DateTime.now()),
        errorKind: Value(error?.kind.name),
        errorDetail: Value(error?.detail ?? error?.line),
        log: Value(log.join('\n')),
        outputSize: Value(outputSize),
        extraJson: Value(extra.isEmpty ? null : jsonEncode(extra)),
      ),
    );
    _lastUiUpdate.remove(job.id);
  }

  Future<void> _deletePartial(String? path) async {
    if (path == null) return;
    final f = File(path);
    if (await f.exists()) {
      try {
        await f.delete();
      } on FileSystemException {
        // ignore
      }
    }
  }

  Future<void> cancel(String id) async {
    final h = _handles[id];
    if (h != null) {
      await h.cancel();
      return;
    }
    final item = state.byId(id);
    if (item != null && item.status == JobStatus.queued) {
      await _saveJob(item.job.copyWith(status: JobStatus.canceled.name, finishedAt: Value(DateTime.now())));
    }
  }

  bool get canPause => RunHandle.canPause;

  Future<void> pause(String id) async {
    final h = _handles[id];
    if (h == null || !h.pause()) return;
    final item = state.byId(id);
    if (item != null) await _saveJob(item.job.copyWith(status: JobStatus.paused.name));
  }

  Future<void> resume(String id) async {
    final h = _handles[id];
    if (h == null || !h.resume()) return;
    final item = state.byId(id);
    if (item != null) await _saveJob(item.job.copyWith(status: JobStatus.running.name));
  }

  Future<void> retry(String id) async {
    final item = state.byId(id);
    if (item == null || !item.isFinished) return;
    await _saveJob(
      item.job.copyWith(
        status: JobStatus.queued.name,
        attempts: 0,
        errorKind: const Value(null),
        errorDetail: const Value(null),
        finishedAt: const Value(null),
      ),
    );
    _schedule();
  }

  Future<void> setPriority(String id, int priority) async {
    final item = state.byId(id);
    if (item == null) return;
    await _saveJob(item.job.copyWith(priority: priority));
  }

  Future<void> remove(String id) async {
    final item = state.byId(id);
    if (item == null || item.isActive) return;
    await _db.deleteJob(id);
    state = QueueState(items: state.items.where((i) => i.id != id).toList(), loaded: state.loaded);
  }

  Future<void> clearFinished() async {
    await _db.deleteFinished();
    state = QueueState(items: state.items.where((i) => !i.isFinished).toList(), loaded: state.loaded);
  }
}
