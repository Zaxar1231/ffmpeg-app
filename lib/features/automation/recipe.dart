/// Recipes (stage 5): an ordered chain of operations applied to a file.
/// Each operation is planned with the existing builders; intermediate
/// results live in the job's `{{tmp}}` folder, the last step writes the
/// output. Recipes are stored as JSON (`recipes.json` in the app data).
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/engine/capabilities.dart' show MediaKind;
import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../audio/audio_chain.dart';
import '../audio/audio_ops.dart';
import '../convert/builtin_presets.dart';
import '../convert/convert_params.dart';
import '../edit/edit_encode.dart';
import '../edit/graphs.dart';
import '../metadata/meta_ops.dart';
import '../subtitles/subs_ops.dart';

enum RecipeOp {
  /// Convert with a built-in or user preset (`preset`: id or `user:<id>`).
  convert,

  /// Loudness normalization (`lufs`: −14 / −16 / −23).
  normalize,

  /// Vertical 9:16 with a blurred background (`height`).
  vertical,

  /// Downscale to `height` (never upscales).
  scale,

  /// Noise reduction: RNNoise when a model is installed, else FFT denoise.
  denoise,

  /// Fade in/out of video and audio (`seconds`).
  fade,

  /// Text caption (`text`, `corner`).
  text,

  /// Logo image (`image`, `corner`, `size` share of width).
  logo,

  /// Burn in `<name>.srt`/`.ass` next to the source, when present.
  burnSidecar,

  /// Remove tags, chapters and cover.
  stripMetadata,

  /// MP4 index to the front.
  faststart,

  /// Audio only: `format` mp3 / m4a / flac / opus.
  extractAudio,
}

class RecipeStep {
  const RecipeStep(this.op, [this.params = const {}]);
  final RecipeOp op;
  final Map<String, Object?> params;

  T? get<T>(String k) => params[k] is T ? params[k] as T : null;
  double number(String k, double def) => (params[k] as num?)?.toDouble() ?? def;

  Map<String, Object?> toJson() => {'op': op.name, 'params': params};
  factory RecipeStep.fromJson(Map<String, Object?> j) => RecipeStep(
    RecipeOp.values.byName(j['op'] as String),
    ((j['params'] as Map?) ?? const {}).cast<String, Object?>(),
  );
}

class Recipe {
  const Recipe({required this.id, required this.name, required this.steps});
  final String id;
  final String name;
  final List<RecipeStep> steps;

  Recipe copyWith({String? name, List<RecipeStep>? steps}) =>
      Recipe(id: id, name: name ?? this.name, steps: steps ?? this.steps);

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'steps': [for (final s in steps) s.toJson()],
  };
  factory Recipe.fromJson(Map<String, Object?> j) => Recipe(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    steps: [for (final s in (j['steps'] as List? ?? const [])) RecipeStep.fromJson((s as Map).cast<String, Object?>())],
  );
}

/// Recipes file: `{"recipes": [...]}`.
Future<List<Recipe>> loadRecipes(String path) async {
  final f = File(path);
  if (!f.existsSync()) return const [];
  try {
    final j = jsonDecode(await f.readAsString()) as Map;
    return [for (final r in (j['recipes'] as List? ?? const [])) Recipe.fromJson((r as Map).cast<String, Object?>())];
  } catch (_) {
    return const [];
  }
}

Future<void> saveRecipes(String path, List<Recipe> recipes) async {
  final f = File(path);
  await f.parent.create(recursive: true);
  final tmp = File('$path.tmp');
  await tmp.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'recipes': [for (final r in recipes) r.toJson()],
    }),
  );
  await tmp.rename(path);
}

/// Everything a recipe needs from the app to plan a file.
class RecipeEnv {
  const RecipeEnv({this.encode = const EncodeEnv(), this.userPresets = const {}, this.rnnoiseModel});
  final EncodeEnv encode;

  /// `user:<id>` → convert parameters.
  final Map<String, ConvertParams> userPresets;
  final String? rnnoiseModel;

  ConvertParams? preset(String? id) {
    if (id == null) return null;
    if (id.startsWith('user:')) return userPresets[id];
    return builtinPresets.where((b) => b.id == id).firstOrNull?.params;
  }
}

