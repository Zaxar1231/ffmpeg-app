/// Video/audio encoder knowledge: how each encoder expresses quality,
/// bitrate, speed presets, two-pass and pixel formats.
///
/// Every option here was checked against `ffmpeg -h encoder=<name>`
/// (ffmpeg 9.0 BtbN build) — encoders differ a lot (`-crf` vs `-cq` vs
/// `-global_quality` vs `-qp_i/-qp_p`), so this table is the single place
/// that knows the differences.
library;

import 'capabilities.dart';
import 'hwaccel.dart';

/// What the user picks; the concrete encoder is chosen from the build.
enum VideoCodecChoice { h264, hevc, av1, vp9, prores, dnxhr, ffv1, mjpeg, copy, none }

enum AudioCodecChoice { aac, opus, mp3, flac, alac, pcm16, pcm24, ac3, eac3, vorbis, copy, none }

/// Speed/quality trade-off, mapped onto each encoder's own preset scale.
enum SpeedPreset { fastest, fast, medium, slow, slowest }

class VideoEncoderSpec {
  const VideoEncoderSpec({
    required this.name,
    required this.choice,
    this.hardware = false,
    this.qualityMin = 0,
    this.qualityMax = 51,
    this.qualityDefault = 23,
    this.higherIsBetter = false,
    this.hasQuality = true,
    this.hasBitrate = true,
    this.twoPass = TwoPassStyle.none,
    this.presets = const {},
    this.tenBit = '',
    this.eightBit = 'yuv420p',
    this.profiles = const [],
    this.tunes = const [],
  });

  final String name;
  final VideoCodecChoice choice;
  final bool hardware;

  /// Native quality scale of the encoder (CRF/CQ/QP...).
  final int qualityMin;
  final int qualityMax;
  final int qualityDefault;

  /// True for scales where a higher number means better quality.
  final bool higherIsBetter;
  final bool hasQuality;
  final bool hasBitrate;
  final TwoPassStyle twoPass;
  final Map<SpeedPreset, String> presets;

  /// Pixel format for 10-bit output ('' = not supported).
  final String tenBit;
  final String eightBit;
  final List<String> profiles;
  final List<String> tunes;

  bool get supportsTenBit => tenBit.isNotEmpty;

  /// Options that select constant-quality mode at [q].
  List<String> qualityArgs(int q) => switch (name) {
    'libx264' || 'libx265' || 'libsvtav1' => ['-crf', '$q'],
    'libvpx-vp9' || 'libaom-av1' => ['-crf', '$q', '-b:v', '0'],
    'librav1e' => ['-qp', '$q'],
    'h264_nvenc' || 'hevc_nvenc' || 'av1_nvenc' => ['-rc', 'vbr', '-cq', '$q', '-b:v', '0'],
    'h264_qsv' || 'hevc_qsv' || 'av1_qsv' => ['-global_quality', '$q'],
    'h264_amf' || 'hevc_amf' => ['-rc', 'cqp', '-qp_i', '$q', '-qp_p', '$q', '-qp_b', '$q'],
    'av1_amf' => ['-rc', 'cqp', '-qp_i', '$q', '-qp_p', '$q'],
    'h264_vaapi' || 'hevc_vaapi' || 'av1_vaapi' => ['-rc_mode', 'CQP', '-qp', '$q'],
    'mjpeg' => ['-q:v', '$q'],
    _ => const [],
  };

  /// Options for average-bitrate (VBR) or constant-bitrate encoding.
  List<String> bitrateArgs(int kbps, {required bool constant}) {
    final b = ['-b:v', '${kbps}k'];
    final cbr = ['-minrate', '${kbps}k', '-maxrate', '${kbps}k', '-bufsize', '${kbps * 2}k'];
    return switch (name) {
      'h264_nvenc' || 'hevc_nvenc' || 'av1_nvenc' => ['-rc', constant ? 'cbr' : 'vbr', ...b],
      'h264_amf' || 'hevc_amf' || 'av1_amf' => ['-rc', constant ? 'cbr' : 'vbr_peak', ...b],
      'h264_vaapi' || 'hevc_vaapi' || 'av1_vaapi' => ['-rc_mode', constant ? 'CBR' : 'VBR', ...b],
      'libx264' || 'libx265' || 'libvpx-vp9' || 'libaom-av1' => [...b, if (constant) ...cbr],
      _ => [...b, if (constant) ...cbr.sublist(2)],
    };
  }

  List<String> presetArgs(SpeedPreset p) {
    final v = presets[p];
    if (v == null) return const [];
    return switch (name) {
      'libvpx-vp9' => ['-deadline', 'good', '-cpu-used', v, '-row-mt', '1'],
      'libaom-av1' => ['-cpu-used', v, '-row-mt', '1'],
      'librav1e' => ['-speed', v],
      'h264_amf' || 'hevc_amf' || 'av1_amf' => ['-quality', v],
      _ => ['-preset', v],
    };
  }
}

