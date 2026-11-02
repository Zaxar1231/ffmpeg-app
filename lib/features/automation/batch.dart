/// Batch processing and watch folders (stage 5): file discovery, output
/// naming and the "is this file finished?" check.
library;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/util/output_paths.dart';

/// Extensions treated as media when scanning folders.
const mediaExtensions = {
  'mp4', 'mkv', 'mov', 'avi', 'webm', 'm4v', 'ts', 'mts', 'm2ts', 'flv', 'wmv', 'mpg', 'mpeg', '3gp', 'ogv', //
  'mp3', 'm4a', 'aac', 'flac', 'wav', 'ogg', 'opus', 'wma', 'aiff', 'aif', 'ac3', 'mka',
  'png', 'jpg', 'jpeg', 'webp', 'bmp', 'tif', 'tiff', 'gif', 'avif',
};

enum FileKindFilter { all, video, audio, images }

const _video = {
  'mp4',
  'mkv',
  'mov',
  'avi',
  'webm',
  'm4v',
  'ts',
  'mts',
  'm2ts',
  'flv',
  'wmv',
  'mpg',
  'mpeg',
  '3gp',
  'ogv',
};
const _audio = {'mp3', 'm4a', 'aac', 'flac', 'wav', 'ogg', 'opus', 'wma', 'aiff', 'aif', 'ac3', 'mka'};
const _images = {'png', 'jpg', 'jpeg', 'webp', 'bmp', 'tif', 'tiff', 'gif', 'avif'};

String extOf(String path) => p.extension(path).replaceFirst('.', '').toLowerCase();

bool matchesKind(String path, FileKindFilter k) {
  final e = extOf(path);
  return switch (k) {
    FileKindFilter.all => mediaExtensions.contains(e),
    FileKindFilter.video => _video.contains(e),
    FileKindFilter.audio => _audio.contains(e),
    FileKindFilter.images => _images.contains(e),
  };
}

/// Media files in [dir] (sorted), skipping hidden files and our own
/// partial outputs.
Future<List<String>> scanFolder(String dir, {bool recursive = true, FileKindFilter kind = FileKindFilter.all}) async {
  final out = <String>[];
  await for (final e in Directory(dir).list(recursive: recursive, followLinks: false)) {
    if (e is! File) continue;
    final name = p.basename(e.path);
    if (name.startsWith('.') || name.endsWith('.part') || name.endsWith('.tmp')) continue;
    if (matchesKind(e.path, kind)) out.add(e.path);
  }
  out.sort();
  return out;
}

/// Output for [input] of a batch: in [outDir] (or next to the input when
/// null), mirroring the sub-folder below [root] when [keepStructure].
String batchOutput({
  required String input,
  required String ext,
  String? outDir,
  String? root,
  bool keepStructure = true,
  String suffix = '',
  bool Function(String path)? exists,
}) {
  var dir = outDir ?? p.dirname(input);
  if (outDir != null && keepStructure && root != null && p.isWithin(root, input)) {
    final rel = p.relative(p.dirname(input), from: root);
    if (rel != '.') dir = p.join(outDir, rel);
  }
  // Same folder and same extension: a suffix keeps the input untouched.
  final sfx = suffix.isEmpty && p.equals(dir, p.dirname(input)) && extOf(input) == ext ? '_kadra' : suffix;
  return outputPathFor(input, ext: ext, suffix: sfx, dir: dir, exists: exists);
}

/// Waits until [path] stops growing (size and mtime unchanged for
/// [stable]), so a file that is still being copied is not picked up.
Future<bool> waitUntilComplete(
  String path, {
  Duration stable = const Duration(seconds: 3),
  Duration timeout = const Duration(hours: 2),
}) async {
  final f = File(path);
  final end = DateTime.now().add(timeout);
  int? lastSize;
  DateTime? lastMod;
  var since = DateTime.now();
  while (DateTime.now().isBefore(end)) {
    if (!f.existsSync()) return false;
    final st = f.statSync();
    if (st.size != lastSize || st.modified != lastMod) {
      lastSize = st.size;
      lastMod = st.modified;
      since = DateTime.now();
    } else if (DateTime.now().difference(since) >= stable && st.size > 0) {
      // A file another program still holds open for writing fails here on Windows.
      try {
        final raf = f.openSync(mode: FileMode.append);
        raf.closeSync();
        return true;
      } on FileSystemException {
        since = DateTime.now();
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  return false;
}
