@Tags(['ffmpeg'])
@Timeout(Duration(minutes: 10))
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/queue/job_steps.dart';
import 'package:kadra/features/audio_editor/engine/dsp.dart';
import 'package:kadra/features/audio_editor/engine/effects.dart';
import 'package:kadra/features/audio_editor/engine/generators.dart';
import 'package:kadra/features/audio_editor/engine/model.dart';
import 'package:kadra/features/audio_editor/engine/peaks.dart';
import 'package:kadra/features/audio_editor/engine/render.dart';
import 'package:kadra/features/audio_editor/engine/wav.dart';
import 'package:path/path.dart' as p;

const sr = 48000;

void main() {
  final dirEnv = Platform.environment['KADRA_TEST_FFMPEG'];
  final ffmpeg = dirEnv != null ? p.join(dirEnv, HostPlatform.current.exe('ffmpeg')) : findOnPath('ffmpeg');
  final skip = ffmpeg == null ? 'ffmpeg not available' : null;
  const runner = ProcessRunner();
  late Directory dir;
  late String src; // 3 s stereo: 440 Hz left, 660 Hz right, plus a little noise
  var hasRubberband = false;
  var n = 0;

  WavInfo info(String path) {
    final f = File(path).openSync();
    try {
      return readWavInfo(f);
    } finally {
      f.closeSync();
    }
  }

  Future<String> run(List<String> args) async {
    final r = await runner.capture(ffmpeg!, args);
    expect(r.ok, isTrue, reason: '${args.join(' ')}\n${r.stderr}');
    return r.stderr;
  }

  String out() => p.join(dir.path, 'o${n++}.wav');

  setUpAll(() async {
    if (skip != null) return;
    dir = await Directory.systemTemp.createTemp('kadra_ae');
    final gen = p.join(dir.path, 'gen.wav');
    await run([
      '-v', 'error', '-f', 'lavfi', '-i', 'sine=f=440:d=3:sample_rate=$sr', '-f', 'lavfi', //
      '-i', 'sine=f=660:d=3:sample_rate=$sr', '-f', 'lavfi', '-i', 'anoisesrc=d=3:c=pink:a=0.02:r=$sr',
      '-filter_complex', '[0][1]amerge=inputs=2[s];[2]pan=stereo|c0=c0|c1=c0[nz];[s][nz]amix=inputs=2:normalize=0',
      '-c:a', 'pcm_s16le', gen,
    ]);
    src = p.join(dir.path, 'src.wav');
    await run(importArgs(gen, src, sampleRate: sr, channels: 2));
    final l = (await runner.capture(ffmpeg!, ['-hide_banner', '-filters'])).stdout;
    hasRubberband = l.contains(' rubberband ');
  });

  tearDownAll(() async {
    if (skip == null) await dir.delete(recursive: true);
  });

  test('import produces f32 stereo at project rate', () {
    final i = info(src);
    expect(i.isFloat, isTrue);
    expect(i.channels, 2);
    expect(i.sampleRate, sr);
    expect(i.frames, 3 * sr);
  }, skip: skip);

  test('every ffmpeg effect runs on a selection and keeps/changes length as declared', () async {
    final total = info(src).frames;
    const r = SampleRange(sr ~/ 2, 2 * sr); // 0.5 s … 2 s
    final bad = <String>[];
    final brokenInBuild = <String>[];
    for (final fx in fxCatalog) {
      if (fx.kind == FxKind.dsp || fx.kind == FxKind.sidechain) continue;
      final v = fx.defaults();
      // Make "do nothing by default" effects actually do something.
      if (fx.id == 'amplify') v['gain'] = -6;
      if (fx.id == 'changeTempo' || fx.id == 'changeSpeed') v['percent'] = 50;
      if (fx.id == 'changePitch') v['semitones'] = 3;
      if (fx.id == 'repeat') v['times'] = 2;
      final o = out();
      if (fx.id == 'reverb') {
        await run(reverbArgs(src, o, total: total, r: r, v: v, sampleRate: sr));
      } else {
        var measured = <String, String>{};
        if (fx.measure == FxMeasure.peakDc) {
          final st = analyzeStats(src, start: r.start, end: r.end);
          measured = {
            for (var c = 0; c < st.length; c++) ...{'peak$c': '${st[c].peak}', 'dc$c': '${st[c].dc}'},
          };
        } else if (fx.measure == FxMeasure.loudness) {
          final log = await run(loudnessMeasureArgs(src, r: r, lufs: v['lufs']!, tp: v['truePeak']!));
          measured = parseLoudnormJson(log.split('\n'))!;
        }
        final chain = fx.build!(
          v,
          FxContext(sampleRate: sr, channels: 2, frames: r.length, measured: measured, hasRubberband: hasRubberband),
        );
        // Some builds ship broken filters; the app detects this with a smoke
        // test and reports it instead of running the effect.
        final smoke = await runner.capture(ffmpeg!, smokeTestArgs(chain, sampleRate: sr));
        if (!smoke.ok) {
          brokenInBuild.add(fx.id);
          continue;
        }
        await run(
          effectArgs(src, o, total: total, r: r, chain: fx.changesLength ? chain : exactLength(chain, r.length)),
        );
      }
      final oi = info(o);
      expect(oi.channels, 2, reason: fx.id);
      if (fx.id == 'reverb') {
        expect(oi.frames, greaterThan(total), reason: 'reverb tail');
      } else if (!fx.changesLength) {
        if (oi.frames != total) bad.add('${fx.id}: ${oi.frames}');
      } else if (fx.id == 'repeat') {
        expect(oi.frames, total + r.length * 2, reason: 'repeat x2 adds two copies');
      } else if (fx.id == 'changeTempo' || fx.id == 'changeSpeed') {
        expect(oi.frames, closeTo(total - r.length + r.length / 1.5, sr * 0.05), reason: fx.id);
      }
    }
    expect(bad, isEmpty);
    // Known: anlmdn aborts in the BtbN 9.0 build. Anything else is a regression.
    expect(brokenInBuild.where((id) => id != 'nlmDenoise'), isEmpty);
    if (brokenInBuild.isNotEmpty) markTestSkipped('broken in this ffmpeg build: $brokenInBuild');
  }, skip: skip);

  test('normalize hits the requested peak on the selection only', () async {
    final total = info(src).frames;
    const r = SampleRange(sr, 2 * sr);
    final st = analyzeStats(src, start: r.start, end: r.end);
    final fx = fxById('normalize');
    final v = fx.defaults()..['peak'] = -3;
    final chain = fx.build!(
      v,
      FxContext(
        sampleRate: sr,
        channels: 2,
        frames: r.length,
        measured: {
          for (var c = 0; c < 2; c++) ...{
            'peak$c': '${st[c].peak}',
            'dc$c': '${st[c].dc}',
            'min$c': '${st[c].min}',
            'max$c': '${st[c].max}',
          },
        },
      ),
    );
    final o = out();
    await run(effectArgs(src, o, total: total, r: r, chain: chain));
    final after = analyzeStats(o, start: r.start, end: r.end);
    expect(after.map((s) => s.peakDb).reduce(math.max), closeTo(-3, 0.05));
    final outside = analyzeStats(o, start: 0, end: sr ~/ 2);
    final before = analyzeStats(src, start: 0, end: sr ~/ 2);
    expect(outside.first.peak, closeTo(before.first.peak, 1e-6), reason: 'untouched outside');
  }, skip: skip);

  test('delete, silence, trim, insert, crossfade are sample exact', () async {
    final total = info(src).frames;
    const r = SampleRange(12345, 54321);
    final del = out();
    await run(deleteArgs(src, del, total: total, r: r));
    expect(info(del).frames, total - r.length);
    final sil = out();
    await run(silenceArgs(src, sil, total: total, r: r));
    expect(info(sil).frames, total);
    expect(analyzeStats(sil, start: r.start, end: r.end).first.peak, 0);
    final tr = out();
    await run(trimToArgs(src, tr, r: r));
    expect(info(tr).frames, r.length);
    final ins = out();
    await run(insertArgs(src, ins, total: total, position: 1000, clip: tr, sampleRate: sr, channels: 2));
    expect(info(ins).frames, total + r.length);
    final rep = out();
    await run(
      insertArgs(
        src,
        rep,
        total: total,
        position: 0,
        clip: tr,
        sampleRate: sr,
        channels: 2,
        replace: const SampleRange(0, 100),
      ),
    );
    expect(info(rep).frames, total - 100 + r.length);
    final xf = out();
    await run(crossfadeArgs(src, xf, total: total, position: sr, frames: sr ~/ 10, sampleRate: sr));
    expect(info(xf).frames, closeTo(total - sr ~/ 10, 2));
    final all = out();
    await run(deleteArgs(src, all, total: total, r: SampleRange(0, total)));
    expect(info(all).frames, 1);
  }, skip: skip);

  test('noise reduction with a profile beats plain afftdn', () async {
    final noise = p.join(dir.path, 'noise.wav');
    await run(generateArgs('anoisesrc=d=3:c=pink:a=0.05:r=$sr', noise, channels: 2));
    final profile = out();
    await run(trimToArgs(noise, profile, r: const SampleRange(0, sr)));
    final total = info(noise).frames;
    final chain = fxById('noiseReduction')
        .build!({'reduction': 30, 'floor': -20, 'track': 0}, const FxContext(sampleRate: sr, channels: 2, frames: 0));
    final withProfile = out();
    await run(
      noiseProfileArgs(
        noise,
        withProfile,
        total: total,
        profileWav: profile,
        profileFrames: sr,
        sampleRate: sr,
        afftdn: chain,
      ),
    );
    expect(info(withProfile).frames, total);
    final plain = out();
    await run(effectArgs(noise, plain, total: total, chain: chain));
    final rmsProfile = analyzeStats(withProfile, start: sr).first.rmsDb;
    final rmsPlain = analyzeStats(plain, start: sr).first.rmsDb;
    expect(rmsProfile, lessThan(rmsPlain - 6));
  }, skip: skip);

  test('auto duck lowers music under a voice track', () async {
    final music = p.join(dir.path, 'music.wav');
    await run(generateArgs("aevalsrc=exprs='0.3*sin(2*PI*220*t)':s=$sr:d=4", music, channels: 2));
    final voice = p.join(dir.path, 'voice.wav');
    // Voice only between 1 s and 2 s (track starts at 0.5 s on the timeline).
    await run(generateArgs("aevalsrc=exprs='between(t,0.5,1.5)*0.5*sin(2*PI*1000*t)':s=$sr:d=2", voice, channels: 1));
    final fx = fxById('autoDuck');
    final o = out();
    await run(
      autoDuckArgs(
        music,
        o,
        total: info(music).frames,
        control: voice,
        controlOffset: sr ~/ 2,
        chain: fx.build!(fx.defaults(), const FxContext(sampleRate: sr, channels: 2, frames: 0)),
      ),
    );
    expect(info(o).frames, info(music).frames);
    final ducked = analyzeStats(o, start: (1.3 * sr).round(), end: (1.8 * sr).round()).first.rmsDb;
    final free = analyzeStats(o, start: (3 * sr).round(), end: (3.5 * sr).round()).first.rmsDb;
    expect(ducked, lessThan(free - 6));
  }, skip: skip);

  test('generators', () async {
    for (final g in genCatalog) {
      final o = out();
      await run(generateArgs(g.source(g.defaults(), sr, 1.5), o, channels: 1));
      expect(info(o).frames, closeTo(1.5 * sr, 2), reason: g.id);
      if (g.id != 'silence') expect(analyzeStats(o).first.peak, greaterThan(0.01), reason: g.id);
    }
    final dtmf = out();
    await run(generateArgs(dtmfSource('5551234', seconds: 2, sampleRate: sr), dtmf, channels: 1));
    expect(analyzeStats(dtmf).first.peak, greaterThan(0.3));
    // A 1 kHz tone shows up at 1 kHz in the spectrum.
    final tone = out();
    await run(
      generateArgs(genById('tone').source({'waveform': 0, 'freq': 1000, 'amp': 0.5}, sr, 1), tone, channels: 1),
    );
    final spec = averageSpectrum(tone, fftSize: 4096);
    var best = 0;
    for (var i = 1; i < spec.length; i++) {
      if (spec[i] > spec[best]) best = i;
    }
    expect(best * sr / 4096, closeTo(1000, sr / 4096));
  }, skip: skip);

  test('mixdown applies offset, gain, pan, envelope and solo', () async {
    final a = p.join(dir.path, 'ma.wav');
    final b = p.join(dir.path, 'mb.wav');
    await run(generateArgs("aevalsrc=exprs='0.5*sin(2*PI*300*t)':s=$sr:d=1", a, channels: 1));
    await run(generateArgs("aevalsrc=exprs='0.5*sin(2*PI*500*t)':s=$sr:d=1", b, channels: 1));
    final state = AudioProjectState(
      sampleRate: sr,
      tracks: [
        AudioTrack(id: 'a', name: 'a', file: a, frames: sr, channels: 1, pan: -1),
        AudioTrack(
          id: 'b',
          name: 'b',
          file: b,
          frames: sr,
          channels: 1,
          offset: sr,
          gainDb: -6,
          envelope: const [EnvelopePoint(0, 1), EnvelopePoint(1, 0)],
        ),
      ],
    );
    final o = out();
    await run(mixArgs(state, o));
    final mi = info(o);
    expect(mi.channels, 2);
    expect(mi.frames, 2 * sr);
    final first = analyzeStats(o, start: 0, end: sr);
    expect(first[1].peak, lessThan(0.001), reason: 'track a hard-left');
    final second = analyzeStats(o, start: (1.05 * sr).round(), end: (1.15 * sr).round());
    expect(second[0].peak, closeTo(0.5 * 0.5 * 0.707 * 0.95, 0.03), reason: 'gain −6 dB, centre pan, envelope ≈0.95');
    final tail = analyzeStats(o, start: (1.9 * sr).round(), end: 2 * sr);
    expect(tail[0].peak, lessThan(0.05), reason: 'envelope fades to 0');
    final soloB = state.copyWith(tracks: [state.tracks[0], state.tracks[1].copyWith(solo: true)]);
    final o2 = out();
    await run(mixArgs(soloB, o2, range: const SampleRange(0, sr)));
    expect(analyzeStats(o2).first.peak, lessThan(0.001), reason: 'only b audible, silent before its offset');
  }, skip: skip);

  test('ebur128 summary parses', () async {
    final log = await run(ebur128Args(src));
    final s = parseEbur128Summary(log);
    expect(s.integrated, isNotNull);
    expect(s.integrated, lessThan(0));
    expect(s.truePeak, isNotNull);
  }, skip: skip);

  test('dart DSP: wav roundtrip, paulstretch, wahwah, sliding speed, peaks, finders', () async {
    final f = File(src).openSync();
    final i = readWavInfo(f);
    final pcm = readFrames(f, i, 0, sr); // 1 s
    f.closeSync();
    final w = p.join(dir.path, 'rt.wav');
    await writeWavFloat(w, pcm, sr);
    expect(info(w).frames, sr);
    final ps = paulstretch(pcm, sr, stretch: 4, windowSec: 0.1);
    expect(ps.first.length, 4 * sr);
    final wah = wahwah(pcm, sr, lfoHz: 1, depth: 0.7, resonance: 2.5, offset: 0.3);
    expect(wah.first.length, sr);
    final sl = slidingSpeed(pcm, fromPct: 0, toPct: 100);
    expect(sl.first.length, inInclusiveRange((sr / 1.6).round(), (sr / 1.4).round()));
    final peaks = computePeaks(src);
    expect(peaks.frames, 3 * sr);
    final (lo, hi) = peaks.range(0, 0, sr);
    expect(hi, greaterThan(0.1));
    expect(lo, lessThan(-0.1));
    // Clipping: amplify +30 dB then find runs.
    final clipped = out();
    await run(effectArgs(src, clipped, total: 3 * sr, chain: 'volume=30dB,alimiter=limit=1:level=0,volume=1.2'));
    expect(findClipping(clipped, level: 0.999), isNotEmpty);
    // Silence/sound finder on generated pattern.
    final pat = out();
    await run(generateArgs("aevalsrc=exprs='lt(mod(t,1),0.5)*0.5*sin(2*PI*440*t)':s=$sr:d=3", pat, channels: 1));
    final env = rmsEnvelope(pat);
    final sounds = findRegions(env, sr ~/ 100, thresholdDb: -30, minWindows: 10, sounds: true);
    expect(sounds.length, 3);
    final silences = findRegions(env, sr ~/ 100, thresholdDb: -30, minWindows: 10, sounds: false);
    expect(silences.length, 3);
    expect(findBeats(env, sr ~/ 100, thresholdDb: -30).length, 3);
  }, skip: skip);

  test('FFT basics', () {
    final re = Float64List(8)..[1] = 1;
    final im = Float64List(8);
    fft(re, im);
    fft(re, im, inverse: true);
    expect(re[1], closeTo(1, 1e-12));
    expect(re[0], closeTo(0, 1e-12));
  });
}
