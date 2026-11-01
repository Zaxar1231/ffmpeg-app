import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/ffmpeg_command.dart';
import 'package:kadra/core/engine/shell_quote.dart';

void main() {
  group('formatTimestamp', () {
    test('formats hours/minutes/seconds/millis', () {
      expect(formatTimestamp(const Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 45)), '01:02:03.045');
      expect(formatTimestamp(Duration.zero), '00:00:00.000');
      expect(formatTimestamp(const Duration(hours: 100)), '100:00:00.000');
      expect(formatTimestamp(const Duration(milliseconds: -1500)), '-00:00:01.500');
    });
  });

  group('FfmpegCommand.toArgs', () {
    test('base flags, progress reporting and order', () {
      const cmd = FfmpegCommand(
        inputs: [FfmpegInput('in.mp4')],
        outputs: [FfmpegOutput('out.mkv', videoCodec: 'copy', audioCodec: 'copy')],
      );
      expect(cmd.toArgs(), [
        '-hide_banner', '-nostdin', '-y', '-v', 'error', //
        '-progress', 'pipe:1', '-nostats',
        '-i', 'in.mp4',
        '-c:v', 'copy', '-c:a', 'copy',
        'out.mkv',
      ]);
    });

    test('input options precede -i and output options precede the path', () {
      const cmd = FfmpegCommand(
        reportProgress: false,
        overwrite: false,
        logLevel: 'info',
        globalOptions: ['-threads', '4'],
        inputs: [
          FfmpegInput('a.mp4', seek: Duration(seconds: 10), to: Duration(seconds: 20), hwaccel: 'cuda'),
          FfmpegInput('color=c=black', format: 'lavfi', duration: Duration(seconds: 1)),
        ],
        filterComplex: '[0:v][1:v]concat=n=2:v=1:a=0[v]',
        outputs: [
          FfmpegOutput(
            'o.mp4',
            maps: ['[v]', '0:a?'],
            videoCodec: 'libx264',
            noSubtitles: true,
            metadata: {'title': 'Hello world'},
            options: ['-crf', '23', '-movflags', '+faststart'],
          ),
        ],
      );
      expect(cmd.toArgs(), [
        '-hide_banner', '-nostdin', '-n', '-v', 'info', //
        '-threads', '4',
        '-hwaccel', 'cuda', '-ss', '00:00:10.000', '-to', '00:00:20.000', '-i', 'a.mp4',
        '-t', '00:00:01.000', '-f', 'lavfi', '-i', 'color=c=black',
        '-filter_complex', '[0:v][1:v]concat=n=2:v=1:a=0[v]',
        '-map', '[v]', '-map', '0:a?',
        '-sn', '-c:v', 'libx264',
        '-metadata', 'title=Hello world',
        '-crf', '23', '-movflags', '+faststart',
        'o.mp4',
      ]);
    });

    test('filters are joined and null output format comes last before path', () {
      const cmd = FfmpegCommand(
        inputs: [FfmpegInput('in.wav')],
        outputs: [
          FfmpegOutput('-', noVideo: true, audioFilters: ['highpass=f=80', 'loudnorm'], format: 'null'),
        ],
      );
      final args = cmd.toArgs();
      expect(args.sublist(args.length - 6), ['-vn', '-af', 'highpass=f=80,loudnorm', '-f', 'null', '-']);
    });

    test('display string quotes paths with spaces', () {
      const cmd = FfmpegCommand(
        reportProgress: false,
        inputs: [FfmpegInput('/home/u/My Video.mp4')],
        outputs: [FfmpegOutput("/tmp/it's.mkv", videoCodec: 'copy')],
      );
      final posix = cmd.toDisplayString();
      expect(posix, contains("'/home/u/My Video.mp4'"));
      expect(posix, contains(r"'/tmp/it'\''s.mkv'"));
      expect(splitCommandLine(posix), ['ffmpeg', ...cmd.toArgs()]);

      final win = cmd.toDisplayString(executable: r'C:\ff\ffmpeg.exe', windows: true);
      expect(win, startsWith(r'C:\ff\ffmpeg.exe '));
      expect(win, contains(r'"/home/u/My Video.mp4"'));
    });
  });

  group('escapeFilterValue', () {
    test('escapes Windows paths for filter options', () {
      expect(escapeFilterValue(r'C:\fonts\a.ttf'), r'C\\:\\\\fonts\\\\a.ttf');
    });
    test('escapes quotes and graph separators', () {
      expect(escapeFilterValue("it's, [x]; y"), r"it\\\'s\, \[x\]\; y");
    });
  });
}
