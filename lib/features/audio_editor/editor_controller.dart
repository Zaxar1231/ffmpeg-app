import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/engine/capabilities.dart';
import '../../core/engine/error_translator.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/engine/process_runner.dart';
import '../../core/platform/host.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';
import 'engine/dsp.dart';
import 'engine/effects.dart';
import 'engine/generators.dart';
import 'engine/model.dart';
import 'engine/peaks.dart';
import 'engine/render.dart';
import 'engine/wav.dart';

/// A piece of audio outside the timeline (clipboard, noise profile).
class AudioClip {
  const AudioClip(this.file, this.frames, this.channels);
  final String file;
  final int frames;
  final int channels;
}

class EditorState {
  const EditorState({
    this.project = const AudioProjectState(sampleRate: 48000),
    this.history = const [],
    this.historyIndex = -1,
    this.selection,
    this.cursor = 0,
    this.selectedTracks = const {},
    this.busy,
    this.progress,
    this.error,
    this.clipboard,
    this.noiseProfile,
    this.peaks = const {},
    this.projectPath,
    this.dirty = false,
    this.recording = false,
    this.recordLevel,
    this.recordFrames = 0,
  });

  final AudioProjectState project;

  /// Undo history; [historyIndex] points at [project].
  final List<(AudioProjectState, String)> history;
  final int historyIndex;

  /// Selection on the project timeline (frames). Null = no selection.
  final SampleRange? selection;
  final int cursor;

  /// Tracks edits apply to. Empty = all tracks.
  final Set<String> selectedTracks;

  /// Name of the running operation (shows a progress bar), null when idle.
  final String? busy;
  final double? progress;
  final String? error;
  final AudioClip? clipboard;
  final AudioClip? noiseProfile;

  /// Waveform overviews by file path.
  final Map<String, Peaks> peaks;
  final String? projectPath;
  final bool dirty;
  final bool recording;

  /// Momentary loudness while recording (LUFS).
  final double? recordLevel;
  final int recordFrames;

  bool get canUndo => historyIndex > 0;
  bool get canRedo => historyIndex < history.length - 1;
  String? get undoLabel => canUndo ? history[historyIndex].$2 : null;
  String? get redoLabel => canRedo ? history[historyIndex + 1].$2 : null;

  List<AudioTrack> get targetTracks =>
      selectedTracks.isEmpty ? project.tracks : project.tracks.where((t) => selectedTracks.contains(t.id)).toList();

  EditorState copyWith({
    AudioProjectState? project,
    List<(AudioProjectState, String)>? history,
    int? historyIndex,
    SampleRange? Function()? selection,
    int? cursor,
    Set<String>? selectedTracks,
    String? Function()? busy,
    double? Function()? progress,
    String? Function()? error,
    AudioClip? Function()? clipboard,
    AudioClip? Function()? noiseProfile,
    Map<String, Peaks>? peaks,
    String? Function()? projectPath,
    bool? dirty,
    bool? recording,
    double? Function()? recordLevel,
    int? recordFrames,
  }) => EditorState(
    project: project ?? this.project,
    history: history ?? this.history,
    historyIndex: historyIndex ?? this.historyIndex,
    selection: selection != null ? selection() : this.selection,
    cursor: cursor ?? this.cursor,
    selectedTracks: selectedTracks ?? this.selectedTracks,
    busy: busy != null ? busy() : this.busy,
    progress: progress != null ? progress() : this.progress,
    error: error != null ? error() : this.error,
    clipboard: clipboard != null ? clipboard() : this.clipboard,
    noiseProfile: noiseProfile != null ? noiseProfile() : this.noiseProfile,
    peaks: peaks ?? this.peaks,
    projectPath: projectPath != null ? projectPath() : this.projectPath,
    dirty: dirty ?? this.dirty,
    recording: recording ?? this.recording,
    recordLevel: recordLevel != null ? recordLevel() : this.recordLevel,
    recordFrames: recordFrames ?? this.recordFrames,
  );
}

class EditorException implements Exception {
  EditorException(this.message, {this.log = const []});
  final String message;
  final List<String> log;
  @override
  String toString() => message;
}

/// Audacity-style editor. Every destructive edit renders new working files;
/// undo/redo switches between immutable project states.
class AudioEditorController extends Notifier<EditorState> {
  late Directory _work;
  var _counter = 0;
  RunHandle? _running;
  RunHandle? _recorder;
  final _brokenFx = <String, bool>{};
  final _uuid = const Uuid();

  @override
  EditorState build() {
    final root = ref.read(appPathsProvider).root;
    _work = Directory(p.join(root, 'tmp', 'audio', _uuid.v4()))..createSync(recursive: true);
    ref.onDispose(() {
      _recorder?.cancel();
      try {
        _work.deleteSync(recursive: true);
      } catch (_) {}
    });
    return const EditorState();
  }

  // ---------------------------------------------------------------- basics

  String _newFile([String ext = 'wav']) => p.join(_work.path, 'a${_counter++}.$ext');

