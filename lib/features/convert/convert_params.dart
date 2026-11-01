import '../../core/engine/capabilities.dart';
import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/engine/hwaccel.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';

enum RateMode {
  /// Constant quality (CRF/CQ/QP): best default, size depends on content.
  quality,

  /// Average bitrate.
  bitrate,

  /// Constant bitrate (streaming, strict players).
  cbr,

  /// Hit a file size: bitrate is computed from duration (two-pass if possible).
  targetSize,
}

/// Everything the Convert/Compress tool can set. Serializable for presets.
class ConvertParams {
  const ConvertParams({
    this.container = 'mp4',
    this.video = VideoCodecChoice.h264,
    this.audio = AudioCodecChoice.aac,
    this.useHardware = true,
    this.encoderOverride,
    this.rateMode = RateMode.quality,
    this.quality,
    this.videoKbps = 4000,
    this.targetSizeMb = 10,
    this.twoPass = true,
    this.speed = SpeedPreset.medium,
    this.tenBit = false,
    this.profile,
    this.tune,
    this.maxHeight,
    this.fps,
    this.keyframeSeconds,
    this.audioKbps,
    this.audioChannels,
    this.sampleRate,
    this.faststart = true,
    this.keepSubtitles = true,
    this.keepMetadata = true,
  });

  final String container;
  final VideoCodecChoice video;
  final AudioCodecChoice audio;

  /// Use a working hardware encoder when one exists for the codec.
  final bool useHardware;

  /// Expert: a specific encoder name (e.g. `libaom-av1`).
  final String? encoderOverride;
  final RateMode rateMode;

  /// Encoder-native quality value; null → encoder default.
  final int? quality;
  final int videoKbps;
  final double targetSizeMb;
  final bool twoPass;
  final SpeedPreset speed;
  final bool tenBit;

  /// Encoder profile (x264 `high`, ProRes `hq`, DNxHR `dnxhr_hq`...).
  final String? profile;
  final String? tune;

  /// Downscale to this height if the source is taller (never upscales).
  final int? maxHeight;
  final double? fps;

  /// Keyframe interval in seconds (`-g` = fps × seconds).
  final double? keyframeSeconds;
  final int? audioKbps;

  /// 1 = mono, 2 = stereo; null keeps the source layout.
  final int? audioChannels;
  final int? sampleRate;
  final bool faststart;
  final bool keepSubtitles;
  final bool keepMetadata;

  ConvertParams copyWith({
    String? container,
    VideoCodecChoice? video,
    AudioCodecChoice? audio,
    bool? useHardware,
    String? Function()? encoderOverride,
    RateMode? rateMode,
    int? Function()? quality,
    int? videoKbps,
    double? targetSizeMb,
    bool? twoPass,
    SpeedPreset? speed,
    bool? tenBit,
    String? Function()? profile,
    String? Function()? tune,
    int? Function()? maxHeight,
    double? Function()? fps,
    double? Function()? keyframeSeconds,
    int? Function()? audioKbps,
    int? Function()? audioChannels,
    int? Function()? sampleRate,
    bool? faststart,
    bool? keepSubtitles,
    bool? keepMetadata,
  }) => ConvertParams(
    container: container ?? this.container,
    video: video ?? this.video,
    audio: audio ?? this.audio,
    useHardware: useHardware ?? this.useHardware,
    encoderOverride: encoderOverride != null ? encoderOverride() : this.encoderOverride,
    rateMode: rateMode ?? this.rateMode,
    quality: quality != null ? quality() : this.quality,
    videoKbps: videoKbps ?? this.videoKbps,
    targetSizeMb: targetSizeMb ?? this.targetSizeMb,
    twoPass: twoPass ?? this.twoPass,
    speed: speed ?? this.speed,
    tenBit: tenBit ?? this.tenBit,
    profile: profile != null ? profile() : this.profile,
    tune: tune != null ? tune() : this.tune,
    maxHeight: maxHeight != null ? maxHeight() : this.maxHeight,
    fps: fps != null ? fps() : this.fps,
    keyframeSeconds: keyframeSeconds != null ? keyframeSeconds() : this.keyframeSeconds,
    audioKbps: audioKbps != null ? audioKbps() : this.audioKbps,
    audioChannels: audioChannels != null ? audioChannels() : this.audioChannels,
    sampleRate: sampleRate != null ? sampleRate() : this.sampleRate,
    faststart: faststart ?? this.faststart,
    keepSubtitles: keepSubtitles ?? this.keepSubtitles,
    keepMetadata: keepMetadata ?? this.keepMetadata,
  );

