/// ffmpeg command builders for the audio editor. Every destructive edit
/// reads the track's current WAV and writes a new 32-bit float WAV.
/// Positions are sample-exact (`atrim=start_sample/end_sample`).
library;

import 'dart:math' as math;

import '../../../core/engine/ffmpeg_command.dart';
import 'effects.dart';
import 'model.dart';

const workCodec = ['-c:a', 'pcm_f32le'];

List<String> _cmd(List<FfmpegInput> inputs, String graph, String out, {List<String> extra = const []}) => FfmpegCommand(
  inputs: inputs,
  filterComplex: graph,
  outputs: [
    FfmpegOutput(out, maps: ['[out]'], options: [...workCodec, ...extra]),
  ],
).toArgs();

/// Decode any media's first audio stream into the working format.
List<String> importArgs(String source, String out, {required int sampleRate, required int channels}) => FfmpegCommand(
  inputs: [FfmpegInput(source)],
  outputs: [
    FfmpegOutput(
      out,
      maps: ['0:a:0'],
      noVideo: true,
      options: ['-ac', '$channels', '-ar', '$sampleRate', ...workCodec],
    ),
  ],
).toArgs();

String _trim(int? start, int? end) => [
  'atrim=${[if (start != null && start > 0) 'start_sample=$start', if (end != null) 'end_sample=$end'].join(':')}',
  'asetpts=PTS-STARTPTS',
].join(',').replaceFirst('atrim=,', 'anull,');

/// Splits `[0:a]` into the parts before/inside/after [r] (empty parts are
/// skipped), runs [middle] on the inside part and concatenates.
/// [middle] gets the input label and must end in the given output label.
String segmentGraph(
  SampleRange r,
  int total,
  String Function(String inLabel, String outLabel) middle, {
  String input = '[0:a]',
}) {
  final before = r.start > 0;
  final after = r.end < total;
  final parts = 1 + (before ? 1 : 0) + (after ? 1 : 0);
  final b = StringBuffer();
  final labels = <String>[];
  if (parts == 1) {
    b.write('$input${_trim(r.start > 0 ? r.start : null, r.end < total ? r.end : null)}[mid_in];');
  } else {
    b.write('${input}asplit=$parts${before ? '[pre_in]' : ''}[mid_src]${after ? '[post_in]' : ''};');
    if (before) {
      b.write('[pre_in]${_trim(null, r.start)}[pre];');
      labels.add('[pre]');
    }
    b.write('[mid_src]${_trim(r.start, r.end)}[mid_in];');
  }
  b.write('${middle('[mid_in]', '[mid]')};');
  labels.add('[mid]');
  if (after) {
    b.write('[post_in]${_trim(r.end, null)}[post];');
    labels.add('[post]');
  }
  b.write(labels.length == 1 ? '[mid]anull[out]' : '${labels.join()}concat=n=${labels.length}:v=0:a=1[out]');
  return b.toString();
}

/// Keeps an effect's output exactly [frames] long: tails (echo, chorus) are
/// cut at the selection end and early endings are padded, like Audacity.
String exactLength(String chain, int frames) => '$chain,apad=whole_len=$frames,atrim=end_sample=$frames';

/// Apply a filter chain to the selection (whole track when [r] is null).
List<String> effectArgs(String input, String out, {required int total, SampleRange? r, required String chain}) {
  final range = r ?? SampleRange(0, total);
  return _cmd([FfmpegInput(input)], segmentGraph(range, total, (i, o) => '$i$chain$o'), out);
}

/// Reverb: the synthetic impulse is a second graph source `[ir]`.
List<String> reverbArgs(
  String input,
  String out, {
  required int total,
  SampleRange? r,
  required FxValues v,
  required int sampleRate,
}) {
  final range = r ?? SampleRange(0, total);
  final chain = fxById('reverb').build!(v, FxContext(sampleRate: sampleRate, channels: 1, frames: range.length));
  // The tail rings past the selection end: pad so it is not cut off.
  final tail = (v['time']! * sampleRate).round();
  final graph =
      '${reverbImpulse(v, sampleRate)}[ir];'
      '${segmentGraph(range, total, (i, o) => '${i}apad=pad_len=$tail[rv_in];[rv_in][ir]$chain$o')}';
  return _cmd([FfmpegInput(input)], graph, out);
}

