/// Subtitles (stage 4): burn in, add/extract/remove tracks, convert and
/// shift subtitle files. Options checked on ffmpeg 6.1 and 9.0.
library;

import 'package:path/path.dart' as p;

import '../../core/engine/containers.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../convert/convert_params.dart';
import '../edit/graphs.dart' show secs;

/// Subtitle file extensions the tools accept.
const subtitleExts = ['srt', 'ass', 'ssa', 'vtt', 'sub', 'sup', 'ttml', 'lrc'];

const textSubtitleCodecs = {
  'subrip',
  'srt',
  'ass',
  'ssa',
  'webvtt',
  'mov_text',
  'text',
  'microdvd',
  'subviewer',
  'ttml',
};

bool isTextSubtitle(String? codec) => codec != null && textSubtitleCodecs.contains(codec);

/// Encodings offered for legacy (non-UTF-8) subtitle files.
const subtitleCharsets = [
  'UTF-8',
  'CP1251',
  'KOI8-R',
  'CP1252',
  'ISO-8859-1',
  'CP1250',
  'ISO-8859-2',
  'CP866',
  'UTF-16',
];

// ================================================================== burn in

enum SubPosition { bottom, top }

class BurnStyle {
  const BurnStyle({
    this.fontSize,
    this.color,
    this.box = false,
    this.outline = 2,
    this.marginV,
    this.position = SubPosition.bottom,
    this.fontName,
  });

  /// null = keep the file's own style (ASS) / libass default (SRT).
  final int? fontSize;

  /// `RRGGBB`.
  final String? color;

  /// Opaque box behind the text (BorderStyle=3) instead of an outline.
  final bool box;
  final int outline;
  final int? marginV;
  final SubPosition position;
  final String? fontName;

  bool get isDefault =>
      fontSize == null &&
      color == null &&
      !box &&
      outline == 2 &&
      marginV == null &&
      position == SubPosition.bottom &&
      fontName == null;
}

/// ASS colour `&HAABBGGRR` from `RRGGBB`.
String assColor(String rgb, {int alpha = 0}) {
  final r = rgb.substring(0, 2), g = rgb.substring(2, 4), b = rgb.substring(4, 6);
  return '&H${alpha.toRadixString(16).padLeft(2, '0').toUpperCase()}$b$g$r'.toUpperCase();
}

/// libass `force_style` (comma-separated ASS style overrides).
String forceStyle(BurnStyle s) => [
  if (s.fontName != null) 'FontName=${s.fontName}',
  if (s.fontSize != null) 'FontSize=${s.fontSize}',
  if (s.color != null) 'PrimaryColour=${assColor(s.color!)}',
  if (s.box) ...['BorderStyle=3', 'BackColour=&H80000000', 'OutlineColour=&H80000000'] else 'BorderStyle=1',
  'Outline=${s.outline}',
  if (s.marginV != null) 'MarginV=${s.marginV}',
  if (s.position == SubPosition.top) 'Alignment=8',
].join(',');

/// Burns subtitles from [subFile] (or the source's own subtitle stream
/// [streamIndex] among its subtitle streams) into the video.
///   `[0:v:0]subtitles=filename=…:si=N:charenc=…:force_style='…'[v]`
EditGraph burnGraph(
  MediaInfo info, {
  String? subFile,
  int streamIndex = 0,
  BurnStyle style = const BurnStyle(),
  String? charset,
}) {
  final opts = <String>[
    'filename=${escapeFilterValue(subFile ?? info.path)}',
    if (subFile == null) 'si=$streamIndex',
    if (charset != null && charset != 'UTF-8') 'charenc=$charset',
    if (!style.isDefault) 'force_style=${escapeFilterValue(forceStyle(style))}',
  ];
  return EditGraph(
    complex: '[0:v:0]subtitles=${opts.join(':')}[v]',
    video: 'v',
    audio: info.audioStreams.isEmpty ? null : '0:a',
  );
}

// =================================================================== tracks

class NewSubTrack {
  const NewSubTrack(this.path, {this.language, this.title, this.isDefault = false, this.forced = false, this.charset});
  final String path;

  /// ISO 639-2 (rus, eng…).
  final String? language;
  final String? title;
  final bool isDefault;
  final bool forced;
  final String? charset;
}

/// Subtitle codec a container stores text subtitles in.
String? subtitleCodecFor(String ext, {String? sourceCodec}) => switch (ext) {
  'mp4' || 'mov' || 'm4v' => 'mov_text',
  'webm' => 'webvtt',
  'mkv' || 'mka' => (sourceCodec == 'ass' || sourceCodec == 'ssa') ? 'ass' : 'srt',
  _ => null,
};

/// Containers that can hold subtitle tracks.
bool canHoldSubtitles(String ext) => subtitleCodecFor(ext) != null;

