@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/encoders.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/features/convert/convert_params.dart';
import 'package:kadra/features/edit/edit_encode.dart';
import 'package:kadra/features/subtitles/subs_ops.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo video; // mkv with one SRT track
  late String srt; // UTF-8 with special characters
  late String srt1251; // the same in CP1251, path with a quote and colon
  late ProbeService probe;

  Future<void> run(List<JobStep> steps) async {
    for (final s in steps) {
      final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: s.args))).done;
      expect(r.success, isTrue, reason: '${s.args.join(' ')}\n${r.logText}');
    }
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_subs');
    const text =
        '1\r\n00:00:01,000 --> 00:00:02,500\r\nПривет, мир: 50% «тест» [x]\r\n\r\n'
        '2\r\n00:00:03,000 --> 00:00:04,000\r\nВторая строка\r\n';
    srt = p.join(dir.path, 'a.srt');
    await File(srt).writeAsString(text);
    final odd = Directory(p.join(dir.path, "it's: subs"));
    await odd.create();
    srt1251 = p.join(odd.path, 'b.srt');
    // CP1251 bytes for the Cyrillic text (Latin-1 range is identical).
    const cp = 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя';
    await File(srt1251).writeAsBytes([
      for (final ch in text.runes)
        if (ch < 128) ch else if (cp.runes.contains(ch)) 0xC0 + cp.runes.toList().indexOf(ch) else 0x3F,
    ]);
    final v = p.join(dir.path, 'v.mkv');
    final r = await runner.capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=320x240:d=5', '-f', 'lavfi', '-i', 'sine=d=5', //
      '-i', srt, '-map', '0', '-map', '1', '-map', '2', '-c:v', 'libx264', '-c:a', 'aac', '-c:s', 'srt', v,
    ]);
    expect(r.ok, isTrue, reason: r.stderr);
    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    video = await probe.probe(v);
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  const env = EncodeEnv(allowHardware: false);

  for (final (name, style) in [
    ('default style', const BurnStyle()),
    ('styled', const BurnStyle(fontSize: 28, color: 'FFFF00', box: true, marginV: 30, position: SubPosition.top)),
  ]) {
    test('burn external file, $name', () async {
      final out = p.join(dir.path, 'burn_${name.split(' ').first}.mp4');
      final plan = planEdit(
        info: video,
        output: out,
        graph: burnGraph(video, subFile: srt1251, style: style, charset: 'CP1251'),
        out: const EditOutput(speed: SpeedPreset.fastest),
        env: env,
      );
      await run(plan.steps);
      final i = await probe.probe(out);
      expect(i.subtitleStreams, isEmpty);
      expect(i.duration!.inMilliseconds, closeTo(5000, 150));
    }, skip: skip);
  }

  test('burn the embedded track', () async {
    final out = p.join(dir.path, 'burn_embedded.mkv');
    await run(
      planEdit(
        info: video,
        output: out,
        graph: burnGraph(video),
        out: const EditOutput(ext: 'mkv', speed: SpeedPreset.fastest),
        env: env,
      ).steps,
    );
  }, skip: skip);

  test('add tracks to mp4 (mov_text) with language, default and charset; drop the old one', () async {
    final out = p.join(dir.path, 'tracks.mp4');
    await run(
      planSubTracks(
        info: video,
        output: out,
        keep: const [0],
        add: [
          NewSubTrack(srt, language: 'rus', title: 'Русские', isDefault: true),
          NewSubTrack(srt1251, language: 'eng', charset: 'CP1251', forced: true),
        ],
      ),
    );
    final i = await probe.probe(out);
    final subs = i.subtitleStreams.toList();
    expect(subs.map((s) => s.codecName), everyElement('mov_text'));
    expect(subs, hasLength(3));
    expect(subs[1].tags['language'], 'rus');
    expect(subs[1].disposition['default'], 1);
    expect(subs[2].disposition['forced'], 1);
    expect(i.videoStreams.single.codecName, 'h264'); // copied
  }, skip: skip);

  test('remove all subtitle tracks (mkv)', () async {
    final out = p.join(dir.path, 'nosubs.mkv');
    await run(planSubTracks(info: video, output: out, keep: const []));
    expect((await probe.probe(out)).subtitleStreams, isEmpty);
  }, skip: skip);

  for (final ext in ['srt', 'ass', 'vtt']) {
    test('extract as $ext', () async {
      final out = p.join(dir.path, 'x.$ext');
      await run(planExtractSub(info: video, index: 0, output: out));
      expect(await File(out).readAsString(), contains('Привет'));
    }, skip: skip);
  }

  test('convert: CP1251 → UTF-8 ASS, shifted by -0.5 s and slowed (25 → 23.976)', () async {
    final out = p.join(dir.path, 'conv.ass');
    final r = await runner.capture(
      ffmpeg!,
      planConvertSubs(
        input: srt1251,
        output: out,
        shift: const Duration(milliseconds: -500),
        charset: 'CP1251',
        scale: 25 / 23.976,
      ).single.args,
    );
    expect(r.ok, isTrue, reason: r.stderr);
    final text = await File(out).readAsString(encoding: utf8);
    expect(text, contains('Привет'));
    // 1.0 s · 1.0427 − 0.5 ≈ 0.54 s
    expect(text, contains('Dialogue: 0,0:00:00.54'));
  }, skip: skip);

  test('ASS colour and style string', () {
    expect(assColor('FFFF00'), '&H0000FFFF');
    expect(
      forceStyle(const BurnStyle(fontSize: 20, position: SubPosition.top)),
      'FontSize=20,BorderStyle=1,Outline=2,Alignment=8',
    );
    expect(subtitleCodecFor('mp4'), 'mov_text');
    expect(subtitleCodecFor('mkv', sourceCodec: 'ass'), 'ass');
    expect(subtitleCodecFor('avi'), isNull);
  });
}
