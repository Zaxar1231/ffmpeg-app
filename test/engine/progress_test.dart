import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/progress.dart';

const _block1 = '''
frame=50
fps=25.00
stream_0_0_q=28.0
bitrate=1234.5kbits/s
total_size=262192
out_time_us=2000000
out_time_ms=2000000
out_time=00:00:02.000000
dup_frames=0
drop_frames=1
speed=2.00x
progress=continue
''';

void main() {
  test('parses a block and computes fraction and ETA', () {
    final p = ProgressParser(totalDuration: const Duration(seconds: 10));
    final snaps = _block1.split('\n').map(p.addLine).whereType<FfmpegProgress>().toList();
    expect(snaps, hasLength(1));
    final s = snaps.single;
    expect(s.frame, 50);
    expect(s.fps, 25.0);
    expect(s.bitrateKbps, 1234.5);
    expect(s.totalSize, 262192);
    expect(s.outTime, const Duration(seconds: 2));
    expect(s.speed, 2.0);
    expect(s.dropFrames, 1);
    expect(s.fraction, closeTo(0.2, 1e-9));
    expect(s.eta, const Duration(seconds: 4)); // 8 s left at 2x
    expect(s.ended, isFalse);
  });

  test('handles N/A values at start and the end marker', () {
    final p = ProgressParser(totalDuration: const Duration(seconds: 1));
    for (final l in ['frame=0', 'bitrate=N/A', 'out_time_us=N/A', 'out_time=N/A', 'speed=N/A']) {
      expect(p.addLine(l), isNull);
    }
    final first = p.addLine('progress=continue')!;
    expect(first.bitrateKbps, isNull);
    expect(first.outTime, isNull);
    expect(first.speed, isNull);
    expect(first.fraction, isNull);

    final end = p.addLine('progress=end')!;
    expect(end.ended, isTrue);
    expect(end.fraction, 1);
  });

  test('without total duration there is no fraction', () {
    final p = ProgressParser();
    p.addLine('out_time_us=5000000');
    final s = p.addLine('progress=continue')!;
    expect(s.outTime, const Duration(seconds: 5));
    expect(s.fraction, isNull);
    expect(s.eta, isNull);
  });

  test('fraction is clamped to 1', () {
    final p = ProgressParser(totalDuration: const Duration(seconds: 1));
    p.addLine('out_time_us=1500000');
    expect(p.addLine('progress=continue')!.fraction, 1.0);
  });

  test('ignores garbage lines', () {
    final p = ProgressParser();
    expect(p.addLine(''), isNull);
    expect(p.addLine('[mp4 @ 0x0] something'), isNull);
    expect(p.addLine('=nokey'), isNull);
  });

  test('progress json roundtrip', () {
    const s = FfmpegProgress(frame: 1, fps: 2, outTime: Duration(seconds: 3), fraction: 0.5, eta: Duration(seconds: 7));
    final r = FfmpegProgress.fromJson(s.toJson());
    expect(r.frame, 1);
    expect(r.outTime, const Duration(seconds: 3));
    expect(r.eta, const Duration(seconds: 7));
  });

  group('parseFfmpegTime', () {
    test('formats', () {
      expect(parseFfmpegTime('00:01:02.500'), const Duration(minutes: 1, seconds: 2, milliseconds: 500));
      expect(parseFfmpegTime('1:02'), const Duration(minutes: 1, seconds: 2));
      expect(parseFfmpegTime('12.25'), const Duration(seconds: 12, milliseconds: 250));
      expect(parseFfmpegTime('-00:00:00.040'), const Duration(milliseconds: -40));
      expect(parseFfmpegTime('N/A'), isNull);
      expect(parseFfmpegTime('abc'), isNull);
    });
  });
}
