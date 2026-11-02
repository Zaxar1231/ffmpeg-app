/// Metadata and repair (stage 4): tags, cover art, chapters, container and
/// timestamp repair, audio sync, MP4 faststart. Everything that can be
/// done with stream copy is.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../convert/convert_params.dart';
import '../edit/graphs.dart' show secs, fnum, fpsOf;

String _ext(String path) => p.extension(path).replaceFirst('.', '').toLowerCase();

List<String> _faststart(String output) => containerFor(_ext(output)).faststart ? ['-movflags', '+faststart'] : const [];

// =================================================================== tags

/// Common tag keys (ffmpeg generic names, mapped by each muxer).
const commonTags = [
  'title',
  'artist',
  'album_artist',
  'album',
  'date',
  'genre',
  'track',
  'disc',
  'composer',
  'comment',
  'description',
  'copyright',
];

/// Writes global [tags] (empty value = delete the key) and per-stream
/// languages ([languages]: stream index → ISO 639-2). [clearAll] drops
/// every existing tag first. Streams are copied.
List<JobStep> planTags({
  required MediaInfo info,
  required String output,
  required Map<String, String> tags,
  Map<int, String> languages = const {},
  bool clearAll = false,
}) {
  final known = commonTags.toSet();
  final custom = tags.keys.any((k) => !known.contains(k));
  final ext = _ext(output);
  return [
    JobStep(
      totalDuration: info.duration,
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path)],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0'],
            metadata: tags,
            options: [
              '-c',
              'copy',
              if (clearAll) ...['-map_metadata', '-1'] else ...['-map_metadata', '0'],
              for (final e in languages.entries) ...['-metadata:s:${e.key}', 'language=${e.value}'],
              // MP4/MOV only keep their own tag set unless asked otherwise.
              if (custom && (ext == 'mp4' || ext == 'mov' || ext == 'm4a')) ...[
                '-movflags',
                '+use_metadata_tags+faststart',
              ] else
                ..._faststart(output),
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

// ================================================================== cover

/// The stream index of embedded cover art, if any.
int? coverStreamIndex(MediaInfo info) => info.coverArt?.index;

/// Sets [image] as the cover (replacing an existing one). Audio files and
/// MP4/MOV get an `attached_pic` stream, MKV an attachment.
List<JobStep> planSetCover({required MediaInfo info, required String output, required String image}) {
  final ext = _ext(output);
  final old = coverStreamIndex(info);
  final mime = _ext(image) == 'png' ? 'image/png' : 'image/jpeg';
  if (ext == 'mkv' || ext == 'mka') {
    return [
      JobStep(
        totalDuration: info.duration,
        args: FfmpegCommand(
          inputs: [FfmpegInput(info.path)],
          outputs: [
            FfmpegOutput(
              output,
              maps: ['0', if (old != null) '-0:$old', '-0:t?'],
              options: [
                '-c',
                'copy',
                '-attach',
                image,
                '-metadata:s:t',
                'mimetype=$mime',
                '-metadata:s:t',
                'filename=cover.${mime == 'image/png' ? 'png' : 'jpg'}',
              ],
            ),
          ],
        ).toArgs(),
      ),
    ];
  }
  // Cover = the last video stream of the output.
  final videoCount = info.videoStreams.where((v) => v.index != old).length;
  return [
    JobStep(
      totalDuration: info.duration,
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path), FfmpegInput(image)],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0', if (old != null) '-0:$old', '1:v:0'],
            options: [
              '-c',
              'copy',
              // MP4/M4A only accept JPEG/PNG cover streams; FLAC/MP3 too.
              if (_ext(image) != 'jpg' && _ext(image) != 'jpeg' && _ext(image) != 'png') ...[
                '-c:v:$videoCount',
                'mjpeg',
              ],
              '-disposition:v:$videoCount',
              'attached_pic',
              if (ext == 'mp3') ...['-id3v2_version', '3'],
              ..._faststart(output),
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

List<JobStep> planRemoveCover({required MediaInfo info, required String output}) {
  final old = coverStreamIndex(info);
  return [
    JobStep(
      totalDuration: info.duration,
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path)],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0', if (old != null) '-0:$old', '-0:t?'],
            options: ['-c', 'copy', ..._faststart(output)],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

/// Saves the embedded cover as an image file (as stored).
List<JobStep> planExtractCover({required MediaInfo info, required String output}) => [
  JobStep(
    args: FfmpegCommand(
      reportProgress: false,
      inputs: [FfmpegInput(info.path)],
      outputs: [
        FfmpegOutput(
          output,
          maps: ['0:${coverStreamIndex(info) ?? 'v:0'}'],
          options: const ['-c', 'copy', '-frames:v', '1', '-update', '1'],
        ),
      ],
    ).toArgs(),
  ),
];

/// File extension of the embedded cover.
String coverExt(MediaInfo info) {
  final i = coverStreamIndex(info);
  final s = info.streams.where((x) => x.index == i).firstOrNull;
  return s?.codecName == 'png' ? 'png' : 'jpg';
}

// =============================================================== chapters

class Chapter {
  const Chapter(this.start, this.title);
  final Duration start;
  final String title;
}

/// FFMETADATA1 with chapters; each ends where the next starts.
/// `=`, `;`, `#`, `\` and newlines in values are escaped with `\`.
String ffmetadataChapters(List<Chapter> chapters, Duration total) {
  String esc(String v) => v.replaceAllMapped(RegExp(r'[=;#\\\n]'), (m) => '\\${m[0]}');
  final sorted = [...chapters]..sort((a, b) => a.start.compareTo(b.start));
  final b = StringBuffer(';FFMETADATA1\n');
  for (var i = 0; i < sorted.length; i++) {
    final end = i + 1 < sorted.length ? sorted[i + 1].start : total;
    b
      ..writeln('[CHAPTER]')
      ..writeln('TIMEBASE=1/1000')
      ..writeln('START=${sorted[i].start.inMilliseconds}')
      ..writeln('END=${end.inMilliseconds}')
      ..writeln('title=${esc(sorted[i].title)}');
  }
  return b.toString();
}

const _chapterFile = '{{tmp}}/chapters.txt';

/// Replaces the chapters (empty list = remove them all). Streams copied.
List<JobStep> planChapters({required MediaInfo info, required String output, required List<Chapter> chapters}) {
  final total = info.duration ?? (chapters.isEmpty ? Duration.zero : chapters.last.start + const Duration(seconds: 1));
  return [
    JobStep(
      totalDuration: info.duration,
      files: chapters.isEmpty ? const {} : {_chapterFile: ffmetadataChapters(chapters, total)},
      args: FfmpegCommand(
        inputs: [
          FfmpegInput(info.path),
          if (chapters.isNotEmpty) FfmpegInput(_chapterFile, format: 'ffmetadata'),
        ],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0'],
            options: [
              '-c',
              'copy',
              '-map_metadata',
              '0',
              '-map_chapters',
              chapters.isEmpty ? '-1' : '1',
              ..._faststart(output),
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

/// YouTube-style list: `0:00 Intro` per line.
String chaptersToText(List<Chapter> chapters) {
  String t(Duration d) {
    final h = d.inHours, m = d.inMinutes.remainder(60), s = d.inSeconds.remainder(60);
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
  }

  return [for (final c in chapters) '${t(c.start)} ${c.title}'].join('\n');
}

/// Parses `0:00 Intro`, `1:02:03 - Title`, `(12:30) Title` lines.
List<Chapter> chaptersFromText(String text) {
  final re = RegExp(r'^\s*\(?((?:\d+:)?\d{1,2}:\d{2}(?:\.\d+)?)\)?\s*[-–—:]?\s*(.*)$');
  final out = <Chapter>[];
  for (final line in text.split(RegExp(r'\r?\n'))) {
    final m = re.firstMatch(line);
    if (m == null) continue;
    final parts = m[1]!.split(':').map(double.parse).toList();
    var secsTotal = 0.0;
    for (final v in parts) {
      secsTotal = secsTotal * 60 + v;
    }
    out.add(Chapter(Duration(microseconds: (secsTotal * 1e6).round()), m[2]!.trim()));
  }
  return out;
}

// ================================================================= repair

enum RepairMode {
  /// Remux with regenerated timestamps: fixes most broken containers,
  /// unseekable files and "non monotonic DTS". Lossless.
  remux,

  /// Decode everything ignoring errors and re-encode with constant frame
  /// rate and resampled audio: fixes drifting sync and damaged streams.
  reencode,

  /// Shift the audio against the video (stream copy).
  audioOffset,
}

class RepairParams {
  const RepairParams({this.mode = RepairMode.remux, this.audioOffset = Duration.zero, this.fps});
  final RepairMode mode;

  /// Positive = audio later.
  final Duration audioOffset;

  /// Constant output frame rate for [RepairMode.reencode] (null = source).
  final double? fps;
}

List<JobStep> planRepair({
  required MediaInfo info,
  required String output,
  required RepairParams r,
  EncodeEnv env = const EncodeEnv(),
}) {
  final ext = _ext(output);
  final c = containerFor(ext);
  switch (r.mode) {
    case RepairMode.remux:
      return [
        JobStep(
          totalDuration: info.duration,
          args: FfmpegCommand(
            inputs: [
              FfmpegInput(info.path, options: const ['-fflags', '+genpts+discardcorrupt', '-err_detect', 'ignore_err']),
            ],
            outputs: [
              FfmpegOutput(
                output,
                maps: ['0:v?', '0:a?', if (c.subtitles) '0:s?'],
                options: ['-c', 'copy', '-avoid_negative_ts', 'make_zero', ..._faststart(output)],
              ),
            ],
          ).toArgs(),
        ),
      ];
    case RepairMode.audioOffset:
      final o = r.audioOffset;
      return [
        JobStep(
          totalDuration: info.duration,
          args: FfmpegCommand(
            inputs: [
              FfmpegInput(info.path),
              FfmpegInput(info.path, options: ['-itsoffset', secs(o)]),
            ],
            outputs: [
              FfmpegOutput(
                output,
                maps: ['0:v?', '1:a?', if (c.subtitles) '0:s?'],
                options: ['-c', 'copy', '-avoid_negative_ts', 'make_zero', ..._faststart(output)],
              ),
            ],
          ).toArgs(),
        ),
      ];
    case RepairMode.reencode:
      final fps = r.fps ?? fpsOf(info);
      final v = info.videoStreams.firstOrNull;
      final a = info.audioStreams.firstOrNull;
      final plan = planConvert(
        info: info,
        output: output,
        env: env,
        p: ConvertParams(
          container: ext,
          video: v == null ? VideoCodecChoice.none : videoChoiceFor(ext, sourceCodec: v.codecName),
          audio: a == null ? AudioCodecChoice.none : audioChoiceFor(ext, sourceCodec: a.codecName),
          quality: null,
          keepSubtitles: false,
        ),
        graph: EditGraph(
          complex: [
            if (v != null) '[0:v:0]fps=${fnum(fps, 3)},setpts=N/(${fnum(fps, 3)}*TB)[v]',
            // async: stretch/squeeze audio to follow the timestamps.
            if (a != null) '[0:a:0]aresample=async=1000:first_pts=0[a]',
          ].join(';'),
          video: v == null ? null : 'v',
          audio: a == null ? null : 'a',
        ),
      );
      return [
        for (final s in plan.steps)
          JobStep(
            args: _withInputOptions(s.args, info.path, const [
              '-err_detect',
              'ignore_err',
              '-fflags',
              '+genpts+discardcorrupt',
            ]),
            label: s.label,
            weight: s.weight,
            workingDirectory: s.workingDirectory,
            totalDuration: info.duration,
          ),
      ];
  }
}

List<String> _withInputOptions(List<String> args, String input, List<String> opts) {
  final i = args.indexOf(input);
  if (i < 1 || args[i - 1] != '-i') return args;
  return [...args.sublist(0, i - 1), ...opts, ...args.sublist(i - 1)];
}

/// Moves the MP4/MOV index to the front for instant web playback.
List<JobStep> planFaststart({required MediaInfo info, required String output}) => [
  JobStep(
    totalDuration: info.duration,
    args: FfmpegCommand(
      inputs: [FfmpegInput(info.path)],
      outputs: [
        FfmpegOutput(
          output,
          maps: ['0'],
          options: const ['-c', 'copy', '-map_metadata', '0', '-movflags', '+faststart'],
        ),
      ],
    ).toArgs(),
  ),
];

/// True when the `moov` atom comes after `mdat` (needs faststart).
/// Reads only the top-level atom headers.
Future<bool?> moovAtEnd(String path) async {
  try {
    final f = await File(path).open();
    try {
      final len = await f.length();
      var pos = 0;
      while (pos + 8 <= len) {
        await f.setPosition(pos);
        final h = await f.read(16);
        if (h.length < 8) return null;
        var size = (h[0] << 24) | (h[1] << 16) | (h[2] << 8) | h[3];
        final type = String.fromCharCodes(h.sublist(4, 8));
        if (size == 1 && h.length >= 16) {
          size = 0;
          for (var i = 8; i < 16; i++) {
            size = size * 256 + h[i];
          }
        } else if (size == 0) {
          size = len - pos;
        }
        if (type == 'moov') return false;
        if (type == 'mdat') return true;
        if (size < 8) return null;
        pos += size;
      }
      return null;
    } finally {
      await f.close();
    }
  } catch (_) {
    return null;
  }
}
