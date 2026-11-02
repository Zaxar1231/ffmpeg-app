/// Live capture/stream session: one at a time, stopped with `q` so files
/// are finalized; the recording is then optionally remuxed to MP4.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/error_translator.dart';
import '../../core/engine/process_runner.dart';
import '../../core/engine/progress.dart';
import '../../core/platform/host.dart';
import '../../core/providers.dart';
import 'capture_ops.dart';

enum LiveKind { record, stream }

class LiveState {
  const LiveState({
    this.kind,
    this.running = false,
    this.stopping = false,
    this.progress,
    this.output,
    this.lastFile,
    this.error,
  });
  final LiveKind? kind;
  final bool running;
  final bool stopping;
  final FfmpegProgress? progress;

  /// File or URL being written.
  final String? output;

  /// Finished recording (after remux).
  final String? lastFile;
  final ToolError? error;
}

class LiveController extends Notifier<LiveState> {
  RunHandle? _h;

  @override
  LiveState build() {
    ref.onDispose(() => _h?.writeStdin('q'));
    return const LiveState();
  }

  Future<void> start({
    required LiveKind kind,
    required List<String> args,
    required String output,
    bool remuxMp4 = false,
  }) async {
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null || state.running) return;
    if (kind == LiveKind.record) await Directory(p.dirname(output)).create(recursive: true);
    final h = await ref
        .read(processRunnerProvider)
        .start(ToolInvocation(executable: ffmpeg, args: args, progress: ProgressKind.ffmpeg));
    _h = h;
    state = LiveState(kind: kind, running: true, output: output);
    final sub = h.progress.listen((pr) {
      if (ref.mounted && state.running) {
        state = LiveState(kind: kind, running: true, stopping: state.stopping, progress: pr, output: output);
      }
    });
    unawaited(() async {
      final r = await h.done;
      await sub.cancel();
      _h = null;
      if (!ref.mounted) return;
      final produced = kind == LiveKind.record && File(output).existsSync() && File(output).lengthSync() > 1024;
      // ffmpeg exits with 255 after `q` on some devices; a written file counts.
      final failed = !r.success && !produced && !state.stopping;
      String? last;
      if (produced && remuxMp4) {
        final mp4 = p.setExtension(output, '.mp4');
        final m = await ref.read(processRunnerProvider).capture(ffmpeg, remuxToMp4Args(output, mp4));
        if (m.ok) {
          await File(output).delete();
          last = mp4;
        } else {
          last = output;
        }
      } else if (produced) {
        last = output;
      }
      state = LiveState(
        kind: kind,
        output: output,
        lastFile: last,
        error: failed ? translateToolError(r.log, startError: r.startError) : null,
      );
    }());
  }

  Future<void> stop() async {
    final h = _h;
    if (h == null) return;
    state = LiveState(kind: state.kind, running: true, stopping: true, progress: state.progress, output: state.output);
    h.writeStdin('q');
    await h.done.timeout(
      const Duration(seconds: 8),
      onTimeout: () async {
        await h.cancel();
        return h.done;
      },
    );
  }
}

final liveProvider = NotifierProvider<LiveController, LiveState>(LiveController.new);

/// Capture devices of this computer.
class DeviceList {
  const DeviceList({this.cameras = const [], this.audio = const [], this.note});
  final List<CaptureDevice> cameras;
  final List<CaptureDevice> audio;

  /// Platform remark (e.g. Wayland limits).
  final String? note;
}

final captureDevicesProvider = FutureProvider.autoDispose<DeviceList>((ref) async {
  final ffmpeg = ref.watch(toolchainProvider.select((t) => t.ffmpeg.path));
  if (ffmpeg == null) return const DeviceList();
  final runner = ref.read(processRunnerProvider);
  if (HostPlatform.current.isWindows) {
    final r = await runner.capture(ffmpeg, ['-hide_banner', '-list_devices', 'true', '-f', 'dshow', '-i', 'dummy']);
    final d = parseDshowDevices(r.stderr);
    return DeviceList(cameras: d.video, audio: d.audio);
  }
  final cams = <CaptureDevice>[];
  final dev = Directory('/dev');
  if (dev.existsSync()) {
    for (final f
        in dev.listSync().where((e) => RegExp(r'/video\d+$').hasMatch(e.path)).map((e) => e.path).toList()..sort()) {
      cams.add(CaptureDevice('v4l2', f, p.basename(f)));
    }
  }
  var audio = <CaptureDevice>[];
  final pactl = await runner.capture('pactl', ['list', 'short', 'sources']);
  if (pactl.ok) audio = parsePulseSources(pactl.stdout);
  if (audio.isEmpty) {
    audio = const [
      CaptureDevice('pulse', 'default', 'PulseAudio / PipeWire'),
      CaptureDevice('alsa', 'default', 'ALSA'),
    ];
  }
  final wayland = (Platform.environment['XDG_SESSION_TYPE'] ?? '') == 'wayland';
  return DeviceList(cameras: cams, audio: audio, note: wayland ? 'wayland' : null);
});
