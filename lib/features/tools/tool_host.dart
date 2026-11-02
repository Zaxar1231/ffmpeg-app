import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/analysis_pages.dart';
import '../audio/audio_file_pages.dart';
import '../audio/audio_pages.dart';
import '../audio_editor/ui/editor_page.dart';
import '../convert/convert_page.dart';
import '../edit/ui/cut_pages.dart';
import '../edit/graphs.dart';
import '../edit/ui/frame_pages.dart';
import '../gif/gif_page.dart';
import '../subtitles/subs_pages.dart';
import '../trim/trim_page.dart';
import 'tool_infra.dart';

/// Shows the open tool inside the Tools section (keeps the navigation rail).
class ToolHost extends ConsumerWidget {
  const ToolHost({super.key, required this.tool});
  final OpenTool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ValueKey('${tool.id}|${tool.path}|${tool.presetId}|${identityHashCode(tool.extra)}');
    final extra = tool.extra;
    return switch (tool.id) {
      'convert' || 'compress' => ConvertPage(key: key, toolId: tool.id, path: tool.path, presetId: tool.presetId),
      'trim' => TrimPage(key: key, path: tool.path),
      'extractAudio' => ExtractAudioPage(key: key, path: tool.path),
      'replaceAudio' => AudioTracksPage(key: key, path: tool.path),
      'normalize' => NormalizePage(key: key, path: tool.path),
      'gif' => GifPage(key: key, path: tool.path),
      'audioEditor' => AudioEditorTool(key: key, path: tool.path),
      'cutJoin' => CutJoinPage(key: key, path: tool.path, initial: extra is CutRanges ? extra : null),
      'concat' => ConcatPage(key: key, path: tool.path),
      'transitions' => ConcatPage(key: key, path: tool.path, transitions: true),
      'split' => SplitPage(key: key, path: tool.path, initial: extra is SplitTimes ? extra : null),
      'cropScale' => CropScalePage(key: key, path: tool.path, initialCrop: extra is CropRect ? extra : null),
      'speed' => SpeedPage(key: key, path: tool.path),
      'restore' => RestorePage(key: key, path: tool.path),
      'color' => ColorPage(key: key, path: tool.path),
      'overlay' => OverlayPage(key: key, path: tool.path),
      'blur' => BlurPage(key: key, path: tool.path),
      'stack' => StackPage(key: key, path: tool.path),
      'loop' => LoopPage(key: key, path: tool.path),
      'hdrToSdr' => HdrToSdrPage(key: key, path: tool.path),
      'loudness' => LoudnessPage(key: key, path: tool.path),
      'waveform' => WaveformPicPage(key: key, path: tool.path),
      'detect' => DetectPage(key: key, path: tool.path),
      'compareQuality' => CompareQualityPage(key: key, path: tool.path),
      'denoise' || 'audioFx' => AudioChainPage(key: key, toolId: tool.id, path: tool.path),
      'mix' => MusicPage(key: key, path: tool.path),
      'transcribe' => TranscribePage(key: key, path: tool.path),
      'burnSubs' => BurnSubsPage(key: key, path: tool.path),
      'softSubs' => SubTracksPage(key: key, path: tool.path),
      'convertSubs' => ConvertSubsPage(key: key, path: tool.path),
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
  ...analysisTools,
  ...audioFileTools,
  ...stage4Tools,
};

/// Stage 4 tools with a screen.
const stage4Tools = {'burnSubs', 'softSubs', 'convertSubs'};

/// Stage 3 analysis tools.
const analysisTools = {'loudness', 'waveform', 'detect', 'compareQuality'};

/// Stage 3 whole-file audio tools.
const audioFileTools = {'denoise', 'audioFx', 'mix', 'transcribe'};

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
