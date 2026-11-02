/// App self-update (stage 6): GitHub Releases of this repository, versions,
/// the right asset for how the app was installed, and replacing the app's
/// files. The controller lives in `app_updater.dart`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../platform/host.dart';

/// This build's version; kept in sync with `pubspec.yaml` (checked by a test).
const kAppVersion = '1.0.1';

const kReleasesRepo = 'Zaxar1231/ffmpeg-app';

/// Semantic version `X.Y.Z[-pre]` (a leading `v` and `+build` are ignored).
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch, [this.pre = const []]);
  final int major;
  final int minor;
  final int patch;

  /// Pre-release identifiers (`beta.2` → `[beta, 2]`); empty for releases.
  final List<String> pre;

  bool get isPrerelease => pre.isNotEmpty;

  static AppVersion? tryParse(String s) {
    final m = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+\S*)?$').firstMatch(s.trim());
    if (m == null) return null;
    return AppVersion(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      m.group(4)?.split('.') ?? const [],
    );
  }

  static AppVersion get current => tryParse(kAppVersion)!;

  @override
  int compareTo(AppVersion other) {
    final o = other;
    for (final (a, b) in [(major, o.major), (minor, o.minor), (patch, o.patch)]) {
      if (a != b) return a.compareTo(b);
    }
    // A release is newer than its pre-releases (1.0.0-beta < 1.0.0).
    if (pre.isEmpty || o.pre.isEmpty) return (pre.isEmpty ? 1 : 0) - (o.pre.isEmpty ? 1 : 0);
    for (var i = 0; i < pre.length && i < o.pre.length; i++) {
      final x = int.tryParse(pre[i]), y = int.tryParse(o.pre[i]);
      final c = x != null && y != null
          ? x.compareTo(y)
          : x != null
          ? -1
          : y != null
          ? 1
          : pre[i].compareTo(o.pre[i]);
      if (c != 0) return c;
    }
    return pre.length.compareTo(o.pre.length);
  }

  bool operator >(AppVersion o) => compareTo(o) > 0;

  @override
  bool operator ==(Object other) => other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch, pre.join('.'));

  @override
  String toString() => '$major.$minor.$patch${pre.isEmpty ? '' : '-${pre.join('.')}'}';
}

class ReleaseAsset {
  const ReleaseAsset(this.name, this.url, this.size);
  final String name;
  final String url;
  final int size;
}

class AppRelease {
  const AppRelease({
    required this.tag,
    required this.version,
    required this.notes,
    required this.prerelease,
    required this.pageUrl,
    required this.assets,
    this.published,
  });
  final String tag;
  final AppVersion version;

  /// Release notes (Markdown).
  final String notes;
  final bool prerelease;
  final String pageUrl;
  final List<ReleaseAsset> assets;
  final DateTime? published;

  ReleaseAsset? asset(String name) => assets.where((a) => a.name == name).firstOrNull;
}

/// Parses `GET /repos/{repo}/releases`. Drafts and tags that are not
/// versions are skipped.
List<AppRelease> parseReleases(String json) {
  final out = <AppRelease>[];
  for (final r in (jsonDecode(json) as List).cast<Map<String, Object?>>()) {
    if (r['draft'] == true) continue;
    final tag = r['tag_name'] as String? ?? '';
    final v = AppVersion.tryParse(tag);
    if (v == null) continue;
    out.add(
      AppRelease(
        tag: tag,
        version: v,
        notes: (r['body'] as String? ?? '').trim(),
        // A version like 1.1.0-beta.1 is a pre-release even if not flagged.
        prerelease: r['prerelease'] == true || v.isPrerelease,
        pageUrl: r['html_url'] as String? ?? 'https://github.com/$kReleasesRepo/releases/tag/$tag',
        published: DateTime.tryParse(r['published_at'] as String? ?? ''),
        assets: [
          for (final a in (r['assets'] as List? ?? const []).cast<Map<String, Object?>>())
            ReleaseAsset(a['name'] as String, a['browser_download_url'] as String, (a['size'] as num?)?.toInt() ?? 0),
        ],
      ),
    );
  }
  out.sort((a, b) => b.version.compareTo(a.version));
  return out;
}

/// Releases newer than [current] on the channel, newest first. The first
/// one is the update; all of them make up the changelog.
List<AppRelease> newerReleases(List<AppRelease> releases, AppVersion current, {required bool beta}) => [
  for (final r in releases)
    if ((beta || !r.prerelease) && r.version > current) r,
];

