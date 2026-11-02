/// Recipes and watch folders as app state, plus the background work:
/// watching folders and chaining a recipe after a download finishes.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:path/path.dart' as p;

import '../../core/components/models.dart';
import '../../core/presets/preset_repository.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/queue_models.dart';
import '../convert/convert_params.dart';
import '../tools/tool_infra.dart' show encodeEnvProvider;
import 'batch.dart';
import 'recipe.dart';

// ================================================================ recipes

class RecipesController extends AsyncNotifier<List<Recipe>> {
  String get _path => ref.read(appPathsProvider).recipes;

  @override
  Future<List<Recipe>> build() => loadRecipes(_path);

  Future<void> _save(List<Recipe> list) async {
    state = AsyncData(list);
    await saveRecipes(_path, list);
  }

  Future<Recipe> create(String name, {List<RecipeStep> steps = const []}) async {
    final r = Recipe(id: DateTime.now().microsecondsSinceEpoch.toRadixString(36), name: name, steps: steps);
    await _save([...?state.value, r]);
    return r;
  }

  Future<void> put(Recipe r) async => _save([for (final x in state.value ?? const <Recipe>[]) x.id == r.id ? r : x]);

  Future<void> delete(String id) async => _save([...?state.value?.where((r) => r.id != id)]);

  /// Adds imported recipes; each gets a new id so nothing is overwritten.
  Future<int> import(List<Recipe> recipes) async {
    final base = DateTime.now().microsecondsSinceEpoch;
    await _save([
      ...?state.value,
      for (var i = 0; i < recipes.length; i++)
        Recipe(id: (base + i).toRadixString(36), name: recipes[i].name, steps: recipes[i].steps),
    ]);
    return recipes.length;
  }
}

final recipesProvider = AsyncNotifierProvider<RecipesController, List<Recipe>>(RecipesController.new);

/// What to do with each file of a batch or a watch folder.
class BatchAction {
  const BatchAction.preset(this.presetId) : recipeId = null;
  const BatchAction.recipe(this.recipeId) : presetId = null;
  final String? presetId;
  final String? recipeId;

  Map<String, Object?> toJson() => {'preset': ?presetId, 'recipe': ?recipeId};
  static BatchAction? fromJson(Map<String, Object?> j) => j['recipe'] != null
      ? BatchAction.recipe(j['recipe'] as String)
      : (j['preset'] != null ? BatchAction.preset(j['preset'] as String) : null);

  /// A preset is a one-step recipe.
  Recipe? resolve(List<Recipe> recipes) => recipeId != null
      ? recipes.where((r) => r.id == recipeId).firstOrNull
      : Recipe(
          id: 'preset',
          name: presetId!,
          steps: [
            RecipeStep(RecipeOp.convert, {'preset': presetId}),
          ],
        );
}

/// Builds the recipe environment from the app state (presets, models, HW).
/// [read] is `ref.read` of a provider or a widget.
Future<RecipeEnv> recipeEnv(T Function<T>(ProviderListenable<T>) read) async {
  final presets = await read(presetRepositoryProvider).all();
  final models = read(modelsProvider);
  final rnn = models.installedOf(ModelKind.rnnoise).firstOrNull;
  return RecipeEnv(
    encode: read(encodeEnvProvider),
    userPresets: {
      for (final up in presets)
        if (up.toolId == 'convert' || up.toolId == 'compress') 'user:${up.id}': ConvertParams.fromJson(up.params),
    },
    rnnoiseModel: rnn == null ? null : models.pathOf(rnn.id),
  );
}

/// Queue request for one file, or a reason it cannot be processed.
({JobRequest? request, String? problem}) recipeJob({
  required MediaInfo info,
  required Recipe recipe,
  required RecipeEnv env,
  required String output,
  required String title,
  int priority = 0,
}) {
  final problem = recipeProblem(recipe, info, env);
  if (problem != null) return (request: null, problem: problem);
  return (
    request: JobRequest(
      kind: 'recipe',
      title: title,
      tool: JobTool.ffmpeg,
      steps: planRecipe(info: info, r: recipe, output: output, env: env),
      inputPath: info.path,
      outputPath: output,
      totalDuration: info.duration,
      priority: priority,
    ),
    problem: null,
  );
}

// ========================================================= watch folders

