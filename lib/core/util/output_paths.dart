import 'dart:io';

import 'package:path/path.dart' as p;

/// `<dir>/<name><suffix>.<ext>`, made unique with ` (2)`, ` (3)`… so a run
/// never silently overwrites an existing file (or its own input).
String outputPathFor(
  String input, {
  required String ext,
  String suffix = '',
  required String dir,
  bool Function(String path)? exists,
}) {
  final ex = exists ?? (String s) => File(s).existsSync();
  final base = p.basenameWithoutExtension(input);
  var candidate = p.join(dir, '$base$suffix.$ext');
  var n = 2;
  while (ex(candidate) || p.equals(candidate, input)) {
    candidate = p.join(dir, '$base$suffix ($n).$ext');
    n++;
  }
  return candidate;
}

/// Replaces the extension of a user-edited output path.
String withExtension(String path, String ext) => p.setExtension(path, '.$ext');
