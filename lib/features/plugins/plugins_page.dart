/// "Plugin effects": frei0r video effects and LV2 audio plugins.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../core/platform/host.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/setting_tile.dart';
import '../audio/audio_chain.dart';
import '../edit/ui/edit_widgets.dart';
import '../tools/tool_scaffold.dart';
import 'plugins_ops.dart';

/// Kadra's own frei0r folder (put Windows DLLs here).
final frei0rDirProvider = Provider<String>((ref) => p.join(ref.watch(appPathsProvider).components, 'frei0r'));

final frei0rPluginsProvider = FutureProvider.autoDispose<List<Frei0rPlugin>>((ref) async {
  final own = ref.watch(frei0rDirProvider);
  await Directory(own).create(recursive: true);
  final win = HostPlatform.current.isWindows;
  return scanFrei0r(
    frei0rDirs(own: own, windows: win),
    windows: win,
  );
});

final lv2PluginsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final r = await ref.read(processRunnerProvider).capture('lv2ls', const []);
  return r.ok ? parseLv2ls(r.stdout) : const [];
});

/// What vf_frei0r reports about a module (`-v verbose`).
final frei0rInfoProvider = FutureProvider.autoDispose
    .family<({String? explanation, String? author, int? params}), String>((ref, name) async {
      final ffmpeg = ref.watch(toolchainProvider.select((t) => t.ffmpeg.path));
      if (ffmpeg == null) return (explanation: null, author: null, params: null);
      final env = frei0rEnv(ref.read(frei0rDirProvider), windows: HostPlatform.current.isWindows);
      final r = await ref.read(processRunnerProvider).capture(ffmpeg, [
        '-hide_banner', '-v', 'verbose', '-f', 'lavfi', '-i', 'color=s=32x32:d=0.04', //
        '-vf', 'frei0r=filter_name=$name', '-frames:v', '1', '-f', 'null', '-',
      ], environment: env);
      return parseFrei0rInfo(r.stderr);
    });

class PluginsPage extends ConsumerWidget {
  const PluginsPage({super.key, this.path});
  final String? path;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ToolInputLoader(
    toolId: 'plugins',
    path: path,
    builder: (i) => _PluginsForm(key: ValueKey(i.path), info: i),
  );
}

enum _Kind { video, audio }

class _PluginsForm extends ConsumerStatefulWidget {
  const _PluginsForm({super.key, required this.info});
  final MediaInfo info;
  @override
  ConsumerState<_PluginsForm> createState() => _PluginsFormState();
}

class _PluginsFormState extends ConsumerState<_PluginsForm> {
  late _Kind _kind = widget.info.videoStreams.isEmpty ? _Kind.audio : _Kind.video;
  String? _frei0r;
  String? _lv2;
  final _params = TextEditingController();
  final _controls = TextEditingController();

