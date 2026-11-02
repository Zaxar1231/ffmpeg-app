/// Capture and streaming (stage 5): screen / camera / microphone inputs per
/// platform, recording and live-stream outputs, HLS/DASH packaging.
///
/// Device options: x11grab, v4l2 and pulse checked with `ffmpeg -h demuxer=`
/// on ffmpeg 6.1 and 9.0; gdigrab and dshow (Windows only) checked against
/// libavdevice/gdigrab.c and dshow.c.
library;

import 'dart:math' as math;

import 'package:path/path.dart' as p;

import '../../core/engine/encoders.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/platform/host.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../convert/convert_params.dart';
import '../edit/graphs.dart' show even, fnum;

/// An input device: `-f <format> [options] -i <name>`.
class CaptureDevice {
  const CaptureDevice(this.format, this.name, this.label, {this.options = const []});
  final String format;
  final String name;
  final String label;
  final List<String> options;

  /// Devices deliver frames in real time: a larger input queue avoids
  /// "thread message queue blocking" drops while the encoder warms up.
  FfmpegInput toInput() => FfmpegInput(name, format: format, options: ['-thread_queue_size', '1024', ...options]);

  @override
  bool operator ==(Object other) => other is CaptureDevice && other.format == format && other.name == name;
  @override
  int get hashCode => Object.hash(format, name);
}

class ScreenRegion {
  const ScreenRegion(this.x, this.y, this.width, this.height);
  final int x, y, width, height;
}

/// The screen as an input device for this platform.
CaptureDevice screenDevice({
  required HostPlatform host,
  int fps = 30,
  ScreenRegion? region,
  bool drawMouse = true,
  String display = ':0.0',
}) {
  // Even size, rounded down so the region never leaves the screen.
  final size = region == null
      ? <String>[]
      : ['-video_size', '${math.max(2, region.width ~/ 2 * 2)}x${math.max(2, region.height ~/ 2 * 2)}'];
  if (host.isWindows) {
    return CaptureDevice(
      'gdigrab',
      'desktop',
      'desktop',
      options: [
        '-framerate',
        '$fps',
        '-draw_mouse',
        drawMouse ? '1' : '0',
        if (region != null) ...['-offset_x', '${region.x}', '-offset_y', '${region.y}'],
        ...size,
      ],
    );
  }
  final base = display.contains('.') ? display : '$display.0';
  return CaptureDevice(
    'x11grab',
    region == null ? base : '$base+${region.x},${region.y}',
    display,
    options: ['-framerate', '$fps', '-draw_mouse', drawMouse ? '1' : '0', ...size],
  );
}

/// Cameras and audio sources from `ffmpeg -list_devices true -f dshow -i dummy`.
({List<CaptureDevice> video, List<CaptureDevice> audio}) parseDshowDevices(String stderr) {
  final video = <CaptureDevice>[], audio = <CaptureDevice>[];
  for (final m in RegExp(r'"([^"]+)"\s+\((video|audio)\)').allMatches(stderr)) {
    final name = m[1]!;
    if (m[2] == 'video') {
      video.add(CaptureDevice('dshow', 'video=$name', name, options: const ['-rtbufsize', '256M']));
    } else {
      audio.add(CaptureDevice('dshow', 'audio=$name', name, options: const ['-rtbufsize', '64M']));
    }
  }
  // Older builds print devices under headers instead of "(video)" tags.
  if (video.isEmpty && audio.isEmpty) {
    var section = '';
    for (final line in stderr.split('\n')) {
      if (line.contains('DirectShow video devices')) section = 'video';
      if (line.contains('DirectShow audio devices')) section = 'audio';
      final m = RegExp(r'\]\s+"([^"]+)"\s*$').firstMatch(line);
      if (m == null || line.contains('Alternative name')) continue;
      final name = m[1]!;
      if (section == 'video') {
        video.add(CaptureDevice('dshow', 'video=$name', name, options: const ['-rtbufsize', '256M']));
      } else if (section == 'audio') {
        audio.add(CaptureDevice('dshow', 'audio=$name', name, options: const ['-rtbufsize', '64M']));
      }
    }
  }
  return (video: video, audio: audio);
}

/// PulseAudio/PipeWire sources from `pactl list short sources`
/// (`<id>\t<name>\t<driver>\t<format>\t<state>`); monitors capture what
/// the computer plays.
List<CaptureDevice> parsePulseSources(String out) => [
  for (final line in out.split('\n'))
    if (line.split('\t').length >= 2)
      () {
        final name = line.split('\t')[1].trim();
        return CaptureDevice('pulse', name, name);
      }(),
];

bool isSystemAudio(CaptureDevice d) => d.name.endsWith('.monitor') || d.label.toLowerCase().contains('stereo mix');

/// Encoder settings for live capture: fast presets so encoding keeps up.
class LiveEncode {
  const LiveEncode({
    this.encoder = 'libx264',
    this.videoKbps,
    this.crf = 23,
    this.fps = 30,
    this.audioKbps = 160,
    this.height,
    this.keyframeSeconds = 2,
  });

