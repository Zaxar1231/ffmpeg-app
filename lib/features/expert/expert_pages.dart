import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/capabilities.dart';
import '../../core/platform/host.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../convert/convert_params.dart';
import '../edit/ui/edit_widgets.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'expert_ops.dart';

const _mono = TextStyle(fontFamily: 'monospace', fontSize: 13);

/// Start text for the command editor (from the log or another tool).
class CommandDraft {
  const CommandDraft(this.text);
  final String text;
}

String templateName(AppLocalizations l, String id) => switch (id) {
  'h264' => l.tplH264,
  'cutCopy' => l.tplCutCopy,
  'frame' => l.tplFrame,
  'mp3' => l.tplMp3,
  'speed2x' => l.tplSpeed2x,
  'gifPalette' => l.tplGif,
  _ => l.tplProbe,
};

/// Shows `ffmpeg -h kind=name`.
Future<void> showFfmpegHelp(BuildContext context, WidgetRef ref, String kind, String name) async {
  final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
  if (ffmpeg == null || name.trim().isEmpty) return;
  final r = await ref.read(processRunnerProvider).capture(ffmpeg, helpArgs(kind, name));
  if (!context.mounted) return;
  final text = (r.stdout + r.stderr).trim();
  await showTextDialog(context, title: '$kind: $name', text: text.isEmpty ? context.l10n.nothingFound : text);
}

// ============================================================ command log

class CommandLogPage extends ConsumerStatefulWidget {
  const CommandLogPage({super.key});
  @override
  ConsumerState<CommandLogPage> createState() => _CommandLogPageState();
}