  Map<String, Object?> toJson() => {
    'container': container,
    'video': video.name,
    'audio': audio.name,
    'useHardware': useHardware,
    'encoderOverride': encoderOverride,
    'rateMode': rateMode.name,
    'quality': quality,
    'videoKbps': videoKbps,
    'targetSizeMb': targetSizeMb,
    'twoPass': twoPass,
    'speed': speed.name,
    'tenBit': tenBit,
    'profile': profile,
    'tune': tune,
    'maxHeight': maxHeight,
    'fps': fps,
    'keyframeSeconds': keyframeSeconds,
    'audioKbps': audioKbps,
    'audioChannels': audioChannels,
    'sampleRate': sampleRate,
    'faststart': faststart,
    'keepSubtitles': keepSubtitles,
    'keepMetadata': keepMetadata,
  };

  factory ConvertParams.fromJson(Map<String, Object?> j) {
    const d = ConvertParams();
    T e<T extends Enum>(List<T> v, Object? x, T def) => v.where((a) => a.name == x).firstOrNull ?? def;
    return ConvertParams(
      container: containers.containsKey(j['container']) ? j['container'] as String : d.container,
      video: e(VideoCodecChoice.values, j['video'], d.video),
      audio: e(AudioCodecChoice.values, j['audio'], d.audio),
      useHardware: j['useHardware'] as bool? ?? d.useHardware,
      encoderOverride: j['encoderOverride'] as String?,
      rateMode: e(RateMode.values, j['rateMode'], d.rateMode),
      quality: (j['quality'] as num?)?.toInt(),
      videoKbps: (j['videoKbps'] as num?)?.toInt() ?? d.videoKbps,
      targetSizeMb: (j['targetSizeMb'] as num?)?.toDouble() ?? d.targetSizeMb,
      twoPass: j['twoPass'] as bool? ?? d.twoPass,
      speed: e(SpeedPreset.values, j['speed'], d.speed),
      tenBit: j['tenBit'] as bool? ?? d.tenBit,
      profile: j['profile'] as String?,
      tune: j['tune'] as String?,
      maxHeight: (j['maxHeight'] as num?)?.toInt(),
      fps: (j['fps'] as num?)?.toDouble(),
      keyframeSeconds: (j['keyframeSeconds'] as num?)?.toDouble(),
      audioKbps: (j['audioKbps'] as num?)?.toInt(),
      audioChannels: (j['audioChannels'] as num?)?.toInt(),
      sampleRate: (j['sampleRate'] as num?)?.toInt(),
      faststart: j['faststart'] as bool? ?? d.faststart,
      keepSubtitles: j['keepSubtitles'] as bool? ?? d.keepSubtitles,
      keepMetadata: j['keepMetadata'] as bool? ?? d.keepMetadata,
    );
  }
}

/// Build environment: what the installed ffmpeg and machine can do.
class EncodeEnv {
  const EncodeEnv({this.caps = FfmpegCapabilities.empty, this.hw, this.allowHardware = true, this.threads = 0});
  final FfmpegCapabilities caps;
  final HwAccelReport? hw;

  /// Global switch from settings.
  final bool allowHardware;

  /// `-threads` (0 = automatic).
  final int threads;
}

/// Problems that block the job, shown in the UI before queueing.
enum ConvertIssue {
  noVideoEncoder,
  videoNotInContainer,
  audioNotInContainer,
  copyNotInContainer,
  durationUnknown,
  targetTooSmall,
  noTenBit,
}

class ConvertPlan {
  const ConvertPlan({
    required this.steps,
    required this.encoder,
    required this.issues,
    this.videoKbps,
    this.audioKbps,
    this.estimatedBytes,
    this.warnings = const [],
  });

  final List<JobStep> steps;

  /// Chosen video encoder (null for copy/none/audio-only).
  final VideoEncoderSpec? encoder;
  final List<ConvertIssue> issues;
  final List<ConvertIssue> warnings;

  /// Resulting bitrates for estimates (target size / bitrate modes).
  final int? videoKbps;
  final int? audioKbps;
  final int? estimatedBytes;

  bool get ok => issues.isEmpty;
}

