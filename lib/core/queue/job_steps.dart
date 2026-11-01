/// Multi-step jobs: two-pass encodes, measure-then-apply loudnorm, etc.
///
/// A job is a list of [JobStep]s run in order. Steps are persisted as JSON,
/// so a later step cannot hold a closure; instead it uses `{{name}}`
/// placeholders that are filled from values an earlier step [capture]d
/// (e.g. loudnorm measurements). `{{tmp}}` is a per-job scratch folder that
/// the queue creates before the first step and deletes afterwards.
library;

import 'dart:convert';

import 'queue_models.dart';

enum StepCapture {
  none,

  /// Parse loudnorm `print_format=json` output into `loudnorm.*` values.
  loudnorm,

  /// yt-dlp `--print after_move:"[kadra-file] %(filepath)s"` → `outputPath`.
  ytdlpFilePath,
}

class JobStep {
  const JobStep({
    required this.args,
    this.tool = JobTool.ffmpeg,
    this.label,
    this.weight = 1,
    this.capture = StepCapture.none,
    this.workingDirectory,
    this.totalDuration,
    this.files = const {},
  });

  final List<String> args;

  /// Text files written before the step runs (path → content; both may use
  /// placeholders such as `{{tmp}}`), e.g. concat demuxer lists.
  final Map<String, String> files;
  final JobTool tool;

  /// Short human label, e.g. "1/2".
  final String? label;

  /// Share of the job's total progress (relative to other steps).
  final double weight;
  final StepCapture capture;

  /// May contain `{{tmp}}`.
  final String? workingDirectory;

  /// Duration this step processes (for percent/ETA). Falls back to the job's.
  final Duration? totalDuration;

  Map<String, Object?> toJson() => {
    'args': args,
    'tool': tool.name,
    'label': ?label,
    'weight': weight,
    'capture': capture.name,
    'cwd': ?workingDirectory,
    'durationUs': ?totalDuration?.inMicroseconds,
    if (files.isNotEmpty) 'files': files,
  };

  factory JobStep.fromJson(Map<String, dynamic> j) => JobStep(
    args: (j['args'] as List).cast<String>(),
    tool: JobTool.values.byName(j['tool'] as String? ?? 'ffmpeg'),
    label: j['label'] as String?,
    weight: (j['weight'] as num?)?.toDouble() ?? 1,
    capture: StepCapture.values.byName(j['capture'] as String? ?? 'none'),
    workingDirectory: j['cwd'] as String?,
    totalDuration: j['durationUs'] == null ? null : Duration(microseconds: j['durationUs'] as int),
    files: (j['files'] as Map?)?.cast<String, String>() ?? const {},
  );
}

/// Stored form of a job's steps. A plain JSON list of strings (stage 1 jobs)
/// is read as a single ffmpeg step.
String encodeSteps(List<JobStep> steps) => jsonEncode({'steps': steps.map((s) => s.toJson()).toList()});

List<JobStep> decodeSteps(String json, {JobTool fallbackTool = JobTool.ffmpeg}) {
  final v = jsonDecode(json);
  if (v is List) return [JobStep(args: v.cast<String>(), tool: fallbackTool)];
  final steps = (v as Map)['steps'] as List;
  return [for (final s in steps) JobStep.fromJson((s as Map).cast<String, dynamic>())];
}

final _placeholder = RegExp(r'\{\{([\w.]+)\}\}');

/// Replaces `{{name}}` with [vars]; throws if a placeholder has no value,
/// so a broken chain fails loudly instead of running a wrong command.
List<String> substitute(List<String> args, Map<String, String> vars) => [
  for (final a in args)
    a.replaceAllMapped(_placeholder, (m) {
      final v = vars[m.group(1)!];
      if (v == null) throw StateError('No value for {{${m.group(1)}}}');
      return v;
    }),
];

String? substituteOpt(String? s, Map<String, String> vars) => s == null ? null : substitute([s], vars).single;

/// Extracts the loudnorm JSON block (last one in the log) into
/// `loudnorm.input_i`, `loudnorm.input_tp`, `loudnorm.input_lra`,
/// `loudnorm.input_thresh`, `loudnorm.target_offset`.
/// Returns null if missing or if the input is silent (`-inf`).
Map<String, String>? parseLoudnormJson(List<String> log) {
  final text = log.join('\n');
  final end = text.lastIndexOf('}');
  if (end < 0) return null;
  final start = text.lastIndexOf('{', end);
  if (start < 0) return null;
  final Map<String, dynamic> j;
  try {
    j = (jsonDecode(text.substring(start, end + 1)) as Map).cast<String, dynamic>();
  } on FormatException {
    return null;
  }
  const keys = ['input_i', 'input_tp', 'input_lra', 'input_thresh', 'target_offset'];
  final out = <String, String>{};
  for (final k in keys) {
    final v = j[k]?.toString().trim();
    if (v == null || double.tryParse(v) == null || !double.parse(v).isFinite) return null;
    out['loudnorm.$k'] = v;
  }
  return out;
}

/// `[kadra-file] /path/to/file.mp4` lines printed by yt-dlp.
const ytdlpFileMarker = '[kadra-file] ';

String? parseYtdlpFilePath(List<String> log) {
  for (final l in log.reversed) {
    final i = l.indexOf(ytdlpFileMarker);
    if (i >= 0) return l.substring(i + ytdlpFileMarker.length).trim();
  }
  return null;
}

/// Overall fraction of a multi-step job.
double overallFraction(List<JobStep> steps, int index, double stepFraction) {
  final total = steps.fold<double>(0, (a, s) => a + s.weight);
  if (total <= 0) return stepFraction;
  var done = 0.0;
  for (var i = 0; i < index && i < steps.length; i++) {
    done += steps[i].weight;
  }
  final cur = index < steps.length ? steps[index].weight : 0;
  return ((done + cur * stepFraction.clamp(0.0, 1.0)) / total).clamp(0.0, 1.0);
}
