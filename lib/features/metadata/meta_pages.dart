import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/capabilities.dart' show MediaKind;
import '../../core/engine/containers.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/setting_tile.dart';
import '../edit/ui/edit_widgets.dart';
import '../subtitles/subs_pages.dart' show subLanguages;
import '../tools/tool_catalog.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'meta_ops.dart';

String _srcExt(MediaInfo info, {String fallback = 'mkv'}) {
  final e = p.extension(info.path).replaceFirst('.', '').toLowerCase();
  return containers.containsKey(e) ? e : fallback;
}

Future<void> _submit(
  BuildContext context,
  WidgetRef ref,
  String toolId,
  MediaInfo info,
  List<JobStep> steps,
  String out,
  bool now,
) {
  final l = context.l10n;
  return submitJob(
    context,
    ref,
    JobRequest(
      kind: toolId,
      title: '${toolTitle(l, toolId)}: ${p.basename(info.path)}',
      tool: JobTool.ffmpeg,
      steps: steps,
      inputPath: info.path,
      outputPath: out,
      totalDuration: info.duration,
    ),
    now: now,
  );
}

String tagLabel(AppLocalizations l, String key) => switch (key) {
  'title' => l.tagTitle,
  'artist' => l.tagArtist,
  'album_artist' => l.tagAlbumArtist,
  'album' => l.tagAlbum,
  'date' => l.tagDate,
  'genre' => l.tagGenre,
  'track' => l.tagTrack,
  'disc' => l.tagDisc,
  'composer' => l.tagComposer,
  'comment' => l.tagComment,
  'description' => l.tagDescription,
  'copyright' => l.tagCopyright,
  _ => key,
};

// =================================================================== tags

class TagsPage extends ConsumerWidget {
  const TagsPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'tags',
    path: path,
    builder: (i) => _TagsForm(key: ValueKey(i.path), info: i),
  );
}

class _TagsForm extends ConsumerStatefulWidget {
  const _TagsForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_TagsForm> createState() => _TagsFormState();
}

