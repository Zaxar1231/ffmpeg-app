import 'package:flutter/material.dart';

import '../../core/engine/capabilities.dart';
import '../../core/probe/media_info.dart';
import '../../ui/l10n.dart';

enum ToolCategory {
  analysis,
  convert,
  edit,
  audio,
  subtitles,
  images,
  metadata,
  capture,
  repair,
  download,
  automation,
  expert,
}

/// Every tool of the app. [stage] is the development stage in which it
/// becomes available; tools from later stages are listed but disabled.
class ToolDef {
  const ToolDef(
    this.id,
    this.category,
    this.icon, {
    required this.stage,
    this.keywords = const [],
    this.filters = const [],
    this.encoders = const [],
    this.lossless = false,
    this.forKinds = const {},
  });

  final String id;
  final ToolCategory category;
  final IconData icon;
  final int stage;

  /// Extra search terms (both languages) beyond the localized name.
  final List<String> keywords;

  /// Build requirements; missing ones mark the tool "needs another build".
  final List<String> filters;
  final List<String> encoders;

  /// Works with `-c copy`: instant and without quality loss.
  final bool lossless;

  /// File kinds this tool is suggested for as a quick action on Home.
  final Set<MediaCategory> forKinds;

  List<String> missingIn(FfmpegCapabilities caps) {
    if (caps.version == null) return const [];
    return [
      for (final f in filters)
        if (!caps.hasFilter(f)) f,
      for (final e in encoders)
        if (!caps.hasEncoder(e)) e,
    ];
  }
}

/// Stage in progress. Tools of earlier stages are enabled; tools of the
/// current stage only once they are listed in [currentStageReady].
const currentStage = 3;

