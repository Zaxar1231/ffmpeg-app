@Tags(['ffmpeg'])
library;

import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/components/toolchain.dart';
import 'package:kadra/core/db/database.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/app_paths.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/core/providers.dart';
import 'package:kadra/core/queue/queue_models.dart';
import 'package:kadra/features/audio/audio_ops.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// The real QueueController runs a multi-step job: loudnorm measure →
/// capture → apply, with a per-job temp dir.
void main() {
  final ffmpeg = findOnPath('ffmpeg');
  final ffprobe = findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not on PATH' : null;

  test('two-pass normalize through the queue', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dir = await Directory.systemTemp.createTemp('kadra_q');
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        appPathsProvider.overrideWithValue(AppPaths(dir.path)),
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        toolchainProvider.overrideWithValue(
          Toolchain(
            ffmpeg: ToolPath(ffmpeg, ToolOrigin.system),
            ffprobe: ToolPath(ffprobe, ToolOrigin.system),
            ytdlp: ToolPath.missing,
            deno: ToolPath.missing,
            aria2c: ToolPath.missing,
          ),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      await dir.delete(recursive: true);
    });

    final src = p.join(dir.path, 'quiet.m4a');
    final g = await const ProcessRunner().capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'sine=f=300:d=3:sample_rate=44100', '-af', 'volume=-20dB', src, //
    ]);
    expect(g.ok, isTrue);
    final info = await ProbeService(runner: const ProcessRunner(), ffprobePath: ffprobe!).probe(src);
    final out = p.join(dir.path, 'loud.m4a');

    container.read(queueProvider); // start loading
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final id = await container
        .read(queueProvider.notifier)
        .enqueue(
          JobRequest(
            kind: 'normalize',
            title: 't',
            tool: JobTool.ffmpeg,
            steps: planNormalize(info: info, output: out, target: loudnessTargets.first, ext: 'm4a'),
            outputPath: out,
            totalDuration: info.duration,
          ),
        );
    final done = Completer<QueueItem>();
    final sub = container.listen(queueProvider, (_, s) {
      final it = s.byId(id);
      if (it != null && it.isFinished && !done.isCompleted) done.complete(it);
    });
    final item = await done.future.timeout(const Duration(minutes: 2));
    sub.close();
    expect(item.status, JobStatus.completed, reason: item.job.log);
    expect(item.job.outputSize, greaterThan(1000));
    expect(item.job.log, contains('── 1/2 ──'));
    expect(item.job.log, contains('"input_i"'));
  }, skip: skip);
}
