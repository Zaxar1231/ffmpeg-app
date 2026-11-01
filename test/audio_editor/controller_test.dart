@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/components/toolchain.dart';
import 'package:kadra/core/db/database.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/app_paths.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/providers.dart';
import 'package:kadra/features/audio_editor/editor_controller.dart';
import 'package:kadra/features/audio_editor/engine/effects.dart';
import 'package:kadra/features/audio_editor/engine/model.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the real editor controller with real ffmpeg/ffprobe.
void main() {
  final ffmpeg = findOnPath('ffmpeg');
  final ffprobe = findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not on PATH' : null;

  test('import, edit, undo/redo, effect, clipboard, labels, save/open project', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dir = await Directory.systemTemp.createTemp('kadra_ctl');
    final db = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(
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
      c.dispose();
      await db.close();
      await dir.delete(recursive: true);
    });
    final src = p.join(dir.path, 'in.mp3');
    final g = await const ProcessRunner().capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'sine=f=440:d=4:sample_rate=44100', '-ac', '2', src, //
    ]);
    expect(g.ok, isTrue);

    final ctl = c.read(audioEditorProvider.notifier);
    EditorState st() => c.read(audioEditorProvider);
    expect(await ctl.importFiles([src]), isTrue, reason: st().error);
    expect(st().project.sampleRate, 44100);
    final t0 = st().project.tracks.single;
    expect(t0.channels, 2);
    // mp3 decoders add encoder padding; around 4 s.
    expect(t0.frames, closeTo(4 * 44100, 3000));
    expect(st().peaks[t0.file], isNotNull);

    ctl.setSelection(const SampleRange(44100, 88200));
    expect(await ctl.deleteSelection(), isTrue, reason: st().error);
    expect(st().project.tracks.single.frames, t0.frames - 44100);
    ctl.undo();
    expect(st().project.tracks.single.frames, t0.frames);
    ctl.redo();
    expect(st().project.tracks.single.frames, t0.frames - 44100);
    ctl.undo();

    ctl.setSelection(const SampleRange(0, 44100));
    expect(await ctl.applyEffect(fxById('amplify'), {'gain': -20}), isTrue, reason: st().error);
    final stats = await ctl.stats();
    expect(stats!.first.peakDb, lessThan(-25));

    expect(await ctl.copySelection(), isTrue);
    ctl.setCursor(t0.frames);
    expect(await ctl.paste(), isTrue, reason: st().error);
    expect(st().project.tracks.single.frames, t0.frames + 44100);

    ctl.addLabel('A', at: const SampleRange(0, 1000));
    expect(st().project.labels.single.text, 'A');

    final proj = p.join(dir.path, 'proj');
    expect(await ctl.saveProject(proj), isTrue, reason: st().error);
    expect(File(p.join(proj, 'project.kadra-audio.json')).existsSync(), isTrue);
    ctl.newProject();
    expect(st().project.tracks, isEmpty);
    expect(await ctl.openProject(proj), isTrue, reason: st().error);
    expect(st().project.tracks.single.frames, t0.frames + 44100);
    expect(st().project.labels.single.text, 'A');

    // Paulstretch (Dart DSP) on 0.5 s → 2 s.
    ctl.setSelection(const SampleRange(0, 22050));
    expect(await ctl.applyEffect(fxById('paulstretch'), {'stretch': 4, 'window': 0.1}), isTrue, reason: st().error);
    expect(st().project.tracks.single.frames, t0.frames + 44100 - 22050 + 88200);
  }, skip: skip);
}
