@Tags(['ffmpeg'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/ffmpeg_command.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/features/expert/expert_ops.dart';
import 'package:path/path.dart' as p;

/// LAME fails with "Error encoding a frame: Cannot allocate memory" on NaN
/// samples (a user report from Windows, BtbN 9.0); 16-bit input avoids it.
void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  const runner = ProcessRunner();

  test('mp3 outputs get 16-bit samples', () {
    final a = const FfmpegOutput('o.mp3', audioCodec: 'libmp3lame', options: ['-b:a', '192k']).toArgs();
    expect(a, containsAllInOrder(['-c:a', 'libmp3lame', '-b:a', '192k', '-sample_fmt', 's16p', 'o.mp3']));
    expect(a.last, 'o.mp3');
    final b = const FfmpegOutput('o.mp3', options: ['-c:a', 'libmp3lame', '-sample_fmt', 's32p']).toArgs();
    expect(b.where((x) => x == '-sample_fmt'), hasLength(1)); // the user's choice stays
    expect(const FfmpegOutput('o.m4a', audioCodec: 'aac').toArgs(), isNot(contains('-sample_fmt')));
    final cmd = parseCommand('ffmpeg -i in.wav -c:a libmp3lame -q:a 2 out.mp3');
    expect(cmd.args, containsAllInOrder(['-q:a', '2', '-sample_fmt', 's16p', 'out.mp3']));
  });

  test('audio with NaN samples encodes to mp3', () async {
    if (ffmpeg == null) return markTestSkipped('no ffmpeg');
    final dir = await Directory.systemTemp.createTemp('kadra_lame');
    addTearDown(() => dir.delete(recursive: true));
    final bad = p.join(dir.path, 'bad.wav');
    final g = await runner.capture(ffmpeg, [
      '-v', 'error', '-f', 'lavfi', '-i', "aevalsrc='if(gt(t,0.5),0/0,sin(2*PI*440*t))':s=44100:d=1", //
      '-c:a', 'pcm_f32le', bad,
    ]);
    expect(g.ok, isTrue, reason: g.stderr);
    final args = FfmpegCommand(
      reportProgress: false,
      inputs: [FfmpegInput(bad)],
      outputs: [
        FfmpegOutput(p.join(dir.path, 'out.mp3'), audioCodec: 'libmp3lame', options: const ['-b:a', '192k']),
      ],
    ).toArgs();
    final r = await runner.capture(ffmpeg, args);
    expect(r.ok, isTrue, reason: '${args.join(' ')}\n${r.stderr}');
  });
}
