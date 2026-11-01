import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/app_paths.dart';
import '../../core/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';
import '../../ui/widgets/setting_tile.dart';

enum _Section { general, appearance, performance, paths, downloads, updates, notifications, expert }

class _Item {
  const _Item(this.section, this.title, this.hint, this.help, this.build, {this.advanced = false});
  final _Section section;
  final String title;
  final String hint;
  final String? help;
  final bool advanced;
  final Widget Function(String title, String hint, String? help) build;

  bool matches(String q) => q.isEmpty || '$title $hint ${help ?? ''}'.toLowerCase().contains(q);
}

const _accentPalette = <int>[
  0xFF6750A4,
  0xFF0061A4,
  0xFF006E1C,
  0xFF8C4A00,
  0xFFB3261E,
  0xFF006A6A,
  0xFF7D5260,
  0xFF4A6400,
  0xFF984061,
];

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    const d = AppSettings();
    void up(AppSettings Function(AppSettings) f) => ctl.update(f);

    Widget tile(
      String title,
      String hint,
      String? help,
      Widget control, {
      bool isDefault = true,
      VoidCallback? reset,
      bool below = false,
    }) => SettingTile(
      title: title,
      hint: hint,
      help: help,
      control: control,
      isDefault: isDefault,
      onReset: reset,
      controlBelow: below,
    );

    Widget policy(ComponentUpdatePolicy v, ValueChanged<ComponentUpdatePolicy> on) =>
        DropdownButton<ComponentUpdatePolicy>(
          value: v,
          onChanged: (x) => x == null ? null : on(x),
          items: [
            DropdownMenuItem(value: ComponentUpdatePolicy.automatic, child: Text(l.policyAuto)),
            DropdownMenuItem(value: ComponentUpdatePolicy.ask, child: Text(l.policyAsk)),
            DropdownMenuItem(value: ComponentUpdatePolicy.never, child: Text(l.policyNever)),
          ],
        );

    final items = <_Item>[
      // General
      _Item(
        _Section.general,
        l.setLanguage,
        l.setLanguageHint,
        null,
        (t, h, x) => tile(
          t,
          h,
          x,
          DropdownButton<String?>(
            value: s.locale,
            onChanged: (v) => up((a) => a.copyWith(locale: () => v)),
            items: [
              DropdownMenuItem(value: null, child: Text(l.languageSystem)),
              const DropdownMenuItem(value: 'ru', child: Text('Русский')),
              const DropdownMenuItem(value: 'en', child: Text('English')),
            ],
          ),
          isDefault: s.locale == d.locale,
          reset: () => up((a) => a.copyWith(locale: () => null)),
        ),
      ),
      _Item(
        _Section.general,
        l.setAdvancedMode,
        l.setAdvancedModeHint,
        l.setAdvancedModeHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          Switch(
            value: s.advancedMode,
            onChanged: (v) => up((a) => a.copyWith(advancedMode: v)),
          ),
          isDefault: s.advancedMode == d.advancedMode,
          reset: () => up((a) => a.copyWith(advancedMode: d.advancedMode)),
        ),
      ),
      // Appearance
      _Item(
        _Section.appearance,
        l.setTheme,
        l.setThemeHint,
        null,
        (t, h, x) => tile(
          t,
          h,
          x,
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto),
                label: Text(l.themeSystem),
              ),
              ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode), label: Text(l.themeLight)),
              ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode), label: Text(l.themeDark)),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => up((a) => a.copyWith(themeMode: v.first)),
          ),
          below: true,
          isDefault: s.themeMode == d.themeMode,
          reset: () => up((a) => a.copyWith(themeMode: d.themeMode)),
        ),
      ),
      _Item(
        _Section.appearance,
        l.setAccent,
        l.setAccentHint,
        l.setAccentHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<AccentSource>(
                segments: [
                  ButtonSegment(value: AccentSource.system, label: Text(l.accentSystem)),
                  ButtonSegment(value: AccentSource.custom, label: Text(l.accentCustom)),
                ],
                selected: {s.accentSource},
                onSelectionChanged: (v) => up((a) => a.copyWith(accentSource: v.first)),
              ),
              if (s.accentSource == AccentSource.custom) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in _accentPalette)
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => up((a) => a.copyWith(accentColor: c)),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(c),
                          child: s.accentColor == c ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          below: true,
          isDefault: s.accentSource == d.accentSource && s.accentColor == d.accentColor,
          reset: () => up((a) => a.copyWith(accentSource: d.accentSource, accentColor: d.accentColor)),
        ),
      ),
      // Performance
      _Item(
        _Section.performance,
        l.setParallel,
        l.setParallelHint,
        l.setParallelHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          ZonedSlider(
            value: s.maxParallelJobs.toDouble(),
            min: 1,
            max: 8,
            divisions: 7,
            leftLabel: l.zoneFasterEach,
            rightLabel: l.zoneMoreAtOnce,
            onChanged: (v) => up((a) => a.copyWith(maxParallelJobs: v.round())),
          ),
          below: true,
          isDefault: s.maxParallelJobs == d.maxParallelJobs,
          reset: () => up((a) => a.copyWith(maxParallelJobs: d.maxParallelJobs)),
        ),
      ),
      _Item(
        _Section.performance,
        l.setHwAccel,
        l.setHwAccelHint,
        l.setHwAccelHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          Switch(
            value: s.useHwAccel,
            onChanged: (v) => up((a) => a.copyWith(useHwAccel: v)),
          ),
          isDefault: s.useHwAccel == d.useHwAccel,
          reset: () => up((a) => a.copyWith(useHwAccel: d.useHwAccel)),
        ),
      ),
      _Item(
        _Section.performance,
        l.setRetries,
        l.setRetriesHint,
        l.setRetriesHelp,
        advanced: true,
        (t, h, x) => tile(
          t,
          h,
          x,
          ZonedSlider(
            value: s.retryCount.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: (v) => up((a) => a.copyWith(retryCount: v.round())),
          ),
          below: true,
          isDefault: s.retryCount == d.retryCount,
          reset: () => up((a) => a.copyWith(retryCount: d.retryCount)),
        ),
      ),
      _Item(
        _Section.performance,
        l.setThreads,
        l.setThreadsHint,
        l.setThreadsHelp,
        advanced: true,
        (t, h, x) => tile(
          t,
          h,
          x,
          ZonedSlider(
            value: s.ffmpegThreads.toDouble(),
            min: 0,
            max: 32,
            divisions: 32,
            valueLabel: (v) => v == 0 ? l.auto : '${v.round()}',
            onChanged: (v) => up((a) => a.copyWith(ffmpegThreads: v.round())),
          ),
          below: true,
          isDefault: s.ffmpegThreads == d.ffmpegThreads,
          reset: () => up((a) => a.copyWith(ffmpegThreads: d.ffmpegThreads)),
        ),
      ),
      // Paths
      _Item(
        _Section.paths,
        l.setNextToSource,
        l.setNextToSourceHint,
        null,
        (t, h, x) => tile(
          t,
          h,
          x,
          Switch(
            value: s.outputNextToSource,
            onChanged: (v) => up((a) => a.copyWith(outputNextToSource: v)),
          ),
          isDefault: s.outputNextToSource == d.outputNextToSource,
          reset: () => up((a) => a.copyWith(outputNextToSource: d.outputNextToSource)),
        ),
      ),
      _Item(
        _Section.paths,
        l.setOutputDir,
        l.setOutputDirHint,
        l.setOutputDirHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          Row(
            children: [
              Expanded(
                child: Text(
                  s.outputDir ?? l.outputDirDefault(AppPaths.defaultOutputDir()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.folder_open),
                label: Text(l.choose),
                onPressed: () async {
                  final dir = await getDirectoryPath();
                  if (dir != null) up((a) => a.copyWith(outputDir: () => dir));
                },
              ),
            ],
          ),
          below: true,
          isDefault: s.outputDir == null,
          reset: () => up((a) => a.copyWith(outputDir: () => null)),
        ),
      ),
      _Item(
        _Section.paths,
        l.setCustomFfmpeg,
        l.setCustomFfmpegHint,
        l.setCustomFfmpegHelp,
        advanced: true,
        (t, h, x) => tile(
          t,
          h,
          x,
          _PathPicker(
            value: s.customFfmpegPath,
            onChanged: (v) => up((a) => a.copyWith(customFfmpegPath: () => v)),
          ),
          below: true,
          isDefault: s.customFfmpegPath == null,
          reset: () => up((a) => a.copyWith(customFfmpegPath: () => null)),
        ),
      ),
      _Item(
        _Section.paths,
        l.setCustomFfprobe,
        l.setCustomFfprobeHint,
        null,
        advanced: true,
        (t, h, x) => tile(
          t,
          h,
          x,
          _PathPicker(
            value: s.customFfprobePath,
            onChanged: (v) => up((a) => a.copyWith(customFfprobePath: () => v)),
          ),
          below: true,
          isDefault: s.customFfprobePath == null,
          reset: () => up((a) => a.copyWith(customFfprobePath: () => null)),
        ),
      ),
      _Item(
        _Section.paths,
        l.setCustomYtdlp,
        l.setCustomYtdlpHint,
        null,
        advanced: true,
        (t, h, x) => tile(
          t,
          h,
          x,
          _PathPicker(
            value: s.customYtdlpPath,
            onChanged: (v) => up((a) => a.copyWith(customYtdlpPath: () => v)),
          ),
          below: true,
          isDefault: s.customYtdlpPath == null,
          reset: () => up((a) => a.copyWith(customYtdlpPath: () => null)),
        ),
      ),
      // Downloads
      _Item(
        _Section.downloads,
        l.setAria2,
        l.setAria2Hint,
        l.setAria2Help,
        (t, h, x) => tile(
          t,
          h,
          x,
          Switch(
            value: s.ytdlpUseAria2,
            onChanged: (v) => up((a) => a.copyWith(ytdlpUseAria2: v)),
          ),
          isDefault: s.ytdlpUseAria2 == d.ytdlpUseAria2,
          reset: () => up((a) => a.copyWith(ytdlpUseAria2: d.ytdlpUseAria2)),
        ),
      ),
      _Item(
        _Section.downloads,
        l.setFragments,
        l.setFragmentsHint,
        l.setFragmentsHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          ZonedSlider(
            value: s.ytdlpConcurrentFragments.toDouble(),
            min: 1,
            max: 16,
            divisions: 15,
            leftLabel: l.zoneGentle,
            rightLabel: l.zoneFaster,
            onChanged: (v) => up((a) => a.copyWith(ytdlpConcurrentFragments: v.round())),
          ),
          below: true,
          isDefault: s.ytdlpConcurrentFragments == d.ytdlpConcurrentFragments,
          reset: () => up((a) => a.copyWith(ytdlpConcurrentFragments: d.ytdlpConcurrentFragments)),
        ),
      ),
      // Updates
      _Item(
        _Section.updates,
        l.setPolicyFfmpeg,
        l.setPolicyHint,
        l.setPolicyHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          policy(s.ffmpegUpdatePolicy, (v) => up((a) => a.copyWith(ffmpegUpdatePolicy: v))),
          isDefault: s.ffmpegUpdatePolicy == d.ffmpegUpdatePolicy,
          reset: () => up((a) => a.copyWith(ffmpegUpdatePolicy: d.ffmpegUpdatePolicy)),
        ),
      ),
      _Item(
        _Section.updates,
        l.setPolicyYtdlp,
        l.setPolicyYtdlpHint,
        l.setPolicyHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          policy(s.ytdlpUpdatePolicy, (v) => up((a) => a.copyWith(ytdlpUpdatePolicy: v))),
          isDefault: s.ytdlpUpdatePolicy == d.ytdlpUpdatePolicy,
          reset: () => up((a) => a.copyWith(ytdlpUpdatePolicy: d.ytdlpUpdatePolicy)),
        ),
      ),
      _Item(
        _Section.updates,
        l.setPolicyOther,
        l.setPolicyHint,
        l.setPolicyHelp,
        (t, h, x) => tile(
          t,
          h,
          x,
          policy(s.otherUpdatePolicy, (v) => up((a) => a.copyWith(otherUpdatePolicy: v))),
          isDefault: s.otherUpdatePolicy == d.otherUpdatePolicy,
          reset: () => up((a) => a.copyWith(otherUpdatePolicy: d.otherUpdatePolicy)),
        ),
      ),
      _Item(
        _Section.updates,
        l.setKeepVersions,
        l.setKeepVersionsHint,
        l.setKeepVersionsHelp,
        advanced: true,
        (t, h, x) => tile(
          t,
          h,
          x,
          ZonedSlider(
            value: s.keepPreviousVersions.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            leftLabel: l.zoneLessDisk,
            rightLabel: l.zoneMoreRollback,
            onChanged: (v) => up((a) => a.copyWith(keepPreviousVersions: v.round())),
          ),
          below: true,
          isDefault: s.keepPreviousVersions == d.keepPreviousVersions,
          reset: () => up((a) => a.copyWith(keepPreviousVersions: d.keepPreviousVersions)),
        ),
      ),
      // Notifications
      _Item(
        _Section.notifications,
        l.setNotify,
        l.setNotifyHint,
        null,
        (t, h, x) => tile(
          t,
          h,
          x,
          Switch(
            value: s.notifyOnFinish,
            onChanged: (v) => up((a) => a.copyWith(notifyOnFinish: v)),
          ),
          isDefault: s.notifyOnFinish == d.notifyOnFinish,
          reset: () => up((a) => a.copyWith(notifyOnFinish: d.notifyOnFinish)),
        ),
      ),
      // Expert
      _Item(
        _Section.expert,
        l.setShowCommand,
        l.setShowCommandHint,
        l.setShowCommandHelp,
        advanced: true,
        (t, h, x) => tile(
          t,
          h,
          x,
          Switch(
            value: s.showCommandBeforeRun,
            onChanged: (v) => up((a) => a.copyWith(showCommandBeforeRun: v)),
          ),
          isDefault: s.showCommandBeforeRun == d.showCommandBeforeRun,
          reset: () => up((a) => a.copyWith(showCommandBeforeRun: d.showCommandBeforeRun)),
        ),
      ),
    ];

    final q = _query.trim().toLowerCase();
    // Search finds advanced settings too; otherwise simple mode hides them.
    final visible = items.where((i) => i.matches(q) && (q.isNotEmpty || s.advancedMode || !i.advanced)).toList();
    final hiddenAdvanced = q.isEmpty && !s.advancedMode ? items.where((i) => i.advanced).length : 0;

    String sectionTitle(_Section x) => switch (x) {
      _Section.general => l.secGeneral,
      _Section.appearance => l.secAppearance,
      _Section.performance => l.secPerformance,
      _Section.paths => l.secPaths,
      _Section.downloads => l.secDownloads,
      _Section.updates => l.secUpdates,
      _Section.notifications => l.secNotifications,
      _Section.expert => l.secExpert,
    };
    IconData sectionIcon(_Section x) => switch (x) {
      _Section.general => Icons.tune,
      _Section.appearance => Icons.palette_outlined,
      _Section.performance => Icons.speed,
      _Section.paths => Icons.folder_outlined,
      _Section.downloads => Icons.download_outlined,
      _Section.updates => Icons.system_update_alt,
      _Section.notifications => Icons.notifications_outlined,
      _Section.expert => Icons.terminal,
    };

    AppSettings resetSection(_Section x, AppSettings a) => switch (x) {
      _Section.general => a.copyWith(locale: () => d.locale, advancedMode: d.advancedMode),
      _Section.appearance => a.copyWith(
        themeMode: d.themeMode,
        accentSource: d.accentSource,
        accentColor: d.accentColor,
      ),
      _Section.performance => a.copyWith(
        maxParallelJobs: d.maxParallelJobs,
        useHwAccel: d.useHwAccel,
        retryCount: d.retryCount,
        ffmpegThreads: d.ffmpegThreads,
      ),
      _Section.paths => a.copyWith(
        outputDir: () => null,
        outputNextToSource: d.outputNextToSource,
        customFfmpegPath: () => null,
        customFfprobePath: () => null,
        customYtdlpPath: () => null,
      ),
      _Section.downloads => a.copyWith(
        ytdlpConcurrentFragments: d.ytdlpConcurrentFragments,
        ytdlpUseAria2: d.ytdlpUseAria2,
      ),
      _Section.updates => a.copyWith(
        ffmpegUpdatePolicy: d.ffmpegUpdatePolicy,
        ytdlpUpdatePolicy: d.ytdlpUpdatePolicy,
        otherUpdatePolicy: d.otherUpdatePolicy,
        keepPreviousVersions: d.keepPreviousVersions,
      ),
      _Section.notifications => a.copyWith(notifyOnFinish: d.notifyOnFinish),
      _Section.expert => a.copyWith(showCommandBeforeRun: d.showCommandBeforeRun),
    };

    return PageFrame(
      title: l.navSettings,
      maxWidth: 860,
      actions: [
        Text(l.setAdvancedMode, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 8),
        Switch(
          value: s.advancedMode,
          onChanged: (v) => up((a) => a.copyWith(advancedMode: v)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SearchBar(
              hintText: l.settingsSearchHint,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? EmptyState(icon: Icons.search_off, title: l.nothingFound)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      for (final sec in _Section.values)
                        if (visible.any((i) => i.section == sec))
                          SettingsSection(
                            title: sectionTitle(sec),
                            icon: sectionIcon(sec),
                            onReset: () => up((a) => resetSection(sec, a)),
                            children: [
                              for (final i in visible.where((i) => i.section == sec)) i.build(i.title, i.hint, i.help),
                            ],
                          ),
                      if (hiddenAdvanced > 0)
                        Center(
                          child: TextButton.icon(
                            onPressed: () => up((a) => a.copyWith(advancedMode: true)),
                            icon: const Icon(Icons.expand_more),
                            label: Text(l.showAdvanced(hiddenAdvanced)),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => ctl.reset(),
                          icon: const Icon(Icons.restart_alt),
                          label: Text(l.resetAll),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PathPicker extends StatelessWidget {
  const _PathPicker({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(child: Text(value ?? l.notSet, style: Theme.of(context).textTheme.bodySmall)),
        TextButton.icon(
          icon: const Icon(Icons.file_open_outlined),
          label: Text(l.choose),
          onPressed: () async {
            final f = await openFile();
            if (f != null) onChanged(f.path);
          },
        ),
      ],
    );
  }
}
