import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' show Media, Player;
import 'package:path/path.dart' as p;

import '../../../core/platform/app_paths.dart';
import '../../../core/providers.dart';
import '../../../ui/l10n.dart';
import '../../../ui/widgets/common.dart';
import '../editor_controller.dart';
import '../engine/dsp.dart';
import '../engine/effects.dart';
import '../engine/generators.dart';
import 'fx_labels.dart';
import 'painters.dart';

String _fmt(double v, FxParam p) {
  final step = p.step ?? (p.max - p.min) / 1000;
  final digits = step >= 1 ? 0 : (step >= 0.1 ? 1 : (step >= 0.01 ? 2 : 3));
  return v.toStringAsFixed(digits);
}

/// Slider/dropdown/switch editors for a parameter list.
class FxParamEditor extends StatelessWidget {
  const FxParamEditor({
    super.key,
    required this.fxId,
    required this.params,
    required this.values,
    required this.onChanged,
  });
  final String fxId;
  final List<FxParam> params;
  final FxValues values;
  final ValueChanged<FxValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (fxId == 'graphicEq') return _graphicEq(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final pr in params)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(width: 190, child: Text(paramLabel(l, fxId, pr.id))),
                Expanded(child: _editor(context, pr)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _editor(BuildContext context, FxParam pr) {
    final l = context.l10n;
    final v = values[pr.id] ?? pr.def;
    void set(double x) => onChanged({...values, pr.id: x});
    if (pr.isChoice) {
      return Align(
        alignment: Alignment.centerLeft,
        child: DropdownButton<int>(
          value: v.round().clamp(0, pr.choices!.length - 1),
          onChanged: (i) => set(i!.toDouble()),
          items: [
            for (var i = 0; i < pr.choices!.length; i++)
              DropdownMenuItem(value: i, child: Text(choiceLabel(l, pr.id, pr.choices![i]))),
          ],
        ),
      );
    }
    if (pr.isBool) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Switch(value: v > 0.5, onChanged: (b) => set(b ? 1 : 0)),
      );
    }
    // Frequencies and long time ranges are easier on a log scale.
    final logScale = (pr.unit == FxUnit.hz || pr.unit == FxUnit.ms) && pr.min > 0 && pr.max / pr.min > 50;
    final sv = logScale ? math.log(v.clamp(pr.min, pr.max)) : v.clamp(pr.min, pr.max);
    final smin = logScale ? math.log(pr.min) : pr.min;
    final smax = logScale ? math.log(pr.max) : pr.max;
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: sv.toDouble(),
            min: smin,
            max: smax,
            divisions: !logScale && pr.step != null ? ((pr.max - pr.min) / pr.step!).round().clamp(1, 2000) : null,
            onChanged: (x) {
              var nv = logScale ? math.exp(x) : x;
              if (pr.step != null) nv = (nv / pr.step!).round() * pr.step!;
              set(nv.clamp(pr.min, pr.max).toDouble());
            },
          ),
        ),
        SizedBox(
          width: 110,
          child: _ValueField(
            text: _fmt(v, pr),
            suffix: unitLabel(l, pr.unit),
            onSubmitted: (t) {
              final x = double.tryParse(t.replaceAll(',', '.'));
              if (x != null) set(x.clamp(pr.min, pr.max));
            },
          ),
        ),
      ],
    );
  }

  Widget _graphicEq(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: Row(
            children: [
              for (final pr in params)
                Expanded(
                  child: Column(
                    children: [
                      Text((values[pr.id] ?? 0).toStringAsFixed(0), style: Theme.of(context).textTheme.labelSmall),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: values[pr.id] ?? 0,
                            min: pr.min,
                            max: pr.max,
                            onChanged: (x) => onChanged({...values, pr.id: (x * 2).round() / 2}),
                          ),
                        ),
                      ),
                      Text(paramLabel(l, fxId, pr.id), style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () => onChanged({for (final p0 in params) p0.id: 0}), child: Text(l.flatten)),
        ),
      ],
    );
  }
}

