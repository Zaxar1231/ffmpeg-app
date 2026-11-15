@Tags(['ffmpeg'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/features/audio/audio_chain.dart';
import 'package:kadra/features/plugins/plugins_ops.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  const runner = ProcessRunner();

  test('frei0r folders, scan and environment', () {
    final tmp = Directory.systemTemp.createTempSync('kadra_f0r');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final own = Directory(p.join(tmp.path, 'own'))..createSync();
    final other = Directory(p.join(tmp.path, 'other'))..createSync();
    for (final n in ['glow.so', 'Cartoon.so', 'readme.txt']) {
      File(p.join(own.path, n)).writeAsStringSync('');
    }
    File(p.join(other.path, 'glow.so')).writeAsStringSync('');
    File(p.join(other.path, 'vertigo.so')).writeAsStringSync('');
    final win = Platform.isWindows;
    final dirs = frei0rDirs(own: own.path, env: {'FREI0R_PATH': other.path, 'HOME': '/home/u'}, windows: win);
    expect(dirs.take(3), [own.path, other.path, p.join('/home/u', '.frei0r-1', 'lib')]);
    // Windows paths contain ':', so the list separator there is ';'.
    expect(frei0rDirs(own: 'o', env: {'FREI0R_PATH': r'C:\a;D:\b'}, windows: true).take(3), ['o', r'C:\a', r'D:\b']);
    final ext = win ? '.dll' : '.so';
    for (final d in [own.path, other.path]) {
      for (final f in Directory(d).listSync()) {
        if (f.path.endsWith('.so') && ext != '.so') f.renameSync(f.path.replaceAll(RegExp(r'\.so$'), ext));
      }
    }
    final found = scanFrei0r(dirs.take(2).toList(), windows: win);
    expect(found.map((x) => x.name), ['Cartoon', 'glow', 'vertigo']);
    expect(found.firstWhere((x) => x.name == 'glow').dir, own.path); // own folder wins
    expect(frei0rEnv('C:\\k\\frei0r', env: {'FREI0R_PATH': 'D:\\x'}, windows: true), {
      'FREI0R_PATH': 'C:\\k\\frei0r;D:\\x',
    });
    expect(frei0rEnv('/k', env: {}), {'FREI0R_PATH': '/k'});
    final info = parseFrei0rInfo(
      "[Parsed_frei0r_0 @ 0x1] name:Glow author:'Richard Spindler' explanation:'Creates a Glamorous Glow' "
      'color_model:rgba8888 frei0r_version:1 version:0.1 num_params:1',
    );
    expect((info.explanation, info.author, info.params), ('Creates a Glamorous Glow', 'Richard Spindler', 1));
    expect(parseLv2ls('http://plugin.org.uk/swh-plugins/amp\nurn:x:y\n\nwarning: foo\n'), [
      'http://plugin.org.uk/swh-plugins/amp',
      'urn:x:y',
    ]);
    expect(lv2Filter('http://a/b', controls: 'gain=6'), r'lv2=plugin=http\\://a/b:controls=gain=6');
  });

  test('frei0r glow on a real video', () async {
    if (ffmpeg == null || ffprobe == null) return markTestSkipped('no ffmpeg');
    final win = HostPlatform.current.isWindows;
    final plugins = scanFrei0r(
      frei0rDirs(own: '/nonexistent', windows: win),
      windows: win,
    );
    if (!plugins.any((x) => x.name == 'glow')) return markTestSkipped('frei0r-plugins not installed');
    final dir = await Directory.systemTemp.createTemp('kadra_f0rv');
    addTearDown(() => dir.delete(recursive: true));
    final src = p.join(dir.path, 'a.mp4');
    expect(
      (await runner.capture(ffmpeg, ['-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=320x180:d=1', src])).ok,
      isTrue,
    );
    final info = await ProbeService(runner: runner, ffprobePath: ffprobe).probe(src);
    final g = frei0rGraph(info, 'glow', params: '0.6');
    final out = p.join(dir.path, 'glow.mp4');
    final r = await runner.capture(ffmpeg, [
      '-v',
      'error',
      '-i',
      src,
      '-filter_complex',
      g.complex,
      '-map',
      '[v]',
      out,
    ]);
    expect(r.ok, isTrue, reason: r.stderr);
  });

  test('LV2 amplifier through the audio chain', () async {
    if (ffmpeg == null || ffprobe == null) return markTestSkipped('no ffmpeg');
    final ls = await runner.capture('lv2ls', const []);
    const amp = 'http://plugin.org.uk/swh-plugins/amp';
    if (!ls.ok || !parseLv2ls(ls.stdout).contains(amp)) return markTestSkipped('swh-lv2 not installed');
    final dir = await Directory.systemTemp.createTemp('kadra_lv2');
    addTearDown(() => dir.delete(recursive: true));
    final src = p.join(dir.path, 'a.wav');
    expect(
      (await runner.capture(ffmpeg, ['-v', 'error', '-f', 'lavfi', '-i', 'sine=d=1:sample_rate=48000', src])).ok,
      isTrue,
    );
    final info = await ProbeService(runner: runner, ffprobePath: ffprobe).probe(src);
    final steps = planAudioChain(
      info: info,
      output: p.join(dir.path, 'loud.wav'),
      filters: [lv2Filter(amp, controls: 'gain=6')],
      keepLength: false,
    );
    final args = steps.single.args.where((a) => a != '-progress' && a != 'pipe:1').toList();
    final r = await runner.capture(ffmpeg, args);
    expect(r.ok, isTrue, reason: '${args.join(' ')}\n${r.stderr}');
  });
}
