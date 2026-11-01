import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_pages.dart';
import '../audio_editor/ui/editor_page.dart';
import '../convert/convert_page.dart';
import '../edit/ui/cut_pages.dart';
import '../edit/ui/frame_pages.dart';
import '../gif/gif_page.dart';
import '../trim/trim_page.dart';
import 'tool_infra.dart';

/// Shows the open tool inside the Tools section (keeps the navigation rail).
class ToolHost extends ConsumerWidget {
  const ToolHost({super.key, required this.tool});
  final OpenTool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ValueKey('${tool.id}|${tool.path}|${tool.presetId}');
    return switch (tool.id) {
      'convert' || 'compress' => ConvertPage(key: key, toolId: tool.id, path: tool.path, presetId: tool.presetId),
      'trim' => TrimPage(key: key, path: tool.path),
      'extractAudio' => ExtractAudioPage(key: key, path: tool.path),
      'replaceAudio' => AudioTracksPage(key: key, path: tool.path),
      'normalize' => NormalizePage(key: key, path: tool.path),
      'gif' => GifPage(key: key, path: tool.path),
      'audioEditor' => AudioEditorTool(key: key, path: tool.path),
      'cutJoin' => CutJoinPage(key: key, path: tool.path),
      'concat' => ConcatPage(key: key, path: tool.path),
      'transitions' => ConcatPage(key: key, path: tool.path, transitions: true),
      'split' => SplitPage(key: key, path: tool.path),
      'cropScale' => CropScalePage(key: key, path: tool.path),
      'speed' => SpeedPage(key: key, path: tool.path),
      'restore' => RestorePage(key: key, path: tool.path),
      'color' => ColorPage(key: key, path: tool.path),
      'overlay' => OverlayPage(key: key, path: tool.path),
      'blur' => BlurPage(key: key, path: tool.path),
      'stack' => StackPage(key: key, path: tool.path),
      'loop' => LoopPage(key: key, path: tool.path),
      'hdrToSdr' => HdrToSdrPage(key: key, path: tool.path),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Tools that open an interactive screen (rather than running immediately).
const screenTools = {
  'convert',
  'compress',
  'trim',
  'extractAudio',
  'replaceAudio',
  'normalize',
  'gif',
  'audioEditor',
  ...editTools,
};

/// Stage 3 video editing tools.
const editTools = {
  'cutJoin',
  'concat',
  'transitions',
  'split',
  'cropScale',
  'speed',
  'restore',
  'color',
  'overlay',
  'blur',
  'stack',
  'loop',
  'hdrToSdr',
};