class WatchRule {
  const WatchRule({
    required this.id,
    required this.folder,
    required this.action,
    this.outDir,
    this.recursive = false,
    this.kind = FileKindFilter.all,
    this.enabled = true,
  });
  final String id;
  final String folder;
  final BatchAction action;

  /// null = a `kadra` sub-folder of the watched folder.
  final String? outDir;
  final bool recursive;
  final FileKindFilter kind;
  final bool enabled;

  String get effectiveOutDir => outDir ?? p.join(folder, 'kadra');

  WatchRule copyWith({bool? enabled}) => WatchRule(
    id: id,
    folder: folder,
    action: action,
    outDir: outDir,
    recursive: recursive,
    kind: kind,
    enabled: enabled ?? this.enabled,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'folder': folder,
    'action': action.toJson(),
    'outDir': ?outDir,
    'recursive': recursive,
    'kind': kind.name,
    'enabled': enabled,
  };

  static WatchRule? fromJson(Map<String, Object?> j) {
    final a = BatchAction.fromJson(((j['action'] as Map?) ?? const {}).cast<String, Object?>());
    if (a == null) return null;
    return WatchRule(
      id: j['id'] as String,
      folder: j['folder'] as String,
      action: a,
      outDir: j['outDir'] as String?,
      recursive: j['recursive'] as bool? ?? false,
      kind: FileKindFilter.values.asNameMap()[j['kind']] ?? FileKindFilter.all,
      enabled: j['enabled'] as bool? ?? true,
    );
  }
}

class WatchEvent {
  const WatchEvent(this.time, this.path, {this.problem, this.queued = false});
  final DateTime time;
  final String path;
  final String? problem;
  final bool queued;
}

class WatchState {
  const WatchState({this.rules = const [], this.log = const [], this.active = const {}});
  final List<WatchRule> rules;
  final List<WatchEvent> log;

  /// Rule ids whose folder is currently watched.
  final Set<String> active;
}

/// Watches enabled folders while the app runs. New (or changed) files are
/// processed once their size stops changing; the output folder is never
/// watched itself, so results do not loop.
class WatchController extends Notifier<WatchState> {
  final _subs = <String, StreamSubscription<FileSystemEvent>>{};
  final _seen = <String>{};
  final _pending = <String>{};

  String get _path => ref.read(appPathsProvider).watchers;

  @override
  WatchState build() {
    ref.onDispose(() {
      for (final s in _subs.values) {
        unawaited(s.cancel());
      }
    });
    unawaited(_load());
    return const WatchState();
  }

  Future<void> _load() async {
    final f = File(_path);
    if (!f.existsSync()) return;
    try {
      final j = jsonDecode(await f.readAsString()) as Map;
      final rules = [
        for (final r in (j['rules'] as List? ?? const [])) ?WatchRule.fromJson((r as Map).cast<String, Object?>()),
      ];
      _seen.addAll(((j['seen'] as List?) ?? const []).cast<String>());
      state = WatchState(rules: rules, log: state.log);
      _restart();
    } catch (_) {}
  }

  Future<void> _save() async {
    final f = File(_path);
    await f.parent.create(recursive: true);
    // Remember at most the last 5000 processed files.
    final seen = _seen.length > 5000 ? _seen.skip(_seen.length - 5000).toList() : _seen.toList();
    await f.writeAsString(
      jsonEncode({
        'rules': [for (final r in state.rules) r.toJson()],
        'seen': seen,
      }),
    );
  }

  Future<void> add(WatchRule r) async {
    // Files already there are not processed — only new ones.
    if (Directory(r.folder).existsSync()) {
      for (final f in await scanFolder(r.folder, recursive: r.recursive, kind: r.kind)) {
        _seen.add(_key(f));
      }
    }
    state = WatchState(rules: [...state.rules, r], log: state.log, active: state.active);
    await _save();
    _restart();
  }

  Future<void> remove(String id) async {
    state = WatchState(rules: [...state.rules.where((r) => r.id != id)], log: state.log, active: state.active);
    await _save();
    _restart();
  }

  Future<void> setEnabled(String id, bool on) async {
    state = WatchState(
      rules: [for (final r in state.rules) r.id == id ? r.copyWith(enabled: on) : r],
      log: state.log,
      active: state.active,
    );
    await _save();
    _restart();
  }

  String _key(String path) {
    try {
      final st = File(path).statSync();
      return '$path|${st.size}|${st.modified.millisecondsSinceEpoch}';
    } catch (_) {
      return path;
    }
  }

