@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';
import 'package:kadra/features/capture/capture_ops.dart';
import 'package:path/path.dart' as p;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final ffprobe = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffprobe')) : findOnPath('ffprobe');
  final skip = ffmpeg == null || ffprobe == null ? 'ffmpeg not available' : null;
  // A running X server (e.g. Xvfb) to test real screen capture.
  final display = Platform.environment['DISPLAY'];
  const runner = ProcessRunner();
  late Directory dir;
  late MediaInfo clip;
  late ProbeService probe;
  // Test tone instead of a microphone (lavfi works as an input device).
  const tone = CaptureDevice('lavfi', 'sine=f=440:sample_rate=48000', 'tone');

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_cap');
    final c = p.join(dir.path, 'clip.mp4');
    final r = await runner.capture(ffmpeg!, [
      '-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=1280x720:r=30:d=4', '-f', 'lavfi', '-i', 'sine=d=4', //
      '-c:v', 'libx264', '-c:a', 'aac', c,
    ]);
    expect(r.ok, isTrue, reason: r.stderr);
    probe = ProbeService(runner: runner, ffprobePath: ffprobe!);
    clip = await probe.probe(c);
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  /// Runs a live command for [seconds], then stops it with `q`.
  Future<RunResult> live(List<String> args, Duration seconds) async {
    final h = await runner.start(ToolInvocation(executable: ffmpeg!, args: args));
    await Future<void>.delayed(seconds);
    h.writeStdin('q');
    return h.done.timeout(const Duration(seconds: 15));
  }

  test('screen (x11grab) + two audio sources mixed, stopped with q, remuxed to mp4', () async {
    if (display == null || HostPlatform.current.isWindows) return markTestSkipped('no X display');
    final out = p.join(dir.path, 'screen.$recordingExt');
    final args = recordArgs(
      src: CaptureSources(
        video: screenDevice(
          host: HostPlatform.current,
          fps: 15,
          display: display,
          region: const ScreenRegion(10, 10, 640, 360),
        ),
        audio: const [tone, CaptureDevice('lavfi', 'sine=f=880:sample_rate=48000', 'tone2')],
      ),
      output: out,
      enc: const LiveEncode(fps: 15),
    );
    final r = await live(args, const Duration(seconds: 3));
    expect(r.success, isTrue, reason: '${args.join(' ')}\n${r.logText}');
    final i = await probe.probe(out);
    expect(i.videoStreams.single.width, 640);
    expect(i.audioStreams, hasLength(1));
    expect(i.duration!.inMilliseconds, greaterThan(1500));
    final mp4 = p.join(dir.path, 'screen.mp4');
    final m = await runner.capture(ffmpeg!, remuxToMp4Args(out, mp4));
    expect(m.ok, isTrue, reason: m.stderr);
  }, skip: skip);

  test('audio only recording', () async {
    final out = p.join(dir.path, 'mic.$recordingExt');
    final r = await live(
      recordArgs(
        src: const CaptureSources(audio: [tone]),
        output: out,
        enc: const LiveEncode(),
      ),
      const Duration(seconds: 2),
    );
    expect(r.success, isTrue, reason: r.logText);
    final i = await probe.probe(out);
    expect(i.videoStreams, isEmpty);
    expect(i.audioStreams.single.codecName, 'aac');
  }, skip: skip);

  for (final (name, url) in [('flv', 'out.flv'), ('srt-like mpegts', 'srt://127.0.0.1:1')]) {
    test('stream a file: $name arguments', () async {
      final target = name == 'flv' ? p.join(dir.path, url) : url;
      final args = streamArgs(
        src: CaptureSources(file: clip.path),
        url: target,
        enc: const LiveEncode(videoKbps: 2500, height: 480),
      );
      expect(args, contains('-re'));
      expect(args, containsAllInOrder(['-f', name == 'flv' ? 'flv' : 'mpegts', target]));
      if (name != 'flv') return; // no SRT listener here
      final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: args))).done;
      expect(r.success, isTrue, reason: '${args.join(' ')}\n${r.logText}');
      final i = await probe.probe(target);
      expect(i.videoStreams.single.height, 480);
    }, skip: skip);
  }

  for (final f in PackageFormat.values) {
    test('package ${f.name} with a 3-rung ladder', () async {
      final out = Directory(p.join(dir.path, f.name));
      await out.create();
      final steps = planPackage(
        info: clip,
        outDir: out.path,
        format: f,
        heights: const [1080, 720, 480, 360],
        segment: 2,
      );
      final r = await (await runner.start(ToolInvocation(executable: ffmpeg!, args: steps.single.args))).done;
      expect(r.success, isTrue, reason: '${steps.single.args.join(' ')}\n${r.logText}');
      final entry = File(packageEntry(out.path, f));
      expect(entry.existsSync(), isTrue);
      final text = await entry.readAsString();
      if (f == PackageFormat.hls) {
        expect(RegExp('#EXT-X-STREAM-INF').allMatches(text), hasLength(3));
        expect(text, contains('720p/index.m3u8'));
      } else {
        expect(RegExp('<Representation').allMatches(text).length, 4); // 3 video + 1 shared audio
      }
      // The packaged stream plays back (ffprobe reads the entry file).
      final pi = await probe.probe(entry.path);
      expect(pi.videoStreams, isNotEmpty);
    }, skip: skip);
  }

  test('device lists', () {
    const modern = '''
[dshow @ 0000] "HD Webcam" (video)
[dshow @ 0000]   Alternative name "@device_pnp_\\\\?\\usb#vid"
[dshow @ 0000] "Microphone (Realtek Audio)" (audio)
[dshow @ 0000] "Stereo Mix (Realtek Audio)" (audio)
''';
    final d = parseDshowDevices(modern);
    expect(d.video.single.name, 'video=HD Webcam');
    expect(d.audio.map((a) => a.label), ['Microphone (Realtek Audio)', 'Stereo Mix (Realtek Audio)']);
    expect(isSystemAudio(d.audio[1]), isTrue);
    const old = '''
[dshow @ 0000] DirectShow video devices (some may be both video and audio devices)
[dshow @ 0000]  "USB Camera"
[dshow @ 0000]     Alternative name "@device_pnp_x"
[dshow @ 0000] DirectShow audio devices
[dshow @ 0000]  "Mic"
''';
    final o = parseDshowDevices(old);
    expect(o.video.single.label, 'USB Camera');
    expect(o.audio.single.name, 'audio=Mic');
    final pulse = parsePulseSources(
      '1\talsa_output.pci.analog-stereo.monitor\tPipeWire\ts32le 2ch 48000Hz\tSUSPENDED\n2\talsa_input.usb-mic\tPipeWire\ts16le 1ch\tRUNNING\n',
    );
    expect(pulse, hasLength(2));
    expect(isSystemAudio(pulse.first), isTrue);
    expect(
      screenDevice(
        host: const HostPlatform(HostOs.windows, HostArch.x64),
        region: const ScreenRegion(5, 6, 101, 99),
      ).options,
      containsAllInOrder(['-offset_x', '5', '-offset_y', '6', '-video_size', '100x98']),
    );
  });
}
