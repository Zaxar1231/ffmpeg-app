import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/capabilities.dart';
import 'package:kadra/core/engine/encoders.dart';
import 'package:kadra/core/engine/hwaccel.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/core/util/output_paths.dart';
import 'package:kadra/features/audio/audio_ops.dart';
import 'package:kadra/features/convert/builtin_presets.dart';
import 'package:kadra/features/convert/convert_params.dart';
import 'package:kadra/features/gif/gif.dart';
import 'package:kadra/features/trim/trim.dart';

MediaInfo fakeInfo({
  int height = 1080,
  Duration duration = const Duration(seconds: 60),
  String vcodec = 'h264',
  String acodec = 'aac',
  bool subs = false,
  int audioTracks = 1,
}) => MediaInfo.fromJson('/in/movie.mkv', {
  'format': {'duration': '${duration.inMicroseconds / 1e6}', 'bit_rate': '5000000'},
  'streams': [
    {
      'index': 0,
      'codec_type': 'video',
      'codec_name': vcodec,
      'width': height * 16 ~/ 9,
      'height': height,
      'avg_frame_rate': '30/1',
      'pix_fmt': 'yuv420p',
    },
    for (var i = 0; i < audioTracks; i++)
      {
        'index': 1 + i,
        'codec_type': 'audio',
        'codec_name': acodec,
        'sample_rate': '48000',
        'channels': 2,
        'bit_rate': '192000',
      },
    if (subs) {'index': 1 + audioTracks, 'codec_type': 'subtitle', 'codec_name': 'subrip'},
  ],
});

List<String> argsOf(List<JobStep> s, [int i = 0]) => s[i].args;

