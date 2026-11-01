import 'package:flutter/material.dart';

import '../l10n.dart';

/// One setting or tool parameter, following the app-wide pattern:
/// clear title, one-line hint, "?" that expands a detailed explanation,
/// the control itself and an optional per-item reset.
class SettingTile extends StatefulWidget {
  const SettingTile({
    super.key,
    required this.title,
    required this.hint,
    required this.control,
    this.help,
    this.onReset,
    this.isDefault = true,
    this.controlBelow = false,
    this.leading,
  });

  final String title;
  final String hint;

  /// Detailed explanation: what it is, what it affects, when to change,
  /// recommended values and the default.
  final String? help;
  final Widget control;

  /// Shown only when the value differs from the default.
  final VoidCallback? onReset;
  final bool isDefault;

  /// Wide controls (sliders, text fields, segmented buttons) go below.
  final bool controlBelow;
  final Widget? leading;

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool _helpOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 16)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(widget.hint, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        if (widget.help != null)
          IconButton(
            tooltip: l10n.helpTooltip,
            isSelected: _helpOpen,
            icon: const Icon(Icons.help_outline),
            selectedIcon: const Icon(Icons.help),
            onPressed: () => setState(() => _helpOpen = !_helpOpen),
          ),
        if (widget.onReset != null && !widget.isDefault)
          IconButton(tooltip: l10n.resetTooltip, icon: const Icon(Icons.restart_alt), onPressed: widget.onReset),
        if (!widget.controlBelow) ...[const SizedBox(width: 8), widget.control],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _helpOpen && widget.help != null
                ? Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(widget.help!, style: theme.textTheme.bodyMedium),
                  )
                : const SizedBox(width: double.infinity),
          ),
          if (widget.controlBelow) ...[const SizedBox(height: 8), widget.control],
        ],
      ),
    );
  }
}

/// A titled group of settings with a section-level reset.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children, this.onReset, this.icon});

  final String title;
  final IconData? icon;
  final List<Widget> children;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                if (icon != null) ...[Icon(icon, color: theme.colorScheme.primary), const SizedBox(width: 12)],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                ),
                if (onReset != null)
                  TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: Text(context.l10n.resetSection),
                  ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// Slider with labeled zones ("better quality ← → smaller file").
class ZonedSlider extends StatelessWidget {
  const ZonedSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.leftLabel,
    this.rightLabel,
    this.valueLabel,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? leftLabel;
  final String? rightLabel;
  final String Function(double)? valueLabel;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    final label = valueLabel?.call(value) ?? value.round().toString();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                label: label,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(label, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleSmall),
            ),
          ],
        ),
        if (leftLabel != null || rightLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                if (leftLabel != null) Text('← $leftLabel', style: style),
                const Spacer(),
                if (rightLabel != null) Text('$rightLabel →', style: style),
              ],
            ),
          ),
      ],
    );
  }
}