/// Noise reduction with a learned profile: the noise sample is prepended,
/// `afftdn` learns from it via `sample_noise` (asendcmd) and the prepended
/// part is trimmed away again.
List<String> noiseProfileArgs(
  String input,
  String out, {
  required int total,
  SampleRange? r,
  required String profileWav,
  required int profileFrames,
  required int sampleRate,
  required String afftdn,
}) {
  final range = r ?? SampleRange(0, total);
  final pSec = profileFrames / sampleRate;
  final graph = segmentGraph(
    range,
    total,
    (i, o) =>
        '[1:a]aformat=sample_rates=$sampleRate[nr_p];[nr_p]${i}concat=n=2:v=0:a=1,'
        "asendcmd=c='0 afftdn sample_noise start;${(pSec * 0.98).toStringAsFixed(4)} afftdn sample_noise stop',"
        '$afftdn,atrim=start_sample=$profileFrames,asetpts=PTS-STARTPTS$o',
  );
  return _cmd([FfmpegInput(input), FfmpegInput(profileWav)], graph, out);
}

/// Auto Duck: [control] (another track's WAV) drives a sidechain compressor
/// on the selection. [controlOffset] = control track start − this track start.
List<String> autoDuckArgs(
  String input,
  String out, {
  required int total,
  SampleRange? r,
  required String control,
  required int controlOffset,
  required String chain,
}) {
  final range = r ?? SampleRange(0, total);
  // Control signal for exactly the selection span on this track's timeline.
  final from = range.start - controlOffset;
  final pre = from < 0 ? -from : 0;
  final ctrl =
      '[1:a]${_trim(math.max(0, from), math.max(0, from + range.length))}'
      '${pre > 0 ? ',adelay=delays=${pre}S:all=1' : ''},apad=whole_len=${range.length},atrim=end_sample=${range.length}[ctl]';
  final graph = '$ctrl;${segmentGraph(range, total, (i, o) => '$i[ctl]$chain$o')}';
  return _cmd([FfmpegInput(input), FfmpegInput(control)], graph, out);
}

List<String> deleteArgs(String input, String out, {required int total, required SampleRange r}) {
  final parts = <String>[if (r.start > 0) 'pre', if (r.end < total) 'post'];
  if (parts.isEmpty) {
    // Deleting everything: keep a single silent sample so the file stays valid.
    return _cmd([FfmpegInput(input)], '[0:a]atrim=end_sample=1,volume=0[out]', out);
  }
  final b = StringBuffer(parts.length == 2 ? '[0:a]asplit=2[pre_in][post_in];' : '');
  String src(String p) => parts.length == 2 ? '[${p}_in]' : '[0:a]';
  if (r.start > 0) b.write('${src('pre')}${_trim(null, r.start)}[pre];');
  if (r.end < total) b.write('${src('post')}${_trim(r.end, null)}[post];');
  b.write(parts.length == 2 ? '[pre][post]concat=n=2:v=0:a=1[out]' : '[${parts.single}]anull[out]');
  return _cmd([FfmpegInput(input)], b.toString(), out);
}

List<String> silenceArgs(String input, String out, {required int total, required SampleRange r}) =>
    effectArgs(input, out, total: total, r: r, chain: 'volume=0');

List<String> trimToArgs(String input, String out, {required SampleRange r}) =>
    _cmd([FfmpegInput(input)], '[0:a]${_trim(r.start, r.end)}[out]', out);

/// Copy a range into a clip file (clipboard, duplicate, split to new track).
List<String> extractArgs(String input, String out, {required SampleRange r}) => trimToArgs(input, out, r: r);