enum TwoPassStyle {
  none,

  /// `-pass 1|2 -passlogfile <prefix>` (x264, vp9, aom).
  passFlag,

  /// `-x265-params pass=1|2:stats=<file>`.
  x265,

  /// One process, encoder-internal multipass (`-multipass fullres`).
  nvencMultipass,
}

const _x26xPresets = {
  SpeedPreset.fastest: 'veryfast',
  SpeedPreset.fast: 'faster',
  SpeedPreset.medium: 'medium',
  SpeedPreset.slow: 'slow',
  SpeedPreset.slowest: 'veryslow',
};
const _nvencPresets = {
  SpeedPreset.fastest: 'p1',
  SpeedPreset.fast: 'p3',
  SpeedPreset.medium: 'p4',
  SpeedPreset.slow: 'p6',
  SpeedPreset.slowest: 'p7',
};
const _qsvPresets = {
  SpeedPreset.fastest: 'veryfast',
  SpeedPreset.fast: 'fast',
  SpeedPreset.medium: 'medium',
  SpeedPreset.slow: 'slow',
  SpeedPreset.slowest: 'veryslow',
};
const _amfPresets = {
  SpeedPreset.fastest: 'speed',
  SpeedPreset.fast: 'speed',
  SpeedPreset.medium: 'balanced',
  SpeedPreset.slow: 'quality',
  SpeedPreset.slowest: 'high_quality',
};
const _vaapiNone = <SpeedPreset, String>{};