  /// Video encoder name (libx264, h264_nvenc, h264_qsv, h264_amf…).
  final String encoder;

  /// Constant bitrate (streaming); null = constant quality (recording).
  final int? videoKbps;
  final int crf;
  final int fps;
  final int audioKbps;

  /// Downscale to this height (null = keep).
  final int? height;
  final int keyframeSeconds;
}

List<String> _videoEncodeArgs(LiveEncode e, {required bool streaming}) {
  final spec = videoEncoderByName(e.encoder);
  final a = <String>['-c:v', e.encoder];
  if (e.videoKbps != null && spec != null) {
    a.addAll(spec.bitrateArgs(e.videoKbps!, constant: true));
    if (e.encoder == 'libx264') a.addAll(['-maxrate', '${e.videoKbps}k', '-bufsize', '${e.videoKbps! * 2}k']);
  } else if (spec != null && spec.hasQuality) {
    a.addAll(spec.qualityArgs(e.crf.clamp(spec.qualityMin, spec.qualityMax)));
  }
  if (spec != null) a.addAll(spec.presetArgs(SpeedPreset.fastest));
  if (e.encoder == 'libx264' && streaming) a.addAll(['-tune', 'zerolatency']);
  final g = e.fps * e.keyframeSeconds;
  a.addAll(['-g', '$g', '-keyint_min', '$g', '-pix_fmt', 'yuv420p']);
  return a;
}

/// What to capture.
class CaptureSources {
  const CaptureSources({this.video, this.audio = const [], this.file, this.loopFile = false});

  /// Screen or camera (null = audio only).
  final CaptureDevice? video;

  /// Microphone and/or system audio; several are mixed.
  final List<CaptureDevice> audio;

  /// Stream a file instead of devices (real-time: `-re`).
  final String? file;
  final bool loopFile;
}

/// The live ffmpeg command. No `-nostdin`: the recorder stops ffmpeg with
/// `q` on stdin so the file is finalized. Progress goes to stdout.
List<String> liveArgs({
  required CaptureSources src,
  required String output,
  required LiveEncode enc,
  String? format,
  bool streaming = false,
}) {
  final inputs = <FfmpegInput>[
    if (src.file != null)
      FfmpegInput(
        src.file!,
        options: [
          '-re',
          if (src.loopFile) ...['-stream_loop', '-1'],
        ],
      ),
    if (src.file == null && src.video != null) src.video!.toInput(),
    if (src.file == null)
      for (final a in src.audio) a.toInput(),
  ];
  final hasVideo = src.file != null || src.video != null;
  final audioStart = src.file == null && src.video != null ? 1 : 0;
  final nAudio = src.file != null ? 0 : src.audio.length;
  final parts = <String>[];
  String? vMap, aMap;
  if (hasVideo) {
    final scale = enc.height == null ? '' : 'scale=-2:${even(enc.height!)},';
    parts.add('[0:v:0]${scale}fps=${enc.fps},format=yuv420p[v]');
    vMap = '[v]';
  }
  if (src.file != null) {
    aMap = '0:a?';
  } else if (nAudio == 1) {
    aMap = '$audioStart:a:0';
  } else if (nAudio > 1) {
    parts.add(
      '${[for (var i = 0; i < nAudio; i++) '[${audioStart + i}:a:0]'].join()}amix=inputs=$nAudio:duration=longest:normalize=0[a]',
    );
    aMap = '[a]';
  }
  return [
    '-hide_banner',
    '-y',
    '-v',
    'error',
    '-progress',
    'pipe:1',
    '-nostats',
    for (final i in inputs) ...i.toArgs(),
    if (parts.isNotEmpty) ...['-filter_complex', parts.join(';')],
    if (vMap != null) ...['-map', vMap, ..._videoEncodeArgs(enc, streaming: streaming)],
    if (aMap != null) ...['-map', aMap, '-c:a', 'aac', '-b:a', '${enc.audioKbps}k', '-ar', '48000', '-ac', '2'],
    if (format != null) ...['-f', format],
    if (format == 'flv') ...['-flvflags', 'no_duration_filesize'],
    output,
  ];
}

List<String> recordArgs({required CaptureSources src, required String output, required LiveEncode enc}) =>
    liveArgs(src: src, output: output, enc: enc);

/// Live stream to RTMP(S) (FLV) or SRT (MPEG-TS).
List<String> streamArgs({required CaptureSources src, required String url, required LiveEncode enc}) {
  final format = url.startsWith('srt://') || url.startsWith('udp://') ? 'mpegts' : 'flv';
  return liveArgs(src: src, output: url, enc: enc, format: format, streaming: true);
}

/// Recording container: MKV survives a crash; MP4 needs a clean finish.
const recordingExt = 'mkv';

/// Remux a finished recording to MP4 (stream copy).
List<String> remuxToMp4Args(String input, String output) => FfmpegCommand(
  reportProgress: false,
  inputs: [FfmpegInput(input)],
  outputs: [
    FfmpegOutput(output, maps: ['0'], options: const ['-c', 'copy', '-movflags', '+faststart']),
  ],
).toArgs();

