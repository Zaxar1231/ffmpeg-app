import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/engine/error_translator.dart';
import '../../core/providers.dart';
import '../../core/queue/queue_models.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../tools/command_text.dart';

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final q = ref.watch(queueProvider);
    final parallel = ref.watch(settingsProvider.select((s) => s.maxParallelJobs));
    // Active first, then queued, then history (newest first).
    final active = q.items.where((i) => i.isActive).toList();
    final queued = q.items.where((i) => i.status == JobStatus.queued).toList()
      ..sort(
        (a, b) => b.job.priority != a.job.priority
            ? b.job.priority - a.job.priority
            : a.job.createdAt.compareTo(b.job.createdAt),
      );
    final done = q.items.where((i) => i.isFinished).toList()
      ..sort((a, b) => (b.job.finishedAt ?? b.job.createdAt).compareTo(a.job.finishedAt ?? a.job.createdAt));

    return PageFrame(
      title: l.navQueue,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(l.parallelJobsShort(parallel), style: Theme.of(context).textTheme.labelLarge),
        ),
        if (done.isNotEmpty)
          TextButton.icon(
            onPressed: () => ref.read(queueProvider.notifier).clearFinished(),
            icon: const Icon(Icons.clear_all),
            label: Text(l.clearFinished),
          ),
      ],
      child: !q.loaded
          ? const Center(child: CircularProgressIndicator())
          : q.items.isEmpty
          ? EmptyState(icon: Icons.queue_play_next, title: l.queueEmptyTitle, message: l.queueEmptyBody)
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                if (active.isNotEmpty || queued.isNotEmpty) _header(context, l.queueActive),
                for (final i in [...active, ...queued]) _JobCard(item: i),
                if (done.isNotEmpty) _header(context, l.queueHistory),
                for (final i in done) _JobCard(item: i),
              ],
            ),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class _JobCard extends ConsumerWidget {
  const _JobCard({required this.item});
  final QueueItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = item.progress;
    final job = item.job;
    final findings = item.extra['findings'] as int?;

    final (statusText, statusColor, statusIcon) = switch (item.status) {
      JobStatus.queued => (l.statusQueued, cs.secondaryContainer, Icons.schedule),
      JobStatus.running => (l.statusRunning, cs.primaryContainer, Icons.play_arrow),
      JobStatus.paused => (l.statusPaused, cs.tertiaryContainer, Icons.pause),
      JobStatus.completed => (
        findings == null
            ? l.statusCompleted
            : (findings > 0 ? l.statusCompletedWithFindings(findings) : l.statusNoProblems),
        findings != null && findings > 0 ? cs.tertiaryContainer : cs.primaryContainer,
        findings != null && findings > 0 ? Icons.report_outlined : Icons.check,
      ),
      JobStatus.failed => (l.statusFailed, cs.errorContainer, Icons.error_outline),
      JobStatus.canceled => (l.statusCanceled, cs.surfaceContainerHighest, Icons.block),
    };

    String? errorText;
    if (item.status == JobStatus.failed && job.errorKind != null) {
      final kind = ToolErrorKind.values.where((k) => k.name == job.errorKind).firstOrNull ?? ToolErrorKind.unknown;
      errorText = toolErrorText(l, kind, job.errorDetail);
    }

    final steps = item.isActive ? item.steps : const [];
    final stats = <String>[
      if (steps.length > 1)
        l.stepLabel(steps[item.step.clamp(0, steps.length - 1)].label ?? '${item.step + 1}/${steps.length}'),
      if (p?.fraction != null) '${(p!.fraction! * 100).toStringAsFixed(1)}%',
      if (p?.downloadedBytes != null)
        '${formatBytes(p!.downloadedBytes, units: byteUnits(l))}${p.totalBytes != null ? ' / ${formatBytes(p.totalBytes, units: byteUnits(l))}' : ''}',
      if (p?.bytesPerSecond != null) '${formatBytes(p!.bytesPerSecond!.round(), units: byteUnits(l))}/${l.unitSecond}',
      if (p?.outTime != null)
        '${formatDuration(p!.outTime)}${item.totalDuration != null ? ' / ${formatDuration(item.totalDuration)}' : ''}',
      if (p?.fps != null && p!.fps! > 0) '${p.fps!.toStringAsFixed(0)} ${l.unitFps}',
      if (p?.speed != null) '${p!.speed!.toStringAsFixed(2)}×',
      if (p?.bitrateKbps != null) '${p!.bitrateKbps!.round()} ${l.unitKbps}',
      if (p?.eta != null && item.status == JobStatus.running) l.etaLabel(formatDuration(p!.eta)),
    ];

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                TagChip(statusText, icon: statusIcon, color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(job.title, style: t.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (job.priority > 0 && !item.isFinished)
                  Tooltip(
                    message: l.priorityHigh,
                    child: Icon(Icons.priority_high, size: 18, color: cs.primary),
                  ),
                ..._actions(context, ref, l),
              ],
            ),
            if (item.isActive) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(value: p?.fraction, borderRadius: BorderRadius.circular(4)),
            ],
            if (stats.isNotEmpty && item.isActive) ...[
              const SizedBox(height: 6),
              Text(stats.join('  ·  '), style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
            if (item.isFinished) ...[
              const SizedBox(height: 6),
              Text(
                [
                  if (job.finishedAt != null && job.startedAt != null)
                    l.tookLabel(formatDuration(job.finishedAt!.difference(job.startedAt!))),
                  if (job.outputSize != null) formatBytes(job.outputSize, units: byteUnits(l)),
                  if (job.attempts > 1) l.attemptsLabel(job.attempts),
                ].join('  ·  '),
                style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Text(errorText, style: t.textTheme.bodyMedium?.copyWith(color: cs.error)),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final c = ref.read(queueProvider.notifier);
    final job = item.job;
    final out = job.outputPath;
    return [
      if (item.status == JobStatus.running && c.canPause)
        IconButton(tooltip: l.pause, icon: const Icon(Icons.pause), onPressed: () => c.pause(item.id)),
      if (item.status == JobStatus.paused)
        IconButton(tooltip: l.resume, icon: const Icon(Icons.play_arrow), onPressed: () => c.resume(item.id)),
      if (item.status == JobStatus.queued)
        IconButton(
          tooltip: job.priority > 0 ? l.priorityNormal : l.priorityRaise,
          icon: Icon(job.priority > 0 ? Icons.arrow_downward : Icons.arrow_upward),
          onPressed: () => c.setPriority(item.id, job.priority > 0 ? 0 : 10),
        ),
      if (!item.isFinished)
        IconButton(tooltip: l.cancel, icon: const Icon(Icons.stop_circle_outlined), onPressed: () => c.cancel(item.id)),
      if (item.status == JobStatus.failed || item.status == JobStatus.canceled)
        IconButton(tooltip: l.retry, icon: const Icon(Icons.replay), onPressed: () => c.retry(item.id)),
      if (item.status == JobStatus.completed && out != null)
        IconButton(
          tooltip: l.openFolder,
          icon: const Icon(Icons.folder_open),
          onPressed: () => openContainingFolder(out),
        ),
      PopupMenuButton<String>(
        tooltip: l.more,
        onSelected: (v) async {
          switch (v) {
            case 'log':
              final log = item.isActive ? item.attemptLog.join('\n') : (job.log ?? '');
              await showTextDialog(context, title: l.logTitle, text: log);
            case 'cmd':
              await showTextDialog(
                context,
                title: l.commandTitle,
                text: stepsCommandText(item.steps, ref.read(toolchainProvider)),
              );
            case 'remove':
              await c.remove(item.id);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'log',
            child: ListTile(leading: const Icon(Icons.article_outlined), title: Text(l.showLog)),
          ),
          PopupMenuItem(
            value: 'cmd',
            child: ListTile(leading: const Icon(Icons.terminal), title: Text(l.showCommand)),
          ),
          if (!item.isActive)
            PopupMenuItem(
              value: 'remove',
              child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l.removeFromList)),
            ),
        ],
      ),
    ];
  }
}

/// Opens the folder containing [path] in the system file manager.
Future<void> openContainingFolder(String path) async {
  final dir = FileSystemEntity.isDirectorySync(path) ? path : File(path).parent.path;
  if (Platform.isWindows && File(path).existsSync()) {
    // Explorer can highlight the file itself.
    await Process.start('explorer.exe', ['/select,', path]);
    return;
  }
  await launchUrl(Uri.directory(dir));
}
