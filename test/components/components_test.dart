import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kadra/core/components/catalog.dart';
import 'package:kadra/core/components/component_store.dart';
import 'package:kadra/core/components/downloader.dart';
import 'package:kadra/core/components/installer.dart';
import 'package:kadra/core/components/resolver.dart';
import 'package:kadra/core/components/toolchain.dart';
import 'package:kadra/core/platform/host.dart';
import 'package:kadra/core/settings/app_settings.dart';
import 'package:path/path.dart' as p;

String fx(String name) => File('test/fixtures/$name').readAsStringSync();

const win = HostPlatform(HostOs.windows, HostArch.x64);
const linux = HostPlatform(HostOs.linux, HostArch.x64);
const linuxArm = HostPlatform(HostOs.linux, HostArch.arm64);

void main() {
  group('checksums', () {
    test('BtbN file', () {
      final sums = parseChecksums(fx('btbn_checksums.sha256'));
      expect(sums.length, greaterThan(20));
      expect(sums.values.every((v) => RegExp(r'^[0-9a-f]{64}$').hasMatch(v)), isTrue);
    });
    test('bare hash and binary marker', () {
      expect(parseChecksums('${'A' * 64}\n', singleName: 'f.zip'), {'f.zip': 'a' * 64});
      expect(parseChecksums('${'b' * 64} *dir/x.exe'), {'x.exe': 'b' * 64});
      expect(parseChecksums('garbage\n'), isEmpty);
    });
  });

  group('BtbN asset selection', () {
    final names = parseChecksums(fx('btbn_checksums.sha256')).keys.toList();

    test('stable picks the newest numbered release, static, right license', () {
      final w = selectBtbnAsset(names, host: win, license: FfmpegLicense.gpl, channel: UpdateChannel.stable)!;
      expect(w.fileName, matches(RegExp(r'^ffmpeg-n\d+\.\d+-latest-win64-gpl-\d+\.\d+\.zip$')));
      expect(w.fileName, isNot(contains('shared')));
      final l = selectBtbnAsset(names, host: linux, license: FfmpegLicense.lgpl, channel: UpdateChannel.stable)!;
      expect(l.fileName, matches(RegExp(r'^ffmpeg-n\d+\.\d+-latest-linux64-lgpl-\d+\.\d+\.tar\.xz$')));
      expect(l.version, startsWith('n'));
    });

    test('newest version wins numerically', () {
      final r = selectBtbnAsset(
        [
          'ffmpeg-n9.0-latest-linux64-gpl-9.0.tar.xz',
          'ffmpeg-n10.1-latest-linux64-gpl-10.1.tar.xz',
          'ffmpeg-n9.10-latest-linux64-gpl-9.10.tar.xz',
        ],
        host: linux,
        license: FfmpegLicense.gpl,
        channel: UpdateChannel.stable,
      )!;
      expect(r.version, 'n10.1');
    });

    test('nightly picks master', () {
      final r = selectBtbnAsset(names, host: linuxArm, license: FfmpegLicense.gpl, channel: UpdateChannel.nightly)!;
      expect(r.fileName, 'ffmpeg-master-latest-linuxarm64-gpl.tar.xz');
      expect(r.version, 'master');
    });

    test('unsupported platform', () {
      expect(
        selectBtbnAsset(
          names,
          host: const HostPlatform(HostOs.macos, HostArch.arm64),
          license: FfmpegLicense.gpl,
          channel: UpdateChannel.stable,
        ),
        isNull,
      );
    });
  });

  test('yt-dlp asset names exist in the real SHA2-256SUMS', () {
    final sums = parseChecksums(fx('ytdlp_SHA2-256SUMS'));
    for (final h in [win, linux, linuxArm, const HostPlatform(HostOs.windows, HostArch.arm64)]) {
      expect(sums.containsKey(ytdlpAssetName(h)), isTrue, reason: '$h');
    }
  });

  group('resolver with mocked HTTP', () {
    test('BtbN resolves URL and checksum', () async {
      final client = MockClient((req) async {
        expect(req.url.toString(), '$btbnDownloadBase/checksums.sha256');
        return http.Response(fx('btbn_checksums.sha256'), 200);
      });
      final spec = await ComponentResolver(
        client: client,
        host: linux,
      ).resolveFfmpegBtbn(license: FfmpegLicense.gpl, channel: UpdateChannel.nightly);
      expect(spec.url, '$btbnDownloadBase/ffmpeg-master-latest-linux64-gpl.tar.xz');
      expect(spec.archive, ArchiveType.tarXz);
      expect(spec.sha256, hasLength(64));
      expect(spec.variant, 'gpl');
    });

    test('yt-dlp uses checksum file; API is optional', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.github.com') return http.Response('rate limited', 403);
        expect(req.url.toString(), githubLatestDownload('yt-dlp/yt-dlp-nightly-builds', 'SHA2-256SUMS'));
        return http.Response(fx('ytdlp_SHA2-256SUMS'), 200);
      });
      final spec = await ComponentResolver(client: client, host: win).resolveYtdlp(channel: UpdateChannel.nightly);
      expect(spec.fileName, 'yt-dlp.exe');
      expect(spec.archive, ArchiveType.raw);
      expect(spec.sha256, hasLength(64));
      expect(spec.versionLabel, isNull);
    });

    test('gyan essentials', () async {
      final client = MockClient((req) async {
        final u = req.url.toString();
        if (u == gyanReleaseVersionUrl) return http.Response('9.0.2\n', 200);
        if (u.endsWith('.sha256')) return http.Response('c' * 64, 200);
        return http.Response('', 404);
      });
      final spec = await ComponentResolver(client: client, host: win).resolveFfmpegGyan(flavor: GyanFlavor.essentials);
      expect(spec.url, '$gyanBase/ffmpeg-release-essentials.zip');
      expect(spec.sha256, 'c' * 64);
      expect(spec.versionLabel, '9.0.2');
      expect(
        gyanUrl(GyanFlavor.full, '9.0.2'),
        'https://github.com/GyanD/codexffmpeg/releases/download/9.0.2/ffmpeg-9.0.2-full_build.zip',
      );
    });

    test('github release json', () {
      final r = GithubRelease.fromJson({
        'tag_name': '2026.10.22',
        'body': 'notes',
        'published_at': '2026-10-22T10:00:00Z',
        'assets': [
          {'name': 'a.zip', 'browser_download_url': 'https://x/a.zip', 'digest': 'sha256:${'D' * 64}'},
          {'name': 'b.zip', 'browser_download_url': 'https://x/b.zip', 'digest': null},
        ],
      });
      expect(r.tag, '2026.10.22');
      expect(r.assets['a.zip']!.sha256, 'd' * 64);
      expect(r.assets['b.zip']!.sha256, isNull);
    });
  });

  group('download', () {
    test('streams, hashes and verifies', () async {
      final dir = await Directory.systemTemp.createTemp('kadra');
      final body = List<int>.generate(100000, (i) => i % 251);
      final client = MockClient.streaming(
        (req, _) async => http.StreamedResponse(Stream.value(body), 200, contentLength: body.length),
      );
      final dest = p.join(dir.path, 'f.bin');
      final sha = await downloadFile('https://x/f.bin', dest, client: client);
      expect(await File(dest).length(), body.length);
      expect(await sha256OfFile(dest), sha);

      await expectLater(
        downloadFile('https://x/f.bin', p.join(dir.path, 'g.bin'), client: client, expectedSha256: '0' * 64),
        throwsA(isA<ChecksumMismatch>()),
      );
      expect(File(p.join(dir.path, 'g.bin')).existsSync(), isFalse, reason: 'bad file is deleted');
      await dir.delete(recursive: true);
    });

    test('HTTP errors fail', () async {
      final dir = await Directory.systemTemp.createTemp('kadra');
      final client = MockClient((_) async => http.Response('nope', 404));
      await expectLater(
        downloadFile('https://x/f', p.join(dir.path, 'f'), client: client),
        throwsA(isA<HttpException>()),
      );
      await dir.delete(recursive: true);
    });
  });

  group('installer', () {
    test('extracts tar.xz and zip, locates binaries', () async {
      final dir = await Directory.systemTemp.createTemp('kadra');
      final src = Directory(p.join(dir.path, 'src', 'ffmpeg-x', 'bin'))..createSync(recursive: true);
      File(p.join(src.path, 'ffmpeg')).writeAsStringSync('#!/bin/sh\necho ffmpeg version 9.9-test\n');
      File(p.join(src.path, 'ffprobe')).writeAsStringSync('x');
      Directory(p.join(dir.path, 'src', 'ffmpeg-x', 'doc', 'examples')).createSync(recursive: true);
      File(p.join(dir.path, 'src', 'ffmpeg-x', 'doc', 'examples', 'ffmpeg')).writeAsStringSync('decoy');

      final txz = p.join(dir.path, 'a.tar.xz');
      final tarOk = await Process.run('tar', ['-cJf', txz, '-C', p.join(dir.path, 'src'), 'ffmpeg-x']);
      if (tarOk.exitCode == 0) {
        final out = p.join(dir.path, 'out1');
        await extractArchive(txz, out, ArchiveType.tarXz, host: linux);
        final bins = locateBinaries(out, ['ffmpeg', 'ffprobe'], host: linux);
        expect(bins['ffmpeg'], p.join('ffmpeg-x', 'bin', 'ffmpeg'));
        expect(bins['ffprobe'], p.join('ffmpeg-x', 'bin', 'ffprobe'));
        await makeExecutable(p.join(out, bins['ffmpeg']!), host: linux);
        final v = await probeComponentVersion(ComponentId.ffmpeg, p.join(out, bins['ffmpeg']!));
        expect(v, '9.9-test');
      }

      if (await _has('zip')) {
        final zip = p.join(dir.path, 'a.zip');
        await Process.run('zip', ['-qr', zip, 'ffmpeg-x'], workingDirectory: p.join(dir.path, 'src'));
        final out = p.join(dir.path, 'out2');
        await extractArchive(zip, out, ArchiveType.zip, host: linux);
        expect(locateBinaries(out, ['ffmpeg'], host: linux), {'ffmpeg': p.join('ffmpeg-x', 'bin', 'ffmpeg')});
      }

      // Windows names get .exe
      final w = Directory(p.join(dir.path, 'w', 'bin'))..createSync(recursive: true);
      File(p.join(w.path, 'yt-dlp.exe')).writeAsStringSync('x');
      expect(locateBinaries(p.join(dir.path, 'w'), ['yt-dlp'], host: win), {'yt-dlp': p.join('bin', 'yt-dlp.exe')});
      await dir.delete(recursive: true);
    });

    test('version parsing per component', () {
      expect(parseComponentVersion(ComponentId.ytdlp, '2026.10.22\n'), '2026.10.22');
      expect(
        parseComponentVersion(ComponentId.deno, 'deno 2.5.1 (stable, release, x86_64-unknown-linux-gnu)\nv8 14'),
        '2.5.1',
      );
      expect(parseComponentVersion(ComponentId.aria2, 'aria2 version 1.37.0\nCopyright'), '1.37.0');
      expect(parseComponentVersion(ComponentId.ffmpeg, 'ffmpeg version n8.1-3-gabc Copyright'), 'n8.1-3-gabc');
    });
  });

  group('store', () {
    test('roundtrip, active and rollback candidates', () async {
      final dir = await Directory.systemTemp.createTemp('kadra');
      final store = ComponentStore(p.join(dir.path, 'state.json'));
      expect(await store.load(), isEmpty);
      final a = InstalledVersion(
        key: '2',
        source: ComponentSource.btbn,
        channel: UpdateChannel.stable,
        variant: 'gpl',
        version: 'n9.0',
        sha256: 'x',
        installedAt: DateTime(2026),
        binaries: const {'ffmpeg': 'bin/ffmpeg'},
      );
      final b = InstalledVersion(
        key: '1',
        source: ComponentSource.btbn,
        channel: UpdateChannel.stable,
        installedAt: DateTime(2025),
        binaries: const {},
      );
      await store.save({
        ComponentId.ffmpeg: ComponentRecord(active: '2', installs: [a, b]),
      });
      final loaded = await store.load();
      final rec = loaded[ComponentId.ffmpeg]!;
      expect(rec.activeInstall!.version, 'n9.0');
      expect(rec.activeInstall!.binaries['ffmpeg'], 'bin/ffmpeg');
      expect(rec.previous.map((i) => i.key), ['1']);

      File(p.join(dir.path, 'state.json')).writeAsStringSync('{broken');
      expect(await store.load(), isEmpty);
      expect(File(p.join(dir.path, 'state.json.corrupt')).existsSync(), isTrue);
      await dir.delete(recursive: true);
    });
  });

  group('toolchain', () {
    final records = {
      ComponentId.ffmpeg: ComponentRecord(
        active: 'k',
        installs: [
          InstalledVersion(
            key: 'k',
            source: ComponentSource.btbn,
            channel: UpdateChannel.stable,
            installedAt: DateTime(2026),
            binaries: const {'ffmpeg': 'bin/ffmpeg', 'ffprobe': 'bin/ffprobe'},
          ),
        ],
      ),
    };

    test('custom > managed > system', () {
      final existing = {'/c/ffmpeg', '/c/ffprobe', '/root/ffmpeg/k/bin/ffmpeg', '/root/ffmpeg/k/bin/ffprobe'};
      Toolchain r(AppSettings s) => Toolchain.resolve(
        settings: s,
        records: records,
        componentsRoot: '/root',
        host: linux,
        exists: existing.contains,
        which: (n) => '/usr/bin/$n',
      );
      final managed = r(const AppSettings());
      expect(managed.ffmpeg.origin, ToolOrigin.managed);
      expect(managed.ffmpeg.path, '/root/ffmpeg/k/bin/ffmpeg');
      expect(managed.ytdlp.origin, ToolOrigin.system);

      final custom = r(const AppSettings(customFfmpegPath: '/c/ffmpeg'));
      expect(custom.ffmpeg.origin, ToolOrigin.custom);
      expect(custom.ffprobe.path, '/c/ffprobe', reason: 'sibling ffprobe');
    });

    test('nothing installed', () {
      final t = Toolchain.resolve(
        settings: const AppSettings(),
        records: const {},
        componentsRoot: '/r',
        host: linux,
        exists: (_) => false,
        which: (_) => null,
      );
      expect(t.hasFfmpeg, isFalse);
      expect(t.ffmpeg.origin, ToolOrigin.none);
    });
  });
}

Future<bool> _has(String tool) async => findOnPath(tool) != null;
