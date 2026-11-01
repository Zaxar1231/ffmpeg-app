import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/engine/error_translator.dart';
import '../l10n.dart';

/// Localized, human message for a tool error. Suggestions are concrete.
String toolErrorText(AppLocalizations l, ToolErrorKind kind, String? detail) {
  final d = detail ?? '';
  return switch (kind) {
    ToolErrorKind.toolMissing => l.errToolMissing,
    ToolErrorKind.fileNotFound => l.errFileNotFound(d),
    ToolErrorKind.permissionDenied => l.errPermissionDenied(d),
    ToolErrorKind.diskFull => l.errDiskFull,
    ToolErrorKind.invalidData => l.errInvalidData,
    ToolErrorKind.encoderMissing => l.errEncoderMissing(d),
    ToolErrorKind.decoderMissing => l.errDecoderMissing(d),
    ToolErrorKind.filterMissing => l.errFilterMissing(d),
    ToolErrorKind.codecContainerMismatch => l.errCodecContainer,
    ToolErrorKind.oddDimensions => l.errOddDimensions,
    ToolErrorKind.hwEncoderUnavailable => l.errHwUnavailable,
    ToolErrorKind.invalidArgument => l.errInvalidArgument(d),
    ToolErrorKind.streamNotFound => l.errStreamNotFound,
    ToolErrorKind.outputSameAsInput => l.errSameAsInput,
    ToolErrorKind.networkError => l.errNetwork,
    ToolErrorKind.ytdlpUnsupportedUrl => l.errUnsupportedUrl,
    ToolErrorKind.ytdlpLoginRequired => l.errLoginRequired,
    ToolErrorKind.ytdlpUnavailable => l.errVideoUnavailable,
    ToolErrorKind.canceled => l.errCanceled,
    ToolErrorKind.unknown => l.errUnknown,
  };
}

/// Localized byte units for [formatBytes].
List<String> byteUnits(AppLocalizations l) => [l.unitB, l.unitKB, l.unitMB, l.unitGB, l.unitTB];

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: t.colorScheme.primary.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(title, style: t.textTheme.titleLarge, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[const SizedBox(height: 24), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Page scaffold used by every top-level destination.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.title, required this.child, this.actions = const [], this.maxWidth = 1100});
  final String title;
  final Widget child;
  final List<Widget> actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
          child: Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
              ...actions,
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.selectable = false});
  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: selectable
                ? SelectableText(value, style: t.textTheme.bodyMedium)
                : Text(value, style: t.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Small tonal label (e.g. "instant, lossless", "needs full build").
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = color ?? cs.secondaryContainer;
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark ? Colors.white : Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Monospace log/command viewer with copy button.
Future<void> showTextDialog(BuildContext context, {required String title, required String text, Widget? extraAction}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 760,
        height: 420,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: SelectableText(
              text.isEmpty ? '—' : text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.4),
            ),
          ),
        ),
      ),
      actions: [
        ?extraAction,
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(ctx.l10n.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(ctx.l10n.copied)));
          },
        ),
        FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l10n.close)),
      ],
    ),
  );
}
