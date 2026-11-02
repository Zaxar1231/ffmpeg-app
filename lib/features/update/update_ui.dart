/// App update UI: the bar above every page when an update is found, the
/// "What's new" dialog, and the tile in Settings.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../core/update/app_update.dart';
import '../../core/update/app_updater.dart';
import '../../ui/l10n.dart';
import '../../core/util/format.dart';
import '../../ui/widgets/common.dart' show byteUnits;

/// Shown above the current page while an update is available, downloading
/// or ready to install.
class AppUpdateBar extends ConsumerWidget {
  const AppUpdateBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appUpdateProvider);
    final r = st.update;
    if (r == null ||
        !const [
          UpdatePhase.available,
          UpdatePhase.downloading,
          UpdatePhase.ready,
          UpdatePhase.installing,
        ].contains(st.phase)) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final ctl = ref.read(appUpdateProvider.notifier);
    final text = switch (st.phase) {
      UpdatePhase.downloading => l.updateDownloading(r.version.toString()),
      UpdatePhase.ready => l.updateReady(r.version.toString()),
      UpdatePhase.installing => l.updateInstalling,
      _ => l.appUpdateAvailable(r.version.toString()),
    };
    return Material(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Row(
          children: [
            Icon(Icons.system_update_alt, color: cs.onSecondaryContainer, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text, style: TextStyle(color: cs.onSecondaryContainer)),
                  if (st.phase == UpdatePhase.downloading)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LinearProgressIndicator(value: st.progress?.fraction),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: () => showUpdateDialog(context), child: Text(l.whatsNew)),
            if (st.phase == UpdatePhase.ready)
              FilledButton.icon(
                onPressed: () => confirmInstall(context, ref),
                icon: const Icon(Icons.restart_alt),
                label: Text(l.restartAndUpdate),
              )
            else if (st.phase == UpdatePhase.available)
              FilledButton.tonal(
                onPressed: ctl.canSelfUpdate ? ctl.download : () => launchUrl(Uri.parse(r.pageUrl)),
                child: Text(ctl.canSelfUpdate ? l.download : l.openReleasePage),
              ),
          ],
        ),
      ),
    );
  }
}

/// Installing restarts the app; running jobs would be interrupted.
Future<void> confirmInstall(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final busy = ref.read(queueProvider).activeCount;
  if (busy > 0) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.restartAndUpdate),
        content: Text(l.updateInterruptsJobs(busy)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.restartAndUpdate)),
        ],
      ),
    );
    if (ok != true) return;
    final q = ref.read(queueProvider.notifier);
    await Future.wait([
      for (final i in ref.read(queueProvider).items)
        if (i.isActive) q.cancel(i.id),
    ]);
  }
  await ref.read(appUpdateProvider.notifier).install();
}

Future<void> showUpdateDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _UpdateDialog());

class _UpdateDialog extends ConsumerWidget {
  const _UpdateDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final st = ref.watch(appUpdateProvider);
    final ctl = ref.read(appUpdateProvider.notifier);
    final r = st.update;
    if (r == null) {
      return AlertDialog(
        content: Text(l.updateUpToDate(kAppVersion)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.close))],
      );
    }
    final size = r.asset(assetName(ctl.kind, r.tag))?.size;
    return AlertDialog(
      title: Text(l.updateTitle(r.version.toString())),
      content: SizedBox(
        width: 560,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.updateFromTo(kAppVersion, r.version.toString()) +
                  (size != null ? ' · ${formatBytes(size, units: byteUnits(l))}' : ''),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (r.prerelease) ...[const SizedBox(height: 4), Chip(label: Text(l.channelBeta))],
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: MarkdownLite(combinedNotes(st.releases)),
                ),
              ),
            ),
            if (st.phase == UpdatePhase.downloading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: st.progress?.fraction),
            ],
            if (st.phase == UpdatePhase.error && st.error != null) ...[
              const SizedBox(height: 12),
              Text(l.updateFailed(st.error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (!ctl.canSelfUpdate) ...[const SizedBox(height: 12), Text(l.updateManual)],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ctl.skip();
            Navigator.pop(context);
          },
          child: Text(l.skipVersion),
        ),
        TextButton(onPressed: () => launchUrl(Uri.parse(r.pageUrl)), child: Text(l.openReleasePage)),
        if (st.phase == UpdatePhase.downloading)
          TextButton(onPressed: ctl.cancelDownload, child: Text(l.cancel))
        else if (st.phase == UpdatePhase.ready)
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              unawaited(confirmInstall(context, ref));
            },
            icon: const Icon(Icons.restart_alt),
            label: Text(l.restartAndUpdate),
          )
        else if (ctl.canSelfUpdate)
          FilledButton(onPressed: ctl.download, child: Text(l.download))
        else
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.close)),
      ],
    );
  }
}

/// Current version, last check and a "Check now" button (Settings).
class AppUpdateTile extends ConsumerWidget {
  const AppUpdateTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final st = ref.watch(appUpdateProvider);
    final ctl = ref.read(appUpdateProvider.notifier);
    final status = switch (st.phase) {
      UpdatePhase.checking => l.updateChecking,
      UpdatePhase.upToDate => l.updateUpToDate(kAppVersion),
      UpdatePhase.error => l.updateFailed(st.error ?? ''),
      UpdatePhase.idle => l.updateNotChecked,
      _ => l.appUpdateAvailable(st.update?.version.toString() ?? ''),
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline),
      title: Text(l.appVersionLabel(kAppVersion)),
      subtitle: Text(status),
      trailing: st.update != null
          ? FilledButton.tonal(onPressed: () => showUpdateDialog(context), child: Text(l.whatsNew))
          : OutlinedButton(
              onPressed: st.phase == UpdatePhase.checking ? null : () => ctl.check(manual: true),
              child: Text(l.checkNow),
            ),
    );
  }
}

/// Minimal Markdown for release notes: headings, bullets, `**bold**`,
/// `` `code` ``; links are shown as their text.
class MarkdownLite extends StatelessWidget {
  const MarkdownLite(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final children = <Widget>[];
    for (final raw in text.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }
      final h = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
      if (h != null) {
        final level = h.group(1)!.length;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(_strip(h.group(2)!), style: level <= 2 ? t.titleMedium : t.titleSmall),
          ),
        );
        continue;
      }
      final b = RegExp(r'^(\s*)[-*+]\s+(.*)$').firstMatch(line);
      if (b != null) {
        final indent = b.group(1)!.length ~/ 2;
        children.add(
          Padding(
            padding: EdgeInsets.only(left: 8.0 + indent * 16, top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text.rich(_inline(b.group(2)!, cs))),
              ],
            ),
          ),
        );
        continue;
      }
      children.add(Text.rich(_inline(line, cs)));
    }
    return SelectionArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  static String _strip(String s) =>
      s.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1)!).replaceAll('**', '').replaceAll('`', '');

  static TextSpan _inline(String s, ColorScheme cs) {
    s = s.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1)!);
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
    var i = 0;
    for (final m in re.allMatches(s)) {
      if (m.start > i) spans.add(TextSpan(text: s.substring(i, m.start)));
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: TextStyle(backgroundColor: cs.surfaceContainerHighest),
          ),
        );
      }
      i = m.end;
    }
    if (i < s.length) spans.add(TextSpan(text: s.substring(i)));
    return TextSpan(children: spans);
  }
}
