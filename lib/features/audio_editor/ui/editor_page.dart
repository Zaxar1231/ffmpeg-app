import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' show Media, Player;
import 'package:path/path.dart' as p;

import '../../../core/providers.dart';
import '../../../ui/l10n.dart';
import '../../../ui/widgets/common.dart';
import '../../convert/convert_page.dart' show promptText;
import '../../tools/tool_infra.dart';
import '../editor_controller.dart';
import '../engine/effects.dart';
import '../engine/generators.dart';
import '../engine/model.dart';
import 'dialogs.dart';
import 'fx_labels.dart';
import 'painters.dart';

enum EditTool { select, shift, envelope }

/// Audacity-style multitrack audio editor.
class AudioEditorPage extends ConsumerStatefulWidget {
  const AudioEditorPage({super.key, this.path});
  final String? path;

  @override
  ConsumerState<AudioEditorPage> createState() => _AudioEditorPageState();
}

class _AudioEditorPageState extends ConsumerState<AudioEditorPage> {
  static const headerWidth = 230.0;
  static const laneHeight = 150.0;

  double _start = 0;
  double _spp = 512;
  double _laneWidth = 800;
  EditTool _tool = EditTool.select;
  final _focus = FocusNode();

  // Playback
  late final Player _player = Player();
  StreamSubscription<Duration>? _posSub;
  String? _openedFile;
  int? _playhead;
  bool _playing = false;
  bool _loop = false;
  SampleRange? _playRange;

  // Interaction
  int? _anchor;
  String? _shiftTrack;
  int _shiftOrigin = 0;
  double _shiftDx = 0;
  int? _envDrag;

  // Spectrogram view
  final _spectro = <String>{};
  final _spectroImg = <String, ui.Image>{};

