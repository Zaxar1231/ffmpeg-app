/// Effect catalog of the audio editor — the Audacity effect set, each mapped
/// to an ffmpeg filter chain (options checked with `ffmpeg -h filter=<name>`)
/// or, where ffmpeg has no equivalent, to a Dart DSP routine (dsp.dart).
library;

import 'dart:math' as math;

enum FxCategory { volume, fades, eq, noise, pitchTempo, delayReverb, distortion, special }

enum FxUnit { db, hz, ms, s, percent, ratio, factor, semitones, bpm, none }

/// How an effect is executed.
enum FxKind {
  /// Plain ffmpeg filter chain on the selection.
  filter,

  /// ffmpeg chain that needs values measured on the selection first
  /// ([FxDef.measure]).
  measured,

  /// Implemented in Dart (dsp.dart).
  dsp,

  /// Needs a second track as control signal (Auto Duck).
  sidechain,
}

enum FxMeasure { none, peakDc, loudness }

class FxParam {
  const FxParam(this.id, this.min, this.max, this.def, {this.unit = FxUnit.none, this.step, this.choices});
  final String id;
  final double min;
  final double max;
  final double def;
  final FxUnit unit;

  /// Slider step; null = continuous.
  final double? step;

  /// For enum-like params: value is the index into [choices] (ffmpeg names).
  final List<String>? choices;

  bool get isChoice => choices != null;
  bool get isBool => min == 0 && max == 1 && step == 1 && choices == null;
}

/// Values of an effect run: param id → value.
typedef FxValues = Map<String, double>;

class FxContext {
  const FxContext({
    required this.sampleRate,
    required this.channels,
    required this.frames,
    this.measured = const {},
    this.hasRubberband = true,
  });
  final int sampleRate;
  final int channels;

  /// Length of the processed selection.
  final int frames;

  /// Results of [FxDef.measure] (per channel: `peak0`, `dc0`, …; loudnorm keys).
  final Map<String, String> measured;
  final bool hasRubberband;

  double get seconds => frames / sampleRate;
}

class FxDef {
  const FxDef(
    this.id,
    this.category,
    this.params, {
    this.build,
    this.kind = FxKind.filter,
    this.measure = FxMeasure.none,
    this.filters = const [],
    this.changesLength = false,
    this.stereoOnly = false,
  });

  final String id;
  final FxCategory category;
  final List<FxParam> params;

  /// Filter chain for the selection (no pad labels). Null for DSP effects.
  final String Function(FxValues v, FxContext c)? build;
  final FxKind kind;
  final FxMeasure measure;

  /// ffmpeg filters this effect needs (to mark it unavailable in a build).
  final List<String> filters;
  final bool changesLength;
  final bool stereoOnly;

  FxValues defaults() => {for (final p in params) p.id: p.def};
}

double dbToLin(double db) => math.pow(10, db / 20).toDouble();
String _n(double v, [int digits = 6]) {
  final s = v.toStringAsFixed(digits);
  return s.contains('.') ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '') : s;
}

String _choice(FxDef d, FxValues v, String id) {
  final p = d.params.firstWhere((x) => x.id == id);
  return p.choices![(v[id] ?? p.def).round().clamp(0, p.choices!.length - 1)];
}

const fadeCurves = ['tri', 'qsin', 'hsin', 'esin', 'log', 'ipar', 'qua', 'cub', 'squ', 'cbr', 'par', 'exp'];
const softclipTypes = ['hard', 'tanh', 'atan', 'cubic', 'exp', 'alg', 'quintic', 'sin', 'erf'];

/// Repeated 2-pole sections for steeper slopes: 6 dB/oct = 1 pole,
/// 12 = one biquad, 24 = two, 36 = three, 48 = four.
String _slope(String filter, double f, int slopeIdx) {
  if (slopeIdx == 0) return '$filter=f=${_n(f)}:p=1';
  return List.filled(slopeIdx, '$filter=f=${_n(f)}:p=2').join(',');
}

/// Superequalizer band centers (Hz), from `ffmpeg -h filter=superequalizer`.
const graphicEqBands = [
  65,
  92,
  131,
  185,
  262,
  370,
  523,
  740,
  1047,
  1480,
  2093,
  2960,
  4186,
  5920,
  8372,
  11840,
  16744,
  20000,
];

final List<FxDef> fxCatalog = _catalog();

FxDef fxById(String id) => fxCatalog.firstWhere((f) => f.id == id);

