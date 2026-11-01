import '../../core/components/toolchain.dart';
import '../../core/engine/shell_quote.dart';
import '../../core/platform/host.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';

/// Copy-pasteable text for all steps of a job (expert "Show command").
/// `{{...}}` placeholders stay visible: they are filled at run time.
String stepsCommandText(List<JobStep> steps, Toolchain tc) {
  final windows = HostPlatform.current.isWindows;
  String exe(JobTool t) => switch (t) {
    JobTool.ffmpeg => tc.ffmpeg.path ?? 'ffmpeg',
    JobTool.ffprobe => tc.ffprobe.path ?? 'ffprobe',
    JobTool.ytdlp => tc.ytdlp.path ?? 'yt-dlp',
  };
  final b = StringBuffer();
  for (var i = 0; i < steps.length; i++) {
    final s = steps[i];
    if (steps.length > 1) {
      b.writeln(
        '# ${s.label ?? '${i + 1}/${steps.length}'}${s.workingDirectory != null ? '  (cd ${s.workingDirectory})' : ''}',
      );
    }
    for (final f in s.files.entries) {
      b.writeln('# ${f.key}:');
      for (final line in f.value.trimRight().split('\n')) {
        b.writeln('#   $line');
      }
    }
    b.writeln(quoteCommand([exe(s.tool), ...s.args], windows: windows));
    if (i < steps.length - 1) b.writeln();
  }
  return b.toString().trimRight();
}
