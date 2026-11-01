/// Stream-copy (lossless, instant) editing jobs: cut/join by keyframes,
/// joining identical files, splitting with the segment muxer.
library;

import 'package:path/path.dart' as p;

import '../../core/engine/containers.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../convert/convert_params.dart';
import 'edit_encode.dart';
import 'graphs.dart';

const _listFile = '{{tmp}}/list.ffconcat';

List<String> _copyOptions(String ext) => [
  '-c',
  'copy',
  '-dn',
  if (!containerFor(ext).subtitles) '-sn',
  if (containerFor(ext).faststart) ...['-movflags', '+faststart'],
];

/// Keeps [keep] ranges with stream copy (each range starts at the keyframe
/// at or before its start): concat demuxer with `inpoint`/`outpoint`.
List<JobStep> planCutCopy(MediaInfo info, List<(Duration, Duration)> keep, String output) {
  final ext = p.extension(output).replaceFirst('.', '');
  final script = ffconcatScript([for (final (s, e) in keep) (path: info.path, inpoint: s, outpoint: e)]);
  final total = keep.fold<Duration>(Duration.zero, (t, r) => t + (r.$2 - r.$1));
  return [
    JobStep(
      files: {_listFile: script},
      totalDuration: total,
      args: FfmpegCommand(
        inputs: [ffconcatInput(_listFile)],
        outputs: [
          FfmpegOutput(
            output,
            maps: ['0:v?', '0:a?'],
            options: ['-avoid_negative_ts', 'make_zero', ..._copyOptions(ext)],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

/// Joins files with identical codecs/parameters without re-encoding.
List<JobStep> planConcatCopy(List<MediaInfo> clips, String output) {
  final ext = p.extension(output).replaceFirst('.', '');
  final script = ffconcatScript([for (final c in clips) (path: c.path, inpoint: null, outpoint: null)]);
  return [
    JobStep(
      files: {_listFile: script},
      totalDuration: clips.fold<Duration>(Duration.zero, (t, c) => t + (c.duration ?? Duration.zero)),
      args: FfmpegCommand(
        inputs: [ffconcatInput(_listFile)],
        outputs: [
          FfmpegOutput(output, maps: ['0:v?', '0:a?'], options: _copyOptions(ext)),
        ],
      ).toArgs(),
    ),
  ];
}

enum SplitMode { every, parts, chapters, times }

class SplitParams {
  const SplitParams({
    this.mode = SplitMode.every,
    this.every = const Duration(minutes: 1),
    this.parts = 2,
    this.times = const [],
    this.precise = false,
  });
  final SplitMode mode;
  final Duration every;
  final int parts;

  /// Cut points for [SplitMode.times].
  final List<Duration> times;

  /// Re-encode with keyframes forced at the cut points (exact cuts).
  final bool precise;
}

/// Cut points of [s] (empty for [SplitMode.every], which uses `-segment_time`).
List<Duration> splitPoints(MediaInfo info, SplitParams s) {
  final d = info.duration ?? Duration.zero;
  final pts = switch (s.mode) {
    SplitMode.every => <Duration>[],
    SplitMode.parts => [for (var i = 1; i < s.parts; i++) d * i ~/ s.parts],
    SplitMode.chapters => [for (final c in info.chapters.skip(1)) c.start],
    SplitMode.times => ([...s.times]..sort()),
  };
  return pts.where((t) => t > Duration.zero && (d == Duration.zero || t < d)).toList();
}

/// Number of resulting files (estimate for [SplitMode.every]).
int splitCount(MediaInfo info, SplitParams s) {
  if (s.mode == SplitMode.every) {
    final d = info.duration ?? Duration.zero;
    if (s.every <= Duration.zero) return 1;
    return (d.inMicroseconds / s.every.inMicroseconds).ceil().clamp(1, 1 << 20);
  }
  return splitPoints(info, s).length + 1;
}

/// `name_%03d.ext` next to [output]; `%` in the name is escaped.
String splitPattern(String output) {
  final dir = p.dirname(output);
  final base = p.basenameWithoutExtension(output).replaceAll('%', '%%');
  return p.join(dir, '${base}_%03d${p.extension(output)}');
}

/// Segment muxer: `-f segment -segment_time N | -segment_times a,b -reset_timestamps 1`.
List<JobStep> planSplit({
  required MediaInfo info,
  required SplitParams s,
  required String output,
  EditOutput out = const EditOutput(),
  EncodeEnv env = const EncodeEnv(),
}) {
  final pattern = splitPattern(output);
  final ext = p.extension(output).replaceFirst('.', '');
  final points = splitPoints(info, s);
  final segOpts = <String>[
    '-f',
    'segment',
    if (s.mode == SplitMode.every) ...['-segment_time', secs(s.every)],
    if (s.mode != SplitMode.every) ...['-segment_times', points.map(secs).join(',')],
    '-reset_timestamps',
    '1',
  ];
  if (!s.precise) {
    final args = FfmpegCommand(
      inputs: [FfmpegInput(info.path)],
      outputs: [
        FfmpegOutput(pattern, maps: ['0:v?', '0:a?'], options: [..._withoutFaststart(_copyOptions(ext)), ...segOpts]),
      ],
    ).toArgs();
    return [JobStep(args: args, totalDuration: info.duration)];
  }
  final graph = EditGraph(
    complex: '[0:v:0]null[v]',
    video: info.videoStreams.isEmpty ? null : 'v',
    audio: info.audioStreams.isEmpty ? null : '0:a',
  );
  final g = info.videoStreams.isEmpty ? EditGraph(complex: '[0:a:0]anull[a]', audio: 'a') : graph;
  final plan = planEdit(
    info: info,
    output: pattern,
    graph: g,
    out: out.copyWith(ext: ext),
    env: env,
  );
  final forced = s.mode == SplitMode.every ? 'expr:gte(t,n_forced*${secs(s.every)})' : points.map(secs).join(',');
  final st = plan.steps.last;
  final args = _withoutFaststart(st.args.sublist(0, st.args.length - 1));
  return [
    JobStep(
      args: [
        ...args,
        if (info.videoStreams.isNotEmpty) ...['-force_key_frames', forced],
        ...segOpts,
        st.args.last,
      ],
      totalDuration: info.duration,
    ),
  ];
}

/// The segment muxer does not take `-movflags` (it would need
/// `-segment_format_options`), so it is dropped.
List<String> _withoutFaststart(List<String> args) {
  final out = <String>[];
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '-movflags' && i + 1 < args.length) {
      i++;
      continue;
    }
    out.add(args[i]);
  }
  return out;
}
