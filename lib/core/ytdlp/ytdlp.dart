/// yt-dlp wrapper: metadata (`-J --flat-playlist`) and download arguments.
/// Every option used here is listed in `yt-dlp --help` (2026.10).
library;

import '../engine/progress.dart' show ytdlpProgressTemplate;
import '../queue/job_steps.dart' show ytdlpFileMarker;

/// [deno]: YouTube needs a JavaScript runtime to list most formats.
List<String> ytdlpInfoArgs(String url, {String? cookiesFromBrowser, String? proxy, String? deno}) => [
  '-J',
  '--flat-playlist',
  '--no-warnings',
  '--no-colors',
  if (deno != null) ...['--js-runtimes', 'deno:$deno'],
  if (cookiesFromBrowser != null) ...['--cookies-from-browser', cookiesFromBrowser],
  if (proxy != null) ...['--proxy', proxy],
  url,
];

class YtFormat {
  const YtFormat({
    required this.id,
    this.ext,
    this.vcodec,
    this.acodec,
    this.width,
    this.height,
    this.fps,
    this.tbr,
    this.filesize,
    this.note,
    this.protocol,
  });

  final String id;
  final String? ext;
  final String? vcodec;
  final String? acodec;
  final int? width;
  final int? height;
  final double? fps;

  /// Total bitrate, kbps.
  final double? tbr;

  /// Exact or approximate size in bytes.
  final int? filesize;
  final String? note;
  final String? protocol;

  bool get hasVideo => vcodec != null && vcodec != 'none';
  bool get hasAudio => acodec != null && acodec != 'none';
  bool get isStoryboard => ext == 'mhtml' || (note?.contains('storyboard') ?? false);

  factory YtFormat.fromJson(Map<String, dynamic> j) => YtFormat(
    id: j['format_id'].toString(),
    ext: j['ext'] as String?,
    vcodec: j['vcodec'] as String?,
    acodec: j['acodec'] as String?,
    width: (j['width'] as num?)?.toInt(),
    height: (j['height'] as num?)?.toInt(),
    fps: (j['fps'] as num?)?.toDouble(),
    tbr: (j['tbr'] as num?)?.toDouble(),
    filesize: ((j['filesize'] ?? j['filesize_approx']) as num?)?.toInt(),
    note: j['format_note'] as String?,
    protocol: j['protocol'] as String?,
  );
}

class YtEntry {
  const YtEntry({required this.index, required this.url, this.id, this.title, this.duration});

  /// 1-based position in the playlist.
  final int index;
  final String url;
  final String? id;
  final String? title;
  final Duration? duration;
}

class YtInfo {
  const YtInfo({
    required this.isPlaylist,
    this.id,
    this.title,
    this.uploader,
    this.duration,
    this.thumbnail,
    this.webpageUrl,
    this.formats = const [],
    this.entries = const [],
    this.hasSubtitles = false,
    this.hasAutoSubtitles = false,
    this.subtitleLangs = const [],
  });

  final bool isPlaylist;
  final String? id;
  final String? title;
  final String? uploader;
  final Duration? duration;
  final String? thumbnail;
  final String? webpageUrl;
  final List<YtFormat> formats;
  final List<YtEntry> entries;
  final bool hasSubtitles;
  final bool hasAutoSubtitles;
  final List<String> subtitleLangs;

  /// Distinct video heights, highest first (for the quality picker).
  List<int> get heights {
    final h = {
      for (final f in formats)
        if (f.hasVideo && f.height != null && !f.isStoryboard) f.height!,
    }.toList()..sort((a, b) => b.compareTo(a));
    return h;
  }

  factory YtInfo.fromJson(Map<String, dynamic> j) {
    final type = j['_type'] as String?;
    final isPlaylist = type == 'playlist' || type == 'multi_video';
    final entries = <YtEntry>[];
    if (isPlaylist) {
      var i = 0;
      for (final e in (j['entries'] as List? ?? const [])) {
        i++;
        if (e is! Map) continue;
        final m = e.cast<String, dynamic>();
        final url = (m['url'] ?? m['webpage_url'] ?? m['original_url']) as String?;
        if (url == null) continue;
        entries.add(
          YtEntry(
            index: i,
            url: url,
            id: m['id'] as String?,
            title: m['title'] as String?,
            duration: (m['duration'] as num?) == null
                ? null
                : Duration(milliseconds: ((m['duration'] as num) * 1000).round()),
          ),
        );
      }
    }
    final subs = (j['subtitles'] as Map?)?.keys.map((k) => k.toString()).toList() ?? const <String>[];
    final auto = (j['automatic_captions'] as Map?) ?? const {};
    final dur = j['duration'] as num?;
    return YtInfo(
      isPlaylist: isPlaylist,
      id: j['id']?.toString(),
      title: j['title'] as String?,
      uploader: (j['uploader'] ?? j['channel']) as String?,
      duration: dur == null ? null : Duration(milliseconds: (dur * 1000).round()),
      thumbnail: j['thumbnail'] as String? ?? _bestThumb(j['thumbnails']),
      webpageUrl: j['webpage_url'] as String?,
      formats: [
        for (final f in (j['formats'] as List? ?? const []))
          if (f is Map) YtFormat.fromJson(f.cast<String, dynamic>()),
      ],
      entries: entries,
      hasSubtitles: subs.isNotEmpty,
      hasAutoSubtitles: auto.isNotEmpty,
      subtitleLangs: subs,
    );
  }
}

