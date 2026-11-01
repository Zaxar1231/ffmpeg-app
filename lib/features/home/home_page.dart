import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/engine/error_translator.dart';
import '../../core/probe/media_info.dart';
import '../../core/probe/probe_service.dart';
import '../../core/providers.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/media_preview.dart';
import '../analysis/media_info_view.dart';
import '../shell/app_shell.dart';
import '../tools/tool_catalog.dart';
import '../tools/tool_launcher.dart';
import 'current_file.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = ref.watch(currentFileProvider);
    final comps = ref.watch(componentsProvider);
    final hasFfmpeg = ref.watch(toolchainProvider.select((t) => t.hasFfmpeg));

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (d) {
        setState(() => _dragging = false);
        if (d.files.isNotEmpty) ref.read(currentFileProvider.notifier).open(d.files.first.path);
      },
      child: PageFrame(
        title: current == null ? l.homeTitle : p.basename(current.path),
        actions: [
          if (current != null) ...[
            IconButton(
              tooltip: l.reload,
              onPressed: () => ref.read(currentFileProvider.notifier).reload(),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: l.closeFile,
              onPressed: () => ref.read(currentFileProvider.notifier).clear(),
              icon: const Icon(Icons.close),
            ),
          ],
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () => ref.read(currentFileProvider.notifier).pickAndOpen(),
            icon: const Icon(Icons.folder_open),
            label: Text(l.openFile),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (comps.loaded && !hasFfmpeg) const _FfmpegMissingBanner(),
            Expanded(
              child: current == null
                  ? _DropZone(active: _dragging)
                  : Stack(
                      children: [
                        _FileView(current: current),
                        if (_dragging) Positioned.fill(child: _DropZone(active: true, overlay: true)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FfmpegMissingBanner extends ConsumerWidget {
  const _FfmpegMissingBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Card.filled(
        color: cs.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.onErrorContainer),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.ffmpegMissingTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.onErrorContainer),
                    ),
                    Text(l.ffmpegMissingBody, style: TextStyle(color: cs.onErrorContainer)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: () => ref.read(navProvider.notifier).go(Destination.components),
                child: Text(l.openComponents),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropZone extends ConsumerWidget {
  const _DropZone({required this.active, this.overlay = false});
  final bool active;
  final bool overlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: active ? cs.primaryContainer.withValues(alpha: overlay ? 0.92 : 0.6) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: active ? cs.primary : cs.outlineVariant, width: active ? 3 : 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => ref.read(currentFileProvider.notifier).pickAndOpen(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: active ? 1.15 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.file_download_outlined, size: 72, color: cs.primary),
                ),
                const SizedBox(height: 16),
                Text(l.dropTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  l.dropSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  l.shortcutOpenHint,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FileView extends ConsumerWidget {
  const _FileView({required this.current});
  final CurrentFile current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return current.info.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: l.probeFailed,
        message: _probeErrorText(l, e),
        action: FilledButton.tonal(
          onPressed: () => ref.read(currentFileProvider.notifier).pickAndOpen(),
          child: Text(l.openAnother),
        ),
      ),
      data: (info) => LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 900;
          final preview = (info.category == MediaCategory.video || info.category == MediaCategory.audio)
              ? MediaPreview(path: info.path, aspectRatio: info.category == MediaCategory.audio ? 16 / 5 : 16 / 9)
              : null;
          final actions = _QuickActions(info: info);
          final details = MediaInfoView(info: info);
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
                    children: [?preview, const SizedBox(height: 16), actions],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 24, 24), children: [details]),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [?preview, const SizedBox(height: 16), actions, const SizedBox(height: 16), details],
          );
        },
      ),
    );
  }
}

String _probeErrorText(AppLocalizations l, Object e) {
  final raw = e is ProbeException ? '${e.message}\n${e.log}' : e.toString();
  final err = translateToolError(raw.split('\n'), startError: e is ProbeException && e.toolMissing ? e.message : null);
  return err.kind == ToolErrorKind.unknown ? raw.trim() : toolErrorText(l, err.kind, err.detail);
}

/// Smart quick actions depending on what the file is.
class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.info});
  final MediaInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tools = toolCatalog.where((t) => t.forKinds.contains(info.category)).toList()
      ..sort((a, b) => a.stage.compareTo(b.stage));
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.quickActions, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in tools)
                  Tooltip(
                    message: !toolReady(t) ? l.toolComingSoon(t.stage) : toolDescription(l, t.id),
                    child: ActionChip(
                      avatar: Icon(t.icon, size: 18),
                      label: Text(toolTitle(l, t.id)),
                      onPressed: !toolReady(t) ? null : () => launchTool(context, ref, t, path: info.path, info: info),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