class _ValueField extends StatefulWidget {
  const _ValueField({required this.text, required this.onSubmitted, this.suffix = ''});
  final String text;
  final String suffix;
  final ValueChanged<String> onSubmitted;
  @override
  State<_ValueField> createState() => _ValueFieldState();
}

class _ValueFieldState extends State<_ValueField> {
  late final _c = TextEditingController(text: widget.text);
  final _f = FocusNode();
  @override
  void didUpdateWidget(covariant _ValueField old) {
    super.didUpdateWidget(old);
    if (!_f.hasFocus && _c.text != widget.text) _c.text = widget.text;
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _c,
    focusNode: _f,
    decoration: InputDecoration(isDense: true, suffixText: widget.suffix),
    onSubmitted: widget.onSubmitted,
    onTapOutside: (_) {
      widget.onSubmitted(_c.text);
      _f.unfocus();
    },
  );
}

/// Plays a file once (effect preview, A/B).
class _PreviewPlayer {
  Player? _player;
  Future<void> play(String file) async {
    _player ??= Player();
    await _player!.open(Media(file));
  }

  Future<void> stop() async => _player?.stop();
  void dispose() => _player?.dispose();
}

// ---------------------------------------------------------------- effect dialog

Future<void> showEffectDialog(BuildContext context, WidgetRef ref, FxDef fx) => showDialog<void>(
  context: context,
  builder: (_) => _EffectDialog(fx: fx),
);

class _EffectDialog extends ConsumerStatefulWidget {
  const _EffectDialog({required this.fx});
  final FxDef fx;
  @override
  ConsumerState<_EffectDialog> createState() => _EffectDialogState();
}

class _EffectDialogState extends ConsumerState<_EffectDialog> {
  late FxValues _v = widget.fx.defaults();
  final _preview = _PreviewPlayer();
  bool? _broken;
  bool _useProfile = true;
  String? _control;
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    ref.read(audioEditorProvider.notifier).isEffectBroken(widget.fx).then((b) {
      if (mounted) setState(() => _broken = b);
    });
  }

  @override
  void dispose() {
    _preview.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final st = ref.watch(audioEditorProvider);
    final ctl = ref.read(audioEditorProvider.notifier);
    final fx = widget.fx;
    final targets = st.targetTracks;
    final others = st.project.tracks.where((t) => !targets.any((x) => x.id == t.id)).toList();
    final mono = targets.isNotEmpty && targets.every((t) => t.channels < 2);
    return AlertDialog(
      title: Text(fxName(l, fx.id)),
      content: SizedBox(
        width: fx.id == 'graphicEq' ? 900 : 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fxDescription(l, fx.id), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                st.selection == null ? l.applyToWholeTracks(targets.length) : l.applyToSelection(targets.length),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              if (_broken == true) _warn(context, l.fxBrokenInBuild),
              if (fx.stereoOnly && mono) _warn(context, l.fxStereoOnly),
              if (fx.kind == FxKind.dsp) _info(context, l.fxDartDsp),
              if (fx.id == 'noiseReduction')
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _useProfile && st.noiseProfile != null,
                  onChanged: st.noiseProfile == null ? null : (v) => setState(() => _useProfile = v),
                  title: Text(l.useNoiseProfile),
                  subtitle: Text(
                    st.noiseProfile == null
                        ? l.noNoiseProfile
                        : l.noiseProfileReady((st.noiseProfile!.frames / st.project.sampleRate).toStringAsFixed(2)),
                  ),
                ),
              if (fx.kind == FxKind.sidechain)
                Row(
                  children: [
                    SizedBox(width: 190, child: Text(l.controlTrack)),
                    DropdownButton<String>(
                      value: _control,
                      hint: Text(l.chooseTrack),
                      onChanged: (v) => setState(() => _control = v),
                      items: [for (final t in others) DropdownMenuItem(value: t.id, child: Text(t.name))],
                    ),
                  ],
                ),
              FxParamEditor(fxId: fx.id, params: fx.params, values: _v, onChanged: (v) => setState(() => _v = v)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => setState(() => _v = fx.defaults()), child: Text(l.resetTooltip)),
        if (fx.kind != FxKind.sidechain)
          TextButton.icon(
            icon: _previewing
                ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            label: Text(l.preview),
            onPressed: _previewing || _broken == true
                ? null
                : () async {
                    setState(() => _previewing = true);
                    final f = await ctl.previewEffect(fx, _v);
                    if (f != null) await _preview.play(f);
                    if (mounted) setState(() => _previewing = false);
                  },
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _broken == true || (fx.kind == FxKind.sidechain && _control == null)
              ? null
              : () {
                  _preview.stop();
                  Navigator.pop(context);
                  ctl.applyEffect(fx, _v, controlTrack: _control, useNoiseProfile: _useProfile);
                },
          child: Text(l.apply),
        ),
      ],
    );
  }
}