/// Remuxes [info] without re-encoding: keeps the subtitle streams whose
/// indices (among subtitle streams) are in [keep], appends [add].
List<JobStep> planSubTracks({
  required MediaInfo info,
  required String output,
  required List<int> keep,
  List<NewSubTrack> add = const [],
}) {
  final ext = p.extension(output).replaceFirst('.', '').toLowerCase();
  final subs = info.subtitleStreams.toList();
  final opts = <String>['-c', 'copy'];
  var outIndex = 0;
  for (final i in keep) {
    final codec = subs[i].codecName;
    if (isTextSubtitle(codec)) {
      final target = subtitleCodecFor(ext, sourceCodec: codec);
      if (target != null && target != codec && !(target == 'srt' && codec == 'subrip')) {
        opts.addAll(['-c:s:$outIndex', target]);
      }
    }
    outIndex++;
  }
  for (final (k, t) in add.indexed) {
    final o = outIndex + k;
    final target = subtitleCodecFor(ext, sourceCodec: p.extension(t.path).replaceFirst('.', ''));
    if (target != null) opts.addAll(['-c:s:$o', target]);
    if (t.language != null) opts.addAll(['-metadata:s:s:$o', 'language=${t.language}']);
    if (t.title != null && t.title!.isNotEmpty) opts.addAll(['-metadata:s:s:$o', 'title=${t.title}']);
  }
  // Dispositions for all output subtitle streams (default/forced flags).
  final all = outIndex + add.length;
  for (var o = 0; o < all; o++) {
    final t = o >= outIndex ? add[o - outIndex] : null;
    final flags = [if (t?.isDefault ?? false) 'default', if (t?.forced ?? false) 'forced'];
    if (t != null) opts.addAll(['-disposition:s:$o', flags.isEmpty ? '0' : flags.join('+')]);
  }
  final c = containerFor(ext);
  if (c.faststart) opts.addAll(['-movflags', '+faststart']);
  return [
    JobStep(
      totalDuration: info.duration,
      args: FfmpegCommand(
        inputs: [
          FfmpegInput(info.path),
          for (final t in add)
            FfmpegInput(
              t.path,
              options: [
                if (t.charset != null && t.charset != 'UTF-8') ...['-sub_charenc', t.charset!],
              ],
            ),
        ],
        outputs: [
          FfmpegOutput(
            output,
            maps: [
              '0:v?',
              '0:a?',
              for (final i in keep) '0:s:$i',
              for (var k = 0; k < add.length; k++) '${k + 1}:0',
              '0:t?',
            ],
            options: opts,
          ),
        ],
      ).toArgs(),
    ),
  ];
}

/// File extension for extracting a subtitle stream as is / as text.
String extractSubExt(String? codec, {bool toSrt = false}) {
  if (isTextSubtitle(codec)) {
    if (toSrt) return 'srt';
    return switch (codec) {
      'ass' || 'ssa' => 'ass',
      'webvtt' => 'vtt',
      _ => 'srt',
    };
  }
  return switch (codec) {
    'hdmv_pgs_subtitle' => 'sup',
    _ => 'mks',
  };
}

/// Extracts subtitle stream [index] (among subtitle streams).
List<JobStep> planExtractSub({required MediaInfo info, required int index, required String output}) {
  final ext = p.extension(output).replaceFirst('.', '').toLowerCase();
  final codec = info.subtitleStreams.elementAt(index).codecName;
  final enc = switch (ext) {
    'srt' => 'srt',
    'ass' => 'ass',
    'vtt' => 'webvtt',
    _ => 'copy',
  };
  return [
    JobStep(
      totalDuration: info.duration,
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path)],
        outputs: [
          FfmpegOutput(output, maps: ['0:s:$index'], options: ['-c:s', isTextSubtitle(codec) ? enc : 'copy']),
        ],
      ).toArgs(),
    ),
  ];
}

// ================================================================= convert

enum SubFormat { srt, ass, vtt }

String subFormatExt(SubFormat f) => f.name;

/// Converts a subtitle file: format, encoding, time shift and speed.
/// `-itsscale` multiplies start times (e.g. 25/23.976 for a 23.976 fps
/// video) and is applied after `-itsoffset`, so the offset is divided by the
/// scale to shift the final times by exactly [shift].
List<JobStep> planConvertSubs({
  required String input,
  required String output,
  Duration shift = Duration.zero,
  String? charset,
  double scale = 1,
}) {
  final ext = p.extension(output).replaceFirst('.', '').toLowerCase();
  final enc = switch (ext) {
    'ass' => 'ass',
    'vtt' => 'webvtt',
    _ => 'srt',
  };
  return [
    JobStep(
      args: FfmpegCommand(
        reportProgress: false,
        inputs: [
          FfmpegInput(
            input,
            options: [
              if (shift != Duration.zero) ...['-itsoffset', secs(shift * (1 / scale))],
              if (scale != 1) ...['-itsscale', scale.toStringAsFixed(6)],
              if (charset != null && charset != 'UTF-8') ...['-sub_charenc', charset],
            ],
          ),
        ],
        outputs: [
          FfmpegOutput(output, maps: ['0:s:0'], options: ['-c:s', enc]),
        ],
      ).toArgs(),
    ),
  ];
}