  String get _ffmpeg {
    final f = ref.read(toolchainProvider).ffmpeg.path;
    if (f == null) throw EditorException('ffmpeg');
    return f;
  }

  bool get _hasRubberband => ref.read(capabilitiesProvider).value?.hasFilter('rubberband') ?? true;

  int get sampleRate => state.project.sampleRate;

  Future<RunResult> _run(List<String> args, {int? frames}) async {
    final h = await ref
        .read(processRunnerProvider)
        .start(
          ToolInvocation(
            executable: _ffmpeg,
            args: args,
            totalDuration: frames == null ? null : Duration(microseconds: frames * 1000000 ~/ sampleRate),
          ),
        );
    _running = h;
    final sub = h.progress.listen((pr) {
      if (ref.mounted && pr.fraction != null) state = state.copyWith(progress: () => pr.fraction);
    });
    final r = await h.done;
    await sub.cancel();
    _running = null;
    if (r.canceled) throw EditorException('canceled');
    if (!r.success) {
      final e = translateToolError(r.log, startError: r.startError);
      throw EditorException(e.line ?? e.kind.name, log: r.log);
    }
    return r;
  }

  void cancelOperation() => _running?.cancel();

  static WavInfo wavInfo(String path) {
    final f = File(path).openSync();
    try {
      return readWavInfo(f);
    } finally {
      f.closeSync();
    }
  }

  Future<void> _ensurePeaks(Iterable<String> files) async {
    final missing = files.where((f) => !state.peaks.containsKey(f)).toSet();
    if (missing.isEmpty) return;
    final computed = await Future.wait(missing.map((f) => Isolate.run(() => computePeaks(f))));
    if (!ref.mounted) return;
    final peaks = Map.of(state.peaks);
    var i = 0;
    for (final f in missing) {
      peaks[f] = computed[i++];
    }
    // Drop peaks of files no longer referenced by any reachable state.
    final live = {
      for (final h in state.history)
        for (final t in h.$1.tracks) t.file,
    };
    peaks.removeWhere((k, _) => !live.contains(k) && !missing.contains(k));
    state = state.copyWith(peaks: peaks);
  }