/// Bitrate (kbps) for the video so that video+audio fit [sizeMb] MiB.
/// Keeps ~3% for container overhead. Returns null if impossible.
int? targetVideoKbps({required double sizeMb, required Duration duration, required int audioKbps}) {
  final secs = duration.inMicroseconds / 1e6;
  if (secs <= 0) return null;
  final totalKbps = sizeMb * 1024 * 1024 * 8 / 1000 / secs * 0.97;
  final v = (totalKbps - audioKbps).floor();
  return v < 50 ? null : v;
}

/// A filter graph that replaces the plain "input → encoder" path: editing
/// tools describe extra inputs and a `-filter_complex` whose labeled outputs
/// are encoded with the usual encoder settings.
class EditGraph {
  const EditGraph({
    this.inputs = const [],
    required this.complex,
    this.video,
    this.audio,
    this.duration,
    this.mainInput,
  });

  /// Inputs after the main one (`1:…`, `2:…`).
  final List<FfmpegInput> inputs;

  /// Replaces the plain `-i <main>` (e.g. to add `-stream_loop`).
  final FfmpegInput? mainInput;
  final String complex;

  /// Output labels without brackets (`v`, `a`); null = no such stream.
  final String? video;
  final String? audio;

  /// Length of the result when it differs from the source.
  final Duration? duration;
}