class _CommandLogPageState extends ConsumerState<CommandLogPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final windows = HostPlatform.current.isWindows;
    final items = [...ref.watch(queueProvider).items]..sort((a, b) => b.job.createdAt.compareTo(a.job.createdAt));
    final fmt = DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).add_Hms();
    final shown = [
      for (final it in items)
        if (_q.isEmpty ||
            it.job.title.toLowerCase().contains(_q) ||
            it.steps.any((s) => s.args.join(' ').toLowerCase().contains(_q)))
          it,
    ];
    return ToolFrame(
      toolId: 'commandLog',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.searchCommands,
              isDense: true,
            ),
            onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l.commandLogHint, style: t.textTheme.bodySmall),
          ),
          if (shown.isEmpty) EmptyState(icon: Icons.history, title: l.noCommands),
          for (final it in shown)
            Card.outlined(
              child: ExpansionTile(
                leading: Icon(switch (it.status) {
                  JobStatus.completed => Icons.check_circle_outline,
                  JobStatus.failed => Icons.error_outline,
                  JobStatus.running => Icons.play_circle_outline,
                  _ => Icons.schedule,
                }),
                title: Text(it.job.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(fmt.format(it.job.createdAt)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  for (final s in it.steps)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SelectableText(commandToText(s.tool, s.args, windows: windows), style: _mono),
                          ),
                          IconButton(
                            tooltip: l.copy,
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () =>
                                Clipboard.setData(ClipboardData(text: commandToText(s.tool, s.args, windows: windows))),
                          ),
                          if (s.tool != JobTool.ytdlp && !s.args.any((a) => a.contains('{{')))
                            IconButton(
                              tooltip: l.editCommand,
                              icon: const Icon(Icons.edit_note, size: 20),
                              onPressed: () => ref
                                  .read(openToolProvider.notifier)
                                  .open(
                                    OpenTool(
                                      'commandEditor',
                                      extra: CommandDraft(commandToText(s.tool, s.args, windows: windows)),
                                    ),
                                  ),
                            ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.replay),
                      label: Text(l.runAgain),
                      onPressed: () async {
                        await ref
                            .read(queueProvider.notifier)
                            .enqueue(
                              JobRequest(
                                kind: it.job.kind,
                                title: it.job.title,
                                tool: it.tool,
                                steps: it.steps,
                                inputPath: it.job.inputPath,
                                outputPath: it.job.outputPath,
                              ),
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.addedToQueue)));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ========================================================= command editor

class CommandEditorPage extends ConsumerStatefulWidget {
  const CommandEditorPage({super.key, this.path, this.draft});
  final String? path;
  final CommandDraft? draft;
  @override
  ConsumerState<CommandEditorPage> createState() => _CommandEditorPageState();
}

class _CommandEditorPageState extends ConsumerState<CommandEditorPage> {
  late final _c = TextEditingController(
    text: widget.draft?.text ?? (widget.path == null ? '' : _fill(commandTemplates.first)),
  );

  String _fill(CommandTemplate tp) {
    final path = widget.path;
    if (path == null) return tp.text;
    final ext = tp.ext ?? p.extension(path).replaceFirst('.', '');
    final out = defaultOutput(ref, path, ext: ext, suffix: '_cmd');
    return fillTemplate(tp.text, input: path, output: out);
  }

  final _help = TextEditingController();
  String _helpKind = helpKinds.first;
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    _help.dispose();
    super.dispose();
  }

  void _insert(String s) {
    final sel = _c.selection;
    final text = _c.text;
    final at = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    _c.value = TextEditingValue(
      text: text.replaceRange(at, end, s),
      selection: TextSelection.collapsed(offset: at + s.length),
    );
    setState(() {});
  }

  String _q(String path) => '"$path"';

  Future<void> _run() async {
    final l = context.l10n;
    final ParsedCommand cmd;
    try {
      cmd = parseCommand(_c.text);
    } on CommandParseError catch (e) {
      setState(
        () => _error = switch (e.kind) {
          'syntax' => l.cmdErrSyntax,
          'empty' => l.cmdErrEmpty,
          'executable' => l.cmdErrExecutable,
          'placeholder' => l.cmdErrPlaceholder,
          _ => l.cmdErrNoInput,
        },
      );
      return;
    }
    setState(() => _error = null);
    Duration? total;
    final probe = ref.read(probeServiceProvider);
    if (probe != null && cmd.inputs.isNotEmpty && File(cmd.inputs.first).existsSync()) {
      try {
        total = (await probe.probe(cmd.inputs.first)).duration;
      } catch (_) {}
    }
    if (!mounted) return;
    await submitJob(
      context,
      ref,
      JobRequest(
        kind: 'command',
        title:
            '${l.toolCommandEditor}: ${cmd.output == null ? p.basename(cmd.inputs.firstOrNull ?? '') : p.basename(cmd.output!)}',
        tool: cmd.tool,
        steps: [JobStep(args: cmd.args, tool: cmd.tool, totalDuration: total)],
        inputPath: cmd.inputs.firstOrNull,
        outputPath: cmd.output,
        totalDuration: total,
        logIsResult: cmd.tool == JobTool.ffprobe,
      ),
      now: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    return ToolFrame(
      toolId: 'commandEditor',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PopupMenuButton<CommandTemplate>(
                tooltip: l.templates,
                onSelected: (tp) => setState(() => _c.text = _fill(tp)),
                itemBuilder: (_) => [
                  for (final tp in commandTemplates) PopupMenuItem(value: tp, child: Text(templateName(l, tp.id))),
                ],
                child: Chip(avatar: const Icon(Icons.library_books_outlined, size: 18), label: Text(l.templates)),
              ),
              ActionChip(
                avatar: const Icon(Icons.input, size: 18),
                label: Text(l.insertInput),
                onPressed: () async {
                  final f = await openFile();
                  if (f != null) _insert(_q(f.path));
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.output, size: 18),
                label: Text(l.insertOutput),
                onPressed: () async {
                  final f = await getSaveLocation(initialDirectory: outputDirFor(ref, widget.path ?? ''));
                  if (f != null) _insert(_q(f.path));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            minLines: 6,
            maxLines: 16,
            style: _mono,
            decoration: InputDecoration(
              hintText: 'ffmpeg -i "input.mp4" -c:v libx264 -crf 23 "output.mp4"',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 8),
          Text(l.commandEditorHint, style: t.textTheme.bodySmall),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(l.runNow),
              onPressed: _c.text.trim().isEmpty ? null : _run,
            ),
          ),
          const SizedBox(height: 24),
          ParamGroup(
            title: l.groupHelp,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _helpKind,
                      onChanged: (v) => setState(() => _helpKind = v!),
                      items: [for (final k in helpKinds) DropdownMenuItem(value: k, child: Text(k))],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _help,
                        decoration: InputDecoration(isDense: true, hintText: l.helpNameHint),
                        onSubmitted: (v) => showFfmpegHelp(context, ref, _helpKind, v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => showFfmpegHelp(context, ref, _helpKind, _help.text),
                      child: Text(l.showHelp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================== filter graph

class FilterGraphPage extends ConsumerWidget {
  const FilterGraphPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'filterGraph',
    path: path,
    builder: (i) => _FilterGraphForm(key: ValueKey(i.path), info: i),
  );
}

class _FilterGraphForm extends ConsumerStatefulWidget {
  const _FilterGraphForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_FilterGraphForm> createState() => _FilterGraphFormState();
}

class _FilterGraphFormState extends ConsumerState<_FilterGraphForm> {
  final _v = TextEditingController(text: 'eq=contrast=1.1:saturation=1.2,unsharp');
  final _a = TextEditingController();
  String _q = '';
  String _applied = 'eq=contrast=1.1:saturation=1.2,unsharp';
  String _appliedA = '';

  @override
  void dispose() {
    _v.dispose();
    _a.dispose();
    super.dispose();
  }

  void _add(TextEditingController c, String name) {
    final t = c.text.trim();
    c.text = t.isEmpty ? name : '$t,$name';
    setState(() {});
  }

  EditGraph? get _graph {
    final hasV = widget.info.videoStreams.isNotEmpty;
    final hasA = widget.info.audioStreams.isNotEmpty;
    if (!hasV && !hasA) return null;
    return EditGraph(
      complex: [
        if (hasV) '[0:v:0]${_applied.trim().isEmpty ? 'null' : _applied.trim()}[v]',
        if (hasA && _appliedA.trim().isNotEmpty) '[0:a:0]${_appliedA.trim()}[a]',
      ].join(';'),
      video: hasV ? 'v' : null,
      audio: hasA ? (_appliedA.trim().isEmpty ? '0:a' : 'a') : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final caps = ref.watch(capabilitiesProvider).value;
    final filters =
        (caps?.filters.values.toList() ?? const <FilterEntry>[])
            .where((f) => _q.isEmpty || f.name.contains(_q) || f.description.toLowerCase().contains(_q))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    final graph = _graph;
    final dirty = _v.text != _applied || _a.text != _appliedA;
    return EditScaffold(
      toolId: 'filterGraph',
      info: info,
      suffix: '_filtered',
      graph: graph,
      compare: true,
      preview: info.videoStreams.isEmpty || graph == null ? null : FramePreview(info: info, graph: graph),
      params: [
        ParamGroup(
          title: l.groupFilterChain,
          children: [
            if (info.videoStreams.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _v,
                  style: _mono,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: l.videoChain,
                    helperText: l.videoChainHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            if (info.audioStreams.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _a,
                  style: _mono,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: l.audioChain,
                    helperText: l.audioChainHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l.applyFilters),
                  onPressed: dirty
                      ? () => setState(() {
                          _applied = _v.text;
                          _appliedA = _a.text;
                        })
                      : null,
                ),
              ),
            ),
          ],
        ),
        ParamGroup(
          title: l.groupFilterList(filters.length),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l.searchFilters,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
              ),
            ),
            SizedBox(
              height: 320,
              child: ListView.builder(
                itemCount: filters.length,
                itemBuilder: (context, i) {
                  final f = filters[i];
                  final audio = f.io.contains('A') && !f.io.contains('V');
                  return ListTile(
                    dense: true,
                    title: Text(f.name, style: _mono),
                    subtitle: Text('${f.io} · ${f.description}', maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => showFfmpegHelp(context, ref, 'filter', f.name),
                    trailing: IconButton(
                      tooltip: l.addFilter,
                      icon: const Icon(Icons.add),
                      onPressed: () => _add(audio ? _a : _v, f.name),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