/// Parses `-progress` key=value lines of a live run.
class LiveStats {
  const LiveStats({this.time = Duration.zero, this.fps, this.kbps, this.drop = 0, this.dup = 0, this.speed});
  final Duration time;
  final double? fps;
  final double? kbps;
  final int drop;
  final int dup;
  final double? speed;
}

// ============================================================= HLS / DASH

enum PackageFormat { hls, dash }

/// Renditions of an adaptive ladder (height, video kb/s, audio kb/s).
const ladder = [(1080, 5000, 160), (720, 2800, 128), (480, 1400, 96), (360, 800, 64)];

/// Rungs not taller than the source.
List<(int, int, int)> ladderFor(MediaInfo info, List<int> heights) {
  final h = info.videoStreams.firstOrNull?.height ?? 1080;
  final rungs = ladder.where((r) => heights.contains(r.$1) && r.$1 <= math.max(h, 360)).toList();
  return rungs.isEmpty ? [ladder.last] : rungs;
}

/// HLS (`master.m3u8` + variant playlists) or DASH (`manifest.mpd`) in
/// [outDir]: each rung is a scaled H.264 + AAC rendition with aligned
/// keyframes ([segment] seconds apart).
List<JobStep> planPackage({
  required MediaInfo info,
  required String outDir,
  required PackageFormat format,
  required List<int> heights,
  int segment = 6,
  EncodeEnv env = const EncodeEnv(),
}) {
  final rungs = ladderFor(info, heights);
  final n = rungs.length;
  final hasAudio = info.audioStreams.isNotEmpty;
  final audioCount = format == PackageFormat.hls ? n : 1;
  final fps = info.videoStreams.firstOrNull?.avgFrameRate ?? 30;
  final gop = (fps * segment).round();
  final split = n == 1 ? '[0:v:0]null[s0]' : '[0:v:0]split=$n${[for (var i = 0; i < n; i++) '[s$i]'].join()}';
  final graph = [
    split,
    for (var i = 0; i < n; i++) '[s$i]scale=-2:${rungs[i].$1}:flags=lanczos,format=yuv420p[v$i]',
  ].join(';');
  final enc = pickVideoEncoder(VideoCodecChoice.h264, caps: env.caps, hw: env.hw, allowHardware: env.allowHardware);
  final encName = enc?.name ?? 'libx264';
  final args = <String>[
    '-hide_banner', '-nostdin', '-y', '-v', 'error', '-progress', 'pipe:1', '-nostats', //
    '-i', info.path,
    '-filter_complex', graph,
    for (var i = 0; i < n; i++) ...['-map', '[v$i]'],
    // HLS: every variant carries its own audio; DASH: one shared audio set.
    if (hasAudio)
      for (var i = 0; i < audioCount; i++) ...['-map', '0:a:0'],
    '-c:v', encName,
    if (enc != null) ...enc.presetArgs(SpeedPreset.medium),
    for (var i = 0; i < n; i++) ...[
      '-b:v:$i',
      '${rungs[i].$2}k',
      '-maxrate:v:$i',
      '${(rungs[i].$2 * 1.07).round()}k',
      '-bufsize:v:$i',
      '${rungs[i].$2 * 2}k', //
    ],
    '-g', '$gop', '-keyint_min', '$gop', '-sc_threshold', '0',
    if (hasAudio) ...['-c:a', 'aac', '-ar', '48000', '-ac', '2'],
    if (hasAudio)
      for (var i = 0; i < audioCount; i++) ...['-b:a:$i', '${rungs[i].$3}k'],
  ];
  if (format == PackageFormat.hls) {
    final map = [for (var i = 0; i < n; i++) hasAudio ? 'v:$i,a:$i,name:${rungs[i].$1}p' : 'v:$i,name:${rungs[i].$1}p']
        .join(' ');
    args.addAll([
      '-f', 'hls', '-hls_time', '$segment', '-hls_playlist_type', 'vod', //
      '-hls_segment_filename', p.join(outDir, '%v', 'seg_%04d.ts'),
      '-master_pl_name', 'master.m3u8',
      '-var_stream_map', map,
      p.join(outDir, '%v', 'index.m3u8'),
    ]);
  } else {
    final sets = hasAudio
        ? 'id=0,streams=${[for (var i = 0; i < n; i++) i].join(',')} id=1,streams=$n'
        : 'id=0,streams=${[for (var i = 0; i < n; i++) i].join(',')}';
    args.addAll([
      '-f', 'dash', '-seg_duration', '$segment', '-use_template', '1', '-use_timeline', '1', //
      '-adaptation_sets', sets,
      p.join(outDir, 'manifest.mpd'),
    ]);
  }
  return [JobStep(args: args, totalDuration: info.duration)];
}

/// Main file of a package (to open in a player / upload).
String packageEntry(String outDir, PackageFormat f) =>
    p.join(outDir, f == PackageFormat.hls ? 'master.m3u8' : 'manifest.mpd');

String fpsLabel(double v) => fnum(v, 2);