class _TagsFormState extends ConsumerState<_TagsForm> {
  late final Map<String, String> _orig = {
    for (final e in widget.info.format.tags.entries)
      if (!e.key.toLowerCase().startsWith('major_brand') &&
          !const {'minor_version', 'compatible_brands', 'encoder'}.contains(e.key.toLowerCase()))
        e.key.toLowerCase(): e.value,
  };
  late final Map<String, TextEditingController> _c = {
    for (final k in {...commonTags, ..._orig.keys}) k: TextEditingController(text: _orig[k] ?? ''),
  };
  late final Map<int, String?> _lang = {
    for (final s in widget.info.streams)
      if (s.kind != MediaKind.attachment) s.index: s.tags['language'],
  };
  bool _clear = false;
  String? _output;
  final _newKey = TextEditingController();

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    _newKey.dispose();
    super.dispose();
  }

  Map<String, String> get _changes => {
    for (final e in _c.entries)
      if ((_orig[e.key] ?? '') != e.value.text || (_clear && e.value.text.isNotEmpty)) e.key: e.value.text,
  };

  Map<int, String> get _langChanges => {
    for (final s in widget.info.streams)
      if (_lang[s.index] != null && _lang[s.index] != s.tags['language']) s.index: _lang[s.index]!,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = _srcExt(info);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_tags'), ext);
    final changed = _changes.isNotEmpty || _langChanges.isNotEmpty || _clear;
    final steps = changed
        ? planTags(info: info, output: out, tags: _changes, languages: _langChanges, clearAll: _clear)
        : null;
    return ToolScaffold(
      toolId: 'tags',
      info: info,
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (!changed) l.nothingChanged],
      onSubmit: (now) => _submit(context, ref, 'tags', info, steps!, out, now),
      params: [
        ParamGroup(
          title: l.groupTags,
          trailing: TagChip(l.losslessTag, icon: Icons.bolt, color: Theme.of(context).colorScheme.tertiaryContainer),
          children: [
            for (final e in _c.entries)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: TextField(
                  controller: e.value,
                  maxLines: e.key == 'comment' || e.key == 'description' ? 3 : 1,
                  minLines: 1,
                  decoration: InputDecoration(labelText: tagLabel(l, e.key), isDense: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newKey,
                      decoration: InputDecoration(labelText: l.customTagKey, isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l.addTag),
                    onPressed: () {
                      final k = _newKey.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
                      if (k.isEmpty || _c.containsKey(k)) return;
                      setState(() {
                        _c[k] = TextEditingController();
                        _newKey.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
            SettingTile(
              title: l.pClearTags,
              hint: l.pClearTagsHint,
              control: Switch(value: _clear, onChanged: (v) => setState(() => _clear = v)),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupStreamLanguages,
          children: [
            for (final s in info.streams)
              if (s.kind != MediaKind.attachment && !s.isAttachedPicture)
                SettingTile(
                  title: '#${s.index} · ${s.codecName ?? ''}',
                  hint: s.tags['title'] ?? '',
                  control: DropdownButton<String?>(
                    value: subLanguages.contains(_lang[s.index]) ? _lang[s.index] : null,
                    hint: Text(_lang[s.index] ?? l.notSet),
                    onChanged: (v) => setState(() => _lang[s.index] = v),
                    items: [for (final c in subLanguages) DropdownMenuItem(value: c, child: Text(c))],
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

// ================================================================== cover

class CoverPage extends ConsumerWidget {
  const CoverPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'cover',
    path: path,
    builder: (i) => _CoverForm(key: ValueKey(i.path), info: i),
  );
}

enum _CoverAction { set, remove }

class _CoverForm extends ConsumerStatefulWidget {
  const _CoverForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_CoverForm> createState() => _CoverFormState();
}

class _CoverFormState extends ConsumerState<_CoverForm> {
  _CoverAction _action = _CoverAction.set;
  String? _image;
  String? _output;
  File? _current;
  Directory? _tmp;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCurrent());
  }

  @override
  void dispose() {
    final t = _tmp;
    if (t != null) unawaited(t.delete(recursive: true).catchError((_) => t));
    super.dispose();
  }

  Future<void> _loadCurrent() async {
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null || coverStreamIndex(widget.info) == null) return;
    _tmp = await Directory.systemTemp.createTemp('kadra_cover');
    final out = p.join(_tmp!.path, 'cover.${coverExt(widget.info)}');
    final r = await ref
        .read(processRunnerProvider)
        .capture(ffmpeg, planExtractCover(info: widget.info, output: out).single.args);
    if (r.ok && mounted) setState(() => _current = File(out));
  }

  Future<void> _saveCurrent() async {
    final cur = _current;
    if (cur == null) return;
    final loc = await getSaveLocation(
      initialDirectory: outputDirFor(ref, widget.info.path),
      suggestedName: '${p.basenameWithoutExtension(widget.info.path)}_cover${p.extension(cur.path)}',
    );
    if (loc != null) await cur.copy(loc.path);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = _srcExt(info, fallback: info.videoStreams.isEmpty ? 'mka' : 'mkv');
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_cover'), ext);
    final has = coverStreamIndex(info) != null;
    final steps = switch (_action) {
      _CoverAction.set => _image == null ? null : planSetCover(info: info, output: out, image: _image!),
      _CoverAction.remove => has ? planRemoveCover(info: info, output: out) : null,
    };
    final preview = _action == _CoverAction.set && _image != null ? File(_image!) : _current;
    return ToolScaffold(
      toolId: 'cover',
      info: info,
      preview: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: 1,
                child: preview == null
                    ? Center(
                        child: Text(l.noCover, style: const TextStyle(color: Colors.white70)),
                      )
                    : Image.file(preview, fit: BoxFit.contain),
              ),
            ),
          ),
          if (_current != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: Text(l.saveCover),
                  onPressed: _saveCurrent,
                ),
              ),
            ),
        ],
      ),
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [
        if (_action == _CoverAction.set && _image == null) l.chooseCoverImage,
        if (_action == _CoverAction.remove && !has) l.noCover,
      ],
      onSubmit: (now) => _submit(context, ref, 'cover', info, steps!, out, now),
      params: [
        ParamGroup(
          title: l.groupCover,
          children: [
            SettingTile(
              title: l.pCoverAction,
              hint: has ? l.coverPresent : l.noCover,
              controlBelow: true,
              control: SegmentedButton<_CoverAction>(
                segments: [
                  ButtonSegment(
                    value: _CoverAction.set,
                    icon: const Icon(Icons.image),
                    label: Text(has ? l.coverReplace : l.coverSet),
                  ),
                  ButtonSegment(
                    value: _CoverAction.remove,
                    icon: const Icon(Icons.hide_image_outlined),
                    label: Text(l.coverRemove),
                    enabled: has,
                  ),
                ],
                selected: {_action},
                onSelectionChanged: (v) => setState(() => _action = v.first),
              ),
            ),
            if (_action == _CoverAction.set)
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(_image == null ? l.chooseCoverImage : p.basename(_image!)),
                subtitle: Text(l.coverImageHint),
                trailing: OutlinedButton(
                  onPressed: () async {
                    final f = await openFile(
                      acceptedTypeGroups: [
                        XTypeGroup(
                          label: context.l10n.fileTypeImages,
                          extensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
                        ),
                      ],
                    );
                    if (f != null) setState(() => _image = f.path);
                  },
                  child: Text(l.choose),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// =============================================================== chapters

class ChaptersPage extends ConsumerWidget {
  const ChaptersPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'chapters',
    path: path,
    builder: (i) => _ChaptersForm(key: ValueKey(i.path), info: i),
  );
}

class _Ch {
  _Ch(this.start, String title) : title = TextEditingController(text: title);
  Duration start;
  final TextEditingController title;
}

class _ChaptersForm extends ConsumerStatefulWidget {
  const _ChaptersForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_ChaptersForm> createState() => _ChaptersFormState();
}

class _ChaptersFormState extends ConsumerState<_ChaptersForm> {
  late final List<_Ch> _items = [for (final c in widget.info.chapters) _Ch(c.start, c.title ?? '')];
  String? _output;
  bool _touched = false;

  @override
  void dispose() {
    for (final c in _items) {
      c.title.dispose();
    }
    super.dispose();
  }

  List<Chapter> get _chapters => [for (final c in _items) Chapter(c.start, c.title.text)];

  Future<void> _import() async {
    final text = await showDialog<String>(context: context, builder: (_) => const _ImportChaptersDialog());
    if (text == null) return;
    final parsed = chaptersFromText(text);
    if (parsed.isEmpty) return;
    setState(() {
      _items
        ..clear()
        ..addAll([for (final ch in parsed) _Ch(ch.start, ch.title)]);
      _touched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = _srcExt(info);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_chapters'), ext);
    final steps = _touched ? planChapters(info: info, output: out, chapters: _chapters) : null;
    return ToolScaffold(
      toolId: 'chapters',
      info: info,
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (!_touched) l.nothingChanged],
      onSubmit: (now) => _submit(context, ref, 'chapters', info, steps!, out, now),
      params: [
        ParamGroup(
          title: l.groupChapters,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(tooltip: l.importChapters, icon: const Icon(Icons.playlist_add), onPressed: _import),
              IconButton(
                tooltip: l.copyChapters,
                icon: const Icon(Icons.copy),
                onPressed: _items.isEmpty
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: chaptersToText(_chapters)));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                      },
              ),
            ],
          ),
          children: [
            if (_items.isEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), child: Text(l.noChapters)),
            for (final c in _items)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                child: Row(
                  children: [
                    DurationField(
                      value: c.start,
                      width: 120,
                      onChanged: (d) => setState(() {
                        c.start = d ?? Duration.zero;
                        _touched = true;
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: c.title,
                        decoration: InputDecoration(isDense: true, hintText: l.chapterTitle),
                        onChanged: (_) => setState(() => _touched = true),
                      ),
                    ),
                    IconButton(
                      tooltip: l.removeFromList,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _items.remove(c);
                        _touched = true;
                      }),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l.addChapter),
                    onPressed: () => setState(() {
                      final last = _items.isEmpty ? Duration.zero : _items.last.start + const Duration(minutes: 1);
                      _items.add(_Ch(last, l.chapterN(_items.length + 1)));
                      _touched = true;
                    }),
                  ),
                  if (_items.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l.removeAllChapters),
                      onPressed: () => setState(() {
                        _items.clear();
                        _touched = true;
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Owns its controller, so it is disposed only after the closing animation.
class _ImportChaptersDialog extends StatefulWidget {
  const _ImportChaptersDialog();
  @override
  State<_ImportChaptersDialog> createState() => _ImportChaptersDialogState();
}

class _ImportChaptersDialogState extends State<_ImportChaptersDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.importChapters),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: _c,
          autofocus: true,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: '0:00 Вступление\n1:30 Основная часть\n12:05 Итоги',
            helperText: l.importChaptersHint,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _c.text), child: Text(l.importAction)),
      ],
    );
  }
}

// ================================================================= repair

class RepairPage extends ConsumerWidget {
  const RepairPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'repair',
    path: path,
    builder: (i) => _RepairForm(key: ValueKey(i.path), info: i),
  );
}

class _RepairForm extends ConsumerStatefulWidget {
  const _RepairForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_RepairForm> createState() => _RepairFormState();
}

class _RepairFormState extends ConsumerState<_RepairForm> {
  RepairMode _mode = RepairMode.remux;
  double _offset = 0;
  double? _fps;
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final env = ref.watch(encodeEnvProvider);
    final ext = _srcExt(info);
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_fixed'), ext);
    final r = RepairParams(
      mode: _mode,
      audioOffset: Duration(microseconds: (_offset * 1e6).round()),
      fps: _fps,
    );
    final noAv = _mode == RepairMode.audioOffset && (info.videoStreams.isEmpty || info.audioStreams.isEmpty);
    final steps = noAv || (_mode == RepairMode.audioOffset && _offset == 0)
        ? null
        : planRepair(info: info, output: out, r: r, env: env);
    return ToolScaffold(
      toolId: 'repair',
      info: info,
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [
        if (noAv) l.repairNeedsAv,
        if (!noAv && _mode == RepairMode.audioOffset && _offset == 0) l.nothingChanged,
      ],
      onSubmit: (now) => _submit(context, ref, 'repair', info, steps!, out, now),
      params: [
        ParamGroup(
          title: l.groupRepair,
          children: [
            SettingTile(
              title: l.pRepairMode,
              hint: switch (_mode) {
                RepairMode.remux => l.repairRemuxHint,
                RepairMode.reencode => l.repairReencodeHint,
                RepairMode.audioOffset => l.repairOffsetHint,
              },
              help: l.pRepairModeHelp,
              controlBelow: true,
              control: SegmentedButton<RepairMode>(
                segments: [
                  ButtonSegment(value: RepairMode.remux, label: Text(l.repairRemux)),
                  ButtonSegment(value: RepairMode.audioOffset, label: Text(l.repairOffset)),
                  ButtonSegment(value: RepairMode.reencode, label: Text(l.repairReencode)),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() => _mode = v.first),
              ),
            ),
            if (_mode == RepairMode.audioOffset)
              ValueSlider(
                title: l.pAudioOffset,
                hint: l.pAudioOffsetHint,
                value: _offset,
                min: -3,
                max: 3,
                divisions: 120,
                defaultValue: 0,
                format: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(2)} ${l.unitSecond}',
                onChanged: (v) => setState(() => _offset = double.parse(v.toStringAsFixed(2))),
              ),
            if (_mode == RepairMode.reencode)
              SettingTile(
                title: l.pSpeedFps,
                hint: l.repairFpsHint,
                control: DropdownButton<double?>(
                  value: _fps,
                  onChanged: (v) => setState(() => _fps = v),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                    for (final f in const [23.976, 24.0, 25.0, 29.97, 30.0, 50.0, 60.0])
                      DropdownMenuItem(value: f, child: Text('$f ${l.unitFps}')),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ============================================================== faststart

class FaststartPage extends ConsumerWidget {
  const FaststartPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'faststart',
    path: path,
    builder: (i) => _FaststartForm(key: ValueKey(i.path), info: i),
  );
}

class _FaststartForm extends ConsumerStatefulWidget {
  const _FaststartForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_FaststartForm> createState() => _FaststartFormState();
}

class _FaststartFormState extends ConsumerState<_FaststartForm> {
  late final Future<bool?> _atEnd = moovAtEnd(widget.info.path);
  String? _output;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = _srcExt(info, fallback: 'mp4');
    final ok = ext == 'mp4' || ext == 'mov' || ext == 'm4a' || ext == 'm4v';
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: '_web'), ext);
    final steps = ok ? planFaststart(info: info, output: out) : null;
    return FutureBuilder<bool?>(
      future: _atEnd,
      builder: (context, snap) => ToolScaffold(
        toolId: 'faststart',
        info: info,
        outputPath: out,
        outputExt: ext,
        onOutputChanged: (v) => setState(() => _output = v),
        steps: steps,
        problems: [if (!ok) l.faststartOnlyMp4],
        warnings: [if (snap.data == false) l.faststartAlready],
        estimate: formatBytes(info.format.size, units: byteUnits(l)),
        onSubmit: (now) => _submit(context, ref, 'faststart', info, steps!, out, now),
        params: [
          ParamGroup(
            title: l.groupFaststart,
            children: [
              ListTile(
                leading: Icon(snap.data == true ? Icons.hourglass_bottom : Icons.check_circle_outline),
                title: Text(switch (snap.data) {
                  true => l.moovAtEnd,
                  false => l.moovAtStart,
                  null => l.moovUnknown,
                }),
                subtitle: Text(l.faststartExplained),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
