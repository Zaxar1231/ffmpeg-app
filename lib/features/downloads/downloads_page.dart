import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../shell/app_shell.dart';

/// yt-dlp downloads arrive in stage 2; for now show readiness of the tool.
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final ytdlp = ref.watch(toolchainProvider.select((t) => t.ytdlp));
    return PageFrame(
      title: l.navDownloads,
      child: EmptyState(
        icon: Icons.cloud_download_outlined,
        title: l.downloadsSoonTitle,
        message: ytdlp.available ? l.downloadsReady(ytdlp.path!) : l.downloadsNeedYtdlp,
        action: ytdlp.available
            ? null
            : FilledButton(
                onPressed: () => ref.read(navProvider.notifier).go(Destination.components),
                child: Text(l.openComponents),
              ),
      ),
    );
  }
}
