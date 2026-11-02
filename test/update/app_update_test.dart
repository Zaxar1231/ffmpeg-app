import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/settings/app_settings.dart';
import 'package:kadra/core/update/app_update.dart';
import 'package:path/path.dart' as p;

AppVersion v(String s) => AppVersion.tryParse(s)!;

Map<String, Object?> rel(String tag, {bool pre = false, bool draft = false, List<String> assets = const []}) => {
  'tag_name': tag,
  'prerelease': pre,
  'draft': draft,
  'body': 'notes $tag',
  'html_url': 'https://github.com/x/y/releases/tag/$tag',
  'published_at': '2026-11-01T10:00:00Z',
  'assets': [
    for (final a in assets) {'name': a, 'browser_download_url': 'https://dl/$a', 'size': 1000},
  ],
};

void main() {
  test('kAppVersion matches pubspec.yaml', () {
    final pub = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(r'^version:\s*([^+\s]+)', multiLine: true).firstMatch(pub)!;
    expect(kAppVersion, m.group(1));
    expect(AppVersion.tryParse(kAppVersion), isNotNull);
  });

  test('version order with pre-releases', () {
    final order = [
      '0.4.0',
      '1.0.0-alpha',
      '1.0.0-alpha.1',
      '1.0.0-beta',
      '1.0.0-beta.2',
      '1.0.0-beta.11',
      '1.0.0',
      '1.0.1',
      '1.10.0',
    ];
    for (var i = 0; i < order.length - 1; i++) {
      expect(v(order[i + 1]) > v(order[i]), isTrue, reason: '${order[i + 1]} > ${order[i]}');
      expect(v(order[i]) > v(order[i + 1]), isFalse);
    }
    expect(v('v1.2.3+7'), v('1.2.3'));
    expect(v('1.2.3-rc.1').isPrerelease, isTrue);
    expect(AppVersion.tryParse('latest'), isNull);
    expect(v('1.0.0-beta.2').toString(), '1.0.0-beta.2');
  });

  test('releases: drafts skipped, newest first, channel filter', () {
    final json = jsonEncode([
      rel('v0.4.0'),
      rel('v1.1.0-beta.1', pre: true),
      rel('v1.0.1'),
      rel('v2.0.0', draft: true),
      rel('nightly'),
      rel('v1.2.0-beta.1'), // not flagged, but a pre-release by its version
    ]);
    final all = parseReleases(json);
    expect(all.map((r) => r.tag), ['v1.2.0-beta.1', 'v1.1.0-beta.1', 'v1.0.1', 'v0.4.0']);
    expect(all.first.prerelease, isTrue);
    final stable = newerReleases(all, v('1.0.0'), beta: false);
    expect(stable.map((r) => r.tag), ['v1.0.1']);
    final beta = newerReleases(all, v('1.0.0'), beta: true);
    expect(beta.first.tag, 'v1.2.0-beta.1');
    expect(beta, hasLength(3));
    // A beta user moves on to the final release.
    expect(newerReleases(all, v('1.0.1-beta.3'), beta: false).single.tag, 'v1.0.1');
    expect(newerReleases(all, v('1.2.0'), beta: true), isEmpty);
    expect(combinedNotes(stable), '## v1.0.1\n\nnotes v1.0.1');
  });

  test('install kind and asset names', () {
    final dir = Directory.systemTemp.createTempSync('kadra_kind');
    addTearDown(() => dir.deleteSync(recursive: true));
    const win = HostPlatform(HostOs.windows, HostArch.x64);
    const lin = HostPlatform(HostOs.linux, HostArch.x64);
    expect(detectInstallKind(host: win, exeDir: dir.path, env: {}), InstallKind.windowsPortable);
    File(p.join(dir.path, 'unins000.exe')).writeAsStringSync('');
    expect(detectInstallKind(host: win, exeDir: dir.path, env: {}), InstallKind.windowsInstaller);
    expect(
      detectInstallKind(host: lin, exeDir: dir.path, env: {'APPIMAGE': '/home/u/Kadra.AppImage'}),
      InstallKind.appImage,
    );
    expect(detectInstallKind(host: lin, exeDir: dir.path, env: {}), InstallKind.linuxBundle);
    // Must match the names written by .github/workflows/release.yml.
    final wf = File('.github/workflows/release.yml').readAsStringSync();
    for (final k in InstallKind.values) {
      final pattern = assetName(k, r'${{ needs.version.outputs.tag }}');
      expect(wf, contains(pattern), reason: '$k asset $pattern is not produced by the release workflow');
    }
    expect(wf, contains(checksumsAsset));
  });

  group('replacing files', () {
    late Directory root;
    setUp(() => root = Directory.systemTemp.createTempSync('kadra_upd'));
    tearDown(() => root.deleteSync(recursive: true));

    void write(String path, String text) {
      File(path)
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
    }

    test('findAppDir locates the unpacked folder', () {
      final app = p.join(root.path, 'x', 'kadra-v1.0.1-linux-x64');
      write(p.join(app, 'kadra'), 'bin');
      Directory(p.join(app, 'data', 'flutter_assets')).createSync(recursive: true);
      write(p.join(root.path, 'x', 'readme', 'kadra'), 'not this one');
      expect(findAppDir(root.path, 'kadra'), app);
      expect(findAppDir(root.path, 'kadra.exe'), isNull);
    });

    test('replaceTree swaps files, keeps the old ones aside, cleanup removes them', () async {
      final from = p.join(root.path, 'new'), to = p.join(root.path, 'app');
      write(p.join(to, 'kadra'), 'old exe');
      write(p.join(to, 'lib', 'libapp.so'), 'old lib');
      write(p.join(to, 'user.txt'), 'kept');
      write(p.join(from, 'kadra'), 'new exe');
      write(p.join(from, 'lib', 'libapp.so'), 'new lib');
      write(p.join(from, 'data', 'new_asset'), 'asset');
      if (!Platform.isWindows) await Process.run('chmod', ['755', p.join(from, 'kadra')]);
      // Linux: the running exe stays open while being replaced. (On Windows a
      // running image can be renamed, but a file opened by Dart cannot.)
      final open = Platform.isWindows ? null : File(p.join(to, 'kadra')).openSync();
      await replaceTree(from, to);
      open?.closeSync();
      expect(File(p.join(to, 'kadra')).readAsStringSync(), 'new exe');
      expect(File(p.join(to, 'lib', 'libapp.so')).readAsStringSync(), 'new lib');
      expect(File(p.join(to, 'data', 'new_asset')).existsSync(), isTrue);
      expect(File(p.join(to, 'user.txt')).readAsStringSync(), 'kept');
      expect(File(p.join(to, 'kadra$oldFileSuffix')).readAsStringSync(), 'old exe');
      if (!Platform.isWindows) {
        expect(File(p.join(to, 'kadra')).statSync().mode & 0x1ff, 0x1ed); // 755
      }
      expect(await cleanupOldFiles(to), 2);
      expect(File(p.join(to, 'kadra$oldFileSuffix')).existsSync(), isFalse);
    });

    test('replaceTree restores everything when a copy fails', () async {
      final from = p.join(root.path, 'new'), to = p.join(root.path, 'app');
      write(p.join(to, 'a'), 'old a');
      write(p.join(from, 'a'), 'new a');
      // A directory where a file should go makes the copy fail.
      write(p.join(from, 'b'), 'new b');
      Directory(p.join(to, 'b')).createSync();
      await expectLater(replaceTree(from, to), throwsA(isA<FileSystemException>()));
      expect(File(p.join(to, 'a')).readAsStringSync(), 'old a');
      expect(File(p.join(to, 'a$oldFileSuffix')).existsSync(), isFalse);
    });
  });

  test('settings survive a save/load round trip', () {
    const s = AppSettings(
      outputNextToSource: true,
      appChannel: AppChannel.beta,
      appUpdateHours: 24,
      appUpdateAutoDownload: false,
      skippedAppVersion: '1.0.1',
      closeToTray: false,
      preventSleep: false,
      appUpdateCheck: false,
    );
    final back = AppSettings.fromMap(jsonDecode(jsonEncode(s.toMap())) as Map<String, Object?>);
    expect(back.toMap(), s.toMap());
    expect(back.outputNextToSource, isTrue);
    // Every field is persisted (a new field missing in toMap is lost on restart).
    expect(const AppSettings().toMap().length, greaterThanOrEqualTo(34));
  });
}
