import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';

// ------------------------------------------------------------ extract

/// `copy` keeps the original stream (instant, lossless); others re-encode.
enum ExtractFormat { copy, mp3, aac, opus, flac, wav }

String extractExtension(ExtractFormat f, {String? sourceCodec}) => switch (f) {
  ExtractFormat.copy => audioContainerForCodec(sourceCodec),
  ExtractFormat.mp3 => 'mp3',
  ExtractFormat.aac => 'm4a',
  ExtractFormat.opus => 'opus',
  ExtractFormat.flac => 'flac',
  ExtractFormat.wav => 'wav',
};

/// `ffmpeg -i in -map 0:<stream> -vn -c:a copy|<enc> out.<ext>`
List<JobStep> planExtractAudio({
  required MediaInfo info,
  required String output,
  required int streamIndex,
  required ExtractFormat format,
  int? kbps,
}) {
  final codec = switch (format) {
    ExtractFormat.copy => ['-c:a', 'copy'],
    ExtractFormat.mp3 => audioEncoders[AudioCodecChoice.mp3]!.args(kbps: kbps),
    ExtractFormat.aac => audioEncoders[AudioCodecChoice.aac]!.args(kbps: kbps),
    ExtractFormat.opus => audioEncoders[AudioCodecChoice.opus]!.args(kbps: kbps),
    ExtractFormat.flac => audioEncoders[AudioCodecChoice.flac]!.args(),
    ExtractFormat.wav => audioEncoders[AudioCodecChoice.pcm16]!.args(),
  };
  return [
    JobStep(
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path)],
        outputs: [
          FfmpegOutput(output, maps: ['0:$streamIndex'], noVideo: true, options: codec),
        ],
      ).toArgs(),
    ),
  ];
}

// ------------------------------------------------------------ tracks

enum TrackMode {
  /// Replace all audio with the new file.
  replace,

  /// Keep existing audio and add the new file as another track.
  add,

  /// Remove all audio.
  remove,
}

/// Video is always stream-copied. New audio is copied when the container
/// accepts its codec, otherwise encoded with the container's default.
List<JobStep> planAudioTracks({
  required MediaInfo video,
  MediaInfo? audio,
  required String output,
  required TrackMode mode,
  required String ext,
  bool shortest = true,
  String? language,
}) {
  final c = containerFor(ext);
  if (mode == TrackMode.remove) {
    return [
      JobStep(
        args: FfmpegCommand(
          inputs: [FfmpegInput(video.path)],
          outputs: [
            FfmpegOutput(output, maps: ['0'], noAudio: true, options: ['-c', 'copy', if (!c.subtitles) '-sn', '-dn']),
          ],
        ).toArgs(),
      ),
    ];
  }
  final newAudio = audio!.audioStreams.first;
  final copyOk = c.acceptsCopy(newAudio.codecName) && !c.audioOnly;
  // Index of the new track among output audio streams.
  final newIdx = mode == TrackMode.add ? video.audioStreams.length : 0;
  // Per-stream options (`-c:a:N`, `-b:a:N`) so existing tracks stay copied.
  final enc = audioEncoders[audioChoiceFor(ext, sourceCodec: newAudio.codecName)]!;
  final newCodec = copyOk
      ? ['-c:a:$newIdx', 'copy']
      : [
          '-c:a:$newIdx',
          enc.name,
          if (enc.defaultKbps != null) ...['-b:a:$newIdx', '${enc.defaultKbps}k'],
        ];
  return [
    JobStep(
      args: FfmpegCommand(
        inputs: [FfmpegInput(video.path), FfmpegInput(audio.path)],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0:v?', if (mode == TrackMode.add) '0:a?', '1:a:0', if (c.subtitles) '0:s?'],
            options: [
              '-c',
              'copy',
              ...newCodec,
              if (language != null) ...['-metadata:s:a:$newIdx', 'language=$language'],
              if (shortest) '-shortest',
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

// ------------------------------------------------------------ loudness

class LoudnessTarget {
  const LoudnessTarget(this.id, this.integrated, this.truePeak, this.lra);
  final String id;

  /// Integrated loudness, LUFS.
  final double integrated;

  /// Maximum true peak, dBTP.
  final double truePeak;

  /// Loudness range, LU.
  final double lra;
}

const loudnessTargets = <LoudnessTarget>[
  LoudnessTarget('streaming', -14, -1, 11), // YouTube, Spotify
  LoudnessTarget('podcast', -16, -1.5, 11), // Apple Podcasts
  LoudnessTarget('broadcast', -23, -1, 15), // EBU R128
  LoudnessTarget('apple', -16, -1, 11), // Apple Music
];

String _f(double v) => v.toStringAsFixed(1);

String loudnormMeasureFilter(LoudnessTarget t) =>
    'loudnorm=I=${_f(t.integrated)}:TP=${_f(t.truePeak)}:LRA=${_f(t.lra)}:print_format=json';

/// Second-pass filter with `{{loudnorm.*}}` placeholders filled from pass 1.
String loudnormApplyFilter(LoudnessTarget t) =>
    'loudnorm=I=${_f(t.integrated)}:TP=${_f(t.truePeak)}:LRA=${_f(t.lra)}'
    ':measured_I={{loudnorm.input_i}}:measured_TP={{loudnorm.input_tp}}'
    ':measured_LRA={{loudnorm.input_lra}}:measured_thresh={{loudnorm.input_thresh}}'
    ':offset={{loudnorm.target_offset}}:linear=true:print_format=summary';

/// Two-pass (measure, then apply linearly) or one-pass (dynamic) loudnorm.
/// Video and subtitles are copied; audio is re-encoded in a codec the
/// container accepts, at the source sample rate (loudnorm outputs 192 kHz).
List<JobStep> planNormalize({
  required MediaInfo info,
  required String output,
  required LoudnessTarget target,
  required String ext,
  bool twoPass = true,
  int? kbps,
}) {
  final c = containerFor(ext);
  final a = info.audioStreams.first;
  final choice = audioChoiceFor(ext, sourceCodec: a.codecName);
  final srcKbps = a.bitRate == null ? null : (a.bitRate! ~/ 1000).clamp(96, 512);
  final enc = audioEncoders[choice]!.args(kbps: kbps ?? srcKbps);
  final rate = a.sampleRate ?? 48000;

  final apply = FfmpegCommand(
    inputs: [FfmpegInput(info.path)],
    outputs: [
      FfmpegOutput(
        output,
        maps: [if (!c.audioOnly) '0:v?', '0:a', if (c.subtitles) '0:s?'],
        audioFilters: [
          twoPass ? loudnormApplyFilter(target) : loudnormMeasureFilter(target).replaceAll(':print_format=json', ''),
        ],
        options: [
          if (!c.audioOnly) ...['-c:v', 'copy'],
          if (c.subtitles) ...['-c:s', 'copy'],
          ...enc,
          '-ar',
          '$rate',
        ],
        noVideo: c.audioOnly,
      ),
    ],
  ).toArgs();
  if (!twoPass) return [JobStep(args: apply)];

  final measure = FfmpegCommand(
    logLevel: 'info', // loudnorm prints its JSON at info level
    inputs: [FfmpegInput(info.path)],
    outputs: [
      FfmpegOutput('-', maps: ['0:a:0'], noVideo: true, audioFilters: [loudnormMeasureFilter(target)], format: 'null'),
    ],
  ).toArgs();
  return [
    JobStep(args: measure, label: '1/2', weight: 0.35, capture: StepCapture.loudnorm),
    JobStep(args: apply, label: '2/2', weight: 0.65),
  ];
}
