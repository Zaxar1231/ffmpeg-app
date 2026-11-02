import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/probe/media_info.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/setting_tile.dart';
import '../edit/graphs.dart' show fnum;
import '../edit/ui/edit_widgets.dart';
import '../tools/tool_catalog.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'subs_ops.dart';

List<XTypeGroup> _subTypes(BuildContext context) => [
  XTypeGroup(label: context.l10n.fileTypeSubtitles, extensions: subtitleExts),
];

/// ISO 639-2 codes offered for subtitle languages.
const subLanguages = [
  'rus',
  'eng',
  'ukr',
  'bel',
  'kaz',
  'deu',
  'fra',
  'spa',
  'ita',
  'por',
  'pol',
  'tur',
  'chi',
  'jpn',
  'kor',
  'ara',
];

String _trackLabel(AppLocalizations l, StreamInfo s, int i) => [
  '#${i + 1}',
  s.tags['language'] ?? '',
  s.tags['title'] ?? '',
  s.codecName ?? '',
  if (s.disposition['default'] == 1) l.flagDefault,
  if (s.disposition['forced'] == 1) l.flagForced,
].where((x) => x.isNotEmpty).join(' · ');

Widget _charsetPicker(String value, ValueChanged<String> onChanged) => DropdownButton<String>(
  value: value,
  onChanged: (v) => onChanged(v!),
  items: [for (final c in subtitleCharsets) DropdownMenuItem(value: c, child: Text(c))],
);

// =================================================================== burn

class BurnSubsPage extends ConsumerWidget {
  const BurnSubsPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'burnSubs',
    path: path,
    builder: (i) => _BurnForm(key: ValueKey(i.path), info: i),
  );
}

class _BurnForm extends StatefulWidget {
  const _BurnForm({super.key, required this.info});
  final MediaInfo info;
  @override
  State<_BurnForm> createState() => _BurnFormState();
}

class _BurnFormState extends State<_BurnForm> {
  String? _file;
  late int? _stream = _textTracks.isEmpty ? null : _textTracks.first;
  String _charset = 'UTF-8';
  int _fontSize = 0;
  String? _color;
  bool _box = false;
  SubPosition _pos = SubPosition.bottom;
  int _margin = 0;

