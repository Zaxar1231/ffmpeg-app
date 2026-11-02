@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/features/convert/convert_params.dart';
import 'package:kadra/features/metadata/meta_ops.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo mp4; // moov at the end, title tag
  late MediaInfo mp3;
  late MediaInfo mkv;
  late String jpg;
  late ProbeService probe;

  Future<void> run(List<JobStep> steps) async {
    final tmp = await Directory.systemTemp.createTemp('kadra_mt');
    final vars = {'tmp': tmp.path};
    for (final s in steps) {
      for (final f in s.files.entries) {
        await File(substitute([f.key], vars).single).writeAsString(substitute([f.value], vars).single);
      }
      final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: substitute(s.args, vars)))).done;
      expect(r.success, isTrue, reason: '${s.args.join(' ')}\n${r.logText}');
    }
    await tmp.delete(recursive: true);
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_meta');
    Future<String> gen(String name, List<String> a) async {
      final out = p.join(dir.path, name);
      final r = await runner.capture(ffmpeg!, ['-v', 'error', '-y', ...a, out]);
      expect(r.ok, isTrue, reason: r.stderr);
      return out;
    }

    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    final src = ['-f', 'lavfi', '-i', 'testsrc2=s=320x240:d=6', '-f', 'lavfi', '-i', 'sine=d=6'];
    mp4 = await probe.probe(await gen('v.mp4', [...src, '-c:v', 'libx264', '-c:a', 'aac', '-metadata', 'title=Old']));
    mkv = await probe.probe(await gen('v.mkv', [...src, '-c:v', 'libx264', '-c:a', 'aac']));
    mp3 = await probe.probe(await gen('a.mp3', ['-f', 'lavfi', '-i', 'sine=d=3']));
    jpg = await gen('cover.jpg', ['-f', 'lavfi', '-i', 'testsrc=s=300x300', '-frames:v', '1']);
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  test('tags: set, delete, custom key, stream language', () async {
    final out = p.join(dir.path, 'tags.mp4');
    await run(
      planTags(
        info: mp4,
        output: out,
        tags: {'title': '', 'artist': 'Кто-то; "x" = y', 'kadra_note': 'custom'},
        languages: {1: 'rus'},
      ),
    );
    final i = await probe.probe(out);
    expect(i.format.tags.containsKey('title'), isFalse);
    expect(i.format.tags['artist'], 'Кто-то; "x" = y');
    expect(i.format.tags['kadra_note'], 'custom');
    expect(i.streams[1].tags['language'], 'rus');
  }, skip: skip);

  for (final (name, getInfo, ext) in [
    ('mp3', () => mp3, 'mp3'),
    ('mp4', () => mp4, 'mp4'),
    ('mkv attachment', () => mkv, 'mkv'),
  ]) {
    test('cover: set, replace, extract, remove ($name)', () async {
      final info = getInfo();
      final a = p.join(dir.path, 'cov1.$ext');
      await run(planSetCover(info: info, output: a, image: jpg));
      final ia = await probe.probe(a);
      {
        expect(coverStreamIndex(ia), isNotNull);
        // Replacing keeps exactly one cover.
        final b = p.join(dir.path, 'cov2.$ext');
        await run(planSetCover(info: ia, output: b, image: jpg));
        final ib = await probe.probe(b);
        expect(ib.streams.where((v) => v.isAttachedPicture), hasLength(1));
        final img = p.join(dir.path, 'extracted_$ext.${coverExt(ib)}');
        await run(planExtractCover(info: ib, output: img));
        expect(await File(img).length(), greaterThan(1000));
        final c = p.join(dir.path, 'cov3.$ext');
        await run(planRemoveCover(info: ib, output: c));
        expect(coverStreamIndex(await probe.probe(c)), isNull);
      }
    }, skip: skip);
  }

  test('chapters: write with special chars, then remove', () async {
    final out = p.join(dir.path, 'ch.mkv');
    await run(
      planChapters(
        info: mkv,
        output: out,
        chapters: const [Chapter(Duration.zero, 'Вступление = intro; #1'), Chapter(Duration(seconds: 3), 'Финал')],
      ),
    );
    final i = await probe.probe(out);
    expect(i.chapters, hasLength(2));
    expect(i.chapters.first.title, 'Вступление = intro; #1');
    expect(i.chapters[1].start, const Duration(seconds: 3));
    final out2 = p.join(dir.path, 'ch2.mkv');
    await run(planChapters(info: i, output: out2, chapters: const []));
    expect((await probe.probe(out2)).chapters, isEmpty);
  }, skip: skip);

  test('chapters text round trip', () {
    const text = '0:00 Intro\n1:02:03 - Длинная глава\n(12:30) Third';
    final ch = chaptersFromText(text);
    expect(ch.map((c) => c.start.inSeconds), [0, 3723, 750]);
    expect(ch[1].title, 'Длинная глава');
    expect(chaptersToText(ch).split('\n').first, '0:00 Intro');
  });

  for (final mode in RepairMode.values) {
    test('repair ${mode.name}', () async {
      final out = p.join(dir.path, 'rep_${mode.name}.mp4');
      await run(
        planRepair(
          info: mp4,
          output: out,
          r: RepairParams(mode: mode, audioOffset: const Duration(milliseconds: 300), fps: 30),
          env: const EncodeEnv(allowHardware: false),
        ),
      );
      final i = await probe.probe(out);
      expect(i.duration!.inMilliseconds, closeTo(6000, 400));
      if (mode == RepairMode.reencode) expect(i.videoStreams.first.avgFrameRate, closeTo(30, 0.1));
    }, skip: skip);
  }

  test('faststart moves moov to the front', () async {
    expect(await moovAtEnd(mp4.path), isTrue);
    final out = p.join(dir.path, 'fast.mp4');
    await run(planFaststart(info: mp4, output: out));
    expect(await moovAtEnd(out), isFalse);
  }, skip: skip);
}