String? _bestThumb(Object? thumbs) {
  if (thumbs is! List || thumbs.isEmpty) return null;
  final last = thumbs.last;
  return last is Map ? last['url'] as String? : null;
}

enum YtQuality { best, maxHeight, audioOnly, format }

enum YtAudioFormat { best, mp3, m4a, opus, flac }

enum SponsorBlockMode { off, mark, remove }

class YtDownloadParams {
  const YtDownloadParams({
    this.quality = YtQuality.best,
    this.maxHeight = 1080,
    this.audioFormat = YtAudioFormat.mp3,
    this.formatId,
    this.container = 'mp4',
    this.subtitles = false,
    this.autoSubtitles = false,
    this.subLangs = 'ru,en',
    this.embedSubs = true,
    this.embedThumbnail = true,
    this.embedMetadata = true,
    this.embedChapters = true,
    this.sponsorBlock = SponsorBlockMode.off,
    this.cookiesFromBrowser,
    this.template = '%(title)s [%(id)s].%(ext)s',
    this.rateLimit,
    this.proxy,
    this.archiveFile,
  });

  final YtQuality quality;
  final int maxHeight;
  final YtAudioFormat audioFormat;

  /// Exact format id when [quality] is [YtQuality.format].
  final String? formatId;

  /// `mp4`, `mkv`, `webm`, or null (whatever the site serves).
  final String? container;
  final bool subtitles;
  final bool autoSubtitles;
  final String subLangs;
  final bool embedSubs;
  final bool embedThumbnail;
  final bool embedMetadata;
  final bool embedChapters;
  final SponsorBlockMode sponsorBlock;

  /// `chrome`, `firefox`, `edge`, ... (`--cookies-from-browser`).
  final String? cookiesFromBrowser;
  final String template;

  /// e.g. `5M` (bytes/s, yt-dlp syntax).
  final String? rateLimit;
  final String? proxy;

  /// `--download-archive` file to skip already downloaded videos.
  final String? archiveFile;

  YtDownloadParams copyWith({
    YtQuality? quality,
    int? maxHeight,
    YtAudioFormat? audioFormat,
    String? Function()? formatId,
    String? Function()? container,
    bool? subtitles,
    bool? autoSubtitles,
    String? subLangs,
    bool? embedSubs,
    bool? embedThumbnail,
    bool? embedMetadata,
    bool? embedChapters,
    SponsorBlockMode? sponsorBlock,
    String? Function()? cookiesFromBrowser,
    String? template,
    String? Function()? rateLimit,
    String? Function()? proxy,
    String? Function()? archiveFile,
  }) => YtDownloadParams(
    quality: quality ?? this.quality,
    maxHeight: maxHeight ?? this.maxHeight,
    audioFormat: audioFormat ?? this.audioFormat,
    formatId: formatId != null ? formatId() : this.formatId,
    container: container != null ? container() : this.container,
    subtitles: subtitles ?? this.subtitles,
    autoSubtitles: autoSubtitles ?? this.autoSubtitles,
    subLangs: subLangs ?? this.subLangs,
    embedSubs: embedSubs ?? this.embedSubs,
    embedThumbnail: embedThumbnail ?? this.embedThumbnail,
    embedMetadata: embedMetadata ?? this.embedMetadata,
    embedChapters: embedChapters ?? this.embedChapters,
    sponsorBlock: sponsorBlock ?? this.sponsorBlock,
    cookiesFromBrowser: cookiesFromBrowser != null ? cookiesFromBrowser() : this.cookiesFromBrowser,
    template: template ?? this.template,
    rateLimit: rateLimit != null ? rateLimit() : this.rateLimit,
    proxy: proxy != null ? proxy() : this.proxy,
    archiveFile: archiveFile != null ? archiveFile() : this.archiveFile,
  );
}

/// Tools yt-dlp should use (all optional).
class YtTools {
  const YtTools({this.ffmpeg, this.deno, this.aria2c, this.concurrentFragments = 4});
  final String? ffmpeg;
  final String? deno;
  final String? aria2c;
  final int concurrentFragments;
}

