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
import 'package:kadra/features/convert/convert_params.dart';
import 'package:kadra/features/edit/copy_ops.dart';
import 'package:kadra/features/edit/edit_encode.dart';
import 'package:kadra/features/edit/graphs.dart';
import 'package:path/path.dart' as p;

/// Every editing graph against a real ffmpeg (KADRA_TEST_FFMPEG selects a build).
void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo sample; // 640x360 25 fps, 4 s, stereo AAC
  late MediaInfo small; // 320x240 30 fps, 2 s, no audio
  late MediaInfo hdr; // 10-bit HEVC tagged PQ/BT.2020, 1 s
  late String logo;
  late String lut;
  late EncodeEnv env;
  late ProbeService probe;
  late Set<String> filters;

  Future<List<String>> run(List<JobStep> steps) async {
    final tmp = await Directory.systemTemp.createTemp('kadra_step');
    final vars = {'tmp': tmp.path};
    final log = <String>[];
    for (final s in steps) {
      for (final f in s.files.entries) {
        await File(substitute([f.key], vars).single).writeAsString(substitute([f.value], vars).single);
      }
      final r = await (await runner.start(
        ToolInvocation(
          executable: ffmpeg!,
          args: substitute(s.args, vars),
          workingDirectory: substituteOpt(s.workingDirectory, vars),
        ),
      )).done;
      expect(r.success, isTrue, reason: '${s.args.join(' ')}\n${r.logText}');
      log.addAll(r.log);
    }
    await tmp.delete(recursive: true);
    return log;
  }

  Future<MediaInfo> encode(
    String name,
    EditGraph g, {
    MediaInfo? info,
    String? cwd,
    List<JobStep> pre = const [],
    bool eightBit = false,
  }) async {
    final out = p.join(dir.path, name);
    final plan = planEdit(
      info: info ?? sample,
      output: out,
      graph: g,
      out: EditOutput(ext: p.extension(name).substring(1), speed: SpeedPreset.fastest),
      env: env,
      workingDirectory: cwd,
      eightBit: eightBit,
    );
    expect(plan.issues, isEmpty);
    await run([...pre, ...plan.steps]);
    return probe.probe(out);
  }

  void expectDur(MediaInfo i, int ms, {int tol = 150}) => expect(i.duration!.inMilliseconds, closeTo(ms, tol));
  (int, int) size(MediaInfo i) => (i.videoStreams.first.width!, i.videoStreams.first.height!);

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_edit');
    Future<void> gen(List<String> a) async {
      final r = await runner.capture(ffmpeg!, ['-v', 'error', '-y', ...a]);
      expect(r.ok, isTrue, reason: r.stderr);
    }

    final a = p.join(dir.path, 'a.mp4'), b = p.join(dir.path, 'b.mkv'), h = p.join(dir.path, 'hdr.mkv');
    await gen([
      '-f', 'lavfi', '-i', 'testsrc2=s=640x360:r=25:d=4', '-f', 'lavfi', '-i', 'sine=f=440:d=4:sample_rate=48000', //
      '-ac', '2', '-c:v', 'libx264', '-g', '25', '-pix_fmt', 'yuv420p', '-c:a', 'aac', a,
    ]);
    await gen(['-f', 'lavfi', '-i', 'testsrc=s=320x240:r=30:d=2', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', b]);
    await gen([
      '-f', 'lavfi', '-i', 'testsrc2=s=320x180:r=25:d=1', '-c:v', 'libx265', '-pix_fmt', 'yuv420p10le', //
      '-vf',
      'setparams=color_trc=smpte2084:color_primaries=bt2020:colorspace=bt2020nc',
      '-x265-params',
      'log-level=error',
      h,
    ]);
    logo = p.join(dir.path, 'logo.png');
    await gen(['-f', 'lavfi', '-i', 'color=c=red@0.8:s=200x100,format=rgba', '-frames:v', '1', logo]);
    lut = p.join(dir.path, "my lut's.cube");
    await File(lut).writeAsString('LUT_3D_SIZE 2\n0 0 0\n1 0 0\n0 1 0\n1 1 0\n0 0 1\n1 0 1\n0 1 1\n1 1 1\n');
    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    sample = await probe.probe(a);
    small = await probe.probe(b);
    hdr = await probe.probe(h);
    final caps = FfmpegCapabilities(
      version: 'test',
      configuration: const [],
      encoders: parseCodecList((await runner.capture(ffmpeg!, ['-hide_banner', '-encoders'])).stdout),
      decoders: const {},
      filters: const {},
      muxers: const {},
      hwaccels: const {},
    );
    env = EncodeEnv(caps: caps, allowHardware: false);
    final fl = (await runner.capture(ffmpeg, ['-hide_banner', '-filters'])).stdout;
    filters = {
      for (final l in fl.split('\n'))
        if (l.trim().split(RegExp(r'\s+')).length > 2) l.trim().split(RegExp(r'\s+'))[1],
    };
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  group('cut', () {
    test('keep two ranges, frame-accurate', () async {
      final keep = [
        (const Duration(milliseconds: 500), const Duration(seconds: 1)),
        (const Duration(seconds: 2), const Duration(milliseconds: 3500)),
      ];
      final i = await encode('cut.mp4', cutGraph(sample, keep));
      expectDur(i, 2000, tol: 80);
      expect(i.audioStreams, isNotEmpty);
    }, skip: skip);

    test('remove range (inverted) without audio', () async {
      final keep = invertRanges([(const Duration(milliseconds: 500), const Duration(seconds: 1))], small.duration!);
      final i = await encode('cut_noaudio.mkv', cutGraph(small, keep), info: small);
      expectDur(i, 1500, tol: 80);
      expect(i.audioStreams, isEmpty);
    }, skip: skip);

    test('stream copy via concat demuxer', () async {
      final out = p.join(dir.path, "cut copy's.mp4");
      await run(
        planCutCopy(sample, [
          (Duration.zero, const Duration(seconds: 1)),
          (const Duration(seconds: 3), const Duration(seconds: 4)),
        ], out),
      );
      final i = await probe.probe(out);
      expectDur(i, 2000, tol: 300);
    }, skip: skip);
  });

  group('concat', () {
    test('re-encode different sizes, one without audio', () async {
      final clips = [sample, small, sample];
      final i = await encode('concat.mp4', concatGraph(clips, JoinFrame.of(sample)));
      expectDur(i, 10000, tol: 200);
      expect(size(i), (640, 360));
      expect(i.audioStreams, isNotEmpty);
    }, skip: skip);

    test('stream copy of identical files', () async {
      expect(concatMismatches([sample, sample]), isEmpty);
      expect(concatMismatches([sample, small]), containsAll(['size', 'audio']));
      final out = p.join(dir.path, 'concat_copy.mp4');
      await run(planConcatCopy([sample, sample], out));
      expectDur(await probe.probe(out), 8000, tol: 200);
    }, skip: skip);

    test('xfade transitions with fades', () async {
      final g = transitionGraph(
        [sample, small, sample],
        JoinFrame.of(sample),
        transition: 'wipeleft',
        d: const Duration(milliseconds: 500),
        fadeIn: const Duration(milliseconds: 300),
        fadeOut: const Duration(milliseconds: 300),
      );
      expect(g.duration!.inMilliseconds, 9000);
      final i = await encode('xfade.mp4', g);
      expectDur(i, 9000, tol: 200);
    }, skip: skip);

    test('every xfade transition name exists in this build', () async {
      final help = (await runner.capture(ffmpeg!, ['-hide_banner', '-h', 'filter=xfade'])).stdout;
      for (final t in xfadeTransitions) {
        expect(RegExp('^\\s+$t\\s', multiLine: true).hasMatch(help), isTrue, reason: t);
      }
    }, skip: skip);

    test('fade in/out of one file', () async {
      final i = await encode('fade.mp4', fadeGraph(sample, const Duration(seconds: 1), const Duration(seconds: 1)));
      expectDur(i, 4000);
    }, skip: skip);
  });

  group('split', () {
    test('every second, copy', () async {
      final out = p.join(dir.path, 'split', 'part.mp4');
      await Directory(p.dirname(out)).create();
      await run(
        planSplit(
          info: sample,
          s: const SplitParams(every: Duration(seconds: 1)),
          output: out,
        ),
      );
      final files = Directory(p.dirname(out)).listSync().whereType<File>().toList();
      expect(files.length, 4);
    }, skip: skip);

    test('at times, precise', () async {
      final out = p.join(dir.path, 'split2', 'part.mp4');
      await Directory(p.dirname(out)).create();
      final s = SplitParams(
        mode: SplitMode.times,
        times: const [Duration(milliseconds: 700), Duration(milliseconds: 2300)],
        precise: true,
      );
      expect(splitCount(sample, s), 3);
      await run(
        planSplit(
          info: sample,
          s: s,
          output: out,
          out: const EditOutput(speed: SpeedPreset.fastest),
          env: env,
        ),
      );
      final files = Directory(p.dirname(out)).listSync().whereType<File>().map((f) => f.path).toList()..sort();
      expect(files.length, 3);
      expectDur(await probe.probe(files.first), 700, tol: 80);
    }, skip: skip);
  });

  group('crop & scale', () {
    test('crop + rotate 90', () async {
      final prm = CropScaleParams(crop: const CropRect(101, 21, 301, 201), rotate: 90);
      final i = await encode('crop.mp4', cropScaleGraph(sample, prm));
      expect(size(i), (200, 300));
      expect(i.audioStreams.first.codecName, 'aac'); // copied
    }, skip: skip);

    for (final fit in FitMode.values) {
      test('vertical 9:16 1280 high, ${fit.name}', () async {
        final prm = CropScaleParams(aspect: 9 / 16, height: 1280, fit: fit);
        final i = await encode('vert_${fit.name}.mp4', cropScaleGraph(sample, prm));
        expect(size(i), (720, 1280));
      }, skip: skip);
    }

    test('free angle and flips, downscale to 240p', () async {
      final prm = CropScaleParams(angle: 10, hflip: true, vflip: true, height: 240);
      final i = await encode('angle.mkv', cropScaleGraph(sample, prm));
      expect(size(i).$2, 240);
    }, skip: skip);

    test('cropdetect output parses', () async {
      final r = await runner.capture(ffmpeg!, [
        '-hide_banner', '-f', 'lavfi', '-i', 'testsrc2=s=640x360:d=1,pad=640:480:0:60:black', //
        '-vf', 'cropdetect=round=2', '-f', 'null', '-',
      ]);
      final c = parseCropdetect(r.stderr.split('\n'));
      expect(c, const CropRect(0, 60, 640, 360));
    }, skip: skip);
  });

  group('speed', () {
    test('2x keep pitch', () async {
      final i = await encode('fast.mp4', speedGraph(sample, const SpeedParams(factor: 2)));
      expectDur(i, 2000);
    }, skip: skip);

    test('0.25x change pitch + interpolate to 30 fps', () async {
      final i = await encode(
        'slow.mp4',
        speedGraph(sample, const SpeedParams(factor: 0.25, audio: SpeedAudio.changePitch, fps: 30, interpolate: true)),
      );
      expectDur(i, 16000, tol: 300);
    }, skip: skip);

    test('reverse, mute, 15 fps', () async {
      final i = await encode(
        'rev.mp4',
        speedGraph(sample, const SpeedParams(reverse: true, audio: SpeedAudio.mute, fps: 15)),
      );
      expect(i.audioStreams, isEmpty);
      expect(i.videoStreams.first.avgFrameRate, closeTo(15, 0.1));
    }, skip: skip);

    test('atempo chain', () {
      expect(atempoChain(0.25), ['atempo=0.5', 'atempo=0.5']);
      expect(atempoChain(0.3), ['atempo=0.5', 'atempo=0.6']);
      expect(atempoChain(4), ['atempo=4']);
    });
  });

  group('restore', () {
    test('deinterlace + denoise + sharpen', () async {
      final prm = RestoreParams(deinterlace: Deinterlace.bwdif, denoise: Denoise.medium, sharpen: Sharpen.cas);
      await encode('restore.mp4', restoreGraph(sample, prm));
    }, skip: skip);

    test('nlmeans + yadif', () async {
      final prm = RestoreParams(deinterlace: Deinterlace.yadif, denoise: Denoise.nlmeans, sharpen: Sharpen.strong);
      await encode('restore2.mp4', restoreGraph(small, prm), info: small);
    }, skip: skip);

    test('vidstab two-pass', () async {
      if (!filters.contains('vidstabdetect')) return markTestSkipped('no libvidstab');
      const prm = RestoreParams(stabilize: true);
      final i = await encode(
        'stab.mp4',
        restoreGraph(sample, prm),
        cwd: '{{tmp}}',
        pre: [JobStep(args: vidstabDetectArgs(sample, prm), workingDirectory: '{{tmp}}')],
      );
      expectDur(i, 4000);
    }, skip: skip);

    test('deshake fallback', () async {
      await encode(
        'deshake.mp4',
        restoreGraph(small, const RestoreParams(stabilize: true, useVidstab: false)),
        info: small,
      );
    }, skip: skip);
  });

  group('color', () {
    for (final look in ColorLook.values) {
      test('look ${look.name} + eq + temperature', () async {
        final prm = ColorParams(
          look: look,
          brightness: 0.05,
          contrast: 1.1,
          saturation: 1.2,
          temperature: 5000,
          hue: 10,
          vignette: true,
        );
        await encode('color_${look.name}.mp4', colorGraph(small, prm), info: small);
      }, skip: skip);
    }

    test('LUT with quote in path, full and partial', () async {
      await encode('lut_full.mp4', colorGraph(small, ColorParams(lutPath: lut)), info: small);
      await encode(
        'lut_mix.mp4',
        colorGraph(small, ColorParams(lutPath: lut, lutMix: 0.5, contrast: 1.2)),
        info: small,
      );
    }, skip: skip);
  });

  group('overlay', () {
    test('logo + text with special chars + timecode, time window', () async {
      final prm = OverlayParams(
        imagePath: logo,
        imageOpacity: 0.6,
        text: "It's 50% off: a,b [x] \\ done",
        timecode: true,
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 3),
      );
      final i = await encode('overlay.mp4', overlayGraph(sample, prm));
      expectDur(i, 4000);
      expect(size(i), (640, 360));
    }, skip: skip);

    test('text only, no box, top-left', () async {
      await encode(
        'text.mkv',
        overlayGraph(small, const OverlayParams(text: 'Привет', textBox: false, textCorner: Corner.topLeft)),
        info: small,
      );
    }, skip: skip);
  });

  group('blur', () {
    for (final mode in BlurMode.values) {
      test('two regions, ${mode.name}', () async {
        final prm = BlurParams(
          mode: mode,
          regions: [
            const BlurRegion(CropRect(0, 0, 120, 60)),
            const BlurRegion(CropRect(560, 300, 200, 200), from: Duration(seconds: 1), to: Duration(seconds: 2)),
          ],
        );
        await encode('blur_${mode.name}.mp4', blurGraph(sample, prm));
      }, skip: skip);
    }

    test('whole frame', () async {
      await encode('blur_all.mp4', blurGraph(small, const BlurParams(wholeFrame: true)), info: small);
    }, skip: skip);
  });

  group('stack', () {
    for (final layout in StackLayout.values) {
      test('${layout.name} with mixed audio', () async {
        final g = stackGraph([sample, small, sample], StackParams(layout: layout, audio: StackAudio.mix));
        final i = await encode('stack_${layout.name}.mp4', g);
        expect(i.audioStreams, isNotEmpty);
      }, skip: skip);
    }

    test('side by side size, shortest', () async {
      final i = await encode('sbs.mp4', stackGraph([sample, small], const StackParams()));
      expect(size(i), (640 + 480, 360));
      expectDur(i, 2000);
    }, skip: skip);
  });

  group('loop', () {
    test('repeat 3 times', () async {
      final i = await encode('loop.mp4', loopGraph(sample, const LoopParams(times: 3)));
      expectDur(i, 12000, tol: 200);
    }, skip: skip);

    test('boomerang x2 with audio', () async {
      final i = await encode(
        'boom.mp4',
        loopGraph(small, const LoopParams(mode: LoopMode.boomerang, times: 2)),
        info: small,
      );
      expectDur(i, 8000, tol: 200);
    }, skip: skip);
  });

  group('hdr', () {
    test('zscale + tonemap', () async {
      expect(isHdr(hdr), isTrue);
      final i = await encode('sdr.mp4', hdrToSdrGraph(hdr), info: hdr, eightBit: true);
      expect(i.videoStreams.first.pixFmt, 'yuv420p');
    }, skip: skip);
  });

  group('frame preview', () {
    final cases = <String, EditGraph Function()>{
      'original': () => const EditGraph(complex: ''),
      'overlay': () => overlayGraph(sample, OverlayParams(imagePath: logo, text: 'x', timecode: true)),
      'speed (audio label)': () => speedGraph(sample, const SpeedParams(factor: 2)),
      'blur': () => blurGraph(sample, const BlurParams(regions: [BlurRegion(CropRect(10, 10, 100, 100))])),
      'crop vertical blur': () => cropScaleGraph(sample, const CropScaleParams(aspect: 9 / 16, fit: FitMode.blur)),
      'stack': () => stackGraph([sample, small], const StackParams(audio: StackAudio.mix)),
      'fade': () => fadeGraph(sample, const Duration(seconds: 1), const Duration(seconds: 1)),
      'loop': () => loopGraph(sample, const LoopParams()),
    };
    for (final e in cases.entries) {
      test(e.key, () async {
        final out = p.join(dir.path, 'frame_${e.key.split(' ').first}.png');
        final g = e.value();
        final args = previewFrameArgs(
          info: sample,
          at: const Duration(milliseconds: 1500),
          output: out,
          graph: g,
          original: e.key == 'original',
        );
        final r = await runner.capture(ffmpeg!, args);
        expect(r.ok, isTrue, reason: '${args.join(' ')}\n${r.stderr}');
        expect(await File(out).length(), greaterThan(1000));
      }, skip: skip);
    }
  });
}
