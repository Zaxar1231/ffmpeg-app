import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/catalog.dart';
import '../../core/providers.dart';
import '../../ui/l10n.dart';
import '../components/components_page.dart';
import '../downloads/downloads_page.dart';
import '../home/current_file.dart';
import '../home/home_page.dart';
import '../presets/presets_page.dart';
import '../queue/queue_page.dart';
import '../settings/settings_page.dart';
import '../tools/tools_page.dart';

enum Destination { home, tools, downloads, queue, presets, components, settings }

class NavController extends Notifier<Destination> {
  @override
  Destination build() => Destination.home;
  void go(Destination d) => state = d;
}

final navProvider = NotifierProvider<NavController, Destination>(NavController.new);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final current = ref.watch(navProvider);
    final queue = ref.watch(queueProvider);
    final comps = ref.watch(componentsProvider);
    final updates = ComponentId.values.where(comps.updateAvailable).length;
    final hasFfmpeg = ref.watch(toolchainProvider.select((t) => t.hasFfmpeg));

    final dests = <(Destination, IconData, IconData, String, String?)>[
      (Destination.home, Icons.home_outlined, Icons.home, l.navHome, null),
      (Destination.tools, Icons.handyman_outlined, Icons.handyman, l.navTools, null),
      (Destination.downloads, Icons.download_outlined, Icons.download, l.navDownloads, null),
      (
        Destination.queue,
        Icons.queue_play_next_outlined,
        Icons.queue_play_next,
        l.navQueue,
        queue.activeCount + queue.pendingCount > 0 ? '${queue.activeCount + queue.pendingCount}' : null,
      ),
      (Destination.presets, Icons.bookmarks_outlined, Icons.bookmarks, l.navPresets, null),
      (
        Destination.components,
        Icons.extension_outlined,
        Icons.extension,
        l.navComponents,
        (comps.loaded && !hasFfmpeg) ? '!' : (updates > 0 ? '$updates' : null),
      ),
      (Destination.settings, Icons.settings_outlined, Icons.settings, l.navSettings, null),
    ];

    Widget icon(IconData i, String? badge) => badge == null ? Icon(i) : Badge(label: Text(badge), child: Icon(i));

    final page = switch (current) {
      Destination.home => const HomePage(),
      Destination.tools => const ToolsPage(),
      Destination.downloads => const DownloadsPage(),
      Destination.queue => const QueuePage(),
      Destination.presets => const PresetsPage(),
      Destination.components => const ComponentsPage(),
      Destination.settings => const SettingsPage(),
    };

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // MD3 "fade through": outgoing fades out, incoming fades + scales in.
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(anim), child: child),
      ),
      child: KeyedSubtree(key: ValueKey(current), child: page),
    );

    final shortcuts = <ShortcutActivator, VoidCallback>{
      for (var i = 0; i < Destination.values.length; i++)
        SingleActivator(LogicalKeyboardKey(LogicalKeyboardKey.digit1.keyId + i), control: true): () =>
            ref.read(navProvider.notifier).go(Destination.values[i]),
      const SingleActivator(LogicalKeyboardKey.keyO, control: true): () {
        ref.read(navProvider.notifier).go(Destination.home);
        ref.read(currentFileProvider.notifier).pickAndOpen();
      },
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, c) {
            final compact = c.maxWidth < 720;
            if (compact) {
              return Scaffold(
                body: SafeArea(child: body),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: current.index,
                  labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                  onDestinationSelected: (i) => ref.read(navProvider.notifier).go(Destination.values[i]),
                  destinations: [
                    for (final d in dests)
                      NavigationDestination(
                        icon: icon(d.$2, d.$5),
                        selectedIcon: icon(d.$3, d.$5),
                        label: d.$4,
                        tooltip: d.$4,
                      ),
                  ],
                ),
              );
            }
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: current.index,
                    onDestinationSelected: (i) => ref.read(navProvider.notifier).go(Destination.values[i]),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Icon(Icons.movie_filter_rounded, size: 32, color: Theme.of(context).colorScheme.primary),
                    ),
                    destinations: [
                      for (final d in dests)
                        NavigationRailDestination(
                          icon: icon(d.$2, d.$5),
                          selectedIcon: icon(d.$3, d.$5),
                          label: Text(d.$4),
                        ),
                    ],
                  ),
                  Expanded(child: SafeArea(child: body)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