void main() {
  group('convert', () {
    test('quality mode with x264', () {
      final plan = planConvert(info: fakeInfo(), output: '/o/out.mp4', p: const ConvertParams(useHardware: false));
      expect(plan.ok, isTrue);
      expect(plan.encoder!.name, 'libx264');
      final a = argsOf(plan.steps);
      expect(a, containsAllInOrder(['-i', '/in/movie.mkv', '-map', '0:0', '-map', '0:a']));
      expect(a, containsAllInOrder(['-c:v', 'libx264', '-crf', '23', '-preset', 'medium', '-pix_fmt', 'yuv420p']));
      expect(a, containsAllInOrder(['-c:a', 'aac', '-b:a', '192k']));
      expect(a, containsAllInOrder(['-movflags', '+faststart', '/o/out.mp4']));
      expect(a.last, '/o/out.mp4');
    });

    test('downscale only when taller, keeps aspect', () {
      final p = const ConvertParams(maxHeight: 720, useHardware: false);
      expect(
        argsOf(planConvert(info: fakeInfo(), output: 'o.mp4', p: p).steps),
        containsAllInOrder(['-vf', 'scale=-2:720:flags=lanczos']),
      );
      expect(argsOf(planConvert(info: fakeInfo(height: 480), output: 'o.mp4', p: p).steps), isNot(contains('-vf')));
    });

    test('target size computes bitrate and uses two passes', () {
      final plan = planConvert(
        info: fakeInfo(duration: const Duration(seconds: 80)),
        output: '/o/out.mp4',
        p: const ConvertParams(rateMode: RateMode.targetSize, targetSizeMb: 10, audioKbps: 96, useHardware: false),
      );
      // 10 MiB * 8 / 80 s = 1048.6 kbps, *0.97 = 1017, minus 96 = 921
      expect(plan.videoKbps, 921);
      expect(plan.steps, hasLength(2));
      final p1 = argsOf(plan.steps, 0);
      final p2 = argsOf(plan.steps, 1);
      expect(p1, containsAllInOrder(['-b:v', '921k', '-fps_mode', 'vfr', '-pass', '1', '-passlogfile', 'kadra2pass']));
      expect(p1, containsAllInOrder(['-an', '-f', 'null', '-']));
      expect(p2, containsAllInOrder(['-b:v', '921k', '-pass', '2', '-passlogfile', 'kadra2pass']));
      expect(plan.steps.every((s) => s.workingDirectory == '{{tmp}}'), isTrue);
      expect(plan.estimatedBytes, closeTo(10 * 1024 * 1024 * 0.97, 10 * 1024 * 1024 * 0.02));
    });

    test('x265 two-pass uses x265-params and hvc1 tag in mp4', () {
      final plan = planConvert(
        info: fakeInfo(),
        output: 'o.mp4',
        p: const ConvertParams(
          video: VideoCodecChoice.hevc,
          rateMode: RateMode.bitrate,
          videoKbps: 3000,
          useHardware: false,
        ),
      );
      expect(argsOf(plan.steps, 0), containsAllInOrder(['-x265-params', 'pass=1:stats=kadra2pass.log']));
      expect(argsOf(plan.steps, 1), containsAllInOrder(['-tag:v', 'hvc1']));
    });

    test('target too small and unknown duration are reported', () {
      final tiny = planConvert(
        info: fakeInfo(duration: const Duration(hours: 2)),
        output: 'o.mp4',
        p: const ConvertParams(rateMode: RateMode.targetSize, targetSizeMb: 5),
      );
      expect(tiny.issues, contains(ConvertIssue.targetTooSmall));
      final noDur = MediaInfo.fromJson('x', {
        'format': {},
        'streams': [
          {'index': 0, 'codec_type': 'video', 'codec_name': 'h264', 'height': 100},
        ],
      });
      expect(
        planConvert(
          info: noDur,
          output: 'o.mp4',
          p: const ConvertParams(rateMode: RateMode.targetSize),
        ).issues,
        contains(ConvertIssue.durationUnknown),
      );
    });

    test('container compatibility', () {
      expect(
        planConvert(
          info: fakeInfo(),
          output: 'o.webm',
          p: const ConvertParams(container: 'webm'),
        ).issues,
        containsAll([ConvertIssue.videoNotInContainer, ConvertIssue.audioNotInContainer]),
      );
      expect(
        planConvert(
          info: fakeInfo(acodec: 'pcm_s16le'),
          output: 'o.mp4',
          p: const ConvertParams(video: VideoCodecChoice.copy, audio: AudioCodecChoice.copy),
        ).issues,
        contains(ConvertIssue.copyNotInContainer),
      );
    });

    test('mkv keeps subtitles; audio-only container drops video', () {
      final mkv = argsOf(
        planConvert(
          info: fakeInfo(subs: true),
          output: 'o.mkv',
          p: const ConvertParams(container: 'mkv'),
        ).steps,
      );
      expect(mkv, containsAllInOrder(['-map', '0:s', '-c:s', 'copy']));
      final m4a = argsOf(
        planConvert(
          info: fakeInfo(),
          output: 'o.m4a',
          p: const ConvertParams(container: 'm4a'),
        ).steps,
      );
      expect(m4a, contains('-vn'));
      expect(m4a, isNot(contains('-c:v')));
    });

    test('hardware encoder from the trial report', () {
      final hw = HwAccelReport(
        hwaccels: const {'cuda'},
        working: knownHwEncoders.where((e) => e.name == 'h264_nvenc').toList(),
        failed: const {},
      );
      final plan = planConvert(
        info: fakeInfo(),
        output: 'o.mp4',
        p: const ConvertParams(),
        env: EncodeEnv(hw: hw),
      );
      expect(plan.encoder!.name, 'h264_nvenc');
      expect(argsOf(plan.steps), containsAllInOrder(['-rc', 'vbr', '-cq', '23', '-b:v', '0', '-preset', 'p4']));
      // Globally disabled → software.
      expect(
        planConvert(
          info: fakeInfo(),
          output: 'o.mp4',
          p: const ConvertParams(),
          env: EncodeEnv(hw: hw, allowHardware: false),
        ).encoder!.name,
        'libx264',
      );
    });

    test('vaapi adds device and upload filters', () {
      final plan = planConvert(
        info: fakeInfo(),
        output: 'o.mkv',
        p: const ConvertParams(container: 'mkv', encoderOverride: 'hevc_vaapi'),
      );
      final a = argsOf(plan.steps);
      expect(a, containsAllInOrder(['-vaapi_device', '/dev/dri/renderD128', '-i']));
      expect(a, containsAllInOrder(['-vf', 'format=nv12,hwupload']));
      expect(a, isNot(contains('-pix_fmt')));
    });

    test('encoder picked from the build, not assumed', () {
      const caps = FfmpegCapabilities(
        version: '7.0',
        configuration: [],
        encoders: {'libaom-av1': CodecEntry('libaom-av1', MediaKind.video, '')},
        decoders: {},
        filters: {},
        muxers: {},
        hwaccels: {},
      );
      expect(pickVideoEncoder(VideoCodecChoice.av1, caps: caps)!.name, 'libaom-av1');
      expect(pickVideoEncoder(VideoCodecChoice.h264, caps: caps), isNull);
    });

    test('params json roundtrip and tolerance', () {
      const p = ConvertParams(container: 'mkv', video: VideoCodecChoice.av1, quality: 30, maxHeight: 720, fps: 29.97);
      final back = ConvertParams.fromJson(p.toJson());
      expect(back.toJson(), p.toJson());
      expect(ConvertParams.fromJson({'container': 'zzz', 'video': 'nope'}).container, 'mp4');
    });

    test('every builtin preset plans cleanly for a typical file', () {
      for (final bp in builtinPresets) {
        final plan = planConvert(info: fakeInfo(), output: 'o.${bp.params.container}', p: bp.params);
        expect(plan.issues, isEmpty, reason: bp.id);
      }
    });
  });

  group('trim', () {
    test('fast is stream copy with input seek', () {
      final s = planTrim(
        info: fakeInfo(),
        output: 'o.mkv',
        ext: 'mkv',
        t: const TrimParams(start: Duration(seconds: 10), end: Duration(seconds: 25)),
      );
      expect(
        s.single.args,
        containsAllInOrder([
          '-ss',
          '00:00:10.000',
          '-i',
          '/in/movie.mkv',
          '-map',
          '0',
          '-t',
          '00:00:15.000',
          '-c',
          'copy',
        ]),
      );
      expect(s.single.totalDuration, const Duration(seconds: 15));
    });

    test('precise re-encodes in the source family', () {
      final s = planTrim(
        info: fakeInfo(vcodec: 'hevc'),
        output: 'o.mp4',
        ext: 'mp4',
        t: const TrimParams(start: Duration(seconds: 1), end: Duration(seconds: 2), mode: TrimMode.precise),
      );
      final a = s.single.args;
      expect(a, containsAllInOrder(['-ss', '00:00:01.000', '-i']));
      expect(a, contains('libx265'));
      expect(a.sublist(a.length - 3), ['-t', '00:00:01.000', 'o.mp4']);
    });
  });

  group('audio', () {
    test('extract copy and convert', () {
      expect(extractExtension(ExtractFormat.copy, sourceCodec: 'aac'), 'm4a');
      expect(extractExtension(ExtractFormat.copy, sourceCodec: 'dts'), 'mka');
      final copy = planExtractAudio(info: fakeInfo(), output: 'o.m4a', streamIndex: 1, format: ExtractFormat.copy);
      expect(copy.single.args, containsAllInOrder(['-map', '0:1', '-vn', '-c:a', 'copy', 'o.m4a']));
      final mp3 = planExtractAudio(
        info: fakeInfo(),
        output: 'o.mp3',
        streamIndex: 1,
        format: ExtractFormat.mp3,
        kbps: 320,
      );
      expect(mp3.single.args, containsAllInOrder(['-c:a', 'libmp3lame', '-b:a', '320k']));
    });

    test('replace, add and remove tracks', () {
      final audio = MediaInfo.fromJson('/a/music.flac', {
        'format': {'duration': '60'},
        'streams': [
          {'index': 0, 'codec_type': 'audio', 'codec_name': 'flac'},
        ],
      });
      final rep = planAudioTracks(
        video: fakeInfo(),
        audio: audio,
        output: 'o.mp4',
        mode: TrackMode.replace,
        ext: 'mp4',
      );
      expect(
        rep.single.args,
        containsAllInOrder(['-i', '/in/movie.mkv', '-i', '/a/music.flac', '-map', '0:v?', '-map', '1:a:0']),
      );
      // flac is accepted by mp4 → copy
      expect(rep.single.args, containsAllInOrder(['-c', 'copy', '-c:a:0', 'copy', '-shortest']));
      final add = planAudioTracks(
        video: fakeInfo(audioTracks: 2),
        audio: audio,
        output: 'o.mov',
        mode: TrackMode.add,
        ext: 'mov',
        language: 'rus',
      );
      // mov does not take flac → encode the new (third) track
      expect(add.single.args, containsAllInOrder(['-map', '0:a?', '-map', '1:a:0', '-c', 'copy', '-c:a:2', 'aac']));
      expect(add.single.args, containsAllInOrder(['-metadata:s:a:2', 'language=rus']));
      final rm = planAudioTracks(video: fakeInfo(), output: 'o.mp4', mode: TrackMode.remove, ext: 'mp4');
      expect(rm.single.args, containsAllInOrder(['-map', '0', '-an', '-c', 'copy']));
    });

    test('two-pass loudnorm', () {
      final s = planNormalize(info: fakeInfo(), output: 'o.mkv', target: loudnessTargets.first, ext: 'mkv');
      expect(s, hasLength(2));
      expect(s[0].capture, StepCapture.loudnorm);
      expect(s[0].args, containsAllInOrder(['-v', 'info']));
      expect(
        s[0].args,
        containsAllInOrder(['-af', 'loudnorm=I=-14.0:TP=-1.0:LRA=11.0:print_format=json', '-f', 'null', '-']),
      );
      final applied = substitute(s[1].args, {
        'loudnorm.input_i': '-20.1',
        'loudnorm.input_tp': '-3.0',
        'loudnorm.input_lra': '5.5',
        'loudnorm.input_thresh': '-30.4',
        'loudnorm.target_offset': '0.3',
      });
      expect(
        applied.join(' '),
        contains('measured_I=-20.1:measured_TP=-3.0:measured_LRA=5.5:measured_thresh=-30.4:offset=0.3:linear=true'),
      );
      expect(applied, containsAllInOrder(['-c:v', 'copy', '-c:s', 'copy']));
      expect(applied, containsAllInOrder(['-ar', '48000']));
    });
  });

  group('gif', () {
    test('palette pipeline', () {
      final s = planGif(
        info: fakeInfo(),
        output: 'o.gif',
        g: const GifParams(start: Duration(seconds: 2), duration: Duration(seconds: 3)),
      );
      final a = s.single.args;
      expect(a, containsAllInOrder(['-ss', '00:00:02.000', '-t', '00:00:03.000', '-i']));
      expect(
        a,
        contains(
          '[0:v]fps=15,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse=dither=sierra2_4a[out]',
        ),
      );
      expect(a, containsAllInOrder(['-map', '[out]', '-loop', '0', 'o.gif']));
    });
    test('webp and apng', () {
      expect(
        planGif(
          info: fakeInfo(),
          output: 'o.webp',
          g: const GifParams(format: AnimFormat.webp),
        ).single.args,
        containsAllInOrder(['-c:v', 'libwebp_anim', '-lossless', '0', '-quality', '75']),
      );
      expect(
        planGif(
          info: fakeInfo(),
          output: 'o.png',
          g: const GifParams(format: AnimFormat.apng, loop: false),
        ).single.args,
        containsAllInOrder(['-c:v', 'apng', '-plays', '1', '-f', 'apng']),
      );
    });
  });

  group('steps', () {
    test('json roundtrip and legacy format', () {
      final steps = [
        const JobStep(
          args: ['-a'],
          label: '1/2',
          weight: 0.3,
          capture: StepCapture.loudnorm,
          workingDirectory: '{{tmp}}',
        ),
        const JobStep(args: ['-b'], totalDuration: Duration(seconds: 3)),
      ];
      final back = decodeSteps(encodeSteps(steps));
      expect(back[0].capture, StepCapture.loudnorm);
      expect(back[0].workingDirectory, '{{tmp}}');
      expect(back[1].totalDuration, const Duration(seconds: 3));
      expect(decodeSteps('["-version"]').single.args, ['-version']);
    });
    test('substitute fails loudly on missing values', () {
      expect(substitute(['a={{x}}'], {'x': '1'}), ['a=1']);
      expect(() => substitute(['{{y}}'], {}), throwsStateError);
    });
    test('loudnorm json parsing', () {
      final log = [
        '[Parsed_loudnorm_0 @ 0x1] ',
        '{',
        '\t"input_i" : "-27.61",',
        '\t"input_tp" : "-4.47",',
        '\t"input_lra" : "18.06",',
        '\t"input_thresh" : "-39.20",',
        '\t"output_i" : "-16.58",',
        '\t"target_offset" : "0.58"',
        '}',
      ];
      expect(parseLoudnormJson(log)!['loudnorm.input_i'], '-27.61');
      expect(
        parseLoudnormJson([
          ...log.take(1),
          '{"input_i":"-inf","input_tp":"-inf","input_lra":"0","input_thresh":"-70","target_offset":"0"}',
        ]),
        isNull,
      );
      expect(parseLoudnormJson(['nothing']), isNull);
    });
    test('overall fraction', () {
      const s = [JobStep(args: [], weight: 0.4), JobStep(args: [], weight: 0.6)];
      expect(overallFraction(s, 0, 0.5), closeTo(0.2, 1e-9));
      expect(overallFraction(s, 1, 0.5), closeTo(0.7, 1e-9));
    });
    test('yt-dlp file marker', () {
      expect(parseYtdlpFilePath(['x', '[kadra-file] /d/a b.mp4']), '/d/a b.mp4');
    });
  });

  test('output paths never overwrite', () {
    final existing = {'/o/a_x.mp4', '/o/a_x (2).mp4'};
    expect(outputPathFor('/i/a.mkv', ext: 'mp4', suffix: '_x', dir: '/o', exists: existing.contains), '/o/a_x (3).mp4');
    expect(outputPathFor('/o/a.mp4', ext: 'mp4', dir: '/o', exists: (_) => false), '/o/a (2).mp4');
  });
}
