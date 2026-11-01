/// Analysis tools (stage 3): loudness meter, waveform/spectrum pictures,
/// detectors and quality metrics. Builders return ffmpeg arguments, parsers
/// read the filters' log output (formats checked on ffmpeg 6.1 and 9.0).
library;

import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../edit/graphs.dart' show displaySize, even, fnum, secs;

// ================================================================ loudness

/// One `framelog` line of ebur128 (every 100 ms).
class LoudnessPoint {
  const LoudnessPoint(this.t, this.momentary, this.shortTerm);
  final double t;
  final double momentary;
  final double shortTerm;
}

class LoudnessReport {
  const LoudnessReport({required this.points, this.integrated, this.range, this.truePeak, this.lraLow, this.lraHigh});
  final List<LoudnessPoint> points;
  final double? integrated;
  final double? range;
  final double? truePeak;
  final double? lraLow;
  final double? lraHigh;

  double? get maxMomentary => _max(points.map((p) => p.momentary));
  double? get maxShortTerm => _max(points.map((p) => p.shortTerm));

  static double? _max(Iterable<double> v) {
    final f = v.where((x) => x > -70).toList();
    return f.isEmpty ? null : f.reduce((a, b) => a > b ? a : b);
  }
}

/// `ffmpeg -i in -map 0:a:N -af ebur128=peak=true:framelog=info -f null -`
List<String> loudnessArgs(String path, {int stream = 0}) => FfmpegCommand(
  logLevel: 'info',
  inputs: [FfmpegInput(path)],
  outputs: [
    FfmpegOutput('-', maps: ['0:a:$stream'], audioFilters: ['ebur128=peak=true:framelog=info'], format: 'null'),
  ],
).toArgs();

final _frameRe = RegExp(r't:\s*([\d.]+)\s+TARGET:.*?M:\s*(-?[\d.]+|-?inf|nan)\s+S:\s*(-?[\d.]+|-?inf|nan)');

/// `-inf`/`nan` (silence) count as −120 dB.
double _db(String s) {
  final v = double.tryParse(s);
  return v == null || !v.isFinite ? -120 : v;
}

LoudnessReport parseLoudness(List<String> log) {
  final pts = <LoudnessPoint>[];
  for (final l in log) {
    final m = _frameRe.firstMatch(l);
    if (m != null) pts.add(LoudnessPoint(double.parse(m[1]!), _db(m[2]!), _db(m[3]!)));
  }
  final text = log.join('\n');
  final s = text.lastIndexOf('Summary:');
  final sum = s < 0 ? '' : text.substring(s);
  double? val(String re) {
    final m = RegExp(re).firstMatch(sum);
    final v = m?.group(1);
    return v == null || v == '-inf' ? null : double.tryParse(v);
  }

  return LoudnessReport(
    points: pts,
    integrated: val(r'I:\s+(-?[\d.]+|-inf) LUFS'),
    range: val(r'LRA:\s+([\d.]+) LU'),
    truePeak: val(r'Peak:\s+(-?[\d.]+|-inf) dBFS'),
    lraLow: val(r'LRA low:\s+(-?[\d.]+|-inf) LUFS'),
    lraHigh: val(r'LRA high:\s+(-?[\d.]+|-inf) LUFS'),
  );
}

/// Loudness targets of popular platforms (integrated LUFS, max true peak).
const loudnessTargets = <(String, double, double)>[
  ('YouTube', -14, -1),
  ('Spotify', -14, -1),
  ('Apple Music', -16, -1),
  ('Podcast', -16, -1),
  ('EBU R128', -23, -1),
  ('ATSC A/85', -24, -2),
];

// ============================================================ waveform pic

enum PicKind { waveform, spectrogram }

enum WaveScale { lin, log, sqrt, cbrt }

enum SpectrumColor { intensity, rainbow, magma, viridis, fire, cool, green }

