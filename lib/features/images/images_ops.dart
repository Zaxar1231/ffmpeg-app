/// Images & animation (stage 4): frame grabs, contact sheets, slideshows,
/// audio → video with a cover, audio visualizers, image conversion.
/// Filters and options checked on ffmpeg 6.1 and 9.0.
library;

import 'dart:math' as math;

import 'package:path/path.dart' as p;

import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../convert/convert_params.dart';
import '../edit/graphs.dart' show displaySize, even, fnum, secs, fadeFilters, xfadeTransitions;

// ================================================================ formats

enum ImageFormat { png, jpg, webp, avif, jxl }

String imageExt(ImageFormat f) => f.name;

/// Encoder options for a still image at [quality] (0–100, higher = better).
List<String> imageCodecArgs(ImageFormat f, int quality) => switch (f) {
  ImageFormat.png => ['-c:v', 'png'],
  // mjpeg q:v: 2 (best) … 31.
  ImageFormat.jpg => [
    '-c:v',
    'mjpeg',
    '-q:v',
    '${(31 - quality * 29 / 100).round().clamp(2, 31)}',
    '-pix_fmt',
    'yuvj444p',
  ],
  ImageFormat.webp => [
    '-c:v',
    'libwebp',
    '-quality',
    '$quality',
    if (quality >= 100) ...['-lossless', '1'],
  ],
  // libaom crf 0 (lossless) … 63.
  ImageFormat.avif => [
    '-c:v',
    'libaom-av1',
    '-still-picture',
    '1',
    '-crf',
    '${(63 - quality * 63 / 100).round()}',
    '-cpu-used',
    '6',
  ],
  // Butteraugli distance: 0 lossless … ~6 low quality.
  ImageFormat.jxl => ['-c:v', 'libjxl', '-distance', fnum(quality >= 100 ? 0 : (100 - quality) / 15, 2)],
};

/// Encoder each format needs (to mark it unavailable in a build).
String imageEncoder(ImageFormat f) => switch (f) {
  ImageFormat.png => 'png',
  ImageFormat.jpg => 'mjpeg',
  ImageFormat.webp => 'libwebp',
  ImageFormat.avif => 'libaom-av1',
  ImageFormat.jxl => 'libjxl',
};

/// `name_%04d.ext` next to [output] (`%` in the name escaped).
String numberedPattern(String output) {
  final base = p.basenameWithoutExtension(output).replaceAll('%', '%%');
  return p.join(p.dirname(output), '${base}_%04d${p.extension(output)}');
}

String? _scale(int? width) => width == null ? null : 'scale=$width:-2:flags=lanczos';

// ================================================================= frames

enum FramesMode { single, every, count, scenes, best }

class FramesParams {
  const FramesParams({
    this.mode = FramesMode.single,
    this.at = Duration.zero,
    this.every = const Duration(seconds: 10),
    this.count = 10,
    this.sceneThreshold = 0.3,
    this.format = ImageFormat.jpg,
    this.quality = 90,
    this.width,
  });
  final FramesMode mode;
  final Duration at;
  final Duration every;
  final int count;

  /// select scene score 0–1.
  final double sceneThreshold;
  final ImageFormat format;
  final int quality;
  final int? width;

  bool get single => mode == FramesMode.single || mode == FramesMode.best;
}

