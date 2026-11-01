import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/current_file.dart';
import '../../core/engine/capabilities.dart';
import '../../core/providers.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import 'tool_catalog.dart';
import 'tool_host.dart';
import 'tool_infra.dart';
import 'tool_launcher.dart';

class ToolsPage extends ConsumerStatefulWidget {
  const ToolsPage({super.key});

  @override
  ConsumerState<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends ConsumerState<ToolsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final open = ref.watch(openToolProvider);
    if (open != null) return ToolHost(tool: open);
    final l = context.l10n;
    final caps = ref.watch(capabilitiesProvider).value ?? FfmpegCapabilities.empty;
    final q = _search.text;
    final groups = <ToolCategory, List<ToolDef>>{};
    for (final t in toolCatalog.where((t) => toolMatches(l, t, q))) {
      groups.putIfAbsent(t.category, () => []).add(t);
    }

    return PageFrame(
      title: l.navTools,
      maxWidth: 1400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SearchBar(
              controller: _search,
              hintText: l.toolsSearchHint,
              leading: const Icon(Icons.search),
              trailing: [
                if (q.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(_search.clear)),
              ],
              onChanged: (_) => setState(() {}),
              elevation: const WidgetStatePropertyAll(0),
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? EmptyState(icon: Icons.search_off, title: l.nothingFound)
                : CustomScrollView(
                    slivers: [
                      for (final e in groups.entries) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              categoryTitle(l, e.key),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 340,
                              mainAxisExtent: 148,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildListDelegate([
                              for (final t in e.value) _ToolCard(tool: t, caps: caps),
                            ]),
                          ),
                        ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends ConsumerWidget {
  const _ToolCard({required this.tool, required this.caps});
  final ToolDef tool;
  final FfmpegCapabilities caps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final soon = !toolReady(tool);
    final missing = tool.missingIn(caps);
    return Opacity(
      opacity: soon ? 0.6 : 1,
      child: Card.filled(
        color: t.colorScheme.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // The file opened on Home (if any) is used by the tool.
          onTap: () => launchTool(context, ref, tool, path: ref.read(currentFileProvider)?.path),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(tool.icon, color: t.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        toolTitle(l, tool.id),
                        style: t.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    toolDescription(l, tool.id),
                    style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (soon) TagChip(l.stageLabel(tool.stage), icon: Icons.schedule),
                    if (tool.lossless) TagChip(l.losslessTag, icon: Icons.bolt, color: t.colorScheme.tertiaryContainer),
                    if (missing.isNotEmpty)
                      Tooltip(
                        message: l.needsBuildTooltip(missing.join(', ')),
                        child: TagChip(
                          l.needsOtherBuild,
                          icon: Icons.warning_amber,
                          color: t.colorScheme.errorContainer,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