class PicParams {
  const PicParams({
    this.kind = PicKind.waveform,
    this.width = 1920,
    this.height = 480,
    this.splitChannels = false,
    this.color = '0x4FC3F7',
    this.waveScale = WaveScale.lin,
    this.spectrumColor = SpectrumColor.intensity,
    this.logFrequency = false,
    this.legend = true,
  });
  final PicKind kind;
  final int width;
  final int height;
  final bool splitChannels;
  final String color;
  final WaveScale waveScale;
  final SpectrumColor spectrumColor;
  final bool logFrequency;
  final bool legend;
}

/// showwavespic / showspectrumpic of the whole file into one PNG.
List<String> picArgs(String path, String output, PicParams p, {int stream = 0}) {
  final size = '${p.width}x${p.height}';
  final filter = switch (p.kind) {
    PicKind.waveform =>
      'showwavespic=s=$size:split_channels=${p.splitChannels ? 1 : 0}:'
          'colors=${p.color}:scale=${p.waveScale.name}',
    PicKind.spectrogram =>
      'showspectrumpic=s=$size:color=${p.spectrumColor.name}:'
          'fscale=${p.logFrequency ? 'log' : 'lin'}:legend=${p.legend ? 1 : 0}'
          '${p.splitChannels ? ':mode=separate' : ':mode=combined'}',
  };
  return FfmpegCommand(
    reportProgress: false,
    inputs: [FfmpegInput(path)],
    filterComplex: '[0:a:$stream]$filter[pic]',
    outputs: [
      FfmpegOutput(output, maps: ['[pic]'], options: ['-frames:v', '1', '-update', '1']),
    ],
  ).toArgs();
}

// =============================================================== detectors

enum DetectKind { silence, black, freeze, scenes, crop }

class DetectParams {
  const DetectParams({
    this.kind = DetectKind.silence,
    this.silenceDb = -35,
    this.minDuration = 0.5,
    this.blackThreshold = 0.1,
    this.freezeDb = -60,
    this.sceneThreshold = 10,
  });
  final DetectKind kind;
  final double silenceDb;

  /// Minimum length of silence/black/freeze, seconds.
  final double minDuration;

  /// blackdetect pix_th (0–1): how dark a pixel counts as black.
  final double blackThreshold;
  final double freezeDb;

  /// scdet threshold (0–100).
  final double sceneThreshold;

  bool get isAudio => kind == DetectKind.silence;
}

/// One finding: an interval, or a point (scene cut) when [end] is null.
class Finding {
  const Finding(this.start, [this.end, this.score]);
  final Duration start;
  final Duration? end;
  final double? score;
  Duration? get length => end == null ? null : end! - start;
}

List<String> detectArgs(String path, DetectParams p) {
  final d = fnum(p.minDuration);
  final (filter, isAudio) = switch (p.kind) {
    DetectKind.silence => ('silencedetect=n=${fnum(p.silenceDb, 1)}dB:d=$d', true),
    DetectKind.black => ('blackdetect=d=$d:pix_th=${fnum(p.blackThreshold, 2)}', false),
    DetectKind.freeze => ('freezedetect=n=${fnum(p.freezeDb, 1)}dB:d=$d', false),
    DetectKind.scenes => ('scdet=t=${fnum(p.sceneThreshold, 1)}', false),
    DetectKind.crop => ('cropdetect=round=2', false),
  };
  return FfmpegCommand(
    logLevel: 'info',
    inputs: [FfmpegInput(path)],
    outputs: [
      FfmpegOutput(
        '-',
        maps: [isAudio ? '0:a:0' : '0:v:0'],
        audioFilters: isAudio ? [filter] : const [],
        videoFilters: isAudio ? const [] : [filter],
        format: 'null',
      ),
    ],
  ).toArgs();
}

Duration _sec(String s) => Duration(microseconds: (double.parse(s) * 1e6).round());

