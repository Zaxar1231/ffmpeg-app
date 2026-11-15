/// Files used by ffmpeg filters: RNNoise models (`arnndn`), whisper.cpp
/// models (`whisper`) and fonts with Cyrillic for subtitles and `drawtext`.
/// Downloaded on demand into `components/models` (fonts: `components/fonts`,
/// passed to libass as `fontsdir`), verified by SHA-256.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../providers.dart';
import 'downloader.dart';

enum ModelKind { rnnoise, whisper, font }

class ModelDef {
  const ModelDef(this.id, this.kind, this.url, {required this.sha256, required this.size, this.file, this.family});
  final String id;
  final ModelKind kind;
  final String url;
  final String sha256;
  final int size;

  /// Local file name (default: from the URL).
  final String? file;

  /// Font family name, as libass and fontconfig see it.
  final String? family;

  String get fileName => file ?? p.basename(Uri.parse(url).path);
}

/// google/fonts at a fixed commit, so the checksums stay valid. All of these
/// fonts cover Cyrillic; licenses: SIL Open Font License.
const _gf = 'https://raw.githubusercontent.com/google/fonts/cc39c4c2c304bc368c9b7c311ea2bcc6013299fe/ofl';

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
  ModelDef(
    'fontNotoSans',
    ModelKind.font,
    '$_gf/notosans/NotoSans%5Bwdth,wght%5D.ttf',
    sha256: 'bfb7bb691513f12e734dc346c03a03f784912432d7e3fa8e56efcf906fe86b3d',
    size: 2049096,
    file: 'NotoSans.ttf',
    family: 'Noto Sans',
  ),
  ModelDef(
    'fontPtSans',
    ModelKind.font,
    '$_gf/ptsans/PT_Sans-Web-Regular.ttf',
    sha256: '9cc831490532009bae2b3ce0d39c62adfc889060beb421593bfd9d2396d0f10a',
    size: 442960,
    file: 'PTSans-Regular.ttf',
    family: 'PT Sans',
  ),
  ModelDef(
    'fontPtSansBold',
    ModelKind.font,
    '$_gf/ptsans/PT_Sans-Web-Bold.ttf',
    sha256: '3128bd5ecf01816e59a23d54c57a7a6b14615b07db53ff277c77376010265b05',
    size: 470240,
    file: 'PTSans-Bold.ttf',
    family: 'PT Sans',
  ),
  ModelDef(
    'fontPtSerif',
    ModelKind.font,
    '$_gf/ptserif/PT_Serif-Web-Regular.ttf',
    sha256: 'a4951fade06ff8f09b7673aa81ffb65a8cd409e24d3289a6dc670bc4dda2557a',
    size: 359048,
    file: 'PTSerif-Regular.ttf',
    family: 'PT Serif',
  ),
  ModelDef(
    'fontMontserrat',
    ModelKind.font,
    '$_gf/montserrat/Montserrat%5Bwght%5D.ttf',
    sha256: '0f7b311b2f3279e4eef9b2f968bcdbab6e28f4daeb1f049f4f278a902bcd82f7',
    size: 744936,
    file: 'Montserrat.ttf',
    family: 'Montserrat',
  ),
  ModelDef(
    'fontOswald',
    ModelKind.font,
    '$_gf/oswald/Oswald%5Bwght%5D.ttf',
    sha256: '5b38c246e255a12f5712d640d56bcced0472466fc68983d2d0410ec0457c2817',
    size: 172088,
    file: 'Oswald.ttf',
    family: 'Oswald',
  ),
  ModelDef(
    'fontRobotoMono',
    ModelKind.font,
    '$_gf/robotomono/RobotoMono%5Bwght%5D.ttf',
    sha256: '66a80e79d17e4c7cabd162e2916578a4cc08fd19eef6e2a643305eae9c567b2b',
    size: 183700,
    file: 'RobotoMono.ttf',
    family: 'Roboto Mono',
  ),
  ModelDef(
    'fontLobster',
    ModelKind.font,
    '$_gf/lobster/Lobster-Regular.ttf',
    sha256: 'd6568e697fd50cedc0be04d8aae4127fe95add607e7bff954ca88604be80c205',
    size: 406076,
    file: 'Lobster-Regular.ttf',
    family: 'Lobster',
  ),
  ModelDef(
    'fontCaveat',
    ModelKind.font,
    '$_gf/caveat/Caveat%5Bwght%5D.ttf',
    sha256: '0bdb6b660482d31531b3945849fba5916b3ef8695da7024a9e6b9ee3c4157988',
    size: 403648,
    file: 'Caveat.ttf',
    family: 'Caveat',
  ),
  ModelDef(
    'fontRubikMonoOne',
    ModelKind.font,
    '$_gf/rubikmonoone/RubikMonoOne-Regular.ttf',
    sha256: 'b22624b6a36e543e942106edfccd198c50b57b65b924bfe02a6f0a5699429e6b',
    size: 141088,
    file: 'RubikMonoOne-Regular.ttf',
    family: 'Rubik Mono One',
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

  String get _modelsDir => p.join(ref.read(appPathsProvider).components, 'models');

  /// Folder with the downloaded fonts (libass `fontsdir`).
  String get fontsDir => p.join(ref.read(appPathsProvider).components, 'fonts');

  String _dir(ModelDef m) => m.kind == ModelKind.font ? fontsDir : _modelsDir;

  @override
  ModelsState build() {
    final installed = <String, String>{};
    for (final m in modelCatalog) {
      final f = File(p.join(_dir(m), m.fileName));
      if (f.existsSync() && f.lengthSync() == m.size) installed[m.id] = f.path;
    }
    return ModelsState(installed: installed);
  }

  Future<void> install(ModelDef m) async {
    if (state.progress.containsKey(m.id)) return;
    final token = CancelToken();
    _cancels[m.id] = token;
    _set(progress: {...state.progress, m.id: 0}, errors: {...state.errors}..remove(m.id));
    final dest = p.join(_dir(m), m.fileName);
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
