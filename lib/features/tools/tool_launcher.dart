import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/probe/media_info.dart';
import '../../core/providers.dart';
import '../../ui/l10n.dart';
import '../analysis/integrity.dart';
import '../home/current_file.dart';
import '../shell/app_shell.dart';
import 'tool_catalog.dart';
import 'tool_host.dart';
import 'tool_infra.dart';

/// Starts a tool, optionally for an already opened file.
Future<void> launchTool(BuildContext context, WidgetRef ref, ToolDef tool, {String? path, MediaInfo? info}) async {
  final l = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  if (tool.stage > currentStage) {
    messenger.showSnackBar(SnackBar(content: Text(l.toolComingSoon(tool.stage))));
    return;
  }
  if (tool.id != 'download' && !ref.read(toolchainProvider).hasFfmpeg) {
    messenger.showSnackBar(
      SnackBar(
        persist: false,
        content: Text(l.ffmpegMissingTitle),
        action: SnackBarAction(
          label: l.install,
          onPressed: () => ref.read(navProvider.notifier).go(Destination.components),
        ),
      ),
    );
    return;
  }
  if (screenTools.contains(tool.id)) {
    ref.read(openToolProvider.notifier).open(OpenTool(tool.id, path: path));
    ref.read(navProvider.notifier).go(Destination.tools);
    return;
  }
  switch (tool.id) {
    case 'download':
      ref.read(navProvider.notifier).go(Destination.downloads);
    case 'mediaInfo':
      ref.read(navProvider.notifier).go(Destination.home);
      if (path != null) {
        await ref.read(currentFileProvider.notifier).open(path);
      } else {
        await ref.read(currentFileProvider.notifier).pickAndOpen();
      }
    case 'integrity':
      var file = path;
      if (file == null) {
        final f = await openFile();
        if (f == null) return;
        file = f.path;
      }
      final duration = info?.duration;
      await ref
          .read(queueProvider.notifier)
          .enqueue(integrityJob(file, duration: duration, title: '${l.toolIntegrity}: ${displayName(file)}'));
      messenger.showSnackBar(
        SnackBar(
          persist: false,
          content: Text(l.addedToQueue),
          action: SnackBarAction(
            label: l.openQueue,
            onPressed: () => ref.read(navProvider.notifier).go(Destination.queue),
          ),
        ),
      );
  }
}
