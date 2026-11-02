@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/capabilities.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/features/automation/batch.dart';
import 'package:kadra/features/automation/recipe.dart';
import 'package:kadra/features/convert/convert_params.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo video;
  late ProbeService probe;
  late RecipeEnv env;

  /// Runs steps the way the queue does: files, {{tmp}}, loudnorm capture.
  Future<void> run(List<JobStep> steps) async {
    final tmp = await Directory.systemTemp.createTemp('kadra_rc');
    final vars = {'tmp': tmp.path};
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
      expect(r.success, isTrue, reason: '${s.label}: ${s.args.join(' ')}\n${r.logText}');
      if (s.capture == StepCapture.loudnorm) vars.addAll(parseLoudnormJson(r.log)!);
    }
    await tmp.delete(recursive: true);
  }

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_recipe');
    final v = p.join(dir.path, 'clip.mp4');
    final r = await runner.capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=640x360:d=4', '-f', 'lavfi', '-i', 'sine=d=4', //
      '-c:v', 'libx264', '-c:a', 'aac', '-metadata', 'title=Secret', v,
    ]);
    expect(r.ok, isTrue, reason: r.stderr);
    await File(p.join(dir.path, 'clip.srt')).writeAsString('1\n00:00:00,500 --> 00:00:02,000\nHello\n');
    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    video = await probe.probe(v);
    env = RecipeEnv(
      encode: EncodeEnv(
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
      ),
      rnnoiseModel: Platform.environment['KADRA_TEST_RNNOISE'],
    );
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  final recipes = <String, (List<RecipeStep>, void Function(MediaInfo))>{
    'scale + text + normalize + fade + faststart': (
      const [
        RecipeStep(RecipeOp.scale, {'height': 240}),
        RecipeStep(RecipeOp.text, {'text': 'Kadra: 100%', 'corner': 'top'}),
        RecipeStep(RecipeOp.normalize, {'lufs': -16}),
        RecipeStep(RecipeOp.fade, {'seconds': 0.5}),
        RecipeStep(RecipeOp.faststart),
      ],
      (i) => expect(i.videoStreams.first.height, 240),
    ),
    'vertical + burn sidecar + denoise + strip metadata': (
      const [
        RecipeStep(RecipeOp.vertical, {'height': 640}),
        RecipeStep(RecipeOp.burnSidecar),
        RecipeStep(RecipeOp.denoise),
        RecipeStep(RecipeOp.stripMetadata),
      ],
      (i) {
        expect(i.videoStreams.first.width, 360);
        expect(i.format.tags.containsKey('title'), isFalse);
      },
    ),
    'telegram preset then extract audio': (
      const [
        RecipeStep(RecipeOp.convert, {'preset': 'telegram'}),
        RecipeStep(RecipeOp.extractAudio, {'format': 'mp3'}),
        RecipeStep(RecipeOp.normalize, {'lufs': -14}),
      ],
      (i) {
        expect(i.videoStreams, isEmpty);
        expect(i.audioStreams.single.codecName, 'mp3');
      },
    ),
    'scale up is a no-op copy': (
      const [
        RecipeStep(RecipeOp.scale, {'height': 1080}),
      ],
      (i) => expect(i.videoStreams.first.height, 360),
    ),
  };

  for (final e in recipes.entries) {
    test(e.key, () async {
      final r = Recipe(id: 'x', name: e.key, steps: e.value.$1);
      expect(recipeProblem(r, video, env), isNull);
      final ext = recipeOutputExt(r, video, env);
      final out = batchOutput(input: video.path, ext: ext, outDir: p.join(dir.path, 'out'));
      await Directory(p.dirname(out)).create(recursive: true);
      await run(planRecipe(info: video, r: r, output: out, env: env));
      final i = await probe.probe(out);
      expect(i.duration!.inMilliseconds, closeTo(4000, 250));
      e.value.$2(i);
    }, skip: skip);
  }

  test('recipes json round trip', () async {
    final d = await Directory.systemTemp.createTemp('kadra_rj');
    final path = p.join(d.path, 'recipes.json');
    const r = Recipe(
      id: 'a',
      name: 'Для Reels',
      steps: [
        RecipeStep(RecipeOp.vertical, {'height': 1920}),
        RecipeStep(RecipeOp.normalize),
      ],
    );
    await saveRecipes(path, [r]);
    final back = await loadRecipes(path);
    expect(back.single.name, 'Для Reels');
    expect(back.single.steps.map((s) => s.op), [RecipeOp.vertical, RecipeOp.normalize]);
    expect(back.single.steps.first.params['height'], 1920);
    await d.delete(recursive: true);
  });

  test('batch output naming and scanning', () async {
    final d = await Directory.systemTemp.createTemp('kadra_bt');
    await Directory(p.join(d.path, 'sub')).create();
    for (final f in ['a.mp4', 'sub/b.mkv', 'sub/c.mp3', 'note.txt', '.hidden.mp4']) {
      await File(p.join(d.path, f)).writeAsString('x');
    }
    expect((await scanFolder(d.path)).map((f) => p.relative(f, from: d.path)), [
      'a.mp4',
      p.join('sub', 'b.mkv'),
      p.join('sub', 'c.mp3'),
    ]);
    expect(await scanFolder(d.path, kind: FileKindFilter.audio, recursive: true), hasLength(1));
    expect(await scanFolder(d.path, recursive: false), hasLength(1));
    final out = batchOutput(
      input: p.join(d.path, 'sub', 'b.mkv'),
      ext: 'mp4',
      outDir: p.join(d.path, 'o'),
      root: d.path,
    );
    expect(p.relative(out, from: d.path), p.join('o', 'sub', 'b.mp4'));
    // Next to the source with the same extension: never overwrites.
    expect(p.basename(batchOutput(input: p.join(d.path, 'a.mp4'), ext: 'mp4')), 'a_kadra.mp4');
    expect(await waitUntilComplete(p.join(d.path, 'a.mp4'), stable: const Duration(milliseconds: 600)), isTrue);
    await d.delete(recursive: true);
  });
}
