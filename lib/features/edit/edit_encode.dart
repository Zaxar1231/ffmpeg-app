import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../convert/convert_params.dart';

/// Output quality of editing tools, mapped onto the chosen encoder's scale.
enum EditQuality {
  /// Visually lossless (CRF ≈ 18 for x264).
  high,

  /// Encoder default (CRF 23 for x264).
  balanced,

  /// Smaller file (CRF ≈ 28 for x264).
  small,
}

/// Output format of editing tools: container + quality.
class EditOutput {
  const EditOutput({this.ext = 'mp4', this.quality = EditQuality.high, this.speed = SpeedPreset.fast});
  final String ext;
  final EditQuality quality;
  final SpeedPreset speed;

  EditOutput copyWith({String? ext, EditQuality? quality, SpeedPreset? speed}) =>
      EditOutput(ext: ext ?? this.ext, quality: quality ?? this.quality, speed: speed ?? this.speed);
}

/// Containers offered by editing tools.
const editContainers = ['mp4', 'mkv', 'mov', 'webm'];

/// Default output container: the source's when it is a common one.
String editExtFor(MediaInfo info) {
  final e = info.path.split('.').last.toLowerCase();
  return editContainers.contains(e) ? e : 'mp4';
}

/// Quality value for [enc] at [q]: ±5 CRF-steps around the default,
/// scaled to the encoder's range and direction.
int qualityFor(VideoEncoderSpec enc, EditQuality q) {
  final step = (enc.qualityMax - enc.qualityMin) / 51 * 5;
  final delta = switch (q) {
    EditQuality.high => -step,
    EditQuality.balanced => 0.0,
    EditQuality.small => step,
  };
  final v = enc.qualityDefault + (enc.higherIsBetter ? -delta : delta);
  return v.round().clamp(enc.qualityMin, enc.qualityMax);
}

/// Encodes [graph] of [info] into [output]: codec family follows the
/// source when the container allows it; audio is copied when the graph
/// passes it through untouched and the container accepts the codec.
ConvertPlan planEdit({
  required MediaInfo info,
  required String output,
  required EditGraph graph,
  required EditOutput out,
  EncodeEnv env = const EncodeEnv(),
  String? workingDirectory,
  bool eightBit = false,
}) {
  final c = containerFor(out.ext);
  final v = info.videoStreams.firstOrNull;
  final a = info.audioStreams.firstOrNull;
  final videoChoice = graph.video == null || v == null
      ? VideoCodecChoice.none
      : videoChoiceFor(out.ext, sourceCodec: v.codecName);
  final passthroughAudio = graph.audio != null && graph.audio!.contains(':');
  final AudioCodecChoice audioChoice;
  if (graph.audio == null || a == null) {
    audioChoice = AudioCodecChoice.none;
  } else if (passthroughAudio && info.audioStreams.every((s) => c.acceptsCopy(s.codecName))) {
    audioChoice = AudioCodecChoice.copy;
  } else {
    audioChoice = audioChoiceFor(out.ext, sourceCodec: a.codecName);
  }
  final enc = videoChoice == VideoCodecChoice.none
      ? null
      : pickVideoEncoder(videoChoice, caps: env.caps, hw: env.hw, allowHardware: env.allowHardware);
  final params = ConvertParams(
    container: out.ext,
    video: videoChoice,
    audio: audioChoice,
    quality: enc == null ? null : qualityFor(enc, out.quality),
    speed: out.speed,
    tenBit: !eightBit && (v?.bitDepth ?? 8) > 8,
    keepSubtitles: false,
  );
  final plan = planConvert(info: info, output: output, p: params, env: env, graph: graph);
  if (workingDirectory == null) return plan;
  return ConvertPlan(
    steps: [
      for (final s in plan.steps)
        JobStep(
          args: s.args,
          tool: s.tool,
          label: s.label,
          weight: s.weight,
          capture: s.capture,
          workingDirectory: workingDirectory,
          totalDuration: s.totalDuration,
          files: s.files,
        ),
    ],
    encoder: plan.encoder,
    issues: plan.issues,
    warnings: plan.warnings,
    videoKbps: plan.videoKbps,
    audioKbps: plan.audioKbps,
    estimatedBytes: plan.estimatedBytes,
  );
}