const videoEncoders = <VideoEncoderSpec>[
  VideoEncoderSpec(
    name: 'libx264',
    choice: VideoCodecChoice.h264,
    qualityDefault: 23,
    twoPass: TwoPassStyle.passFlag,
    presets: _x26xPresets,
    tenBit: 'yuv420p10le',
    profiles: ['baseline', 'main', 'high', 'high10'],
    tunes: ['film', 'animation', 'grain', 'stillimage', 'fastdecode', 'zerolatency'],
  ),
  VideoEncoderSpec(
    name: 'libx265',
    choice: VideoCodecChoice.hevc,
    qualityDefault: 28,
    twoPass: TwoPassStyle.x265,
    presets: _x26xPresets,
    tenBit: 'yuv420p10le',
    profiles: ['main', 'main10'],
    tunes: ['grain', 'animation', 'fastdecode', 'zerolatency'],
  ),
  VideoEncoderSpec(
    name: 'libsvtav1',
    choice: VideoCodecChoice.av1,
    qualityMax: 63,
    qualityDefault: 35,
    presets: {
      SpeedPreset.fastest: '12',
      SpeedPreset.fast: '10',
      SpeedPreset.medium: '8',
      SpeedPreset.slow: '6',
      SpeedPreset.slowest: '4',
    },
    tenBit: 'yuv420p10le',
  ),
  VideoEncoderSpec(
    name: 'libaom-av1',
    choice: VideoCodecChoice.av1,
    qualityMax: 63,
    qualityDefault: 32,
    twoPass: TwoPassStyle.passFlag,
    presets: {
      SpeedPreset.fastest: '8',
      SpeedPreset.fast: '6',
      SpeedPreset.medium: '4',
      SpeedPreset.slow: '2',
      SpeedPreset.slowest: '1',
    },
    tenBit: 'yuv420p10le',
  ),
  VideoEncoderSpec(
    name: 'librav1e',
    choice: VideoCodecChoice.av1,
    qualityMax: 255,
    qualityDefault: 100,
    presets: {
      SpeedPreset.fastest: '10',
      SpeedPreset.fast: '8',
      SpeedPreset.medium: '6',
      SpeedPreset.slow: '4',
      SpeedPreset.slowest: '2',
    },
    tenBit: 'yuv420p10le',
  ),
  VideoEncoderSpec(
    name: 'libvpx-vp9',
    choice: VideoCodecChoice.vp9,
    qualityMax: 63,
    qualityDefault: 31,
    twoPass: TwoPassStyle.passFlag,
    presets: {
      SpeedPreset.fastest: '5',
      SpeedPreset.fast: '4',
      SpeedPreset.medium: '2',
      SpeedPreset.slow: '1',
      SpeedPreset.slowest: '0',
    },
    tenBit: 'yuv420p10le',
  ),
  // Hardware
  VideoEncoderSpec(
    name: 'h264_nvenc',
    choice: VideoCodecChoice.h264,
    hardware: true,
    qualityDefault: 23,
    twoPass: TwoPassStyle.nvencMultipass,
    presets: _nvencPresets,
  ),
  VideoEncoderSpec(
    name: 'hevc_nvenc',
    choice: VideoCodecChoice.hevc,
    hardware: true,
    qualityDefault: 26,
    twoPass: TwoPassStyle.nvencMultipass,
    presets: _nvencPresets,
    tenBit: 'p010le',
  ),
  VideoEncoderSpec(
    name: 'av1_nvenc',
    choice: VideoCodecChoice.av1,
    hardware: true,
    qualityDefault: 30,
    twoPass: TwoPassStyle.nvencMultipass,
    presets: _nvencPresets,
    tenBit: 'p010le',
  ),
  VideoEncoderSpec(
    name: 'h264_qsv',
    choice: VideoCodecChoice.h264,
    hardware: true,
    qualityMin: 1,
    presets: _qsvPresets,
    eightBit: 'nv12',
  ),
  VideoEncoderSpec(
    name: 'hevc_qsv',
    choice: VideoCodecChoice.hevc,
    hardware: true,
    qualityMin: 1,
    qualityDefault: 25,
    presets: _qsvPresets,
    eightBit: 'nv12',
    tenBit: 'p010le',
  ),
  VideoEncoderSpec(
    name: 'av1_qsv',
    choice: VideoCodecChoice.av1,
    hardware: true,
    qualityMin: 1,
    qualityDefault: 28,
    presets: _qsvPresets,
    eightBit: 'nv12',
    tenBit: 'p010le',
  ),
  VideoEncoderSpec(
    name: 'h264_amf',
    choice: VideoCodecChoice.h264,
    hardware: true,
    presets: _amfPresets,
    eightBit: 'nv12',
  ),
  VideoEncoderSpec(
    name: 'hevc_amf',
    choice: VideoCodecChoice.hevc,
    hardware: true,
    qualityDefault: 25,
    presets: _amfPresets,
    eightBit: 'nv12',
    tenBit: 'p010le',
  ),
  VideoEncoderSpec(
    name: 'av1_amf',
    choice: VideoCodecChoice.av1,
    hardware: true,
    qualityDefault: 30,
    presets: _amfPresets,
    eightBit: 'nv12',
    tenBit: 'p010le',
  ),
  VideoEncoderSpec(
    name: 'h264_vaapi',
    choice: VideoCodecChoice.h264,
    hardware: true,
    qualityMax: 52,
    presets: _vaapiNone,
    eightBit: 'nv12',
  ),
  VideoEncoderSpec(
    name: 'hevc_vaapi',
    choice: VideoCodecChoice.hevc,
    hardware: true,
    qualityMax: 52,
    qualityDefault: 25,
    presets: _vaapiNone,
    eightBit: 'nv12',
    tenBit: 'p010',
  ),
  VideoEncoderSpec(
    name: 'av1_vaapi',
    choice: VideoCodecChoice.av1,
    hardware: true,
    qualityMax: 255,
    qualityDefault: 120,
    presets: _vaapiNone,
    eightBit: 'nv12',
    tenBit: 'p010',
  ),
  // Intermediate / lossless
  VideoEncoderSpec(
    name: 'prores_ks',
    choice: VideoCodecChoice.prores,
    hasQuality: false,
    hasBitrate: false,
    eightBit: 'yuv422p10le',
    tenBit: 'yuv422p10le',
    profiles: ['proxy', 'lt', 'standard', 'hq', '4444', '4444xq'],
  ),
  VideoEncoderSpec(
    name: 'dnxhd',
    choice: VideoCodecChoice.dnxhr,
    hasQuality: false,
    hasBitrate: false,
    eightBit: 'yuv422p',
    tenBit: 'yuv422p10le',
    profiles: ['dnxhr_lb', 'dnxhr_sq', 'dnxhr_hq', 'dnxhr_hqx', 'dnxhr_444'],
  ),
  VideoEncoderSpec(
    name: 'ffv1',
    choice: VideoCodecChoice.ffv1,
    hasQuality: false,
    hasBitrate: false,
    tenBit: 'yuv420p10le',
  ),
  VideoEncoderSpec(
    name: 'mjpeg',
    choice: VideoCodecChoice.mjpeg,
    qualityMin: 2,
    qualityMax: 31,
    qualityDefault: 3,
    eightBit: 'yuvj420p',
  ),
];

VideoEncoderSpec? videoEncoderByName(String name) => videoEncoders.where((e) => e.name == name).firstOrNull;

/// Software encoders for a codec, in preference order.
List<VideoEncoderSpec> softwareEncodersFor(VideoCodecChoice c) =>
    videoEncoders.where((e) => e.choice == c && !e.hardware).toList();

