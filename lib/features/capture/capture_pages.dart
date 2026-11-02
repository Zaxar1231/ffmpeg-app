import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/encoders.dart';
import '../../core/platform/app_paths.dart';
import '../../core/platform/host.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/setting_tile.dart';
import '../queue/queue_page.dart' show openContainingFolder;
import '../tools/tool_catalog.dart';
import '../tools/tool_infra.dart';
import '../tools/tool_scaffold.dart';
import 'capture_controller.dart';
import 'capture_ops.dart';

String _outDir(WidgetRef ref) {
  final s = ref.read(settingsProvider);
  return s.outputDir ?? AppPaths.defaultOutputDir();
}

/// H.264 encoder for live work: a working hardware one when allowed.
String _liveEncoder(WidgetRef ref) {
  final env = ref.read(encodeEnvProvider);
  return pickVideoEncoder(VideoCodecChoice.h264, caps: env.caps, hw: env.hw, allowHardware: env.allowHardware)?.name ??
      'libx264';
}

/// Timer, live stats and the start/stop button.
class _LivePanel extends ConsumerWidget {
  const _LivePanel({required this.kind, required this.onStart, required this.canStart});
  final LiveKind kind;
  final VoidCallback onStart;
  final bool canStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final st = ref.watch(liveProvider);
    final mine = st.kind == kind;
    final busyOther = st.running && !mine;
    final pr = mine ? st.progress : null;
    final slow = pr?.speed != null && pr!.speed! < 0.95 && (pr.outTime ?? Duration.zero) > const Duration(seconds: 3);
    return Card.filled(
      color: st.running && mine ? t.colorScheme.errorContainer : t.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (st.running && mine) ...[
                  Icon(Icons.fiber_manual_record, color: t.colorScheme.error),
                  const SizedBox(width: 8),
                ],
                Text(
                  formatDuration(pr?.outTime ?? Duration.zero),
                  style: t.textTheme.displaySmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
                const Spacer(),
                if (st.running && mine)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: t.colorScheme.error,
                      foregroundColor: t.colorScheme.onError,
                    ),
                    icon: st.stopping
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.stop),
                    label: Text(l.stop),
                    onPressed: st.stopping ? null : () => ref.read(liveProvider.notifier).stop(),
                  )
                else
                  FilledButton.icon(
                    icon: Icon(kind == LiveKind.record ? Icons.fiber_manual_record : Icons.cell_tower),
                    label: Text(kind == LiveKind.record ? l.startRecording : l.startStream),
                    onPressed: canStart && !busyOther ? onStart : null,
                  ),
              ],
            ),
            if (pr != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  [
                    if (pr.fps != null) '${pr.fps!.toStringAsFixed(0)} ${l.unitFps}',
                    if (pr.bitrateKbps != null) '${pr.bitrateKbps!.round()} ${l.unitKbps}',
                    if (pr.totalSize != null && kind == LiveKind.record) formatBytes(pr.totalSize, units: byteUnits(l)),
                    if ((pr.dropFrames ?? 0) > 0) l.droppedFrames(pr.dropFrames!),
                  ].join(' · '),
                ),
              ),
            if (slow)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l.liveTooSlow(pr.speed!.toStringAsFixed(2)), style: TextStyle(color: t.colorScheme.error)),
              ),
            if (busyOther) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.liveBusy)),
            if (mine && st.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  toolErrorText(l, st.error!.kind, st.error!.detail).isEmpty
                      ? (st.error!.line ?? '')
                      : toolErrorText(l, st.error!.kind, st.error!.detail),
                  style: TextStyle(color: t.colorScheme.error),
                ),
              ),
            if (mine && !st.running && st.lastFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(l.savedTo(st.lastFile!))),
                    TextButton.icon(
                      icon: const Icon(Icons.folder_open),
                      label: Text(l.openFolder),
                      onPressed: () => openContainingFolder(st.lastFile!),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Audio sources as checkboxes.
class _AudioPicker extends StatelessWidget {
  const _AudioPicker({required this.devices, required this.selected, required this.onChanged});
  final List<CaptureDevice> devices;
  final Set<CaptureDevice> selected;
  final ValueChanged<Set<CaptureDevice>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        for (final d in devices)
          CheckboxListTile(
            dense: true,
            value: selected.contains(d),
            title: Text(d.label),
            subtitle: Text(isSystemAudio(d) ? l.systemAudio : l.microphone),
            onChanged: (v) => onChanged(v! ? ({...selected, d}) : ({...selected}..remove(d))),
          ),
        if (devices.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text(l.noAudioDevices)),
      ],
    );
  }
}