const currentStageReady = {
  'audioEditor',
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

bool toolReady(ToolDef t) => t.stage < currentStage || (t.stage == currentStage && currentStageReady.contains(t.id));

const _v = {MediaCategory.video};
const _a = {MediaCategory.audio};
const _av = {MediaCategory.video, MediaCategory.audio};
const _img = {MediaCategory.image, MediaCategory.animation};
const _any = {MediaCategory.video, MediaCategory.audio, MediaCategory.image, MediaCategory.animation};

const toolCatalog = <ToolDef>[
  // 1. Analysis
  ToolDef(
    'mediaInfo',
    ToolCategory.analysis,
    Icons.info_outline,
    stage: 1,
    keywords: ['info', 'ffprobe', 'инфо', 'кодек', 'codec'],
  ),
  ToolDef(
    'integrity',
    ToolCategory.analysis,
    Icons.health_and_safety_outlined,
    stage: 1,
    keywords: ['check', 'broken', 'corrupt', 'проверка', 'битый'],
    forKinds: _any,
  ),
  ToolDef(
    'loudness',
    ToolCategory.analysis,
    Icons.graphic_eq,
    stage: 3,
    filters: ['ebur128', 'loudnorm'],
    keywords: ['lufs', 'ebur128', 'громкость'],
    forKinds: _av,
  ),
  ToolDef(
    'waveform',
    ToolCategory.analysis,
    Icons.waves,
    stage: 3,
    filters: ['showwavespic', 'showspectrumpic'],
    keywords: ['spectrogram', 'спектрограмма', 'осциллограмма'],
    forKinds: _a,
  ),
  ToolDef(
    'detect',
    ToolCategory.analysis,
    Icons.manage_search,
    stage: 3,
    filters: ['silencedetect', 'blackdetect', 'cropdetect', 'freezedetect'],
    keywords: ['silence', 'black', 'scene', 'тишина', 'сцены'],
  ),
  ToolDef(
    'compareQuality',
    ToolCategory.analysis,
    Icons.compare,
    stage: 3,
    filters: ['libvmaf', 'psnr', 'ssim'],
    keywords: ['vmaf', 'psnr', 'ssim'],
  ),
  // 2. Convert
  ToolDef(
    'convert',
    ToolCategory.convert,
    Icons.transform,
    stage: 2,
    keywords: ['mp4', 'mkv', 'webm', 'mp3', 'формат'],
    forKinds: _av,
  ),
  ToolDef(
    'compress',
    ToolCategory.convert,
    Icons.compress,
    stage: 2,
    keywords: ['сжать', 'crf', 'telegram', 'discord', 'size', 'размер'],
    forKinds: _v,
  ),
  ToolDef(
    'hdrToSdr',
    ToolCategory.convert,
    Icons.hdr_off_outlined,
    stage: 3,
    filters: ['zscale', 'tonemap'],
    keywords: ['hdr', 'tonemap'],
  ),
  // 3. Edit
  ToolDef(
    'trim',
    ToolCategory.edit,
    Icons.content_cut,
    stage: 2,
    lossless: true,
    keywords: ['cut', 'обрезать', 'вырезать'],
    forKinds: _av,
  ),
  ToolDef('cutJoin', ToolCategory.edit, Icons.splitscreen, stage: 3, keywords: ['fragments', 'фрагменты']),
  ToolDef('concat', ToolCategory.edit, Icons.merge, stage: 3, lossless: true, keywords: ['join', 'merge', 'склеить']),
  ToolDef(
    'split',
    ToolCategory.edit,
    Icons.call_split,
    stage: 3,
    lossless: true,
    keywords: ['segment', 'chapters', 'разделить'],
  ),
  ToolDef(
    'cropScale',
    ToolCategory.edit,
    Icons.crop,
    stage: 3,
    keywords: ['resize', 'rotate', 'flip', 'vertical', 'размер', 'поворот', 'вертикальное'],
    forKinds: _v,
  ),
  ToolDef(
    'speed',
    ToolCategory.edit,
    Icons.speed,
    stage: 3,
    keywords: ['reverse', 'fps', 'slow', 'реверс', 'замедление'],
  ),
  ToolDef(
    'restore',
    ToolCategory.edit,
    Icons.auto_fix_high,
    stage: 3,
    filters: ['bwdif', 'hqdn3d', 'nlmeans', 'unsharp'],
    keywords: ['deinterlace', 'denoise', 'sharpen', 'stabilize', 'vidstab', 'шум'],
  ),
  ToolDef(
    'color',
    ToolCategory.edit,
    Icons.palette_outlined,
    stage: 3,
    filters: ['eq', 'lut3d', 'curves'],
    keywords: ['lut', 'цвет', 'яркость'],
  ),
  ToolDef(
    'overlay',
    ToolCategory.edit,
    Icons.branding_watermark_outlined,
    stage: 3,
    filters: ['drawtext', 'overlay'],
    keywords: ['watermark', 'text', 'timecode', 'водяной', 'текст'],
  ),
  ToolDef(
    'blur',
    ToolCategory.edit,
    Icons.blur_on,
    stage: 3,
    filters: ['delogo', 'boxblur'],
    keywords: ['delogo', 'pixelate', 'размытие', 'логотип'],
  ),
  ToolDef(
    'stack',
    ToolCategory.edit,
    Icons.view_quilt_outlined,
    stage: 3,
    filters: ['hstack', 'xstack', 'overlay'],
    keywords: ['pip', 'side by side', 'сетка'],
  ),
  ToolDef(
    'transitions',
    ToolCategory.edit,
    Icons.gradient,
    stage: 3,
    filters: ['xfade', 'fade'],
    keywords: ['fade', 'xfade', 'переход'],
  ),
  ToolDef('loop', ToolCategory.edit, Icons.loop, stage: 3, keywords: ['boomerang', 'бумеранг']),
  // 4. Audio
  ToolDef(
    'audioEditor',
    ToolCategory.audio,
    Icons.graphic_eq,
    stage: 3,
    keywords: ['audacity', 'редактор', 'editor', 'waveform', 'волна', 'запись', 'record', 'эффекты', 'effects'],
    forKinds: _av,
  ),
  ToolDef(
    'extractAudio',
    ToolCategory.audio,
    Icons.music_note_outlined,
    stage: 2,
    lossless: true,
    keywords: ['mp3', 'звук', 'извлечь'],
    forKinds: _v,
  ),
  ToolDef(
    'replaceAudio',
    ToolCategory.audio,
    Icons.swap_horiz,
    stage: 2,
    lossless: true,
    keywords: ['track', 'дорожка', 'заменить', 'удалить звук', 'mute'],
    forKinds: _v,
  ),
  ToolDef(
    'normalize',
    ToolCategory.audio,
    Icons.equalizer,
    stage: 2,
    filters: ['loudnorm'],
    keywords: ['loudnorm', 'lufs', 'громкость', 'нормализация'],
    forKinds: _av,
  ),
  ToolDef(
    'denoise',
    ToolCategory.audio,
    Icons.noise_aware,
    stage: 3,
    filters: ['afftdn', 'anlmdn', 'arnndn'],
    keywords: ['noise', 'rnnoise', 'шум', 'щелчки'],
  ),
  ToolDef(
    'audioFx',
    ToolCategory.audio,
    Icons.tune,
    stage: 3,
    filters: ['equalizer', 'acompressor', 'alimiter'],
    keywords: ['eq', 'compressor', 'tempo', 'pitch', 'эквалайзер', 'темп'],
  ),
  ToolDef(
    'mix',
    ToolCategory.audio,
    Icons.queue_music,
    stage: 3,
    filters: ['amix', 'sidechaincompress'],
    keywords: ['ducking', 'музыка', 'смешать'],
  ),
  ToolDef(
    'transcribe',
    ToolCategory.audio,
    Icons.record_voice_over_outlined,
    stage: 3,
    filters: ['whisper'],
    keywords: ['whisper', 'speech', 'транскрипция', 'распознавание'],
  ),
  // 5. Subtitles
  ToolDef(
    'burnSubs',
    ToolCategory.subtitles,
    Icons.subtitles,
    stage: 4,
    filters: ['subtitles'],
    keywords: ['hardsub', 'вшить'],
  ),
  ToolDef(
    'softSubs',
    ToolCategory.subtitles,
    Icons.closed_caption_outlined,
    stage: 4,
    lossless: true,
    keywords: ['softsub', 'дорожка'],
  ),
  ToolDef(
    'convertSubs',
    ToolCategory.subtitles,
    Icons.text_snippet_outlined,
    stage: 4,
    keywords: ['srt', 'ass', 'vtt', 'shift', 'сдвиг'],
  ),
  // 6. Images & animation
  ToolDef(
    'gif',
    ToolCategory.images,
    Icons.gif_box_outlined,
    stage: 2,
    filters: ['palettegen', 'paletteuse'],
    keywords: ['webp', 'apng', 'анимация'],
    forKinds: _v,
  ),
  ToolDef(
    'frames',
    ToolCategory.images,
    Icons.photo_library_outlined,
    stage: 4,
    keywords: ['thumbnail', 'screenshot', 'кадры', 'превью'],
  ),
  ToolDef(
    'contactSheet',
    ToolCategory.images,
    Icons.grid_view,
    stage: 4,
    filters: ['tile'],
    keywords: ['storyboard', 'раскадровка'],
  ),
  ToolDef('slideshow', ToolCategory.images, Icons.slideshow_outlined, stage: 4, keywords: ['images', 'картинки']),
  ToolDef(
    'audioToVideo',
    ToolCategory.images,
    Icons.album_outlined,
    stage: 4,
    keywords: ['youtube', 'cover', 'обложка'],
    forKinds: _a,
  ),
  ToolDef(
    'visualizer',
    ToolCategory.images,
    Icons.bar_chart,
    stage: 4,
    filters: ['showwaves', 'showspectrum', 'avectorscope'],
    keywords: ['waves', 'spectrum', 'визуализация'],
  ),
  ToolDef(
    'imageConvert',
    ToolCategory.images,
    Icons.image_outlined,
    stage: 4,
    keywords: ['jpeg', 'png', 'webp', 'avif'],
    forKinds: _img,
  ),
  // 7. Metadata
  ToolDef(
    'tags',
    ToolCategory.metadata,
    Icons.sell_outlined,
    stage: 4,
    lossless: true,
    keywords: ['metadata', 'теги', 'метаданные'],
    forKinds: _av,
  ),
  ToolDef('cover', ToolCategory.metadata, Icons.image_search, stage: 4, lossless: true, keywords: ['art', 'обложка']),
  ToolDef('chapters', ToolCategory.metadata, Icons.bookmark_border, stage: 4, lossless: true, keywords: ['главы']),
  // 8. Capture & streaming
  ToolDef(
    'screenRecord',
    ToolCategory.capture,
    Icons.screen_share_outlined,
    stage: 5,
    keywords: ['screen', 'экран', 'запись'],
  ),
  ToolDef(
    'webcam',
    ToolCategory.capture,
    Icons.videocam_outlined,
    stage: 5,
    keywords: ['camera', 'mic', 'камера', 'микрофон'],
  ),
  ToolDef('stream', ToolCategory.capture, Icons.cell_tower, stage: 5, keywords: ['rtmp', 'srt', 'twitch', 'стрим']),
  ToolDef('hls', ToolCategory.capture, Icons.stream, stage: 5, keywords: ['dash', 'web']),
  // 9. Repair
  ToolDef(
    'repair',
    ToolCategory.repair,
    Icons.build_outlined,
    stage: 4,
    lossless: true,
    keywords: ['broken', 'timestamps', 'sync', 'починить', 'рассинхрон'],
    forKinds: _av,
  ),
  ToolDef('faststart', ToolCategory.repair, Icons.bolt, stage: 4, lossless: true, keywords: ['mp4', 'web', 'moov']),
  // 10. Download
  ToolDef(
    'download',
    ToolCategory.download,
    Icons.cloud_download_outlined,
    stage: 2,
    keywords: ['yt-dlp', 'youtube', 'скачать', 'ссылка'],
  ),
  // 11. Automation
  ToolDef('batch', ToolCategory.automation, Icons.dynamic_feed, stage: 5, keywords: ['folder', 'папка', 'пакет']),
  ToolDef(
    'recipes',
    ToolCategory.automation,
    Icons.account_tree_outlined,
    stage: 5,
    keywords: ['chain', 'цепочка', 'рецепт'],
  ),
  ToolDef(
    'watchFolder',
    ToolCategory.automation,
    Icons.folder_special_outlined,
    stage: 5,
    keywords: ['watch', 'наблюдение'],
  ),
  // 12. Expert
  ToolDef('commandEditor', ToolCategory.expert, Icons.terminal, stage: 5, keywords: ['cli', 'command', 'команда']),
  ToolDef('filterGraph', ToolCategory.expert, Icons.schema_outlined, stage: 5, keywords: ['filtergraph', 'фильтры']),
  ToolDef('commandLog', ToolCategory.expert, Icons.history, stage: 5, keywords: ['history', 'журнал']),
];

ToolDef toolById(String id) => toolCatalog.firstWhere((t) => t.id == id);

String toolTitle(AppLocalizations l, String id) => switch (id) {
  'mediaInfo' => l.toolMediaInfo,
  'integrity' => l.toolIntegrity,
  'loudness' => l.toolLoudness,
  'waveform' => l.toolWaveform,
  'detect' => l.toolDetect,
  'compareQuality' => l.toolCompareQuality,
  'convert' => l.toolConvert,
  'compress' => l.toolCompress,
  'hdrToSdr' => l.toolHdrToSdr,
  'trim' => l.toolTrim,
  'cutJoin' => l.toolCutJoin,
  'concat' => l.toolConcat,
  'split' => l.toolSplit,
  'cropScale' => l.toolCropScale,
  'speed' => l.toolSpeed,
  'restore' => l.toolRestore,
  'color' => l.toolColor,
  'overlay' => l.toolOverlay,
  'blur' => l.toolBlur,
  'stack' => l.toolStack,
  'transitions' => l.toolTransitions,
  'loop' => l.toolLoop,
  'audioEditor' => l.toolAudioEditor,
  'extractAudio' => l.toolExtractAudio,
  'replaceAudio' => l.toolReplaceAudio,
  'normalize' => l.toolNormalize,
  'denoise' => l.toolDenoise,
  'audioFx' => l.toolAudioFx,
  'mix' => l.toolMix,
  'transcribe' => l.toolTranscribe,
  'burnSubs' => l.toolBurnSubs,
  'softSubs' => l.toolSoftSubs,
  'convertSubs' => l.toolConvertSubs,
  'gif' => l.toolGif,
  'frames' => l.toolFrames,
  'contactSheet' => l.toolContactSheet,
  'slideshow' => l.toolSlideshow,
  'audioToVideo' => l.toolAudioToVideo,
  'visualizer' => l.toolVisualizer,
  'imageConvert' => l.toolImageConvert,
  'tags' => l.toolTags,
  'cover' => l.toolCover,
  'chapters' => l.toolChapters,
  'screenRecord' => l.toolScreenRecord,
  'webcam' => l.toolWebcam,
  'stream' => l.toolStream,
  'hls' => l.toolHls,
  'repair' => l.toolRepair,
  'faststart' => l.toolFaststart,
  'download' => l.toolDownload,
  'batch' => l.toolBatch,
  'recipes' => l.toolRecipes,
  'watchFolder' => l.toolWatchFolder,
  'commandEditor' => l.toolCommandEditor,
  'filterGraph' => l.toolFilterGraph,
  'commandLog' => l.toolCommandLog,
  _ => id,
};

String categoryTitle(AppLocalizations l, ToolCategory c) => switch (c) {
  ToolCategory.analysis => l.catAnalysis,
  ToolCategory.convert => l.catConvert,
  ToolCategory.edit => l.catEdit,
  ToolCategory.audio => l.catAudio,
  ToolCategory.subtitles => l.catSubtitles,
  ToolCategory.images => l.catImages,
  ToolCategory.metadata => l.catMetadata,
  ToolCategory.capture => l.catCapture,
  ToolCategory.repair => l.catRepair,
  ToolCategory.download => l.catDownload,
  ToolCategory.automation => l.catAutomation,
  ToolCategory.expert => l.catExpert,
};

/// Case-insensitive search over localized title, id and keywords.
bool toolMatches(AppLocalizations l, ToolDef t, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  final hay = [toolTitle(l, t.id), toolDescription(l, t.id), t.id, ...t.keywords].join(' ').toLowerCase();
  return q.split(RegExp(r'\s+')).every(hay.contains);
}

String toolDescription(AppLocalizations l, String id) => switch (id) {
  'mediaInfo' => l.toolMediaInfoDesc,
  'integrity' => l.toolIntegrityDesc,
  'loudness' => l.toolLoudnessDesc,
  'waveform' => l.toolWaveformDesc,
  'detect' => l.toolDetectDesc,
  'compareQuality' => l.toolCompareQualityDesc,
  'convert' => l.toolConvertDesc,
  'compress' => l.toolCompressDesc,
  'hdrToSdr' => l.toolHdrToSdrDesc,
  'trim' => l.toolTrimDesc,
  'cutJoin' => l.toolCutJoinDesc,
  'concat' => l.toolConcatDesc,
  'split' => l.toolSplitDesc,
  'cropScale' => l.toolCropScaleDesc,
  'speed' => l.toolSpeedDesc,
  'restore' => l.toolRestoreDesc,
  'color' => l.toolColorDesc,
  'overlay' => l.toolOverlayDesc,
  'blur' => l.toolBlurDesc,
  'stack' => l.toolStackDesc,
  'transitions' => l.toolTransitionsDesc,
  'loop' => l.toolLoopDesc,
  'audioEditor' => l.toolAudioEditorDesc,
  'extractAudio' => l.toolExtractAudioDesc,
  'replaceAudio' => l.toolReplaceAudioDesc,
  'normalize' => l.toolNormalizeDesc,
  'denoise' => l.toolDenoiseDesc,
  'audioFx' => l.toolAudioFxDesc,
  'mix' => l.toolMixDesc,
  'transcribe' => l.toolTranscribeDesc,
  'burnSubs' => l.toolBurnSubsDesc,
  'softSubs' => l.toolSoftSubsDesc,
  'convertSubs' => l.toolConvertSubsDesc,
  'gif' => l.toolGifDesc,
  'frames' => l.toolFramesDesc,
  'contactSheet' => l.toolContactSheetDesc,
  'slideshow' => l.toolSlideshowDesc,
  'audioToVideo' => l.toolAudioToVideoDesc,
  'visualizer' => l.toolVisualizerDesc,
  'imageConvert' => l.toolImageConvertDesc,
  'tags' => l.toolTagsDesc,
  'cover' => l.toolCoverDesc,
  'chapters' => l.toolChaptersDesc,
  'screenRecord' => l.toolScreenRecordDesc,
  'webcam' => l.toolWebcamDesc,
  'stream' => l.toolStreamDesc,
  'hls' => l.toolHlsDesc,
  'repair' => l.toolRepairDesc,
  'faststart' => l.toolFaststartDesc,
  'download' => l.toolDownloadDesc,
  'batch' => l.toolBatchDesc,
  'recipes' => l.toolRecipesDesc,
  'watchFolder' => l.toolWatchFolderDesc,
  'commandEditor' => l.toolCommandEditorDesc,
  'filterGraph' => l.toolFilterGraphDesc,
  'commandLog' => l.toolCommandLogDesc,
  _ => '',
};
