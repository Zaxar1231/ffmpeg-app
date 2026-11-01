import 'dart:io';

import 'package:path/path.dart' as p;

import '../platform/host.dart';
import '../settings/app_settings.dart';
import 'catalog.dart';
import 'component_store.dart';

enum ToolOrigin { custom, managed, system, none }

class ToolPath {
  const ToolPath(this.path, this.origin);
  static const missing = ToolPath(null, ToolOrigin.none);
  final String? path;
  final ToolOrigin origin;
  bool get available => path != null;
}

/// Which executable is used for each tool, in priority order:
/// user-specified path → app-managed component → system PATH.
class Toolchain {
  const Toolchain({
    required this.ffmpeg,
    required this.ffprobe,
    required this.ytdlp,
    required this.deno,
    required this.aria2c,
  });

  final ToolPath ffmpeg;
  final ToolPath ffprobe;
  final ToolPath ytdlp;
  final ToolPath deno;
  final ToolPath aria2c;

  bool get hasFfmpeg => ffmpeg.available && ffprobe.available;

  static Toolchain resolve({
    required AppSettings settings,
    required Map<ComponentId, ComponentRecord> records,
    required String componentsRoot,
    HostPlatform? host,
    bool Function(String path)? exists,
    String? Function(String name)? which,
  }) {
    final h = host ?? HostPlatform.current;
    final ex = exists ?? (String path) => File(path).existsSync();
    final wh = which ?? (String name) => findOnPath(name, host: h);

    ToolPath managed(ComponentId id, String bin) {
      final inst = records[id]?.activeInstall;
      final rel = inst?.binaries[bin];
      if (inst == null || rel == null) return ToolPath.missing;
      final full = p.join(componentsRoot, id.name, inst.key, rel);
      return ex(full) ? ToolPath(full, ToolOrigin.managed) : ToolPath.missing;
    }

    ToolPath pick(String? custom, ComponentId id, String bin) {
      if (custom != null && ex(custom)) return ToolPath(custom, ToolOrigin.custom);
      final m = managed(id, bin);
      if (m.available) return m;
      final s = wh(bin);
      return s != null ? ToolPath(s, ToolOrigin.system) : ToolPath.missing;
    }

    // ffprobe next to a custom ffmpeg is the natural default.
    String? probeCustom = settings.customFfprobePath;
    if (probeCustom == null && settings.customFfmpegPath != null) {
      final sibling = p.join(p.dirname(settings.customFfmpegPath!), h.exe('ffprobe'));
      if (ex(sibling)) probeCustom = sibling;
    }

    return Toolchain(
      ffmpeg: pick(settings.customFfmpegPath, ComponentId.ffmpeg, 'ffmpeg'),
      ffprobe: pick(probeCustom, ComponentId.ffmpeg, 'ffprobe'),
      ytdlp: pick(settings.customYtdlpPath, ComponentId.ytdlp, 'yt-dlp'),
      deno: pick(null, ComponentId.deno, 'deno'),
      aria2c: pick(null, ComponentId.aria2, 'aria2c'),
    );
  }
}
