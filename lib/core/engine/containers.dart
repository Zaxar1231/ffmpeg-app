/// Output containers and which codecs they accept.
///
/// The muxer is chosen by ffmpeg from the file extension, so no `-f` is
/// needed. Compatibility lists are conservative: what plays reliably, not
/// everything a muxer technically accepts.
library;

import 'encoders.dart';

class ContainerSpec {
  const ContainerSpec(
    this.ext, {
    required this.video,
    required this.audio,
    this.audioOnly = false,
    this.subtitles = false,
    this.faststart = false,
    this.copyCodecs = const {},
  });

  /// File extension (also the id), e.g. `mp4`.
  final String ext;
  final Set<VideoCodecChoice> video;
  final Set<AudioCodecChoice> audio;
  final bool audioOnly;

  /// Can carry subtitle streams as-is (`-c:s copy`).
  final bool subtitles;

  /// Supports `-movflags +faststart`.
  final bool faststart;

  /// ffprobe codec names accepted for stream copy (empty = anything).
  final Set<String> copyCodecs;

  bool acceptsCopy(String? codecName) => copyCodecs.isEmpty || (codecName != null && copyCodecs.contains(codecName));
}

const _mp4Copy = {
  'h264', 'hevc', 'av1', 'vp9', 'mpeg4', 'mjpeg', 'aac', 'mp3', 'opus', 'flac', 'alac', 'ac3', 'eac3', 'mov_text', //
};

const containers = <String, ContainerSpec>{
  'mp4': ContainerSpec(
    'mp4',
    video: {
      VideoCodecChoice.h264,
      VideoCodecChoice.hevc,
      VideoCodecChoice.av1,
      VideoCodecChoice.vp9,
      VideoCodecChoice.mjpeg,
    },
    audio: {
      AudioCodecChoice.aac,
      AudioCodecChoice.mp3,
      AudioCodecChoice.opus,
      AudioCodecChoice.flac,
      AudioCodecChoice.alac,
      AudioCodecChoice.ac3,
      AudioCodecChoice.eac3,
    },
    faststart: true,
    copyCodecs: _mp4Copy,
  ),
  'mkv': ContainerSpec(
    'mkv',
    video: {
      VideoCodecChoice.h264,
      VideoCodecChoice.hevc,
      VideoCodecChoice.av1,
      VideoCodecChoice.vp9,
      VideoCodecChoice.prores,
      VideoCodecChoice.dnxhr,
      VideoCodecChoice.ffv1,
      VideoCodecChoice.mjpeg,
    },
    audio: {
      AudioCodecChoice.aac,
      AudioCodecChoice.opus,
      AudioCodecChoice.mp3,
      AudioCodecChoice.flac,
      AudioCodecChoice.alac,
      AudioCodecChoice.pcm16,
      AudioCodecChoice.pcm24,
      AudioCodecChoice.ac3,
      AudioCodecChoice.eac3,
      AudioCodecChoice.vorbis,
    },
    subtitles: true,
  ),
  'mov': ContainerSpec(
    'mov',
    video: {
      VideoCodecChoice.h264,
      VideoCodecChoice.hevc,
      VideoCodecChoice.prores,
      VideoCodecChoice.dnxhr,
      VideoCodecChoice.mjpeg,
    },
    audio: {
      AudioCodecChoice.aac,
      AudioCodecChoice.alac,
      AudioCodecChoice.pcm16,
      AudioCodecChoice.pcm24,
      AudioCodecChoice.mp3,
      AudioCodecChoice.ac3,
    },
    faststart: true,
    // FLAC and Opus are only allowed in ISO MP4 mode, not in QuickTime MOV.
    copyCodecs: {
      'h264', 'hevc', 'mpeg4', 'mjpeg', 'prores', 'dnxhd', 'aac', 'alac', 'mp3', 'ac3', 'eac3', //
      'pcm_s16le', 'pcm_s24le', 'mov_text',
    },
  ),
  'webm': ContainerSpec(
    'webm',
    video: {VideoCodecChoice.vp9, VideoCodecChoice.av1},
    audio: {AudioCodecChoice.opus, AudioCodecChoice.vorbis},
    copyCodecs: {'vp8', 'vp9', 'av1', 'opus', 'vorbis', 'webvtt'},
  ),
  'avi': ContainerSpec(
    'avi',
    video: {VideoCodecChoice.h264, VideoCodecChoice.mjpeg, VideoCodecChoice.ffv1},
    audio: {AudioCodecChoice.mp3, AudioCodecChoice.pcm16, AudioCodecChoice.ac3},
  ),
  'ts': ContainerSpec(
    'ts',
    video: {VideoCodecChoice.h264, VideoCodecChoice.hevc},
    audio: {
      AudioCodecChoice.aac,
      AudioCodecChoice.mp3,
      AudioCodecChoice.ac3,
      AudioCodecChoice.eac3,
      AudioCodecChoice.opus,
    },
    copyCodecs: {'h264', 'hevc', 'mpeg2video', 'aac', 'mp3', 'mp2', 'ac3', 'eac3', 'opus'},
  ),
  // Audio only
  'm4a': ContainerSpec(
    'm4a',
    video: {},
    audio: {AudioCodecChoice.aac, AudioCodecChoice.alac},
    audioOnly: true,
    faststart: true,
    copyCodecs: {'aac', 'alac'},
  ),
  'mp3': ContainerSpec('mp3', video: {}, audio: {AudioCodecChoice.mp3}, audioOnly: true, copyCodecs: {'mp3'}),
  'opus': ContainerSpec('opus', video: {}, audio: {AudioCodecChoice.opus}, audioOnly: true, copyCodecs: {'opus'}),
  'ogg': ContainerSpec(
    'ogg',
    video: {},
    audio: {AudioCodecChoice.vorbis, AudioCodecChoice.opus, AudioCodecChoice.flac},
    audioOnly: true,
    copyCodecs: {'vorbis', 'opus', 'flac'},
  ),
  'flac': ContainerSpec('flac', video: {}, audio: {AudioCodecChoice.flac}, audioOnly: true, copyCodecs: {'flac'}),
  'wav': ContainerSpec(
    'wav',
    video: {},
    audio: {AudioCodecChoice.pcm16, AudioCodecChoice.pcm24},
    audioOnly: true,
    copyCodecs: {'pcm_s16le', 'pcm_s24le', 'pcm_s32le', 'pcm_f32le', 'pcm_u8'},
  ),
  'mka': ContainerSpec(
    'mka',
    video: {},
    audio: {
      AudioCodecChoice.aac,
      AudioCodecChoice.opus,
      AudioCodecChoice.mp3,
      AudioCodecChoice.flac,
      AudioCodecChoice.alac,
      AudioCodecChoice.pcm16,
      AudioCodecChoice.pcm24,
      AudioCodecChoice.ac3,
      AudioCodecChoice.eac3,
      AudioCodecChoice.vorbis,
    },
    audioOnly: true,
  ),
};

