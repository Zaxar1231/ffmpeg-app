@Tags(['ffmpeg'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/capabilities.dart';
import 'package:kadra/core/engine/error_translator.dart';
import 'package:kadra/core/engine/ffmpeg_command.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/engine/progress.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/probe_service.dart';

/// Integration tests against a real ffmpeg on PATH; skipped when absent.
void main() {
  final ffmpeg = findOnPath('ffmpeg');
  final ffprobe = findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg/ffprobe not on PATH' : null;
  const runner = ProcessRunner();

  test('runs ffmpeg and reports progress to the end', () async {
    const cmd = FfmpegCommand(
      inputs: [FfmpegInput('testsrc2=s=160x120:r=25:d=2', format: 'lavfi')],
      outputs: [FfmpegOutput('-', format: 'null')],
    );
    final h = await runner.start(
      ToolInvocation(executable: ffmpeg!, args: cmd.toArgs(), totalDuration: const Duration(seconds: 2)),
    );
    final snaps = <FfmpegProgress>[];
    h.progress.listen(snaps.add);
    final r = await h.done;
    expect(r.success, isTrue, reason: r.logText);
    expect(snaps, isNotEmpty);
    expect(snaps.last.ended, isTrue);
    expect(snaps.last.fraction, 1);
    expect(snaps.last.frame, 50);
  }, skip: skip);

  test('cancel stops a long job', () async {
    const cmd = FfmpegCommand(
      inputs: [
        FfmpegInput('testsrc2=s=640x480:r=25', format: 'lavfi', options: ['-re']),
      ],
      outputs: [FfmpegOutput('-', format: 'null')],
    );
    final h = await runner.start(ToolInvocation(executable: ffmpeg!, args: cmd.toArgs()));
    await h.progress.first;
    await h.cancel();
    final r = await h.done;
    expect(r.canceled, isTrue);
    expect(r.success, isFalse);
  }, skip: skip);

  test('pause and resume (POSIX)', () async {
    const cmd = FfmpegCommand(
      inputs: [
        FfmpegInput('testsrc2=s=160x120:r=25:d=1.5', format: 'lavfi', options: ['-re']),
      ],
      outputs: [FfmpegOutput('-', format: 'null')],
    );
    final h = await runner.start(ToolInvocation(executable: ffmpeg!, args: cmd.toArgs()));
    await h.progress.first;
    expect(h.pause(), isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(h.resume(), isTrue);
    expect((await h.done).success, isTrue);
  }, skip: skip ?? (RunHandle.canPause ? null : 'no pause on this OS'));

  test('failure is translated to a human error', () async {
    const cmd = FfmpegCommand(
      inputs: [FfmpegInput('/definitely/not/here.mp4')],
      outputs: [FfmpegOutput('-', format: 'null')],
    );
    final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: cmd.toArgs()))).done;
    expect(r.success, isFalse);
    expect(translateToolError(r.log).kind, ToolErrorKind.fileNotFound);
  }, skip: skip);

  test('missing executable completes with startError', () async {
    final r = await (await runner.start(const ToolInvocation(executable: '/no/such/ffmpeg', args: []))).done;
    expect(r.startError, isNotNull);
    expect(translateToolError(r.log, startError: r.startError).kind, ToolErrorKind.toolMissing);
  });

  test('escapeFilterValue survives a real filtergraph', () async {
    for (final v in [r'C:\fonts\a.ttf', "it's, [x]; y: z", 'q\'u:o=te']) {
      final r = await runner.capture(ffmpeg!, [
        '-hide_banner', '-f', 'lavfi', '-i', 'color=d=0.04', //
        '-vf', 'metadata=mode=add:key=k:value=${escapeFilterValue(v)},metadata=mode=print',
        '-f', 'null', '-',
      ]);
      expect(r.stderr, contains(' k=$v\n'), reason: v);
    }
  }, skip: skip);

  test('capabilities of the real build parse', () async {
    final enc = parseCodecList((await runner.capture(ffmpeg!, ['-hide_banner', '-encoders'])).stdout);
    expect(enc, contains('rawvideo'));
  }, skip: skip);

  test('probe a generated file', () async {
    final dir = await Directory.systemTemp.createTemp('kadra');
    final out = '${dir.path}/t.mkv';
    final gen = await runner.capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=160x120:d=1', '-f', 'lavfi', '-i', 'sine=d=1', //
      '-c:v', 'ffv1', '-c:a', 'flac', out,
    ]);
    expect(gen.ok, isTrue, reason: gen.stderr);
    final info = await ProbeService(runner: runner, ffprobePath: ffprobe!).probe(out);
    expect(info.videoStreams.single.codecName, 'ffv1');
    expect(info.audioStreams.single.codecName, 'flac');
    expect(info.duration!.inMilliseconds, closeTo(1000, 100));
    await expectLater(
      ProbeService(runner: runner, ffprobePath: ffprobe).probe('${dir.path}/missing.mkv'),
      throwsA(isA<ProbeException>()),
    );
    await dir.delete(recursive: true);
  }, skip: skip);
}