  List<int> get _textTracks => [
    for (final (i, s) in widget.info.subtitleStreams.indexed)
      if (isTextSubtitle(s.codecName)) i,
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final style = BurnStyle(
      fontSize: _fontSize == 0 ? null : _fontSize,
      color: _color,
      box: _box,
      position: _pos,
      marginV: _margin == 0 ? null : _margin,
    );
    final ready = info.videoStreams.isNotEmpty && (_file != null || _stream != null);
    final graph = ready
        ? burnGraph(
            info,
            subFile: _file,
            streamIndex: _stream ?? 0,
            style: style,
            charset: _file == null ? null : _charset,
          )
        : null;
    final bitmapOnly = info.subtitleStreams.isNotEmpty && _textTracks.isEmpty;
    return EditScaffold(
      toolId: 'burnSubs',
      info: info,
      suffix: '_subs',
      compare: true,
      graph: graph,
      problems: [
        if (info.videoStreams.isEmpty) l.issueNoVideo,
        if (!ready && info.videoStreams.isNotEmpty) l.burnChooseSubs,
      ],
      warnings: [if (bitmapOnly && _file == null) l.burnBitmapNote],
      preview: graph == null ? null : FramePreview(info: info, graph: graph),
      params: [
        ParamGroup(
          title: l.groupSubSource,
          children: [
            if (_textTracks.isNotEmpty)
              RadioGroup<int?>(
                groupValue: _file == null ? _stream : -1,
                onChanged: (v) => setState(() {
                  _file = null;
                  _stream = v;
                }),
                child: Column(
                  children: [
                    for (final i in _textTracks)
                      RadioListTile<int?>(
                        value: i,
                        title: Text(l.embeddedTrack),
                        subtitle: Text(_trackLabel(l, info.subtitleStreams.elementAt(i), i)),
                      ),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.subtitles_outlined),
              title: Text(_file == null ? l.subFileFromDisk : p.basename(_file!)),
              subtitle: Text(l.subFileHint),
              trailing: OutlinedButton(
                onPressed: () async {
                  final f = await openFile(acceptedTypeGroups: _subTypes(context));
                  if (f != null) setState(() => _file = f.path);
                },
                child: Text(l.choose),
              ),
            ),
            if (_file != null)
              SettingTile(
                title: l.pCharset,
                hint: l.pCharsetHint,
                control: _charsetPicker(_charset, (v) => setState(() => _charset = v)),
              ),
          ],
        ),
        ParamGroup(
          title: l.groupSubStyle,
          children: [
            ValueSlider(
              title: l.pFontSize,
              hint: l.pSubFontSizeHint,
              value: _fontSize.toDouble(),
              min: 0,
              max: 72,
              divisions: 72,
              defaultValue: 0,
              format: (v) => v == 0 ? l.auto : '${v.round()}',
              onChanged: (v) => setState(() => _fontSize = v.round()),
            ),
            SettingTile(
              title: l.pFontColor,
              hint: l.pSubColorHint,
              control: DropdownButton<String?>(
                value: _color,
                onChanged: (v) => setState(() => _color = v),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.auto)),
                  DropdownMenuItem(value: 'FFFFFF', child: Text(l.colorWhite)),
                  DropdownMenuItem(value: 'FFFF00', child: Text(l.colorYellow)),
                  DropdownMenuItem(value: '00C8FF', child: Text(l.colorBlue)),
                ],
              ),
            ),
            SettingTile(
              title: l.pTextBox,
              hint: l.pTextBoxHint,
              control: Switch(value: _box, onChanged: (v) => setState(() => _box = v)),
            ),
            SettingTile(
              title: l.pPosition,
              hint: l.pSubPositionHint,
              controlBelow: true,
              control: SegmentedButton<SubPosition>(
                segments: [
                  ButtonSegment(value: SubPosition.bottom, label: Text(l.cornerBottom)),
                  ButtonSegment(value: SubPosition.top, label: Text(l.cornerTop)),
                ],
                selected: {_pos},
                onSelectionChanged: (v) => setState(() => _pos = v.first),
              ),
            ),
            ValueSlider(
              title: l.pMargin,
              hint: l.pSubMarginHint,
              value: _margin.toDouble(),
              min: 0,
              max: 120,
              divisions: 24,
              defaultValue: 0,
              format: (v) => v == 0 ? l.auto : '${v.round()}',
              onChanged: (v) => setState(() => _margin = v.round()),
            ),
          ],
        ),
      ],
    );
  }
}

// ================================================================= tracks

class SubTracksPage extends ConsumerWidget {
  const SubTracksPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'softSubs',
    path: path,
    builder: (i) => _TracksForm(key: ValueKey(i.path), info: i),
  );
}

class _NewTrack {
  _NewTrack(this.path);
  final String path;
  String language = 'rus';
  String title = '';
  bool isDefault = false;
  bool forced = false;
  String charset = 'UTF-8';
}

class _TracksForm extends ConsumerStatefulWidget {
  const _TracksForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_TracksForm> createState() => _TracksFormState();
}

class _TracksFormState extends ConsumerState<_TracksForm> {
  late final _keep = {for (var i = 0; i < widget.info.subtitleStreams.length; i++) i};
  final _add = <_NewTrack>[];
  late String _ext = () {
    final e = p.extension(widget.info.path).replaceFirst('.', '').toLowerCase();
    return canHoldSubtitles(e) ? e : 'mkv';
  }();
  String? _output;

