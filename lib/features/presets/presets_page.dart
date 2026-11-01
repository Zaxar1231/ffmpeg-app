import 'package:flutter/material.dart';

import '../../ui/l10n.dart';
import '../../ui/widgets/common.dart';

/// Presets (built-in and user) arrive with the conversion tools in stage 2.
class PresetsPage extends StatelessWidget {
  const PresetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PageFrame(
      title: l.navPresets,
      child: EmptyState(icon: Icons.bookmarks_outlined, title: l.presetsSoonTitle, message: l.presetsSoonBody),
    );
  }
}
