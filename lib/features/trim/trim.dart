import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../convert/convert_params.dart';

enum TrimMode {
  /// `-c copy`: instant and lossless, but starts at the keyframe before [start].
  fast,

  /// Re-encodes: frame-accurate start and end.
  precise,
}

class TrimParams {
  const TrimParams({required this.start, required this.end, this.mode = TrimMode.fast});
  final Duration start;
  final Duration end;
  final TrimMode mode;
  Duration get length => end - start;
}

/// Fast: `ffmpeg -ss S -i in -t D -map 0 -c copy -avoid_negative_ts make_zero out`
///   Seeking before `-i` with stream copy cuts at the previous keyframe.
/// Precise: `ffmpeg -ss S -i in -t D <encode> out`
///   With transcoding, input seeking is frame-accurate.
List<JobStep> planTrim({
  required MediaInfo info,
  required String output,
  required TrimParams t,
  required String ext,
  EncodeEnv env = const EncodeEnv(),
}) {
  final c = containerFor(ext);
  final input = FfmpegInput(info.path, seek: t.start > Duration.zero ? t.start : null);
  if (t.mode == TrimMode.fast) {
    return [
      JobStep(
        totalDuration: t.length,
        args: FfmpegCommand(
          inputs: [input],
          outputs: [
            FfmpegOutput(
              output,
              maps: ['0'],
              duration: t.length,
              options: [
                '-c',
                'copy',
                '-avoid_negative_ts',
                'make_zero',
                // Data/attachment streams often cannot be muxed into a new file.
                '-dn',
                if (!c.subtitles) '-sn',
              ],
            ),
          ],
        ).toArgs(),
      ),
    ];
  }
  // Precise: re-encode in the source codec family at high quality.
  final v = info.videoStreams.firstOrNull;
  final a = info.audioStreams.firstOrNull;
  final params = ConvertParams(
    container: ext,
    video: v == null ? VideoCodecChoice.none : videoChoiceFor(ext, sourceCodec: v.codecName),
    audio: a == null ? AudioCodecChoice.none : audioChoiceFor(ext, sourceCodec: a.codecName),
    quality: null,
    speed: SpeedPreset.fast,
    tenBit: (v?.bitDepth ?? 8) > 8,
    useHardware: true,
  );
  final plan = planConvert(info: info, output: output, p: params, env: env);
  // Inject the seek/duration into the single convert step.
  final args = List<String>.of(plan.steps.single.args);
  final iIdx = args.indexOf('-i');
  if (t.start > Duration.zero) args.insertAll(iIdx, ['-ss', formatTimestamp(t.start)]);
  args.insertAll(args.length - 1, ['-t', formatTimestamp(t.length)]);
  return [JobStep(args: args, totalDuration: t.length)];
}
