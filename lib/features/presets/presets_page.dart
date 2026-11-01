import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/presets/preset_repository.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../convert/builtin_presets.dart';
import '../convert/convert_page.dart' show promptText;
import '../convert/convert_params.dart';
import '../convert/labels.dart';
import '../shell/app_shell.dart';
import '../tools/tool_infra.dart';

/// Built-in and user presets: apply, rename, delete, import/export JSON.
class PresetsPage extends ConsumerWidget {
  const PresetsPage({super.key});

  String _summary(AppLocalizations l, ConvertParams p) => [
    p.container.toUpperCase(),
    videoCodecLabel(l, p.video),
    if (p.rateMode == RateMode.targetSize) '≤ ${formatFps(p.targetSizeMb)} ${l.unitMB}',
    if (p.maxHeight != null) '${p.maxHeight}p',
    audioCodecLabel(l, p.audio),
  ].join(' · ');

  void _apply(WidgetRef ref, String presetId) {
    ref.read(openToolProvider.notifier).open(OpenTool('convert', presetId: presetId));
    ref.read(navProvider.notifier).go(Destination.tools);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.read(presetRepositoryProvider);
    final user = ref.watch(userPresetsProvider(null)).value ?? const <UserPreset>[];
    final messenger = ScaffoldMessenger.of(context);

    return PageFrame(
      title: l.navPresets,
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.file_upload_outlined),
          label: Text(l.importPresets),
          onPressed: () async {
            final f = await openFile(
              acceptedTypeGroups: const [
                XTypeGroup(label: 'JSON', extensions: ['json']),
              ],
            );
            if (f == null) return;
            try {
              final n = await repo.importText(await File(f.path).readAsString());
              messenger.showSnackBar(SnackBar(content: Text(l.presetsImported(n))));
            } on FormatException {
              messenger.showSnackBar(SnackBar(content: Text(l.presetsImportFailed)));
            }
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.file_download_outlined),
          label: Text(l.exportPresets),
          onPressed: user.isEmpty
              ? null
              : () async {
                  final loc = await getSaveLocation(suggestedName: 'kadra-presets.json');
                  if (loc == null) return;
                  await File(loc.path).writeAsString(exportPresets(user));
                  messenger.showSnackBar(SnackBar(content: Text(l.presetsExported(user.length))));
                },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Text(l.builtinPresets, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final bp in builtinPresets)
            Card.outlined(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(presetName(l, bp.id)),
                subtitle: Text('${presetDescription(l, bp.id)}\n${_summary(l, bp.params)}'),
                isThreeLine: true,
                trailing: FilledButton.tonal(onPressed: () => _apply(ref, bp.id), child: Text(l.apply)),
              ),
            ),
          const SizedBox(height: 16),
          Text(l.userPresets, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (user.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(l.userPresetsEmpty))
          else
            for (final up in user)
              Card.outlined(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(up.name),
                  subtitle: up.toolId == 'convert'
                      ? Text(_summary(l, ConvertParams.fromJson(up.params)))
                      : Text(up.toolId),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: l.rename,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final n = await promptText(
                            context,
                            title: l.rename,
                            label: l.presetNameLabel,
                            initial: up.name,
                          );
                          if (n != null && n.trim().isNotEmpty) await repo.rename(up.id, n.trim());
                        },
                      ),
                      IconButton(
                        tooltip: l.remove,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => repo.delete(up.id),
                      ),
                      FilledButton.tonal(onPressed: () => _apply(ref, 'user:${up.id}'), child: Text(l.apply)),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