/// Insert [clip] at [position] (paste). When [replace] is given, that range
/// is removed first (paste over a selection).
List<String> insertArgs(
  String input,
  String out, {
  required int total,
  required int position,
  required String clip,
  required int sampleRate,
  required int channels,
  SampleRange? replace,
}) {
  final cut = replace ?? SampleRange(position, position);
  final layout = channels == 1 ? 'mono' : 'stereo';
  final b = StringBuffer('[1:a]aformat=sample_fmts=flt:sample_rates=$sampleRate:channel_layouts=$layout[clip];');
  final labels = <String>[];
  final hasPre = cut.start > 0;
  final hasPost = cut.end < total;
  final n = (hasPre ? 1 : 0) + (hasPost ? 1 : 0);
  if (n == 2) b.write('[0:a]asplit=2[pre_in][post_in];');
  if (hasPre) {
    b.write('${n == 2 ? '[pre_in]' : '[0:a]'}${_trim(null, cut.start)}[pre];');
    labels.add('[pre]');
  }
  labels.add('[clip]');
  if (hasPost) {
    b.write('${n == 2 ? '[post_in]' : '[0:a]'}${_trim(cut.end, null)}[post];');
    labels.add('[post]');
  }
  b.write(labels.length == 1 ? '[clip]anull[out]' : '${labels.join()}concat=n=${labels.length}:v=0:a=1[out]');
  return _cmd([FfmpegInput(input), FfmpegInput(clip)], b.toString(), out);
}

/// Crossfade at [position]: the material before and after overlaps by
/// [frames] (the track gets that much shorter), like Audacity "Crossfade Clips".
List<String> crossfadeArgs(
  String input,
  String out, {
  required int total,
  required int position,
  required int frames,
  required int sampleRate,
}) {
  final d = (frames / sampleRate).toStringAsFixed(6);
  final graph =
      '[0:a]asplit=2[a_in][b_in];[a_in]${_trim(null, position)}[a];[b_in]${_trim(position, null)}[b];'
      '[a][b]acrossfade=d=$d:c1=qsin:c2=qsin[out]';
  return _cmd([FfmpegInput(input)], graph, out);
}

/// Render a generator (lavfi source) into a clip with the track's layout.
List<String> generateArgs(String source, String out, {required int channels}) => FfmpegCommand(
  inputs: [FfmpegInput(source, format: 'lavfi')],
  outputs: [
    FfmpegOutput(out, options: ['-ac', '$channels', ...workCodec]),
  ],
).toArgs();

/// loudnorm measurement of a range (pass 1 of the Loudness effect).
List<String> loudnessMeasureArgs(String input, {SampleRange? r, required double lufs, required double tp}) =>
    FfmpegCommand(
      logLevel: 'info',
      reportProgress: false,
      inputs: [FfmpegInput(input)],
      filterComplex:
          '[0:a]${r == null ? 'anull' : _trim(r.start, r.end)},loudnorm=I=$lufs:TP=$tp:LRA=20:print_format=json[out]',
      outputs: [
        FfmpegOutput('-', maps: ['[out]'], format: 'null'),
      ],
    ).toArgs();

/// EBU R128 analysis (integrated, range, true peak) of a range.
List<String> ebur128Args(String input, {SampleRange? r}) => FfmpegCommand(
  logLevel: 'info',
  reportProgress: false,
  inputs: [FfmpegInput(input)],
  filterComplex: '[0:a]${r == null ? 'anull' : _trim(r.start, r.end)},ebur128=peak=true[out]',
  outputs: [
    FfmpegOutput('-', maps: ['[out]'], format: 'null'),
  ],
).toArgs();

/// Parses the ebur128 summary block.
({double? integrated, double? range, double? truePeak}) parseEbur128Summary(String log) {
  final i = RegExp(r'Summary:[\s\S]*?I:\s+(-?[\d.]+|-inf) LUFS').firstMatch(log);
  final lra = RegExp(r'Summary:[\s\S]*?LRA:\s+([\d.]+) LU').firstMatch(log);
  final tp = RegExp(r'Summary:[\s\S]*?Peak:\s+(-?[\d.]+|-inf) dBFS').firstMatch(log);
  return (
    integrated: double.tryParse(i?.group(1) ?? ''),
    range: double.tryParse(lra?.group(1) ?? ''),
    truePeak: double.tryParse(tp?.group(1) ?? ''),
  );
}

// ------------------------------------------------------------ mixdown

