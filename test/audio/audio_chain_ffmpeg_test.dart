@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 10))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/features/audio/audio_chain.dart';
import 'package:kadra/features/audio_editor/engine/effects.dart';
import 'package:kadra/features/audio_editor/engine/render.dart' show smokeTestArgs;
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  // An RNNoise model file (e.g. sh.rnnn) to test arnndn; skipped otherwise.
  final rnnoise = Platform.environment['KADRA_TEST_RNNOISE'];
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo video;
  late MediaInfo voice;
  late MediaInfo music;
  late ProbeService probe;
  late Set<String> filters;

  Future<void> run(List<JobStep> steps) async {
    for (final s in steps) {
      final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: s.args))).done;
      expect(r.success, isTrue, reason: '${s.args.join(' ')}\n${r.logText}');
    }
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_ach');
    Future<String> gen(String name, List<String> a) async {
      final out = p.join(dir.path, name);
      final r = await runner.capture(ffmpeg!, ['-v', 'error', '-y', ...a, out]);
      expect(r.ok, isTrue, reason: r.stderr);
      return out;
    }

    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    video = await probe.probe(
      await gen('v.mp4', [
        '-f', 'lavfi', '-i', 'testsrc2=s=320x240:d=3', '-f', 'lavfi', //
        '-i', 'sine=f=300:d=3:sample_rate=48000,aformat=channel_layouts=stereo',
        '-c:v', 'libx264', '-c:a', 'aac',
      ]),
    );
    // "Voice" with pauses: 0.5 s tone, 0.5 s silence…
    voice = await probe.probe(
      await gen('voice.wav', ['-f', 'lavfi', '-i', "aevalsrc='if(lt(mod(t,1),0.5),sin(2*PI*2000*t),0)':d=4:s=44100"]),
    );
    music = await probe.probe(await gen('music.mp3', ['-f', 'lavfi', '-i', 'sine=f=200:d=1.5']));
    final fl = (await runner.capture(ffmpeg!, ['-hide_banner', '-filters'])).stdout;
    filters = {
      for (final l in fl.split('\n'))
        if (l.trim().split(RegExp(r'\s+')).length > 2) l.trim().split(RegExp(r'\s+'))[1],
    };
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  test('every whole-file effect keeps video and length', () async {
    final usable = fxCatalog.where((d) => fxUsableOnFile(d, hasVideo: true)).toList();
    expect(usable.length, greaterThan(25));
    final ctx = fileFxContext(video);
    for (final d in usable) {
      if (!d.filters.every(filters.contains)) continue;
      // Effects that crash in some builds are caught by the smoke test.
      final smoke = await runner.capture(ffmpeg!, smokeTestArgs(d.build!(d.defaults(), ctx)));
      if (!smoke.ok) continue;
      final out = p.join(dir.path, 'fx_${d.id}.mp4');
      await run(
        planAudioChain(info: video, output: out, filters: chainFilters([ChainItem.fx(d.id, d.defaults())], ctx)),
      );
      final i = await probe.probe(out);
      expect(i.videoStreams.single.codecName, 'h264', reason: d.id);
      expect(i.duration!.inMilliseconds, closeTo(3000, 120), reason: d.id);
    }
  }, skip: skip);

  test('chain of several effects on audio-only file (FLAC)', () async {
    final ctx = fileFxContext(voice);
    final items = [
      ChainItem.fx('highPass', fxById('highPass').defaults()),
      ChainItem.fx('noiseReduction', fxById('noiseReduction').defaults()),
      ChainItem.fx('changeTempo', fxById('changeTempo').defaults()..['percent'] = 50),
    ];
    final out = p.join(dir.path, 'chain.flac');
    await run(planAudioChain(info: voice, output: out, filters: chainFilters(items, ctx)));
    final i = await probe.probe(out);
    expect(i.audioStreams.single.codecName, 'flac');
  }, skip: skip);

  test('RNNoise with a model whose path needs escaping', () async {
    if (rnnoise == null) return markTestSkipped('KADRA_TEST_RNNOISE not set');
    final model = p.join(dir.path, "model's: dir", 'm.rnnn');
    await Directory(p.dirname(model)).create();
    await File(rnnoise).copy(model);
    final out = p.join(dir.path, 'rnn.mp4');
    await run(
      planAudioChain(
        info: video,
        output: out,
        filters: chainFilters([ChainItem.rnnoise(model, mix: 0.8)], fileFxContext(video)),
      ),
    );
  }, skip: skip);

  test('preview segment', () async {
    final out = p.join(dir.path, 'prev.wav');
    final r = await runner.capture(
      ffmpeg!,
      audioPreviewArgs(
        info: video,
        output: out,
        start: const Duration(seconds: 1),
        length: const Duration(seconds: 1),
        filters: ['volume=-6dB'],
      ),
    );
    expect(r.ok, isTrue, reason: r.stderr);
    expect((await probe.probe(out)).duration!.inMilliseconds, closeTo(1000, 30));
  }, skip: skip);

  for (final duck in [true, false]) {
    test('music under video, looped, duck=$duck', () async {
      final out = p.join(dir.path, 'music_$duck.mp4');
      await run(
        planMusic(
          main: video,
          music: music,
          output: out,
          m: MusicParams(duck: duck, offset: const Duration(milliseconds: 500), fadeOut: const Duration(seconds: 1)),
        ),
      );
      final i = await probe.probe(out);
      expect(i.videoStreams, hasLength(1));
      expect(i.duration!.inMilliseconds, closeTo(3000, 120));
    }, skip: skip);
  }

  test('ducking lowers the music while the voice sounds', () async {
    Future<double> rms(String path, String range) async {
      final r = await runner.capture(ffmpeg!, [
        '-hide_banner', '-i', path, '-af', 'atrim=$range,astats=measure_overall=RMS_level:measure_perchannel=0', //
        '-f', 'null', '-',
      ]);
      return double.parse(RegExp(r'RMS level dB: (-?[\d.]+)').allMatches(r.stderr).last[1]!);
    }

    // The music is 200 Hz, the voice 2 kHz: a low-pass isolates the music.
    Future<double> music200(String path, String range) => rms(path, '$range,lowpass=f=250,lowpass=f=250');
    final plain = p.join(dir.path, 'm_plain.wav');
    final ducked = p.join(dir.path, 'm_ducked.wav');
    await run(
      planMusic(
        main: voice,
        music: music,
        output: plain,
        m: const MusicParams(duck: false, fadeOut: Duration.zero),
      ),
    );
    await run(
      planMusic(
        main: voice,
        music: music,
        output: ducked,
        m: const MusicParams(duckAmount: 20, fadeOut: Duration.zero),
      ),
    );
    // 2.1–2.4 s: the voice sounds → the ducked music is clearly quieter.
    final a = await music200(plain, 'start=2.1:end=2.4');
    final b = await music200(ducked, 'start=2.1:end=2.4');
    expect(a - b, greaterThan(6), reason: 'plain $a dB, ducked $b dB');
  }, skip: skip);

  test('transcribe arguments', () {
    final s = planTranscribe(
      // Pure test: must not depend on setUpAll (skipped without ffmpeg).
      info: const MediaInfo(path: 'v.mp4', format: FormatInfo(), streams: [], chapters: []),
      model: r'C:\models\ggml-base.bin',
      output: r'C:\out\v.srt',
      language: 'ru',
    ).single;
    final af = s.args[s.args.indexOf('-af') + 1];
    expect(af, startsWith('whisper=model='));
    expect(af, contains('language=ru'));
    expect(af, contains('format=srt'));
    expect(af, contains(r'C\\:'));
  });
}
