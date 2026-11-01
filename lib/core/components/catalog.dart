/// Static description of downloadable components and pure helpers that pick
/// the right asset for a host platform. Network access lives in resolver.dart.
library;

import '../platform/host.dart';

enum ComponentId { ffmpeg, ytdlp, deno, aria2 }

enum ArchiveType { zip, tarXz, raw }

enum UpdateChannel { stable, nightly }

/// Where a component comes from. One component may have several sources.
enum ComponentSource {
  /// github.com/BtbN/FFmpeg-Builds — Windows and Linux static builds.
  btbn,

  /// gyan.dev — Windows only (essentials / full).
  gyan,

  /// github.com/yt-dlp/yt-dlp (stable) and yt-dlp-nightly-builds.
  ytdlp,

  /// github.com/denoland/deno
  deno,

  /// github.com/aria2/aria2 — Windows builds only; Linux uses the system package.
  aria2,
}

/// User-selectable build flavor for ffmpeg.
enum FfmpegLicense { gpl, lgpl }

enum GyanFlavor { essentials, full }

class ComponentDescriptor {
  const ComponentDescriptor({
    required this.id,
    required this.binaries,
    required this.sources,
    required this.versionArgs,
    this.required = false,
  });

  final ComponentId id;

  /// Executables this component provides (without .exe).
  final List<String> binaries;
  final List<ComponentSource> sources;

  /// How to ask the main binary for its version.
  final List<String> versionArgs;
  final bool required;
}

const componentCatalog = <ComponentId, ComponentDescriptor>{
  ComponentId.ffmpeg: ComponentDescriptor(
    id: ComponentId.ffmpeg,
    binaries: ['ffmpeg', 'ffprobe'],
    sources: [ComponentSource.btbn, ComponentSource.gyan],
    versionArgs: ['-hide_banner', '-version'],
    required: true,
  ),
  ComponentId.ytdlp: ComponentDescriptor(
    id: ComponentId.ytdlp,
    binaries: ['yt-dlp'],
    sources: [ComponentSource.ytdlp],
    versionArgs: ['--version'],
  ),
  ComponentId.deno: ComponentDescriptor(
    id: ComponentId.deno,
    binaries: ['deno'],
    sources: [ComponentSource.deno],
    versionArgs: ['--version'],
  ),
  ComponentId.aria2: ComponentDescriptor(
    id: ComponentId.aria2,
    binaries: ['aria2c'],
    sources: [ComponentSource.aria2],
    versionArgs: ['--version'],
  ),
};

/// A concrete file to download, with how to verify and unpack it.
class PackageSpec {
  const PackageSpec({
    required this.component,
    required this.source,
    required this.channel,
    required this.url,
    required this.fileName,
    required this.archive,
    this.sha256,
    this.versionLabel,
    this.variant,
  });

  final ComponentId component;
  final ComponentSource source;
  final UpdateChannel channel;
  final String url;
  final String fileName;
  final ArchiveType archive;

  /// Expected SHA-256 (lowercase hex). Null only when the source publishes none.
  final String? sha256;

  /// e.g. `n8.1`, `master`, `9.0.2`, `2026.10.22`. May be null until installed.
  final String? versionLabel;

  /// e.g. `gpl`, `lgpl`, `essentials`, `full`.
  final String? variant;
}

/// Parses `sha256sum`-style files: `<hex>  <name>` or `<hex> *<name>`.
/// Also accepts a bare hash (single-file `.sha256`), keyed by [singleName].
Map<String, String> parseChecksums(String text, {String? singleName}) {
  final result = <String, String>{};
  final re = RegExp(r'^([0-9a-fA-F]{64})(?:\s+\*?(.+))?$');
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final m = re.firstMatch(line);
    if (m == null) continue;
    final name = m.group(2)?.trim() ?? singleName;
    if (name == null) continue;
    result[name.split('/').last] = m.group(1)!.toLowerCase();
  }
  return result;
}

// ---------------------------------------------------------------- BtbN