/// Format selector for the chosen quality.
List<String> ytdlpFormatArgs(YtDownloadParams p, {YtFormat? chosen}) {
  switch (p.quality) {
    case YtQuality.best:
      return [
        '-f',
        'bv*+ba/b',
        if (p.container == 'mp4') ...['-S', 'vcodec:h264,res,acodec:m4a'],
      ];
    case YtQuality.maxHeight:
      final h = p.maxHeight;
      return [
        '-f',
        'bv*[height<=$h]+ba/b[height<=$h]/bv*+ba/b',
        if (p.container == 'mp4') ...['-S', 'vcodec:h264,res,acodec:m4a'],
      ];
    case YtQuality.audioOnly:
      return [
        '-f',
        'ba/b',
        '-x',
        if (p.audioFormat != YtAudioFormat.best) ...['--audio-format', p.audioFormat.name, '--audio-quality', '0'],
      ];
    case YtQuality.format:
      final id = p.formatId ?? 'b';
      // A video-only format needs the best audio merged in.
      final needsAudio = chosen != null && chosen.hasVideo && !chosen.hasAudio;
      return ['-f', needsAudio ? '$id+ba/$id' : id];
  }
}

/// Full argument list for downloading [url] into [outputDir].
List<String> ytdlpDownloadArgs({
  required String url,
  required String outputDir,
  required YtDownloadParams p,
  YtTools tools = const YtTools(),
  YtFormat? chosen,
  bool singleItem = true,
}) {
  final audioOnly = p.quality == YtQuality.audioOnly;
  return [
    '--newline',
    '--no-colors',
    '--progress',
    '--progress-template',
    ytdlpProgressTemplate,
    // Printed once the file is in its final place; the queue reads it.
    '--print',
    'after_move:$ytdlpFileMarker%(filepath)s',
    if (singleItem) '--no-playlist',
    '-N',
    '${tools.concurrentFragments}',
    if (tools.ffmpeg != null) ...['--ffmpeg-location', tools.ffmpeg!],
    if (tools.deno != null) ...['--js-runtimes', 'deno:${tools.deno}'],
    if (tools.aria2c != null) ...['--downloader', tools.aria2c!],
    ...ytdlpFormatArgs(p, chosen: chosen),
    if (!audioOnly && p.container != null) ...['--merge-output-format', p.container!],
    if (!audioOnly && (p.subtitles || p.autoSubtitles)) ...[
      if (p.subtitles) '--write-subs',
      if (p.autoSubtitles) '--write-auto-subs',
      '--sub-langs',
      p.subLangs,
      if (p.embedSubs) '--embed-subs',
    ],
    if (p.embedThumbnail) '--embed-thumbnail',
    if (p.embedMetadata) '--embed-metadata',
    if (p.embedChapters && !audioOnly) '--embed-chapters',
    if (p.sponsorBlock == SponsorBlockMode.mark) ...['--sponsorblock-mark', 'all'],
    if (p.sponsorBlock == SponsorBlockMode.remove) ...['--sponsorblock-remove', 'sponsor,selfpromo,interaction'],
    if (p.cookiesFromBrowser != null) ...['--cookies-from-browser', p.cookiesFromBrowser!],
    if (p.rateLimit != null) ...['-r', p.rateLimit!],
    if (p.proxy != null) ...['--proxy', p.proxy!],
    if (p.archiveFile != null) ...['--download-archive', p.archiveFile!],
    '-P',
    outputDir,
    '-o',
    p.template,
    url,
  ];
}

final _urlRe = RegExp(r'''https?://[^\s<>"']+''');

/// All http(s) links in pasted text (one per line, or mixed with words).
List<String> extractUrls(String text) => _urlRe
    .allMatches(text)
    // Trailing punctuation belongs to the sentence, not the link.
    .map((m) => m.group(0)!.replaceFirst(RegExp(r'[.,;:!?)\]]+$'), ''))
    .toSet()
    .toList();

/// "1,3,5-7" → {1,3,5,6,7}. Invalid parts are ignored.
Set<int> parseItemRanges(String text, {int? max}) {
  final out = <int>{};
  for (final part in text.split(',')) {
    final t = part.trim();
    if (t.isEmpty) continue;
    final r = RegExp(r'^(\d+)\s*-\s*(\d+)$').firstMatch(t);
    if (r != null) {
      final a = int.parse(r.group(1)!);
      final b = int.parse(r.group(2)!);
      for (var i = a; i <= b && (max == null || i <= max); i++) {
        if (i > 0) out.add(i);
      }
    } else {
      final n = int.tryParse(t);
      if (n != null && n > 0 && (max == null || n <= max)) out.add(n);
    }
  }
  return out;
}
