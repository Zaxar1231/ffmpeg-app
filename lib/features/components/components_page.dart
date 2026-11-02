import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../core/components/models.dart';
import '../audio/audio_file_pages.dart' show ModelsCard;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/components/catalog.dart';
import '../../core/components/component_store.dart';
import '../../core/components/components_controller.dart';
import '../../core/components/toolchain.dart';
import '../../core/engine/hwaccel.dart';
import '../../core/platform/host.dart';
import '../../core/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/util/format.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';

class ComponentsPage extends ConsumerWidget {
  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(componentsProvider);
    final host = HostPlatform.current;
    return PageFrame(
      title: l.navComponents,
      actions: [
        if (state.lastCheck != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              l.lastChecked(DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(state.lastCheck!)),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        FilledButton.tonalIcon(
          onPressed: state.checking ? null : () => ref.read(componentsProvider.notifier).checkUpdates(),
          icon: state.checking
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.update),
          label: Text(l.checkUpdates),
        ),
      ],
      child: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                const _ComponentCard(id: ComponentId.ffmpeg),
                const _BuildInfoCard(),
                const _HwAccelCard(),
                const _ComponentCard(id: ComponentId.ytdlp),
                const _ComponentCard(id: ComponentId.deno),
                if (host.isWindows)
                  const _ComponentCard(id: ComponentId.aria2)
                else
                  const _SystemOnlyCard(id: ComponentId.aria2),
                const ModelsCard(kind: ModelKind.rnnoise),
                const ModelsCard(kind: ModelKind.whisper),
                const _PlannedComponents(),
              ],
            ),
    );
  }
}

String componentTitle(AppLocalizations l, ComponentId id) => switch (id) {
  ComponentId.ffmpeg => l.compFfmpeg,
  ComponentId.ytdlp => l.compYtdlp,
  ComponentId.deno => l.compDeno,
  ComponentId.aria2 => l.compAria2,
};

String componentDescription(AppLocalizations l, ComponentId id) => switch (id) {
  ComponentId.ffmpeg => l.compFfmpegDesc,
  ComponentId.ytdlp => l.compYtdlpDesc,
  ComponentId.deno => l.compDenoDesc,
  ComponentId.aria2 => l.compAria2Desc,
};

String originLabel(AppLocalizations l, ToolOrigin o) => switch (o) {
  ToolOrigin.custom => l.originCustom,
  ToolOrigin.managed => l.originManaged,
  ToolOrigin.system => l.originSystem,
  ToolOrigin.none => l.originNone,
};

String sourceLabel(AppLocalizations l, ComponentSource s) => switch (s) {
  ComponentSource.btbn => 'BtbN (GitHub)',
  ComponentSource.gyan => 'gyan.dev',
  ComponentSource.ytdlp => 'yt-dlp (GitHub)',
  ComponentSource.deno => 'Deno (GitHub)',
  ComponentSource.aria2 => 'aria2 (GitHub)',
};

ToolPath _toolPathFor(Toolchain tc, ComponentId id) => switch (id) {
  ComponentId.ffmpeg => tc.ffmpeg,
  ComponentId.ytdlp => tc.ytdlp,
  ComponentId.deno => tc.deno,
  ComponentId.aria2 => tc.aria2c,
};

