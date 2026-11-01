/// Model files used by ffmpeg filters: RNNoise (`arnndn`) and whisper.cpp
/// (`whisper`). Downloaded on demand into `components/models`, verified by
/// SHA-256 (values taken from the hosting repositories).
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../providers.dart';
import 'downloader.dart';

enum ModelKind { rnnoise, whisper }

class ModelDef {
  const ModelDef(this.id, this.kind, this.url, {required this.sha256, required this.size});
  final String id;
  final ModelKind kind;
  final String url;
  final String sha256;
  final int size;

  String get fileName => p.basename(Uri.parse(url).path);
}

const _rnn = 'https://raw.githubusercontent.com/GregorR/rnnoise-models/master';
const _hf = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main';

const modelCatalog = <ModelDef>[
  ModelDef(
    'rnnSh',
    ModelKind.rnnoise,
    '$_rnn/somnolent-hogwash-2018-09-01/sh.rnnn',
    sha256: '70bb6685eb0c2a1d18e2918dca3fbfbd39317010b1802eb1b6ea73a92f3fdec0',
    size: 297646,
  ),
  ModelDef(
    'rnnBd',
    ModelKind.rnnoise,
    '$_rnn/beguiling-drafter-2018-08-30/bd.rnnn',
    sha256: 'ae3f7411e1e6a884f839a4a145c394408398f09854dbc1216ee02faafc98a17b',
    size: 299693,
  ),
  ModelDef(
    'rnnCb',
    ModelKind.rnnoise,
    '$_rnn/conjoined-burgers-2018-08-28/cb.rnnn',
    sha256: 'f1357c4e5be9dee8467bead486dfced2d75b640c26ad0b594fa7f102322371d9',
    size: 299741,
  ),
  ModelDef(
    'rnnLq',
    ModelKind.rnnoise,
    '$_rnn/leavened-quisling-2018-08-31/lq.rnnn',
    sha256: '1957528b752799fddf06270bc5469af7cf54c3badc358544ae2abed730943ff9',
    size: 297041,
  ),
  ModelDef(
    'rnnMp',
    ModelKind.rnnoise,
    '$_rnn/marathon-prescription-2018-08-29/mp.rnnn',
    sha256: '4e84a448a4baf937992aaf4d10c8258007ec5d24219b6647dfd5fb4b563ad231',
    size: 296861,
  ),
  ModelDef(
    'whisperTiny',
    ModelKind.whisper,
    '$_hf/ggml-tiny.bin',
    sha256: 'be07e048e1e599ad46341c8d2a135645097a538221678b7acdd1b1919c6e1b21',
    size: 77691713,
  ),
  ModelDef(
    'whisperBase',
    ModelKind.whisper,
    '$_hf/ggml-base.bin',
    sha256: '60ed5bc3dd14eea856493d334349b405782ddcaf0028d4b5df4088345fba2efe',
    size: 147951465,
  ),
  ModelDef(
    'whisperSmall',
    ModelKind.whisper,
    '$_hf/ggml-small.bin',
    sha256: '1be3a9b2063867b937e64e2ec7483364a79917e157fa98c5d94b5c1fffea987b',
    size: 487601967,
  ),
  ModelDef(
    'whisperMedium',
    ModelKind.whisper,
    '$_hf/ggml-medium-q5_0.bin',
    sha256: '19fea4b380c3a618ec4723c3eef2eb785ffba0d0538cf43f8f235e7b3b34220f',
    size: 539212467,
  ),
  ModelDef(
    'whisperTurbo',
    ModelKind.whisper,
    '$_hf/ggml-large-v3-turbo-q5_0.bin',
    sha256: '394221709cd5ad1f40c46e6031ca61bce88931e6e088c188294c6d5a55ffa7e2',
    size: 574041195,
  ),
];

ModelDef modelById(String id) => modelCatalog.firstWhere((m) => m.id == id);

class ModelsState {
  const ModelsState({this.installed = const {}, this.progress = const {}, this.errors = const {}});

  /// id → absolute path of installed models.
  final Map<String, String> installed;

  /// id → download fraction (null = unknown) for running downloads.
  final Map<String, double?> progress;
  final Map<String, String> errors;

  String? pathOf(String id) => installed[id];
  List<ModelDef> installedOf(ModelKind k) => [
    for (final m in modelCatalog)
      if (m.kind == k && installed.containsKey(m.id)) m,
  ];
}

class ModelsController extends Notifier<ModelsState> {
  final _cancels = <String, CancelToken>{};

  String get _dir => p.join(ref.read(appPathsProvider).components, 'models');

  @override
  ModelsState build() {
    final installed = <String, String>{};
    for (final m in modelCatalog) {
      final f = File(p.join(_dir, m.fileName));
      if (f.existsSync() && f.lengthSync() == m.size) installed[m.id] = f.path;
    }
    return ModelsState(installed: installed);
  }

  Future<void> install(ModelDef m) async {
    if (state.progress.containsKey(m.id)) return;
    final token = CancelToken();
    _cancels[m.id] = token;
    _set(progress: {...state.progress, m.id: 0}, errors: {...state.errors}..remove(m.id));
    final dest = p.join(_dir, m.fileName);
    final part = '$dest.part';
    try {
      await downloadFile(
        m.url,
        part,
        expectedSha256: m.sha256,
        cancel: token,
        onProgress: (d) => _set(progress: {...state.progress, m.id: d.total == null ? null : d.received / d.total!}),
      );
      await File(part).rename(dest);
      _set(installed: {...state.installed, m.id: dest}, progress: {...state.progress}..remove(m.id));
    } on DownloadCanceled {
      _set(progress: {...state.progress}..remove(m.id));
    } catch (e) {
      _set(progress: {...state.progress}..remove(m.id), errors: {...state.errors, m.id: e.toString()});
    } finally {
      _cancels.remove(m.id);
    }
  }

  void cancel(String id) => _cancels[id]?.cancel();

  Future<void> remove(ModelDef m) async {
    final path = state.installed[m.id];
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    _set(installed: {...state.installed}..remove(m.id));
  }

  void _set({Map<String, String>? installed, Map<String, double?>? progress, Map<String, String>? errors}) {
    if (!ref.mounted) return;
    state = ModelsState(
      installed: installed ?? state.installed,
      progress: progress ?? state.progress,
      errors: errors ?? state.errors,
    );
  }
}

final modelsProvider = NotifierProvider<ModelsController, ModelsState>(ModelsController.new);
