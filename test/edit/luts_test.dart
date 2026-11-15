import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/process_runner.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/features/edit/luts.dart';
import 'package:path/path.dart' as p;

void main() {
  test('looks keep black and white sensible and stay in range', () {
    for (final look in LutLook.values) {
      for (final v in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final (r, g, b) = lookColor(look, v, v, v);
        for (final x in [r, g, b]) {
          expect(x, inInclusiveRange(0, 1), reason: '${look.name} $v');
        }
      }
      // Brighter input never gets darker (monotonic grey ramp).
      var last = -1.0;
      for (var i = 0; i <= 32; i++) {
        final (r, g, b) = lookColor(look, i / 32, i / 32, i / 32);
        final y = (r + g + b) / 3;
        expect(y, greaterThanOrEqualTo(last - 1e-9), reason: look.name);
        last = y;
      }
    }
    final (r, _, b) = lookColor(LutLook.warm, 0.5, 0.5, 0.5);
    expect(r, greaterThan(b));
    final (mr, mg, mb) = lookColor(LutLook.mono, 0.9, 0.1, 0.3);
    expect(mr == mg && mg == mb, isTrue);
  });

  test('ffmpeg applies the generated cubes', () async {
    final ffmpeg = findOnPath('ffmpeg');
    if (ffmpeg == null) return markTestSkipped('no ffmpeg');
    final dir = await Directory.systemTemp.createTemp('kadra_lut');
    addTearDown(() => dir.delete(recursive: true));
    for (final look in LutLook.values) {
      final lut = await ensureLut(dir.path, look);
      expect(File(lut).readAsLinesSync().length, 2 + 33 * 33 * 33);
      final out = p.join(dir.path, '${look.name}.png');
      final r = await const ProcessRunner().capture(ffmpeg, [
        '-v', 'error', '-f', 'lavfi', '-i', 'testsrc2=s=160x90:d=1', '-vf', 'lut3d=file=$lut', '-frames:v', '1', out, //
      ]);
      expect(r.ok, isTrue, reason: '${look.name}: ${r.stderr}');
    }
  });
}
