import 'dart:convert';

import '../db/database.dart';
import '../engine/progress.dart';
import 'job_steps.dart';

enum JobStatus { queued, running, paused, completed, failed, canceled }

enum JobTool { ffmpeg, ffprobe, ytdlp }

/// What a feature submits to the queue.
class JobRequest {
  const JobRequest({
    required this.kind,
    required this.title,
    required this.tool,
    this.args = const [],
    this.steps,
    this.inputPath,
    this.outputPath,
    this.totalDuration,
    this.priority = 0,
    this.maxRetries,
    this.logIsResult = false,
    this.extra = const {},
  });

  /// Stored with the job (JSON), e.g. `thenRecipe` for a download.
  final Map<String, Object?> extra;

  final String kind;
  final String title;
  final JobTool tool;

  /// Single-step jobs: arguments for [tool]. Ignored when [steps] is set.
  final List<String> args;

  /// Multi-step jobs (two-pass, measure + apply...).
  final List<JobStep>? steps;
  final String? inputPath;
  final String? outputPath;
  final Duration? totalDuration;
  final int priority;

  /// null → use the retry count from settings.
  final int? maxRetries;

  /// For checks like integrity: stderr lines are findings, not failures.
  final bool logIsResult;

  List<JobStep> get effectiveSteps => steps ?? [JobStep(args: args, tool: tool)];
}

class QueueItem {
  const QueueItem({required this.job, this.progress, this.attemptLog = const [], this.step = 0});

  final Job job;
  final FfmpegProgress? progress;

  /// Index of the step currently running.
  final int step;

  /// Live log of the current attempt (tail).
  final List<String> attemptLog;

  String get id => job.id;
  JobStatus get status => JobStatus.values.byName(job.status);
  JobTool get tool => JobTool.values.byName(job.tool);
  List<JobStep> get steps => decodeSteps(job.argsJson, fallbackTool: tool);
  Duration? get totalDuration => job.durationUs == null ? null : Duration(microseconds: job.durationUs!);
  bool get isActive => status == JobStatus.running || status == JobStatus.paused;
  bool get isFinished => status == JobStatus.completed || status == JobStatus.failed || status == JobStatus.canceled;
  Map<String, dynamic> get extra =>
      job.extraJson == null ? const {} : (jsonDecode(job.extraJson!) as Map).cast<String, dynamic>();

  QueueItem copyWith({Job? job, FfmpegProgress? Function()? progress, List<String>? attemptLog, int? step}) =>
      QueueItem(
        job: job ?? this.job,
        progress: progress != null ? progress() : this.progress,
        attemptLog: attemptLog ?? this.attemptLog,
        step: step ?? this.step,
      );
}

/// Picks the next job: highest priority first, then oldest.
QueueItem? pickNext(Iterable<QueueItem> items) {
  QueueItem? best;
  for (final i in items) {
    if (i.status != JobStatus.queued) continue;
    if (best == null ||
        i.job.priority > best.job.priority ||
        (i.job.priority == best.job.priority && i.job.createdAt.isBefore(best.job.createdAt))) {
      best = i;
    }
  }
  return best;
}
