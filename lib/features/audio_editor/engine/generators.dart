/// Generators (Audacity "Generate" menu) as ffmpeg lavfi sources.
library;

import 'dart:math' as math;

import 'effects.dart';

String _n(double v) {
  final s = v.toStringAsFixed(6);
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

const waveforms = ['sine', 'square', 'sawtooth', 'triangle'];
const noiseColors = ['white', 'pink', 'brown', 'blue', 'violet', 'velvet'];

/// Phase expression (cycles) → waveform expression in [-1, 1].
String _wave(int shape, String cycles) => switch (shape) {
  1 => '(2*lt(mod($cycles,1),0.5)-1)',
  2 => '(2*mod($cycles,1)-1)',
  3 => '(4*abs(mod($cycles,1)-0.5)-1)',
  _ => 'sin(2*PI*($cycles))',
};

class GenDef {
  const GenDef(this.id, this.params, this.source);
  final String id;
  final List<FxParam> params;

  /// lavfi source description for [seconds] at [sampleRate].
  final String Function(FxValues v, int sampleRate, double seconds) source;

  FxValues defaults() => {for (final p in params) p.id: p.def};
}

/// DTMF frequency pairs (low, high).
const dtmfFreqs = <String, (int, int)>{
  '1': (697, 1209), '2': (697, 1336), '3': (697, 1477), 'A': (697, 1633), //
  '4': (770, 1209), '5': (770, 1336), '6': (770, 1477), 'B': (770, 1633),
  '7': (852, 1209), '8': (852, 1336), '9': (852, 1477), 'C': (852, 1633),
  '*': (941, 1209), '0': (941, 1336), '#': (941, 1477), 'D': (941, 1633),
};

/// DTMF expression: each tone occupies `duty` of its slot.
String dtmfExpr(String digits, double seconds, double duty, double amp) {
  final valid = digits.toUpperCase().split('').where(dtmfFreqs.containsKey).toList();
  if (valid.isEmpty) return '0';
  final slot = seconds / valid.length;
  final parts = <String>[];
  for (var i = 0; i < valid.length; i++) {
    final (lo, hi) = dtmfFreqs[valid[i]]!;
    final s = i * slot;
    final e = s + slot * duty;
    parts.add('between(t,${_n(s)},${_n(e)})*(sin(2*PI*$lo*t)+sin(2*PI*$hi*t))');
  }
  return '${_n(amp / 2)}*(${parts.join('+')})';
}

final genCatalog = <GenDef>[
  GenDef(
    'tone',
    const [
      FxParam('waveform', 0, 3, 0, choices: waveforms),
      FxParam('freq', 1, 20000, 440, unit: FxUnit.hz),
      FxParam('amp', 0, 1, 0.8, step: 0.01),
    ],
    (v, sr, s) =>
        "aevalsrc=exprs='${_n(v['amp']!)}*${_wave(v['waveform']!.round(), '${_n(v['freq']!)}*t')}':s=$sr:d=${_n(s)}",
  ),
  GenDef(
    'chirp',
    const [
      FxParam('waveform', 0, 3, 0, choices: waveforms),
      FxParam('freqStart', 1, 20000, 100, unit: FxUnit.hz),
      FxParam('freqEnd', 1, 20000, 4000, unit: FxUnit.hz),
      FxParam('amp', 0, 1, 0.8, step: 0.01),
      FxParam('log', 0, 1, 0, step: 1),
    ],
    (v, sr, s) {
      final f0 = v['freqStart']!;
      final f1 = v['freqEnd']!;
      // Instantaneous phase in cycles: integral of the frequency sweep.
      final String cycles;
      if (v['log']! > 0.5 && f0 != f1) {
        final k = f1 / f0;
        cycles = '${_n(f0 * s / math.log(k))}*(pow(${_n(k)},t/${_n(s)})-1)';
      } else {
        cycles = '(${_n(f0)}*t+${_n((f1 - f0) / (2 * s))}*t*t)';
      }
      return "aevalsrc=exprs='${_n(v['amp']!)}*${_wave(v['waveform']!.round(), cycles)}':s=$sr:d=${_n(s)}";
    },
  ),
  GenDef('noise', const [
    FxParam('color', 0, 5, 0, choices: noiseColors),
    FxParam('amp', 0, 1, 0.5, step: 0.01),
  ], (v, sr, s) => 'anoisesrc=c=${noiseColors[v['color']!.round()]}:a=${_n(v['amp']!)}:r=$sr:d=${_n(s)}'),
  GenDef('silence', const [], (v, sr, s) => 'anullsrc=r=$sr:cl=mono,atrim=end=${_n(s)}'),
  GenDef(
    'metronome',
    const [
      FxParam('bpm', 30, 300, 120, unit: FxUnit.bpm, step: 1),
      FxParam('beats', 1, 16, 4, step: 1),
      FxParam('amp', 0, 1, 0.8, step: 0.01),
    ],
    (v, sr, s) {
      final p = 60 / v['bpm']!;
      final bar = p * v['beats']!.round();
      // Short decaying click every beat; higher pitch on the first beat of a bar.
      return "aevalsrc=exprs='${_n(v['amp']!)}*lt(mod(t,${_n(p)}),0.04)*exp(-mod(t,${_n(p)})*120)"
          "*sin(2*PI*if(lt(mod(t,${_n(bar)}),${_n(p)}),1600,1000)*t)':s=$sr:d=${_n(s)}";
    },
  ),
];

GenDef genById(String id) => genCatalog.firstWhere((g) => g.id == id);

/// DTMF has a text parameter, so it is built separately.
String dtmfSource(
  String digits, {
  required double seconds,
  required int sampleRate,
  double duty = 0.55,
  double amp = 0.8,
}) => "aevalsrc=exprs='${dtmfExpr(digits, seconds, duty, amp)}':s=$sampleRate:d=${_n(seconds)}";