List<FxDef> _catalog() {
  late final List<FxDef> all;
  FxDef self(String id) => all.firstWhere((f) => f.id == id);
  all = [
    // ------------------------------------------------------------ volume
    FxDef(
      'amplify',
      FxCategory.volume,
      const [FxParam('gain', -50, 50, 0, unit: FxUnit.db, step: 0.1)],
      build: (v, c) => 'volume=${_n(v['gain']!)}dB',
      filters: const ['volume'],
    ),
    FxDef(
      'normalize',
      FxCategory.volume,
      const [
        FxParam('peak', -30, 0, -1, unit: FxUnit.db, step: 0.1),
        FxParam('removeDc', 0, 1, 1, step: 1),
        FxParam('independent', 0, 1, 0, step: 1),
      ],
      kind: FxKind.measured,
      measure: FxMeasure.peakDc,
      filters: const ['aeval'],
      build: (v, c) {
        // Per-channel expression: (x − dc) · gain, gain from the measured peak.
        final target = dbToLin(v['peak']!);
        final dcOn = v['removeDc']! > 0.5;
        final indep = v['independent']! > 0.5;
        double peakOf(int ch) {
          final pk = double.parse(c.measured['peak$ch'] ?? '0');
          final dc = dcOn ? double.parse(c.measured['dc$ch'] ?? '0') : 0;
          return pk + dc.abs();
        }

        final all = [for (var ch = 0; ch < c.channels; ch++) peakOf(ch)];
        final common = all.fold<double>(0, math.max);
        final exprs = [
          for (var ch = 0; ch < c.channels; ch++)
            () {
              final pk = indep ? all[ch] : common;
              final g = pk <= 0 ? 1.0 : target / pk;
              final dc = dcOn ? double.parse(c.measured['dc$ch'] ?? '0') : 0.0;
              return '(val($ch)-(${_n(dc, 9)}))*${_n(g, 9)}';
            }(),
        ];
        return "aeval=exprs='${exprs.join('|')}':c=same";
      },
    ),
    FxDef(
      'loudness',
      FxCategory.volume,
      const [
        FxParam('lufs', -40, -5, -23, unit: FxUnit.db, step: 0.5),
        FxParam('truePeak', -9, 0, -1, unit: FxUnit.db, step: 0.1),
      ],
      kind: FxKind.measured,
      measure: FxMeasure.loudness,
      filters: const ['loudnorm'],
      build: (v, c) {
        final m = c.measured;
        return 'loudnorm=I=${_n(v['lufs']!)}:TP=${_n(v['truePeak']!)}:LRA=20'
            ':measured_I=${m['loudnorm.input_i']}:measured_TP=${m['loudnorm.input_tp']}'
            ':measured_LRA=${m['loudnorm.input_lra']}:measured_thresh=${m['loudnorm.input_thresh']}'
            ':offset=${m['loudnorm.target_offset']}:linear=true,aresample=${c.sampleRate}';
      },
    ),
    FxDef(
      'compressor',
      FxCategory.volume,
      const [
        FxParam('threshold', -60, 0, -18, unit: FxUnit.db, step: 0.5),
        FxParam('ratio', 1, 20, 4, unit: FxUnit.ratio, step: 0.1),
        FxParam('attack', 0.01, 2000, 20, unit: FxUnit.ms),
        FxParam('release', 0.01, 9000, 250, unit: FxUnit.ms),
        FxParam('makeup', 0, 36, 0, unit: FxUnit.db, step: 0.5),
        FxParam('knee', 1, 8, 2.83, step: 0.01),
      ],
      filters: const ['acompressor'],
      build: (v, c) =>
          'acompressor=threshold=${_n(dbToLin(v['threshold']!).clamp(0.000976563, 1))}:ratio=${_n(v['ratio']!)}'
          ':attack=${_n(v['attack']!)}:release=${_n(v['release']!)}:makeup=${_n(dbToLin(v['makeup']!).clamp(1, 64))}'
          ':knee=${_n(v['knee']!)}',
    ),
    FxDef(
      'limiter',
      FxCategory.volume,
      const [
        FxParam('limit', -24, 0, -1, unit: FxUnit.db, step: 0.1),
        FxParam('attack', 0.1, 80, 5, unit: FxUnit.ms),
        FxParam('release', 1, 8000, 50, unit: FxUnit.ms),
      ],
      filters: const ['alimiter'],
      // level=0: no automatic make-up (alimiter normalizes by default).
      build: (v, c) =>
          'alimiter=limit=${_n(dbToLin(v['limit']!).clamp(0.0625, 1))}:attack=${_n(v['attack']!)}'
          ':release=${_n(v['release']!)}:level=0',
    ),
    FxDef(
      'gate',
      FxCategory.volume,
      const [
        FxParam('threshold', -80, 0, -40, unit: FxUnit.db, step: 0.5),
        FxParam('reduction', -90, 0, -24, unit: FxUnit.db, step: 0.5),
        FxParam('attack', 0.01, 9000, 10, unit: FxUnit.ms),
        FxParam('release', 0.01, 9000, 100, unit: FxUnit.ms),
      ],
      filters: const ['agate'],
      build: (v, c) =>
          'agate=threshold=${_n(dbToLin(v['threshold']!))}:range=${_n(dbToLin(v['reduction']!))}'
          ':ratio=9000:attack=${_n(v['attack']!)}:release=${_n(v['release']!)}',
    ),
    FxDef(
      'autoDuck',
      FxCategory.volume,
      const [
        FxParam('duck', -40, 0, -12, unit: FxUnit.db, step: 0.5),
        FxParam('threshold', -60, 0, -30, unit: FxUnit.db, step: 0.5),
        FxParam('attack', 0.01, 2000, 50, unit: FxUnit.ms),
        FxParam('release', 0.01, 9000, 500, unit: FxUnit.ms),
      ],
      kind: FxKind.sidechain,
      filters: const ['sidechaincompress'],
      // Ratio chosen so that a control signal well above the threshold
      // reduces the music by roughly the requested amount.
      build: (v, c) {
        final ratio = (1 / (1 - (v['duck']!.abs() / 40).clamp(0.0, 0.95))).clamp(1.0, 20.0);
        return 'sidechaincompress=threshold=${_n(dbToLin(v['threshold']!).clamp(0.000976563, 1))}'
            ':ratio=${_n(ratio)}:attack=${_n(v['attack']!)}:release=${_n(v['release']!)}';
      },
    ),
    FxDef(
      'dynamicNormalizer',
      FxCategory.volume,
      const [
        FxParam('frame', 10, 8000, 500, unit: FxUnit.ms),
        FxParam('gauss', 3, 301, 31, step: 2),
        FxParam('peakLin', 0.1, 1, 0.95, step: 0.01),
        FxParam('maxGain', 1, 100, 10, unit: FxUnit.factor, step: 0.5),
      ],
      filters: const ['dynaudnorm'],
      build: (v, c) =>
          'dynaudnorm=f=${v['frame']!.round()}:g=${v['gauss']!.round() | 1}:p=${_n(v['peakLin']!)}:m=${_n(v['maxGain']!)}',
    ),
    FxDef(
      'speechNormalizer',
      FxCategory.volume,
      const [
        FxParam('peakLin', 0.1, 1, 0.95, step: 0.01),
        FxParam('expansion', 1, 50, 2, unit: FxUnit.factor, step: 0.5),
        FxParam('compression', 1, 50, 2, unit: FxUnit.factor, step: 0.5),
      ],
      filters: const ['speechnorm'],
      build: (v, c) => 'speechnorm=p=${_n(v['peakLin']!)}:e=${_n(v['expansion']!)}:c=${_n(v['compression']!)}',
    ),
    // ------------------------------------------------------------ fades
    FxDef(
      'fadeIn',
      FxCategory.fades,
      const [FxParam('curve', 0, 11, 0, choices: fadeCurves)],
      filters: const ['afade'],
      build: (v, c) => 'afade=t=in:ss=0:ns=${c.frames}:curve=${_choice(self('fadeIn'), v, 'curve')}',
    ),
    FxDef(
      'fadeOut',
      FxCategory.fades,
      const [FxParam('curve', 0, 11, 0, choices: fadeCurves)],
      filters: const ['afade'],
      build: (v, c) => 'afade=t=out:ss=0:ns=${c.frames}:curve=${_choice(self('fadeOut'), v, 'curve')}',
    ),
    FxDef(
      'studioFadeOut',
      FxCategory.fades,
      const [],
      filters: const ['afade'],
      build: (v, c) => 'afade=t=out:ss=0:ns=${c.frames}:curve=esin',
    ),
    FxDef(
      'adjustableFade',
      FxCategory.fades,
      const [
        FxParam('from', 0, 200, 100, unit: FxUnit.percent),
        FxParam('to', 0, 200, 0, unit: FxUnit.percent),
        FxParam('shape', 0, 1, 0, choices: ['linear', 'db']),
      ],
      filters: const ['aeval'],
      // Per-sample gain ramp over the selection (t restarts at 0).
      build: (v, c) {
        final a = v['from']! / 100;
        final b = v['to']! / 100;
        final d = _n(c.seconds, 9);
        if (v['shape']!.round() == 1) {
          final da = 20 * math.log(math.max(a, 1e-5)) / math.ln10;
          final db = 20 * math.log(math.max(b, 1e-5)) / math.ln10;
          return "aeval=exprs='val(ch)*pow(10,(${_n(da)}+(${_n(db - da)})*min(t/$d,1))/20)':c=same";
        }
        return "aeval=exprs='val(ch)*(${_n(a)}+(${_n(b - a)})*min(t/$d,1))':c=same";
      },
    ),
    // ------------------------------------------------------------ EQ & filters
    FxDef(
      'bassTreble',
      FxCategory.eq,
      const [
        FxParam('bass', -30, 30, 0, unit: FxUnit.db, step: 0.5),
        FxParam('treble', -30, 30, 0, unit: FxUnit.db, step: 0.5),
        FxParam('gain', -30, 30, 0, unit: FxUnit.db, step: 0.5),
      ],
      filters: const ['bass', 'treble'],
      build: (v, c) => 'bass=g=${_n(v['bass']!)},treble=g=${_n(v['treble']!)},volume=${_n(v['gain']!)}dB',
    ),
    FxDef(
      'graphicEq',
      FxCategory.eq,
      [for (var i = 0; i < 18; i++) FxParam('b$i', -20, 20, 0, unit: FxUnit.db, step: 0.5)],
      filters: const ['superequalizer'],
      build: (v, c) =>
          'superequalizer=${[for (var i = 0; i < 18; i++) '${i + 1}b=${_n(dbToLin(v['b$i']!).clamp(0, 20), 4)}'].join(':')}',
    ),
    FxDef(
      'parametricEq',
      FxCategory.eq,
      [
        for (var i = 0; i < 4; i++) ...[
          FxParam('f$i', 20, 20000, const [100.0, 500.0, 2000.0, 8000.0][i], unit: FxUnit.hz),
          FxParam('g$i', -24, 24, 0, unit: FxUnit.db, step: 0.5),
          FxParam('q$i', 0.1, 10, 1, step: 0.05),
        ],
      ],
      filters: const ['equalizer'],
      build: (v, c) => [
        for (var i = 0; i < 4; i++)
          if (v['g$i']!.abs() > 0.01) 'equalizer=f=${_n(v['f$i']!)}:t=q:w=${_n(v['q$i']!)}:g=${_n(v['g$i']!)}',
      ].join(',').let((s) => s.isEmpty ? 'anull' : s),
    ),
    FxDef(
      'highPass',
      FxCategory.eq,
      const [
        FxParam('freq', 10, 20000, 100, unit: FxUnit.hz),
        FxParam('slope', 0, 4, 1, choices: ['6', '12', '24', '36', '48']),
      ],
      filters: const ['highpass'],
      build: (v, c) => _slope('highpass', v['freq']!, v['slope']!.round()),
    ),
    FxDef(
      'lowPass',
      FxCategory.eq,
      const [
        FxParam('freq', 10, 20000, 8000, unit: FxUnit.hz),
        FxParam('slope', 0, 4, 1, choices: ['6', '12', '24', '36', '48']),
      ],
      filters: const ['lowpass'],
      build: (v, c) => _slope('lowpass', v['freq']!, v['slope']!.round()),
    ),
    FxDef(
      'bandPass',
      FxCategory.eq,
      const [FxParam('freq', 20, 20000, 1000, unit: FxUnit.hz), FxParam('octaves', 0.1, 6, 1, step: 0.1)],
      filters: const ['bandpass'],
      build: (v, c) => 'bandpass=f=${_n(v['freq']!)}:t=o:w=${_n(v['octaves']!)}',
    ),
    FxDef(
      'notch',
      FxCategory.eq,
      const [FxParam('freq', 10, 20000, 60, unit: FxUnit.hz), FxParam('q', 0.1, 30, 1, step: 0.1)],
      filters: const ['bandreject'],
      build: (v, c) => 'bandreject=f=${_n(v['freq']!)}:t=q:w=${_n(v['q']!)}',
    ),
    FxDef(
      'humRemoval',
      FxCategory.eq,
      const [
        FxParam('mains', 0, 1, 0, choices: ['50', '60']),
        FxParam('harmonics', 1, 10, 5, step: 1),
        FxParam('q', 1, 50, 10, step: 0.5),
      ],
      filters: const ['bandreject'],
      build: (v, c) {
        final f0 = v['mains']!.round() == 0 ? 50 : 60;
        final nyq = c.sampleRate / 2;
        return [
          for (var k = 1; k <= v['harmonics']!.round(); k++)
            if (f0 * k < nyq) 'bandreject=f=${f0 * k}:t=q:w=${_n(v['q']!)}',
        ].join(',');
      },
    ),
    FxDef(
      'deesser',
      FxCategory.eq,
      const [
        FxParam('intensity', 0, 1, 0.5, step: 0.01),
        FxParam('maxReduction', 0, 1, 0.5, step: 0.01),
        FxParam('freqPos', 0, 1, 0.5, step: 0.01),
      ],
      filters: const ['deesser'],
      build: (v, c) => 'deesser=i=${_n(v['intensity']!)}:m=${_n(v['maxReduction']!)}:f=${_n(v['freqPos']!)}',
    ),
    FxDef(
      'exciter',
      FxCategory.eq,
      const [
        FxParam('amount', 0, 10, 1, step: 0.1),
        FxParam('drive', 0.1, 10, 8.5, step: 0.1),
        FxParam('freq', 2000, 12000, 7500, unit: FxUnit.hz),
      ],
      filters: const ['aexciter'],
      build: (v, c) => 'aexciter=amount=${_n(v['amount']!)}:drive=${_n(v['drive']!)}:freq=${_n(v['freq']!)}',
    ),
    // ------------------------------------------------------------ noise & repair
    FxDef(
      'noiseReduction',
      FxCategory.noise,
      const [
        FxParam('reduction', 1, 97, 12, unit: FxUnit.db, step: 1),
        FxParam('floor', -80, -20, -50, unit: FxUnit.db, step: 1),
        FxParam('track', 0, 1, 0, step: 1),
      ],
      filters: const ['afftdn'],
      // With a noise profile the controller prepends the profile and drives
      // `sample_noise` via asendcmd (see render.dart).
      build: (v, c) => 'afftdn=nr=${_n(v['reduction']!)}:nf=${_n(v['floor']!)}${v['track']! > 0.5 ? ':tn=1' : ''}',
    ),
    FxDef(
      'nlmDenoise',
      FxCategory.noise,
      const [FxParam('strength', 0, 100, 30, unit: FxUnit.percent)],
      filters: const ['anlmdn'],
      // anlmdn strength is exponential in practice: 1e-5 … 1e-1.
      build: (v, c) => 'anlmdn=s=${_n(math.pow(10, -5 + 4 * v['strength']! / 100).toDouble(), 7)}',
    ),
    FxDef(
      'clickRemoval',
      FxCategory.noise,
      const [FxParam('threshold', 1, 100, 2, step: 0.5), FxParam('window', 10, 100, 55, unit: FxUnit.ms)],
      filters: const ['adeclick'],
      build: (v, c) => 'adeclick=t=${_n(v['threshold']!)}:w=${_n(v['window']!)}',
    ),
    FxDef(
      'clipFix',
      FxCategory.noise,
      const [FxParam('threshold', 1, 100, 10, step: 0.5)],
      filters: const ['adeclip'],
      build: (v, c) => 'adeclip=t=${_n(v['threshold']!)}',
    ),
    // ------------------------------------------------------------ pitch & tempo
    FxDef(
      'changePitch',
      FxCategory.pitchTempo,
      const [
        FxParam('semitones', -24, 24, 0, unit: FxUnit.semitones, step: 0.01),
        FxParam('formants', 0, 1, 0, step: 1),
        FxParam('hq', 0, 1, 1, step: 1),
      ],
      filters: const ['aresample'],
      build: (v, c) {
        final f = math.pow(2, v['semitones']! / 12).toDouble();
        if (c.hasRubberband) {
          return 'rubberband=pitch=${_n(f, 9)}:formant=${v['formants']! > 0.5 ? 'preserved' : 'shifted'}'
              ':pitchq=${v['hq']! > 0.5 ? 'quality' : 'speed'}';
        }
        // Fallback: resample (pitch+speed) then restore tempo.
        return 'asetrate=${_n(c.sampleRate * f)},aresample=${c.sampleRate},atempo=${_n(1 / f, 9)}';
      },
    ),
    FxDef(
      'changeTempo',
      FxCategory.pitchTempo,
      const [FxParam('percent', -90, 400, 0, unit: FxUnit.percent, step: 0.1)],
      changesLength: true,
      filters: const ['atempo'],
      build: (v, c) {
        final f = 1 + v['percent']! / 100;
        return c.hasRubberband ? 'rubberband=tempo=${_n(f, 9)}' : 'atempo=${_n(f, 9)}';
      },
    ),
    FxDef(
      'changeSpeed',
      FxCategory.pitchTempo,
      const [FxParam('percent', -90, 400, 0, unit: FxUnit.percent, step: 0.1)],
      changesLength: true,
      filters: const ['asetrate', 'aresample'],
      build: (v, c) => 'asetrate=${_n(c.sampleRate * (1 + v['percent']! / 100), 3)},aresample=${c.sampleRate}',
    ),
    const FxDef(
      'slidingSpeed',
      FxCategory.pitchTempo,
      [
        FxParam('from', -90, 400, 0, unit: FxUnit.percent, step: 1),
        FxParam('to', -90, 400, 50, unit: FxUnit.percent, step: 1),
      ],
      kind: FxKind.dsp,
      changesLength: true,
    ),
    const FxDef(
      'paulstretch',
      FxCategory.pitchTempo,
      [
        FxParam('stretch', 1, 100, 10, unit: FxUnit.factor, step: 0.5),
        FxParam('window', 0.05, 2, 0.25, unit: FxUnit.s, step: 0.01),
      ],
      kind: FxKind.dsp,
      changesLength: true,
    ),
    // ------------------------------------------------------------ delay & reverb
    FxDef(
      'echo',
      FxCategory.delayReverb,
      const [FxParam('delay', 1, 5000, 400, unit: FxUnit.ms), FxParam('decay', 0.01, 0.95, 0.5, step: 0.01)],
      filters: const ['aecho'],
      // Repeats until they fall below −60 dB (max 30 taps), like a feedback echo.
      build: (v, c) {
        final d = v['delay']!;
        final k = v['decay']!;
        final taps = math.min(30, (math.log(0.001) / math.log(k)).ceil());
        final delays = [for (var i = 1; i <= taps; i++) _n(d * i, 2)].join('|');
        final decays = [for (var i = 1; i <= taps; i++) _n(math.pow(k, i).toDouble(), 6)].join('|');
        return 'aecho=in_gain=1:out_gain=1:delays=$delays:decays=$decays';
      },
    ),
    FxDef(
      'reverb',
      FxCategory.delayReverb,
      const [
        FxParam('time', 0.1, 10, 1.5, unit: FxUnit.s, step: 0.05),
        FxParam('predelay', 0, 200, 10, unit: FxUnit.ms),
        FxParam('damping', 0, 100, 50, unit: FxUnit.percent),
        FxParam('wet', -40, 6, -6, unit: FxUnit.db, step: 0.5),
        FxParam('dry', -40, 6, 0, unit: FxUnit.db, step: 0.5),
      ],
      filters: const ['afir', 'anoisesrc'],
      // Convolution with a synthetic impulse: exponentially decaying noise,
      // darker with more damping. The IR is generated inside the graph
      // and connected by render.dart as `[ir]`.
      build: (v, c) => 'afir=dry=${_n(dbToLin(v['dry']!).clamp(0, 10))}:wet=${_n(dbToLin(v['wet']!).clamp(0, 10))}',
    ),
    // ------------------------------------------------------------ distortion & modulation
    FxDef(
      'distortion',
      FxCategory.distortion,
      const [
        FxParam('type', 0, 8, 1, choices: softclipTypes),
        FxParam('drive', 0, 48, 12, unit: FxUnit.db, step: 0.5),
        FxParam('output', -48, 0, -6, unit: FxUnit.db, step: 0.5),
      ],
      filters: const ['asoftclip'],
      build: (v, c) =>
          'volume=${_n(v['drive']!)}dB,asoftclip=type=${_choice(self('distortion'), v, 'type')},volume=${_n(v['output']!)}dB',
    ),
    FxDef(
      'bitcrusher',
      FxCategory.distortion,
      const [
        FxParam('bits', 1, 24, 8, step: 1),
        FxParam('downsample', 1, 250, 1, unit: FxUnit.factor, step: 1),
        FxParam('mix', 0, 100, 100, unit: FxUnit.percent),
      ],
      filters: const ['acrusher'],
      build: (v, c) =>
          'acrusher=bits=${v['bits']!.round()}:samples=${v['downsample']!.round()}:mix=${_n(v['mix']! / 100)}',
    ),
    FxDef(
      'phaser',
      FxCategory.distortion,
      const [
        FxParam('speed', 0.1, 2, 0.5, unit: FxUnit.hz, step: 0.05),
        FxParam('decay', 0, 0.99, 0.4, step: 0.01),
        FxParam('delay', 0, 5, 3, unit: FxUnit.ms, step: 0.1),
      ],
      filters: const ['aphaser'],
      build: (v, c) => 'aphaser=speed=${_n(v['speed']!)}:decay=${_n(v['decay']!)}:delay=${_n(v['delay']!)}',
    ),
    FxDef(
      'flanger',
      FxCategory.distortion,
      const [
        FxParam('delay', 0, 30, 0, unit: FxUnit.ms, step: 0.1),
        FxParam('depth', 0, 10, 2, unit: FxUnit.ms, step: 0.1),
        FxParam('regen', -95, 95, 0, unit: FxUnit.percent),
        FxParam('speed', 0.1, 10, 0.5, unit: FxUnit.hz, step: 0.1),
      ],
      filters: const ['flanger'],
      build: (v, c) =>
          'flanger=delay=${_n(v['delay']!)}:depth=${_n(v['depth']!)}:regen=${_n(v['regen']!)}:speed=${_n(v['speed']!)}',
    ),
    FxDef(
      'chorus',
      FxCategory.distortion,
      const [
        FxParam('delay', 20, 100, 50, unit: FxUnit.ms),
        FxParam('decay', 0.05, 1, 0.4, step: 0.01),
        FxParam('speed', 0.05, 5, 0.25, unit: FxUnit.hz, step: 0.05),
        FxParam('depth', 0.1, 10, 2, unit: FxUnit.ms, step: 0.1),
      ],
      filters: const ['chorus'],
      build: (v, c) =>
          'chorus=in_gain=0.7:out_gain=0.9:delays=${_n(v['delay']!)}:decays=${_n(v['decay']!)}'
          ':speeds=${_n(v['speed']!)}:depths=${_n(v['depth']!)}',
    ),
    FxDef(
      'tremolo',
      FxCategory.distortion,
      const [
        FxParam('freq', 0.1, 40, 5, unit: FxUnit.hz, step: 0.1),
        FxParam('depth', 0, 100, 50, unit: FxUnit.percent),
      ],
      filters: const ['tremolo'],
      build: (v, c) => 'tremolo=f=${_n(v['freq']!)}:d=${_n(v['depth']! / 100)}',
    ),
    FxDef(
      'vibrato',
      FxCategory.distortion,
      const [
        FxParam('freq', 0.1, 20, 5, unit: FxUnit.hz, step: 0.1),
        FxParam('depth', 0, 100, 50, unit: FxUnit.percent),
      ],
      filters: const ['vibrato'],
      build: (v, c) => 'vibrato=f=${_n(v['freq']!)}:d=${_n(v['depth']! / 100)}',
    ),
    const FxDef('wahwah', FxCategory.distortion, [
      FxParam('freq', 0.1, 4, 1.5, unit: FxUnit.hz, step: 0.05),
      FxParam('depth', 0, 100, 70, unit: FxUnit.percent),
      FxParam('resonance', 0.1, 10, 2.5, step: 0.1),
      FxParam('offset', 0, 100, 30, unit: FxUnit.percent),
    ], kind: FxKind.dsp),
    FxDef(
      'autoPan',
      FxCategory.distortion,
      const [
        FxParam('freq', 0.01, 20, 0.5, unit: FxUnit.hz, step: 0.01),
        FxParam('amount', 0, 100, 100, unit: FxUnit.percent),
      ],
      stereoOnly: true,
      filters: const ['apulsator'],
      build: (v, c) => 'apulsator=hz=${_n(v['freq']!)}:amount=${_n(v['amount']! / 100)}',
    ),
    // ------------------------------------------------------------ special
    FxDef(
      'invert',
      FxCategory.special,
      const [],
      filters: const ['aeval'],
      build: (v, c) => "aeval=exprs='-val(ch)':c=same",
    ),
    FxDef('reverse', FxCategory.special, const [], filters: const ['areverse'], build: (v, c) => 'areverse'),
    FxDef(
      'repeat',
      FxCategory.special,
      const [FxParam('times', 1, 100, 1, step: 1)],
      changesLength: true,
      filters: const ['aloop'],
      build: (v, c) => 'aloop=loop=${v['times']!.round()}:size=${c.frames}',
    ),
    FxDef(
      'truncateSilence',
      FxCategory.special,
      const [
        FxParam('threshold', -80, -20, -50, unit: FxUnit.db, step: 1),
        FxParam('minSilence', 0.01, 10, 0.5, unit: FxUnit.s, step: 0.01),
        FxParam('keep', 0, 10, 0.3, unit: FxUnit.s, step: 0.01),
      ],
      changesLength: true,
      filters: const ['silenceremove'],
      build: (v, c) =>
          'silenceremove=stop_periods=-1:stop_duration=${_n(v['minSilence']!)}'
          ':stop_threshold=${_n(v['threshold']!)}dB:stop_silence=${_n(v['keep']!)}',
    ),
    FxDef(
      'vocalRemove',
      FxCategory.special,
      const [FxParam('keepBass', 20, 500, 150, unit: FxUnit.hz)],
      stereoOnly: true,
      filters: const ['pan', 'asplit', 'amix'],
      // Side signal (L−R) removes the centre; bass below the cutoff is kept
      // from the original (vocals rarely live there, the kick and bass do).
      build: (v, c) =>
          'asplit[vr_a][vr_b];[vr_a]pan=stereo|c0=0.5*c0-0.5*c1|c1=0.5*c1-0.5*c0,highpass=f=${_n(v['keepBass']!)}[vr_s];'
          '[vr_b]lowpass=f=${_n(v['keepBass']!)}[vr_l];[vr_s][vr_l]amix=inputs=2:normalize=0',
    ),
    FxDef(
      'vocalIsolate',
      FxCategory.special,
      const [FxParam('low', 50, 1000, 120, unit: FxUnit.hz), FxParam('high', 1000, 16000, 8000, unit: FxUnit.hz)],
      stereoOnly: true,
      filters: const ['pan'],
      build: (v, c) =>
          'pan=stereo|c0=0.5*c0+0.5*c1|c1=0.5*c0+0.5*c1,highpass=f=${_n(v['low']!)},lowpass=f=${_n(v['high']!)}',
    ),
    FxDef(
      'swapChannels',
      FxCategory.special,
      const [],
      stereoOnly: true,
      filters: const ['pan'],
      build: (v, c) => 'pan=stereo|c0=c1|c1=c0',
    ),
    FxDef(
      'monoMix',
      FxCategory.special,
      const [],
      stereoOnly: true,
      filters: const ['pan'],
      build: (v, c) => 'pan=stereo|c0=0.5*c0+0.5*c1|c1=0.5*c0+0.5*c1',
    ),
    FxDef(
      'stereoWiden',
      FxCategory.special,
      const [FxParam('amount', 0, 10, 2.5, unit: FxUnit.factor, step: 0.1)],
      stereoOnly: true,
      filters: const ['extrastereo'],
      build: (v, c) => 'extrastereo=m=${_n(v['amount']!)}',
    ),
    FxDef(
      'balance',
      FxCategory.special,
      const [FxParam('balance', -100, 100, 0, unit: FxUnit.percent)],
      stereoOnly: true,
      filters: const ['pan'],
      build: (v, c) {
        final b = v['balance']! / 100;
        final l = b > 0 ? 1 - b : 1.0;
        final r = b < 0 ? 1 + b : 1.0;
        return 'pan=stereo|c0=${_n(l)}*c0|c1=${_n(r)}*c1';
      },
    ),
    FxDef(
      'haas',
      FxCategory.special,
      const [FxParam('delay', 0, 40, 15, unit: FxUnit.ms, step: 0.5)],
      filters: const ['haas'],
      build: (v, c) => 'haas=left_delay=0:right_delay=${_n(v['delay']!)}',
    ),
  ];
  return all;
}

/// Synthetic reverb impulse for [fxById('reverb')] (a lavfi source chain).
String reverbImpulse(FxValues v, int sampleRate) {
  final t = v['time']!;
  final damp = v['damping']! / 100;
  final cutoff = 20000 - damp * 17000; // 20 kHz … 3 kHz
  final pre = v['predelay']!;
  return 'anoisesrc=d=${_n(t)}:c=white:r=$sampleRate:a=0.5:seed=7,'
      'afade=t=out:st=0:d=${_n(t)}:curve=exp,lowpass=f=${_n(cutoff)}'
      '${pre > 0 ? ',adelay=delays=${_n(pre)}:all=1' : ''}';
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
