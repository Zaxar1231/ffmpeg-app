@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 10))
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
import 'package:kadra/features/audio/audio_ops.dart';
import 'package:kadra/features/convert/builtin_presets.dart';
import 'package:kadra/features/convert/convert_params.dart';
import 'package:kadra/features/gif/gif.dart';
import 'package:kadra/features/trim/trim.dart';
import 'package:path/path.dart' as p;

/// Runs every builder against a real ffmpeg, the same way the queue does
/// (placeholders, per-job temp dir as cwd, captures). Set KADRA_TEST_FFMPEG
/// to a folder with ffmpeg/ffprobe to test a specific build.
void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo sample;
  late MediaInfo music;
  late FfmpegCapabilities caps;
  late ProbeService probe;

  Future<void> run(List<JobStep> steps) async {
    final tmp = await Directory.systemTemp.createTemp('kadra_step');
    final vars = {'tmp': tmp.path};
    for (final s in steps) {
      final r = await (await runner.start(
        ToolInvocation(
          executable: ffmpeg!,
          args: substitute(s.args, vars),
          workingDirectory: substituteOpt(s.workingDirectory, vars),
        ),
      )).done;
      expect(r.success, isTrue, reason: '${s.args.join(' ')}\n${r.logText}');
      if (s.capture == StepCapture.loudnorm) {
        final m = parseLoudnormJson(r.log);
        expect(m, isNotNull, reason: r.logText);
        vars.addAll(m!);
      }
    }
    await tmp.delete(recursive: true);
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_it');
    final src = p.join(dir.path, 'sample.mkv');
    final g = await runner.capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=640x360:r=25:d=4', //
      '-f', 'lavfi', '-i', 'sine=f=440:d=4:sample_rate=48000', '-ac', '2',
      '-c:v', 'libx264', '-g', '25', '-pix_fmt', 'yuv420p', '-c:a', 'aac', src,
    ]);
    expect(g.ok, isTrue, reason: g.stderr);
    final m = p.join(dir.path, 'music.flac');
    await runner.capture(ffmpeg, ['-v', 'error', '-f', 'lavfi', '-i', 'sine=f=220:d=6:sample_rate=44100', m]);
    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    sample = await probe.probe(src);
    music = await probe.probe(m);
    caps = FfmpegCapabilities(
      version: 'test',
      configuration: const [],
      encoders: parseCodecList((await runner.capture(ffmpeg, ['-hide_banner', '-encoders'])).stdout),
      decoders: const {},
      filters: const {},
      muxers: const {},
      hwaccels: const {},
    );
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  for (final bp in builtinPresets) {
    test('preset ${bp.id}', () async {
      final out = p.join(dir.path, 'preset_${bp.id}.${bp.params.container}');
      final plan = planConvert(
        info: sample,
        output: out,
        p: bp.params,
        env: EncodeEnv(caps: caps, allowHardware: false),
      );
      if (plan.issues.contains(ConvertIssue.noVideoEncoder)) {
        markTestSkipped('encoder not in this build');
        return;
      }
      expect(plan.issues, isEmpty);
      await run(plan.steps);
      final info = await probe.probe(out);
      expect(info.videoStreams, isNotEmpty);
      expect(info.audioStreams, isNotEmpty);
      expect(info.duration!.inMilliseconds, closeTo(4000, 300));
    }, skip: skip);
  }

  test('target size lands under the limit (two-pass x264)', () async {
    final out = p.join(dir.path, 'target.mp4');
    final plan = planConvert(
      info: sample,
      output: out,
      p: const ConvertParams(rateMode: RateMode.targetSize, targetSizeMb: 0.5, audioKbps: 64, useHardware: false),
      env: EncodeEnv(caps: caps),
    );
    expect(plan.steps, hasLength(2));
    await run(plan.steps);
    final size = await File(out).length();
    expect(size, lessThanOrEqualTo(512 * 1024));
    expect(size, greaterThan(512 * 1024 * 0.6), reason: 'should use most of the budget');
  }, skip: skip);

  test('vp9 two-pass into webm', () async {
    final out = p.join(dir.path, 'vp9.webm');
    final plan = planConvert(
      info: sample,
      output: out,
      p: const ConvertParams(
        container: 'webm',
        video: VideoCodecChoice.vp9,
        audio: AudioCodecChoice.opus,
        rateMode: RateMode.bitrate,
        videoKbps: 500,
        speed: SpeedPreset.fastest,
      ),
      env: EncodeEnv(caps: caps),
    );
    expect(plan.steps, hasLength(2));
    await run(plan.steps);
    expect((await probe.probe(out)).videoStreams.single.codecName, 'vp9');
  }, skip: skip);

  test('trim fast and precise', () async {
    final fast = p.join(dir.path, 'trim_fast.mkv');
    await run(
      planTrim(
        info: sample,
        output: fast,
        ext: 'mkv',
        t: const TrimParams(start: Duration(seconds: 1), end: Duration(seconds: 3)),
      ),
    );
    // Stream copy starts at the keyframe at or before 1 s, so it may be longer.
    final fastMs = (await probe.probe(fast)).duration!.inMilliseconds;
    expect(fastMs, inInclusiveRange(1900, 3400));
    final precise = p.join(dir.path, 'trim_precise.mp4');
    await run(
      planTrim(
        info: sample,
        output: precise,
        ext: 'mp4',
        env: EncodeEnv(caps: caps, allowHardware: false),
        t: const TrimParams(
          start: Duration(milliseconds: 1200),
          end: Duration(milliseconds: 2600),
          mode: TrimMode.precise,
        ),
      ),
    );
    final info = await probe.probe(precise);
    expect(info.videoStreams.single.duration!.inMilliseconds, closeTo(1400, 80));
  }, skip: skip);

  test('extract, replace, add, remove audio', () async {
    final ext = extractExtension(ExtractFormat.copy, sourceCodec: sample.audioStreams.first.codecName);
    final a = p.join(dir.path, 'audio.$ext');
    await run(
      planExtractAudio(
        info: sample,
        output: a,
        streamIndex: sample.audioStreams.first.index,
        format: ExtractFormat.copy,
      ),
    );
    expect((await probe.probe(a)).audioStreams.single.codecName, 'aac');
    final mp3 = p.join(dir.path, 'audio.mp3');
    await run(planExtractAudio(info: sample, output: mp3, streamIndex: 1, format: ExtractFormat.mp3, kbps: 128));
    expect((await probe.probe(mp3)).audioStreams.single.codecName, 'mp3');

    final rep = p.join(dir.path, 'replaced.mp4');
    await run(planAudioTracks(video: sample, audio: music, output: rep, mode: TrackMode.replace, ext: 'mp4'));
    final ri = await probe.probe(rep);
    expect(ri.audioStreams.single.codecName, 'flac');
    expect(ri.duration!.inMilliseconds, closeTo(4000, 300), reason: '-shortest');

    final add = p.join(dir.path, 'added.mov');
    await run(
      planAudioTracks(video: sample, audio: music, output: add, mode: TrackMode.add, ext: 'mov', language: 'rus'),
    );
    final ai = await probe.probe(add);
    expect(ai.audioStreams.map((s) => s.codecName), ['aac', 'aac']);
    expect(ai.audioStreams.last.language, 'rus');

    final rm = p.join(dir.path, 'silent.mp4');
    await run(planAudioTracks(video: sample, output: rm, mode: TrackMode.remove, ext: 'mp4'));
    expect((await probe.probe(rm)).audioStreams, isEmpty);
  }, skip: skip);

  test('two-pass loudnorm hits the target', () async {
    final out = p.join(dir.path, 'loud.mkv');
    final target = loudnessTargets.firstWhere((t) => t.id == 'broadcast');
    await run(planNormalize(info: sample, output: out, target: target, ext: 'mkv'));
    final info = await probe.probe(out);
    expect(info.videoStreams.single.codecName, 'h264', reason: 'video copied');
    expect(info.audioStreams.single.sampleRate, 48000);
    // Measure the result.
    final m = await runner.capture(ffmpeg!, [
      '-hide_banner', '-i', out, '-map', '0:a', '-af', 'loudnorm=print_format=json', '-f', 'null', '-', //
    ]);
    final measured = parseLoudnormJson(m.stderr.split('\n'))!;
    expect(double.parse(measured['loudnorm.input_i']!), closeTo(-23, 1.0));
  }, skip: skip);

  test('gif, webp, apng', () async {
    for (final f in AnimFormat.values) {
      const base = GifParams(duration: Duration(seconds: 2), fps: 10, width: 200);
      final g = GifParams(format: f, duration: base.duration, fps: base.fps, width: base.width);
      final out = p.join(dir.path, 'anim.${g.ext}');
      if (f == AnimFormat.webp && !caps.hasEncoder('libwebp_anim')) continue;
      await run(planGif(info: sample, output: out, g: g));
      expect(await File(out).length(), greaterThan(1000), reason: f.name);
      // Older ffmpeg cannot decode animated WebP, so probe the others only.
      if (f != AnimFormat.webp) {
        final info = await probe.probe(out);
        expect(info.videoStreams.first.width, 200, reason: f.name);
      }
    }
  }, skip: skip);
}