Widget _warn(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Card.filled(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(padding: const EdgeInsets.all(10), child: Text(text)),
  ),
);

Widget _info(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Card.filled(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Padding(padding: const EdgeInsets.all(10), child: Text(text)),
  ),
);

// ---------------------------------------------------------------- generators

Future<void> showGeneratorDialog(BuildContext context, WidgetRef ref, String genId) => showDialog<void>(
  context: context,
  builder: (_) => _GeneratorDialog(genId: genId),
);

class _GeneratorDialog extends ConsumerStatefulWidget {
  const _GeneratorDialog({required this.genId});
  final String genId;
  @override
  ConsumerState<_GeneratorDialog> createState() => _GeneratorDialogState();
}

class _GeneratorDialogState extends ConsumerState<_GeneratorDialog> {
  late final GenDef? _g = widget.genId == 'dtmf' ? null : genById(widget.genId);
  late FxValues _v = _g?.defaults() ?? {};
  late double _seconds = ref.read(audioEditorProvider.notifier).generatorSeconds(widget.genId == 'dtmf' ? 2 : 10);
  String _digits = '0123456789';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ctl = ref.read(audioEditorProvider.notifier);
    final hasSel = ref.watch(audioEditorProvider.select((s) => s.selection != null));
    return AlertDialog(
      title: Text(genName(l, widget.genId)),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(hasSel ? l.generateReplaces : l.generateInserts, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (_g != null)
              FxParamEditor(
                fxId: widget.genId,
                params: _g.params,
                values: _v,
                onChanged: (v) => setState(() => _v = v),
              ),
            if (_g == null)
              TextFormField(
                initialValue: _digits,
                decoration: InputDecoration(labelText: l.dtmfDigits),
                onChanged: (v) => _digits = v,
              ),
            Row(
              children: [
                SizedBox(width: 190, child: Text(l.pDuration)),
                SizedBox(
                  width: 140,
                  child: TextFormField(
                    initialValue: _seconds.toStringAsFixed(3),
                    decoration: InputDecoration(isDense: true, suffixText: l.unitSecond),
                    onChanged: (t) => _seconds = double.tryParse(t.replaceAll(',', '.')) ?? _seconds,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            final sr = ref.read(audioEditorProvider).project.sampleRate;
            final s = _seconds.clamp(0.001, 36000).toDouble();
            final src = _g == null ? dtmfSource(_digits, seconds: s, sampleRate: sr) : ctl.generatorSource(_g, _v, s);
            ctl.generate(src, seconds: s, label: widget.genId);
          },
          child: Text(l.generate),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- analysis

Future<void> showStatsDialog(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final ctl = ref.read(audioEditorProvider.notifier);
  final results = await Future.wait([ctl.stats(), ctl.loudness()]);
  if (!context.mounted) return;
  final st = results[0] as List<ChannelStats>?;
  final lu = results[1] as ({double? integrated, double? range, double? truePeak})?;
  String db(double v) => v.isFinite ? '${v.toStringAsFixed(2)} ${l.unitDb}' : '−∞';
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.anStats),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (st != null)
              for (var c = 0; c < st.length; c++) ...[
                Text(l.channelN(c + 1), style: Theme.of(ctx).textTheme.titleSmall),
                InfoRow(l.statPeak, db(st[c].peakDb)),
                InfoRow(l.statRms, db(st[c].rmsDb)),
                InfoRow(l.statDc, '${(st[c].dc * 100).toStringAsFixed(4)} %'),
                InfoRow(l.statClipped, '${st[c].clipped}'),
                const SizedBox(height: 8),
              ],
            if (lu != null) ...[
              Text('EBU R128', style: Theme.of(ctx).textTheme.titleSmall),
              InfoRow(l.statIntegrated, lu.integrated == null ? '—' : '${lu.integrated!.toStringAsFixed(1)} LUFS'),
              InfoRow(l.statLra, lu.range == null ? '—' : '${lu.range!.toStringAsFixed(1)} LU'),
              InfoRow(l.statTruePeak, lu.truePeak == null ? '—' : '${lu.truePeak!.toStringAsFixed(1)} dBTP'),
            ],
          ],
        ),
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l.close))],
    ),
  );
}

