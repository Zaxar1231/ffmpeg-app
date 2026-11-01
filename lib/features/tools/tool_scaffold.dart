import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/error_translator.dart';
import '../../core/probe/media_info.dart';
import '../../core/probe/probe_service.dart';
import '../../core/providers.dart';
import '../../core/queue/job_steps.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import 'ab_compare.dart';
import 'command_text.dart';
import 'tool_catalog.dart';
import 'tool_infra.dart';

/// Loads the input file of a tool and shows loading/error states.
class ToolInputLoader extends ConsumerWidget {
  const ToolInputLoader({super.key, required this.toolId, required this.path, required this.builder});
  final String toolId;
  final String? path;
  final Widget Function(MediaInfo info) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final path = this.path;
    if (path == null) {
      return ToolFrame(
        toolId: toolId,
        child: EmptyState(
          icon: toolById(toolId).icon,
          title: l.chooseInputTitle,
          message: toolDescription(l, toolId),
          action: FilledButton.icon(
            icon: const Icon(Icons.folder_open),
            label: Text(l.openFile),
            onPressed: () async {
              final f = await pickInputFile();
              if (f != null) ref.read(openToolProvider.notifier).setPath(f);
            },
          ),
        ),
      );
    }
    return ref
        .watch(mediaInfoProvider(path))
        .when(
          loading: () => ToolFrame(
            toolId: toolId,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) {
            final raw = e is ProbeException ? '${e.message}\n${e.log}' : e.toString();
            final err = translateToolError(raw.split('\n'));
            return ToolFrame(
              toolId: toolId,
              child: EmptyState(
                icon: Icons.error_outline,
                title: l.probeFailed,
                message: err.kind == ToolErrorKind.unknown ? raw.trim() : toolErrorText(l, err.kind, err.detail),
              ),
            );
          },
          data: builder,
        );
  }
}

/// Header with back button and tool title.
class ToolFrame extends ConsumerWidget {
  const ToolFrame({super.key, required this.toolId, required this.child, this.subtitle, this.trailing = const []});
  final String toolId;
  final Widget child;
  final String? subtitle;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 16, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: l.back,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => ref.read(openToolProvider.notifier).close(),
              ),
              const SizedBox(width: 4),
              Icon(toolById(toolId).icon, color: t.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(toolTitle(l, toolId), style: t.textTheme.titleLarge),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              ...trailing,
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Standard tool layout: preview left, parameters right, and a bottom bar
/// with the estimate, output path, "Show command" and "Queue / Run now".
class ToolScaffold extends ConsumerWidget {
  const ToolScaffold({
    super.key,
    required this.toolId,
    required this.info,
    required this.params,
    required this.outputPath,
    required this.onOutputChanged,
    required this.outputExt,
    required this.steps,
    required this.onSubmit,
    this.preview,
    this.estimate,
    this.problems = const [],
    this.warnings = const [],
    this.compare = false,
  });

  final String toolId;
  final MediaInfo info;
  final Widget? preview;

  /// Offer the A/B comparison of a rendered fragment with the original.
  final bool compare;
  final List<Widget> params;
  final String? outputPath;
  final ValueChanged<String> onOutputChanged;
  final String outputExt;

  /// Null when parameters are invalid (see [problems]).
  final List<JobStep>? steps;
  final void Function(bool now) onSubmit;
  final String? estimate;
  final List<String> problems;
  final List<String> warnings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final canRun = steps != null && problems.isEmpty && outputPath != null;
    final summary = [
      formatDuration(info.duration),
      if (info.videoStreams.isNotEmpty) '${info.videoStreams.first.width}×${info.videoStreams.first.height}',
      if (info.format.size != null) formatBytes(info.format.size, units: byteUnits(l)),
    ].join(' · ');

    final paramsList = ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
      children: [
        ...params,
        for (final w in warnings) _Note(text: w, error: false),
        for (final pr in problems) _Note(text: pr, error: true),
      ],
    );

    final bottom = Material(
      color: t.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (estimate != null) Text(estimate!, style: t.textTheme.titleSmall),
                  if (outputPath != null)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l.saveTo(outputPath!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await pickOutput(context, outputPath!, outputExt);
                            if (picked != null) onOutputChanged(picked);
                          },
                          child: Text(l.change),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (compare && canRun) AbCompareButton(info: info, steps: steps!, output: outputPath!),
            TextButton.icon(
              icon: const Icon(Icons.terminal),
              label: Text(l.showCommand),
              onPressed: steps == null
                  ? null
                  : () => showTextDialog(
                      context,
                      title: l.commandTitle,
                      text: stepsCommandText(steps!, ref.read(toolchainProvider)),
                    ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.playlist_add),
              label: Text(l.addToQueue),
              onPressed: canRun ? () => onSubmit(false) : null,
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(l.runNow),
              onPressed: canRun ? () => onSubmit(true) : null,
            ),
          ],
        ),
      ),
    );

    return ToolFrame(
      toolId: toolId,
      subtitle: '${p.basename(info.path)} · $summary',
      trailing: [
        TextButton.icon(
          icon: const Icon(Icons.swap_horiz),
          label: Text(l.otherFile),
          onPressed: () async {
            final f = await pickInputFile();
            if (f != null) ref.read(openToolProvider.notifier).setPath(f);
          },
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth > 980 && preview != null) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(padding: const EdgeInsets.fromLTRB(24, 0, 12, 24), child: preview),
                      ),
                      Expanded(flex: 6, child: paramsList),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    if (preview != null) ...[preview!, const SizedBox(height: 16)],
                    ...params,
                    for (final w in warnings) _Note(text: w, error: false),
                    for (final pr in problems) _Note(text: pr, error: true),
                  ],
                );
              },
            ),
          ),
          bottom,
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.error});
  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card.filled(
        color: error ? cs.errorContainer : cs.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                error ? Icons.error_outline : Icons.info_outline,
                color: error ? cs.onErrorContainer : cs.onTertiaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(text, style: TextStyle(color: error ? cs.onErrorContainer : cs.onTertiaryContainer)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled card grouping parameters on the right side of a tool.
class ParamGroup extends StatelessWidget {
  const ParamGroup({super.key, required this.title, required this.children, this.trailing});
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: t.textTheme.titleSmall?.copyWith(color: t.colorScheme.primary)),
                  ),
                  ?trailing,
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
