import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_pages.dart';
import '../convert/convert_page.dart';
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
      _ => const SizedBox.shrink(),
    };
  }
}

/// Tools that open an interactive screen (rather than running immediately).
const screenTools = {'convert', 'compress', 'trim', 'extractAudio', 'replaceAudio', 'normalize', 'gif'};