/// Picks the encoder for [choice]: a working hardware encoder when allowed
/// (by the trial-encode report), else the first software encoder in the build.
VideoEncoderSpec? pickVideoEncoder(
  VideoCodecChoice choice, {
  required FfmpegCapabilities caps,
  HwAccelReport? hw,
  bool allowHardware = true,
  String? forced,
}) {
  if (forced != null) return videoEncoderByName(forced);
  if (allowHardware && hw != null) {
    final family = switch (choice) {
      VideoCodecChoice.h264 => VideoCodecFamily.h264,
      VideoCodecChoice.hevc => VideoCodecFamily.hevc,
      VideoCodecChoice.av1 => VideoCodecFamily.av1,
      _ => null,
    };
    final best = family == null ? null : hw.bestFor(family);
    if (best != null) {
      final spec = videoEncoderByName(best.name);
      if (spec != null) return spec;
    }
  }
  final sw = softwareEncodersFor(choice);
  // Without capabilities (tests, unknown build) take the first preference.
  if (caps.version == null) return sw.firstOrNull;
  return sw.where((e) => caps.hasEncoder(e.name)).firstOrNull;
}

/// All encoders for [choice] present in the build (for the expert picker).
List<VideoEncoderSpec> availableEncodersFor(VideoCodecChoice c, FfmpegCapabilities caps) =>
    videoEncoders.where((e) => e.choice == c && (caps.version == null || caps.hasEncoder(e.name))).toList();

/// Extra pre-input / filter arguments some hardware encoders need.
({List<String> global, List<String> filters}) hwEncoderPlumbing(String encoder) {
  if (encoder.endsWith('_vaapi')) {
    return (global: ['-vaapi_device', defaultVaapiDevice], filters: ['format=nv12', 'hwupload']);
  }
  return (global: const [], filters: const []);
}

// ------------------------------------------------------------------ audio

class AudioEncoderSpec {
  const AudioEncoderSpec(this.choice, this.name, {this.defaultKbps, this.lossless = false, this.extraArgs = const []});
  final AudioCodecChoice choice;
  final String name;

  /// null → no bitrate option (lossless / PCM).
  final int? defaultKbps;
  final bool lossless;
  final List<String> extraArgs;

  List<String> args({int? kbps}) => [
    '-c:a',
    name,
    if (defaultKbps != null) ...['-b:a', '${kbps ?? defaultKbps}k'],
    ...extraArgs,
  ];
}

const audioEncoders = <AudioCodecChoice, AudioEncoderSpec>{
  AudioCodecChoice.aac: AudioEncoderSpec(AudioCodecChoice.aac, 'aac', defaultKbps: 192),
  AudioCodecChoice.opus: AudioEncoderSpec(AudioCodecChoice.opus, 'libopus', defaultKbps: 128),
  AudioCodecChoice.mp3: AudioEncoderSpec(AudioCodecChoice.mp3, 'libmp3lame', defaultKbps: 192),
  AudioCodecChoice.vorbis: AudioEncoderSpec(AudioCodecChoice.vorbis, 'libvorbis', defaultKbps: 160),
  AudioCodecChoice.ac3: AudioEncoderSpec(AudioCodecChoice.ac3, 'ac3', defaultKbps: 448),
  AudioCodecChoice.eac3: AudioEncoderSpec(AudioCodecChoice.eac3, 'eac3', defaultKbps: 640),
  AudioCodecChoice.flac: AudioEncoderSpec(AudioCodecChoice.flac, 'flac', lossless: true),
  AudioCodecChoice.alac: AudioEncoderSpec(AudioCodecChoice.alac, 'alac', lossless: true),
  AudioCodecChoice.pcm16: AudioEncoderSpec(AudioCodecChoice.pcm16, 'pcm_s16le', lossless: true),
  AudioCodecChoice.pcm24: AudioEncoderSpec(AudioCodecChoice.pcm24, 'pcm_s24le', lossless: true),
};

/// Typical bitrate (kbps) used to estimate sizes of lossless audio.
int estimateAudioKbps(AudioCodecChoice c, {int? sourceKbps, int channels = 2, int sampleRate = 48000}) => switch (c) {
  AudioCodecChoice.none => 0,
  AudioCodecChoice.copy => sourceKbps ?? 192,
  AudioCodecChoice.pcm16 => sampleRate * 16 * channels ~/ 1000,
  AudioCodecChoice.pcm24 => sampleRate * 24 * channels ~/ 1000,
  AudioCodecChoice.flac || AudioCodecChoice.alac => (sampleRate * 16 * channels * 0.6) ~/ 1000,
  _ => audioEncoders[c]!.defaultKbps ?? 192,
};
