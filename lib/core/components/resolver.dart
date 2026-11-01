/// Resolves "the latest package of component X for this host" over HTTP.
///
/// Update detection does not depend on the (rate-limited) GitHub API: every
/// source publishes a checksum file at a stable URL, and a different SHA-256
/// than the installed one means an update. The API is used only to enrich
/// results with a version tag and changelog when it is reachable.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../platform/host.dart';
import 'catalog.dart';

class ResolveException implements Exception {
  ResolveException(this.message);
  final String message;
  @override
  String toString() => message;
}

class GithubRelease {
  const GithubRelease({required this.tag, required this.body, required this.assets, this.publishedAt});
  final String tag;
  final String body;
  final DateTime? publishedAt;

  /// name → (url, sha256?)
  final Map<String, ({String url, String? sha256})> assets;

  factory GithubRelease.fromJson(Map<String, dynamic> j) {
    final assets = <String, ({String url, String? sha256})>{};
    for (final a in (j['assets'] as List? ?? const [])) {
      final m = (a as Map).cast<String, dynamic>();
      final digest = m['digest'] as String?;
      assets[m['name'] as String] = (
        url: m['browser_download_url'] as String,
        sha256: digest != null && digest.startsWith('sha256:') ? digest.substring(7).toLowerCase() : null,
      );
    }
    return GithubRelease(
      tag: j['tag_name'] as String? ?? '',
      body: j['body'] as String? ?? '',
      publishedAt: DateTime.tryParse(j['published_at'] as String? ?? ''),
      assets: assets,
    );
  }
}

class ComponentResolver {
  ComponentResolver({http.Client? client, HostPlatform? host, this.userAgent = 'Kadra'})
      : _client = client ?? http.Client(),
        host = host ?? HostPlatform.current;

  final http.Client _client;
  final HostPlatform host;
  final String userAgent;

  Future<String> _getText(String url) async {
    final r = await _client.get(Uri.parse(url), headers: {'User-Agent': userAgent}).timeout(const Duration(seconds: 30));
    if (r.statusCode != 200) throw ResolveException('HTTP ${r.statusCode}: $url');
    return utf8.decode(r.bodyBytes, allowMalformed: true);
  }

  /// Optional enrichment; returns null on any failure (rate limit, offline).
  Future<GithubRelease?> latestGithubRelease(String repo, {String? tag}) async {
    try {
      final path = tag == null ? 'releases/latest' : 'releases/tags/$tag';
      final r = await _client.get(
        Uri.parse('https://api.github.com/repos/$repo/$path'),
        headers: {'User-Agent': userAgent, 'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return null;
      return GithubRelease.fromJson((jsonDecode(r.body) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<PackageSpec> resolveFfmpegBtbn({required FfmpegLicense license, required UpdateChannel channel}) async {
    final sums = parseChecksums(await _getText('$btbnDownloadBase/checksums.sha256'));
    final pick = selectBtbnAsset(sums.keys, host: host, license: license, channel: channel);
    if (pick == null) throw ResolveException('No BtbN build for $host (${license.name}, ${channel.name})');
    return PackageSpec(
      component: ComponentId.ffmpeg,
      source: ComponentSource.btbn,
      channel: channel,
      url: '$btbnDownloadBase/${pick.fileName}',
      fileName: pick.fileName,
      archive: pick.fileName.endsWith('.zip') ? ArchiveType.zip : ArchiveType.tarXz,
      sha256: sums[pick.fileName],
      versionLabel: pick.version,
      variant: license.name,
    );
  }

  Future<PackageSpec> resolveFfmpegGyan({required GyanFlavor flavor}) async {
    if (!host.isWindows) throw ResolveException('gyan.dev builds are Windows-only');
    final version = (await _getText(gyanReleaseVersionUrl)).trim();
    if (!RegExp(r'^[\w.\-]+$').hasMatch(version)) throw ResolveException('Bad gyan version: $version');
    final url = gyanUrl(flavor, version);
    String? sha;
    if (flavor == GyanFlavor.essentials) {
      sha = parseChecksums(await _getText('$url.sha256'), singleName: 'x')['x'];
    } else {
      final rel = await latestGithubRelease('GyanD/codexffmpeg', tag: version);
      sha = rel?.assets['ffmpeg-$version-full_build.zip']?.sha256;
    }
    return PackageSpec(
      component: ComponentId.ffmpeg,
      source: ComponentSource.gyan,
      channel: UpdateChannel.stable,
      url: url,
      fileName: url.split('/').last,
      archive: ArchiveType.zip,
      sha256: sha,
      versionLabel: version,
      variant: flavor.name,
    );
  }

  Future<PackageSpec> resolveYtdlp({required UpdateChannel channel}) async {
    final asset = ytdlpAssetName(host);
    if (asset == null) throw ResolveException('No yt-dlp build for $host');
    final repo = ytdlpRepo(channel);
    final sums = parseChecksums(await _getText(githubLatestDownload(repo, 'SHA2-256SUMS')));
    final rel = await latestGithubRelease(repo);
    return PackageSpec(
      component: ComponentId.ytdlp,
      source: ComponentSource.ytdlp,
      channel: channel,
      url: githubLatestDownload(repo, asset),
      fileName: asset,
      archive: ArchiveType.raw,
      sha256: sums[asset],
      versionLabel: rel?.tag,
    );
  }

  Future<PackageSpec> resolveDeno() async {
    final asset = denoAssetName(host);
    if (asset == null) throw ResolveException('No Deno build for $host');
    const repo = 'denoland/deno';
    final sums = parseChecksums(await _getText(githubLatestDownload(repo, '$asset.sha256sum')), singleName: asset);
    final rel = await latestGithubRelease(repo);
    return PackageSpec(
      component: ComponentId.deno,
      source: ComponentSource.deno,
      channel: UpdateChannel.stable,
      url: githubLatestDownload(repo, asset),
      fileName: asset,
      archive: ArchiveType.zip,
      sha256: sums[asset] ?? sums.values.firstOrNull,
      versionLabel: rel?.tag,
    );
  }

  /// aria2 names assets with the version, so the API is required here.
  Future<PackageSpec> resolveAria2() async {
    if (!host.isWindows) throw ResolveException('Install aria2 with your system package manager');
    final rel = await latestGithubRelease('aria2/aria2');
    if (rel == null) throw ResolveException('GitHub API unavailable, try again later');
    final want = host.arch == HostArch.arm64 ? 'win-arm64' : 'win-64bit';
    final entry = rel.assets.entries.where((e) => e.key.contains(want) && e.key.endsWith('.zip')).firstOrNull;
    if (entry == null) throw ResolveException('No aria2 asset for $host');
    return PackageSpec(
      component: ComponentId.aria2,
      source: ComponentSource.aria2,
      channel: UpdateChannel.stable,
      url: entry.value.url,
      fileName: entry.key,
      archive: ArchiveType.zip,
      sha256: entry.value.sha256,
      versionLabel: rel.tag,
    );
  }

  void close() => _client.close();
}