String? btbnPlatformTag(HostPlatform h) => switch ((h.os, h.arch)) {
  (HostOs.windows, HostArch.x64) => 'win64',
  (HostOs.windows, HostArch.arm64) => 'winarm64',
  (HostOs.linux, HostArch.x64) => 'linux64',
  (HostOs.linux, HostArch.arm64) => 'linuxarm64',
  _ => null,
};

const btbnDownloadBase = 'https://github.com/BtbN/FFmpeg-Builds/releases/latest/download';

/// Picks the BtbN asset from `checksums.sha256`.
/// stable → newest `ffmpeg-nX.Y-latest-<plat>-<lic>-X.Y.<ext>`;
/// nightly → `ffmpeg-master-latest-<plat>-<lic>.<ext>`. Static (non-shared) only.
({String fileName, String version})? selectBtbnAsset(
  Iterable<String> assetNames, {
  required HostPlatform host,
  required FfmpegLicense license,
  required UpdateChannel channel,
}) {
  final plat = btbnPlatformTag(host);
  if (plat == null) return null;
  final ext = host.isWindows ? 'zip' : 'tar.xz';
  final lic = license.name;
  if (channel == UpdateChannel.nightly) {
    final name = 'ffmpeg-master-latest-$plat-$lic.$ext';
    return assetNames.contains(name) ? (fileName: name, version: 'master') : null;
  }
  final re = RegExp('^ffmpeg-n(\\d+)\\.(\\d+)-latest-$plat-$lic-(\\d+\\.\\d+)\\.${RegExp.escape(ext)}\$');
  ({String fileName, String version})? best;
  var bestKey = -1;
  for (final n in assetNames) {
    final m = re.firstMatch(n);
    if (m == null) continue;
    final key = int.parse(m.group(1)!) * 1000 + int.parse(m.group(2)!);
    if (key > bestKey) {
      bestKey = key;
      best = (fileName: n, version: 'n${m.group(1)}.${m.group(2)}');
    }
  }
  return best;
}

// ---------------------------------------------------------------- gyan.dev

const gyanBase = 'https://www.gyan.dev/ffmpeg/builds';
const gyanReleaseVersionUrl = '$gyanBase/release-version';

/// gyan.dev publishes the essentials build as .zip with a .sha256 next to it.
/// The full build is only a .7z there, so we take the .zip mirror from
/// github.com/GyanD/codexffmpeg (same build, same author).
String gyanUrl(GyanFlavor flavor, String version) => switch (flavor) {
  GyanFlavor.essentials => '$gyanBase/ffmpeg-release-essentials.zip',
  GyanFlavor.full => 'https://github.com/GyanD/codexffmpeg/releases/download/$version/ffmpeg-$version-full_build.zip',
};

// ---------------------------------------------------------------- yt-dlp

String ytdlpRepo(UpdateChannel c) => c == UpdateChannel.nightly ? 'yt-dlp/yt-dlp-nightly-builds' : 'yt-dlp/yt-dlp';

/// Standalone single-file builds (no Python needed).
String? ytdlpAssetName(HostPlatform h) => switch ((h.os, h.arch)) {
  (HostOs.windows, HostArch.x64) => 'yt-dlp.exe',
  (HostOs.windows, HostArch.arm64) => 'yt-dlp_arm64.exe',
  (HostOs.linux, HostArch.x64) => 'yt-dlp_linux',
  (HostOs.linux, HostArch.arm64) => 'yt-dlp_linux_aarch64',
  _ => null,
};

// ---------------------------------------------------------------- deno

String? denoAssetName(HostPlatform h) => switch ((h.os, h.arch)) {
  (HostOs.windows, HostArch.x64) => 'deno-x86_64-pc-windows-msvc.zip',
  (HostOs.windows, HostArch.arm64) => 'deno-aarch64-pc-windows-msvc.zip',
  (HostOs.linux, HostArch.x64) => 'deno-x86_64-unknown-linux-gnu.zip',
  (HostOs.linux, HostArch.arm64) => 'deno-aarch64-unknown-linux-gnu.zip',
  _ => null,
};

String githubLatestDownload(String repo, String asset) => 'https://github.com/$repo/releases/latest/download/$asset';