/// Piecewise-linear envelope as an aeval gain expression over `t` (seconds
/// on the track's own timeline).
String envelopeExpr(List<EnvelopePoint> pts) {
  if (pts.isEmpty) return '1';
  final s = [...pts]..sort((a, b) => a.time.compareTo(b.time));
  String f(double v) => v.toStringAsFixed(6);
  var expr = f(s.last.gain);
  for (var i = s.length - 2; i >= 0; i--) {
    final a = s[i];
    final b = s[i + 1];
    final seg = b.time - a.time <= 0
        ? f(b.gain)
        : '(${f(a.gain)}+(${f(b.gain - a.gain)})*(t-${f(a.time)})/${f(b.time - a.time)})';
    expr = 'if(lt(t,${f(b.time)}),$seg,$expr)';
  }
  return 'if(lt(t,${f(s.first.time)}),${f(s.first.gain)},$expr)';
}

/// Mixes the audible tracks: gain, pan, envelope, time offset → stereo
/// (or mono if every track is mono). [range] limits the output to part of
/// the project timeline (play selection / export selection).
List<String> mixArgs(
  AudioProjectState p,
  String out, {
  SampleRange? range,
  List<String> codec = workCodec,
  Map<String, String> metadata = const {},
  bool reportProgress = true,
}) {
  final tracks = p.audible;
  final stereo = tracks.any((t) => t.channels > 1 || t.pan != 0);
  final b = StringBuffer();
  final labels = <String>[];
  for (var i = 0; i < tracks.length; i++) {
    final t = tracks[i];
    final chain = <String>[
      'aformat=sample_fmts=flt',
      if (t.envelope.isNotEmpty) "aeval=exprs='val(ch)*(${envelopeExpr(t.envelope)})':c=same",
      if (t.gainDb != 0) 'volume=${t.gainDb.toStringAsFixed(3)}dB',
      if (stereo)
        t.channels == 1
            // Equal-power pan of a mono track.
            ? 'pan=stereo|c0=${math.cos((t.pan + 1) * math.pi / 4).toStringAsFixed(6)}*c0|c1=${math.sin((t.pan + 1) * math.pi / 4).toStringAsFixed(6)}*c0'
            : 'pan=stereo|c0=${(t.pan > 0 ? 1 - t.pan : 1.0).toStringAsFixed(6)}*c0|c1=${(t.pan < 0 ? 1 + t.pan : 1.0).toStringAsFixed(6)}*c1',
      if (t.offset > 0) 'adelay=delays=${t.offset}S:all=1',
    ];
    b.write('[$i:a]${chain.join(',')}[t$i];');
    labels.add('[t$i]');
  }
  final mix = labels.isEmpty
      ? 'anullsrc=r=${p.sampleRate}:cl=stereo,atrim=end_sample=1'
      : labels.length == 1
      ? '${labels.single}anull'
      : '${labels.join()}amix=inputs=${labels.length}:normalize=0:duration=longest:dropout_transition=0';
  final r = range;
  b.write('$mix${r == null ? '' : ',${_trim(r.start, r.end)}'}[out]');
  return FfmpegCommand(
    reportProgress: reportProgress,
    inputs: [for (final t in tracks) FfmpegInput(t.file)],
    filterComplex: b.toString(),
    outputs: [
      FfmpegOutput(out, maps: ['[out]'], options: codec, metadata: metadata),
    ],
  ).toArgs();
}

/// Quick self-test of an effect chain on 0.3 s of generated stereo audio.
/// Catches filters that are broken in a particular ffmpeg build (e.g.
/// `anlmdn` aborts with heap corruption in some 9.0 builds).
List<String> smokeTestArgs(String chain, {int sampleRate = 48000}) => FfmpegCommand(
  reportProgress: false,
  inputs: [FfmpegInput('anoisesrc=d=0.3:a=0.1:r=$sampleRate,pan=stereo|c0=c0|c1=c0', format: 'lavfi')],
  filterComplex: '[0:a]$chain[out]',
  outputs: [
    FfmpegOutput('-', maps: ['[out]'], format: 'null'),
  ],
).toArgs();