String _audioExt(String f) => switch (f) {
  'm4a' => 'm4a',
  'flac' => 'flac',
  'opus' => 'opus',
  _ => 'mp3',
};

/// Container a step writes.
String stepExt(RecipeStep s, String current, RecipeEnv env) => switch (s.op) {
  RecipeOp.convert => env.preset(s.get<String>('preset'))?.container ?? current,
  RecipeOp.extractAudio => _audioExt(s.get<String>('format') ?? 'mp3'),
  _ => current,
};

/// Container of the recipe result for [info].
String recipeOutputExt(Recipe r, MediaInfo info, RecipeEnv env) {
  final e = p.extension(info.path).replaceFirst('.', '').toLowerCase();
  var ext = containers.containsKey(e) ? e : 'mkv';
  for (final s in r.steps) {
    ext = stepExt(s, ext, env);
  }
  return ext;
}

/// Why a recipe cannot run on [info] (null = fine).
String? recipeProblem(Recipe r, MediaInfo info, RecipeEnv env) {
  if (r.steps.isEmpty) return 'empty';
  var hasVideo = info.videoStreams.isNotEmpty;
  final hasAudio = info.audioStreams.isNotEmpty;
  for (final s in r.steps) {
    switch (s.op) {
      case RecipeOp.convert:
        if (env.preset(s.get<String>('preset')) == null) return 'preset';
      case RecipeOp.vertical ||
          RecipeOp.scale ||
          RecipeOp.text ||
          RecipeOp.logo ||
          RecipeOp.burnSidecar ||
          RecipeOp.fade:
        if (!hasVideo && s.op != RecipeOp.fade) return 'video';
      case RecipeOp.normalize || RecipeOp.denoise || RecipeOp.extractAudio:
        if (!hasAudio) return 'audio';
        if (s.op == RecipeOp.extractAudio) hasVideo = false;
      case RecipeOp.stripMetadata || RecipeOp.faststart:
        break;
    }
  }
  return null;
}

/// The subtitle file next to [path] (`name.srt`, `name.ass`, `name.ru.srt`…).
String? sidecarSubtitle(String path) {
  final dir = Directory(p.dirname(path));
  final base = p.basenameWithoutExtension(path);
  if (!dir.existsSync()) return null;
  final cands =
      dir
          .listSync()
          .whereType<File>()
          .where((f) {
            final n = p.basename(f.path);
            final ext = p.extension(n).replaceFirst('.', '').toLowerCase();
            return n.startsWith(base) && const ['srt', 'ass', 'ssa', 'vtt'].contains(ext);
          })
          .map((f) => f.path)
          .toList()
        ..sort((a, b) => a.length.compareTo(b.length));
  return cands.firstOrNull;
}

MediaInfo _at(MediaInfo info, String path, {bool audioOnly = false}) => MediaInfo(
  path: path,
  format: info.format,
  streams: audioOnly
      ? [
          for (final s in info.streams)
            if (s.kind == MediaKind.audio) s,
        ]
      : info.streams,
  chapters: info.chapters,
);

