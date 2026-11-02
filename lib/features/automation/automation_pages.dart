import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../core/platform/app_paths.dart';
import '../../core/presets/preset_repository.dart';
import '../../core/providers.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/setting_tile.dart';
import '../convert/builtin_presets.dart';
import '../convert/labels.dart';
import '../edit/graphs.dart' show Corner;
import '../edit/ui/frame_pages.dart' show cornerName;
import '../shell/app_shell.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'automation_service.dart';
import 'batch.dart';
import 'recipe.dart';

String recipeOpName(AppLocalizations l, RecipeOp op) => switch (op) {
  RecipeOp.convert => l.opConvert,
  RecipeOp.normalize => l.opNormalize,
  RecipeOp.vertical => l.opVertical,
  RecipeOp.scale => l.opScale,
  RecipeOp.denoise => l.opDenoise,
  RecipeOp.fade => l.opFade,
  RecipeOp.text => l.opText,
  RecipeOp.logo => l.opLogo,
  RecipeOp.burnSidecar => l.opBurnSidecar,
  RecipeOp.stripMetadata => l.opStripMetadata,
  RecipeOp.faststart => l.opFaststart,
  RecipeOp.extractAudio => l.opExtractAudio,
};

String recipeProblemText(AppLocalizations l, String p) => switch (p) {
  'empty' => l.recipeEmpty,
  'preset' => l.recipePresetMissing,
  'video' => l.issueNoVideo,
  'audio' => l.issueNoAudio,
  'probe' => l.probeFailed,
  'ffprobe' => l.ffmpegMissingTitle,
  _ => l.recipeNotFound,
};

const _defaults = <RecipeOp, Map<String, Object?>>{
  RecipeOp.convert: {'preset': 'compress'},
  RecipeOp.normalize: {'lufs': -14},
  RecipeOp.vertical: {'height': 1920},
  RecipeOp.scale: {'height': 1080},
  RecipeOp.fade: {'seconds': 1},
  RecipeOp.text: {'text': '', 'corner': 'bottom'},
  RecipeOp.logo: {'corner': 'bottomRight', 'size': 0.15},
  RecipeOp.extractAudio: {'format': 'mp3'},
};

/// Example recipes offered when there are none yet.
List<(String, List<RecipeStep>)> _templates(AppLocalizations l) => [
  (
    l.tplReels,
    const [
      RecipeStep(RecipeOp.vertical, {'height': 1920}),
      RecipeStep(RecipeOp.normalize, {'lufs': -14}),
      RecipeStep(RecipeOp.faststart),
    ],
  ),
  (
    l.tplPodcast,
    const [
      RecipeStep(RecipeOp.extractAudio, {'format': 'mp3'}),
      RecipeStep(RecipeOp.denoise),
      RecipeStep(RecipeOp.normalize, {'lufs': -16}),
    ],
  ),
  (
    l.tplTelegram,
    const [
      RecipeStep(RecipeOp.burnSidecar),
      RecipeStep(RecipeOp.convert, {'preset': 'telegram'}),
      RecipeStep(RecipeOp.stripMetadata),
    ],
  ),
];

