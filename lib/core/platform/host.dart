import 'dart:io';

import 'package:path/path.dart' as p;

enum HostOs { windows, linux, macos, other }

enum HostArch { x64, arm64, other }

class HostPlatform {
  const HostPlatform(this.os, this.arch);

  static final HostPlatform current = HostPlatform(_os(), _arch());

  final HostOs os;
  final HostArch arch;

  bool get isWindows => os == HostOs.windows;
  bool get isLinux => os == HostOs.linux;

  String exe(String name) => isWindows ? '$name.exe' : name;

  static HostOs _os() {
    if (Platform.isWindows) return HostOs.windows;
    if (Platform.isLinux) return HostOs.linux;
    if (Platform.isMacOS) return HostOs.macos;
    return HostOs.other;
  }

  /// Dart reports the VM's target, e.g. `... on "windows_x64"`.
  static HostArch _arch() {
    final v = Platform.version;
    if (v.contains('_arm64') || v.contains('aarch64')) return HostArch.arm64;
    if (v.contains('_x64')) return HostArch.x64;
    return HostArch.other;
  }

  @override
  String toString() => '${os.name}-${arch.name}';
}

/// Finds an executable on PATH (like `which` / `where`), without a shell.
String? findOnPath(String name, {HostPlatform? host, Map<String, String>? env}) {
  final h = host ?? HostPlatform.current;
  final e = env ?? Platform.environment;
  final pathVar = e['PATH'] ?? e['Path'] ?? '';
  final sep = h.isWindows ? ';' : ':';
  final exts = h.isWindows
      ? (e['PATHEXT'] ?? '.EXE;.CMD;.BAT').split(';').where((x) => x.isNotEmpty).map((x) => x.toLowerCase()).toList()
      : [''];
  for (final dir in pathVar.split(sep)) {
    if (dir.trim().isEmpty) continue;
    for (final ext in exts) {
      final candidate = p.join(dir.trim(), name.toLowerCase().endsWith(ext) ? name : '$name$ext');
      if (File(candidate).existsSync()) return candidate;
    }
  }
  return null;
}