  void _restart() {
    for (final s in _subs.values) {
      unawaited(s.cancel());
    }
    _subs.clear();
    final active = <String>{};
    for (final r in state.rules.where((r) => r.enabled)) {
      final dir = Directory(r.folder);
      if (!dir.existsSync()) continue;
      try {
        _subs[r.id] = dir.watch(recursive: r.recursive).listen((e) {
          if (e is FileSystemDeleteEvent) return;
          final path = e is FileSystemMoveEvent ? (e.destination ?? e.path) : e.path;
          unawaited(_onFile(r, path));
        });
        active.add(r.id);
      } catch (_) {}
    }
    state = WatchState(rules: state.rules, log: state.log, active: active);
  }

  void _log(WatchEvent e) {
    final log = [e, ...state.log];
    state = WatchState(rules: state.rules, log: log.length > 100 ? log.sublist(0, 100) : log, active: state.active);
  }

  Future<void> _onFile(WatchRule r, String path) async {
    if (!matchesKind(path, r.kind) || p.isWithin(r.effectiveOutDir, path) || p.equals(r.effectiveOutDir, path)) return;
    if (p.basename(path).startsWith('.') || _pending.contains(path)) return;
    if (!File(path).existsSync()) return;
    _pending.add(path);
    try {
      if (!await waitUntilComplete(path)) return;
      final key = _key(path);
      if (_seen.contains(key) || !ref.mounted) return;
      _seen.add(key);
      await _save();
      final probe = ref.read(probeServiceProvider);
      final recipes = await ref.read(recipesProvider.future);
      final recipe = r.action.resolve(recipes);
      if (probe == null || recipe == null) {
        _log(WatchEvent(DateTime.now(), path, problem: probe == null ? 'ffprobe' : 'recipe'));
        return;
      }
      final MediaInfo info;
      try {
        info = await probe.probe(path);
      } catch (_) {
        _log(WatchEvent(DateTime.now(), path, problem: 'probe'));
        return;
      }
      final env = await recipeEnv(ref.read);
      await Directory(r.effectiveOutDir).create(recursive: true);
      final out = batchOutput(
        input: path,
        ext: recipeOutputExt(recipe, info, env),
        outDir: r.effectiveOutDir,
        root: r.folder,
      );
      final job = recipeJob(
        info: info,
        recipe: recipe,
        env: env,
        output: out,
        title: '${recipe.name}: ${p.basename(path)}',
      );
      if (job.request == null) {
        _log(WatchEvent(DateTime.now(), path, problem: job.problem));
        return;
      }
      await ref.read(queueProvider.notifier).enqueue(job.request!);
      _log(WatchEvent(DateTime.now(), path, queued: true));
    } finally {
      _pending.remove(path);
    }
  }
}

final watchProvider = NotifierProvider<WatchController, WatchState>(WatchController.new);

// ====================================================== recipe after job

/// When a job carrying `thenRecipe` in its extra data completes, its
/// output is probed and the recipe is queued for it (e.g. after yt-dlp).
final chainRecipesProvider = Provider<void>((ref) {
  final done = <String>{};
  ref.listen(queueProvider, (prev, next) async {
    for (final item in next.items) {
      if (item.status != JobStatus.completed || done.contains(item.id)) continue;
      final recipeId = item.extra['thenRecipe'] as String?;
      if (recipeId == null) continue;
      final before = prev?.items.where((i) => i.id == item.id).firstOrNull;
      if (before == null || before.status == JobStatus.completed) continue;
      done.add(item.id);
      final path = item.job.outputPath;
      final probe = ref.read(probeServiceProvider);
      final recipe = (await ref.read(recipesProvider.future)).where((r) => r.id == recipeId).firstOrNull;
      if (path == null || probe == null || recipe == null || !File(path).existsSync()) continue;
      try {
        final info = await probe.probe(path);
        final env = await recipeEnv(ref.read);
        final out = batchOutput(input: path, ext: recipeOutputExt(recipe, info, env));
        final job = recipeJob(
          info: info,
          recipe: recipe,
          env: env,
          output: out,
          title: '${recipe.name}: ${p.basename(path)}',
        );
        if (job.request != null) await ref.read(queueProvider.notifier).enqueue(job.request!);
      } catch (_) {}
    }
  });
});