  @override
  void initState() {
    super.initState();
    _posSub = _player.stream.position.listen(_onPosition);
    HardwareKeyboard.instance.addHandler(_onKey);
    _player.stream.playing.listen((v) {
      if (mounted) setState(() => _playing = v);
    });
    final path = widget.path;
    if (path != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ctl = ref.read(audioEditorProvider.notifier);
        if (ref.read(audioEditorProvider).project.tracks.isEmpty) {
          await ctl.importFiles([path]);
          _zoomFit();
        }
      });
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _posSub?.cancel();
    _player.dispose();
    _focus.dispose();
    super.dispose();
  }

  EditorState get _st => ref.read(audioEditorProvider);
  AudioEditorController get _ctl => ref.read(audioEditorProvider.notifier);
  int get _sr => _st.project.sampleRate;
  TimeView get _view => TimeView(start: _start, spp: _spp, sampleRate: _sr);

  // ---------------------------------------------------------------- view

  void _clampView() {
    final total = math.max(_st.project.length, _sr);
    _spp = _spp.clamp(1, math.max(1, total / 100)).toDouble();
    final visible = _laneWidth * _spp;
    _start = _start.clamp(0, math.max(0, total - visible * 0.5)).toDouble();
  }

  void _zoom(double factor, {double? aroundX}) {
    setState(() {
      final x = aroundX ?? _laneWidth / 2;
      final f = _start + x * _spp;
      _spp = (_spp * factor);
      _start = f - x * _spp;
      _clampView();
    });
  }

  void _zoomFit() => setState(() {
    final total = math.max(_st.project.length, _sr);
    _spp = total / math.max(100, _laneWidth - 20);
    _start = 0;
    _clampView();
  });

  void _zoomSelection() {
    final s = _st.selection;
    if (s == null) return;
    setState(() {
      _spp = s.length / math.max(100, _laneWidth - 40);
      _start = s.start - 20 * _spp;
      _clampView();
    });
  }

  // ---------------------------------------------------------------- playback

  void _onPosition(Duration d) {
    if (!mounted || !_playing) return;
    final frame = d.inMicroseconds * _sr ~/ 1000000;
    final r = _playRange;
    if (r != null && frame >= r.end) {
      if (_loop) {
        _player.seek(Duration(microseconds: r.start * 1000000 ~/ _sr));
      } else {
        _player.pause();
      }
    }
    setState(() => _playhead = frame);
    // Follow the playhead.
    final x = _view.xOf(frame);
    if (x > _laneWidth - 20) setState(() => _start = frame - 20 * _spp);
  }

  Future<void> _play({bool selectionOnly = false}) async {
    if (_playing) {
      await _player.pause();
      return;
    }
    final file = await _ctl.playbackFile();
    if (file == null) return;
    final sel = _st.selection;
    final start = sel?.start ?? _st.cursor;
    _playRange = sel != null && (selectionOnly || _loop) ? sel : null;
    if (_openedFile != file) {
      await _player.open(Media(file), play: false);
      _openedFile = file;
      // Wait until the duration is known so seeking works.
      await _player.stream.duration
          .firstWhere((d) => d > Duration.zero)
          .timeout(const Duration(seconds: 5), onTimeout: () => Duration.zero);
    }
    await _player.seek(Duration(microseconds: start * 1000000 ~/ _sr));
    await _player.play();
  }

  Future<void> _stop() async {
    await _player.pause();
    setState(() => _playhead = null);
  }

  // ---------------------------------------------------------------- spectrogram

  Future<void> _toggleSpectrogram(AudioTrack t) async {
    if (_spectro.remove(t.id)) {
      setState(() {});
      return;
    }
    _spectro.add(t.id);
    await _ensureSpectrogram(t);
  }

  Future<void> _ensureSpectrogram(AudioTrack t) async {
    if (_spectroImg.containsKey(t.file)) return setState(() {});
    final ffmpeg = ref.read(toolchainProvider).ffmpeg.path;
    if (ffmpeg == null) return;
    final png = '${t.file}.spectrum.png';
    final r = await ref.read(processRunnerProvider).capture(ffmpeg, [
      '-hide_banner', '-v', 'error', '-y', '-i', t.file, //
      '-lavfi', 'showspectrumpic=s=2048x256:legend=0:scale=log:fscale=log:color=intensity:mode=combined',
      '-frames:v', '1', png,
    ]);
    if (!r.ok || !mounted) return;
    final img = await decodeImageFromList(await File(png).readAsBytes());
    if (mounted) setState(() => _spectroImg[t.file] = img);
  }

  // ---------------------------------------------------------------- actions

  Future<void> _importDialog() async {
    final files = await openFiles();
    if (files.isEmpty) return;
    final empty = _st.project.tracks.isEmpty;
    await _ctl.importFiles([for (final f in files) f.path]);
    if (empty) _zoomFit();
  }

  Future<void> _addLabel() async {
    final l = context.l10n;
    final text = await promptText(context, title: l.addLabel, label: l.labelText);
    if (text != null) _ctl.addLabel(text);
  }

  Future<void> _saveProject() async {
    final dir = _st.projectPath ?? await getDirectoryPath(confirmButtonText: context.l10n.save);
    if (dir != null) await _ctl.saveProject(dir);
  }

  Future<void> _saveProjectAs() async {
    final dir = await getDirectoryPath(confirmButtonText: context.l10n.save);
    if (dir != null) await _ctl.saveProject(dir);
  }

  Future<void> _openProject() async {
    final dir = await getDirectoryPath();
    if (dir == null) return;
    await _ctl.openProject(dir);
    _zoomFit();
  }

  Future<void> _importLabels() async {
    final f = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Labels', extensions: ['txt']),
      ],
    );
    if (f != null) _ctl.importLabels(await File(f.path).readAsString());
  }

  Future<void> _exportLabels() async {
    final loc = await getSaveLocation(suggestedName: 'labels.txt');
    if (loc != null) await File(loc.path).writeAsString(_ctl.exportLabels());
  }

  // ---------------------------------------------------------------- keys

  /// Editor shortcuts work while the editor is visible, wherever the focus
  /// is, except when typing in a text field or when a dialog/menu is open.
  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return false;
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    final focused = FocusManager.instance.primaryFocus?.context?.widget;
    if (focused is EditableText) return false;
    for (final entry in _shortcuts().entries) {
      if (entry.key.accepts(e, HardwareKeyboard.instance)) {
        entry.value();
        return true;
      }
    }
    return false;
  }

  Map<ShortcutActivator, VoidCallback> _shortcuts() {
    final project = _st.project;
    return {
      const SingleActivator(LogicalKeyboardKey.space): () => _play(),
      const SingleActivator(LogicalKeyboardKey.space, shift: true): () => _play(selectionOnly: true),
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _ctl.undo,
      const SingleActivator(LogicalKeyboardKey.keyY, control: true): _ctl.redo,
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): _ctl.redo,
      const SingleActivator(LogicalKeyboardKey.keyX, control: true): () => _ctl.cutSelection(),
      const SingleActivator(LogicalKeyboardKey.keyC, control: true): () => _ctl.copySelection(),
      const SingleActivator(LogicalKeyboardKey.keyV, control: true): () => _ctl.paste(),
      const SingleActivator(LogicalKeyboardKey.delete): () => _ctl.deleteSelection(),
      const SingleActivator(LogicalKeyboardKey.backspace): () => _ctl.deleteSelection(),
      const SingleActivator(LogicalKeyboardKey.keyL, control: true): () => _ctl.silenceSelection(),
      const SingleActivator(LogicalKeyboardKey.keyT, control: true): () => _ctl.trimToSelection(),
      const SingleActivator(LogicalKeyboardKey.keyD, control: true): () => _ctl.duplicateToNewTrack(),
      const SingleActivator(LogicalKeyboardKey.keyB, control: true): _addLabel,
      const SingleActivator(LogicalKeyboardKey.keyA, control: true): _ctl.selectAll,
      const SingleActivator(LogicalKeyboardKey.equal, control: true): () => _zoom(0.5),
      const SingleActivator(LogicalKeyboardKey.minus, control: true): () => _zoom(2),
      const SingleActivator(LogicalKeyboardKey.keyF, control: true): _zoomFit,
      const SingleActivator(LogicalKeyboardKey.keyE, control: true): _zoomSelection,
      const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveProject,
      const SingleActivator(LogicalKeyboardKey.keyI, control: true): _importDialog,
      const SingleActivator(LogicalKeyboardKey.keyR, shift: true): () => showRecordDialog(context, ref),
      const SingleActivator(LogicalKeyboardKey.escape): () => _ctl.setSelection(null),
      const SingleActivator(LogicalKeyboardKey.home): () => _ctl.setCursor(0),
      const SingleActivator(LogicalKeyboardKey.end): () => _ctl.setCursor(project.length),
    };
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final st = ref.watch(audioEditorProvider);
    final t = Theme.of(context);
    final project = st.project;

    return CallbackShortcuts(
      bindings: const {},
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        child: DropTarget(
          onDragDone: (d) async {
            final empty = _st.project.tracks.isEmpty;
            await _ctl.importFiles([for (final f in d.files) f.path]);
            if (empty) _zoomFit();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _menuBar(context, st),
              _toolbar(context, st),
              const Divider(height: 1),
              Expanded(
                child: project.tracks.isEmpty
                    ? EmptyState(
                        icon: Icons.graphic_eq,
                        title: l.aeEmptyTitle,
                        message: l.aeEmptyBody,
                        action: Wrap(
                          spacing: 8,
                          children: [
                            FilledButton.icon(
                              onPressed: _importDialog,
                              icon: const Icon(Icons.audio_file),
                              label: Text(l.aeImport),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => showRecordDialog(context, ref),
                              icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
                              label: Text(l.record),
                            ),
                            OutlinedButton.icon(
                              onPressed: _openProject,
                              icon: const Icon(Icons.folder_open),
                              label: Text(l.aeOpenProject),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, c) {
                          final w = c.maxWidth - headerWidth;
                          if ((w - _laneWidth).abs() > 1) {
                            _laneWidth = w;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(_clampView);
                            });
                          }
                          return Column(
                            children: [
                              _ruler(context, st),
                              Expanded(
                                child: ListView(
                                  children: [
                                    for (final tr in project.tracks) _trackLane(context, st, tr),
                                    if (project.labels.isNotEmpty) _labelLane(context, st),
                                  ],
                                ),
                              ),
                              _hScroll(context, st),
                            ],
                          );
                        },
                      ),
              ),
              _statusBar(context, st, t),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- menus

  Widget _menuBar(BuildContext context, EditorState st) {
    final l = context.l10n;
    final caps = ref.watch(capabilitiesProvider).value;
    final hasTracks = st.project.tracks.isNotEmpty;
    final hasSel = st.selection != null;
    MenuItemButton item(String label, VoidCallback? onPressed, {IconData? icon, SingleActivator? shortcut}) =>
        MenuItemButton(
          onPressed: onPressed,
          leadingIcon: icon == null ? null : Icon(icon, size: 18),
          shortcut: shortcut,
          child: Text(label),
        );
    return MenuBar(
      style: const MenuStyle(elevation: WidgetStatePropertyAll(0)),
      children: [
        SubmenuButton(
          menuChildren: [
            item(l.aeNew, _ctl.newProject, icon: Icons.note_add_outlined),
            item(l.aeOpenProject, _openProject, icon: Icons.folder_open),
            item(
              l.aeSaveProject,
              hasTracks ? _saveProject : null,
              icon: Icons.save_outlined,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
            ),
            item(l.aeSaveProjectAs, hasTracks ? _saveProjectAs : null),
            const Divider(),
            item(
              l.aeImport,
              _importDialog,
              icon: Icons.audio_file_outlined,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyI, control: true),
            ),
            item(l.aeImportLabels, _importLabels),
            const Divider(),
            item(l.exportAudio, hasTracks ? () => showExportDialog(context, ref) : null, icon: Icons.ios_share),
            item(l.aeExportSelection, hasSel ? () => showExportDialog(context, ref, scope: 'selection') : null),
            item(
              l.exportByLabels,
              st.project.labels.isNotEmpty ? () => showExportDialog(context, ref, scope: 'labels') : null,
            ),
            item(l.aeExportLabels, st.project.labels.isNotEmpty ? _exportLabels : null),
          ],
          child: Text(l.menuFile),
        ),
        SubmenuButton(
          menuChildren: [
            item(
              st.undoLabel == null ? l.undo : l.undoX(historyLabel(l, st.undoLabel!)),
              st.canUndo ? _ctl.undo : null,
              icon: Icons.undo,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
            ),
            item(
              st.redoLabel == null ? l.redo : l.redoX(historyLabel(l, st.redoLabel!)),
              st.canRedo ? _ctl.redo : null,
              icon: Icons.redo,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyY, control: true),
            ),
            const Divider(),
            item(
              l.cut,
              hasSel ? () => _ctl.cutSelection() : null,
              icon: Icons.content_cut,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyX, control: true),
            ),
            item(
              l.copy,
              hasSel ? () => _ctl.copySelection() : null,
              icon: Icons.copy,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyC, control: true),
            ),
            item(
              l.paste,
              st.clipboard != null ? () => _ctl.paste() : null,
              icon: Icons.paste,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyV, control: true),
            ),
            item(
              l.aeDelete,
              hasSel ? () => _ctl.deleteSelection() : null,
              icon: Icons.backspace_outlined,
              shortcut: const SingleActivator(LogicalKeyboardKey.delete),
            ),
            item(
              l.aeSilence,
              hasSel ? () => _ctl.silenceSelection() : null,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyL, control: true),
            ),
            item(
              l.aeTrim,
              hasSel ? () => _ctl.trimToSelection() : null,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyT, control: true),
            ),
            item(
              l.aeDuplicate,
              hasTracks ? () => _ctl.duplicateToNewTrack() : null,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyD, control: true),
            ),
            item(l.aeSplitNew, hasSel ? () => _ctl.duplicateToNewTrack(removeFromSource: true) : null),
            item(l.aeCrossfade, hasTracks ? () => _ctl.crossfadeAtCursor(const Duration(milliseconds: 500)) : null),
            const Divider(),
            item(
              l.aeSelectAll,
              hasTracks ? _ctl.selectAll : null,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyA, control: true),
            ),
            item(
              l.addLabel,
              hasTracks ? _addLabel : null,
              icon: Icons.label_outline,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyB, control: true),
            ),
            item(l.aeNoiseProfile, hasSel ? () => _ctl.captureNoiseProfile() : null, icon: Icons.noise_aware),
          ],
          child: Text(l.menuEdit),
        ),
        SubmenuButton(
          menuChildren: [
            for (final g in [...genCatalog.map((g) => g.id), 'dtmf'])
              item(genName(l, g), () => showGeneratorDialog(context, ref, g)),
          ],
          child: Text(l.menuGenerate),
        ),
        SubmenuButton(
          menuChildren: [
            for (final cat in FxCategory.values)
              SubmenuButton(
                menuChildren: [
                  for (final fx in fxCatalog.where((f) => f.category == cat))
                    item(
                      fxName(l, fx.id) +
                          (caps != null && !_ctl.effectAvailable(fx, caps) ? ' (${l.needsOtherBuild})' : ''),
                      hasTracks && (caps == null || _ctl.effectAvailable(fx, caps))
                          ? () => showEffectDialog(context, ref, fx)
                          : null,
                    ),
                ],
                child: Text(fxCategoryName(l, cat)),
              ),
          ],
          child: Text(l.menuEffects),
        ),
        SubmenuButton(
          menuChildren: [
            item(l.anStats, hasTracks ? () => showStatsDialog(context, ref) : null, icon: Icons.analytics_outlined),
            item(l.anSpectrum, hasTracks ? () => showSpectrumDialog(context, ref) : null, icon: Icons.bar_chart),
            const Divider(),
            item(l.anSounds, hasTracks ? () => showFinderDialog(context, ref, kind: 'sounds') : null),
            item(l.anSilence, hasTracks ? () => showFinderDialog(context, ref, kind: 'silence') : null),
            item(l.anBeats, hasTracks ? () => showFinderDialog(context, ref, kind: 'beats') : null),
            item(
              l.anClipping,
              hasTracks
                  ? () async {
                      final n = await _ctl.labelClipping();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.labelsAdded(n))));
                      }
                    }
                  : null,
            ),
          ],
          child: Text(l.menuAnalyze),
        ),
        SubmenuButton(
          menuChildren: [
            item(l.aeAddTrack, _importDialog, icon: Icons.add),
            item(l.record, () => showRecordDialog(context, ref), icon: Icons.fiber_manual_record),
            item(l.aeMixRender, st.project.tracks.length > 1 ? () => _ctl.mixToNewTrack() : null),
          ],
          child: Text(l.menuTracks),
        ),
      ],
    );
  }

  Widget _toolbar(BuildContext context, EditorState st) {
    final l = context.l10n;
    final busy = st.busy != null;
    final sel = st.selection;
    String secs(int f) => formatTimecode(f / _sr, 0.001);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          IconButton.filled(
            tooltip: l.aePlayHint,
            onPressed: st.project.tracks.isEmpty || busy ? null : () => _play(),
            icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(tooltip: l.stop, onPressed: _playing ? _stop : null, icon: const Icon(Icons.stop)),
          IconButton(
            tooltip: l.aePlaySelection,
            onPressed: sel == null || busy ? null : () => _play(selectionOnly: true),
            icon: const Icon(Icons.play_circle_outline),
          ),
          IconButton(
            tooltip: l.aeLoop,
            isSelected: _loop,
            onPressed: () => setState(() => _loop = !_loop),
            icon: const Icon(Icons.repeat),
            selectedIcon: const Icon(Icons.repeat_on),
          ),
          IconButton(
            tooltip: l.record,
            onPressed: busy ? null : () => showRecordDialog(context, ref),
            icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
          ),
          const SizedBox(width: 12),
          SegmentedButton<EditTool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: EditTool.select, icon: const Icon(Icons.text_fields), tooltip: l.toolSelect),
              ButtonSegment(value: EditTool.shift, icon: const Icon(Icons.swap_horiz), tooltip: l.toolShift),
              ButtonSegment(value: EditTool.envelope, icon: const Icon(Icons.show_chart), tooltip: l.toolEnvelope),
            ],
            selected: {_tool},
            onSelectionChanged: (v) => setState(() => _tool = v.first),
          ),
          const SizedBox(width: 12),
          IconButton(tooltip: l.undo, onPressed: st.canUndo && !busy ? _ctl.undo : null, icon: const Icon(Icons.undo)),
          IconButton(tooltip: l.redo, onPressed: st.canRedo && !busy ? _ctl.redo : null, icon: const Icon(Icons.redo)),
          IconButton(
            tooltip: l.cut,
            onPressed: sel != null && !busy ? () => _ctl.cutSelection() : null,
            icon: const Icon(Icons.content_cut),
          ),
          IconButton(
            tooltip: l.copy,
            onPressed: sel != null && !busy ? () => _ctl.copySelection() : null,
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            tooltip: l.paste,
            onPressed: st.clipboard != null && !busy ? () => _ctl.paste() : null,
            icon: const Icon(Icons.paste),
          ),
          IconButton(
            tooltip: l.aeTrim,
            onPressed: sel != null && !busy ? () => _ctl.trimToSelection() : null,
            icon: const Icon(Icons.crop),
          ),
          IconButton(
            tooltip: l.aeSilence,
            onPressed: sel != null && !busy ? () => _ctl.silenceSelection() : null,
            icon: const Icon(Icons.volume_off_outlined),
          ),
          const SizedBox(width: 12),
          IconButton(tooltip: l.zoomIn, onPressed: () => _zoom(0.5), icon: const Icon(Icons.zoom_in)),
          IconButton(tooltip: l.zoomOut, onPressed: () => _zoom(2), icon: const Icon(Icons.zoom_out)),
          IconButton(
            tooltip: l.zoomSelection,
            onPressed: sel == null ? null : _zoomSelection,
            icon: const Icon(Icons.fit_screen_outlined),
          ),
          IconButton(tooltip: l.zoomFit, onPressed: _zoomFit, icon: const Icon(Icons.fit_screen)),
          const SizedBox(width: 12),
          Text(
            sel == null
                ? l.aeCursorAt(secs(st.cursor))
                : l.aeSelectionInfo(secs(sel.start), secs(sel.end), secs(sel.length)),
            style: const TextStyle(fontFeatures: [ui.FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }

  Widget _ruler(BuildContext context, EditorState st) {
    final t = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: headerWidth,
          height: 26,
          child: Center(child: Text('${st.project.sampleRate} Hz', style: t.textTheme.labelSmall)),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _ctl.setCursor(_view.frameAt(d.localPosition.dx)),
            child: SizedBox(
              height: 26,
              child: CustomPaint(
                painter: RulerPainter(
                  view: _view,
                  color: t.colorScheme.onSurfaceVariant,
                  textStyle: t.textTheme.labelSmall!,
                  selection: st.selection,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hScroll(BuildContext context, EditorState st) {
    final total = math.max(st.project.length, _sr).toDouble();
    final visible = _laneWidth * _spp;
    final maxStart = math.max(0.0, total - visible * 0.5);
    return Row(
      children: [
        const SizedBox(width: headerWidth),
        Expanded(
          child: Slider(
            value: _start.clamp(0, maxStart),
            min: 0,
            max: maxStart <= 0 ? 1 : maxStart,
            onChanged: maxStart <= 0 ? null : (v) => setState(() => _start = v),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- tracks

  Widget _trackLane(BuildContext context, EditorState st, AudioTrack tr) {
    final t = Theme.of(context);
    final selected = st.selectedTracks.contains(tr.id);
    final shifting = _shiftTrack == tr.id;
    final shown = shifting ? tr.copyWith(offset: math.max(0, _shiftOrigin + (_shiftDx * _spp).round())) : tr;
    final color = tr.mute ? t.colorScheme.outline : t.colorScheme.primary;
    return SizedBox(
      height: laneHeight,
      child: Row(
        children: [
          _TrackHeader(
            track: tr,
            selected: selected,
            spectrogram: _spectro.contains(tr.id),
            onToggleSpectrogram: () => _toggleSpectrogram(tr),
          ),
          Expanded(
            child: Listener(
              onPointerSignal: (e) {
                if (e is! PointerScrollEvent) return;
                final keys = HardwareKeyboard.instance;
                if (keys.isControlPressed) {
                  _zoom(e.scrollDelta.dy > 0 ? 1.25 : 0.8, aroundX: e.localPosition.dx);
                } else if (keys.isShiftPressed || e.scrollDelta.dx != 0) {
                  final d = e.scrollDelta.dx != 0 ? e.scrollDelta.dx : e.scrollDelta.dy;
                  setState(() {
                    _start += d * _spp;
                    _clampView();
                  });
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _onTapDown(tr, d.localPosition),
                onDoubleTapDown: (d) => _onDoubleTap(tr, d.localPosition),
                onDoubleTap: () {},
                dragStartBehavior: DragStartBehavior.down,
                onPanStart: (d) => _onPanStart(tr, d.localPosition),
                onPanUpdate: (d) => _onPanUpdate(tr, d.localPosition, d.delta),
                onPanEnd: (_) => _onPanEnd(tr),
                child: ClipRect(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: WaveformPainter(
                      view: _view,
                      track: shown,
                      peaks: st.peaks[tr.file],
                      color: color,
                      selectionColor: t.colorScheme.primary.withValues(alpha: 0.18),
                      lineColor: t.colorScheme.onSurface,
                      selection: st.selection,
                      cursor: st.cursor,
                      playhead: _playhead,
                      showEnvelope: _tool == EditTool.envelope,
                      spectrogram: _spectro.contains(tr.id) ? _spectroImg[tr.file] : null,
                      selected: selected,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapDown(AudioTrack tr, Offset pos) {
    _focus.requestFocus();
    final frame = math.max(0, _view.frameAt(pos.dx));
    switch (_tool) {
      case EditTool.select:
        final keys = HardwareKeyboard.instance;
        final sel = _st.selection;
        if (keys.isShiftPressed) {
          final a = sel?.start ?? _st.cursor;
          final b = sel?.end ?? _st.cursor;
          _ctl.setSelection(SampleRange(math.min(a, frame), math.max(b, frame)));
        } else {
          _ctl.setCursor(frame);
        }
        _ctl.toggleTrackSelected(tr.id, exclusive: !keys.isControlPressed);
      case EditTool.envelope:
        final hit = _envelopeHit(tr, pos);
        if (hit == null) {
          final time = (frame - tr.offset) / _sr;
          if (time < 0 || time > tr.frames / _sr) return;
          final env = [...tr.envelope, EnvelopePoint(time, _gainAt(pos.dy))]..sort((a, b) => a.time.compareTo(b.time));
          _ctl.updateTrack(tr.copyWith(envelope: env), 'track');
        }
      case EditTool.shift:
        break;
    }
  }

  void _onDoubleTap(AudioTrack tr, Offset pos) {
    if (_tool == EditTool.envelope) {
      final hit = _envelopeHit(tr, pos);
      if (hit != null) {
        final env = [...tr.envelope]..removeAt(hit);
        _ctl.updateTrack(tr.copyWith(envelope: env), 'track');
      }
    } else if (_tool == EditTool.select) {
      // Double click selects the whole clip, like Audacity.
      _ctl.setSelection(SampleRange(tr.offset, tr.end));
    }
  }

  double _gainAt(double y) => (2 * (1 - y / laneHeight)).clamp(0.0, 2.0);

  int? _envelopeHit(AudioTrack tr, Offset pos) {
    final pts = tr.envelope;
    for (var i = 0; i < pts.length; i++) {
      final x = _view.xOf(tr.offset + pts[i].time * _sr);
      final y = laneHeight * (1 - (pts[i].gain / 2).clamp(0.0, 1.0));
      if ((Offset(x, y) - pos).distance < 9) return i;
    }
    return null;
  }

  void _onPanStart(AudioTrack tr, Offset pos) {
    switch (_tool) {
      case EditTool.select:
        _anchor = math.max(0, _view.frameAt(pos.dx));
        if (!_st.selectedTracks.contains(tr.id) && !HardwareKeyboard.instance.isControlPressed) {
          _ctl.toggleTrackSelected(tr.id);
        }
      case EditTool.shift:
        setState(() {
          _shiftTrack = tr.id;
          _shiftOrigin = tr.offset;
          _shiftDx = 0;
        });
      case EditTool.envelope:
        _envDrag = _envelopeHit(tr, pos);
    }
  }

  void _onPanUpdate(AudioTrack tr, Offset pos, Offset delta) {
    switch (_tool) {
      case EditTool.select:
        final a = _anchor;
        if (a == null) return;
        final b = math.max(0, _view.frameAt(pos.dx));
        _ctl.setSelection(SampleRange(math.min(a, b), math.max(a, b)));
      case EditTool.shift:
        setState(() => _shiftDx += delta.dx);
      case EditTool.envelope:
        final i = _envDrag;
        if (i == null) return;
        final env = [...tr.envelope];
        final time = ((_view.frameAt(pos.dx) - tr.offset) / _sr).clamp(0.0, tr.frames / _sr);
        env[i] = EnvelopePoint(time, _gainAt(pos.dy));
        // Live update without a history step; committed on pan end.
        _ctl.previewTrack(tr.copyWith(envelope: env));
    }
  }

  void _onPanEnd(AudioTrack tr) {
    switch (_tool) {
      case EditTool.select:
        _anchor = null;
      case EditTool.shift:
        final off = math.max(0, _shiftOrigin + (_shiftDx * _spp).round());
        setState(() => _shiftTrack = null);
        if (off != tr.offset) _ctl.updateTrack(tr.copyWith(offset: off), 'track');
      case EditTool.envelope:
        if (_envDrag != null) {
          final cur = _st.project.track(tr.id);
          if (cur != null) _ctl.updateTrack(cur, 'track');
        }
        _envDrag = null;
    }
  }

  // ---------------------------------------------------------------- labels

  Widget _labelLane(BuildContext context, EditorState st) {
    final l = context.l10n;
    final t = Theme.of(context);
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: headerWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(l.labelsTrack, style: t.textTheme.labelLarge),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: Stack(
                children: [
                  for (final lb in st.project.labels)
                    if (_view.xOf(lb.end) >= 0 && _view.xOf(lb.start) <= _laneWidth)
                      Positioned(
                        left: _view.xOf(lb.start),
                        top: 6,
                        child: GestureDetector(
                          onTap: () => lb.end > lb.start
                              ? _ctl.setSelection(SampleRange(lb.start, lb.end))
                              : _ctl.setCursor(lb.start),
                          onDoubleTap: () async {
                            final text = await promptText(
                              context,
                              title: l.editLabel,
                              label: l.labelText,
                              initial: lb.text,
                            );
                            if (text != null) _ctl.updateLabel(lb.copyWith(text: text));
                          },
                          onSecondaryTap: () => _ctl.removeLabel(lb.id),
                          child: Tooltip(
                            message: l.labelHint,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: math.max(8, _view.xOf(lb.end) - _view.xOf(lb.start)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: t.colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(6),
                                border: Border(left: BorderSide(color: t.colorScheme.tertiary, width: 2)),
                              ),
                              child: Text(lb.text.isEmpty ? '•' : lb.text, style: t.textTheme.labelSmall),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- status

  Widget _statusBar(BuildContext context, EditorState st, ThemeData t) {
    final l = context.l10n;
    return Material(
      color: t.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            if (st.busy != null) ...[
              SizedBox(width: 160, child: LinearProgressIndicator(value: st.progress)),
              const SizedBox(width: 8),
              Text(historyLabel(l, st.busy!)),
              TextButton(onPressed: _ctl.cancelOperation, child: Text(l.cancel)),
            ] else if (st.error != null) ...[
              Icon(Icons.error_outline, color: t.colorScheme.error, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  st.error == 'noSelection'
                      ? l.aeNeedSelection
                      : (st.error == 'silent'
                            ? l.errLoudnessMeasure
                            : (st.error == 'noAudio' ? l.issueNoAudio : st.error!)),
                  style: TextStyle(color: t.colorScheme.error),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(onPressed: _ctl.clearError, icon: const Icon(Icons.close, size: 16)),
            ] else
              Expanded(
                child: Text(l.aeStatusHint, style: t.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ),
            if (st.busy == null && st.error == null) const SizedBox.shrink() else const Spacer(),
            if (st.noiseProfile != null) TagChip(l.noiseProfileShort, icon: Icons.noise_aware),
            const SizedBox(width: 8),
            Text(
              '${st.project.tracks.length} · ${formatTimecode(st.project.length / st.project.sampleRate, 0.1)}${st.dirty ? ' •' : ''}',
              style: t.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackHeader extends ConsumerWidget {
  const _TrackHeader({
    required this.track,
    required this.selected,
    required this.spectrogram,
    required this.onToggleSpectrogram,
  });
  final AudioTrack track;
  final bool selected;
  final bool spectrogram;
  final VoidCallback onToggleSpectrogram;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final ctl = ref.read(audioEditorProvider.notifier);
    final tr = track;
    return Container(
      width: _AudioEditorPageState.headerWidth,
      decoration: BoxDecoration(
        color: selected ? t.colorScheme.secondaryContainer : t.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: t.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => ctl.toggleTrackSelected(tr.id),
                  child: Text(tr.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.titleSmall),
                ),
              ),
              PopupMenuButton<String>(
                iconSize: 18,
                onSelected: (v) async {
                  switch (v) {
                    case 'rename':
                      final n = await promptText(context, title: l.rename, label: l.trackName, initial: tr.name);
                      if (n != null && n.trim().isNotEmpty) ctl.updateTrack(tr.copyWith(name: n.trim()), 'track');
                    case 'up':
                      ctl.moveTrack(tr.id, -1);
                    case 'down':
                      ctl.moveTrack(tr.id, 1);
                    case 'split':
                      await ctl.splitStereo(tr.id);
                    case 'spectro':
                      onToggleSpectrogram();
                    case 'clearEnv':
                      ctl.updateTrack(tr.copyWith(envelope: const []), 'track');
                    case 'remove':
                      ctl.removeTrack(tr.id);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'rename', child: Text(l.rename)),
                  PopupMenuItem(value: 'up', child: Text(l.moveUp)),
                  PopupMenuItem(value: 'down', child: Text(l.moveDown)),
                  if (tr.channels > 1) PopupMenuItem(value: 'split', child: Text(l.aeSplitStereo)),
                  PopupMenuItem(value: 'spectro', child: Text(spectrogram ? l.aeWaveformView : l.aeSpectrogramView)),
                  if (tr.envelope.isNotEmpty) PopupMenuItem(value: 'clearEnv', child: Text(l.aeClearEnvelope)),
                  PopupMenuItem(value: 'remove', child: Text(l.aeRemoveTrack)),
                ],
              ),
            ],
          ),
          Text(
            '${tr.channels == 1 ? l.mono : l.stereo} · ${formatTimecode(tr.frames / ref.read(audioEditorProvider).project.sampleRate, 0.1)}',
            style: t.textTheme.labelSmall,
          ),
          Row(
            children: [
              _Toggle(
                label: 'M',
                tooltip: l.mute,
                on: tr.mute,
                onTap: () => ctl.updateTrack(tr.copyWith(mute: !tr.mute), 'track'),
              ),
              const SizedBox(width: 4),
              _Toggle(
                label: 'S',
                tooltip: l.solo,
                on: tr.solo,
                onTap: () => ctl.updateTrack(tr.copyWith(solo: !tr.solo), 'track'),
              ),
              const Spacer(),
              Text(
                '${tr.gainDb >= 0 ? '+' : ''}${tr.gainDb.toStringAsFixed(1)} ${l.unitDb}',
                style: t.textTheme.labelSmall,
              ),
            ],
          ),
          _MiniSlider(
            icon: Icons.volume_up,
            value: tr.gainDb,
            min: -36,
            max: 12,
            tooltip: l.trackGain,
            onChangeEnd: (v) => ctl.updateTrack(tr.copyWith(gainDb: (v * 2).round() / 2), 'track'),
          ),
          _MiniSlider(
            icon: Icons.surround_sound_outlined,
            value: tr.pan,
            min: -1,
            max: 1,
            tooltip: l.trackPan,
            onChangeEnd: (v) => ctl.updateTrack(tr.copyWith(pan: (v * 20).round() / 20), 'track'),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, required this.tooltip, required this.on, required this.onTap});
  final String label;
  final String tooltip;
  final bool on;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? cs.primary : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(color: on ? cs.onPrimary : cs.onSurfaceVariant, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// Compact slider that commits on release (one history step per drag).
class _MiniSlider extends StatefulWidget {
  const _MiniSlider({
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChangeEnd,
    required this.tooltip,
  });
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final String tooltip;
  final ValueChanged<double> onChangeEnd;
  @override
  State<_MiniSlider> createState() => _MiniSliderState();
}

class _MiniSliderState extends State<_MiniSlider> {
  double? _drag;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: SizedBox(
      height: 24,
      child: Row(
        children: [
          Icon(widget.icon, size: 14),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: (_drag ?? widget.value).clamp(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                onChanged: (v) => setState(() => _drag = v),
                onChangeEnd: (v) {
                  setState(() => _drag = null);
                  widget.onChangeEnd(v);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Tool host entry: opens the editor (optionally with a file).
class AudioEditorTool extends ConsumerWidget {
  const AudioEditorTool({super.key, this.path});
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: l.back,
                onPressed: () => ref.read(openToolProvider.notifier).close(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 4),
              Icon(Icons.graphic_eq, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(l.toolAudioEditor, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(
                p.basename(ref.watch(audioEditorProvider.select((s) => s.projectPath)) ?? ''),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        Expanded(child: AudioEditorPage(path: path)),
      ],
    );
  }
}