/// Plans every step of [r] for [info] → [output].
List<JobStep> planRecipe({required MediaInfo info, required Recipe r, required String output, required RecipeEnv env}) {
  final steps = <JobStep>[];
  var cur = info;
  final srcExt = p.extension(info.path).replaceFirst('.', '').toLowerCase();
  var ext = containers.containsKey(srcExt) ? srcExt : 'mkv';
  const mid = EditOutput(ext: 'mkv', quality: EditQuality.high, speed: SpeedPreset.fast);
  for (var i = 0; i < r.steps.length; i++) {
    final s = r.steps[i];
    final last = i == r.steps.length - 1;
    ext = stepExt(s, ext, env);
    // Intermediate files keep the step's container (mkv holds anything).
    final midExt = s.op == RecipeOp.convert || s.op == RecipeOp.extractAudio ? ext : 'mkv';
    final out = last ? output : p.join('{{tmp}}', 'step$i.$midExt');
    final outExt = last ? ext : midExt;
    final enc = EditOutput(ext: outExt, quality: last ? EditQuality.high : mid.quality, speed: mid.speed);
    List<JobStep> edit(EditGraph g) => planEdit(info: cur, output: out, graph: g, out: enc, env: env.encode).steps;
    final List<JobStep> planned;
    switch (s.op) {
      case RecipeOp.convert:
        planned = planConvert(info: cur, output: out, p: env.preset(s.get<String>('preset'))!, env: env.encode).steps;
      case RecipeOp.normalize:
        final lufs = s.number('lufs', -14);
        final t = LoudnessTarget('recipe', lufs, -1.5, 11);
        planned = planNormalize(info: cur, output: out, target: t, ext: outExt);
      case RecipeOp.vertical:
        planned = edit(
          cropScaleGraph(
            cur,
            CropScaleParams(aspect: 9 / 16, height: s.number('height', 1920).round(), fit: FitMode.blur),
          ),
        );
      case RecipeOp.scale:
        final h = s.number('height', 1080).round();
        final srcH = displaySize(cur).$2;
        // Never upscale: a smaller file is passed on unchanged.
        planned = srcH <= h ? _copy(cur, out) : edit(cropScaleGraph(cur, CropScaleParams(height: h)));
      case RecipeOp.denoise:
        final ctx = fileFxContext(cur);
        final items = env.rnnoiseModel != null
            ? [ChainItem.rnnoise(env.rnnoiseModel)]
            : [
                const ChainItem.fx('noiseReduction', {'reduction': 12, 'floor': -50, 'track': 1}),
              ];
        planned = planAudioChain(info: cur, output: out, filters: chainFilters(items, ctx));
      case RecipeOp.fade:
        final d = Duration(milliseconds: (s.number('seconds', 1) * 1000).round());
        planned = edit(fadeGraph(cur, d, d));
      case RecipeOp.text:
        planned = edit(
          overlayGraph(
            cur,
            OverlayParams(
              text: s.get<String>('text') ?? '',
              textCorner: Corner.values.byName(s.get<String>('corner') ?? Corner.bottom.name),
            ),
          ),
        );
      case RecipeOp.logo:
        planned = edit(
          overlayGraph(
            cur,
            OverlayParams(
              imagePath: s.get<String>('image'),
              imageCorner: Corner.values.byName(s.get<String>('corner') ?? Corner.bottomRight.name),
              imageScale: s.number('size', 0.15),
            ),
          ),
        );
      case RecipeOp.burnSidecar:
        final sub = sidecarSubtitle(info.path);
        planned = sub == null ? _copy(cur, out) : edit(burnGraph(cur, subFile: sub, charset: s.get<String>('charset')));
      case RecipeOp.stripMetadata:
        planned = _copy(cur, out, strip: true);
      case RecipeOp.faststart:
        planned = planFaststart(info: cur, output: out);
      case RecipeOp.extractAudio:
        final f = _audioExt(s.get<String>('format') ?? 'mp3');
        planned = planExtractAudio(
          info: cur,
          output: out,
          streamIndex: cur.audioStreams.first.index,
          format: switch (f) {
            'm4a' => ExtractFormat.aac,
            'flac' => ExtractFormat.flac,
            'opus' => ExtractFormat.opus,
            _ => ExtractFormat.mp3,
          },
        );
    }
    final label = '${i + 1}/${r.steps.length}';
    for (final st in planned) {
      steps.add(
        JobStep(
          args: st.args,
          tool: st.tool,
          label: st.label == null ? label : '$label · ${st.label}',
          weight: st.weight,
          capture: st.capture,
          workingDirectory: st.workingDirectory,
          totalDuration: st.totalDuration ?? info.duration,
          files: st.files,
        ),
      );
    }
    cur = _at(cur, out, audioOnly: s.op == RecipeOp.extractAudio);
  }
  return steps;
}

/// Stream copy, optionally dropping all metadata.
List<JobStep> _copy(MediaInfo info, String output, {bool strip = false}) {
  final steps = planTags(info: info, output: output, tags: const {}, clearAll: strip);
  if (!strip) return steps;
  final a = List<String>.of(steps.single.args);
  a.insertAll(a.length - 1, ['-map_chapters', '-1']);
  return [JobStep(args: a, totalDuration: info.duration)];
}