/// Parses detector output; open intervals end at [total].
List<Finding> parseFindings(DetectKind kind, List<String> log, {Duration? total}) {
  final out = <Finding>[];
  switch (kind) {
    case DetectKind.silence:
    case DetectKind.freeze:
      final key = kind == DetectKind.silence ? 'silence' : 'lavfi.freezedetect.freeze';
      final startRe = RegExp('${RegExp.escape(key)}_start: (-?[\\d.]+)');
      final endRe = RegExp('${RegExp.escape(key)}_end: (-?[\\d.]+)');
      Duration? open;
      for (final l in log) {
        final s = startRe.firstMatch(l);
        if (s != null) {
          final v = _sec(s[1]!);
          open = v < Duration.zero ? Duration.zero : v;
        }
        final e = endRe.firstMatch(l);
        if (e != null && open != null) {
          out.add(Finding(open, _sec(e[1]!)));
          open = null;
        }
      }
      if (open != null) out.add(Finding(open, total ?? open));
    case DetectKind.black:
      final re = RegExp(r'black_start:\s*([\d.]+)\s+black_end:\s*([\d.]+)');
      for (final l in log) {
        final m = re.firstMatch(l);
        if (m != null) out.add(Finding(_sec(m[1]!), _sec(m[2]!)));
      }
    case DetectKind.scenes:
      final re = RegExp(r'lavfi\.scd\.score:\s*([\d.]+),\s*lavfi\.scd\.time:\s*([\d.]+)');
      for (final l in log) {
        final m = re.firstMatch(l);
        if (m != null) out.add(Finding(_sec(m[2]!), null, double.parse(m[1]!)));
      }
    case DetectKind.crop:
      break;
  }
  return out;
}

/// Findings as CSV (`start;end;length` in seconds).
String findingsCsv(List<Finding> f) => [
  'start;end;duration;score',
  for (final x in f)
    '${secs(x.start)};${x.end == null ? '' : secs(x.end!)};${x.length == null ? '' : secs(x.length!)};'
        '${x.score == null ? '' : fnum(x.score!, 2)}',
].join('\n');

// ================================================================ quality

class QualityReport {
  const QualityReport({this.vmaf, this.psnr, this.psnrMin, this.ssim, this.ssimDb});
  final double? vmaf;
  final double? psnr;
  final double? psnrMin;
  final double? ssim;
  final double? ssimDb;
}

/// Compares [distorted] with [reference]: the distorted video is scaled to
/// the reference size; PSNR, SSIM and (when available) VMAF in one pass.
List<String> qualityArgs({
  required MediaInfo reference,
  required MediaInfo distorted,
  bool vmaf = true,
  int threads = 4,
}) {
  final (w, h) = displaySize(reference);
  final n = vmaf ? 3 : 2;
  final d = ['d1', 'd2', if (vmaf) 'd3'].map((s) => '[$s]').join();
  final r = ['r1', 'r2', if (vmaf) 'r3'].map((s) => '[$s]').join();
  final graph = [
    '[0:v:0]scale=${even(w)}:${even(h)}:flags=bicubic,setpts=PTS-STARTPTS,split=$n$d',
    '[1:v:0]scale=${even(w)}:${even(h)}:flags=bicubic,setpts=PTS-STARTPTS,split=$n$r',
    '[d1][r1]psnr=shortest=1[o1]',
    '[d2][r2]ssim=shortest=1[o2]',
    if (vmaf) '[d3][r3]libvmaf=n_threads=$threads:shortest=1[o3]',
  ].join(';');
  return FfmpegCommand(
    logLevel: 'info',
    inputs: [FfmpegInput(distorted.path), FfmpegInput(reference.path)],
    filterComplex: graph,
    outputs: [
      for (var i = 1; i <= n; i++) FfmpegOutput('-', maps: ['[o$i]'], format: 'null'),
    ],
  ).toArgs();
}

QualityReport parseQuality(List<String> log) {
  double? find(RegExp re) {
    for (final l in log.reversed) {
      final m = re.firstMatch(l);
      if (m != null) return double.tryParse(m[1]!);
    }
    return null;
  }

  return QualityReport(
    vmaf: find(RegExp(r'VMAF score:\s*([\d.]+)')),
    psnr: find(RegExp(r'PSNR y:.*average:([\d.]+|inf)')),
    psnrMin: find(RegExp(r'PSNR y:.*min:([\d.]+|inf)')),
    ssim: find(RegExp(r'SSIM Y:.*All:([\d.]+)')),
    ssimDb: find(RegExp(r'SSIM Y:.*All:[\d.]+ \(([\d.]+|inf)\)')),
  );
}
