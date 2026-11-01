import '../../core/engine/encoders.dart';
import 'convert_params.dart';

/// Built-in presets of the Convert/Compress tool. Ids are stable (stored in
/// recipes and user settings); names come from localization.
class BuiltinPreset {
  const BuiltinPreset(this.id, this.params);
  final String id;
  final ConvertParams params;
}

const builtinPresets = <BuiltinPreset>[
  // Telegram re-encodes anything big; H.264 1080p with fast start plays inline.
  BuiltinPreset(
    'telegram',
    ConvertParams(container: 'mp4', video: VideoCodecChoice.h264, quality: 23, maxHeight: 1080, audioKbps: 128),
  ),
  // YouTube recommends high-bitrate H.264, AAC 48 kHz; it re-encodes anyway,
  // so give it a high-quality master.
  BuiltinPreset(
    'youtube',
    ConvertParams(
      container: 'mp4',
      video: VideoCodecChoice.h264,
      quality: 18,
      speed: SpeedPreset.slow,
      audioKbps: 320,
      sampleRate: 48000,
      keyframeSeconds: 2,
    ),
  ),
  // Discord free upload limit: 10 MiB. Two-pass to land just under it.
  BuiltinPreset(
    'discord',
    ConvertParams(
      container: 'mp4',
      video: VideoCodecChoice.h264,
      rateMode: RateMode.targetSize,
      targetSizeMb: 9.5,
      twoPass: true,
      useHardware: false,
      maxHeight: 720,
      audioKbps: 96,
    ),
  ),
  // Editing: intra-frame, easy to scrub, PCM audio.
  BuiltinPreset(
    'editProres',
    ConvertParams(
      container: 'mov',
      video: VideoCodecChoice.prores,
      profile: 'hq',
      audio: AudioCodecChoice.pcm24,
      faststart: false,
    ),
  ),
  BuiltinPreset(
    'editDnxhr',
    ConvertParams(
      container: 'mov',
      video: VideoCodecChoice.dnxhr,
      profile: 'dnxhr_hq',
      audio: AudioCodecChoice.pcm24,
      faststart: false,
    ),
  ),
  // Mathematically lossless: FFV1 + FLAC in Matroska.
  BuiltinPreset(
    'archive',
    ConvertParams(container: 'mkv', video: VideoCodecChoice.ffv1, audio: AudioCodecChoice.flac, useHardware: false),
  ),
  // Smallest files at good quality: AV1 (SVT) + Opus. Slow, but worth it.
  BuiltinPreset(
    'maxCompression',
    ConvertParams(
      container: 'mp4',
      video: VideoCodecChoice.av1,
      quality: 38,
      speed: SpeedPreset.slow,
      useHardware: false,
      tenBit: true,
      audio: AudioCodecChoice.opus,
      audioKbps: 96,
    ),
  ),
  // Compress: same codec, lower quality, cap 1080p — the "just make it smaller" button.
  BuiltinPreset(
    'compress',
    ConvertParams(container: 'mp4', video: VideoCodecChoice.h264, quality: 26, maxHeight: 1080, audioKbps: 128),
  ),
];

BuiltinPreset? builtinPresetById(String id) => builtinPresets.where((p) => p.id == id).firstOrNull;
