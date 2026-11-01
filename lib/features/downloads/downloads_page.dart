import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/error_translator.dart';
import '../../core/platform/app_paths.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../core/ytdlp/ytdlp.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/setting_tile.dart';
import '../shell/app_shell.dart';
import '../tools/command_text.dart';
import '../tools/tool_scaffold.dart';

/// One analyzed link.
class _Item {
  _Item(this.url);
  final String url;
  bool loading = true;
  YtInfo? info;
  String? error;

  /// Playlist: selected 1-based indexes.
  Set<int> selected = {};
}

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  final _urls = TextEditingController();
  final _items = <_Item>[];
  YtDownloadParams _p = const YtDownloadParams();
  String? _clipboardUrl;
  bool _useArchive = false;

  @override
  void initState() {
    super.initState();
    _checkClipboard();
  }

  @override
  void dispose() {
    _urls.dispose();
    super.dispose();
  }

  /// Offer a link from the clipboard (not inserted without the user's click).
  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final urls = extractUrls(data?.text ?? '');
    if (!mounted || urls.isEmpty) return;
    final u = urls.first;
    if (_urls.text.contains(u) || _items.any((i) => i.url == u)) return;
    setState(() => _clipboardUrl = u);
  }

  String get _outputDir => ref.read(settingsProvider).outputDir ?? AppPaths.defaultOutputDir();

  YtTools _tools() {
    final tc = ref.read(toolchainProvider);
    final s = ref.read(settingsProvider);
    return YtTools(
      ffmpeg: tc.ffmpeg.path,
      deno: tc.deno.path,
      aria2c: s.ytdlpUseAria2 ? tc.aria2c.path : null,
      concurrentFragments: s.ytdlpConcurrentFragments,
    );
  }

  Future<void> _analyze() async {
    final urls = extractUrls(_urls.text);
    if (urls.isEmpty) return;
    final ytdlp = ref.read(toolchainProvider).ytdlp.path;
    if (ytdlp == null) return;
    final items = [for (final u in urls) _Item(u)];
    setState(() {
      _items
        ..clear()
        ..addAll(items);
    });
    final runner = ref.read(processRunnerProvider);
    await Future.wait(
      items.map((it) async {
        final r = await runner.capture(
          ytdlp,
          ytdlpInfoArgs(it.url, cookiesFromBrowser: _p.cookiesFromBrowser, proxy: _p.proxy),
          timeout: const Duration(minutes: 2),
        );
        if (!mounted) return;
        setState(() {
          it.loading = false;
          if (!r.ok) {
            final e = translateToolError(r.stderr.split('\n'), startError: r.startFailed ? r.stderr : null);
            it.error = e.kind == ToolErrorKind.unknown
                ? (e.line ?? r.stderr.trim())
                : toolErrorText(context.l10n, e.kind, e.detail);
            return;
          }
          try {
            it.info = YtInfo.fromJson((jsonDecode(r.stdout) as Map).cast<String, dynamic>());
            it.selected = {for (final e in it.info!.entries) e.index};
          } catch (e) {
            it.error = e.toString();
          }
        });
      }),
    );
  }

  List<JobRequest> _requests(AppLocalizations l, {bool skipAnalysis = false}) {
    final out = _outputDir;
    final params = _useArchive ? _p.copyWith(archiveFile: () => p.join(out, '.kadra-archive.txt')) : _p;
    final tools = _tools();
    JobRequest req(String url, String title, {YtFormat? chosen}) => JobRequest(
      kind: 'download',
      title: '${l.toolDownload}: $title',
      tool: JobTool.ytdlp,
      steps: [
        JobStep(
          tool: JobTool.ytdlp,
          capture: StepCapture.ytdlpFilePath,
          args: ytdlpDownloadArgs(url: url, outputDir: out, p: params, tools: tools, chosen: chosen),
        ),
      ],
    );
    if (skipAnalysis) return [for (final u in extractUrls(_urls.text)) req(u, u)];
    final list = <JobRequest>[];
    for (final it in _items) {
      final info = it.info;
      if (info == null) continue;
      if (info.isPlaylist) {
        for (final e in info.entries.where((e) => it.selected.contains(e.index))) {
          list.add(req(e.url, e.title ?? e.url));
        }
      } else {
        final chosen = params.formatId == null ? null : info.formats.where((f) => f.id == params.formatId).firstOrNull;
        list.add(req(info.webpageUrl ?? it.url, info.title ?? it.url, chosen: chosen));
      }
    }
    return list;
  }

  Future<void> _download({bool skipAnalysis = false}) async {
    final l = context.l10n;
    final reqs = _requests(l, skipAnalysis: skipAnalysis);
    if (reqs.isEmpty) return;
    for (final r in reqs) {
      await ref.read(queueProvider.notifier).enqueue(r);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        persist: false,
        content: Text(l.downloadsQueued(reqs.length)),
        action: SnackBarAction(
          label: l.openQueue,
          onPressed: () => ref.read(navProvider.notifier).go(Destination.queue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ytdlp = ref.watch(toolchainProvider.select((t) => t.ytdlp));
    if (!ytdlp.available) {
      return PageFrame(
        title: l.navDownloads,
        child: EmptyState(
          icon: Icons.cloud_download_outlined,
          title: l.downloadsNeedYtdlpTitle,
          message: l.downloadsNeedYtdlp,
          action: FilledButton(
            onPressed: () => ref.read(navProvider.notifier).go(Destination.components),
            child: Text(l.openComponents),
          ),
        ),
      );
    }
    final advanced = ref.watch(settingsProvider.select((s) => s.advancedMode));
    final hasDeno = ref.watch(toolchainProvider.select((t) => t.deno.available));
    final ready = _items.any((i) => i.info != null);
    final count = _requests(l).length;

    return PageFrame(
      title: l.navDownloads,
      maxWidth: 1000,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                if (_clipboardUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.content_paste, size: 18),
                      label: Text(l.pasteFromClipboard(_clipboardUrl!), overflow: TextOverflow.ellipsis),
                      onPressed: () => setState(() {
                        _urls.text = [_urls.text.trim(), _clipboardUrl!].where((s) => s.isNotEmpty).join('\n');
                        _clipboardUrl = null;
                      }),
                    ),
                  ),
                TextField(
                  controller: _urls,
                  minLines: 2,
                  maxLines: 6,
                  decoration: InputDecoration(labelText: l.urlsLabel, hintText: l.urlsHint),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.search),
                      label: Text(l.analyzeLinks),
                      onPressed: extractUrls(_urls.text).isEmpty ? null : _analyze,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.fast_forward),
                      label: Text(l.downloadWithoutAnalysis),
                      onPressed: extractUrls(_urls.text).isEmpty ? null : () => _download(skipAnalysis: true),
                    ),
                  ],
                ),
                if (!hasDeno)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(l.denoHint, style: Theme.of(context).textTheme.bodySmall),
                  ),
                const SizedBox(height: 16),
                for (final it in _items)
                  _ItemCard(
                    item: it,
                    onChanged: () => setState(() {}),
                    params: _p,
                    onParams: (v) => setState(() => _p = v),
                  ),
                ParamGroup(
                  title: l.groupDownloadQuality,
                  children: [
                    SettingTile(
                      title: l.pYtQuality,
                      hint: l.pYtQualityHint,
                      controlBelow: true,
                      control: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(l.ytBest),
                            selected: _p.quality == YtQuality.best,
                            onSelected: (_) =>
                                setState(() => _p = _p.copyWith(quality: YtQuality.best, formatId: () => null)),
                          ),
                          for (final h in const [2160, 1440, 1080, 720, 480, 360])
                            ChoiceChip(
                              label: Text(l.ytUpTo('${h}p')),
                              selected: _p.quality == YtQuality.maxHeight && _p.maxHeight == h,
                              onSelected: (_) => setState(
                                () =>
                                    _p = _p.copyWith(quality: YtQuality.maxHeight, maxHeight: h, formatId: () => null),
                              ),
                            ),
                          ChoiceChip(
                            avatar: const Icon(Icons.music_note, size: 16),
                            label: Text(l.ytAudioOnly),
                            selected: _p.quality == YtQuality.audioOnly,
                            onSelected: (_) =>
                                setState(() => _p = _p.copyWith(quality: YtQuality.audioOnly, formatId: () => null)),
                          ),
                        ],
                      ),
                    ),
                    if (_p.quality == YtQuality.audioOnly)
                      SettingTile(
                        title: l.pYtAudioFormat,
                        hint: l.pYtAudioFormatHint,
                        control: DropdownButton<YtAudioFormat>(
                          value: _p.audioFormat,
                          onChanged: (v) => setState(() => _p = _p.copyWith(audioFormat: v)),
                          items: [
                            DropdownMenuItem(value: YtAudioFormat.best, child: Text(l.extractAsIs)),
                            const DropdownMenuItem(value: YtAudioFormat.mp3, child: Text('MP3')),
                            const DropdownMenuItem(value: YtAudioFormat.m4a, child: Text('M4A (AAC)')),
                            const DropdownMenuItem(value: YtAudioFormat.opus, child: Text('Opus')),
                            DropdownMenuItem(value: YtAudioFormat.flac, child: Text(l.codecFlac)),
                          ],
                        ),
                      )
                    else
                      SettingTile(
                        title: l.pContainer,
                        hint: l.pYtContainerHint,
                        help: l.pYtContainerHelp,
                        control: DropdownButton<String?>(
                          value: _p.container,
                          onChanged: (v) => setState(() => _p = _p.copyWith(container: () => v)),
                          items: [
                            const DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                            const DropdownMenuItem(value: 'mkv', child: Text('MKV')),
                            const DropdownMenuItem(value: 'webm', child: Text('WebM')),
                            DropdownMenuItem(value: null, child: Text(l.ytContainerAuto)),
                          ],
                        ),
                      ),
                  ],
                ),
                ParamGroup(
                  title: l.groupDownloadExtras,
                  children: [
                    if (_p.quality != YtQuality.audioOnly) ...[
                      SettingTile(
                        title: l.pYtSubs,
                        hint: l.pYtSubsHint,
                        control: Switch(
                          value: _p.subtitles,
                          onChanged: (v) => setState(() => _p = _p.copyWith(subtitles: v)),
                        ),
                      ),
                      SettingTile(
                        title: l.pYtAutoSubs,
                        hint: l.pYtAutoSubsHint,
                        control: Switch(
                          value: _p.autoSubtitles,
                          onChanged: (v) => setState(() => _p = _p.copyWith(autoSubtitles: v)),
                        ),
                      ),
                      if (_p.subtitles || _p.autoSubtitles)
                        SettingTile(
                          title: l.pYtSubLangs,
                          hint: l.pYtSubLangsHint,
                          control: SizedBox(
                            width: 160,
                            child: TextFormField(
                              initialValue: _p.subLangs,
                              decoration: const InputDecoration(isDense: true),
                              onChanged: (v) =>
                                  setState(() => _p = _p.copyWith(subLangs: v.trim().isEmpty ? 'ru,en' : v.trim())),
                            ),
                          ),
                        ),
                    ],
                    SettingTile(
                      title: l.pYtEmbed,
                      hint: l.pYtEmbedHint,
                      control: Switch(
                        value: _p.embedMetadata && _p.embedThumbnail,
                        onChanged: (v) =>
                            setState(() => _p = _p.copyWith(embedMetadata: v, embedThumbnail: v, embedChapters: v)),
                      ),
                    ),
                    SettingTile(
                      title: l.pSponsorBlock,
                      hint: l.pSponsorBlockHint,
                      help: l.pSponsorBlockHelp,
                      control: DropdownButton<SponsorBlockMode>(
                        value: _p.sponsorBlock,
                        onChanged: (v) => setState(() => _p = _p.copyWith(sponsorBlock: v)),
                        items: [
                          DropdownMenuItem(value: SponsorBlockMode.off, child: Text(l.sbOff)),
                          DropdownMenuItem(value: SponsorBlockMode.mark, child: Text(l.sbMark)),
                          DropdownMenuItem(value: SponsorBlockMode.remove, child: Text(l.sbRemove)),
                        ],
                      ),
                    ),
                    SettingTile(
                      title: l.pCookies,
                      hint: l.pCookiesHint,
                      help: l.pCookiesHelp,
                      control: DropdownButton<String?>(
                        value: _p.cookiesFromBrowser,
                        onChanged: (v) => setState(() => _p = _p.copyWith(cookiesFromBrowser: () => v)),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l.none)),
                          for (final b in const ['chrome', 'firefox', 'edge', 'brave', 'opera', 'vivaldi', 'chromium'])
                            DropdownMenuItem(value: b, child: Text(b)),
                        ],
                      ),
                    ),
                    SettingTile(
                      title: l.pArchive,
                      hint: l.pArchiveHint,
                      control: Switch(value: _useArchive, onChanged: (v) => setState(() => _useArchive = v)),
                    ),
                    if (advanced) ...[
                      SettingTile(
                        title: l.pTemplate,
                        hint: l.pTemplateHint,
                        help: l.pTemplateHelp,
                        controlBelow: true,
                        control: TextFormField(
                          initialValue: _p.template,
                          decoration: const InputDecoration(isDense: true),
                          onChanged: (v) => setState(
                            () => _p = _p.copyWith(template: v.trim().isEmpty ? const YtDownloadParams().template : v),
                          ),
                        ),
                      ),
                      SettingTile(
                        title: l.pRateLimit,
                        hint: l.pRateLimitHint,
                        control: SizedBox(
                          width: 120,
                          child: TextFormField(
                            initialValue: _p.rateLimit ?? '',
                            decoration: const InputDecoration(isDense: true, hintText: '5M'),
                            onChanged: (v) =>
                                setState(() => _p = _p.copyWith(rateLimit: () => v.trim().isEmpty ? null : v.trim())),
                          ),
                        ),
                      ),
                      SettingTile(
                        title: l.pProxy,
                        hint: l.pProxyHint,
                        control: SizedBox(
                          width: 240,
                          child: TextFormField(
                            initialValue: _p.proxy ?? '',
                            decoration: const InputDecoration(isDense: true, hintText: 'socks5://127.0.0.1:1080'),
                            onChanged: (v) =>
                                setState(() => _p = _p.copyWith(proxy: () => v.trim().isEmpty ? null : v.trim())),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(child: Text(l.saveTo(_outputDir), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  TextButton.icon(
                    icon: const Icon(Icons.terminal),
                    label: Text(l.showCommand),
                    onPressed: count == 0
                        ? null
                        : () => showTextDialog(
                            context,
                            title: l.commandTitle,
                            text: stepsCommandText(_requests(l).first.effectiveSteps, ref.read(toolchainProvider)),
                          ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(count > 1 ? l.downloadN(count) : l.download),
                    onPressed: ready && count > 0 ? _download : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onChanged, required this.params, required this.onParams});
  final _Item item;
  final VoidCallback onChanged;
  final YtDownloadParams params;
  final ValueChanged<YtDownloadParams> onParams;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final info = item.info;
    Widget body;
    if (item.loading) {
      body = Row(
        children: [
          const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Expanded(child: Text(item.url, overflow: TextOverflow.ellipsis)),
        ],
      );
    } else if (item.error != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.url, style: t.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(item.error!, style: TextStyle(color: t.colorScheme.error)),
        ],
      );
    } else if (info!.isPlaylist) {
      final all = info.entries.length;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.playlist_play, color: t.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(info.title ?? item.url, style: t.textTheme.titleSmall)),
              Text(l.selectedOf(item.selected.length, all)),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  item.selected = {for (final e in info.entries) e.index};
                  onChanged();
                },
                child: Text(l.selectAll),
              ),
              TextButton(
                onPressed: () {
                  item.selected = {};
                  onChanged();
                },
                child: Text(l.selectNone),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: InputDecoration(isDense: true, hintText: l.rangesHint),
                  onSubmitted: (v) {
                    item.selected = parseItemRanges(v, max: all);
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final e in info.entries)
                  CheckboxListTile(
                    dense: true,
                    value: item.selected.contains(e.index),
                    onChanged: (v) {
                      v == true ? item.selected.add(e.index) : item.selected.remove(e.index);
                      onChanged();
                    },
                    title: Text('${e.index}. ${e.title ?? e.url}', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: e.duration == null ? null : Text(formatDuration(e.duration)),
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      final formats = info.formats
          .where((f) => !f.isStoryboard && (f.hasVideo || f.hasAudio))
          .toList()
          .reversed
          .toList();
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                info.thumbnail!,
                width: 192,
                height: 108,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const SizedBox(width: 192, height: 108, child: Icon(Icons.image_not_supported)),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.title ?? item.url, style: t.textTheme.titleSmall),
                Text(
                  [
                    info.uploader,
                    if (info.duration != null) formatDuration(info.duration),
                  ].whereType<String>().join(' · '),
                  style: t.textTheme.bodySmall,
                ),
                if (info.heights.isNotEmpty)
                  Text(
                    l.availableQualities(info.heights.take(6).map((h) => '${h}p').join(', ')),
                    style: t.textTheme.bodySmall,
                  ),
                if (formats.isNotEmpty)
                  DropdownButton<String?>(
                    isExpanded: true,
                    value: formats.any((f) => f.id == params.formatId) ? params.formatId : null,
                    hint: Text(l.exactFormat),
                    onChanged: (v) => onParams(
                      params.copyWith(quality: v == null ? YtQuality.best : YtQuality.format, formatId: () => v),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l.exactFormatAuto)),
                      for (final f in formats)
                        DropdownMenuItem(
                          value: f.id,
                          child: Text(
                            [
                              f.id,
                              f.ext,
                              if (f.hasVideo) '${f.height ?? '?'}p${f.fps != null ? f.fps!.round() : ''} ${f.vcodec}',
                              if (f.hasAudio) f.acodec,
                              if (!f.hasAudio) l.videoOnly,
                              if (f.filesize != null) formatBytes(f.filesize, units: byteUnits(l)),
                            ].whereType<String>().join(' · '),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(12), child: body),
    );
  }
}