Future<void> showSpectrumDialog(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final ctl = ref.read(audioEditorProvider.notifier);
  final sr = ref.read(audioEditorProvider).project.sampleRate;
  final spec = await ctl.spectrum(fftSize: 8192);
  if (!context.mounted || spec == null) return;
  final t = Theme.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.anSpectrum),
      content: SizedBox(
        width: 820,
        height: 420,
        child: CustomPaint(
          painter: SpectrumPainter(
            db: spec,
            sampleRate: sr,
            color: t.colorScheme.primary,
            gridColor: t.colorScheme.outlineVariant,
            textStyle: t.textTheme.labelSmall!,
          ),
        ),
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l.close))],
    ),
  );
}

/// Sound/silence finder parameters → labels.
Future<void> showFinderDialog(BuildContext context, WidgetRef ref, {required String kind}) async {
  final l = context.l10n;
  var threshold = kind == 'beats' ? -30.0 : -40.0;
  var minSec = kind == 'sounds' ? 0.1 : 0.5;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: Text(switch (kind) {
          'sounds' => l.anSounds,
          'silence' => l.anSilence,
          _ => l.anBeats,
        }),
        content: SizedBox(
          width: 520,
          child: FxParamEditor(
            fxId: 'finder',
            params: [
              const FxParam('threshold', -80, 0, -40, unit: FxUnit.db, step: 1),
              if (kind != 'beats') const FxParam('minSilence', 0.01, 10, 0.5, unit: FxUnit.s, step: 0.01),
            ],
            values: {'threshold': threshold, 'minSilence': minSec},
            onChanged: (v) => setS(() {
              threshold = v['threshold']!;
              minSec = v['minSilence'] ?? minSec;
            }),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.findAndLabel)),
        ],
      ),
    ),
  );
  if (ok != true) return;
  final ctl = ref.read(audioEditorProvider.notifier);
  final n = switch (kind) {
    'sounds' => await ctl.labelRegions(sounds: true, thresholdDb: threshold, minSeconds: minSec),
    'silence' => await ctl.labelRegions(sounds: false, thresholdDb: threshold, minSeconds: minSec),
    _ => await ctl.labelBeats(thresholdDb: threshold),
  };
  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.labelsAdded(n))));
}

// ---------------------------------------------------------------- export

class ExportFormat {
  const ExportFormat(this.id, this.ext, this.label, this.codec, {this.bitrates = const [], this.defaultKbps});
  final String id;
  final String ext;
  final String label;
  final List<String> Function(int? kbps) codec;
  final List<int> bitrates;
  final int? defaultKbps;
}