/// Frame grabs. Single frame: input seek (fast) + `-frames:v 1`.
List<JobStep> planFrames({required MediaInfo info, required String output, required FramesParams f}) {
  final d = info.duration ?? Duration.zero;
  final vf = <String>[
    ...switch (f.mode) {
      FramesMode.single => <String>[],
      FramesMode.best => ['thumbnail=n=100'],
      FramesMode.every => ['fps=1/${secs(f.every)}'],
      FramesMode.count => ['fps=${fnum(f.count / math.max(0.001, d.inMicroseconds / 1e6), 6)}'],
      FramesMode.scenes => ["select='gt(scene,${fnum(f.sceneThreshold, 2)})'"],
    },
    ?_scale(f.width),
  ];
  final out = f.single ? output : numberedPattern(output);
  return [
    JobStep(
      totalDuration: f.mode == FramesMode.single ? null : d,
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path, seek: f.mode == FramesMode.single && f.at > Duration.zero ? f.at : null)],
        outputs: [
          FfmpegOutput(
            out,
            maps: ['0:v:0'],
            videoFilters: vf,
            options: [
              if (f.single) ...['-frames:v', '1', '-update', '1'],
              if (f.mode == FramesMode.scenes) ...['-fps_mode', 'vfr'],
              if (f.mode == FramesMode.count) ...['-frames:v', '${f.count}'],
              ...imageCodecArgs(f.format, f.quality),
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

// ========================================================== contact sheet

class SheetParams {
  const SheetParams({
    this.columns = 4,
    this.rows = 4,
    this.thumbWidth = 320,
    this.timestamps = true,
    this.padding = 4,
    this.background = 'black',
    this.format = ImageFormat.jpg,
    this.quality = 90,
  });
  final int columns;
  final int rows;
  final int thumbWidth;
  final bool timestamps;
  final int padding;
  final String background;
  final ImageFormat format;
  final int quality;
  int get count => columns * rows;
}

/// N frames evenly spread over the file in one grid image:
///   `fps=N/D,scale=W:-2,drawtext=%{pts:hms},tile=CxR:padding:margin:color`
List<JobStep> planContactSheet({
  required MediaInfo info,
  required String output,
  required SheetParams s,
  String? fontFile,
}) {
  final d = math.max(0.001, (info.duration ?? Duration.zero).inMicroseconds / 1e6);
  // Start half a step in, so the first and last tiles are not black.
  final step = d / s.count;
  final size = math.max(10, (s.thumbWidth * 0.07).round());
  final font = fontFile == null ? 'font=Sans' : 'fontfile=${escapeFilterValue(fontFile)}';
  final vf = [
    'fps=${fnum(1 / step, 6)}',
    'scale=${s.thumbWidth}:-2:flags=lanczos',
    if (s.timestamps)
      // Input seek resets timestamps; the third pts argument adds it back.
      "drawtext=$font:text='%{pts\\:hms\\:${fnum(step / 2, 3)}}':fontsize=$size:fontcolor=white:box=1:boxcolor=black@0.6:"
          'boxborderw=${(size * 0.25).round()}:x=w-tw-${size ~/ 2}:y=h-th-${size ~/ 2}',
    'tile=${s.columns}x${s.rows}:padding=${s.padding}:margin=${s.padding * 2}:color=${s.background}',
  ];
  return [
    JobStep(
      totalDuration: info.duration,
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path, seek: Duration(microseconds: (step / 2 * 1e6).round()))],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0:v:0'],
            videoFilters: vf,
            options: ['-frames:v', '1', '-update', '1', ...imageCodecArgs(s.format, s.quality)],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

// ============================================================== slideshow

class SlideshowParams {
  const SlideshowParams({
    this.width = 1920,
    this.height = 1080,
    this.fps = 30,
    this.perImage = const Duration(seconds: 4),
    this.transition = 'fade',
    this.transitionLength = const Duration(milliseconds: 800),
    this.kenBurns = false,
    this.fit = true,
    this.audio,
    this.audioDuration,
    this.fitToAudio = false,
  });
  final int width;
  final int height;
  final int fps;
  final Duration perImage;

  /// xfade transition name, or null for hard cuts.
  final String? transition;
  final Duration transitionLength;

  /// Slow zoom on every image (zoompan).
  final bool kenBurns;

  /// true = whole image with bars, false = fill the frame (crop).
  final bool fit;
  final String? audio;
  final Duration? audioDuration;

  /// Stretch the per-image time so the slideshow lasts as long as the audio.
  final bool fitToAudio;
}

/// Effective time per image (when fitted to the audio length).
Duration slideDuration(int images, SlideshowParams s) {
  if (!s.fitToAudio || s.audioDuration == null || images == 0) return s.perImage;
  final t = s.transition == null ? Duration.zero : s.transitionLength;
  // total = n·d − (n−1)·t  →  d = (total + (n−1)·t) / n
  return (s.audioDuration! + t * (images - 1)) ~/ images;
}

Duration slideshowLength(int images, SlideshowParams s) {
  final d = slideDuration(images, s);
  final t = s.transition == null ? Duration.zero : s.transitionLength;
  return d * images - t * math.max(0, images - 1);
}

/// Images → video: every image looped for its time, fitted to W×H,
/// optional Ken Burns zoom, xfade between, optional audio track.
EditGraph slideshowGraph(List<String> images, SlideshowParams s) {
  final w = even(s.width), h = even(s.height);
  final d = slideDuration(images.length, s);
  final t = s.transition == null ? Duration.zero : s.transitionLength;
  final frames = (d.inMicroseconds / 1e6 * s.fps).round();
  final parts = <String>[];
  for (var i = 0; i < images.length; i++) {
    final fit = s.fit
        ? 'scale=$w:$h:force_original_aspect_ratio=decrease,pad=$w:$h:(ow-iw)/2:(oh-ih)/2'
        : 'scale=$w:$h:force_original_aspect_ratio=increase,crop=$w:$h';
    final zoom = s.kenBurns
        // Upscale first so the zoom does not jitter, then zoom 1.0 → 1.15.
        ? ',scale=${w * 2}:${h * 2},zoompan=z=\'min(1+0.15*on/$frames\\,1.15)\':d=$frames:'
              "x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=${w}x$h:fps=${s.fps}"
        : '';
    parts.add('[$i:v]$fit$zoom,setsar=1,fps=${s.fps},format=yuv420p,trim=duration=${secs(d)},setpts=PTS-STARTPTS[s$i]');
  }
  var cur = 's0';
  if (images.length == 1) {
    parts.add('[s0]null[v]');
  } else if (s.transition == null) {
    parts.add('${[for (var i = 0; i < images.length; i++) '[s$i]'].join()}concat=n=${images.length}:v=1:a=0[v]');
  } else {
    for (var i = 1; i < images.length; i++) {
      final offset = (d - t) * i;
      final out = i == images.length - 1 ? 'v' : 'x$i';
      parts.add('[$cur][s$i]xfade=transition=${s.transition}:duration=${secs(t)}:offset=${secs(offset)}[$out]');
      cur = out;
    }
  }
  final total = slideshowLength(images.length, s);
  String? audio;
  if (s.audio != null) {
    final fade = fadeFilters(total, Duration.zero, const Duration(seconds: 2), audio: true);
    parts.add('[${images.length}:a:0]atrim=duration=${secs(total)},${fade.join(',')}[a]');
    audio = 'a';
  }
  return EditGraph(
    // Images are looped long enough; `trim` cuts each to its time.
    mainInput: FfmpegInput(images.first, options: ['-loop', '1', '-t', secs(d + const Duration(seconds: 1))]),
    inputs: [
      for (final img in images.skip(1))
        FfmpegInput(img, options: ['-loop', '1', '-t', secs(d + const Duration(seconds: 1))]),
      if (s.audio != null) FfmpegInput(s.audio!),
    ],
    complex: parts.join(';'),
    video: 'v',
    audio: audio,
    duration: total,
  );
}

/// xfade names usable in slideshows (same list as video transitions).
const slideTransitions = xfadeTransitions;

// ========================================================= audio → video

enum CoverSource { embedded, file, color }

class AudioVideoParams {
  const AudioVideoParams({
    this.cover = CoverSource.embedded,
    this.image,
    this.color = '0x101418',
    this.width = 1920,
    this.height = 1080,
    this.blurBackground = true,
    this.waveform = false,
    this.waveColor = '0xFFFFFF',
  });
  final CoverSource cover;
  final String? image;
  final String color;
  final int width;
  final int height;

  /// Cover centered over its own blurred, zoomed copy (instead of bars).
  final bool blurBackground;

  /// Animated waveform at the bottom.
  final bool waveform;
  final String waveColor;
}

/// Audio + still picture → video (YouTube-style). The picture is looped at
/// a low frame rate; with a waveform the video runs at 25 fps.
EditGraph audioVideoGraph(MediaInfo audio, AudioVideoParams a) {
  final w = even(a.width), h = even(a.height);
  final fps = a.waveform ? 25 : 2;
  final parts = <String>[];
  final inputs = <FfmpegInput>[];
  String picture;
  // Embedded cover art (attached picture), else a real video stream.
  final coverStream = audio.coverArt ?? audio.videoStreams.firstOrNull;
  if (a.cover == CoverSource.color || (a.cover == CoverSource.embedded && coverStream == null)) {
    parts.add('color=c=${a.color}:s=${w}x$h:r=$fps[bg]');
    picture = 'bg';
  } else {
    final src = a.cover == CoverSource.file ? '1:v:0' : '0:${coverStream!.index}';
    if (a.cover == CoverSource.file) inputs.add(FfmpegInput(a.image!, options: const ['-loop', '1']));
    final base = a.cover == CoverSource.embedded ? ',loop=loop=-1:size=1:start=0' : '';
    if (a.blurBackground) {
      parts
        ..add('[$src]setsar=1$base,fps=$fps,split[c1][c2]')
        ..add(
          '[c1]scale=$w:$h:force_original_aspect_ratio=increase,crop=$w:$h,boxblur=luma_radius=min(h\\,w)/20:luma_power=2[bg]',
        )
        ..add('[c2]scale=$w:$h:force_original_aspect_ratio=decrease[fg]')
        ..add('[bg][fg]overlay=(W-w)/2:(H-h)/2[pic]');
    } else {
      parts.add(
        '[$src]setsar=1$base,fps=$fps,scale=$w:$h:force_original_aspect_ratio=decrease,'
        'pad=$w:$h:(ow-iw)/2:(oh-ih)/2:color=${a.color}[pic]',
      );
    }
    picture = 'pic';
  }
  // The picture is endless (looped); cut it to the audio length.
  final trim = audio.duration == null ? '' : ',trim=duration=${secs(audio.duration!)}';
  if (a.waveform) {
    parts
      ..add('[0:a:0]asplit[aw][ao]')
      ..add('[aw]showwaves=s=${w}x${h ~/ 4}:mode=cline:rate=$fps:colors=${a.waveColor},format=rgba[wave]')
      ..add('[$picture][wave]overlay=0:H-h-${h ~/ 20}:shortest=1,format=yuv420p$trim[v]');
  } else {
    parts.add('[$picture]format=yuv420p$trim[v]');
  }
  return EditGraph(
    inputs: inputs,
    complex: parts.join(';'),
    video: 'v',
    audio: a.waveform ? 'ao' : '0:a:0',
    duration: audio.duration,
  );
}

// ============================================================= visualizer

enum VisualKind { waves, spectrum, vectorscope, cqt }

class VisualParams {
  const VisualParams({
    this.kind = VisualKind.waves,
    this.width = 1280,
    this.height = 720,
    this.fps = 30,
    this.color = '0x4FC3F7',
  });
  final VisualKind kind;
  final int width;
  final int height;
  final int fps;
  final String color;
}

EditGraph visualizerGraph(MediaInfo audio, VisualParams v) {
  final w = even(v.width), h = even(v.height);
  final s = '${w}x$h';
  final f = switch (v.kind) {
    VisualKind.waves => 'showwaves=s=$s:mode=cline:rate=${v.fps}:colors=${v.color}',
    VisualKind.spectrum => 'showspectrum=s=$s:slide=scroll:mode=combined:color=intensity:scale=log:fps=${v.fps}',
    VisualKind.vectorscope => 'avectorscope=s=$s:rate=${v.fps}:zoom=1.5:draw=line',
    // showcqt sizes must fit its layout; 1280x720 and 1920x1080 work.
    VisualKind.cqt => 'showcqt=s=$s:fps=${v.fps}',
  };
  return EditGraph(
    complex: '[0:a:0]asplit[a1][a]; [a1]$f,format=yuv420p[v]'.replaceAll('; ', ';'),
    video: 'v',
    audio: 'a',
    duration: audio.duration,
  );
}

// ========================================================= image convert

class ImageConvertParams {
  const ImageConvertParams({
    this.format = ImageFormat.webp,
    this.quality = 85,
    this.maxSide,
    this.stripMetadata = true,
  });
  final ImageFormat format;
  final int quality;

  /// Longest side limit (keeps aspect, never upscales).
  final int? maxSide;
  final bool stripMetadata;
}

List<JobStep> planImageConvert({required MediaInfo info, required String output, required ImageConvertParams c}) {
  final (w, h) = displaySize(info);
  final limit = c.maxSide;
  final scale = limit != null && math.max(w, h) > limit
      ? (w >= h ? 'scale=$limit:-2:flags=lanczos' : 'scale=-2:$limit:flags=lanczos')
      : null;
  return [
    JobStep(
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path)],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0:v:0'],
            videoFilters: [?scale],
            options: [
              '-frames:v',
              '1',
              '-update',
              '1',
              if (c.stripMetadata) ...['-map_metadata', '-1'],
              ...imageCodecArgs(c.format, c.quality),
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}