/// Preset picker: built-in and user convert presets.
class _PresetPicker extends ConsumerWidget {
  const _PresetPicker({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final user = ref.watch(userPresetsProvider(null)).value ?? const <UserPreset>[];
    final items = [
      for (final b in builtinPresets) (b.id, presetName(l, b.id)),
      for (final u in user)
        if (u.toolId == 'convert' || u.toolId == 'compress') ('user:${u.id}', u.name),
    ];
    return DropdownButton<String>(
      value: items.any((i) => i.$1 == value) ? value : null,
      hint: Text(l.notSet),
      onChanged: (v) => onChanged(v!),
      items: [for (final (id, name) in items) DropdownMenuItem(value: id, child: Text(name))],
    );
  }
}

// ================================================================ recipes

class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});
  @override
  ConsumerState<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends ConsumerState<RecipesPage> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final c = ref.read(recipesProvider.notifier);
    final sel = recipes.where((r) => r.id == _selected).firstOrNull ?? recipes.firstOrNull;
    final list = Card.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in recipes)
            ListTile(
              selected: r.id == sel?.id,
              leading: const Icon(Icons.account_tree_outlined),
              title: Text(r.name),
              subtitle: Text(
                r.steps.map((s) => recipeOpName(l, s.op)).join(' → '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => setState(() => _selected = r.id),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.add),
                  label: Text(l.newRecipe),
                  onPressed: () async {
                    final r = await c.create(l.newRecipeName(recipes.length + 1));
                    setState(() => _selected = r.id);
                  },
                ),
                if (recipes.isEmpty)
                  for (final (name, steps) in _templates(l))
                    OutlinedButton(
                      onPressed: () async {
                        final r = await c.create(name, steps: steps);
                        setState(() => _selected = r.id);
                      },
                      child: Text(name),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
    return ToolFrame(
      toolId: 'recipes',
      child: LayoutBuilder(
        builder: (context, box) {
          final editor = sel == null
              ? EmptyState(icon: Icons.account_tree_outlined, title: l.noRecipes, message: l.recipesExplained)
              : _RecipeEditor(key: ValueKey(sel.id), recipe: sel);
          if (box.maxWidth > 980) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 340,
                  child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 12, 24), children: [list]),
                ),
                Expanded(child: editor),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              list,
              const SizedBox(height: 12),
              SizedBox(height: 700, child: editor),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeEditor extends ConsumerStatefulWidget {
  const _RecipeEditor({super.key, required this.recipe});
  final Recipe recipe;
  @override
  ConsumerState<_RecipeEditor> createState() => _RecipeEditorState();
}

class _RecipeEditorState extends ConsumerState<_RecipeEditor> {
  late final _name = TextEditingController(text: widget.recipe.name);
  late List<RecipeStep> _steps = widget.recipe.steps;
  Timer? _save;

  @override
  void dispose() {
    _save?.cancel();
    _flush();
    _name.dispose();
    super.dispose();
  }

  void _flush() {
    final r = widget.recipe.copyWith(
      name: _name.text.trim().isEmpty ? widget.recipe.name : _name.text.trim(),
      steps: _steps,
    );
    unawaited(ref.read(recipesProvider.notifier).put(r));
  }

  void _changed(List<RecipeStep> steps) {
    setState(() => _steps = steps);
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 400), _flush);
  }

  void _setParam(int i, String k, Object? v) {
    final s = _steps[i];
    _changed([..._steps]..[i] = RecipeStep(s.op, {...s.params, k: v}));
  }

  Widget _paramEditor(int i) {
    final l = context.l10n;
    final s = _steps[i];
    return switch (s.op) {
      RecipeOp.convert => SettingTile(
        title: l.pPreset,
        hint: l.pRecipePresetHint,
        control: _PresetPicker(value: s.get<String>('preset'), onChanged: (v) => _setParam(i, 'preset', v)),
      ),
      RecipeOp.normalize => SettingTile(
        title: l.pRecipeLufs,
        hint: l.pRecipeLufsHint,
        control: DropdownButton<num>(
          value: s.number('lufs', -14),
          onChanged: (v) => _setParam(i, 'lufs', v),
          items: [
            for (final v in const [-14.0, -16.0, -19.0, -23.0])
              DropdownMenuItem(value: v, child: Text('${v.round()} LUFS')),
          ],
        ),
      ),
      RecipeOp.vertical || RecipeOp.scale => SettingTile(
        title: l.pFrameHeight,
        hint: s.op == RecipeOp.scale ? l.pRecipeScaleHint : l.pFrameHeightHint,
        control: DropdownButton<num>(
          value: s.number('height', 1080),
          onChanged: (v) => _setParam(i, 'height', v),
          items: [
            for (final h in const [2160.0, 1920.0, 1440.0, 1280.0, 1080.0, 720.0, 480.0])
              DropdownMenuItem(value: h, child: Text('${h.round()}')),
          ],
        ),
      ),
      RecipeOp.fade => SettingTile(
        title: l.pFadeIn,
        hint: l.pRecipeFadeHint,
        control: DropdownButton<num>(
          value: s.number('seconds', 1),
          onChanged: (v) => _setParam(i, 'seconds', v),
          items: [
            for (final v in const [0.5, 1.0, 2.0, 3.0]) DropdownMenuItem(value: v, child: Text('$v ${l.unitSecond}')),
          ],
        ),
      ),
      RecipeOp.text => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextFormField(
              initialValue: s.get<String>('text'),
              decoration: InputDecoration(labelText: l.pOverlayText, isDense: true),
              onChanged: (v) => _setParam(i, 'text', v),
            ),
          ),
          _corner(i, 'bottom'),
        ],
      ),
      RecipeOp.logo => Column(
        children: [
          ListTile(
            title: Text(s.get<String>('image') == null ? l.pWatermarkImage : p.basename(s.get<String>('image')!)),
            trailing: OutlinedButton(
              onPressed: () async {
                final f = await openFile(
                  acceptedTypeGroups: const [
                    XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg', 'webp']),
                  ],
                );
                if (f != null) _setParam(i, 'image', f.path);
              },
              child: Text(l.choose),
            ),
          ),
          _corner(i, 'bottomRight'),
        ],
      ),
      RecipeOp.extractAudio => SettingTile(
        title: l.pImageFormat,
        hint: l.pRecipeAudioHint,
        control: DropdownButton<String>(
          value: s.get<String>('format') ?? 'mp3',
          onChanged: (v) => _setParam(i, 'format', v),
          items: [
            for (final f in const ['mp3', 'm4a', 'opus', 'flac'])
              DropdownMenuItem(value: f, child: Text(f.toUpperCase())),
          ],
        ),
      ),
      RecipeOp.burnSidecar => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(l.opBurnSidecarHint),
      ),
      RecipeOp.denoise => Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text(l.opDenoiseHint)),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _corner(int i, String def) {
    final l = context.l10n;
    final v = Corner.values.asNameMap()[_steps[i].get<String>('corner') ?? def] ?? Corner.bottom;
    return SettingTile(
      title: l.pPosition,
      hint: l.pPositionHint,
      control: DropdownButton<Corner>(
        value: v,
        onChanged: (c) => _setParam(i, 'corner', c!.name),
        items: [for (final c in Corner.values) DropdownMenuItem(value: c, child: Text(cornerName(l, c)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l.recipeName),
                onChanged: (_) => _changed(_steps),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              icon: const Icon(Icons.dynamic_feed),
              label: Text(l.runRecipe),
              onPressed: _steps.isEmpty
                  ? null
                  : () {
                      _flush();
                      ref
                          .read(openToolProvider.notifier)
                          .open(OpenTool('batch', extra: BatchAction.recipe(widget.recipe.id)));
                    },
            ),
            IconButton(
              tooltip: l.remove,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(recipesProvider.notifier).delete(widget.recipe.id),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ParamGroup(
          title: l.groupRecipeSteps,
          trailing: PopupMenuButton<RecipeOp>(
            tooltip: l.addStep,
            icon: const Icon(Icons.add),
            onSelected: (op) => _changed([..._steps, RecipeStep(op, Map.of(_defaults[op] ?? const {}))]),
            itemBuilder: (_) => [
              for (final op in RecipeOp.values) PopupMenuItem(value: op, child: Text(recipeOpName(l, op))),
            ],
          ),
          children: [
            if (_steps.isEmpty)
              Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.recipesExplained)),
            for (var i = 0; i < _steps.length; i++) ...[
              ListTile(
                leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                title: Text(recipeOpName(l, _steps[i].op)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l.moveUp,
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: i == 0
                          ? null
                          : () => _changed(
                              [..._steps]
                                ..insert(i - 1, _steps[i])
                                ..removeAt(i + 1),
                            ),
                    ),
                    IconButton(
                      tooltip: l.removeFromList,
                      icon: const Icon(Icons.close),
                      onPressed: () => _changed([..._steps]..removeAt(i)),
                    ),
                  ],
                ),
              ),
              _paramEditor(i),
              if (i < _steps.length - 1) const Divider(indent: 16, endIndent: 16),
            ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(l.recipeChainNote, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

// ================================================================== batch

class BatchPage extends ConsumerStatefulWidget {
  const BatchPage({super.key, this.initial, this.path});
  final BatchAction? initial;
  final String? path;
  @override
  ConsumerState<BatchPage> createState() => _BatchPageState();
}

enum _ActionKind { preset, recipe }

class _BatchPageState extends ConsumerState<BatchPage> {
  late _ActionKind _kind = widget.initial?.recipeId != null ? _ActionKind.recipe : _ActionKind.preset;
  late String? _preset = widget.initial?.presetId ?? 'compress';
  late String? _recipe = widget.initial?.recipeId;
  late final _files = <String>[?widget.path];
  String? _root;
  String? _outDir;
  bool _keepStructure = true;
  bool _recursive = true;
  FileKindFilter _filter = FileKindFilter.all;
  bool _busy = false;
  double? _progress;
  final _problems = <String, String>{};

  /// Same default as every tool: the settings folder, or next to the source.
  String? _defaultOutDir() {
    final s = ref.read(settingsProvider);
    return s.outputNextToSource ? null : (s.outputDir ?? AppPaths.defaultOutputDir());
  }

  BatchAction? get _action => _kind == _ActionKind.preset
      ? (_preset == null ? null : BatchAction.preset(_preset))
      : (_recipe == null ? null : BatchAction.recipe(_recipe));

  Future<void> _addFolder() async {
    final dir = await getDirectoryPath();
    if (dir == null) return;
    final found = await scanFolder(dir, recursive: _recursive, kind: _filter);
    setState(() {
      _root = dir;
      _files.addAll(found.where((f) => !_files.contains(f)));
    });
  }

  Future<void> _run() async {
    final l = context.l10n;
    final action = _action;
    final probe = ref.read(probeServiceProvider);
    if (action == null || probe == null) return;
    final recipe = action.resolve(await ref.read(recipesProvider.future));
    if (recipe == null) return;
    setState(() {
      _busy = true;
      _progress = 0;
      _problems.clear();
    });
    final env = await recipeEnv(ref.read);
    final outDir = _outDir ?? _defaultOutDir();
    var queued = 0;
    final taken = <String>{};
    for (var i = 0; i < _files.length; i++) {
      final f = _files[i];
      try {
        final info = await probe.probe(f);
        final out = batchOutput(
          input: f,
          ext: recipeOutputExt(recipe, info, env),
          outDir: outDir,
          root: _root,
          keepStructure: _keepStructure,
          // Two files of a batch may map to the same name.
          exists: (path) => taken.contains(path) || File(path).existsSync(),
        );
        taken.add(out);
        final job = recipeJob(
          info: info,
          recipe: recipe,
          env: env,
          output: out,
          title: '${recipe.name}: ${p.basename(f)}',
        );
        if (job.request == null) {
          _problems[f] = recipeProblemText(l, job.problem!);
        } else {
          await ref.read(queueProvider.notifier).enqueue(job.request!);
          queued++;
        }
      } catch (_) {
        _problems[f] = l.probeFailed;
      }
      if (mounted) setState(() => _progress = (i + 1) / _files.length);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.batchQueued(queued, _problems.length)),
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
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    ref.watch(settingsProvider);
    final outDir = _outDir ?? _defaultOutDir();
    final t = Theme.of(context);
    return ToolFrame(
      toolId: 'batch',
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                ParamGroup(
                  title: l.groupBatchAction,
                  children: [
                    SettingTile(
                      title: l.pBatchAction,
                      hint: l.pBatchActionHint,
                      controlBelow: true,
                      control: SegmentedButton<_ActionKind>(
                        segments: [
                          ButtonSegment(
                            value: _ActionKind.preset,
                            icon: const Icon(Icons.tune),
                            label: Text(l.pPreset),
                          ),
                          ButtonSegment(
                            value: _ActionKind.recipe,
                            icon: const Icon(Icons.account_tree_outlined),
                            label: Text(l.toolRecipes),
                          ),
                        ],
                        selected: {_kind},
                        onSelectionChanged: (v) => setState(() => _kind = v.first),
                      ),
                    ),
                    if (_kind == _ActionKind.preset)
                      SettingTile(
                        title: l.pPreset,
                        hint: l.pRecipePresetHint,
                        control: _PresetPicker(value: _preset, onChanged: (v) => setState(() => _preset = v)),
                      )
                    else
                      SettingTile(
                        title: l.toolRecipes,
                        hint: recipes.isEmpty ? l.noRecipes : l.pBatchRecipeHint,
                        control: DropdownButton<String>(
                          value: recipes.any((r) => r.id == _recipe) ? _recipe : null,
                          hint: Text(l.notSet),
                          onChanged: (v) => setState(() => _recipe = v),
                          items: [for (final r in recipes) DropdownMenuItem(value: r.id, child: Text(r.name))],
                        ),
                      ),
                  ],
                ),
                ParamGroup(
                  title: l.groupBatchFiles(_files.length),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.note_add_outlined),
                        label: Text(l.addFiles),
                        onPressed: () async {
                          final fs = await openFiles();
                          setState(() => _files.addAll(fs.map((f) => f.path).where((f) => !_files.contains(f))));
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.create_new_folder_outlined),
                        label: Text(l.addFolder),
                        onPressed: _addFolder,
                      ),
                      if (_files.isNotEmpty)
                        IconButton(
                          tooltip: l.clearList,
                          icon: const Icon(Icons.clear_all),
                          onPressed: () => setState(() {
                            _files.clear();
                            _problems.clear();
                            _root = null;
                          }),
                        ),
                    ],
                  ),
                  children: [
                    SettingTile(
                      title: l.pRecursive,
                      hint: l.pRecursiveHint,
                      control: Switch(value: _recursive, onChanged: (v) => setState(() => _recursive = v)),
                    ),
                    SettingTile(
                      title: l.pFileKind,
                      hint: l.pFileKindHint,
                      control: DropdownButton<FileKindFilter>(
                        value: _filter,
                        onChanged: (v) => setState(() => _filter = v!),
                        items: [
                          DropdownMenuItem(value: FileKindFilter.all, child: Text(l.kindAll)),
                          DropdownMenuItem(value: FileKindFilter.video, child: Text(l.kindVideo)),
                          DropdownMenuItem(value: FileKindFilter.audio, child: Text(l.kindAudio)),
                          DropdownMenuItem(value: FileKindFilter.images, child: Text(l.kindImages)),
                        ],
                      ),
                    ),
                    if (_files.isEmpty)
                      Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Text(l.batchHowTo)),
                    for (final f in _files.take(300))
                      ListTile(
                        dense: true,
                        title: Text(
                          _root != null && p.isWithin(_root!, f) ? p.relative(f, from: _root) : p.basename(f),
                        ),
                        subtitle: _problems[f] == null
                            ? null
                            : Text(_problems[f]!, style: TextStyle(color: t.colorScheme.error)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l.removeFromList,
                          onPressed: () => setState(() => _files.remove(f)),
                        ),
                      ),
                    if (_files.length > 300)
                      Padding(padding: const EdgeInsets.all(16), child: Text(l.moreFound(_files.length - 300))),
                  ],
                ),
                ParamGroup(
                  title: l.groupBatchOutput,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(outDir ?? l.nextToSource),
                      subtitle: Text(l.batchOutDirHint),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_outDir != null)
                            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _outDir = null)),
                          OutlinedButton(
                            onPressed: () async {
                              final d = await getDirectoryPath();
                              if (d != null) setState(() => _outDir = d);
                            },
                            child: Text(l.choose),
                          ),
                        ],
                      ),
                    ),
                    if (_root != null && outDir != null)
                      SettingTile(
                        title: l.pKeepStructure,
                        hint: l.pKeepStructureHint,
                        control: Switch(value: _keepStructure, onChanged: (v) => setState(() => _keepStructure = v)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: t.colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
              child: Row(
                children: [
                  if (_busy) Expanded(child: LinearProgressIndicator(value: _progress)) else const Spacer(),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.playlist_add),
                    label: Text(l.batchRun(_files.length)),
                    onPressed: _busy || _files.isEmpty || _action == null ? null : _run,
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

// ========================================================== watch folders

class WatchFolderPage extends ConsumerWidget {
  const WatchFolderPage({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final rule = await showDialog<WatchRule>(context: context, builder: (_) => const _WatchRuleDialog());
    if (rule != null) await ref.read(watchProvider.notifier).add(rule);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final st = ref.watch(watchProvider);
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final t = Theme.of(context);
    final fmt = DateFormat.Hms();
    String actionName(BatchAction a) => a.recipeId != null
        ? (recipes.where((r) => r.id == a.recipeId).firstOrNull?.name ?? l.recipeNotFound)
        : presetName(l, a.presetId!);
    return ToolFrame(
      toolId: 'watchFolder',
      trailing: [
        FilledButton.tonalIcon(
          icon: const Icon(Icons.add),
          label: Text(l.addWatch),
          onPressed: () => _add(context, ref),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(l.watchExplained, style: t.textTheme.bodyMedium),
          ),
          if (st.rules.isEmpty)
            EmptyState(icon: Icons.folder_special_outlined, title: l.noWatches, message: l.watchHowTo),
          for (final r in st.rules)
            Card.outlined(
              child: ListTile(
                leading: Icon(
                  st.active.contains(r.id) ? Icons.visibility : Icons.visibility_off_outlined,
                  color: st.active.contains(r.id) ? t.colorScheme.primary : null,
                ),
                title: Text(r.folder),
                subtitle: Text('${actionName(r.action)} → ${r.effectiveOutDir}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(value: r.enabled, onChanged: (v) => ref.read(watchProvider.notifier).setEnabled(r.id, v)),
                    IconButton(
                      tooltip: l.remove,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref.read(watchProvider.notifier).remove(r.id),
                    ),
                  ],
                ),
              ),
            ),
          if (st.log.isNotEmpty)
            ParamGroup(
              title: l.groupWatchLog,
              children: [
                for (final e in st.log)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      e.queued ? Icons.playlist_add_check : Icons.error_outline,
                      color: e.queued ? null : t.colorScheme.error,
                    ),
                    title: Text(p.basename(e.path)),
                    subtitle: Text(e.problem == null ? l.watchQueued : recipeProblemText(l, e.problem!)),
                    trailing: Text(fmt.format(e.time)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WatchRuleDialog extends ConsumerStatefulWidget {
  const _WatchRuleDialog();
  @override
  ConsumerState<_WatchRuleDialog> createState() => _WatchRuleDialogState();
}

class _WatchRuleDialogState extends ConsumerState<_WatchRuleDialog> {
  String? _folder;
  String? _outDir;
  _ActionKind _kind = _ActionKind.preset;
  String? _preset = 'compress';
  String? _recipe;
  bool _recursive = false;
  FileKindFilter _filter = FileKindFilter.video;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final action = _kind == _ActionKind.preset
        ? (_preset == null ? null : BatchAction.preset(_preset))
        : (_recipe == null ? null : BatchAction.recipe(_recipe));
    return AlertDialog(
      title: Text(l.addWatch),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: Text(_folder ?? l.watchFolderPick),
                trailing: OutlinedButton(
                  onPressed: () async {
                    final d = await getDirectoryPath();
                    if (d != null) setState(() => _folder = d);
                  },
                  child: Text(l.choose),
                ),
              ),
              SettingTile(
                title: l.pRecursive,
                hint: l.pRecursiveHint,
                control: Switch(value: _recursive, onChanged: (v) => setState(() => _recursive = v)),
              ),
              SettingTile(
                title: l.pFileKind,
                hint: l.pFileKindHint,
                control: DropdownButton<FileKindFilter>(
                  value: _filter,
                  onChanged: (v) => setState(() => _filter = v!),
                  items: [
                    DropdownMenuItem(value: FileKindFilter.all, child: Text(l.kindAll)),
                    DropdownMenuItem(value: FileKindFilter.video, child: Text(l.kindVideo)),
                    DropdownMenuItem(value: FileKindFilter.audio, child: Text(l.kindAudio)),
                    DropdownMenuItem(value: FileKindFilter.images, child: Text(l.kindImages)),
                  ],
                ),
              ),
              SettingTile(
                title: l.pBatchAction,
                hint: l.pBatchActionHint,
                controlBelow: true,
                control: SegmentedButton<_ActionKind>(
                  segments: [
                    ButtonSegment(value: _ActionKind.preset, label: Text(l.pPreset)),
                    ButtonSegment(value: _ActionKind.recipe, label: Text(l.toolRecipes)),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (v) => setState(() => _kind = v.first),
                ),
              ),
              if (_kind == _ActionKind.preset)
                SettingTile(
                  title: l.pPreset,
                  hint: l.pRecipePresetHint,
                  control: _PresetPicker(value: _preset, onChanged: (v) => setState(() => _preset = v)),
                )
              else
                SettingTile(
                  title: l.toolRecipes,
                  hint: recipes.isEmpty ? l.noRecipes : l.pBatchRecipeHint,
                  control: DropdownButton<String>(
                    value: _recipe,
                    hint: Text(l.notSet),
                    onChanged: (v) => setState(() => _recipe = v),
                    items: [for (final r in recipes) DropdownMenuItem(value: r.id, child: Text(r.name))],
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.output),
                title: Text(_outDir ?? (_folder == null ? l.watchOutDefault : p.join(_folder!, 'kadra'))),
                subtitle: Text(l.watchOutHint),
                trailing: OutlinedButton(
                  onPressed: () async {
                    final d = await getDirectoryPath();
                    if (d != null) setState(() => _outDir = d);
                  },
                  child: Text(l.choose),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _folder == null || action == null
              ? null
              : () => Navigator.pop(
                  context,
                  WatchRule(
                    id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
                    folder: _folder!,
                    action: action,
                    outDir: _outDir,
                    recursive: _recursive,
                    kind: _filter,
                  ),
                ),
          child: Text(l.addWatch),
        ),
      ],
    );
  }
}