class _ComponentCard extends ConsumerWidget {
  const _ComponentCard({required this.id});
  final ComponentId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final state = ref.watch(componentsProvider);
    final ctl = ref.read(componentsProvider.notifier);
    final tool = _toolPathFor(ref.watch(toolchainProvider), id);
    final rec = state.records[id] ?? const ComponentRecord();
    final active = rec.activeInstall;
    final task = state.tasks[id];
    final latest = state.latest[id];
    final error = state.errors[id];
    final update = state.updateAvailable(id);

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.extension, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(componentTitle(l, id), style: t.textTheme.titleMedium),
                          const SizedBox(width: 8),
                          TagChip(
                            originLabel(l, tool.origin),
                            color: tool.available ? cs.secondaryContainer : cs.errorContainer,
                            icon: tool.available ? Icons.check_circle_outline : Icons.cancel_outlined,
                          ),
                          if (update) ...[
                            const SizedBox(width: 6),
                            TagChip(l.updateAvailable, icon: Icons.upgrade, color: cs.tertiaryContainer),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        componentDescription(l, id),
                        style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tool.path != null) InfoRow(l.inUse, tool.path!, selectable: true),
            if (active != null) ...[
              InfoRow(l.installedVersion, active.version ?? '—'),
              InfoRow(
                l.sourceLabel,
                [sourceLabel(l, active.source), active.variant, active.channel.name].whereType<String>().join(' · '),
              ),
            ],
            if (latest != null)
              InfoRow(
                l.latestAvailable,
                '${latest.versionLabel ?? latest.fileName}${latest.sha256 == null ? '  (${l.noChecksum})' : ''}',
              ),
            if (id == ComponentId.ffmpeg) const _FfmpegSourceOptions(),
            if (id == ComponentId.ytdlp) const _YtdlpOptions(),
            const SizedBox(height: 12),
            if (task != null)
              _TaskProgress(task: task, onCancel: () => ctl.cancel(id))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (active == null)
                    FilledButton.icon(
                      onPressed: () => ctl.install(id),
                      icon: const Icon(Icons.download),
                      label: Text(l.install),
                    )
                  else if (update)
                    FilledButton.icon(
                      onPressed: () => ctl.install(id, spec: latest),
                      icon: const Icon(Icons.upgrade),
                      label: Text(l.update),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => ctl.install(id),
                      icon: const Icon(Icons.refresh),
                      label: Text(l.reinstall),
                    ),
                  if (rec.previous.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => ctl.rollback(id),
                      icon: const Icon(Icons.history),
                      label: Text(l.rollback),
                    ),
                  if (rec.installs.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        final ok = await _confirm(context, l.removeComponentConfirm(componentTitle(l, id)));
                        if (ok) await ctl.uninstall(id);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l.remove),
                    ),
                ],
              ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(l.componentError(error), style: t.textTheme.bodySmall?.copyWith(color: cs.error)),
            ],
            if (rec.installs.length > 1 || (rec.installs.length == 1 && rec.active == null))
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(l.versionHistory(rec.installs.length)),
                children: [for (final v in rec.installs) _VersionRow(id: id, version: v, active: v.key == rec.active)],
              ),
            if (id == ComponentId.ffmpeg || id == ComponentId.ytdlp) _CustomPathRow(id: id),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirm(BuildContext context, String text) async {
  final l = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(text),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.remove)),
          ],
        ),
      ) ??
      false;
}

class _TaskProgress extends StatelessWidget {
  const _TaskProgress({required this.task, required this.onCancel});
  final ComponentTask task;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final phase = switch (task.phase) {
      TaskPhase.resolving => l.phaseResolving,
      TaskPhase.downloading => l.phaseDownloading,
      TaskPhase.verifying => l.phaseVerifying,
      TaskPhase.extracting => l.phaseExtracting,
      TaskPhase.testing => l.phaseTesting,
    };
    final pct = task.progress == null ? '' : ' ${(task.progress! * 100).toStringAsFixed(0)}%';
    final speed = task.bytesPerSecond == null || task.bytesPerSecond == 0
        ? ''
        : ' · ${formatBytes(task.bytesPerSecond!.round(), units: byteUnits(l))}/${l.unitSecond}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$phase$pct$speed', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: task.phase == TaskPhase.downloading ? task.progress : null),
            ],
          ),
        ),
        if (task.phase == TaskPhase.downloading || task.phase == TaskPhase.resolving)
          TextButton(onPressed: onCancel, child: Text(l.cancel)),
      ],
    );
  }
}