ContainerSpec containerFor(String ext) => containers[ext.toLowerCase()] ?? containers['mkv']!;

/// Best audio-only container to stream-copy a codec into (extract audio).
String audioContainerForCodec(String? codec) => switch (codec) {
  'aac' || 'alac' => 'm4a',
  'mp3' => 'mp3',
  'opus' => 'opus',
  'vorbis' => 'ogg',
  'flac' => 'flac',
  'pcm_s16le' || 'pcm_s24le' || 'pcm_s32le' || 'pcm_f32le' || 'pcm_u8' => 'wav',
  _ => 'mka',
};

/// A sensible audio encoder for a container when audio must be re-encoded
/// (normalize, precise trim): keep the source codec family if the container
/// takes it, else the container's first choice.
AudioCodecChoice audioChoiceFor(String ext, {String? sourceCodec}) {
  final c = containerFor(ext);
  final fromSource = switch (sourceCodec) {
    'aac' => AudioCodecChoice.aac,
    'opus' => AudioCodecChoice.opus,
    'mp3' => AudioCodecChoice.mp3,
    'flac' => AudioCodecChoice.flac,
    'alac' => AudioCodecChoice.alac,
    'vorbis' => AudioCodecChoice.vorbis,
    'ac3' => AudioCodecChoice.ac3,
    'eac3' => AudioCodecChoice.eac3,
    'pcm_s16le' => AudioCodecChoice.pcm16,
    'pcm_s24le' => AudioCodecChoice.pcm24,
    _ => null,
  };
  if (fromSource != null && c.audio.contains(fromSource)) return fromSource;
  return c.audio.contains(AudioCodecChoice.aac) ? AudioCodecChoice.aac : c.audio.first;
}

/// Same idea for video (precise trim keeps the family when possible).
VideoCodecChoice videoChoiceFor(String ext, {String? sourceCodec}) {
  final c = containerFor(ext);
  final fromSource = switch (sourceCodec) {
    'h264' => VideoCodecChoice.h264,
    'hevc' => VideoCodecChoice.hevc,
    'av1' => VideoCodecChoice.av1,
    'vp9' => VideoCodecChoice.vp9,
    'prores' => VideoCodecChoice.prores,
    'dnxhd' => VideoCodecChoice.dnxhr,
    'ffv1' => VideoCodecChoice.ffv1,
    _ => null,
  };
  if (fromSource != null && c.video.contains(fromSource)) return fromSource;
  return c.video.contains(VideoCodecChoice.h264) ? VideoCodecChoice.h264 : c.video.first;
}