  /// Wraps an operation: busy indicator, error capture, history commit.
  Future<bool> _op(String label, Future<AudioProjectState?> Function() body, {bool commit = true}) async {
    if (state.busy != null) return false;
    state = state.copyWith(busy: () => label, progress: () => null, error: () => null);
    try {
      final next = await body();
      if (!ref.mounted) return false;
      if (next != null && commit) _commit(next, label);
      await _ensurePeaks(state.project.tracks.map((t) => t.file));
      return true;
    } on EditorException catch (e) {
      if (ref.mounted && e.message != 'canceled') state = state.copyWith(error: () => e.message);
      return false;
    } catch (e) {
      if (ref.mounted) state = state.copyWith(error: () => e.toString());
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: () => null, progress: () => null);
    }
  }

  void _commit(AudioProjectState next, String label) {
    final hist = [...state.history.take(state.historyIndex + 1), (next, label)];
    // Keep the history bounded (each step may hold large files).
    const maxSteps = 100;
    final trimmed = hist.length > maxSteps ? hist.sublist(hist.length - maxSteps) : hist;
    state = state.copyWith(
      project: next,
      history: trimmed,
      historyIndex: trimmed.length - 1,
      dirty: true,
      selectedTracks: state.selectedTracks.where((id) => next.track(id) != null).toSet(),
    );
  }

  void undo() {
    if (!state.canUndo || state.busy != null) return;
    final i = state.historyIndex - 1;
    state = state.copyWith(project: state.history[i].$1, historyIndex: i, dirty: true);
  }

  void redo() {
    if (!state.canRedo || state.busy != null) return;
    final i = state.historyIndex + 1;
    state = state.copyWith(project: state.history[i].$1, historyIndex: i, dirty: true);
    unawaited(_ensurePeaks(state.project.tracks.map((t) => t.file)));
  }

  void clearError() => state = state.copyWith(error: () => null);

  // ---------------------------------------------------------------- selection

  void setSelection(SampleRange? r) {
    if (r != null && r.isEmpty) {
      state = state.copyWith(selection: () => null, cursor: r.start);
    } else {
      state = state.copyWith(selection: () => r, cursor: r?.start ?? state.cursor);
    }
  }

  void setCursor(int frame) => state = state.copyWith(cursor: math.max(0, frame), selection: () => null);

  void selectAll() {
    state = state.copyWith(selection: () => SampleRange(0, state.project.length), selectedTracks: {});
  }

  void toggleTrackSelected(String id, {bool exclusive = true}) {
    final s = exclusive ? <String>{} : {...state.selectedTracks};
    if (state.selectedTracks.contains(id) && state.selectedTracks.length == 1 && exclusive) {
      state = state.copyWith(selectedTracks: {});
      return;
    }
    s.contains(id) ? s.remove(id) : s.add(id);
    state = state.copyWith(selectedTracks: s);
  }

  /// Selection mapped onto a track's own timeline, clamped to its length.
  SampleRange? localRange(AudioTrack t, [SampleRange? r]) {
    final sel = r ?? state.selection;
    if (sel == null) return null;
    final lr = SampleRange(sel.start - t.offset, sel.end - t.offset).clamp(t.frames);
    return lr.isEmpty ? null : lr;
  }

  // ---------------------------------------------------------------- project

  /// Imports media files as new tracks (first file sets the project rate).
  Future<bool> importFiles(List<String> paths, {String label = 'import', int? atFrame}) => _op(label, () async {
    var project = state.project;
    final probe = ref.read(probeServiceProvider);
    for (final path in paths) {
      final info = await probe?.probe(path);
      final a = info?.audioStreams.firstOrNull;
      if (a == null) throw EditorException('noAudio');
      if (project.tracks.isEmpty) {
        final rate = (a.sampleRate ?? 48000).clamp(8000, 192000);
        project = project.copyWith(sampleRate: rate);
      }
      final ch = (a.channels ?? 2).clamp(1, 2);
      final out = _newFile();
      await _run(importArgs(path, out, sampleRate: project.sampleRate, channels: ch), frames: null);
      final wi = wavInfo(out);
      project = project.copyWith(
        tracks: [
          ...project.tracks,
          AudioTrack(
            id: _uuid.v4(),
            name: p.basenameWithoutExtension(path),
            file: out,
            frames: wi.frames,
            channels: wi.channels,
            offset: atFrame ?? 0,
          ),
        ],
      );
    }
    return project;
  });

  void newProject() {
    state = EditorState(peaks: state.peaks);
  }

  /// Saves the project as a folder: project.json + data/*.wav.
  Future<bool> saveProject(String dir) => _op('save', () async {
    final data = Directory(p.join(dir, 'data'))..createSync(recursive: true);
    final tracks = <AudioTrack>[];
    for (final t in state.project.tracks) {
      final name = '${t.id}.wav';
      final dest = p.join(data.path, name);
      if (!p.equals(t.file, dest)) await File(t.file).copy(dest);
      tracks.add(t.copyWith(file: p.join('data', name)));
    }
    final json = state.project.copyWith(tracks: tracks).encode();
    await File(p.join(dir, 'project.kadra-audio.json')).writeAsString(json);
    state = state.copyWith(projectPath: () => dir, dirty: false);
    return null;
  }, commit: false);

  Future<bool> openProject(String dir) => _op('open', () async {
    final f = File(p.join(dir, 'project.kadra-audio.json'));
    final loaded = AudioProjectState.fromJson((jsonDecode(await f.readAsString()) as Map).cast<String, dynamic>());
    // Work on copies so the saved project stays untouched until "Save".
    final tracks = <AudioTrack>[];
    for (final t in loaded.tracks) {
      final copy = _newFile();
      await File(p.isAbsolute(t.file) ? t.file : p.join(dir, t.file)).copy(copy);
      tracks.add(t.copyWith(file: copy));
    }
    state = EditorState(projectPath: dir, peaks: state.peaks);
    return loaded.copyWith(tracks: tracks);
  });

  // ---------------------------------------------------------------- per-track edit helper

  /// Runs [edit] on every target track that intersects the selection (or all
  /// targets when [needsSelection] is false) and commits one history step.
  Future<bool> _editTracks(
    String label,
    Future<String?> Function(AudioTrack t, SampleRange? local) edit, {
    bool needsSelection = true,
  }) => _op(label, () async {
    var project = state.project;
    var any = false;
    for (final t in state.targetTracks) {
      final local = localRange(t);
      if (needsSelection && local == null) continue;
      final out = await edit(t, local);
      if (out == null) continue;
      final wi = wavInfo(out);
      project = project.replaceTrack(t.copyWith(file: out, frames: wi.frames, channels: wi.channels));
      any = true;
    }
    return any ? project : null;
  });

  // ---------------------------------------------------------------- editing

  Future<bool> deleteSelection() => _editTracks('delete', (t, r) async {
    final out = _newFile();
    await _run(deleteArgs(t.file, out, total: t.frames, r: r!));
    return out;
  });

  Future<bool> silenceSelection() => _editTracks('silence', (t, r) async {
    final out = _newFile();
    await _run(silenceArgs(t.file, out, total: t.frames, r: r!));
    return out;
  });

  Future<bool> trimToSelection() async {
    final sel = state.selection;
    if (sel == null) return false;
    final ok = await _editTracks('trim', (t, r) async {
      final out = _newFile();
      await _run(trimToArgs(t.file, out, r: r!));
      return out;
    });
    // Trimmed audio starts where the selection started.
    if (ok) {
      final project = state.project.copyWith(
        tracks: [
          for (final t in state.project.tracks)
            state.targetTracks.any((x) => x.id == t.id) ? t.copyWith(offset: math.max(t.offset, sel.start)) : t,
        ],
      );
      state = state.copyWith(project: project);
      final h = [...state.history];
      h[state.historyIndex] = (project, h[state.historyIndex].$2);
      state = state.copyWith(history: h);
    }
    return ok;
  }

  Future<bool> copySelection() => _op('copy', () async {
    final t = state.targetTracks.firstWhere(
      (t) => localRange(t) != null,
      orElse: () => throw EditorException('noSelection'),
    );
    final r = localRange(t)!;
    final out = _newFile();
    await _run(extractArgs(t.file, out, r: r));
    state = state.copyWith(clipboard: () => AudioClip(out, r.length, t.channels));
    return null;
  }, commit: false);

  Future<bool> cutSelection() async => await copySelection() && await deleteSelection();

  /// Paste at the cursor (or over the selection) into target tracks; with no
  /// tracks, the clipboard becomes a new track.
  Future<bool> paste() async {
    final clip = state.clipboard;
    if (clip == null) return false;
    if (state.project.tracks.isEmpty) return _addClipAsTrack(clip, 'paste', state.cursor);
    final sel = state.selection;
    return _editTracks('paste', (t, r) async {
      final pos = (sel?.start ?? state.cursor) - t.offset;
      if (pos < 0 || pos > t.frames) return null;
      final out = _newFile();
      await _run(
        insertArgs(
          t.file,
          out,
          total: t.frames,
          position: pos,
          clip: clip.file,
          sampleRate: sampleRate,
          channels: t.channels,
          replace: r,
        ),
      );
      return out;
    }, needsSelection: false);
  }

  /// Duplicate: the selection is copied to a new track at the same time.
  Future<bool> duplicateToNewTrack({bool removeFromSource = false}) =>
      _op(removeFromSource ? 'splitNew' : 'duplicate', () async {
        var project = state.project;
        for (final t in state.targetTracks) {
          final r = localRange(t) ?? SampleRange(0, t.frames);
          final clip = _newFile();
          await _run(extractArgs(t.file, clip, r: r));
          final wi = wavInfo(clip);
          project = project.copyWith(
            tracks: [
              ...project.tracks,
              AudioTrack(
                id: _uuid.v4(),
                name: t.name,
                file: clip,
                frames: wi.frames,
                channels: wi.channels,
                offset: t.offset + r.start,
              ),
            ],
          );
          if (removeFromSource) {
            final out = _newFile();
            await _run(silenceArgs(t.file, out, total: t.frames, r: r));
            project = project.replaceTrack(t.copyWith(file: out));
          }
        }
        return project;
      });

  Future<bool> _addClipAsTrack(AudioClip clip, String label, int offset, {String? name}) => _op(label, () async {
    final copy = _newFile();
    await File(clip.file).copy(copy);
    return state.project.copyWith(
      tracks: [
        ...state.project.tracks,
        AudioTrack(
          id: _uuid.v4(),
          name: name ?? label,
          file: copy,
          frames: clip.frames,
          channels: clip.channels,
          offset: offset,
        ),
      ],
    );
  });

  Future<bool> crossfadeAtCursor(Duration d) => _editTracks('crossfade', (t, _) async {
    final pos = state.cursor - t.offset;
    final frames = d.inMicroseconds * sampleRate ~/ 1000000;
    if (pos <= frames || pos >= t.frames - frames) return null;
    final out = _newFile();
    await _run(crossfadeArgs(t.file, out, total: t.frames, position: pos, frames: frames, sampleRate: sampleRate));
    return out;
  }, needsSelection: false);

  // ---------------------------------------------------------------- effects

  /// Runs [fx] once on 0.3 s of noise to catch filters broken in this build.
  Future<bool> isEffectBroken(FxDef fx) async {
    final build = fx.build;
    if (build == null || fx.kind != FxKind.filter) return false;
    final key = '${ref.read(toolchainProvider).ffmpeg.path}|${fx.id}';
    final cached = _brokenFx[key];
    if (cached != null) return cached;
    final chain = build(
      fx.defaults(),
      FxContext(sampleRate: 48000, channels: 2, frames: 14400, hasRubberband: _hasRubberband),
    );
    final r = await ref.read(processRunnerProvider).capture(_ffmpeg, smokeTestArgs(chain));
    return _brokenFx[key] = !r.ok;
  }

  Future<Map<String, String>> _measure(FxDef fx, FxValues v, AudioTrack t, SampleRange? r) async {
    switch (fx.measure) {
      case FxMeasure.none:
        return const {};
      case FxMeasure.peakDc:
        final st = await Isolate.run(() => analyzeStats(t.file, start: r?.start ?? 0, end: r?.end));
        return {
          for (var c = 0; c < st.length; c++) ...{
            'peak$c': '${st[c].peak}',
            'dc$c': '${st[c].dc}',
            'min$c': '${st[c].min}',
            'max$c': '${st[c].max}',
          },
        };
      case FxMeasure.loudness:
        final res = await _run(loudnessMeasureArgs(t.file, r: r, lufs: v['lufs']!, tp: v['truePeak']!));
        final m = parseLoudnormJson(res.log);
        if (m == null) throw EditorException('silent');
        return m;
    }
  }

  /// Applies an effect to the selection of the target tracks (whole tracks
  /// without a selection). [controlTrack] is the Auto Duck control signal.
  Future<bool> applyEffect(FxDef fx, FxValues v, {String? controlTrack, bool useNoiseProfile = false, String? label}) =>
      _editTracks(label ?? fx.id, (t, r) async {
        if (fx.stereoOnly && t.channels < 2) return null;
        final out = _newFile();
        final range = r ?? SampleRange(0, t.frames);
        if (fx.kind == FxKind.dsp) {
          await _dsp(fx, v, t, range, out);
          return out;
        }
        final ctx = FxContext(
          sampleRate: sampleRate,
          channels: t.channels,
          frames: range.length,
          measured: await _measure(fx, v, t, r),
          hasRubberband: _hasRubberband,
        );
        final chain = fx.build!(v, ctx);
        final fixed = fx.changesLength ? chain : exactLength(chain, range.length);
        if (fx.id == 'reverb') {
          await _run(
            reverbArgs(t.file, out, total: t.frames, r: r, v: v, sampleRate: sampleRate),
            frames: t.frames,
          );
        } else if (fx.id == 'noiseReduction' && useNoiseProfile && state.noiseProfile != null) {
          final np = state.noiseProfile!;
          await _run(
            noiseProfileArgs(
              t.file,
              out,
              total: t.frames,
              r: r,
              profileWav: np.file,
              profileFrames: np.frames,
              sampleRate: sampleRate,
              afftdn: chain,
            ),
            frames: t.frames,
          );
        } else if (fx.kind == FxKind.sidechain) {
          final ctl = controlTrack == null ? null : state.project.track(controlTrack);
          if (ctl == null || ctl.id == t.id) return null;
          await _run(
            autoDuckArgs(
              t.file,
              out,
              total: t.frames,
              r: r,
              control: ctl.file,
              controlOffset: ctl.offset - t.offset,
              chain: chain,
            ),
            frames: t.frames,
          );
        } else {
          await _run(
            effectArgs(t.file, out, total: t.frames, r: r, chain: fixed),
            frames: t.frames,
          );
        }
        return out;
      }, needsSelection: false);

  /// Dart DSP effects: decode the range, process, write, splice back.
  Future<void> _dsp(FxDef fx, FxValues v, AudioTrack t, SampleRange r, String out) async {
    final processed = _newFile();
    final file = t.file;
    final sr = sampleRate;
    await Isolate.run(() async {
      final f = File(file).openSync();
      final info = readWavInfo(f);
      final pcm = readFrames(f, info, r.start, r.length);
      f.closeSync();
      final List<Float32List> res = switch (fx.id) {
        'paulstretch' => paulstretch(pcm, sr, stretch: v['stretch']!, windowSec: v['window']!),
        'wahwah' => wahwah(
          pcm,
          sr,
          lfoHz: v['freq']!,
          depth: v['depth']! / 100,
          resonance: v['resonance']!,
          offset: v['offset']! / 100,
        ),
        'slidingSpeed' => slidingSpeed(pcm, fromPct: v['from']!, toPct: v['to']!),
        _ => pcm,
      };
      await writeWavFloat(processed, res, sr);
    });
    // Splice the processed audio back in place of the range.
    await _run(
      insertArgs(
        t.file,
        out,
        total: t.frames,
        position: r.start,
        clip: processed,
        sampleRate: sr,
        channels: t.channels,
        replace: r,
      ),
    );
  }

  /// Short preview: renders the first seconds of the selection with the
  /// effect into a temp file and returns it for playback.
  Future<String?> previewEffect(FxDef fx, FxValues v, {Duration length = const Duration(seconds: 6)}) async {
    final t = state.targetTracks.firstOrNull;
    if (t == null || fx.kind == FxKind.sidechain) return null;
    final r = localRange(t) ?? SampleRange(0, t.frames);
    final n = math.min(r.length, length.inMicroseconds * sampleRate ~/ 1000000);
    final part = _newFile();
    await _run(extractArgs(t.file, part, r: SampleRange(r.start, r.start + n)));
    final tmp = AudioTrack(id: 'preview', name: '', file: part, frames: n, channels: t.channels);
    final out = _newFile();
    if (fx.kind == FxKind.dsp) {
      await _dsp(fx, v, tmp, SampleRange(0, n), out);
      return out;
    }
    final ctx = FxContext(
      sampleRate: sampleRate,
      channels: t.channels,
      frames: n,
      measured: await _measure(fx, v, tmp, null),
      hasRubberband: _hasRubberband,
    );
    final chain = fx.build!(v, ctx);
    if (fx.id == 'reverb') {
      await _run(reverbArgs(part, out, total: n, v: v, sampleRate: sampleRate));
    } else {
      await _run(effectArgs(part, out, total: n, chain: chain));
    }
    return out;
  }

  /// Remember the selection of the first target track as the noise profile.
  Future<bool> captureNoiseProfile() => _op('noiseProfile', () async {
    final t = state.targetTracks.firstWhere(
      (t) => localRange(t) != null,
      orElse: () => throw EditorException('noSelection'),
    );
    final r = localRange(t)!;
    final out = _newFile();
    await _run(extractArgs(t.file, out, r: r));
    state = state.copyWith(noiseProfile: () => AudioClip(out, r.length, t.channels));
    return null;
  }, commit: false);

  // ---------------------------------------------------------------- generate

  /// Generates audio: replaces the selection on target tracks, inserts at
  /// the cursor, or creates a new track when there are no tracks.
  Future<bool> generate(String source, {required double seconds, required String label}) async {
    if (state.project.tracks.isEmpty) {
      final out = _newFile();
      final ok = await _op(label, () async {
        await _run(generateArgs(source, out, channels: 2));
        return null;
      }, commit: false);
      if (!ok) return false;
      final wi = wavInfo(out);
      return _addClipAsTrack(AudioClip(out, wi.frames, wi.channels), label, state.cursor);
    }
    final sel = state.selection;
    return _editTracks(label, (t, r) async {
      final clip = _newFile();
      await _run(generateArgs(source, clip, channels: t.channels));
      final pos = (sel?.start ?? state.cursor) - t.offset;
      if (pos < 0 || pos > t.frames) return null;
      final out = _newFile();
      await _run(
        insertArgs(
          t.file,
          out,
          total: t.frames,
          position: pos,
          clip: clip,
          sampleRate: sampleRate,
          channels: t.channels,
          replace: r,
        ),
      );
      return out;
    }, needsSelection: false);
  }

  /// Generator duration: selection length, else [fallback].
  double generatorSeconds(double fallback) {
    final s = state.selection;
    return s == null ? fallback : s.length / sampleRate;
  }

  String generatorSource(GenDef g, FxValues v, double seconds) => g.source(v, sampleRate, seconds);

  // ---------------------------------------------------------------- tracks

  void _setProject(AudioProjectState next, String label) {
    if (state.busy != null) return;
    _commit(next, label);
  }

  /// Live change while dragging (no history step; commit with [updateTrack]).
  void previewTrack(AudioTrack t) => state = state.copyWith(project: state.project.replaceTrack(t));

  void updateTrack(AudioTrack t, String label) => _setProject(state.project.replaceTrack(t), label);

  void removeTrack(String id) => _setProject(
    state.project.copyWith(tracks: state.project.tracks.where((t) => t.id != id).toList()),
    'removeTrack',
  );

  void moveTrack(String id, int delta) {
    final list = [...state.project.tracks];
    final i = list.indexWhere((t) => t.id == id);
    final j = (i + delta).clamp(0, list.length - 1);
    if (i < 0 || i == j) return;
    list.insert(j, list.removeAt(i));
    _setProject(state.project.copyWith(tracks: list), 'moveTrack');
  }

  /// Renders the audible mix (or selection) into a new track.
  Future<bool> mixToNewTrack() => _op('mixRender', () async {
    final out = _newFile();
    final sel = state.selection;
    await _run(mixArgs(state.project, out, range: sel), frames: state.project.length);
    final wi = wavInfo(out);
    return state.project.copyWith(
      tracks: [
        ...state.project.tracks,
        AudioTrack(
          id: _uuid.v4(),
          name: 'Mix',
          file: out,
          frames: wi.frames,
          channels: wi.channels,
          offset: sel?.start ?? 0,
        ),
      ],
    );
  });

  /// Stereo → two mono tracks panned left/right.
  Future<bool> splitStereo(String id) => _op('splitStereo', () async {
    final t = state.project.track(id);
    if (t == null || t.channels < 2) return null;
    final tracks = <AudioTrack>[];
    for (final (ch, pan) in [(0, -1.0), (1, 1.0)]) {
      final out = _newFile();
      await _run(
        FfmpegCommand(
          inputs: [FfmpegInput(t.file)],
          filterComplex: '[0:a]pan=mono|c0=c$ch[out]',
          outputs: [
            FfmpegOutput(out, maps: ['[out]'], options: workCodec),
          ],
        ).toArgs(),
      );
      tracks.add(
        AudioTrack(
          id: _uuid.v4(),
          name: '${t.name} ${ch == 0 ? 'L' : 'R'}',
          file: out,
          frames: t.frames,
          channels: 1,
          offset: t.offset,
          pan: pan,
          gainDb: t.gainDb,
        ),
      );
    }
    final list = [...state.project.tracks];
    final i = list.indexWhere((x) => x.id == id);
    list
      ..removeAt(i)
      ..insertAll(i, tracks);
    return state.project.copyWith(tracks: list);
  });

  // ---------------------------------------------------------------- labels

  void addLabel(String text, {SampleRange? at}) {
    final r = at ?? state.selection ?? SampleRange(state.cursor, state.cursor);
    _setProject(
      state.project.copyWith(
        labels: [...state.project.labels, AudioLabel(_uuid.v4(), r.start, r.end, text)]
          ..sort((a, b) => a.start.compareTo(b.start)),
      ),
      'addLabel',
    );
  }

  void addLabels(List<SampleRange> ranges, String prefix) {
    var i = 1;
    _setProject(
      state.project.copyWith(
        labels: [
          ...state.project.labels,
          for (final r in ranges) AudioLabel(_uuid.v4(), r.start, r.end, '$prefix ${i++}'),
        ]..sort((a, b) => a.start.compareTo(b.start)),
      ),
      'addLabels',
    );
  }

  void updateLabel(AudioLabel l) => _setProject(
    state.project.copyWith(labels: [for (final x in state.project.labels) x.id == l.id ? l : x]),
    'editLabel',
  );

  void removeLabel(String id) => _setProject(
    state.project.copyWith(labels: state.project.labels.where((l) => l.id != id).toList()),
    'removeLabel',
  );

  void importLabels(String text) => _setProject(
    state.project.copyWith(
      labels: [...state.project.labels, ...importLabelsText(text, sampleRate, newId: _uuid.v4)]
        ..sort((a, b) => a.start.compareTo(b.start)),
    ),
    'importLabels',
  );

  String exportLabels() => exportLabelsText(state.project.labels, sampleRate);

  // ---------------------------------------------------------------- analysis

  AudioTrack? get _analysisTrack =>
      state.targetTracks.where((t) => localRange(t) != null).firstOrNull ?? state.targetTracks.firstOrNull;

  Future<List<ChannelStats>?> stats() async {
    final t = _analysisTrack;
    if (t == null) return null;
    final r = localRange(t);
    return Isolate.run(() => analyzeStats(t.file, start: r?.start ?? 0, end: r?.end));
  }

  Future<Float64List?> spectrum({int fftSize = 4096}) async {
    final t = _analysisTrack;
    if (t == null) return null;
    final r = localRange(t);
    return Isolate.run(() => averageSpectrum(t.file, start: r?.start ?? 0, end: r?.end, fftSize: fftSize));
  }

  Future<({double? integrated, double? range, double? truePeak})?> loudness() async {
    final t = _analysisTrack;
    if (t == null) return null;
    final res = await ref.read(processRunnerProvider).capture(_ffmpeg, ebur128Args(t.file, r: localRange(t)));
    return parseEbur128Summary(res.stderr);
  }

  /// Finder results become labels (like Audacity's analyzers).
  Future<int> labelRegions({required bool sounds, required double thresholdDb, required double minSeconds}) async {
    final t = _analysisTrack;
    if (t == null) return 0;
    final file = t.file;
    final win = sampleRate ~/ 100;
    final regions = await Isolate.run(() {
      final env = rmsEnvelope(file);
      return findRegions(env, win, thresholdDb: thresholdDb, minWindows: (minSeconds * 100).ceil(), sounds: sounds);
    });
    addLabels([for (final (s, e) in regions) SampleRange(s + t.offset, e + t.offset)], sounds ? 'Sound' : 'Silence');
    return regions.length;
  }

  Future<int> labelClipping() async {
    final t = _analysisTrack;
    if (t == null) return 0;
    final file = t.file;
    final runs = await Isolate.run(() => findClipping(file));
    addLabels([for (final (s, e) in runs) SampleRange(s + t.offset, e + t.offset)], 'Clip');
    return runs.length;
  }

  Future<int> labelBeats({required double thresholdDb}) async {
    final t = _analysisTrack;
    if (t == null) return 0;
    final file = t.file;
    final win = sampleRate ~/ 100;
    final beats = await Isolate.run(() => findBeats(rmsEnvelope(file), win, thresholdDb: thresholdDb));
    addLabels([for (final b in beats) SampleRange(b + t.offset, b + t.offset)], 'Beat');
    return beats.length;
  }

  // ---------------------------------------------------------------- playback

  String? _mixCacheKey;
  String? _mixCacheFile;

  /// File to play for the project (mix of audible tracks), cached per state.
  Future<String?> playbackFile() async {
    final p0 = state.project;
    final audible = p0.audible;
    if (audible.isEmpty) return null;
    final t = audible.first;
    if (audible.length == 1 && t.offset == 0 && t.gainDb == 0 && t.pan == 0 && t.envelope.isEmpty) return t.file;
    final key = jsonEncode(p0.toJson()..remove('labels'));
    if (key == _mixCacheKey && _mixCacheFile != null) return _mixCacheFile;
    final out = _newFile();
    final ok = await _op('mix', () async {
      await _run(mixArgs(p0, out), frames: p0.length);
      return null;
    }, commit: false);
    if (!ok) return null;
    _mixCacheKey = key;
    _mixCacheFile = out;
    return out;
  }

  // ---------------------------------------------------------------- export

  /// Export the mix (or selection, or each label region) through the queue.
  Future<int> export({
    required String outputPath,
    required List<String> codec,
    Map<String, String> metadata = const {},
    bool selectionOnly = false,
    bool byLabels = false,
  }) async {
    final queue = ref.read(queueProvider.notifier);
    final p0 = state.project;
    final ranges = <(SampleRange?, String)>[];
    if (byLabels) {
      var i = 1;
      for (final l in p0.labels.where((l) => l.end > l.start)) {
        final name = l.text.trim().isEmpty
            ? i.toString().padLeft(2, '0')
            : l.text.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        final ext = p.extension(outputPath);
        ranges.add((
          SampleRange(l.start, l.end),
          p.join(p.dirname(outputPath), '${p.basenameWithoutExtension(outputPath)} - $name$ext'),
        ));
        i++;
      }
    } else {
      ranges.add((selectionOnly ? state.selection : null, outputPath));
    }
    // Snapshot the working files so later edits do not change queued exports.
    final snap = Directory(p.join(_work.path, 'export_${_counter++}'))..createSync();
    final tracks = <AudioTrack>[];
    for (final t in p0.audible) {
      final copy = p.join(snap.path, '${t.id}.wav');
      await File(t.file).copy(copy);
      tracks.add(t.copyWith(file: copy));
    }
    final frozen = p0.copyWith(tracks: tracks);
    for (final (r, out) in ranges) {
      final frames = r?.length ?? frozen.length;
      await queue.enqueue(
        JobRequest(
          kind: 'audioExport',
          title: p.basename(out),
          tool: JobTool.ffmpeg,
          steps: [
            JobStep(
              args: mixArgs(frozen, out, range: r, codec: codec, metadata: metadata),
            ),
          ],
          outputPath: out,
          totalDuration: Duration(microseconds: frames * 1000000 ~/ p0.sampleRate),
        ),
      );
    }
    return ranges.length;
  }

  // ---------------------------------------------------------------- recording

  /// Capture devices: Windows dshow audio devices; Linux PulseAudio/ALSA default.
  Future<List<(String format, String device, String label)>> recordingDevices() async {
    if (HostPlatform.current.isWindows) {
      final r = await ref.read(processRunnerProvider).capture(_ffmpeg, [
        '-hide_banner', '-list_devices', 'true', '-f', 'dshow', '-i', 'dummy', //
      ]);
      final out = <(String, String, String)>[];
      for (final m in RegExp(r'"([^"]+)"\s+\(audio\)').allMatches(r.stderr)) {
        out.add(('dshow', 'audio=${m.group(1)}', m.group(1)!));
      }
      return out;
    }
    final caps = ref.read(capabilitiesProvider).value;
    return [
      if (caps == null || caps.version == null || caps.isEnabled('libpulse'))
        ('pulse', 'default', 'PulseAudio / PipeWire'),
      ('alsa', 'default', 'ALSA'),
    ];
  }

  /// Starts recording into a new track at the cursor.
  Future<void> startRecording(String format, String device) async {
    if (state.recording || state.busy != null) return;
    final out = _newFile();
    final args = [
      '-hide_banner', '-y', '-v', 'info', //
      '-f', format, '-i', device,
      '-af', 'ebur128=framelog=verbose',
      '-ar', '$sampleRate', '-ac', '2', ...workCodec, out,
    ];
    final h = await ref
        .read(processRunnerProvider)
        .start(ToolInvocation(executable: _ffmpeg, args: args, progress: ProgressKind.none));
    _recorder = h;
    final startCursor = state.cursor;
    state = state.copyWith(recording: true, recordFrames: 0, recordLevel: () => null, error: () => null);
    final sub = h.logLines.listen((l) {
      final m = RegExp(r't:\s*([\d.]+).*?M:\s*(-?[\d.]+|-inf)').firstMatch(l);
      if (m != null && ref.mounted) {
        state = state.copyWith(
          recordFrames: (double.parse(m.group(1)!) * sampleRate).round(),
          recordLevel: () => double.tryParse(m.group(2)!),
        );
      }
    });
    unawaited(() async {
      final r = await h.done;
      await sub.cancel();
      _recorder = null;
      if (!ref.mounted) return;
      state = state.copyWith(recording: false, recordLevel: () => null);
      if (await File(out).exists() && await File(out).length() > 1024) {
        final wi = wavInfo(out);
        await _addClipAsTrack(AudioClip(out, wi.frames, wi.channels), 'record', startCursor, name: 'Recording');
      } else if (!r.success) {
        final e = translateToolError(r.log, startError: r.startError);
        state = state.copyWith(error: () => e.line ?? 'record');
      }
    }());
  }

  /// Stops cleanly ('q' lets ffmpeg finalize the WAV header).
  Future<void> stopRecording() async {
    final h = _recorder;
    if (h == null) return;
    h.writeStdin('q');
    await h.done.timeout(
      const Duration(seconds: 3),
      onTimeout: () async {
        await h.cancel();
        return h.done;
      },
    );
  }

  // ---------------------------------------------------------------- misc

  /// Effects marked unavailable because their filters are missing.
  bool effectAvailable(FxDef fx, FfmpegCapabilities caps) =>
      caps.version == null || fx.filters.every(caps.hasFilter) || fx.id == 'changePitch' || fx.id == 'changeTempo';
}

final audioEditorProvider = NotifierProvider<AudioEditorController, EditorState>(AudioEditorController.new);
