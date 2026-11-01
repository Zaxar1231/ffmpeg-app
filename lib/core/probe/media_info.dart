/// Typed view of `ffprobe -print_format json -show_format -show_streams
/// -show_chapters` output. Every field is optional: ffprobe omits what it
/// does not know, and values are often strings ("N/A", "30000/1001").
library;

import '../engine/capabilities.dart' show MediaKind;

class MediaInfo {
  const MediaInfo({
    required this.path,
    required this.format,
    required this.streams,
    required this.chapters,
  });

  final String path;
  final FormatInfo format;
  final List<StreamInfo> streams;
  final List<ChapterInfo> chapters;

  factory MediaInfo.fromJson(String path, Map<String, dynamic> json) => MediaInfo(
        path: path,
        format: FormatInfo.fromJson((json['format'] as Map?)?.cast<String, dynamic>() ?? const {}),
        streams: [
          for (final s in (json['streams'] as List? ?? const [])) StreamInfo.fromJson((s as Map).cast<String, dynamic>()),
        ],
        chapters: [
          for (final c in (json['chapters'] as List? ?? const [])) ChapterInfo.fromJson((c as Map).cast<String, dynamic>()),
        ],
      );

  Iterable<StreamInfo> get videoStreams => streams.where((s) => s.kind == MediaKind.video && !s.isAttachedPicture);
  Iterable<StreamInfo> get audioStreams => streams.where((s) => s.kind == MediaKind.audio);
  Iterable<StreamInfo> get subtitleStreams => streams.where((s) => s.kind == MediaKind.subtitle);
  StreamInfo? get coverArt => streams.where((s) => s.isAttachedPicture).firstOrNull;

  /// Best known duration: container, else the longest stream.
  Duration? get duration {
    if (format.duration != null) return format.duration;
    Duration? best;
    for (final s in streams) {
      final d = s.duration;
      if (d != null && (best == null || d > best)) best = d;
    }
    return best;
  }

  /// What kind of file this is, for smart quick actions.
  MediaCategory get category {
    final hasVideo = videoStreams.isNotEmpty;
    final hasAudio = audioStreams.isNotEmpty;
    if (hasVideo) {
      final v = videoStreams.first;
      final singleFrame = (v.frameCount ?? 0) <= 1 && (duration == null || duration! <= const Duration(milliseconds: 100));
      if (!hasAudio && (_imageCodecs.contains(v.codecName) || singleFrame)) {
        return (v.frameCount ?? 1) > 1 ? MediaCategory.animation : MediaCategory.image;
      }
      return MediaCategory.video;
    }
    if (hasAudio) return MediaCategory.audio;
    if (subtitleStreams.isNotEmpty) return MediaCategory.subtitle;
    return MediaCategory.other;
  }
}

const _imageCodecs = {'png', 'mjpeg', 'jpegls', 'webp', 'bmp', 'tiff', 'gif', 'jpeg2000', 'av1_image', 'qoi', 'jpegxl', 'apng'};

enum MediaCategory { video, audio, image, animation, subtitle, other }

class FormatInfo {
  const FormatInfo({
    this.formatName,
    this.formatLongName,
    this.duration,
    this.size,
    this.bitRate,
    this.startTime,
    this.probeScore,
    this.tags = const {},
  });

  final String? formatName;
  final String? formatLongName;
  final Duration? duration;
  final int? size;
  final int? bitRate;
  final Duration? startTime;
  final int? probeScore;
  final Map<String, String> tags;

  factory FormatInfo.fromJson(Map<String, dynamic> j) => FormatInfo(
        formatName: j['format_name'] as String?,
        formatLongName: j['format_long_name'] as String?,
        duration: parseSeconds(j['duration']),
        size: parseIntField(j['size']),
        bitRate: parseIntField(j['bit_rate']),
        startTime: parseSeconds(j['start_time']),
        probeScore: parseIntField(j['probe_score']),
        tags: _tags(j['tags']),
      );
}