final exportFormats = <ExportFormat>[
  ExportFormat(
    'mp3',
    'mp3',
    'MP3',
    (k) => ['-c:a', 'libmp3lame', '-b:a', '${k ?? 192}k'],
    bitrates: [96, 128, 160, 192, 256, 320],
    defaultKbps: 192,
  ),
  ExportFormat('wav16', 'wav', 'WAV 16 bit', (_) => ['-c:a', 'pcm_s16le']),
  ExportFormat('wav24', 'wav', 'WAV 24 bit', (_) => ['-c:a', 'pcm_s24le']),
  ExportFormat('wav32', 'wav', 'WAV 32 bit float', (_) => ['-c:a', 'pcm_f32le']),
  ExportFormat('flac', 'flac', 'FLAC', (_) => ['-c:a', 'flac', '-compression_level', '8']),
  ExportFormat(
    'ogg',
    'ogg',
    'Ogg Vorbis',
    (k) => ['-c:a', 'libvorbis', '-b:a', '${k ?? 192}k'],
    bitrates: [96, 128, 160, 192, 256, 320],
    defaultKbps: 192,
  ),
  ExportFormat(
    'opus',
    'opus',
    'Opus',
    (k) => ['-c:a', 'libopus', '-b:a', '${k ?? 128}k'],
    bitrates: [48, 64, 96, 128, 160, 192, 256],
    defaultKbps: 128,
  ),
  ExportFormat(
    'm4a',
    'm4a',
    'M4A (AAC)',
    (k) => ['-c:a', 'aac', '-b:a', '${k ?? 192}k'],
    bitrates: [96, 128, 160, 192, 256, 320],
    defaultKbps: 192,
  ),
  ExportFormat('alac', 'm4a', 'M4A (ALAC)', (_) => ['-c:a', 'alac']),
  ExportFormat('aiff', 'aiff', 'AIFF 16 bit', (_) => ['-c:a', 'pcm_s16be']),
];

Future<void> showExportDialog(BuildContext context, WidgetRef ref, {String scope = 'all'}) => showDialog<void>(
  context: context,
  builder: (_) => _ExportDialog(scope: scope),
);

