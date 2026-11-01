import 'package:path/path.dart' as p;

import '../../core/engine/ffmpeg_command.dart';
import '../../core/queue/queue_models.dart';

/// Integrity check: decode everything, write nothing, report every error.
/// `ffmpeg -v error -i <file> -map 0 -f null -`
///
/// Without `-xerror`, ffmpeg keeps going after a broken packet so the log
/// lists every problem; an empty log means the file decoded cleanly.
FfmpegCommand integrityCommand(String path) => FfmpegCommand(
  inputs: [FfmpegInput(path)],
  outputs: const [
    FfmpegOutput('-', maps: ['0'], format: 'null'),
  ],
);

JobRequest integrityJob(String path, {Duration? duration, required String title}) => JobRequest(
  kind: 'integrity',
  title: title,
  tool: JobTool.ffmpeg,
  args: integrityCommand(path).toArgs(),
  inputPath: path,
  totalDuration: duration,
  logIsResult: true,
);

String displayName(String path) => p.basename(path);
