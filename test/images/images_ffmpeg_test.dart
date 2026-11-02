@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/capabilities.dart';
import 'package:kadra/core/engine/encoders.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/features/convert/convert_params.dart';
import 'package:kadra/features/edit/edit_encode.dart';
import 'package:kadra/features/images/images_ops.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo video;
  late MediaInfo song; // mp3 with an embedded cover
  late MediaInfo plainAudio;
  late List<String> pics;
  late ProbeService probe;
  late EncodeEnv env;
  late Set<String> encoders;

  Future<void> run(List<JobStep> steps) async {
    for (final s in steps) {
      final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: s.args))).done;
      expect(r.success, isTrue, reason: '${s.args.join(' ')}\n${r.logText}');
    }
  }

  Future<MediaInfo> encode(String name, EditGraph g, MediaInfo info) async {
    final out = p.join(dir.path, name);
    final plan = planEdit(
      info: info,
      output: out,
      graph: g,
      out: const EditOutput(speed: SpeedPreset.fastest),
      env: env,
    );
    expect(plan.issues, isEmpty);
    await run(plan.steps);
    return probe.probe(out);
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_img');
    Future<String> gen(String name, List<String> a) async {
      final out = p.join(dir.path, name);
      final r = await runner.capture(ffmpeg!, ['-v', 'error', '-y', ...a, out]);
      expect(r.ok, isTrue, reason: r.stderr);
      return out;
    }

    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    video = await probe.probe(await gen('v.mp4', ['-f', 'lavfi', '-i', 'testsrc2=s=640x360:d=10', '-c:v', 'libx264']));
    final cover = await gen('cover.jpg', ['-f', 'lavfi', '-i', 'testsrc=s=500x500', '-frames:v', '1']);
    final tone = await gen('tone.mp3', ['-f', 'lavfi', '-i', 'sine=d=4']);
    song = await probe.probe(
      await gen('song.mp3', [
        '-i',
        tone,
        '-i',
        cover,
        '-map',
        '0',
        '-map',
        '1',
        '-c',
        'copy',
        '-disposition:v',
        'attached_pic',
      ]),
    );
    plainAudio = await probe.probe(tone);
    pics = [
      await gen('p1.png', ['-f', 'lavfi', '-i', 'testsrc=s=800x600', '-frames:v', '1']),
      await gen('p2.jpg', ['-f', 'lavfi', '-i', 'smptebars=s=600x900', '-frames:v', '1']),
      await gen('p3.png', ['-f', 'lavfi', '-i', 'color=c=orange:s=1000x500', '-frames:v', '1']),
    ];
    encoders = parseCodecList((await runner.capture(ffmpeg!, ['-hide_banner', '-encoders'])).stdout).keys.toSet();
    env = EncodeEnv(
      caps: FfmpegCapabilities(
        version: 'test',
        configuration: const [],
        encoders: parseCodecList((await runner.capture(ffmpeg, ['-hide_banner', '-encoders'])).stdout),
        decoders: const {},
        filters: const {},
        muxers: const {},
        hwaccels: const {},
      ),
      allowHardware: false,
    );
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  for (final mode in FramesMode.values) {
    test('frames ${mode.name}', () async {
      final sub = await Directory(p.join(dir.path, 'frames_${mode.name}')).create();
      final out = p.join(sub.path, "shot's 50%.jpg");
      await run(
        planFrames(
          info: video,
          output: out,
          f: FramesParams(
            mode: mode,
            at: const Duration(seconds: 3),
            every: const Duration(seconds: 2),
            count: 4,
            width: 320,
          ),
        ),
      );
      final n = sub.listSync().length;
      switch (mode) {
        case FramesMode.single || FramesMode.best:
          expect(n, 1);
        case FramesMode.every:
          expect(n, inInclusiveRange(5, 6));
        case FramesMode.count:
          expect(n, 4);
        case FramesMode.scenes:
          expect(n, greaterThanOrEqualTo(0));
      }
    }, skip: skip);
  }

  for (final f in ImageFormat.values) {
    test('image format ${f.name}', () async {
      if (!encoders.contains(imageEncoder(f))) return markTestSkipped('${imageEncoder(f)} not in this build');
      final out = p.join(dir.path, 'conv.${imageExt(f)}');
      await run(
        planImageConvert(
          info: await probe.probe(pics[1]),
          output: out,
          c: ImageConvertParams(format: f, quality: 80, maxSide: 300),
        ),
      );
      final i = await probe.probe(out);
      expect(i.videoStreams.first.height, 300);
    }, skip: skip);
  }

  test('contact sheet 3x2 with timestamps', () async {
    final out = p.join(dir.path, 'sheet.png');
    await run(
      planContactSheet(
        info: video,
        output: out,
        s: const SheetParams(columns: 3, rows: 2, thumbWidth: 200, format: ImageFormat.png),
      ),
    );
    final i = await probe.probe(out);
    expect(i.videoStreams.first.width, 3 * 200 + 2 * 4 + 2 * 8);
  }, skip: skip);

  for (final (name, s) in [
    ('xfade + ken burns + audio fitted', SlideshowParams(width: 640, height: 360, kenBurns: true, fitToAudio: true)),
    ('hard cuts, fill', const SlideshowParams(width: 640, height: 360, transition: null, fit: false)),
  ]) {
    test('slideshow $name', () async {
      final params = s.fitToAudio
          ? SlideshowParams(
              width: s.width,
              height: s.height,
              kenBurns: s.kenBurns,
              fitToAudio: true,
              audio: plainAudio.path,
              audioDuration: plainAudio.duration,
            )
          : s;
      final g = slideshowGraph(pics, params);
      final i = await encode('slides_${name.split(' ').first}.mp4', g, await probe.probe(pics.first));
      expect(i.duration!.inMilliseconds, closeTo(slideshowLength(3, params).inMilliseconds, 150));
      expect(i.audioStreams.length, s.fitToAudio ? 1 : 0);
    }, skip: skip);
  }

  for (final (name, a) in [
    ('embedded cover, blur', const AudioVideoParams()),
    ('file cover, waveform', null),
    ('color, no cover', const AudioVideoParams(cover: CoverSource.color, width: 1280, height: 720)),
  ]) {
    test('audio → video: $name', () async {
      expect(song.coverArt, isNotNull);
      final params =
          a ?? AudioVideoParams(cover: CoverSource.file, image: pics[2], waveform: true, blurBackground: false);
      final i = await encode('av_${name.split(' ').first}.mp4', audioVideoGraph(song, params), song);
      expect(i.duration!.inMilliseconds, closeTo(4000, 200));
      expect(i.videoStreams.first.width, params.width);
    }, skip: skip);
  }

  for (final k in VisualKind.values) {
    test('visualizer ${k.name}', () async {
      final i = await encode('vis_${k.name}.mp4', visualizerGraph(plainAudio, VisualParams(kind: k)), plainAudio);
      expect(i.duration!.inMilliseconds, closeTo(4000, 200));
    }, skip: skip);
  }
}
