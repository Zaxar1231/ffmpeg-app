@Tags(['ffmpeg'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/features/convert/convert_params.dart';
import 'package:kadra/features/edit/edit_encode.dart';
import 'package:kadra/features/edit/graphs.dart';
import 'package:kadra/features/tools/ab_compare.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();

  test('fragment of a two-pass convert and of a vidstab job', () async {
    final dir = await Directory.systemTemp.createTemp('kadra_ab');
    final src = p.join(dir.path, 'src.mp4');
    final g = await runner.capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=320x240:d=6', '-f', 'lavfi', '-i', 'sine=d=6', //
      '-c:v', 'libx264', '-c:a', 'aac', src,
    ]);
    expect(g.ok, isTrue, reason: g.stderr);
    final probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    final info = await probe.probe(src);
    final out = p.join(dir.path, 'out.mp4');
    final convert = planConvert(
      info: info,
      output: out,
      p: const ConvertParams(rateMode: RateMode.bitrate, videoKbps: 300, useHardware: false),
    ).steps;
    const prm = RestoreParams(stabilize: true);
    final restore = [
      JobStep(args: vidstabDetectArgs(info, prm), workingDirectory: '{{tmp}}'),
      ...planEdit(
        info: info,
        output: out,
        graph: restoreGraph(info, prm),
        out: const EditOutput(),
        workingDirectory: '{{tmp}}',
      ).steps,
    ];
    final fl = (await runner.capture(ffmpeg, ['-hide_banner', '-filters'])).stdout;
    for (final (name, steps) in [('convert', convert), if (fl.contains('vidstabdetect')) ('restore', restore)]) {
      final frag = p.join(dir.path, 'frag_$name.mp4');
      final fs = fragmentSteps(
        steps,
        mainPath: src,
        output: out,
        fragment: frag,
        start: const Duration(seconds: 2),
        length: const Duration(seconds: 2),
      );
      expect(fs, isNotNull, reason: name);
      final tmp = await Directory(p.join(dir.path, 'tmp_$name')).create();
      for (final s in fs!) {
        final r = await (await runner.start(
          ToolInvocation(
            executable: ffmpeg,
            args: substitute(s.args, {'tmp': tmp.path}),
            workingDirectory: substituteOpt(s.workingDirectory, {'tmp': tmp.path}),
          ),
        )).done;
        expect(r.success, isTrue, reason: '$name: ${r.logText}');
      }
      expect((await probe.probe(frag)).duration!.inMilliseconds, closeTo(2000, 120), reason: name);
    }
    await dir.delete(recursive: true);
  }, skip: skip);

  test('jobs that cannot be cut into a fragment', () {
    expect(
      fragmentSteps(
        [
          const JobStep(args: ['-i', 'a.mp4', '-f', 'segment', 'o_%03d.mp4']),
        ],
        mainPath: 'a.mp4',
        output: 'o.mp4',
        fragment: 'f.mp4',
        start: Duration.zero,
        length: Duration.zero,
      ),
      isNull,
    );
    expect(
      fragmentSteps(
        [
          const JobStep(args: ['-i', 'b.mp4', 'o.mp4']),
        ],
        mainPath: 'a.mp4',
        output: 'o.mp4',
        fragment: 'f.mp4',
        start: Duration.zero,
        length: Duration.zero,
      ),
      isNull,
    );
  });
}
