/// Built-in color looks as 3D LUTs (`.cube`, 33³), generated on first use
/// into the app's data folder; `lut3d` applies them like any imported LUT.
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart' as p;

enum LutLook { warm, cool, teal, faded, vintage, vivid, mono }

typedef LutRgb = (double, double, double);

double _luma(double r, double g, double b) => 0.2126 * r + 0.7152 * g + 0.0722 * b;
double _c(double x) => x.clamp(0.0, 1.0);

/// Gentle S-curve: [k] (0..0.5) adds contrast around mid-grey; 0 and 1
/// stay where they are.
double _s(double x, double k) => _c(x + k * (x - 0.5) * (1 - (2 * x - 1).abs()));

LutRgb _sat(double r, double g, double b, double amount) {
  final y = _luma(r, g, b);
  return (_c(y + (r - y) * amount), _c(y + (g - y) * amount), _c(y + (b - y) * amount));
}

/// The look applied to one input color (0..1).
LutRgb lookColor(LutLook look, double r, double g, double b) {
  switch (look) {
    case LutLook.warm:
      return (_c(r * 1.06 + 0.01), _c(g * 1.01), _c(b * 0.90));
    case LutLook.cool:
      return (_c(r * 0.92), _c(g * 1.0), _c(b * 1.08 + 0.01));
    case LutLook.teal:
      // Teal shadows, orange highlights (split toning), a bit more contrast.
      final y = _luma(r, g, b);
      final hi = math.pow(y, 1.5).toDouble(), lo = math.pow(1 - y, 1.5).toDouble();
      return (
        _s(_c(r + 0.10 * hi - 0.06 * lo), 0.35),
        _s(_c(g + 0.03 * hi + 0.02 * lo), 0.35),
        _s(_c(b - 0.10 * hi + 0.08 * lo), 0.35),
      );
    case LutLook.faded:
      final (sr, sg, sb) = _sat(r, g, b, 0.75);
      // Lifted blacks, softer whites.
      return (0.08 + sr * 0.86, 0.08 + sg * 0.86, 0.10 + sb * 0.84);
    case LutLook.vintage:
      final y = _luma(r, g, b);
      final (sr, sg, sb) = _sat(r, g, b, 0.55);
      return (
        _c(0.06 + (sr * 0.7 + y * 0.3) * 0.92 * 1.05),
        _c(0.05 + (sg * 0.7 + y * 0.3) * 0.90),
        _c(0.07 + (sb * 0.7 + y * 0.3) * 0.78),
      );
    case LutLook.vivid:
      final (sr, sg, sb) = _sat(r, g, b, 1.3);
      return (_s(sr, 0.4), _s(sg, 0.4), _s(sb, 0.4));
    case LutLook.mono:
      final y = _s(_luma(r, g, b), 0.5);
      return (y, y, y);
  }
}

/// `.cube` text: red changes fastest, as the format requires.
String cubeText(LutLook look, {int size = 33}) {
  final b = StringBuffer()
    ..writeln('TITLE "Kadra ${look.name}"')
    ..writeln('LUT_3D_SIZE $size');
  final n = size - 1;
  for (var bi = 0; bi < size; bi++) {
    for (var gi = 0; gi < size; gi++) {
      for (var ri = 0; ri < size; ri++) {
        final (r, g, bl) = lookColor(look, ri / n, gi / n, bi / n);
        b.writeln('${r.toStringAsFixed(6)} ${g.toStringAsFixed(6)} ${bl.toStringAsFixed(6)}');
      }
    }
  }
  return b.toString();
}

/// Path of the look's `.cube` file in [dir], written if missing.
Future<String> ensureLut(String dir, LutLook look) async {
  final f = File(p.join(dir, 'kadra-${look.name}.cube'));
  if (!f.existsSync()) {
    await f.parent.create(recursive: true);
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(cubeText(look));
    await tmp.rename(f.path);
  }
  return f.path;
}