  Future<void> _extract(int i, String ext) async {
    final l = context.l10n;
    final info = widget.info;
    final s = info.subtitleStreams.elementAt(i);
    final out = defaultOutput(ref, info.path, ext: ext, suffix: '.${s.tags['language'] ?? i + 1}');
    await submitJob(
      context,
      ref,
      JobRequest(
        kind: 'softSubs',
        title: '${l.extractSubs}: ${p.basename(info.path)} #${i + 1}',
        tool: JobTool.ffmpeg,
        steps: planExtractSub(info: info, index: i, output: out),
        inputPath: info.path,
        outputPath: out,
        totalDuration: info.duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: _ext, suffix: '_subs'), _ext);
    final keep = _keep.toList()..sort();
    final changed =
        _add.isNotEmpty ||
        keep.length != info.subtitleStreams.length ||
        _ext != p.extension(info.path).replaceFirst('.', '').toLowerCase();
    final bitmapInMp4 =
        (_ext == 'mp4' || _ext == 'mov') &&
        keep.any((i) => !isTextSubtitle(info.subtitleStreams.elementAt(i).codecName));
    final steps = changed && !bitmapInMp4
        ? planSubTracks(
            info: info,
            output: out,
            keep: keep,
            add: [
              for (final t in _add)
                NewSubTrack(
                  t.path,
                  language: t.language,
                  title: t.title,
                  isDefault: t.isDefault,
                  forced: t.forced,
                  charset: t.charset,
                ),
            ],
          )
        : null;
    return ToolScaffold(
      toolId: 'softSubs',
      info: info,
      outputPath: out,
      outputExt: _ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (!changed) l.nothingChanged, if (bitmapInMp4) l.bitmapSubsInMp4],
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'softSubs',
          title: '${toolTitle(l, 'softSubs')}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
          totalDuration: info.duration,
        ),
        now: now,
      ),
      params: [
        ParamGroup(
          title: l.groupExistingSubs,
          children: [
            if (info.subtitleStreams.isEmpty)
              Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.noSubtitleTracks)),
            for (final (i, s) in info.subtitleStreams.indexed)
              CheckboxListTile(
                value: _keep.contains(i),
                onChanged: (v) => setState(() => v! ? _keep.add(i) : _keep.remove(i)),
                title: Text(_trackLabel(l, s, i)),
                subtitle: Text(_keep.contains(i) ? l.subKeep : l.subRemove),
                secondary: PopupMenuButton<String>(
                  tooltip: l.extractSubs,
                  icon: const Icon(Icons.file_download_outlined),
                  onSelected: (ext) => _extract(i, ext),
                  itemBuilder: (_) => [
                    if (isTextSubtitle(s.codecName)) ...[
                      const PopupMenuItem(value: 'srt', child: Text('SRT')),
                      const PopupMenuItem(value: 'ass', child: Text('ASS')),
                      const PopupMenuItem(value: 'vtt', child: Text('WebVTT')),
                    ] else
                      PopupMenuItem(
                        value: extractSubExt(s.codecName),
                        child: Text(extractSubExt(s.codecName).toUpperCase()),
                      ),
                  ],
                ),
              ),
          ],
        ),
        ParamGroup(
          title: l.groupAddSubs,
          trailing: TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l.addFiles),
            onPressed: () async {
              final files = await openFiles(acceptedTypeGroups: _subTypes(context));
              setState(() => _add.addAll(files.map((f) => _NewTrack(f.path))));
            },
          ),
          children: [
            if (_add.isEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.addSubsHint)),
            for (final t in _add)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(width: 220, child: Text(p.basename(t.path), overflow: TextOverflow.ellipsis)),
                    DropdownButton<String>(
                      value: t.language,
                      onChanged: (v) => setState(() => t.language = v!),
                      items: [for (final c in subLanguages) DropdownMenuItem(value: c, child: Text(c))],
                    ),
                    SizedBox(
                      width: 140,
                      child: TextFormField(
                        initialValue: t.title,
                        decoration: InputDecoration(isDense: true, hintText: l.trackTitle),
                        onChanged: (v) => setState(() => t.title = v),
                      ),
                    ),
                    _charsetPicker(t.charset, (v) => setState(() => t.charset = v)),
                    FilterChip(
                      label: Text(l.flagDefault),
                      selected: t.isDefault,
                      onSelected: (v) => setState(() => t.isDefault = v),
                    ),
                    FilterChip(
                      label: Text(l.flagForced),
                      selected: t.forced,
                      onSelected: (v) => setState(() => t.forced = v),
                    ),
                    IconButton(
                      tooltip: l.removeFromList,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _add.remove(t)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        ParamGroup(
          title: l.groupEditOutput,
          children: [
            SettingTile(
              title: l.pContainer,
              hint: l.subContainerHint,
              control: DropdownButton<String>(
                value: _ext,
                onChanged: (v) => setState(() => _ext = v!),
                items: [
                  for (final e in {'mkv', 'mp4', 'mov', 'webm', _ext})
                    DropdownMenuItem(value: e, child: Text(e.toUpperCase())),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================================================================ convert

class ConvertSubsPage extends ConsumerWidget {
  const ConvertSubsPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'convertSubs',
    path: path,
    builder: (i) => _ConvertSubsForm(key: ValueKey(i.path), info: i),
  );
}

/// Frame-rate retiming presets: (label, scale).
const _retime = [
  ('—', 1.0),
  ('25 → 23.976', 25 / 23.976),
  ('23.976 → 25', 23.976 / 25),
  ('24 → 25', 24 / 25),
  ('25 → 24', 25 / 24),
];

class _ConvertSubsForm extends ConsumerStatefulWidget {
  const _ConvertSubsForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_ConvertSubsForm> createState() => _ConvertSubsFormState();
}

class _ConvertSubsFormState extends ConsumerState<_ConvertSubsForm> {
  SubFormat _format = SubFormat.srt;
  double _shift = 0;
  int _retimeIndex = 0;
  String _charset = 'UTF-8';
  String? _output;
  late final _shiftC = TextEditingController(text: '0');

  @override
  void dispose() {
    _shiftC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final ext = subFormatExt(_format);
    final same = p.extension(info.path).replaceFirst('.', '').toLowerCase() == ext;
    final out = withExtension(_output ?? defaultOutput(ref, info.path, ext: ext, suffix: same ? '_fixed' : ''), ext);
    final isSub = info.subtitleStreams.isNotEmpty && info.videoStreams.isEmpty && info.audioStreams.isEmpty;
    final steps = isSub
        ? planConvertSubs(
            input: info.path,
            output: out,
            shift: Duration(microseconds: (_shift * 1e6).round()),
            charset: _charset,
            scale: _retime[_retimeIndex].$2,
          )
        : null;
    return ToolScaffold(
      toolId: 'convertSubs',
      info: info,
      outputPath: out,
      outputExt: ext,
      onOutputChanged: (v) => setState(() => _output = v),
      steps: steps,
      problems: [if (!isSub) l.notASubtitleFile],
      onSubmit: (now) => submitJob(
        context,
        ref,
        JobRequest(
          kind: 'convertSubs',
          title: '${toolTitle(l, 'convertSubs')}: ${p.basename(info.path)}',
          tool: JobTool.ffmpeg,
          steps: steps,
          inputPath: info.path,
          outputPath: out,
        ),
        now: now,
      ),
      params: [
        ParamGroup(
          title: l.groupSubConvert,
          children: [
            SettingTile(
              title: l.pSubFormat,
              hint: l.pSubFormatHint,
              controlBelow: true,
              control: SegmentedButton<SubFormat>(
                segments: const [
                  ButtonSegment(value: SubFormat.srt, label: Text('SRT')),
                  ButtonSegment(value: SubFormat.ass, label: Text('ASS')),
                  ButtonSegment(value: SubFormat.vtt, label: Text('WebVTT')),
                ],
                selected: {_format},
                onSelectionChanged: (v) => setState(() => _format = v.first),
              ),
            ),
            SettingTile(
              title: l.pSubShift,
              hint: l.pSubShiftHint,
              control: SizedBox(
                width: 120,
                child: TextField(
                  controller: _shiftC,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  decoration: InputDecoration(isDense: true, suffixText: l.unitSecond),
                  onChanged: (t) {
                    final v = double.tryParse(t.replaceAll(',', '.'));
                    if (v != null) setState(() => _shift = v);
                  },
                ),
              ),
            ),
            SettingTile(
              title: l.pSubRetime,
              hint: l.pSubRetimeHint,
              help: l.pSubRetimeHelp,
              control: DropdownButton<int>(
                value: _retimeIndex,
                onChanged: (v) => setState(() => _retimeIndex = v!),
                items: [
                  for (var i = 0; i < _retime.length; i++)
                    DropdownMenuItem(value: i, child: Text(i == 0 ? l.none : '${_retime[i].$1} ${l.unitFps}')),
                ],
              ),
            ),
            SettingTile(
              title: l.pCharset,
              hint: l.pCharsetHint,
              control: _charsetPicker(_charset, (v) => setState(() => _charset = v)),
            ),
            if (_shift != 0 || _retimeIndex != 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  l.subShiftExample(fnum(1 * _retime[_retimeIndex].$2 + _shift, 3)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