class _VersionRow extends ConsumerWidget {
  const _VersionRow({required this.id, required this.version, required this.active});
  final ComponentId id;
  final InstalledVersion version;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final ctl = ref.read(componentsProvider.notifier);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(active ? Icons.radio_button_checked : Icons.radio_button_off),
      title: Text(version.version ?? version.key),
      subtitle: Text(
        '${sourceLabel(l, version.source)} · ${version.variant ?? ''} · ${DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).add_Hm().format(version.installedAt)}',
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (!active) TextButton(onPressed: () => ctl.activate(id, version.key), child: Text(l.activate)),
          if (!active)
            IconButton(
              tooltip: l.remove,
              onPressed: () => ctl.removeVersion(id, version.key),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}

class _FfmpegSourceOptions extends ConsumerWidget {
  const _FfmpegSourceOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final set = ref.read(settingsProvider.notifier);
    final win = HostPlatform.current.isWindows;
    final gyan = win && s.ffmpegSource == FfmpegSourcePref.gyan;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (win)
            SegmentedButton<FfmpegSourcePref>(
              segments: const [
                ButtonSegment(value: FfmpegSourcePref.btbn, label: Text('BtbN')),
                ButtonSegment(value: FfmpegSourcePref.gyan, label: Text('gyan.dev')),
              ],
              selected: {s.ffmpegSource},
              onSelectionChanged: (v) => set.update((x) => x.copyWith(ffmpegSource: v.first)),
            ),
          if (gyan)
            SegmentedButton<GyanFlavor>(
              segments: [
                ButtonSegment(value: GyanFlavor.full, label: Text(l.flavorFull)),
                ButtonSegment(value: GyanFlavor.essentials, label: Text(l.flavorEssentials)),
              ],
              selected: {s.gyanFlavor},
              onSelectionChanged: (v) => set.update((x) => x.copyWith(gyanFlavor: v.first)),
            )
          else ...[
            SegmentedButton<FfmpegLicense>(
              segments: const [
                ButtonSegment(value: FfmpegLicense.gpl, label: Text('GPL')),
                ButtonSegment(value: FfmpegLicense.lgpl, label: Text('LGPL')),
              ],
              selected: {s.ffmpegLicense},
              onSelectionChanged: (v) => set.update((x) => x.copyWith(ffmpegLicense: v.first)),
            ),
            SegmentedButton<UpdateChannel>(
              segments: [
                ButtonSegment(value: UpdateChannel.stable, label: Text(l.channelRelease)),
                ButtonSegment(value: UpdateChannel.nightly, label: Text(l.channelNightly)),
              ],
              selected: {s.ffmpegChannel},
              onSelectionChanged: (v) => set.update((x) => x.copyWith(ffmpegChannel: v.first)),
            ),
          ],
          Text(gyan ? l.gyanHint : l.btbnHint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _YtdlpOptions extends ConsumerWidget {
  const _YtdlpOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          SegmentedButton<UpdateChannel>(
            segments: [
              ButtonSegment(value: UpdateChannel.stable, label: Text(l.channelStable)),
              ButtonSegment(value: UpdateChannel.nightly, label: Text(l.channelNightly)),
            ],
            selected: {s.ytdlpChannel},
            onSelectionChanged: (v) =>
                ref.read(settingsProvider.notifier).update((x) => x.copyWith(ytdlpChannel: v.first)),
          ),
        ],
      ),
    );
  }
}

class _CustomPathRow extends ConsumerWidget {
  const _CustomPathRow({required this.id});
  final ComponentId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final set = ref.read(settingsProvider.notifier);
    final value = id == ComponentId.ffmpeg ? s.customFfmpegPath : s.customYtdlpPath;
    void save(String? v) => set.update(
      (x) => id == ComponentId.ffmpeg
          ? x.copyWith(customFfmpegPath: () => v, customFfprobePath: () => null)
          : x.copyWith(customYtdlpPath: () => v),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value == null ? l.customPathNone : l.customPathValue(value),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              final f = await openFile(confirmButtonText: l.choose);
              if (f != null) save(f.path);
            },
            icon: const Icon(Icons.file_open_outlined),
            label: Text(l.useCustomBinary),
          ),
          if (value != null)
            IconButton(tooltip: l.resetTooltip, onPressed: () => save(null), icon: const Icon(Icons.clear)),
        ],
      ),
    );
  }
}

class _SystemOnlyCard extends ConsumerWidget {
  const _SystemOnlyCard({required this.id});
  final ComponentId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tool = _toolPathFor(ref.watch(toolchainProvider), id);
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.extension_outlined),
        title: Text(componentTitle(l, id)),
        subtitle: Text(
          tool.available
              ? '${componentDescription(l, id)}\n${tool.path}'
              : '${componentDescription(l, id)}\n${l.installViaPackageManager('aria2')}',
        ),
        isThreeLine: true,
        trailing: TagChip(originLabel(l, tool.origin)),
      ),
    );
  }
}

