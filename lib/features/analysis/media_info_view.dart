import 'package:flutter/material.dart';

import '../../core/engine/capabilities.dart' show MediaKind;
import '../../core/probe/media_info.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';

/// Detailed, readable view of everything ffprobe knows about a file.
class MediaInfoView extends StatelessWidget {
  const MediaInfoView({super.key, required this.info});
  final MediaInfo info;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final f = info.format;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          icon: Icons.inventory_2_outlined,
          title: l.infoContainer,
          children: [
            InfoRow(
              l.infoFormat,
              '${f.formatLongName ?? f.formatName ?? '—'}${f.formatName != null ? ' (${f.formatName})' : ''}',
            ),
            InfoRow(l.infoDuration, formatDuration(info.duration, millis: true)),
            InfoRow(l.infoSize, formatBytes(f.size, units: byteUnits(l))),
            InfoRow(l.infoBitrate, formatBitrate(f.bitRate, kbps: l.unitKbps, mbps: l.unitMbps)),
            if (f.startTime != null && f.startTime != Duration.zero)
              InfoRow(l.infoStartTime, formatDuration(f.startTime, millis: true)),
            InfoRow(l.infoStreams, '${info.streams.length}'),
          ],
        ),
        for (final s in info.streams) _streamSection(context, s),
        if (info.chapters.isNotEmpty)
          _Section(
            icon: Icons.bookmark_border,
            title: l.infoChapters(info.chapters.length),
            children: [
              for (final c in info.chapters)
                InfoRow('${formatDuration(c.start)} – ${formatDuration(c.end)}', c.title ?? '#${c.id + 1}'),
            ],
          ),
        if (f.tags.isNotEmpty)
          _Section(
            icon: Icons.sell_outlined,
            title: l.infoTags,
            children: [for (final e in f.tags.entries) InfoRow(e.key, e.value, selectable: true)],
          ),
      ],
    );
  }

  Widget _streamSection(BuildContext context, StreamInfo s) {
    final l = context.l10n;
    final (icon, kind) = switch (s.kind) {
      MediaKind.video =>
        s.isAttachedPicture ? (Icons.image_outlined, l.streamCover) : (Icons.movie_outlined, l.streamVideo),
      MediaKind.audio => (Icons.audiotrack_outlined, l.streamAudio),
      MediaKind.subtitle => (Icons.subtitles_outlined, l.streamSubtitle),
      MediaKind.attachment => (Icons.attach_file, l.streamAttachment),
      _ => (Icons.data_object, l.streamData),
    };
    final flags = [if (s.isDefault) l.dispositionDefault, if (s.isForced) l.dispositionForced];
    final codec = [s.codecName, if (s.profile != null) s.profile].whereType<String>().join(' · ');
    return _Section(
      icon: icon,
      title:
          '#${s.index} · $kind${s.language != null ? ' · ${s.language}' : ''}${s.title != null ? ' · ${s.title}' : ''}',
      trailing: [
        for (final f in flags) TagChip(f),
        if (s.kind == MediaKind.video && s.hdr != HdrKind.sdr)
          TagChip(
            switch (s.hdr) {
              HdrKind.hdr10 => 'HDR10',
              HdrKind.hlg => 'HLG',
              HdrKind.dolbyVision => 'Dolby Vision',
              HdrKind.sdr => 'SDR',
            },
            icon: Icons.hdr_on,
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
      ],
      children: [
        InfoRow(l.infoCodec, codec.isEmpty ? '—' : '$codec${s.codecLongName != null ? '\n${s.codecLongName}' : ''}'),
        if (s.kind == MediaKind.video) ...[
          InfoRow(
            l.infoResolution,
            '${s.width ?? '?'}×${s.height ?? '?'}${s.displayAspectRatio != null ? '  (${s.displayAspectRatio})' : ''}',
          ),
          if (!s.isAttachedPicture)
            InfoRow(l.infoFrameRate, '${formatFps(s.avgFrameRate ?? s.frameRate)} ${l.unitFps}'),
          InfoRow(l.infoPixelFormat, '${s.pixFmt ?? '—'}${s.bitDepth != null ? ' · ${l.infoBits(s.bitDepth!)}' : ''}'),
          if (s.colorSpace != null || s.colorTransfer != null || s.colorPrimaries != null)
            InfoRow(
              l.infoColor,
              [s.colorRange, s.colorSpace, s.colorTransfer, s.colorPrimaries].whereType<String>().join(' / '),
            ),
          if (s.fieldOrder != null && s.fieldOrder != 'progressive') InfoRow(l.infoFieldOrder, s.fieldOrder!),
          if (s.rotation != null && s.rotation != 0) InfoRow(l.infoRotation, '${s.rotation}°'),
          if (s.masteringDisplay != null)
            InfoRow(
              l.infoMastering,
              s.masteringDisplay!.entries
                  .where((e) => e.key != 'side_data_type')
                  .map((e) => '${e.key}=${e.value}')
                  .join(', '),
              selectable: true,
            ),
          if (s.contentLight != null)
            InfoRow(
              l.infoContentLight,
              s.contentLight!.entries
                  .where((e) => e.key != 'side_data_type')
                  .map((e) => '${e.key}=${e.value}')
                  .join(', '),
            ),
        ],
        if (s.kind == MediaKind.audio) ...[
          InfoRow(l.infoSampleRate, s.sampleRate == null ? '—' : '${s.sampleRate} ${l.unitHz}'),
          InfoRow(l.infoChannels, '${s.channels ?? '—'}${s.channelLayout != null ? ' (${s.channelLayout})' : ''}'),
          if (s.sampleFmt != null) InfoRow(l.infoSampleFormat, s.sampleFmt!),
        ],
        if (s.bitRate != null) InfoRow(l.infoBitrate, formatBitrate(s.bitRate, kbps: l.unitKbps, mbps: l.unitMbps)),
        if (s.duration != null) InfoRow(l.infoDuration, formatDuration(s.duration, millis: true)),
        if (s.frameCount != null) InfoRow(l.infoFrames, '${s.frameCount}'),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children, this.trailing = const []});
  final IconData icon;
  final String title;
  final List<Widget> children;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: t.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: t.textTheme.titleSmall)),
                for (final w in trailing) Padding(padding: const EdgeInsets.only(left: 6), child: w),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