class StreamInfo {
  const StreamInfo({
    required this.index,
    required this.kind,
    this.codecName,
    this.codecLongName,
    this.profile,
    this.codecTag,
    this.width,
    this.height,
    this.sampleAspectRatio,
    this.displayAspectRatio,
    this.pixFmt,
    this.level,
    this.fieldOrder,
    this.colorRange,
    this.colorSpace,
    this.colorTransfer,
    this.colorPrimaries,
    this.bitsPerRawSample,
    this.frameRate,
    this.avgFrameRate,
    this.sampleRate,
    this.channels,
    this.channelLayout,
    this.sampleFmt,
    this.bitRate,
    this.duration,
    this.frameCount,
    this.disposition = const {},
    this.tags = const {},
    this.sideData = const [],
    this.rotation,
  });

  final int index;
  final MediaKind kind;
  final String? codecName;
  final String? codecLongName;
  final String? profile;
  final String? codecTag;
  final int? width;
  final int? height;
  final String? sampleAspectRatio;
  final String? displayAspectRatio;
  final String? pixFmt;
  final int? level;
  final String? fieldOrder;
  final String? colorRange;
  final String? colorSpace;
  final String? colorTransfer;
  final String? colorPrimaries;
  final int? bitsPerRawSample;
  final double? frameRate;
  final double? avgFrameRate;
  final int? sampleRate;
  final int? channels;
  final String? channelLayout;
  final String? sampleFmt;
  final int? bitRate;
  final Duration? duration;
  final int? frameCount;
  final Map<String, int> disposition;
  final Map<String, String> tags;
  final List<Map<String, dynamic>> sideData;

  /// Display rotation in degrees from the display matrix side data.
  final int? rotation;

  factory StreamInfo.fromJson(Map<String, dynamic> j) {
    final side = [
      for (final s in (j['side_data_list'] as List? ?? const [])) (s as Map).cast<String, dynamic>(),
    ];
    int? rotation;
    for (final s in side) {
      final r = s['rotation'];
      if (r is num) rotation = r.toInt();
    }
    rotation ??= parseIntField(_tags(j['tags'])['rotate']);
    return StreamInfo(
      index: parseIntField(j['index']) ?? 0,
      kind: switch (j['codec_type']) {
        'video' => MediaKind.video,
        'audio' => MediaKind.audio,
        'subtitle' => MediaKind.subtitle,
        'data' => MediaKind.data,
        'attachment' => MediaKind.attachment,
        _ => MediaKind.unknown,
      },
      codecName: j['codec_name'] as String?,
      codecLongName: j['codec_long_name'] as String?,
      profile: j['profile'] as String?,
      codecTag: j['codec_tag_string'] as String?,
      width: parseIntField(j['width']),
      height: parseIntField(j['height']),
      sampleAspectRatio: j['sample_aspect_ratio'] as String?,
      displayAspectRatio: j['display_aspect_ratio'] as String?,
      pixFmt: j['pix_fmt'] as String?,
      level: parseIntField(j['level']),
      fieldOrder: j['field_order'] as String?,
      colorRange: j['color_range'] as String?,
      colorSpace: j['color_space'] as String?,
      colorTransfer: j['color_transfer'] as String?,
      colorPrimaries: j['color_primaries'] as String?,
      bitsPerRawSample: parseIntField(j['bits_per_raw_sample']),
      frameRate: parseRational(j['r_frame_rate']),
      avgFrameRate: parseRational(j['avg_frame_rate']),
      sampleRate: parseIntField(j['sample_rate']),
      channels: parseIntField(j['channels']),
      channelLayout: j['channel_layout'] as String?,
      sampleFmt: j['sample_fmt'] as String?,
      bitRate: parseIntField(j['bit_rate']) ?? parseIntField(_tags(j['tags'])['BPS']),
      duration: parseSeconds(j['duration']) ?? parseTagDuration(_tags(j['tags'])['DURATION']),
      frameCount: parseIntField(j['nb_frames']) ?? parseIntField(_tags(j['tags'])['NUMBER_OF_FRAMES']),
      disposition: {
        for (final e in ((j['disposition'] as Map?) ?? const {}).entries)
          if (e.value is num) e.key as String: (e.value as num).toInt(),
      },
      tags: _tags(j['tags']),
      sideData: side,
      rotation: rotation,
    );
  }