// ============================================================ recording

/// Screen recording (`screenRecord`) and camera recording (`webcam`).
class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key, required this.camera});
  final bool camera;
  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage> {
  int _fps = 30;
  bool _mouse = true;
  bool _region = false;
  final _x = TextEditingController(text: '0'), _y = TextEditingController(text: '0');
  final _w = TextEditingController(text: '1280'), _h = TextEditingController(text: '720');
  CaptureDevice? _camera;
  Set<CaptureDevice>? _audio;
  int _crf = 23;
  bool _mp4 = true;
  int? _height;

  @override
  void dispose() {
    for (final c in [_x, _y, _w, _h]) {
      c.dispose();
    }
    super.dispose();
  }

  ScreenRegion? get _screenRegion => _region
      ? ScreenRegion(
          int.tryParse(_x.text) ?? 0,
          int.tryParse(_y.text) ?? 0,
          int.tryParse(_w.text) ?? 1280,
          int.tryParse(_h.text) ?? 720,
        )
      : null;

  void _start(DeviceList devices) {
    final host = HostPlatform.current;
    final video = widget.camera
        ? _camera ?? devices.cameras.firstOrNull
        : screenDevice(
            host: host,
            fps: _fps,
            region: _screenRegion,
            drawMouse: _mouse,
            display: Platform.environment['DISPLAY'] ?? ':0',
          );
    final cam = widget.camera && video != null
        ? CaptureDevice(video.format, video.name, video.label, options: [...video.options, '-framerate', '$_fps'])
        : video;
    final audio = (_audio ?? _defaultAudio(devices)).toList();
    final stamp = DateTime.now().toIso8601String().substring(0, 19).replaceAll(':', '-').replaceAll('T', '_');
    final name = '${widget.camera ? 'camera' : 'screen'}_$stamp.$recordingExt';
    final out = p.join(_outDir(ref), name);
    ref
        .read(liveProvider.notifier)
        .start(
          kind: LiveKind.record,
          args: recordArgs(
            src: CaptureSources(video: cam, audio: audio),
            output: out,
            enc: LiveEncode(encoder: _liveEncoder(ref), crf: _crf, fps: _fps, height: _height),
          ),
          output: out,
          remuxMp4: _mp4,
        );
  }

  /// Microphones by default (system audio needs a choice).
  Set<CaptureDevice> _defaultAudio(DeviceList d) => {...d.audio.where((a) => !isSystemAudio(a)).take(1)};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final devices = ref.watch(captureDevicesProvider);
    final dl = devices.value ?? const DeviceList();
    final audioSel = _audio ?? _defaultAudio(dl);
    final cams = dl.cameras;
    final canStart = !widget.camera || cams.isNotEmpty;
    return ToolFrame(
      toolId: widget.camera ? 'webcam' : 'screenRecord',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          _LivePanel(kind: LiveKind.record, canStart: canStart && devices.hasValue, onStart: () => _start(dl)),
          if (dl.note == 'wayland' && !widget.camera)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.waylandNote, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 12),
          ParamGroup(
            title: widget.camera ? l.groupCamera : l.groupScreen,
            children: [
              if (widget.camera)
                SettingTile(
                  title: l.pCamera,
                  hint: cams.isEmpty ? l.noCameras : l.pCameraHint,
                  control: DropdownButton<CaptureDevice>(
                    value: cams.contains(_camera) ? _camera : cams.firstOrNull,
                    onChanged: (v) => setState(() => _camera = v),
                    items: [for (final c in cams) DropdownMenuItem(value: c, child: Text(c.label))],
                  ),
                )
              else ...[
                SettingTile(
                  title: l.pCaptureRegion,
                  hint: _region ? l.pCaptureRegionHint : l.wholeScreen,
                  control: Switch(value: _region, onChanged: (v) => setState(() => _region = v)),
                ),
                if (_region)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final (c, label) in [(_x, 'X'), (_y, 'Y'), (_w, l.widthLabel), (_h, l.heightLabel)])
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: c,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: label, isDense: true),
                            ),
                          ),
                      ],
                    ),
                  ),
                SettingTile(
                  title: l.pDrawMouse,
                  hint: l.pDrawMouseHint,
                  control: Switch(value: _mouse, onChanged: (v) => setState(() => _mouse = v)),
                ),
              ],
              SettingTile(
                title: l.pSpeedFps,
                hint: l.pCaptureFpsHint,
                control: DropdownButton<int>(
                  value: _fps,
                  onChanged: (v) => setState(() => _fps = v!),
                  items: [
                    for (final f in const [15, 24, 30, 60]) DropdownMenuItem(value: f, child: Text('$f')),
                  ],
                ),
              ),
            ],
          ),
          ParamGroup(
            title: l.groupCaptureAudio,
            children: [
              if (devices.isLoading) const LinearProgressIndicator(),
              _AudioPicker(devices: dl.audio, selected: audioSel, onChanged: (v) => setState(() => _audio = v)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  HostPlatform.current.isWindows ? l.systemAudioWindows : l.systemAudioLinux,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          ParamGroup(
            title: l.groupEditOutput,
            children: [
              SettingTile(
                title: l.pEditQuality,
                hint: l.pCaptureQualityHint,
                controlBelow: true,
                control: SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 18, label: Text(l.editQualityHigh)),
                    ButtonSegment(value: 23, label: Text(l.editQualityBalanced)),
                    ButtonSegment(value: 28, label: Text(l.editQualitySmall)),
                  ],
                  selected: {_crf},
                  onSelectionChanged: (v) => setState(() => _crf = v.first),
                ),
              ),
              SettingTile(
                title: l.pFrameHeight,
                hint: l.pFrameHeightHint,
                control: DropdownButton<int?>(
                  value: _height,
                  onChanged: (v) => setState(() => _height = v),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                    for (final h in const [1080, 720, 480]) DropdownMenuItem(value: h, child: Text('$h')),
                  ],
                ),
              ),
              SettingTile(
                title: l.pSaveMp4,
                hint: l.pSaveMp4Hint,
                control: Switch(value: _mp4, onChanged: (v) => setState(() => _mp4 = v)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(l.saveTo(_outDir(ref)), style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================== stream

enum _StreamSource { screen, camera, file }

const _services = [
  ('youtube', 'rtmp://a.rtmp.youtube.com/live2'),
  ('twitch', 'rtmp://live.twitch.tv/app'),
  ('vk', 'rtmp://ovsu.mycdn.me/input'),
  ('custom', ''),
];

class StreamPage extends ConsumerStatefulWidget {
  const StreamPage({super.key, this.path});
  final String? path;
  @override
  ConsumerState<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends ConsumerState<StreamPage> {
  late _StreamSource _source = widget.path != null ? _StreamSource.file : _StreamSource.screen;
  late String? _file = widget.path;
  bool _loop = false;
  String _service = 'youtube';
  final _url = TextEditingController();
  final _key = TextEditingController();
  bool _showKey = false;
  int _kbps = 4500;
  int _fps = 30;
  int? _height = 1080;
  CaptureDevice? _camera;
  Set<CaptureDevice>? _audio;

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  String? get _target {
    final base = _service == 'custom' ? _url.text.trim() : _services.firstWhere((s) => s.$1 == _service).$2;
    if (base.isEmpty) return null;
    if (base.startsWith('srt://') || _key.text.trim().isEmpty) return base;
    return '${base.replaceAll(RegExp(r'/+$'), '')}/${_key.text.trim()}';
  }

  void _start(DeviceList d) {
    final target = _target;
    if (target == null) return;
    final src = switch (_source) {
      _StreamSource.file => CaptureSources(file: _file, loopFile: _loop),
      _StreamSource.screen => CaptureSources(
        video: screenDevice(host: HostPlatform.current, fps: _fps, display: Platform.environment['DISPLAY'] ?? ':0'),
        audio: (_audio ?? {...d.audio.where((a) => !isSystemAudio(a)).take(1)}).toList(),
      ),
      _StreamSource.camera => CaptureSources(
        video: _camera ?? d.cameras.firstOrNull,
        audio: (_audio ?? {...d.audio.where((a) => !isSystemAudio(a)).take(1)}).toList(),
      ),
    };
    ref
        .read(liveProvider.notifier)
        .start(
          kind: LiveKind.stream,
          args: streamArgs(
            src: src,
            url: target,
            enc: LiveEncode(encoder: _liveEncoder(ref), videoKbps: _kbps, fps: _fps, height: _height),
          ),
          output: target,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final devices = ref.watch(captureDevicesProvider);
    final dl = devices.value ?? const DeviceList();
    final ready =
        _target != null &&
        (_source != _StreamSource.file || _file != null) &&
        (_source != _StreamSource.camera || dl.cameras.isNotEmpty);
    return ToolFrame(
      toolId: 'stream',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          _LivePanel(kind: LiveKind.stream, canStart: ready, onStart: () => _start(dl)),
          const SizedBox(height: 12),
          ParamGroup(
            title: l.groupStreamTarget,
            children: [
              SettingTile(
                title: l.pService,
                hint: l.pServiceHint,
                control: DropdownButton<String>(
                  value: _service,
                  onChanged: (v) => setState(() => _service = v!),
                  items: [
                    for (final (id, _) in _services)
                      DropdownMenuItem(
                        value: id,
                        child: Text(switch (id) {
                          'youtube' => 'YouTube',
                          'twitch' => 'Twitch',
                          'vk' => 'VK Видео',
                          _ => l.customServer,
                        }),
                      ),
                  ],
                ),
              ),
              if (_service == 'custom')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _url,
                    decoration: InputDecoration(
                      labelText: l.serverUrl,
                      hintText: 'rtmp://… / srt://host:port',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _key,
                  obscureText: !_showKey,
                  decoration: InputDecoration(
                    labelText: l.streamKey,
                    helperText: l.streamKeyHint,
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showKey = !_showKey),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          ParamGroup(
            title: l.groupStreamSource,
            children: [
              SettingTile(
                title: l.pStreamSource,
                hint: l.pStreamSourceHint,
                controlBelow: true,
                control: SegmentedButton<_StreamSource>(
                  segments: [
                    ButtonSegment(
                      value: _StreamSource.screen,
                      icon: const Icon(Icons.screen_share_outlined),
                      label: Text(l.sourceScreen),
                    ),
                    ButtonSegment(
                      value: _StreamSource.camera,
                      icon: const Icon(Icons.videocam_outlined),
                      label: Text(l.sourceCamera),
                    ),
                    ButtonSegment(
                      value: _StreamSource.file,
                      icon: const Icon(Icons.movie_outlined),
                      label: Text(l.sourceFile),
                    ),
                  ],
                  selected: {_source},
                  onSelectionChanged: (v) => setState(() => _source = v.first),
                ),
              ),
              if (_source == _StreamSource.file) ...[
                ListTile(
                  title: Text(_file == null ? l.chooseInputTitle : p.basename(_file!)),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final f = await openFile();
                      if (f != null) setState(() => _file = f.path);
                    },
                    child: Text(l.choose),
                  ),
                ),
                SettingTile(
                  title: l.pLoopFile,
                  hint: l.pLoopFileHint,
                  control: Switch(value: _loop, onChanged: (v) => setState(() => _loop = v)),
                ),
              ],
              if (_source == _StreamSource.camera)
                SettingTile(
                  title: l.pCamera,
                  hint: dl.cameras.isEmpty ? l.noCameras : l.pCameraHint,
                  control: DropdownButton<CaptureDevice>(
                    value: dl.cameras.contains(_camera) ? _camera : dl.cameras.firstOrNull,
                    onChanged: (v) => setState(() => _camera = v),
                    items: [for (final c in dl.cameras) DropdownMenuItem(value: c, child: Text(c.label))],
                  ),
                ),
              if (_source != _StreamSource.file)
                _AudioPicker(
                  devices: dl.audio,
                  selected: _audio ?? {...dl.audio.where((a) => !isSystemAudio(a)).take(1)},
                  onChanged: (v) => setState(() => _audio = v),
                ),
            ],
          ),
          ParamGroup(
            title: l.groupStreamQuality,
            children: [
              SettingTile(
                title: l.pFrameHeight,
                hint: l.pFrameHeightHint,
                control: DropdownButton<int?>(
                  value: _height,
                  onChanged: (v) => setState(() => _height = v),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l.keepOriginal)),
                    for (final h in const [1080, 720, 480]) DropdownMenuItem(value: h, child: Text('$h')),
                  ],
                ),
              ),
              SettingTile(
                title: l.pSpeedFps,
                hint: l.pCaptureFpsHint,
                control: DropdownButton<int>(
                  value: _fps,
                  onChanged: (v) => setState(() => _fps = v!),
                  items: [
                    for (final f in const [24, 30, 60]) DropdownMenuItem(value: f, child: Text('$f')),
                  ],
                ),
              ),
              SettingTile(
                title: l.pStreamBitrate,
                hint: l.pStreamBitrateHint,
                control: DropdownButton<int>(
                  value: _kbps,
                  onChanged: (v) => setState(() => _kbps = v!),
                  items: [
                    for (final k in const [1500, 2500, 3500, 4500, 6000, 8000, 12000])
                      DropdownMenuItem(value: k, child: Text('$k ${l.unitKbps}')),
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

// ============================================================ HLS / DASH

class HlsPage extends ConsumerWidget {
  const HlsPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'hls',
    path: path,
    builder: (i) => _HlsForm(key: ValueKey(i.path), info: i),
  );
}

class _HlsForm extends ConsumerStatefulWidget {
  const _HlsForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_HlsForm> createState() => _HlsFormState();
}

class _HlsFormState extends ConsumerState<_HlsForm> {
  PackageFormat _format = PackageFormat.hls;
  final _heights = <int>{1080, 720, 480};
  int _segment = 6;
  String? _dir;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final env = ref.watch(encodeEnvProvider);
    final dir =
        _dir ?? p.join(outputDirFor(ref, info.path), '${p.basenameWithoutExtension(info.path)}_${_format.name}');
    final entry = packageEntry(dir, _format);
    final rungs = info.videoStreams.isEmpty ? const <(int, int, int)>[] : ladderFor(info, _heights.toList());
    final steps = rungs.isEmpty
        ? null
        : planPackage(
            info: info,
            outDir: dir,
            format: _format,
            heights: _heights.toList(),
            segment: _segment,
            env: env,
          );
    return ToolScaffold(
      toolId: 'hls',
      info: info,
      outputPath: entry,
      outputExt: _format == PackageFormat.hls ? 'm3u8' : 'mpd',
      onOutputChanged: (v) => setState(() => _dir = p.dirname(v)),
      steps: steps,
      estimate: rungs.isEmpty ? null : l.ladderSummary(rungs.map((r) => '${r.$1}p').join(', ')),
      problems: [if (info.videoStreams.isEmpty) l.issueNoVideo],
      onSubmit: (now) async {
        await Directory(dir).create(recursive: true);
        if (!context.mounted) return;
        await submitJob(
          context,
          ref,
          JobRequest(
            kind: 'hls',
            title: '${toolTitle(l, 'hls')}: ${p.basename(info.path)}',
            tool: JobTool.ffmpeg,
            steps: steps,
            inputPath: info.path,
            outputPath: entry,
            totalDuration: info.duration,
          ),
          now: now,
        );
      },
      params: [
        ParamGroup(
          title: l.groupPackage,
          children: [
            SettingTile(
              title: l.pPackageFormat,
              hint: _format == PackageFormat.hls ? l.hlsHint : l.dashHint,
              controlBelow: true,
              control: SegmentedButton<PackageFormat>(
                segments: const [
                  ButtonSegment(value: PackageFormat.hls, label: Text('HLS')),
                  ButtonSegment(value: PackageFormat.dash, label: Text('MPEG-DASH')),
                ],
                selected: {_format},
                onSelectionChanged: (v) => setState(() => _format = v.first),
              ),
            ),
            SettingTile(
              title: l.pLadder,
              hint: l.pLadderHint,
              controlBelow: true,
              control: Wrap(
                spacing: 6,
                children: [
                  for (final r in ladder)
                    FilterChip(
                      label: Text('${r.$1}p · ${r.$2} ${l.unitKbps}'),
                      selected: _heights.contains(r.$1),
                      onSelected: (v) => setState(() => v ? _heights.add(r.$1) : _heights.remove(r.$1)),
                    ),
                ],
              ),
            ),
            SettingTile(
              title: l.pSegment,
              hint: l.pSegmentHint,
              control: DropdownButton<int>(
                value: _segment,
                onChanged: (v) => setState(() => _segment = v!),
                items: [
                  for (final s in const [2, 4, 6, 10]) DropdownMenuItem(value: s, child: Text('$s ${l.unitSecond}')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(l.packageFolderNote(dir), style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ],
    );
  }
}