class _ExportDialog extends ConsumerStatefulWidget {
  const _ExportDialog({required this.scope});
  final String scope;
  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  ExportFormat _f = exportFormats.first;
  int? _kbps;
  int? _rate;
  late String _scope = widget.scope;
  final _meta = <String, TextEditingController>{
    for (final k in ['title', 'artist', 'album', 'date', 'genre', 'track', 'comment']) k: TextEditingController(),
  };
  late String _path;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    final dir = s.outputDir ?? AppPaths.defaultOutputDir();
    _path = p.join(dir, '${ref.read(audioEditorProvider).project.tracks.firstOrNull?.name ?? 'audio'}.${_f.ext}');
  }

  @override
  void dispose() {
    for (final c in _meta.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final st = ref.watch(audioEditorProvider);
    final hasLabels = st.project.labels.any((x) => x.end > x.start);
    String metaLabel(String k) => switch (k) {
      'title' => l.metaTitle,
      'artist' => l.metaArtist,
      'album' => l.metaAlbum,
      'date' => l.metaYear,
      'genre' => l.metaGenre,
      'track' => l.metaTrack,
      _ => l.metaComment,
    };
    return AlertDialog(
      title: Text(l.exportAudio),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'all', label: Text(l.exportAll)),
                  ButtonSegment(value: 'selection', label: Text(l.exportSelection), enabled: st.selection != null),
                  ButtonSegment(value: 'labels', label: Text(l.exportByLabels), enabled: hasLabels),
                ],
                selected: {_scope},
                onSelectionChanged: (v) => setState(() => _scope = v.first),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<ExportFormat>(
                      isExpanded: true,
                      value: _f,
                      onChanged: (f) => setState(() {
                        _f = f!;
                        _kbps = null;
                        _path = p.setExtension(_path, '.${f.ext}');
                      }),
                      items: [for (final f in exportFormats) DropdownMenuItem(value: f, child: Text(f.label))],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_f.bitrates.isNotEmpty)
                    DropdownButton<int>(
                      value: _kbps ?? _f.defaultKbps,
                      onChanged: (v) => setState(() => _kbps = v),
                      items: [for (final b in _f.bitrates) DropdownMenuItem(value: b, child: Text('$b ${l.unitKbps}'))],
                    ),
                  const SizedBox(width: 12),
                  DropdownButton<int?>(
                    value: _rate,
                    onChanged: (v) => setState(() => _rate = v),
                    items: [
                      DropdownMenuItem(value: null, child: Text('${st.project.sampleRate} ${l.unitHz}')),
                      for (final r in const [44100, 48000, 96000, 22050])
                        DropdownMenuItem(value: r, child: Text('$r ${l.unitHz}')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(_path, maxLines: 2, overflow: TextOverflow.ellipsis)),
                  TextButton(
                    onPressed: () async {
                      final loc = await getSaveLocation(
                        initialDirectory: p.dirname(_path),
                        suggestedName: p.basename(_path),
                      );
                      if (loc != null) setState(() => _path = p.setExtension(loc.path, '.${_f.ext}'));
                    },
                    child: Text(l.change),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(l.metadataTitle, style: Theme.of(context).textTheme.titleSmall),
              for (final e in _meta.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: TextField(
                    controller: e.value,
                    decoration: InputDecoration(isDense: true, labelText: metaLabel(e.key)),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () async {
            final meta = {
              for (final e in _meta.entries)
                if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
            };
            final codec = [
              ..._f.codec(_kbps ?? _f.defaultKbps),
              if (_rate != null) ...['-ar', '$_rate'],
            ];
            Navigator.pop(context);
            final n = await ref
                .read(audioEditorProvider.notifier)
                .export(
                  outputPath: _path,
                  codec: codec,
                  metadata: meta,
                  selectionOnly: _scope == 'selection',
                  byLabels: _scope == 'labels',
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.downloadsQueued(n))));
            }
          },
          child: Text(l.export),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- recording

Future<void> showRecordDialog(BuildContext context, WidgetRef ref) =>
    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const _RecordDialog());

class _RecordDialog extends ConsumerStatefulWidget {
  const _RecordDialog();
  @override
  ConsumerState<_RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends ConsumerState<_RecordDialog> {
  List<(String, String, String)>? _devices;
  int _sel = 0;

  @override
  void initState() {
    super.initState();
    ref.read(audioEditorProvider.notifier).recordingDevices().then((d) {
      if (mounted) setState(() => _devices = d);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final st = ref.watch(audioEditorProvider);
    final ctl = ref.read(audioEditorProvider.notifier);
    final level = st.recordLevel;
    final norm = level == null ? 0.0 : ((level + 60) / 60).clamp(0.0, 1.0);
    return AlertDialog(
      title: Text(l.recordTitle),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_devices == null)
              const LinearProgressIndicator()
            else if (_devices!.isEmpty)
              Text(l.noRecordingDevices)
            else
              DropdownButton<int>(
                isExpanded: true,
                value: _sel,
                onChanged: st.recording ? null : (v) => setState(() => _sel = v!),
                items: [
                  for (var i = 0; i < _devices!.length; i++) DropdownMenuItem(value: i, child: Text(_devices![i].$3)),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              formatTimecode(st.recordFrames / st.project.sampleRate, 0.1),
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: norm, minHeight: 10, borderRadius: BorderRadius.circular(5)),
            Text(level == null ? '' : '${level.toStringAsFixed(1)} LUFS (M)', textAlign: TextAlign.end),
            const SizedBox(height: 8),
            Text(l.recordHint, style: Theme.of(context).textTheme.bodySmall),
            if (st.error != null) Text(st.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        if (!st.recording) TextButton(onPressed: () => Navigator.pop(context), child: Text(l.close)),
        if (!st.recording)
          FilledButton.icon(
            icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
            label: Text(l.record),
            onPressed: _devices == null || _devices!.isEmpty
                ? null
                : () => ctl.startRecording(_devices![_sel].$1, _devices![_sel].$2),
          )
        else
          FilledButton.icon(
            icon: const Icon(Icons.stop),
            label: Text(l.stop),
            onPressed: () async {
              await ctl.stopRecording();
              if (context.mounted) Navigator.pop(context);
            },
          ),
      ],
    );
  }
}
