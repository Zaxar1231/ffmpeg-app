import 'dart:convert';

import '../db/database.dart';
import '../engine/progress.dart';

enum JobStatus { queued, running, paused, completed, failed, canceled }

enum JobTool { ffmpeg, ffprobe, ytdlp }

/// What a feature submits to the queue.
class JobRequest {
  const JobRequest({
    required this.kind,
    required this.title,
    required this.tool,
    required this.args,
    this.inputPath,
    this.outputPath,
    this.totalDuration,
    this.priority = 0,
    this.maxRetries,
    this.logIsResult = false,
  });

  final String kind;
  final String title;
  final JobTool tool;
  final List<String> args;
  final String? inputPath;
  final String? outputPath;
  final Duration? totalDuration;
  final int priority;

  /// null → use the retry count from settings.
  final int? maxRetries;

  /// For checks like integrity: stderr lines are findings, not failures.
  final bool logIsResult;
}

class QueueItem {
  const QueueItem({required this.job, this.progress, this.attemptLog = const []});

  final Job job;
  final FfmpegProgress? progress;

  /// Live log of the current attempt (tail).
  final List<String> attemptLog;

  String get id => job.id;
  JobStatus get status => JobStatus.values.byName(job.status);
  List<String> get args => (jsonDecode(job.argsJson) as List).cast<String>();
  JobTool get tool => JobTool.values.byName(job.tool);
  Duration? get totalDuration => job.durationUs == null ? null : Duration(microseconds: job.durationUs!);
  bool get isActive => status == JobStatus.running || status == JobStatus.paused;
  bool get isFinished => status == JobStatus.completed || status == JobStatus.failed || status == JobStatus.canceled;
  Map<String, dynamic> get extra =>
      job.extraJson == null ? const {} : (jsonDecode(job.extraJson!) as Map).cast<String, dynamic>();

  QueueItem copyWith({Job? job, FfmpegProgress? Function()? progress, List<String>? attemptLog}) => QueueItem(
    job: job ?? this.job,
    progress: progress != null ? progress() : this.progress,
    attemptLog: attemptLog ?? this.attemptLog,
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
