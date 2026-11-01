import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';

enum AnimFormat { gif, webp, apng }

enum Dither { sierra2_4a, bayer, floydSteinberg, none }

class GifParams {
  const GifParams({
    this.format = AnimFormat.gif,
    this.start = Duration.zero,
    this.duration,
    this.fps = 15,
    this.width = 480,
    this.dither = Dither.sierra2_4a,
    this.staticBackground = false,
    this.loop = true,
    this.webpQuality = 75,
  });

  final AnimFormat format;
  final Duration start;

  /// null = to the end.
  final Duration? duration;
  final int fps;

  /// null = original width.
  final int? width;
  final Dither dither;

  /// `palettegen=stats_mode=diff`: better colors when only parts move.
  final bool staticBackground;
  final bool loop;
  final int webpQuality;

  String get ext => switch (format) {
    AnimFormat.gif => 'gif',
    AnimFormat.webp => 'webp',
    AnimFormat.apng => 'png',
  };
}

String _ditherName(Dither d) => switch (d) {
  Dither.sierra2_4a => 'sierra2_4a',
  Dither.bayer => 'bayer:bayer_scale=4',
  Dither.floydSteinberg => 'floyd_steinberg',
  Dither.none => 'none',
};

/// GIF: one pass with a generated palette (split → palettegen → paletteuse).
///   `[0:v]fps=15,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse`
/// WebP: libwebp_anim. APNG: apng muxer.
List<JobStep> planGif({required MediaInfo info, required String output, required GifParams g}) {
  final base = ['fps=${g.fps}', if (g.width != null) 'scale=${g.width}:-1:flags=lanczos'].join(',');
  final input = FfmpegInput(info.path, seek: g.start > Duration.zero ? g.start : null, duration: g.duration);
  final total = g.duration ?? (info.duration == null ? null : info.duration! - g.start);
  final FfmpegCommand cmd;
  switch (g.format) {
    case AnimFormat.gif:
      final stats = g.staticBackground ? 'palettegen=stats_mode=diff' : 'palettegen';
      final use = 'paletteuse=dither=${_ditherName(g.dither)}${g.staticBackground ? ':diff_mode=rectangle' : ''}';
      cmd = FfmpegCommand(
        inputs: [input],
        filterComplex: '[0:v]$base,split[a][b];[a]$stats[p];[b][p]$use[out]',
        outputs: [
          FfmpegOutput(output, maps: ['[out]'], options: ['-loop', g.loop ? '0' : '-1']),
        ],
      );
    case AnimFormat.webp:
      cmd = FfmpegCommand(
        inputs: [input],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0:v:0'],
            videoFilters: [base],
            options: [
              '-c:v',
              'libwebp_anim',
              '-lossless',
              '0',
              '-quality',
              '${g.webpQuality}',
              '-loop',
              g.loop ? '0' : '1',
            ],
          ),
        ],
      );
    case AnimFormat.apng:
      cmd = FfmpegCommand(
        inputs: [input],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0:v:0'],
            videoFilters: [base],
            options: ['-c:v', 'apng', '-plays', g.loop ? '0' : '1'],
            format: 'apng',
          ),
        ],
      );
  }
  return [JobStep(args: cmd.toArgs(), totalDuration: total)];
}