class _BuildInfoCard extends ConsumerWidget {
  const _BuildInfoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final caps = ref.watch(capabilitiesProvider);
    return caps.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (c) {
        if (c.version == null) return const SizedBox.shrink();
        Widget listButton(String label, int count, Iterable<(String, String)> items) => ActionChip(
          label: Text('$label: $count'),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => _SearchListDialog(title: label, items: items.toList()),
          ),
        );
        return Card.outlined(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.buildInfoTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                InfoRow(l.infoVersion, c.version!),
                InfoRow(l.licenseLabel, c.isGpl ? 'GPL' : 'LGPL'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    listButton(l.encoders, c.encoders.length, c.encoders.values.map((e) => (e.name, e.description))),
                    listButton(l.decoders, c.decoders.length, c.decoders.values.map((e) => (e.name, e.description))),
                    listButton(
                      l.filters,
                      c.filters.length,
                      c.filters.values.map((e) => (e.name, '${e.io}  ${e.description}')),
                    ),
                    listButton(l.muxers, c.muxers.length, c.muxers.entries.map((e) => (e.key, e.value))),
                    listButton(l.configuration, c.configuration.length, c.configuration.map((e) => (e, ''))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchListDialog extends StatefulWidget {
  const _SearchListDialog({required this.title, required this.items});
  final String title;
  final List<(String, String)> items;

  @override
  State<_SearchListDialog> createState() => _SearchListDialogState();
}

class _SearchListDialogState extends State<_SearchListDialog> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = _q.toLowerCase();
    final items = widget.items
        .where((i) => q.isEmpty || i.$1.toLowerCase().contains(q) || i.$2.toLowerCase().contains(q))
        .toList();
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 640,
        height: 480,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.search),
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(items[i].$1, style: const TextStyle(fontFamily: 'monospace')),
                  subtitle: items[i].$2.isEmpty ? null : Text(items[i].$2),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.close))],
    );
  }
}

class _HwAccelCard extends ConsumerWidget {
  const _HwAccelCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hasFfmpeg = ref.watch(toolchainProvider.select((t) => t.ffmpeg.available));
    if (!hasFfmpeg) return const SizedBox.shrink();
    final hw = ref.watch(hwAccelProvider);
    final t = Theme.of(context);
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.memory, color: t.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(l.hwTitle, style: t.textTheme.titleMedium)),
                TextButton.icon(
                  onPressed: hw.isLoading ? null : () => ref.read(hwAccelProvider.notifier).redetect(),
                  icon: const Icon(Icons.refresh),
                  label: Text(l.redetect),
                ),
              ],
            ),
            const SizedBox(height: 8),
            hw.when(
              loading: () => Row(
                children: [
                  const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text(l.hwDetecting),
                ],
              ),
              error: (e, _) => Text('$e', style: TextStyle(color: t.colorScheme.error)),
              data: (r) {
                final win = HostPlatform.current.isWindows;
                String best(VideoCodecFamily f) => r.bestFor(f)?.name ?? l.hwSoftwareOnly;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InfoRow(l.hwDecode, r.hwaccels.isEmpty ? '—' : r.hwaccels.join(', ')),
                    InfoRow(l.hwBestDecode, r.bestDecode(windows: win) ?? l.hwSoftwareOnly),
                    InfoRow(
                      l.hwEncoders,
                      r.working.isEmpty ? l.hwNoneWorking : r.working.map((e) => e.name).join(', '),
                    ),
                    InfoRow('H.264', best(VideoCodecFamily.h264)),
                    InfoRow('H.265 / HEVC', best(VideoCodecFamily.hevc)),
                    InfoRow('AV1', best(VideoCodecFamily.av1)),
                    if (r.failed.isNotEmpty)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(l.hwFailed(r.failed.length)),
                        children: [
                          for (final e in r.failed.entries)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(e.key),
                              subtitle: Text(e.value),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannedComponents extends StatelessWidget {
  const _PlannedComponents();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (Icons.noise_aware, l.compRnnoise, 3),
      (Icons.compare, l.compVmaf, 3),
      (Icons.record_voice_over_outlined, l.compWhisper, 3),
      (Icons.auto_awesome, l.compFrei0r, 3),
      (Icons.palette_outlined, l.compLuts, 3),
      (Icons.font_download_outlined, l.compFonts, 4),
    ];
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.plannedComponents, style: Theme.of(context).textTheme.titleMedium),
            for (final (icon, title, stage) in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon),
                title: Text(title),
                trailing: TagChip(l.stageLabel(stage)),
              ),
          ],
        ),
      ),
    );
  }
}
