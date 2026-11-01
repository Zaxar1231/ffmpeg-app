import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/capabilities.dart';
import '../../core/engine/shell_quote.dart';
import '../../core/platform/app_paths.dart';
import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/output_paths.dart';
import '../../ui/l10n.dart';
import '../convert/convert_params.dart';
import '../shell/app_shell.dart';
import 'command_text.dart';

/// Which tool is open in the Tools section (null = catalog).
class OpenTool {
  const OpenTool(this.id, {this.path, this.presetId, this.extra});
  final String id;
  final String? path;

  /// Tool-specific start data handed over by another tool (e.g. detector
  /// findings → cut ranges). Dropped when the file changes.
  final Object? extra;

  /// Convert: start from this preset (builtin id or `user:<id>`).
  final String? presetId;
}

class OpenToolController extends Notifier<OpenTool?> {
  @override
  OpenTool? build() => null;
  void open(OpenTool t) => state = t;
  void setPath(String path) {
    final s = state;
    if (s != null) state = OpenTool(s.id, path: path, presetId: s.presetId);
  }

  void close() => state = null;
}

final openToolProvider = NotifierProvider<OpenToolController, OpenTool?>(OpenToolController.new);

/// ffprobe result per file, cached while a tool shows it.
final mediaInfoProvider = FutureProvider.autoDispose.family<MediaInfo, String>((ref, path) async {
  final probe = ref.watch(probeServiceProvider);
  if (probe == null) throw StateError('ffprobe');
  return probe.probe(path);
});

/// Build environment for command builders.
final encodeEnvProvider = Provider<EncodeEnv>((ref) {
  final caps = ref.watch(capabilitiesProvider).value ?? FfmpegCapabilities.empty;
  final hw = ref.watch(hwAccelProvider).value;
  final s = ref.watch(settingsProvider);
  return EncodeEnv(caps: caps, hw: hw, allowHardware: s.useHwAccel, threads: s.ffmpegThreads);
});

/// Folder for results of [input] per settings.
String outputDirFor(WidgetRef ref, String input) {
  final s = ref.read(settingsProvider);
  if (s.outputNextToSource) return p.dirname(input);
  return s.outputDir ?? AppPaths.defaultOutputDir();
}

String defaultOutput(WidgetRef ref, String input, {required String ext, String suffix = ''}) =>
    outputPathFor(input, ext: ext, suffix: suffix, dir: outputDirFor(ref, input));

/// Lets the user pick an output file; keeps [ext].
Future<String?> pickOutput(BuildContext context, String current, String ext) async {
  final loc = await getSaveLocation(
    initialDirectory: p.dirname(current),
    suggestedName: p.basename(current),
    confirmButtonText: context.l10n.choose,
  );
  if (loc == null) return null;
  return p.extension(loc.path).isEmpty ? '${loc.path}.$ext' : loc.path;
}

Future<String?> pickInputFile() async => (await openFile())?.path;

/// Queues a job. With "show command before run", the command is shown first;
/// single-step commands can be edited there.
Future<void> submitJob(BuildContext context, WidgetRef ref, JobRequest request, {bool now = false}) async {
  final l = context.l10n;
  var req = request;
  if (ref.read(settingsProvider).showCommandBeforeRun) {
    final edited = await showDialog<List<JobStep>>(
      context: context,
      builder: (_) => _CommandConfirmDialog(steps: req.effectiveSteps),
    );
    if (edited == null) return;
    req = JobRequest(
      kind: req.kind,
      title: req.title,
      tool: req.tool,
      steps: edited,
      inputPath: req.inputPath,
      outputPath: req.outputPath,
      totalDuration: req.totalDuration,
      priority: req.priority,
      maxRetries: req.maxRetries,
      logIsResult: req.logIsResult,
    );
  }
  if (now) {
    req = JobRequest(
      kind: req.kind,
      title: req.title,
      tool: req.tool,
      args: req.args,
      steps: req.steps,
      inputPath: req.inputPath,
      outputPath: req.outputPath,
      totalDuration: req.totalDuration,
      priority: 10,
      maxRetries: req.maxRetries,
      logIsResult: req.logIsResult,
    );
  }
  await ref.read(queueProvider.notifier).enqueue(req);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      persist: false,
      content: Text(l.addedToQueue),
      action: SnackBarAction(label: l.openQueue, onPressed: () => ref.read(navProvider.notifier).go(Destination.queue)),
    ),
  );
}

class _CommandConfirmDialog extends ConsumerStatefulWidget {
  const _CommandConfirmDialog({required this.steps});
  final List<JobStep> steps;

  @override
  ConsumerState<_CommandConfirmDialog> createState() => _CommandConfirmDialogState();
}

class _CommandConfirmDialogState extends ConsumerState<_CommandConfirmDialog> {
  late final TextEditingController _c;
  String? _error;

  bool get _editable => widget.steps.length == 1;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _editable ? quoteCommand(widget.steps.single.args) : '');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final mono = const TextStyle(fontFamily: 'monospace', fontSize: 12.5);
    return AlertDialog(
      title: Text(l.commandTitle),
      content: SizedBox(
        width: 760,
        child: _editable
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.commandEditHint),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _c,
                    maxLines: 8,
                    style: mono,
                    decoration: InputDecoration(errorText: _error),
                  ),
                ],
              )
            : SelectableText(stepsCommandText(widget.steps, ref.read(toolchainProvider)), style: mono),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (!_editable) return Navigator.pop(context, widget.steps);
            try {
              final args = splitCommandLine(_c.text);
              Navigator.pop(context, [
                JobStep(
                  args: args,
                  tool: widget.steps.single.tool,
                  totalDuration: widget.steps.single.totalDuration,
                  workingDirectory: widget.steps.single.workingDirectory,
                  files: widget.steps.single.files,
                ),
              ]);
            } on FormatException {
              setState(() => _error = l.commandParseError);
            }
          },
          child: Text(l.runCommand),
        ),
      ],
    );
  }
}
