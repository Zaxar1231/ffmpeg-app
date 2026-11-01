@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/features/analysis/analysis_ops.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo clip; // 2 s testsrc + 1 s black/frozen, tone with 1 s silence
  late MediaInfo dist;
  late bool hasVmaf;

  Future<List<String>> run(List<String> args) async {
    final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: args))).done;
    expect(r.success, isTrue, reason: '${args.join(' ')}\n${r.logText}');
    return r.log;
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_an');
    final c = p.join(dir.path, 'clip.mkv');
    var r = await runner.capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', //
      'testsrc2=s=320x240:d=2,format=yuv420p[a];color=black:s=320x240:d=1.5,format=yuv420p[b];[a][b]concat',
      '-f', 'lavfi', '-i', 'sine=f=440:d=1.5:sample_rate=48000,apad=whole_dur=3.5',
      '-c:v', 'libx264', '-c:a', 'flac', c,
    ]);
    expect(r.ok, isTrue, reason: r.stderr);
    final d = p.join(dir.path, 'dist.mp4');
    r = await runner.capture(ffmpeg, ['-v', 'error', '-i', c, '-s', '160x120', '-c:v', 'libx264', '-crf', '40', d]);
    expect(r.ok, isTrue, reason: r.stderr);
    final probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    clip = await probe.probe(c);
    dist = await probe.probe(d);
    hasVmaf = (await runner.capture(ffmpeg, ['-hide_banner', '-filters'])).stdout.contains(' libvmaf ');
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  test('loudness: summary and momentary curve', () async {
    final rep = parseLoudness(await run(loudnessArgs(clip.path)));
    expect(rep.integrated, isNotNull);
    expect(rep.truePeak, isNotNull);
    expect(rep.points.length, greaterThan(25));
    expect(rep.maxMomentary, isNotNull);
  }, skip: skip);

  for (final kind in PicKind.values) {
    test('picture ${kind.name}', () async {
      final out = p.join(dir.path, '${kind.name}.png');
      final args = picArgs(
        clip.path,
        out,
        PicParams(kind: kind, width: 800, height: 200, splitChannels: true, logFrequency: true),
      );
      final r = await runner.capture(ffmpeg!, args);
      expect(r.ok, isTrue, reason: r.stderr);
      expect(await File(out).length(), greaterThan(500));
    }, skip: skip);
  }

  test('silence', () async {
    final f = parseFindings(
      DetectKind.silence,
      await run(detectArgs(clip.path, const DetectParams())),
      total: clip.duration,
    );
    expect(f, hasLength(1));
    expect(f.single.start.inMilliseconds, closeTo(1500, 60));
    expect(f.single.end!.inMilliseconds, closeTo(3500, 100));
  }, skip: skip);

  test('black', () async {
    final f = parseFindings(
      DetectKind.black,
      await run(detectArgs(clip.path, const DetectParams(kind: DetectKind.black))),
    );
    expect(f, hasLength(1));
    expect(f.single.start.inMilliseconds, closeTo(2000, 60));
  }, skip: skip);

  test('freeze (open interval ends at the file end)', () async {
    final f = parseFindings(
      DetectKind.freeze,
      await run(detectArgs(clip.path, const DetectParams(kind: DetectKind.freeze))),
      total: clip.duration,
    );
    expect(f, isNotEmpty);
    expect(f.last.end, isNotNull);
  }, skip: skip);

  test('scenes', () async {
    final f = parseFindings(
      DetectKind.scenes,
      await run(detectArgs(clip.path, const DetectParams(kind: DetectKind.scenes))),
    );
    expect(f.any((x) => (x.start.inMilliseconds - 2000).abs() < 60), isTrue);
    expect(findingsCsv(f), startsWith('start;end'));
  }, skip: skip);

  test('quality PSNR/SSIM (+VMAF when built in)', () async {
    final q = parseQuality(await run(qualityArgs(reference: clip, distorted: dist, vmaf: hasVmaf)));
    expect(q.psnr, isNotNull);
    expect(q.ssim, inInclusiveRange(0.3, 1));
    if (hasVmaf) expect(q.vmaf, inInclusiveRange(0, 100));
  }, skip: skip);
}