  bool get isAttachedPicture => (disposition['attached_pic'] ?? 0) == 1;
  bool get isDefault => (disposition['default'] ?? 0) == 1;
  bool get isForced => (disposition['forced'] ?? 0) == 1;
  String? get language => tags['language'];
  String? get title => tags['title'];

  /// HDR10 / HLG / Dolby Vision detection from transfer and side data.
  HdrKind get hdr {
    if (sideData.any((s) => (s['side_data_type'] as String? ?? '').contains('DOVI'))) return HdrKind.dolbyVision;
    switch (colorTransfer) {
      case 'smpte2084':
        return HdrKind.hdr10;
      case 'arib-std-b67':
        return HdrKind.hlg;
    }
    return HdrKind.sdr;
  }

  /// Bit depth from raw sample bits or the pixel format name.
  int? get bitDepth {
    if (bitsPerRawSample != null && bitsPerRawSample! > 0) return bitsPerRawSample;
    final m = RegExp(r'p(\d{2})(?:le|be)?$').firstMatch(pixFmt ?? '');
    if (m != null) return int.parse(m.group(1)!);
    if (pixFmt != null && kind == MediaKind.video) return 8;
    return null;
  }

  /// HDR mastering metadata, if present.
  Map<String, dynamic>? get masteringDisplay =>
      sideData.where((s) => s['side_data_type'] == 'Mastering display metadata').firstOrNull;
  Map<String, dynamic>? get contentLight =>
      sideData.where((s) => s['side_data_type'] == 'Content light level metadata').firstOrNull;
}

enum HdrKind { sdr, hdr10, hlg, dolbyVision }

class ChapterInfo {
  const ChapterInfo({required this.id, required this.start, required this.end, this.title});
  final int id;
  final Duration start;
  final Duration end;
  final String? title;

  factory ChapterInfo.fromJson(Map<String, dynamic> j) => ChapterInfo(
        id: parseIntField(j['id']) ?? 0,
        start: parseSeconds(j['start_time']) ?? Duration.zero,
        end: parseSeconds(j['end_time']) ?? Duration.zero,
        title: _tags(j['tags'])['title'],
      );
}

Map<String, String> _tags(Object? raw) {
  if (raw is! Map) return const {};
  return {for (final e in raw.entries) e.key.toString(): e.value.toString()};
}

int? parseIntField(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

Duration? parseSeconds(Object? v) {
  double? s;
  if (v is num) s = v.toDouble();
  if (v is String) s = double.tryParse(v.trim());
  if (s == null || s.isNaN || s.isInfinite) return null;
  return Duration(microseconds: (s * 1e6).round());
}

/// `30000/1001` → 29.97. `0/0` → null.
double? parseRational(Object? v) {
  if (v is! String) return null;
  final parts = v.split('/');
  if (parts.length != 2) return double.tryParse(v);
  final n = double.tryParse(parts[0]);
  final d = double.tryParse(parts[1]);
  if (n == null || d == null || d == 0 || n == 0) return null;
  return n / d;
}

/// Matroska `DURATION` tag: `00:01:02.500000000`.
Duration? parseTagDuration(String? v) {
  if (v == null) return null;
  final m = RegExp(r'^(\d+):(\d{2}):(\d{2}(?:\.\d+)?)$').firstMatch(v.trim());
  if (m == null) return null;
  final secs = int.parse(m.group(1)!) * 3600 + int.parse(m.group(2)!) * 60 + double.parse(m.group(3)!);
  return Duration(microseconds: (secs * 1e6).round());
}
