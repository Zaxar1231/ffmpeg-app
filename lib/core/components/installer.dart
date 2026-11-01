import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../engine/capabilities.dart' show parseVersionOutput;
import '../engine/process_runner.dart';
import '../platform/host.dart';
import 'catalog.dart';

class InstallException implements Exception {
  InstallException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Unpacks [archivePath] into [destDir]. Uses the system `tar` where it is
/// fast and reliable (GNU tar for .tar.xz on Linux, bsdtar on Windows 10+
/// which also reads .zip), and the pure-Dart `archive` package as fallback.
/// Heavy work runs in a separate process or isolate, never on the UI thread.
Future<void> extractArchive(
  String archivePath,
  String destDir,
  ArchiveType type, {
  HostPlatform? host,
  ProcessRunner runner = const ProcessRunner(),
}) async {
  final h = host ?? HostPlatform.current;
  await Directory(destDir).create(recursive: true);
  if (type == ArchiveType.raw) return;

  final useSystemTar = (type == ArchiveType.tarXz && !h.isWindows) || (type == ArchiveType.zip && h.isWindows);
  if (useSystemTar) {
    final tar = h.isWindows ? (findOnPath('tar') ?? r'C:\Windows\System32\tar.exe') : (findOnPath('tar') ?? 'tar');
    final r = await runner.capture(tar, ['-xf', archivePath, '-C', destDir], timeout: const Duration(minutes: 10));
    if (r.ok) return;
  }
  await Isolate.run(() async {
    await extractFileToDisk(archivePath, destDir);
  });
}

/// Finds each binary (with `.exe` on Windows) anywhere below [root].
/// Returns name → path relative to [root].
Map<String, String> locateBinaries(String root, List<String> names, {HostPlatform? host}) {
  final h = host ?? HostPlatform.current;
  final wanted = {for (final n in names) h.exe(n).toLowerCase(): n};
  final found = <String, String>{};
  for (final e in Directory(root).listSync(recursive: true, followLinks: false)) {
    if (e is! File) continue;
    final base = p.basename(e.path).toLowerCase();
    final n = wanted[base];
    if (n == null) continue;
    final rel = p.relative(e.path, from: root);
    // Prefer the shortest path (bin/ffmpeg over doc/examples/...).
    if (!found.containsKey(n) || rel.length < found[n]!.length) found[n] = rel;
  }
  return found;
}

Future<void> makeExecutable(String path, {HostPlatform? host}) async {
  final h = host ?? HostPlatform.current;
  if (h.isWindows) return;
  await Process.run('chmod', ['+x', path]);
}

/// Extracts a human version string from a component's `--version` output.
String? parseComponentVersion(ComponentId id, String output) {
  final first = output.split('\n').map((l) => l.trim()).firstWhere((l) => l.isNotEmpty, orElse: () => '');
  switch (id) {
    case ComponentId.ffmpeg:
      return parseVersionOutput(output).version;
    case ComponentId.ytdlp:
      return first.isEmpty ? null : first;
    case ComponentId.deno:
      return RegExp(r'^deno (\S+)').firstMatch(first)?.group(1);
    case ComponentId.aria2:
      return RegExp(r'aria2 version (\S+)').firstMatch(first)?.group(1);
  }
}

/// Runs the main binary with its version flag. Throws if it does not start
/// (wrong architecture, missing runtime, blocked by antivirus...).
Future<String?> probeComponentVersion(
  ComponentId id,
  String executable, {
  ProcessRunner runner = const ProcessRunner(),
}) async {
  final desc = componentCatalog[id]!;
  final r = await runner.capture(executable, desc.versionArgs, timeout: const Duration(seconds: 30));
  if (r.startFailed || !r.ok) {
    throw InstallException('${p.basename(executable)} ${desc.versionArgs.join(' ')} failed: ${r.stderr.trim()}');
  }
  return parseComponentVersion(id, r.stdout.isNotEmpty ? r.stdout : r.stderr);
}