/// Builds the job steps for converting [info] to [output].
ConvertPlan planConvert({
  required MediaInfo info,
  required String output,
  required ConvertParams p,
  EncodeEnv env = const EncodeEnv(),
  EditGraph? graph,
}) {
  final issues = <ConvertIssue>[];
  final warnings = <ConvertIssue>[];
  final c = containerFor(p.container);
  final srcVideo = info.videoStreams.firstOrNull;
  final srcAudio = info.audioStreams.toList();
  final duration = graph != null ? (graph.duration ?? info.duration) : info.duration;

  // ------------------------------------------------------------ video
  final wantVideo =
      !c.audioOnly && srcVideo != null && p.video != VideoCodecChoice.none && (graph == null || graph.video != null);
  if (graph != null && graph.video != null && p.video == VideoCodecChoice.copy) {
    issues.add(ConvertIssue.noVideoEncoder);
  }
  VideoEncoderSpec? enc;
  if (wantVideo && p.video != VideoCodecChoice.copy) {
    if (!c.video.contains(p.video)) issues.add(ConvertIssue.videoNotInContainer);
    enc = pickVideoEncoder(
      p.video,
      caps: env.caps,
      hw: env.hw,
      allowHardware: env.allowHardware && p.useHardware,
      forced: p.encoderOverride,
    );
    if (enc == null) issues.add(ConvertIssue.noVideoEncoder);
  }
  if (wantVideo && p.video == VideoCodecChoice.copy && !c.acceptsCopy(srcVideo.codecName)) {
    issues.add(ConvertIssue.copyNotInContainer);
  }

  // ------------------------------------------------------------ audio
  final wantAudio = srcAudio.isNotEmpty && p.audio != AudioCodecChoice.none && (graph == null || graph.audio != null);
  if (wantAudio && p.audio != AudioCodecChoice.copy && !c.audio.contains(p.audio)) {
    issues.add(ConvertIssue.audioNotInContainer);
  }
  if (wantAudio && p.audio == AudioCodecChoice.copy && srcAudio.any((a) => !c.acceptsCopy(a.codecName))) {
    issues.add(ConvertIssue.copyNotInContainer);
  }
  final aSpec = audioEncoders[p.audio];
  final audioKbps = !wantAudio
      ? 0
      : (p.audio == AudioCodecChoice.copy
            ? ((srcAudio.first.bitRate ?? 192000) ~/ 1000)
            : (p.audioKbps ?? estimateAudioKbps(p.audio, channels: p.audioChannels ?? srcAudio.first.channels ?? 2)));

  // ------------------------------------------------------------ rate
  int? videoKbps;
  final encoding = enc != null;
  if (encoding && enc.hasBitrate) {
    switch (p.rateMode) {
      case RateMode.bitrate:
      case RateMode.cbr:
        videoKbps = p.videoKbps;
      case RateMode.targetSize:
        if (duration == null) {
          issues.add(ConvertIssue.durationUnknown);
        } else {
          videoKbps = targetVideoKbps(sizeMb: p.targetSizeMb, duration: duration, audioKbps: audioKbps);
          if (videoKbps == null) issues.add(ConvertIssue.targetTooSmall);
        }
      case RateMode.quality:
        break;
    }
  }
  if (encoding && p.tenBit && !enc.supportsTenBit) warnings.add(ConvertIssue.noTenBit);

  // ------------------------------------------------------------ filters
  final vf = <String>[];
  final srcH = srcVideo?.height;
  if (encoding && p.maxHeight != null && srcH != null && srcH > p.maxHeight!) {
    // -2 keeps the aspect ratio with an even width (required by most encoders).
    vf.add('scale=-2:${p.maxHeight}:flags=lanczos');
  }
  if (encoding && p.fps != null) vf.add('fps=${_num(p.fps!)}');
  final plumbing = enc == null ? null : hwEncoderPlumbing(enc.name);
  if (plumbing != null) vf.addAll(plumbing.filters);

  final af = <String>[];

  // ------------------------------------------------------------ args
  List<String> videoArgs({int? pass}) {
    if (!wantVideo) return const [];
    if (p.video == VideoCodecChoice.copy) return ['-c:v', 'copy'];
    if (enc == null) return const [];
    final a = <String>['-c:v', enc.name];
    final useBitrate = videoKbps != null && p.rateMode != RateMode.quality;
    if (useBitrate) {
      a.addAll(enc.bitrateArgs(videoKbps, constant: p.rateMode == RateMode.cbr));
    } else if (enc.hasQuality) {
      final q = (p.quality ?? enc.qualityDefault).clamp(enc.qualityMin, enc.qualityMax);
      a.addAll(enc.qualityArgs(q));
    }
    a.addAll(enc.presetArgs(p.speed));
    var pixFmt = p.tenBit && enc.supportsTenBit ? enc.tenBit : enc.eightBit;
    // 4:4:4 intermediate profiles need a 4:4:4 pixel format.
    if (p.profile == '4444' || p.profile == '4444xq' || p.profile == 'dnxhr_444') pixFmt = 'yuv444p10le';
    if (p.profile == 'dnxhr_hqx') pixFmt = 'yuv422p10le';
    // vaapi frames are already uploaded in the filter chain.
    if (!enc.name.endsWith('_vaapi')) a.addAll(['-pix_fmt', pixFmt]);
    final profile = p.profile;
    if (profile != null && enc.profiles.contains(profile)) {
      a.addAll(['-profile:v', profile]);
    } else if (enc.name == 'libx265' && p.tenBit) {
      a.addAll(['-profile:v', 'main10']);
    }
    if (p.tune != null && enc.tunes.contains(p.tune)) a.addAll(['-tune', p.tune!]);
    if (enc.name == 'ffv1') a.addAll(['-level', '3', '-g', '1', '-slicecrc', '1']);
    if (p.keyframeSeconds != null) {
      final f = p.fps ?? srcVideo.avgFrameRate ?? srcVideo.frameRate ?? 30;
      a.addAll(['-g', '${(f * p.keyframeSeconds!).round().clamp(1, 100000)}']);
    }
    // Apple players need the hvc1 tag for HEVC in MP4/MOV.
    if (enc.choice == VideoCodecChoice.hevc && (p.container == 'mp4' || p.container == 'mov')) {
      a.addAll(['-tag:v', 'hvc1']);
    }
    if (pass != null) {
      // Both passes must see the same frames. The null muxer (pass 1) and
      // MP4 (pass 2) default to different sync modes, which makes x264 fail
      // with "Incomplete MB-tree stats file" — so pin it.
      a.addAll(['-fps_mode', 'vfr']);
      switch (enc.twoPass) {
        case TwoPassStyle.passFlag:
          a.addAll(['-pass', '$pass', '-passlogfile', 'kadra2pass']);
        case TwoPassStyle.x265:
          a.addAll(['-x265-params', 'pass=$pass:stats=kadra2pass.log']);
        case TwoPassStyle.nvencMultipass:
        case TwoPassStyle.none:
          break;
      }
    } else if (enc.twoPass == TwoPassStyle.nvencMultipass && useBitrate && p.twoPass) {
      a.addAll(['-multipass', 'fullres']);
    }
    return a;
  }

  List<String> audioArgs() {
    if (!wantAudio) return const [];
    if (p.audio == AudioCodecChoice.copy) return ['-c:a', 'copy'];
    if (aSpec == null) return const [];
    return [
      ...aSpec.args(kbps: p.audioKbps),
      if (p.audioChannels != null) ...['-ac', '${p.audioChannels}'],
      if (p.sampleRate != null) ...['-ar', '${p.sampleRate}'],
    ];
  }

  // With a graph, encoder plumbing/scaling is appended to its outputs.
  String? complex;
  var vMap = wantVideo ? '0:${srcVideo.index}' : null;
  var aMap = wantAudio ? '0:a' : null;
  if (graph != null) {
    complex = graph.complex;
    if (wantVideo) {
      vMap = '[${graph.video}]';
      if (vf.isNotEmpty) {
        complex = '$complex;[${graph.video}]${vf.join(',')}[vEnc]';
        vMap = '[vEnc]';
      }
    }
    // A raw stream specifier (`0:a`) passes audio through untouched.
    if (wantAudio) aMap = graph.audio!.contains(':') ? graph.audio! : '[${graph.audio}]';
  }
  final keepSubs = graph == null && c.subtitles && p.keepSubtitles && info.subtitleStreams.isNotEmpty;
  final maps = <String>[?vMap, ?aMap, if (keepSubs) '0:s'];
  final inputs = graph == null
      ? [FfmpegInput(info.path)]
      : [graph.mainInput ?? FfmpegInput(info.path), ...graph.inputs];
  final outVf = graph == null ? vf : const <String>[];
  final subtitleArgs = keepSubs ? ['-c:s', 'copy'] : <String>[];
  final global = <String>[
    if (env.threads > 0) ...['-threads', '${env.threads}'],
    ...?plumbing?.global,
  ];
  final container = <String>[
    if (c.faststart && p.faststart) ...['-movflags', '+faststart'],
    if (!p.keepMetadata) ...['-map_metadata', '-1', '-map_chapters', '-1'],
  ];

  FfmpegCommand finalCmd() => FfmpegCommand(
    globalOptions: global,
    inputs: inputs,
    filterComplex: complex,
    outputs: [
      FfmpegOutput(
        output,
        maps: maps,
        videoFilters: outVf,
        audioFilters: af,
        noVideo: !wantVideo,
        noAudio: !wantAudio,
        options: [
          ...videoArgs(pass: _isTwoPass(enc, p, videoKbps) ? 2 : null),
          ...audioArgs(),
          ...subtitleArgs,
          ...container,
        ],
      ),
    ],
  );

  final steps = <JobStep>[];
  if (_isTwoPass(enc, p, videoKbps)) {
    final pass1 = FfmpegCommand(
      globalOptions: global,
      inputs: inputs,
      filterComplex: complex,
      outputs: [
        FfmpegOutput(
          '-',
          maps: graph == null ? [vMap!] : [vMap!, ?aMap],
          videoFilters: outVf,
          noAudio: graph == null,
          format: 'null',
          options: videoArgs(pass: 1),
        ),
      ],
    );
    steps
      ..add(JobStep(args: pass1.toArgs(), label: '1/2', weight: 0.4, workingDirectory: '{{tmp}}'))
      ..add(JobStep(args: finalCmd().toArgs(), label: '2/2', weight: 0.6, workingDirectory: '{{tmp}}'));
  } else {
    steps.add(JobStep(args: finalCmd().toArgs()));
  }

  int? estimate;
  if (duration != null && (videoKbps != null || !wantVideo)) {
    estimate = ((videoKbps ?? 0) + audioKbps) * 1000 * duration.inMicroseconds ~/ 8 ~/ 1000000;
  } else if (duration != null && wantVideo && p.video == VideoCodecChoice.copy) {
    final vb = srcVideo.bitRate ?? (info.format.bitRate ?? 0) - audioKbps * 1000;
    estimate = (vb + audioKbps * 1000) * duration.inMicroseconds ~/ 8 ~/ 1000000;
  }

  return ConvertPlan(
    steps: steps,
    encoder: enc,
    issues: issues,
    warnings: warnings,
    videoKbps: videoKbps,
    audioKbps: wantAudio ? audioKbps : null,
    estimatedBytes: estimate,
  );
}

bool _isTwoPass(VideoEncoderSpec? enc, ConvertParams p, int? videoKbps) =>
    enc != null &&
    p.twoPass &&
    videoKbps != null &&
    (p.rateMode == RateMode.bitrate || p.rateMode == RateMode.targetSize) &&
    (enc.twoPass == TwoPassStyle.passFlag || enc.twoPass == TwoPassStyle.x265);

String _num(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

/// Wraps a plan into a queue request.
JobRequest convertJob(
  ConvertPlan plan, {
  required MediaInfo info,
  required String output,
  required String title,
  int priority = 0,
}) => JobRequest(
  kind: 'convert',
  title: title,
  tool: JobTool.ffmpeg,
  steps: plan.steps,
  inputPath: info.path,
  outputPath: output,
  totalDuration: info.duration,
  priority: priority,
);
