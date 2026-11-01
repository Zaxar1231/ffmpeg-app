/// Filter graphs of the video editing tools (stage 3).
///
/// Every builder is pure: it takes the probed source(s) and the tool's
/// parameters and returns an [EditGraph] (or job steps for stream-copy
/// paths). Every filter and option used here was checked with
/// `ffmpeg -h filter=<name>` on ffmpeg 6.1 and 9.0.
library;

import 'dart:math' as math;

import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../convert/convert_params.dart';

/// Seconds with millisecond precision, as filters expect (`12.345`).
String secs(Duration d) {
  final v = d.inMicroseconds / 1e6;
  final s = v.toStringAsFixed(3);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

String fnum(double v, [int digits = 3]) {
  final s = v.toStringAsFixed(digits);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

int even(num v) => math.max(2, (v / 2).round() * 2);

double fpsOf(MediaInfo info) {
  final v = info.videoStreams.firstOrNull;
  return v?.avgFrameRate ?? v?.frameRate ?? 30;
}

/// Display size after rotation metadata (`rotate`/display matrix).
(int, int) displaySize(MediaInfo info) {
  final v = info.videoStreams.firstOrNull;
  if (v == null) return (0, 0);
  final w = v.width ?? 0, h = v.height ?? 0;
  final r = (v.rotation ?? 0).abs() % 180;
  return r == 90 ? (h, w) : (w, h);
}

// ===================================================================== cut

/// Keeps [keep] ranges of the source and joins them (frame-accurate).
///   `[0:v]trim=start=S:end=E,setpts=PTS-STARTPTS[v0];[0:a]atrim=…[a0];…;
///    [v0][a0][v1][a1]concat=n=2:v=1:a=1[v][a]`
EditGraph cutGraph(MediaInfo info, List<(Duration, Duration)> keep) {
  final hasV = info.videoStreams.isNotEmpty;
  final hasA = info.audioStreams.isNotEmpty;
  final parts = <String>[];
  final pads = StringBuffer();
  for (var i = 0; i < keep.length; i++) {
    final (s, e) = keep[i];
    if (hasV) parts.add('[0:v:0]trim=start=${secs(s)}:end=${secs(e)},setpts=PTS-STARTPTS[v$i]');
    if (hasA) parts.add('[0:a:0]atrim=start=${secs(s)}:end=${secs(e)},asetpts=PTS-STARTPTS[a$i]');
    if (hasV) pads.write('[v$i]');
    if (hasA) pads.write('[a$i]');
  }
  final outs = '${hasV ? '[v]' : ''}${hasA ? '[a]' : ''}';
  parts.add('${pads}concat=n=${keep.length}:v=${hasV ? 1 : 0}:a=${hasA ? 1 : 0}$outs');
  final total = keep.fold<Duration>(Duration.zero, (t, r) => t + (r.$2 - r.$1));
  return EditGraph(complex: parts.join(';'), video: hasV ? 'v' : null, audio: hasA ? 'a' : null, duration: total);
}

/// Inverts "remove these ranges" into "keep these ranges".
List<(Duration, Duration)> invertRanges(List<(Duration, Duration)> remove, Duration total) {
  final sorted = [...remove]..sort((a, b) => a.$1.compareTo(b.$1));
  final keep = <(Duration, Duration)>[];
  var at = Duration.zero;
  for (final (s, e) in sorted) {
    if (s > at) keep.add((at, s));
    if (e > at) at = e;
  }
  if (at < total) keep.add((at, total));
  return keep.where((r) => r.$2 - r.$1 >= const Duration(milliseconds: 40)).toList();
}

/// Concat demuxer script (`ffconcat`): stream copy of whole files or
/// [inpoint, outpoint] ranges. Paths are absolute, so `-safe 0` is needed.
String ffconcatScript(List<({String path, Duration? inpoint, Duration? outpoint})> items) {
  final b = StringBuffer('ffconcat version 1.0\n');
  for (final it in items) {
    b.writeln("file '${it.path.replaceAll("'", r"'\''")}'");
    if (it.inpoint != null) b.writeln('inpoint ${secs(it.inpoint!)}');
    if (it.outpoint != null) b.writeln('outpoint ${secs(it.outpoint!)}');
  }
  return b.toString();
}

FfmpegInput ffconcatInput(String listPath) => FfmpegInput(listPath, format: 'concat', options: const ['-safe', '0']);

// ================================================================== concat

/// Common frame for joining clips of different size/fps.
class JoinFrame {
  const JoinFrame({required this.width, required this.height, required this.fps, this.sampleRate = 48000});
  final int width;
  final int height;
  final double fps;
  final int sampleRate;

  factory JoinFrame.of(MediaInfo first) {
    final (w, h) = displaySize(first);
    return JoinFrame(width: even(w == 0 ? 1280 : w), height: even(h == 0 ? 720 : h), fps: fpsOf(first));
  }
}

/// Per-clip normalization to [f] (letterboxed, constant fps, stereo 48 kHz).
/// Clips without audio get generated silence so `concat`/`xfade` line up.
List<String> normalizeClips(List<MediaInfo> clips, JoinFrame f, {required bool audio}) {
  final parts = <String>[];
  for (var i = 0; i < clips.length; i++) {
    parts.add(
      '[$i:v:0]scale=${f.width}:${f.height}:force_original_aspect_ratio=decrease,'
      'pad=${f.width}:${f.height}:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=${fnum(f.fps)},format=yuv420p[nv$i]',
    );
    if (!audio) continue;
    if (clips[i].audioStreams.isNotEmpty) {
      parts.add('[$i:a:0]aresample=${f.sampleRate},aformat=sample_fmts=fltp:channel_layouts=stereo[na$i]');
    } else {
      final d = clips[i].duration ?? Duration.zero;
      parts.add('anullsrc=r=${f.sampleRate}:cl=stereo,atrim=duration=${secs(d)}[na$i]');
    }
  }
  return parts;
}

/// Re-encoding join of clips (any formats/sizes).
EditGraph concatGraph(List<MediaInfo> clips, JoinFrame f) {
  final audio = clips.any((c) => c.audioStreams.isNotEmpty);
  final parts = normalizeClips(clips, f, audio: audio);
  final pads = [for (var i = 0; i < clips.length; i++) '[nv$i]${audio ? '[na$i]' : ''}'].join();
  parts.add('${pads}concat=n=${clips.length}:v=1:a=${audio ? 1 : 0}[v]${audio ? '[a]' : ''}');
  return EditGraph(
    inputs: [for (final c in clips.skip(1)) FfmpegInput(c.path)],
    complex: parts.join(';'),
    video: 'v',
    audio: audio ? 'a' : null,
    duration: clips.fold<Duration>(Duration.zero, (t, c) => t + (c.duration ?? Duration.zero)),
  );
}

/// Why stream-copy join may fail; empty = compatible.
List<String> concatMismatches(List<MediaInfo> clips) {
  final out = <String>{};
  final a = clips.first;
  for (final b in clips.skip(1)) {
    final va = a.videoStreams.firstOrNull, vb = b.videoStreams.firstOrNull;
    if ((va == null) != (vb == null)) out.add('video');
    if (va != null && vb != null) {
      if (va.codecName != vb.codecName) out.add('codec');
      if (va.width != vb.width || va.height != vb.height) out.add('size');
      if (va.pixFmt != vb.pixFmt) out.add('pixfmt');
    }
    final aa = a.audioStreams.firstOrNull, ab = b.audioStreams.firstOrNull;
    if ((aa == null) != (ab == null)) out.add('audio');
    if (aa != null && ab != null && (aa.codecName != ab.codecName || aa.sampleRate != ab.sampleRate)) {
      out.add('audioCodec');
    }
  }
  return out.toList();
}

// ============================================================= transitions

/// xfade transitions available in ffmpeg ≥ 5 (a readable subset).
const xfadeTransitions = [
  'fade', 'dissolve', 'fadeblack', 'fadewhite', 'wipeleft', 'wiperight', 'wipeup', 'wipedown', //
  'slideleft', 'slideright', 'slideup', 'slidedown', 'smoothleft', 'smoothright', 'circleopen',
  'circleclose', 'circlecrop', 'rectcrop', 'radial', 'pixelize', 'distance', 'hblur', 'zoomin',
  'diagtl', 'diagbr', 'squeezeh', 'squeezev', 'horzopen', 'vertopen',
];

/// Joins clips with xfade/acrossfade of [d] between each pair.
///   offset_k = (sum of durations of clips 0..k) − (k+1)·d
EditGraph transitionGraph(
  List<MediaInfo> clips,
  JoinFrame f, {
  required String transition,
  required Duration d,
  Duration fadeIn = Duration.zero,
  Duration fadeOut = Duration.zero,
}) {
  final audio = clips.any((c) => c.audioStreams.isNotEmpty);
  final parts = normalizeClips(clips, f, audio: audio);
  var v = 'nv0', a = 'na0';
  var acc = clips.first.duration ?? Duration.zero;
  for (var i = 1; i < clips.length; i++) {
    final offset = acc - d;
    parts.add('[$v][nv$i]xfade=transition=$transition:duration=${secs(d)}:offset=${secs(offset)}[xv$i]');
    v = 'xv$i';
    if (audio) {
      parts.add('[$a][na$i]acrossfade=d=${secs(d)}[xa$i]');
      a = 'xa$i';
    }
    acc = offset + (clips[i].duration ?? Duration.zero);
  }
  final total = acc;
  final vf = fadeFilters(total, fadeIn, fadeOut, audio: false);
  final af = fadeFilters(total, fadeIn, fadeOut, audio: true);
  parts.add('[$v]${vf.isEmpty ? 'null' : vf.join(',')}[v]');
  if (audio) parts.add('[$a]${af.isEmpty ? 'anull' : af.join(',')}[a]');
  return EditGraph(
    inputs: [for (final c in clips.skip(1)) FfmpegInput(c.path)],
    complex: parts.join(';'),
    video: 'v',
    audio: audio ? 'a' : null,
    duration: total,
  );
}

/// `fade=t=in:st=0:d=1,fade=t=out:st=T-1:d=1` (or `afade`).
List<String> fadeFilters(Duration total, Duration fadeIn, Duration fadeOut, {required bool audio}) {
  final name = audio ? 'afade' : 'fade';
  return [
    if (fadeIn > Duration.zero) '$name=t=in:st=0:d=${secs(fadeIn)}',
    if (fadeOut > Duration.zero) '$name=t=out:st=${secs(total - fadeOut)}:d=${secs(fadeOut)}',
  ];
}

/// Fade in/out of a single file.
EditGraph fadeGraph(MediaInfo info, Duration fadeIn, Duration fadeOut) {
  final total = info.duration ?? Duration.zero;
  final hasV = info.videoStreams.isNotEmpty, hasA = info.audioStreams.isNotEmpty;
  final vf = fadeFilters(total, fadeIn, fadeOut, audio: false);
  final af = fadeFilters(total, fadeIn, fadeOut, audio: true);
  return EditGraph(
    complex: [
      if (hasV) '[0:v:0]${vf.isEmpty ? 'null' : vf.join(',')}[v]',
      if (hasA) '[0:a:0]${af.isEmpty ? 'anull' : af.join(',')}[a]',
    ].join(';'),
    video: hasV ? 'v' : null,
    audio: hasA ? 'a' : null,
  );
}

// ============================================================ crop / scale

enum FitMode {
  /// Whole picture, bars around (letterbox/pillarbox).
  fit,

  /// Fill the frame, cutting the edges.
  fill,

  /// Distort to the frame.
  stretch,

  /// Whole picture over a blurred, zoomed copy of itself (vertical videos).
  blur,
}

class CropRect {
  const CropRect(this.x, this.y, this.w, this.h);
  final int x, y, w, h;

  @override
  bool operator ==(Object other) => other is CropRect && other.x == x && other.y == y && other.w == w && other.h == h;
  @override
  int get hashCode => Object.hash(x, y, w, h);
  @override
  String toString() => '$w:$h:$x:$y';

  /// Even position and size: 4:2:0 video cannot be cut at odd pixels.
  CropRect get even =>
      CropRect(x ~/ 2 * 2, y ~/ 2 * 2, w ~/ 2 * 2 < 2 ? 2 : w ~/ 2 * 2, h ~/ 2 * 2 < 2 ? 2 : h ~/ 2 * 2);
}

/// Parses the last `crop=w:h:x:y` that cropdetect printed.
CropRect? parseCropdetect(Iterable<String> log) {
  final re = RegExp(r'crop=(\d+):(\d+):(\d+):(\d+)');
  CropRect? last;
  for (final l in log) {
    final m = re.allMatches(l).lastOrNull;
    if (m != null) {
      last = CropRect(int.parse(m[3]!), int.parse(m[4]!), int.parse(m[1]!), int.parse(m[2]!));
    }
  }
  return last;
}

class CropScaleParams {
  const CropScaleParams({
    this.crop,
    this.rotate = 0,
    this.angle = 0,
    this.hflip = false,
    this.vflip = false,
    this.aspect,
    this.height,
    this.width,
    this.fit = FitMode.fit,
    this.padColor = 'black',
  });

  final CropRect? crop;

  /// Quarter turns clockwise: 0, 90, 180, 270.
  final int rotate;

  /// Free rotation in degrees (positive = clockwise), keeps the whole frame.
  final double angle;
  final bool hflip;
  final bool vflip;

  /// Target frame aspect (w/h); null = keep the picture's own.
  final double? aspect;

  /// Target height; null = keep (or derive from [width]).
  final int? height;

  /// Explicit target width (custom size).
  final int? width;
  final FitMode fit;
  final String padColor;

  bool get isIdentity =>
      crop == null &&
      rotate == 0 &&
      angle == 0 &&
      !hflip &&
      !vflip &&
      aspect == null &&
      height == null &&
      width == null;
}

/// Size of the picture after crop and rotation (before fitting).
(int, int) pictureSize(MediaInfo info, CropScaleParams p) {
  var (w, h) = displaySize(info);
  if (p.crop != null) (w, h) = (p.crop!.even.w, p.crop!.even.h);
  if (p.rotate % 180 == 90) (w, h) = (h, w);
  if (p.angle != 0) {
    final a = p.angle.abs() * math.pi / 180;
    final rw = (w * math.cos(a)).abs() + (h * math.sin(a)).abs();
    final rh = (w * math.sin(a)).abs() + (h * math.cos(a)).abs();
    (w, h) = (rw.ceil(), rh.ceil());
  }
  return (w, h);
}

/// Output frame size for [p].
(int, int) frameSize(MediaInfo info, CropScaleParams p) {
  final (pw, ph) = pictureSize(info, p);
  if (p.width != null && p.height != null) return (even(p.width!), even(p.height!));
  final aspect = p.aspect ?? (ph == 0 ? 16 / 9 : pw / ph);
  if (p.aspect == null) {
    final h = p.height ?? ph;
    return (even(h * aspect), even(h));
  }
  // Fit the new aspect around the picture without upscaling by default:
  // the frame keeps the picture's larger dimension.
  final h = p.height ?? (pw / ph > aspect ? (pw / aspect) : ph).round();
  return (even(h * aspect), even(h));
}

/// Video chain for crop/rotate/flip/scale/pad.
EditGraph cropScaleGraph(MediaInfo info, CropScaleParams p) {
  final pre = <String>[
    if (p.crop != null) 'crop=${p.crop!.even}',
    if (p.rotate == 90) 'transpose=clock',
    if (p.rotate == 180) ...['hflip', 'vflip'],
    if (p.rotate == 270) 'transpose=cclock',
    if (p.hflip) 'hflip',
    if (p.vflip) 'vflip',
    if (p.angle != 0)
      'rotate=${fnum(p.angle * math.pi / 180, 6)}:ow=rotw(${fnum(p.angle * math.pi / 180, 6)}):'
          'oh=roth(${fnum(p.angle * math.pi / 180, 6)}):c=${p.padColor}',
  ];
  final scaled = p.aspect != null || p.height != null || p.width != null;
  final (w, h) = frameSize(info, p);
  final chain = pre.isEmpty ? 'null' : pre.join(',');
  final String video;
  if (!scaled) {
    video = '[0:v:0]$chain,setsar=1[v]';
  } else {
    video = switch (p.fit) {
      FitMode.stretch => '[0:v:0]$chain,scale=$w:$h,setsar=1[v]',
      FitMode.fill => '[0:v:0]$chain,scale=$w:$h:force_original_aspect_ratio=increase,crop=$w:$h,setsar=1[v]',
      FitMode.fit =>
        '[0:v:0]$chain,scale=$w:$h:force_original_aspect_ratio=decrease,'
            'pad=$w:$h:(ow-iw)/2:(oh-ih)/2:color=${p.padColor},setsar=1[v]',
      FitMode.blur =>
        '[0:v:0]$chain,split[fg0][bg0];'
            '[bg0]scale=$w:$h:force_original_aspect_ratio=increase,crop=$w:$h,boxblur=luma_radius=min(h\\,w)/20:luma_power=2[bg];'
            '[fg0]scale=$w:$h:force_original_aspect_ratio=decrease[fg];'
            '[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1[v]',
    };
  }
  return EditGraph(complex: video, video: 'v', audio: info.audioStreams.isEmpty ? null : '0:a');
}

// =================================================================== speed

/// atempo accepts 0.5…100 per instance; slower factors are chained.
List<String> atempoChain(double f) {
  final out = <String>[];
  var r = f;
  while (r < 0.5) {
    out.add('atempo=0.5');
    r /= 0.5;
  }
  while (r > 100) {
    out.add('atempo=100');
    r /= 100;
  }
  if ((r - 1).abs() > 1e-9 || out.isEmpty) out.add('atempo=${fnum(r, 6)}');
  return out;
}

enum SpeedAudio { keepPitch, changePitch, mute }

class SpeedParams {
  const SpeedParams({
    this.factor = 1,
    this.audio = SpeedAudio.keepPitch,
    this.reverse = false,
    this.fps,
    this.interpolate = false,
  });

  /// >1 faster, <1 slower.
  final double factor;
  final SpeedAudio audio;
  final bool reverse;

  /// Output frame rate (null = keep).
  final double? fps;

  /// Motion-interpolated frames (minterpolate, slow) instead of dropping/duplicating.
  final bool interpolate;
}

EditGraph speedGraph(MediaInfo info, SpeedParams p) {
  final hasV = info.videoStreams.isNotEmpty;
  final hasA = info.audioStreams.isNotEmpty && p.audio != SpeedAudio.mute;
  final srcFps = fpsOf(info);
  final v = <String>[
    if (p.reverse) 'reverse',
    if (p.factor != 1) 'setpts=PTS/${fnum(p.factor, 6)}',
    if (p.interpolate) 'minterpolate=fps=${fnum(p.fps ?? srcFps)}:mi_mode=mci:mc_mode=aobmc:vsbmc=1',
    if (!p.interpolate && p.fps != null) 'fps=${fnum(p.fps!)}',
  ];
  final sr = info.audioStreams.firstOrNull?.sampleRate ?? 48000;
  final a = <String>[
    if (p.reverse) 'areverse',
    if (p.factor != 1 && p.audio == SpeedAudio.keepPitch) ...atempoChain(p.factor),
    if (p.factor != 1 && p.audio == SpeedAudio.changePitch) ...['asetrate=${(sr * p.factor).round()}', 'aresample=$sr'],
  ];
  final d = info.duration;
  return EditGraph(
    complex: [
      if (hasV) '[0:v:0]${v.isEmpty ? 'null' : v.join(',')}[v]',
      if (hasA) '[0:a:0]${a.isEmpty ? 'anull' : a.join(',')}[a]',
    ].join(';'),
    video: hasV ? 'v' : null,
    audio: hasA ? 'a' : null,
    duration: d == null ? null : Duration(microseconds: (d.inMicroseconds / p.factor).round()),
  );
}

// ================================================================= restore

enum Deinterlace { off, bwdif, yadif }

enum Denoise { off, light, medium, strong, nlmeans }

enum Sharpen { off, light, medium, strong, cas }

class RestoreParams {
  const RestoreParams({
    this.deinterlace = Deinterlace.off,
    this.denoise = Denoise.off,
    this.sharpen = Sharpen.off,
    this.stabilize = false,
    this.shakiness = 5,
    this.smoothing = 15,
    this.useVidstab = true,
  });
  final Deinterlace deinterlace;
  final Denoise denoise;
  final Sharpen sharpen;
  final bool stabilize;

  /// vidstabdetect shakiness 1–10.
  final int shakiness;

  /// vidstabtransform smoothing (frames on each side).
  final int smoothing;

  /// false = single-pass `deshake` (when libvidstab is missing).
  final bool useVidstab;
}

/// File written by vidstabdetect; relative to the job's `{{tmp}}` cwd so
/// no path escaping is needed.
const vidstabFile = 'transforms.trf';

List<String> _restorePre(RestoreParams p) => [
  if (p.deinterlace == Deinterlace.bwdif) 'bwdif=mode=send_frame',
  if (p.deinterlace == Deinterlace.yadif) 'yadif=mode=send_frame',
];

List<String> _restorePost(RestoreParams p) => [
  ...switch (p.denoise) {
    Denoise.off => <String>[],
    Denoise.light => ['hqdn3d=2:1.5:3:3'],
    Denoise.medium => ['hqdn3d=4:3:6:4.5'],
    Denoise.strong => ['hqdn3d=8:6:12:9'],
    Denoise.nlmeans => ['nlmeans=s=3:p=7:r=15'],
  },
  ...switch (p.sharpen) {
    Sharpen.off => <String>[],
    Sharpen.light => ['unsharp=5:5:0.5:5:5:0'],
    Sharpen.medium => ['unsharp=5:5:1.0:5:5:0'],
    Sharpen.strong => ['unsharp=7:7:1.5:7:7:0'],
    Sharpen.cas => ['cas=strength=0.6'],
  },
];

/// Pass 1 of vidstab: analysis only (`-f null`).
List<String> vidstabDetectArgs(MediaInfo info, RestoreParams p) => FfmpegCommand(
  inputs: [FfmpegInput(info.path)],
  outputs: [
    FfmpegOutput(
      '-',
      maps: ['0:v:0'],
      videoFilters: [..._restorePre(p), 'vidstabdetect=shakiness=${p.shakiness}:accuracy=15:result=$vidstabFile'],
      format: 'null',
    ),
  ],
).toArgs();

EditGraph restoreGraph(MediaInfo info, RestoreParams p) {
  final v = <String>[
    ..._restorePre(p),
    if (p.stabilize && p.useVidstab)
      'vidstabtransform=input=$vidstabFile:smoothing=${p.smoothing}:optzoom=1:interpol=bicubic',
    if (p.stabilize && !p.useVidstab) 'deshake',
    ..._restorePost(p),
  ];
  return EditGraph(
    complex: '[0:v:0]${v.isEmpty ? 'null' : v.join(',')}[v]',
    video: 'v',
    audio: info.audioStreams.isEmpty ? null : '0:a',
  );
}

// =================================================================== color

enum ColorLook { none, grayscale, sepia, vintage, crossProcess, negative, strongContrast, lighter, darker }

class ColorParams {
  const ColorParams({
    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
    this.gamma = 1,
    this.hue = 0,
    this.temperature = 6500,
    this.look = ColorLook.none,
    this.vignette = false,
    this.lutPath,
    this.lutMix = 1,
  });

  /// eq: −1…1, 0 = unchanged.
  final double brightness;

  /// eq: 0…3, 1 = unchanged.
  final double contrast;

  /// eq: 0…3, 1 = unchanged.
  final double saturation;
  final double gamma;

  /// Degrees.
  final double hue;

  /// Kelvin (colortemperature), 6500 = neutral.
  final double temperature;
  final ColorLook look;
  final bool vignette;

  /// .cube/.3dl LUT.
  final String? lutPath;

  /// How much of the LUT result is mixed in (0…1).
  final double lutMix;
}

List<String> colorFilters(ColorParams p) => [
  if (p.lutPath != null && p.lutMix >= 0.999) 'lut3d=file=${escapeFilterValue(p.lutPath!)}',
  if (p.brightness != 0 || p.contrast != 1 || p.saturation != 1 || p.gamma != 1)
    'eq=brightness=${fnum(p.brightness)}:contrast=${fnum(p.contrast)}:saturation=${fnum(p.saturation)}:gamma=${fnum(p.gamma)}',
  if (p.hue != 0) 'hue=h=${fnum(p.hue, 1)}',
  if (p.temperature != 6500) 'colortemperature=temperature=${p.temperature.round()}',
  ...switch (p.look) {
    ColorLook.none => <String>[],
    ColorLook.grayscale => ['hue=s=0'],
    ColorLook.sepia => ['colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131'],
    ColorLook.vintage => ['curves=preset=vintage'],
    ColorLook.crossProcess => ['curves=preset=cross_process'],
    ColorLook.negative => ['curves=preset=negative'],
    ColorLook.strongContrast => ['curves=preset=strong_contrast'],
    ColorLook.lighter => ['curves=preset=lighter'],
    ColorLook.darker => ['curves=preset=darker'],
  },
  if (p.vignette) 'vignette=angle=PI/4',
];

EditGraph colorGraph(MediaInfo info, ColorParams p) {
  final f = colorFilters(p);
  final audio = info.audioStreams.isEmpty ? null : '0:a';
  final lut = p.lutPath;
  if (lut != null && p.lutMix < 0.999) {
    // Partial LUT: blend the graded copy over the original.
    final rest = f.isEmpty ? 'null' : f.join(',');
    return EditGraph(
      complex:
          '[0:v:0]split[o][g];[g]lut3d=file=${escapeFilterValue(lut)}[gl];'
          '[o][gl]blend=all_mode=normal:all_opacity=${fnum(p.lutMix)},$rest[v]',
      video: 'v',
      audio: audio,
    );
  }
  return EditGraph(complex: '[0:v:0]${f.isEmpty ? 'null' : f.join(',')}[v]', video: 'v', audio: audio);
}

// ================================================================= overlay

enum Corner { topLeft, top, topRight, left, center, right, bottomLeft, bottom, bottomRight }

/// Overlay position expressions (`W/H` main, `w/h` overlay, margin [m]).
(String, String) cornerXY(Corner c, int m, {String ow = 'w', String oh = 'h', String mw = 'W', String mh = 'H'}) {
  final left = '$m', right = '$mw-$ow-$m', cx = '($mw-$ow)/2';
  final top = '$m', bottom = '$mh-$oh-$m', cy = '($mh-$oh)/2';
  return switch (c) {
    Corner.topLeft => (left, top),
    Corner.top => (cx, top),
    Corner.topRight => (right, top),
    Corner.left => (left, cy),
    Corner.center => (cx, cy),
    Corner.right => (right, cy),
    Corner.bottomLeft => (left, bottom),
    Corner.bottom => (cx, bottom),
    Corner.bottomRight => (right, bottom),
  };
}

/// `enable='between(t,a,b)'` for a time window (null = always).
String enableExpr(Duration? from, Duration? to) {
  if (from == null && to == null) return '';
  final a = secs(from ?? Duration.zero);
  if (to == null) return ":enable='gte(t,$a)'";
  return ":enable='between(t,$a,${secs(to)})'";
}

/// Text for drawtext with `expansion=none` (no `%{…}` processing).
String drawtextText(String s) => escapeFilterValue(s.replaceAll('\r', ''));

class OverlayParams {
  const OverlayParams({
    this.imagePath,
    this.imageScale = 0.15,
    this.imageOpacity = 1,
    this.imageCorner = Corner.bottomRight,
    this.text = '',
    this.textCorner = Corner.bottom,
    this.fontSize = 0.05,
    this.fontColor = 'white',
    this.textBox = true,
    this.fontFile,
    this.timecode = false,
    this.timecodeCorner = Corner.topLeft,
    this.margin = 0.03,
    this.from,
    this.to,
  });

  final String? imagePath;

  /// Watermark width as a share of the video width.
  final double imageScale;
  final double imageOpacity;
  final Corner imageCorner;
  final String text;
  final Corner textCorner;

  /// Font size as a share of the video height.
  final double fontSize;
  final String fontColor;
  final bool textBox;

  /// TTF/OTF; null = fontconfig default "Sans".
  final String? fontFile;
  final bool timecode;
  final Corner timecodeCorner;

  /// Margin as a share of the video height.
  final double margin;
  final Duration? from;
  final Duration? to;

  bool get isEmpty => imagePath == null && text.trim().isEmpty && !timecode;
}

String _font(String? fontFile) => fontFile == null ? 'font=Sans' : 'fontfile=${escapeFilterValue(fontFile)}';

EditGraph overlayGraph(MediaInfo info, OverlayParams p) {
  final (vw, vh) = displaySize(info);
  final m = math.max(2, (vh * p.margin).round());
  final en = enableExpr(p.from, p.to);
  final parts = <String>[];
  var cur = '0:v:0';
  final inputs = <FfmpegInput>[];
  if (p.imagePath != null) {
    inputs.add(FfmpegInput(p.imagePath!));
    final iw = even(vw * p.imageScale);
    final alpha = p.imageOpacity < 0.999 ? ',colorchannelmixer=aa=${fnum(p.imageOpacity)}' : '';
    parts.add('[1:v]scale=$iw:-1,format=rgba$alpha[wm]');
    final (x, y) = cornerXY(p.imageCorner, m);
    parts.add('[$cur][wm]overlay=x=$x:y=$y$en[ov1]');
    cur = 'ov1';
  }
  final size = math.max(8, (vh * p.fontSize).round());
  final box = p.textBox
      ? ':box=1:boxcolor=black@0.5:boxborderw=${(size * 0.3).round()}'
      : ':borderw=2:bordercolor=black@0.8';
  if (p.text.trim().isNotEmpty) {
    final (x, y) = cornerXY(p.textCorner, m, ow: 'tw', oh: 'th', mw: 'w', mh: 'h');
    parts.add(
      '[$cur]drawtext=${_font(p.fontFile)}:expansion=none:text=${drawtextText(p.text)}:'
      'fontsize=$size:fontcolor=${p.fontColor}$box:x=$x:y=$y$en[ov2]',
    );
    cur = 'ov2';
  }
  if (p.timecode) {
    final (x, y) = cornerXY(p.timecodeCorner, m, ow: 'tw', oh: 'th', mw: 'w', mh: 'h');
    // %{pts\:hms} → H:MM:SS.mmm of the frame.
    parts.add(
      "[$cur]drawtext=${_font(p.fontFile)}:text='%{pts\\:hms}':"
      'fontsize=$size:fontcolor=${p.fontColor}$box:x=$x:y=$y$en[ov3]',
    );
    cur = 'ov3';
  }
  if (parts.isEmpty) parts.add('[0:v:0]null[ov0]');
  final last = parts.removeLast();
  parts.add('${last.substring(0, last.lastIndexOf('['))}[v]');
  return EditGraph(
    inputs: inputs,
    complex: parts.join(';'),
    video: 'v',
    audio: info.audioStreams.isEmpty ? null : '0:a',
  );
}

// ==================================================================== blur

enum BlurMode { blur, pixelate, delogo, box }

class BlurRegion {
  const BlurRegion(this.rect, {this.from, this.to});
  final CropRect rect;
  final Duration? from;
  final Duration? to;
}

class BlurParams {
  const BlurParams({this.regions = const [], this.mode = BlurMode.blur, this.strength = 0.5, this.wholeFrame = false});
  final List<BlurRegion> regions;
  final BlurMode mode;

  /// 0…1.
  final double strength;

  /// Blur the whole frame instead of regions (gblur).
  final bool wholeFrame;
}

/// Keeps a region inside the frame (delogo needs ≥1 px margin).
CropRect clampRegion(CropRect r, int vw, int vh, {int margin = 0}) {
  final x = r.x.clamp(margin, math.max(margin, vw - margin - 2)).toInt();
  final y = r.y.clamp(margin, math.max(margin, vh - margin - 2)).toInt();
  final w = r.w.clamp(2, math.max(2, vw - margin - x)).toInt();
  final h = r.h.clamp(2, math.max(2, vh - margin - y)).toInt();
  return CropRect(x, y, w, h);
}

EditGraph blurGraph(MediaInfo info, BlurParams p) {
  final (vw, vh) = displaySize(info);
  final audio = info.audioStreams.isEmpty ? null : '0:a';
  if (p.wholeFrame) {
    return EditGraph(complex: '[0:v:0]gblur=sigma=${fnum(2 + p.strength * 38, 1)}[v]', video: 'v', audio: audio);
  }
  final parts = <String>[];
  var cur = '0:v:0';
  for (var i = 0; i < p.regions.length; i++) {
    final reg = p.regions[i];
    final en = enableExpr(reg.from, reg.to);
    final out = 'r$i';
    switch (p.mode) {
      case BlurMode.delogo:
        final r = clampRegion(reg.rect, vw, vh, margin: 1);
        parts.add('[$cur]delogo=x=${r.x}:y=${r.y}:w=${r.w}:h=${r.h}$en[$out]');
      case BlurMode.box:
        final r = clampRegion(reg.rect, vw, vh);
        parts.add('[$cur]drawbox=x=${r.x}:y=${r.y}:w=${r.w}:h=${r.h}:color=black:t=fill$en[$out]');
      case BlurMode.blur:
      case BlurMode.pixelate:
        final r = clampRegion(reg.rect, vw, vh);
        final minSide = math.min(r.w, r.h);
        final effect = p.mode == BlurMode.blur
            // boxblur radius must be ≤ min(w,h)/2 for the chroma planes too.
            ? 'boxblur=luma_radius=${math.max(1, (minSide / 4 * (0.2 + p.strength * 0.8)).floor())}:luma_power=3'
            : 'pixelize=w=${math.max(2, (minSide / 4 * (0.1 + p.strength * 0.9)).round())}:'
                  'h=${math.max(2, (minSide / 4 * (0.1 + p.strength * 0.9)).round())}';
        parts
          ..add('[$cur]split[b$i][c$i]')
          ..add('[c$i]crop=${r.w}:${r.h}:${r.x}:${r.y},$effect[e$i]')
          ..add('[b$i][e$i]overlay=x=${r.x}:y=${r.y}$en[$out]');
    }
    cur = out;
  }
  if (parts.isEmpty) return EditGraph(complex: '[0:v:0]null[v]', video: 'v', audio: audio);
  final last = parts.removeLast();
  parts.add('${last.substring(0, last.lastIndexOf('['))}[v]');
  return EditGraph(complex: parts.join(';'), video: 'v', audio: audio);
}

// =================================================================== stack

enum StackLayout { sideBySide, topBottom, grid, pip }

enum StackAudio { first, mix, none }

class StackParams {
  const StackParams({
    this.layout = StackLayout.sideBySide,
    this.audio = StackAudio.first,
    this.pipCorner = Corner.bottomRight,
    this.pipScale = 0.3,
    this.shortest = true,
  });
  final StackLayout layout;
  final StackAudio audio;
  final Corner pipCorner;

  /// PiP width as a share of the main video width.
  final double pipScale;

  /// End with the shortest clip (otherwise the longest; ended clips freeze).
  final bool shortest;
}

EditGraph stackGraph(List<MediaInfo> clips, StackParams p) {
  final (w0, h0) = displaySize(clips.first);
  final n = clips.length;
  final parts = <String>[];
  final sh = p.shortest ? 1 : 0;
  switch (p.layout) {
    case StackLayout.sideBySide:
      final h = even(h0);
      for (var i = 0; i < n; i++) {
        parts.add('[$i:v:0]scale=-2:$h,setsar=1[s$i]');
      }
      parts.add('${[for (var i = 0; i < n; i++) '[s$i]'].join()}hstack=inputs=$n:shortest=$sh[v]');
    case StackLayout.topBottom:
      final w = even(w0);
      for (var i = 0; i < n; i++) {
        parts.add('[$i:v:0]scale=$w:-2,setsar=1[s$i]');
      }
      parts.add('${[for (var i = 0; i < n; i++) '[s$i]'].join()}vstack=inputs=$n:shortest=$sh[v]');
    case StackLayout.grid:
      // Cells of the first clip's size; 2 columns.
      final cw = even(w0 / 2), ch = even(h0 / 2);
      final cells = n.isOdd ? n + 1 : n;
      for (var i = 0; i < n; i++) {
        parts.add(
          '[$i:v:0]scale=$cw:$ch:force_original_aspect_ratio=decrease,pad=$cw:$ch:(ow-iw)/2:(oh-ih)/2,setsar=1[s$i]',
        );
      }
      if (cells > n) parts.add('color=c=black:s=${cw}x$ch:r=${fnum(fpsOf(clips.first))}[s$n]');
      final layout = [for (var i = 0; i < cells; i++) '${i.isOdd ? cw : 0}_${(i ~/ 2) * ch}'].join('|');
      parts.add('${[for (var i = 0; i < cells; i++) '[s$i]'].join()}xstack=inputs=$cells:layout=$layout:shortest=1[v]');
    case StackLayout.pip:
      final pw = even(w0 * p.pipScale);
      final m = even(h0 * 0.03);
      var cur = '0:v:0';
      for (var i = 1; i < n; i++) {
        parts.add('[$i:v:0]scale=$pw:-2,setsar=1[p$i]');
        final (x, y) = cornerXY(p.pipCorner, m);
        final last = i == n - 1;
        parts.add('[$cur][p$i]overlay=x=$x:y=$y:shortest=$sh:eof_action=pass${last ? '' : ''}[o$i]');
        cur = 'o$i';
      }
      final last = parts.removeLast();
      parts.add('${last.substring(0, last.lastIndexOf('['))}[v]');
  }
  final durations = clips.map((c) => c.duration).whereType<Duration>().toList();
  final shortest = p.shortest || p.layout == StackLayout.grid;
  final total = durations.isEmpty
      ? null
      : (shortest ? durations.reduce((a, b) => a < b ? a : b) : durations.reduce((a, b) => a > b ? a : b));
  // Audio is cut to the video's length (a short clip without audio would
  // not limit amix).
  final trim = shortest && total != null ? ',atrim=duration=${secs(total)}' : '';
  String? audio;
  final withAudio = [
    for (var i = 0; i < n; i++)
      if (clips[i].audioStreams.isNotEmpty) i,
  ];
  final sources = switch (p.audio) {
    StackAudio.first => clips.first.audioStreams.isNotEmpty ? [0] : <int>[],
    StackAudio.mix => withAudio,
    StackAudio.none => <int>[],
  };
  if (sources.length == 1) {
    parts.add('[${sources.single}:a:0]anull$trim[a]');
    audio = 'a';
  } else if (sources.length > 1) {
    parts.add(
      '${sources.map((i) => '[$i:a:0]').join()}amix=inputs=${sources.length}:duration=longest:normalize=0$trim[a]',
    );
    audio = 'a';
  }
  return EditGraph(
    inputs: [for (final c in clips.skip(1)) FfmpegInput(c.path)],
    complex: parts.join(';'),
    video: 'v',
    audio: audio,
    duration: total,
  );
}

// ==================================================================== loop

enum LoopMode { repeat, boomerang }

class LoopParams {
  const LoopParams({this.mode = LoopMode.repeat, this.times = 3, this.boomerangAudio = false});
  final LoopMode mode;

  /// Total plays (≥2) of the clip (or of the boomerang).
  final int times;
  final bool boomerangAudio;
}

EditGraph loopGraph(MediaInfo info, LoopParams p) {
  final d = info.duration ?? Duration.zero;
  final hasA = info.audioStreams.isNotEmpty;
  if (p.mode == LoopMode.repeat) {
    return EditGraph(
      mainInput: FfmpegInput(info.path, options: ['-stream_loop', '${p.times - 1}']),
      complex: ['[0:v:0]null[v]', if (hasA) '[0:a:0]anull[a]'].join(';'),
      video: 'v',
      audio: hasA ? 'a' : null,
      duration: d * p.times,
    );
  }
  // Boomerang: forward + reversed, then the pair repeated.
  final withAudio = hasA && p.boomerangAudio;
  final parts = <String>[
    '[0:v:0]split[f][r0];[r0]reverse[r];[f][r]concat=n=2:v=1:a=0[bv]',
    if (withAudio) '[0:a:0]asplit[af][ar0];[ar0]areverse[ar];[af][ar]concat=n=2:v=0:a=1[ba]',
  ];
  if (p.times > 1) {
    final size = (fpsOf(info) * d.inMicroseconds / 1e6 * 2).ceil() + 2;
    parts.add('[bv]loop=loop=${p.times - 1}:size=$size:start=0[v]');
    if (withAudio) {
      final sr = info.audioStreams.first.sampleRate ?? 48000;
      parts.add('[ba]aloop=loop=${p.times - 1}:size=${(sr * d.inMicroseconds / 1e6 * 2).ceil() + sr}[a]');
    }
  } else {
    parts.add('[bv]null[v]');
    if (withAudio) parts.add('[ba]anull[a]');
  }
  return EditGraph(complex: parts.join(';'), video: 'v', audio: withAudio ? 'a' : null, duration: d * 2 * p.times);
}

// ============================================================ HDR → SDR

enum ToneMap { hable, mobius, reinhard, bt2390 }

/// zscale (linearize) → tonemap → zscale to BT.709 (libzimg), or
/// libplacebo when available and preferred.
EditGraph hdrToSdrGraph(MediaInfo info, {ToneMap curve = ToneMap.hable, double desat = 0, bool placebo = false}) {
  final String chain;
  if (placebo) {
    chain =
        'libplacebo=tonemapping=${curve == ToneMap.bt2390 ? 'bt.2390' : curve.name}:colorspace=bt709:'
        'color_primaries=bt709:color_trc=bt709:range=tv:format=yuv420p';
  } else {
    final tm = curve == ToneMap.bt2390 ? 'hable' : curve.name;
    chain =
        'zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=$tm:desat=${fnum(desat)},'
        'zscale=t=bt709:m=bt709:r=tv,format=yuv420p';
  }
  return EditGraph(complex: '[0:v:0]$chain[v]', video: 'v', audio: info.audioStreams.isEmpty ? null : '0:a');
}

bool isHdr(MediaInfo info) {
  final v = info.videoStreams.firstOrNull;
  return v != null && (v.colorTransfer == 'smpte2084' || v.colorTransfer == 'arib-std-b67');
}

/// Start data for Cut/Join handed over by other tools (e.g. detectors).
class CutRanges {
  const CutRanges(this.ranges, {this.remove = true});
  final List<(Duration, Duration)> ranges;
  final bool remove;
}

/// Start data for Split: cut points.
class SplitTimes {
  const SplitTimes(this.times);
  final List<Duration> times;
}