  @override
  void dispose() {
    _params.dispose();
    _controls.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final info = widget.info;
    final caps = ref.watch(capabilitiesProvider).value;
    final own = ref.watch(frei0rDirProvider);
    final win = HostPlatform.current.isWindows;
    final env = frei0rEnv(own, windows: win);
    final frei = ref.watch(frei0rPluginsProvider).value ?? const <Frei0rPlugin>[];
    final lv2 = ref.watch(lv2PluginsProvider).value ?? const <String>[];
    final hasFrei0r = caps?.hasFilter('frei0r') ?? true;
    final hasLv2 = caps?.hasFilter('lv2') ?? true;
    final frei0r = frei.any((x) => x.name == _frei0r) ? _frei0r : frei.firstOrNull?.name;
    final uri = lv2.contains(_lv2) ? _lv2 : lv2.firstOrNull;

    final kindPicker = SettingTile(
      title: l.pPluginKind,
      hint: _kind == _Kind.video ? l.pluginsFrei0rHint : l.pluginsLv2Hint,
      controlBelow: true,
      control: SegmentedButton<_Kind>(
        segments: [
          ButtonSegment(value: _Kind.video, label: Text(l.pluginsVideo), enabled: info.videoStreams.isNotEmpty),
          ButtonSegment(value: _Kind.audio, label: Text(l.pluginsAudio), enabled: info.audioStreams.isNotEmpty),
        ],
        selected: {_kind},
        onSelectionChanged: (v) => setState(() => _kind = v.first),
      ),
    );

    if (_kind == _Kind.video) {
      final graph = frei0r == null || !hasFrei0r ? null : frei0rGraph(info, frei0r, params: _params.text);
      final pi = frei0r == null ? null : ref.watch(frei0rInfoProvider(frei0r)).value;
      return EditScaffold(
        toolId: 'plugins',
        info: info,
        suffix: '_fx',
        compare: true,
        graph: graph,
        processEnv: env,
        problems: [
          if (!hasFrei0r) l.pluginsNoFilter('frei0r'),
          if (hasFrei0r && frei.isEmpty) win ? l.noFrei0rWindows : l.noFrei0rLinux,
        ],
        preview: graph == null ? null : FramePreview(info: info, graph: graph, processEnv: env),
        params: [
          ParamGroup(
            title: l.toolPlugins,
            children: [
              kindPicker,
              if (frei.isNotEmpty)
                SettingTile(
                  title: l.pPlugin,
                  hint: pi?.explanation ?? l.pPluginHint(frei.length),
                  controlBelow: true,
                  control: DropdownButton<String>(
                    isExpanded: true,
                    menuMaxHeight: 420,
                    value: frei0r,
                    onChanged: (v) => setState(() {
                      _frei0r = v;
                      _params.clear();
                    }),
                    items: [for (final x in frei) DropdownMenuItem(value: x.name, child: Text(x.name))],
                  ),
                ),
              if (frei.isNotEmpty)
                SettingTile(
                  title: l.pPluginParams,
                  hint: pi?.params == null ? l.pFrei0rParamsHint : l.pFrei0rParamsCount(pi!.params!),
                  controlBelow: true,
                  control: TextField(
                    controller: _params,
                    decoration: const InputDecoration(hintText: '0.5|0.2', isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: Text(l.openPluginsFolder),
                    onPressed: () async {
                      await Directory(own).create(recursive: true);
                      await launchUrl(Uri.directory(own));
                      ref.invalidate(frei0rPluginsProvider);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final ext = audioFxExt(info);
    final filter = uri == null ? null : lv2Filter(uri, controls: _controls.text);
    return EditScaffold(
      toolId: 'plugins',
      info: info,
      suffix: '_fx',
      fixedExt: ext,
      customSteps: filter == null || !hasLv2
          ? null
          : (out, _) => planAudioChain(info: info, output: out, filters: [filter], keepLength: false),
      problems: [if (!hasLv2) l.pluginsNoFilter('lv2'), if (hasLv2 && lv2.isEmpty) l.noLv2Plugins],
      params: [
        ParamGroup(
          title: l.toolPlugins,
          children: [
            kindPicker,
            if (lv2.isNotEmpty)
              SettingTile(
                title: l.pPlugin,
                hint: l.pPluginHint(lv2.length),
                controlBelow: true,
                control: DropdownButton<String>(
                  isExpanded: true,
                  menuMaxHeight: 420,
                  value: uri,
                  onChanged: (v) => setState(() {
                    _lv2 = v;
                    _controls.clear();
                  }),
                  items: [
                    for (final x in lv2)
                      DropdownMenuItem(
                        value: x,
                        child: Text(x, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
            if (lv2.isNotEmpty)
              SettingTile(
                title: l.pPluginParams,
                hint: l.pLv2ControlsHint,
                controlBelow: true,
                control: TextField(
                  controller: _controls,
                  decoration: const InputDecoration(hintText: 'gain=0.5|freq=1000', isDense: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