/// How this copy of the app was installed; decides what is downloaded and
/// how it is replaced.
enum InstallKind {
  /// Inno Setup installer (an uninstaller lies next to the exe).
  windowsInstaller,

  /// Unpacked ZIP.
  windowsPortable,

  /// A single AppImage file (`$APPIMAGE`).
  appImage,

  /// Unpacked tar.gz bundle.
  linuxBundle,
}

InstallKind detectInstallKind({required HostPlatform host, required String exeDir, Map<String, String>? env}) {
  final e = env ?? Platform.environment;
  if (host.isWindows) {
    return File(p.join(exeDir, 'unins000.exe')).existsSync()
        ? InstallKind.windowsInstaller
        : InstallKind.windowsPortable;
  }
  return (e['APPIMAGE'] ?? '').isNotEmpty ? InstallKind.appImage : InstallKind.linuxBundle;
}

/// Asset names published by `.github/workflows/release.yml`.
String assetName(InstallKind kind, String tag) => switch (kind) {
  InstallKind.windowsInstaller => 'kadra-$tag-windows-x64-setup.exe',
  InstallKind.windowsPortable => 'kadra-$tag-windows-x64.zip',
  InstallKind.appImage => 'kadra-$tag-linux-x86_64.AppImage',
  InstallKind.linuxBundle => 'kadra-$tag-linux-x64.tar.gz',
};

const checksumsAsset = 'SHA256SUMS.txt';

/// Silent update with Inno Setup; `/RELAUNCH=1` starts the app afterwards
/// (see `windows/installer/kadra.iss`). Inno's restart manager closes the
/// running app if it has not exited yet.
const installerArgs = ['/SILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/CLOSEAPPLICATIONS', '/RELAUNCH=1'];

/// Suffix of files moved aside during an update; removed on the next start.
const oldFileSuffix = '.kadra-old';

/// Finds the unpacked app folder (the one holding the executable and
/// `data/`) below [root].
String? findAppDir(String root, String exeName) {
  final candidates = [
    root,
    for (final e in Directory(root).listSync(recursive: true, followLinks: false))
      if (e is Directory) e.path,
  ];
  candidates.sort((a, b) => a.length.compareTo(b.length));
  for (final d in candidates) {
    if (File(p.join(d, exeName)).existsSync() && Directory(p.join(d, 'data')).existsSync()) return d;
  }
  return null;
}

/// Copies the new version in [from] over [to]. Files in use (the running
/// executable and libraries) cannot be overwritten on Windows but can be
/// renamed, so each existing file is first moved aside to `*.kadra-old`; on
/// Linux the rename also keeps the running process' mapped files intact.
/// If anything fails, the files already replaced are restored.
Future<void> replaceTree(String from, String to) async {
  final done = <(String target, String? aside)>[];
  try {
    for (final e in Directory(from).listSync(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      final target = p.join(to, p.relative(e.path, from: from));
      await Directory(p.dirname(target)).create(recursive: true);
      String? aside;
      if (File(target).existsSync()) {
        aside = '$target$oldFileSuffix';
        if (File(aside).existsSync()) await File(aside).delete();
        await File(target).rename(aside);
      }
      done.add((target, aside));
      await e.copy(target);
      if (!Platform.isWindows) {
        final mode = e.statSync().mode & 0x1ff;
        await Process.run('chmod', [mode.toRadixString(8), target]);
      }
    }
  } catch (_) {
    for (final (target, aside) in done.reversed) {
      try {
        if (File(target).existsSync()) await File(target).delete();
        if (aside != null) await File(aside).rename(target);
      } catch (_) {}
    }
    rethrow;
  }
}

/// Removes files left aside by [replaceTree] (they are free after a restart).
Future<int> cleanupOldFiles(String dir) async {
  var n = 0;
  if (!Directory(dir).existsSync()) return 0;
  for (final e in Directory(dir).listSync(recursive: true, followLinks: false)) {
    if (e is File && e.path.endsWith(oldFileSuffix)) {
      try {
        await e.delete();
        n++;
      } catch (_) {}
    }
  }
  return n;
}

/// Whether the app can replace its own files in [dir] (portable copies in
/// Program Files or a read-only mount cannot).
bool canWriteTo(String dir) {
  try {
    final f = File(p.join(dir, '.kadra-write-test'));
    f.writeAsStringSync('');
    f.deleteSync();
    return true;
  } catch (_) {
    return false;
  }
}

/// Changelog of several releases as one Markdown text, newest first.
String combinedNotes(List<AppRelease> releases) =>
    [for (final r in releases) '## ${r.tag}\n\n${r.notes.isEmpty ? '—' : r.notes}'].join('\n\n');
