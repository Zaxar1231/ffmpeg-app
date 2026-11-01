// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kadra';

  @override
  String get navHome => 'Home';

  @override
  String get navTools => 'Tools';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navQueue => 'Queue';

  @override
  String get navPresets => 'Presets';

  @override
  String get navComponents => 'Components';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get choose => 'Choose';

  @override
  String get search => 'Search';

  @override
  String get more => 'More';

  @override
  String get auto => 'auto';

  @override
  String get notSet => 'Not set';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get helpTooltip => 'Details';

  @override
  String get resetTooltip => 'Reset';

  @override
  String get resetSection => 'Reset section';

  @override
  String get resetAll => 'Reset all settings';

  @override
  String get install => 'Install';

  @override
  String get update => 'Update';

  @override
  String get reinstall => 'Reinstall';

  @override
  String get rollback => 'Roll back';

  @override
  String get remove => 'Remove';

  @override
  String get activate => 'Activate';

  @override
  String get reload => 'Reload file';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get retry => 'Retry';

  @override
  String get openFolder => 'Open folder';

  @override
  String get showLog => 'Show log';

  @override
  String get showCommand => 'Show command';

  @override
  String get removeFromList => 'Remove from list';

  @override
  String get logTitle => 'Full log';

  @override
  String get commandTitle => 'Command';

  @override
  String get unitB => 'B';

  @override
  String get unitKB => 'KB';

  @override
  String get unitMB => 'MB';

  @override
  String get unitGB => 'GB';

  @override
  String get unitTB => 'TB';

  @override
  String get unitKbps => 'kb/s';

  @override
  String get unitMbps => 'Mb/s';

  @override
  String get unitFps => 'fps';

  @override
  String get unitHz => 'Hz';

  @override
  String get unitSecond => 's';

  @override
  String get homeTitle => 'Home';

  @override
  String get openFile => 'Open file';

  @override
  String get closeFile => 'Close file';

  @override
  String get dropTitle => 'Drop a file here';

  @override
  String get dropSubtitle => 'or click to choose: video, audio, image';

  @override
  String get shortcutOpenHint => 'Ctrl+O opens a file, Ctrl+1…7 switch sections';

  @override
  String get probeFailed => 'Could not read the file';

  @override
  String get openAnother => 'Open another';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get ffmpegMissingTitle => 'ffmpeg not found';

  @override
  String get ffmpegMissingBody =>
      'The app cannot process files without it. Install ffmpeg in Components; it takes a minute.';

  @override
  String get openComponents => 'Open Components';

  @override
  String get addedToQueue => 'Job added to the queue';

  @override
  String get openQueue => 'Open queue';

  @override
  String get infoContainer => 'Container';

  @override
  String get infoFormat => 'Format';

  @override
  String get infoDuration => 'Duration';

  @override
  String get infoSize => 'Size';

  @override
  String get infoBitrate => 'Bitrate';

  @override
  String get infoStartTime => 'Start time';

  @override
  String get infoStreams => 'Streams';

  @override
  String infoChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count chapters', one: '$count chapter');
    return '$_temp0';
  }

  @override
  String get infoTags => 'Tags';

  @override
  String get infoCodec => 'Codec';

  @override
  String get infoResolution => 'Resolution';

  @override
  String get infoFrameRate => 'Frame rate';

  @override
  String get infoPixelFormat => 'Pixel format';

  @override
  String infoBits(int bits) {
    return '$bits-bit';
  }

  @override
  String get infoColor => 'Color';

  @override
  String get infoFieldOrder => 'Field order';

  @override
  String get infoRotation => 'Rotation';

  @override
  String get infoMastering => 'HDR mastering';

  @override
  String get infoContentLight => 'Content light';

  @override
  String get infoSampleRate => 'Sample rate';

  @override
  String get infoChannels => 'Channels';

  @override
  String get infoSampleFormat => 'Sample format';

  @override
  String get infoFrames => 'Frames';

  @override
  String get infoVersion => 'Version';

  @override
  String get streamVideo => 'Video';

  @override
  String get streamAudio => 'Audio';

  @override
  String get streamSubtitle => 'Subtitles';

  @override
  String get streamCover => 'Cover art';

  @override
  String get streamAttachment => 'Attachment';

  @override
  String get streamData => 'Data';

  @override
  String get dispositionDefault => 'default';

  @override
  String get dispositionForced => 'forced';

  @override
  String get toolsSearchHint => 'Find a tool: \"compress\", \"gif\", \"subtitles\"…';

  @override
  String toolComingSoon(int stage) {
    return 'Coming in development stage $stage';
  }

  @override
  String stageLabel(int stage) {
    return 'stage $stage';
  }

  @override
  String get losslessTag => 'instant, lossless';

  @override
  String get needsOtherBuild => 'needs another build';

  @override
  String needsBuildTooltip(String names) {
    return 'The installed ffmpeg build lacks: $names. Install a full build in Components.';
  }

  @override
  String get catAnalysis => 'Analysis';

  @override
  String get catConvert => 'Convert & compress';

  @override
  String get catEdit => 'Editing';

  @override
  String get catAudio => 'Audio';

  @override
  String get catSubtitles => 'Subtitles';

  @override
  String get catImages => 'Images & animation';

  @override
  String get catMetadata => 'Metadata & chapters';

  @override
  String get catCapture => 'Capture & streaming';

  @override
  String get catRepair => 'Repair';

  @override
  String get catDownload => 'Download';

  @override
  String get catAutomation => 'Batch & automation';

  @override
  String get catExpert => 'Expert';

  @override
  String get toolMediaInfo => 'File info';

  @override
  String get toolMediaInfoDesc => 'Container, streams, codecs, bitrate, HDR, chapters and tags.';

  @override
  String get toolIntegrity => 'Integrity check';

  @override
  String get toolIntegrityDesc => 'Decodes the whole file and lists every error found.';

  @override
  String get toolLoudness => 'Loudness meter';

  @override
  String get toolLoudnessDesc => 'LUFS, True Peak and LRA per EBU R128.';

  @override
  String get toolWaveform => 'Waveform & spectrum';

  @override
  String get toolWaveformDesc => 'An image of the waveform or spectrogram.';

  @override
  String get toolDetect => 'Detectors';

  @override
  String get toolDetectDesc => 'Silence, black and frozen frames, scene changes, black borders.';

  @override
  String get toolCompareQuality => 'Quality comparison';

  @override
  String get toolCompareQualityDesc => 'VMAF, PSNR and SSIM between original and result.';

  @override
  String get toolConvert => 'Convert';

  @override
  String get toolConvertDesc => 'Any container and codec: MP4, MKV, WebM, MP3, FLAC and more.';

  @override
  String get toolCompress => 'Compress';

  @override
  String get toolCompressDesc => 'Shrink files by quality or to a target file size.';

  @override
  String get toolHdrToSdr => 'HDR → SDR';

  @override
  String get toolHdrToSdrDesc => 'Tone-map HDR video for regular screens.';

  @override
  String get toolTrim => 'Trim';

  @override
  String get toolTrimDesc => 'Fast on keyframes or frame-accurate.';

  @override
  String get toolCutJoin => 'Cut fragments';

  @override
  String get toolCutJoinDesc => 'Remove unwanted parts or keep only selected ones.';

  @override
  String get toolConcat => 'Join';

  @override
  String get toolConcatDesc => 'Join several files into one.';

  @override
  String get toolSplit => 'Split';

  @override
  String get toolSplitDesc => 'By time, size, chapters, silence or scenes.';

  @override
  String get toolCropScale => 'Crop & scale';

  @override
  String get toolCropScaleDesc => 'Crop, scale, rotate, vertical video.';

  @override
  String get toolSpeed => 'Speed & FPS';

  @override
  String get toolSpeedDesc => 'Speed up, slow down, reverse, frame interpolation.';

  @override
  String get toolRestore => 'Restore video';

  @override
  String get toolRestoreDesc => 'Deinterlace, stabilize, denoise, sharpen.';

  @override
  String get toolColor => 'Color';

  @override
  String get toolColorDesc => 'Brightness, contrast, curves, 3D LUT, B&W and sepia.';

  @override
  String get toolOverlay => 'Watermark & text';

  @override
  String get toolOverlayDesc => 'Image, text or timecode over the video.';

  @override
  String get toolBlur => 'Blur & logos';

  @override
  String get toolBlurDesc => 'Blur or pixelate an area, remove a logo.';

  @override
  String get toolStack => 'Picture in picture';

  @override
  String get toolStackDesc => 'PiP, grid, side-by-side comparison.';

  @override
  String get toolTransitions => 'Fades & transitions';

  @override
  String get toolTransitionsDesc => 'Fade in/out and every xfade transition.';

  @override
  String get toolLoop => 'Loop';

  @override
  String get toolLoopDesc => 'Loop video and boomerang.';

  @override
  String get toolExtractAudio => 'Extract audio';

  @override
  String get toolExtractAudioDesc => 'Save the audio track as a separate file.';

  @override
  String get toolReplaceAudio => 'Audio tracks';

  @override
  String get toolReplaceAudioDesc => 'Replace, add, remove tracks or set the default one.';

  @override
  String get toolNormalize => 'Loudness normalization';

  @override
  String get toolNormalizeDesc => 'Two-pass loudnorm: YouTube −14, podcast −16, TV −23 LUFS.';

  @override
  String get toolDenoise => 'Noise reduction';

  @override
  String get toolDenoiseDesc => 'afftdn, anlmdn, RNNoise, declick and declip.';

  @override
  String get toolAudioFx => 'Audio effects';

  @override
  String get toolAudioFxDesc => 'EQ, compressor, limiter, tempo and pitch, channels.';

  @override
  String get toolMix => 'Mixing';

  @override
  String get toolMixDesc => 'Mix tracks, duck music under voice.';

  @override
  String get toolTranscribe => 'Transcription';

  @override
  String get toolTranscribeDesc => 'Speech to subtitles with whisper.';

  @override
  String get toolBurnSubs => 'Burn subtitles';

  @override
  String get toolBurnSubsDesc => 'Subtitles drawn into the picture, styled.';

  @override
  String get toolSoftSubs => 'Subtitle tracks';

  @override
  String get toolSoftSubsDesc => 'Add, extract or remove a subtitle track.';

  @override
  String get toolConvertSubs => 'Convert subtitles';

  @override
  String get toolConvertSubsDesc => 'SRT ↔ ASS ↔ VTT, timing shift, encoding.';

  @override
  String get toolGif => 'GIF & animations';

  @override
  String get toolGifDesc => 'High-quality palette GIF, animated WebP and APNG.';

  @override
  String get toolFrames => 'Extract frames';

  @override
  String get toolFramesDesc => 'Every Nth frame, by scene or at given times.';

  @override
  String get toolContactSheet => 'Contact sheet';

  @override
  String get toolContactSheetDesc => 'A grid of thumbnails from the video.';

  @override
  String get toolSlideshow => 'Slideshow';

  @override
  String get toolSlideshowDesc => 'Video from images with transitions.';

  @override
  String get toolAudioToVideo => 'Image + audio';

  @override
  String get toolAudioToVideoDesc => 'Video from a cover and audio, e.g. for YouTube.';

  @override
  String get toolVisualizer => 'Audio visualizer';

  @override
  String get toolVisualizerDesc => 'Waves, spectrum or vectorscope as video.';

  @override
  String get toolImageConvert => 'Convert images';

  @override
  String get toolImageConvertDesc => 'JPEG, PNG, WebP, AVIF: compress and convert.';

  @override
  String get toolTags => 'Tags';

  @override
  String get toolTagsDesc => 'Title, artist, album, year and more.';

  @override
  String get toolCover => 'Cover art';

  @override
  String get toolCoverDesc => 'Add, replace or extract cover art.';

  @override
  String get toolChapters => 'Chapters';

  @override
  String get toolChaptersDesc => 'Add, rename, import and export chapters.';

  @override
  String get toolScreenRecord => 'Screen recording';

  @override
  String get toolScreenRecordDesc => 'Full screen, region or window.';

  @override
  String get toolWebcam => 'Camera & mic';

  @override
  String get toolWebcamDesc => 'Record from webcam and microphone.';

  @override
  String get toolStream => 'Streaming';

  @override
  String get toolStreamDesc => 'RTMP / SRT to YouTube, Twitch or your server.';

  @override
  String get toolHls => 'HLS / DASH';

  @override
  String get toolHlsDesc => 'Packaging for web playback.';

  @override
  String get toolRepair => 'Repair';

  @override
  String get toolRepairDesc => 'Remux broken files, timestamps, A/V sync.';

  @override
  String get toolFaststart => 'MP4 faststart';

  @override
  String get toolFaststartDesc => 'Fast start for web playback.';

  @override
  String get toolDownload => 'Download from link';

  @override
  String get toolDownloadDesc => 'Video and audio from websites via yt-dlp.';

  @override
  String get toolBatch => 'Batch processing';

  @override
  String get toolBatchDesc => 'One operation for a folder or many files.';

  @override
  String get toolRecipes => 'Recipes';

  @override
  String get toolRecipesDesc => 'Operation chains: trim → normalize → compress.';

  @override
  String get toolWatchFolder => 'Watch folder';

  @override
  String get toolWatchFolderDesc => 'New files are processed automatically.';

  @override
  String get toolCommandEditor => 'Command editor';

  @override
  String get toolCommandEditorDesc => 'Your own ffmpeg command with completion.';

  @override
  String get toolFilterGraph => 'Filter graph builder';

  @override
  String get toolFilterGraphDesc => 'A filter chain as a list with parameters.';

  @override
  String get toolCommandLog => 'Command log';

  @override
  String get toolCommandLogDesc => 'Every command run, with logs.';

  @override
  String get queueEmptyTitle => 'The queue is empty';

  @override
  String get queueEmptyBody => 'Jobs from tools appear here with progress, speed and time left.';

  @override
  String get queueActive => 'Active and queued';

  @override
  String get queueHistory => 'History';

  @override
  String get clearFinished => 'Clear finished';

  @override
  String parallelJobsShort(int count) {
    return 'Parallel: $count';
  }

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusCompleted => 'Done';

  @override
  String statusCompletedWithFindings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems found',
      one: '$count problem found',
    );
    return '$_temp0';
  }

  @override
  String get statusNoProblems => 'No problems found';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCanceled => 'Canceled';

  @override
  String etaLabel(String time) {
    return '$time left';
  }

  @override
  String tookLabel(String time) {
    return 'took $time';
  }

  @override
  String attemptsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count attempts', one: '$count attempt');
    return '$_temp0';
  }

  @override
  String get priorityHigh => 'High priority';

  @override
  String get priorityRaise => 'Raise priority';

  @override
  String get priorityNormal => 'Normal priority';

  @override
  String get errToolMissing => 'A required tool was not found. Install it in Components.';

  @override
  String errFileNotFound(String path) {
    return 'File not found: $path';
  }

  @override
  String errPermissionDenied(String path) {
    return 'No access to file or folder: $path. Choose another output folder.';
  }

  @override
  String get errDiskFull => 'The disk is full.';

  @override
  String get errInvalidData => 'The file is damaged or its format is not supported. Try Repair or Integrity check.';

  @override
  String errEncoderMissing(String name) {
    return 'This ffmpeg build has no \"$name\" encoder. Pick another codec or install a full build.';
  }

  @override
  String errDecoderMissing(String name) {
    return 'This ffmpeg build has no \"$name\" decoder.';
  }

  @override
  String errFilterMissing(String name) {
    return 'This ffmpeg build has no \"$name\" filter. Install a full build in Components.';
  }

  @override
  String get errCodecContainer => 'The codec is not supported by this container. Try MKV: it accepts almost anything.';

  @override
  String get errOddDimensions => 'Width and height must be even for this codec. Enable size rounding.';

  @override
  String get errHwUnavailable =>
      'The hardware encoder is unavailable (no GPU or driver). Disable acceleration or pick a software codec.';

  @override
  String errInvalidArgument(String arg) {
    return 'Invalid option: $arg';
  }

  @override
  String get errStreamNotFound => 'The selected track does not exist in the file.';

  @override
  String get errSameAsInput => 'The output cannot overwrite the input. Choose another name.';

  @override
  String get errNetwork => 'Network problem. Check your connection and try again.';

  @override
  String get errUnsupportedUrl => 'This site or link is not supported.';

  @override
  String get errLoginRequired => 'Login required. Enable browser cookies in download settings.';

  @override
  String get errVideoUnavailable => 'The video is unavailable: removed, private or region-blocked.';

  @override
  String get errLoudnessMeasure => 'Could not measure loudness: the audio is silent or missing.';

  @override
  String get errCanceled => 'Canceled.';

  @override
  String get errUnknown => 'It did not work. See the full log for details.';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String lastChecked(String time) {
    return 'Checked at $time';
  }

  @override
  String get compFfmpeg => 'ffmpeg & ffprobe';

  @override
  String get compFfmpegDesc => 'The core engine: conversion, filters, analysis. Required.';

  @override
  String get compYtdlp => 'yt-dlp';

  @override
  String get compYtdlpDesc => 'Downloads video and audio from YouTube and thousands of sites.';

  @override
  String get compDeno => 'Deno';

  @override
  String get compDenoDesc => 'JavaScript runtime that yt-dlp needs for YouTube.';

  @override
  String get compAria2 => 'aria2c';

  @override
  String get compAria2Desc => 'Faster multi-connection downloads for yt-dlp.';

  @override
  String get originCustom => 'custom path';

  @override
  String get originManaged => 'installed by app';

  @override
  String get originSystem => 'system';

  @override
  String get originNone => 'not found';

  @override
  String get updateAvailable => 'update available';

  @override
  String get inUse => 'In use';

  @override
  String get installedVersion => 'Version';

  @override
  String get sourceLabel => 'Source';

  @override
  String get latestAvailable => 'Available';

  @override
  String get noChecksum => 'publisher provides no SHA-256';

  @override
  String removeComponentConfirm(String name) {
    return 'Remove \"$name\" and all saved versions?';
  }

  @override
  String componentError(String error) {
    return 'Error: $error';
  }

  @override
  String versionHistory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Installed versions ($count)',
      one: 'Installed versions ($count)',
    );
    return '$_temp0';
  }

  @override
  String get phaseResolving => 'Looking up the latest version…';

  @override
  String get phaseDownloading => 'Downloading';

  @override
  String get phaseVerifying => 'Verifying SHA-256…';

  @override
  String get phaseExtracting => 'Extracting…';

  @override
  String get phaseTesting => 'Testing the binary…';

  @override
  String get flavorFull => 'full';

  @override
  String get flavorEssentials => 'essentials';

  @override
  String get channelRelease => 'release';

  @override
  String get channelNightly => 'nightly';

  @override
  String get channelStable => 'stable';

  @override
  String get btbnHint => 'BtbN static builds. GPL has everything incl. x264/x265; LGPL omits GPL codecs.';

  @override
  String get gyanHint => 'gyan.dev Windows builds. full has the most filters and codecs (whisper, vmaf, frei0r).';

  @override
  String get customPathNone => 'You can point to your own binary instead.';

  @override
  String customPathValue(String path) {
    return 'Using custom path: $path';
  }

  @override
  String get useCustomBinary => 'Use my own';

  @override
  String installViaPackageManager(String pkg) {
    return 'Install the \"$pkg\" package with your system package manager.';
  }

  @override
  String get buildInfoTitle => 'ffmpeg build capabilities';

  @override
  String get licenseLabel => 'License';

  @override
  String get encoders => 'Encoders';

  @override
  String get decoders => 'Decoders';

  @override
  String get filters => 'Filters';

  @override
  String get muxers => 'Muxers';

  @override
  String get configuration => 'Configuration';

  @override
  String get hwTitle => 'Hardware acceleration';

  @override
  String get redetect => 'Re-detect';

  @override
  String get hwDetecting => 'Trial-encoding on each accelerator…';

  @override
  String get hwDecode => 'Decoding';

  @override
  String get hwBestDecode => 'Best for decoding';

  @override
  String get hwEncoders => 'Working encoders';

  @override
  String get hwSoftwareOnly => 'software only';

  @override
  String get hwNoneWorking => 'none, encoding will use the CPU';

  @override
  String hwFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count failed the check',
      one: '$count failed the check',
    );
    return '$_temp0';
  }

  @override
  String get plannedComponents => 'Coming soon';

  @override
  String get compRnnoise => 'RNNoise models (voice denoise)';

  @override
  String get compVmaf => 'VMAF models (quality metrics)';

  @override
  String get compWhisper => 'whisper.cpp models (transcription)';

  @override
  String get compFrei0r => 'frei0r and LADSPA/LV2 plugins';

  @override
  String get compLuts => '3D LUT packs (.cube)';

  @override
  String get compFonts => 'Fonts for subtitles and text';

  @override
  String get downloadsSoonTitle => 'Link downloads arrive in stage 2';

  @override
  String downloadsReady(String path) {
    return 'yt-dlp is ready: $path';
  }

  @override
  String get downloadsNeedYtdlp => 'Downloads need yt-dlp. You can install it now.';

  @override
  String get presetsSoonTitle => 'Presets arrive with conversion tools';

  @override
  String get presetsSoonBody =>
      '\"For Telegram\", \"For YouTube\", \"For Discord (≤10 MB)\", \"For editing\", \"Lossless archive\" and your own, exportable to JSON.';

  @override
  String get settingsSearchHint => 'Search settings';

  @override
  String showAdvanced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count more advanced settings',
      one: 'Show $count more advanced setting',
    );
    return '$_temp0';
  }

  @override
  String get secGeneral => 'General';

  @override
  String get secAppearance => 'Appearance';

  @override
  String get secPerformance => 'Performance';

  @override
  String get secPaths => 'Paths & folders';

  @override
  String get secDownloads => 'Downloads (yt-dlp)';

  @override
  String get secUpdates => 'Components & updates';

  @override
  String get secNotifications => 'Notifications';

  @override
  String get secExpert => 'For experts';

  @override
  String get setLanguage => 'Interface language';

  @override
  String get setLanguageHint => 'Follows the system by default';

  @override
  String get languageSystem => 'System';

  @override
  String get setAdvancedMode => 'Advanced mode';

  @override
  String get setAdvancedModeHint => 'Show every option, not only the main ones';

  @override
  String get setAdvancedModeHelp =>
      'Simple mode shows only the options needed 90% of the time; the rest use sensible defaults. Advanced mode reveals everything: codec profiles and levels, pixel formats, thread counts and so on. Search finds advanced settings in either mode. Default: off.';

  @override
  String get setTheme => 'Theme';

  @override
  String get setThemeHint => 'Light, dark or follow the system';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get setAccent => 'Accent color';

  @override
  String get setAccentHint => 'Color of buttons and highlights';

  @override
  String get setAccentHelp =>
      '\"System\" takes the accent from Windows or GNOME/KDE settings (Material You). If the system provides none, the color picked below is used. Default: system.';

  @override
  String get accentSystem => 'System';

  @override
  String get accentCustom => 'Custom';

  @override
  String get setParallel => 'Parallel jobs';

  @override
  String get setParallelHint => 'How many queue jobs run at the same time';

  @override
  String get setParallelHelp =>
      'ffmpeg already uses all CPU cores, so 1–2 jobs is usually best for re-encoding: each finishes sooner. More jobs help with light work (remux, lossless trim, downloads) and with hardware encoding, where the GPU can handle several streams. Recommended: 1–2. Default: 1.';

  @override
  String get zoneFasterEach => 'each one faster';

  @override
  String get zoneMoreAtOnce => 'more at once';

  @override
  String get setHwAccel => 'Hardware acceleration';

  @override
  String get setHwAccelHint => 'Encode on the GPU when one is found';

  @override
  String get setHwAccelHelp =>
      'NVENC (NVIDIA), Quick Sync (Intel), AMF (AMD), VAAPI and Vulkan encode many times faster than the CPU, but quality per file size is slightly lower. Turn off for archiving and maximum quality. What was found is shown in Components. Default: on.';

  @override
  String get setRetries => 'Retries on failure';

  @override
  String get setRetriesHint => 'How many times to restart a failed job';

  @override
  String get setRetriesHelp =>
      'Useful for downloads and network sources where failures are often temporary. Local file errors usually repeat, so the default is 0.';

  @override
  String get setThreads => 'ffmpeg threads';

  @override
  String get setThreadsHint => 'Limit CPU threads per job';

  @override
  String get setThreadsHelp =>
      '\"auto\" lets ffmpeg choose. Set a limit to keep the CPU free for other apps while encoding. Default: auto.';

  @override
  String get setOutputDir => 'Output folder';

  @override
  String get setOutputDirHint => 'Where finished files go';

  @override
  String get setOutputDirHelp =>
      'If not set, results go to a \"Kadra\" folder in Videos (or your home folder). Each tool also lets you choose a location manually.';

  @override
  String outputDirDefault(String path) {
    return 'Default: $path';
  }

  @override
  String get setCustomFfmpeg => 'Custom ffmpeg';

  @override
  String get setCustomFfmpegHint => 'Path to an existing ffmpeg';

  @override
  String get setCustomFfmpegHelp =>
      'Takes priority over the downloaded component and system PATH. ffprobe is looked up next to it. Useful for custom builds with extra libraries.';

  @override
  String get setCustomFfprobe => 'Custom ffprobe';

  @override
  String get setCustomFfprobeHint => 'If it is not next to ffmpeg';

  @override
  String get setCustomYtdlp => 'Custom yt-dlp';

  @override
  String get setCustomYtdlpHint => 'Path to an existing yt-dlp';

  @override
  String get setFragments => 'Concurrent fragments';

  @override
  String get setFragmentsHint => 'How many video fragments to download at once';

  @override
  String get setFragmentsHelp =>
      'yt-dlp --concurrent-fragments. Speeds up streaming formats (DASH/HLS) from YouTube and others. Too high may get you temporarily throttled. Recommended: 4–8. Default: 4.';

  @override
  String get zoneGentle => 'gentler on the site';

  @override
  String get zoneFaster => 'faster';

  @override
  String get setPolicyFfmpeg => 'ffmpeg updates';

  @override
  String get setPolicyHint => 'What to do when a new version is out';

  @override
  String get setPolicyYtdlp => 'yt-dlp updates';

  @override
  String get setPolicyYtdlpHint => 'Sites change often, so automatic is best';

  @override
  String get setPolicyOther => 'Other component updates';

  @override
  String get setPolicyHelp =>
      '\"Automatic\" checks and installs at startup; \"Ask\" shows an update badge in Components; \"Never\" does not check. The previous version is kept so you can roll back. Default: yt-dlp automatic, others ask.';

  @override
  String get policyAuto => 'Automatic';

  @override
  String get policyAsk => 'Ask';

  @override
  String get policyNever => 'Never';

  @override
  String get setKeepVersions => 'Keep previous versions';

  @override
  String get setKeepVersionsHint => 'How many old versions to keep for rollback';

  @override
  String get setKeepVersionsHelp => 'Each ffmpeg version takes 100–250 MB. 0 disables rollback. Default: 2.';

  @override
  String get zoneLessDisk => 'less disk';

  @override
  String get zoneMoreRollback => 'more rollback';

  @override
  String get setNotify => 'Notify when done';

  @override
  String get setNotifyHint => 'A system notification when a job finishes';

  @override
  String get setShowCommand => 'Show command before running';

  @override
  String get setShowCommandHint => 'Review and edit the ffmpeg command';

  @override
  String get setShowCommandHelp =>
      'Before queueing, the generated ffmpeg command opens so you can copy, edit and run it. \"Show command\" is available on every job regardless. Default: off.';

  @override
  String get back => 'Back';

  @override
  String get change => 'Change';

  @override
  String get apply => 'Apply';

  @override
  String get rename => 'Rename';

  @override
  String get save => 'Save';

  @override
  String get none => 'none';

  @override
  String get keepOriginal => 'Keep original';

  @override
  String get stereo => 'Stereo';

  @override
  String get mono => 'Mono';

  @override
  String get toEnd => 'to the end';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get runNow => 'Run now';

  @override
  String get otherFile => 'Other file';

  @override
  String saveTo(String path) {
    return 'Save to: $path';
  }

  @override
  String get chooseInputTitle => 'Choose a file';

  @override
  String get commandEditHint => 'You can edit the arguments before running (the ffmpeg path is added automatically).';

  @override
  String get commandParseError => 'Unterminated quote in the command';

  @override
  String get runCommand => 'Run';

  @override
  String stepLabel(String step) {
    return 'step $step';
  }

  @override
  String secondsShort(String value) {
    return '$value s';
  }

  @override
  String estimateSize(String size) {
    return '≈ $size';
  }

  @override
  String estimateAtMost(String size) {
    return 'at most $size';
  }

  @override
  String get estimateDependsOnContent => 'Size depends on the content';

  @override
  String encoderLabel(String name) {
    return 'encoder $name';
  }

  @override
  String get issueNoEncoder =>
      'The installed ffmpeg build has no encoder for this codec. Pick another codec or install a full build.';

  @override
  String get issueVideoContainer =>
      'This container does not support the selected video codec. Pick another codec or MKV.';

  @override
  String get issueAudioContainer =>
      'This container does not support the selected audio codec. Pick another codec or MKV.';

  @override
  String get issueCopyContainer => 'The source codec cannot be copied into this container. Try MKV.';

  @override
  String get issueDurationUnknown => 'The file duration is unknown, so size or trim cannot be calculated.';

  @override
  String get issueTargetTooSmall =>
      'The size is too small for this duration: less than 50 kb/s would remain for video. Increase the size or shorten the video.';

  @override
  String get issueNoTenBit => 'This encoder cannot do 10-bit; 8-bit will be used.';

  @override
  String get issueNoAudio => 'The file has no audio track.';

  @override
  String get issueNoVideo => 'The file has no video.';

  @override
  String get issueChooseAudio => 'Choose an audio file.';

  @override
  String get warnHdrSource =>
      'The source is HDR. Without 10-bit and tone mapping colors will look washed out; proper HDR → SDR comes in the next stage.';

  @override
  String get warnLongGif => 'A GIF longer than 20 seconds will be huge. WebP or video is better.';

  @override
  String get groupFormat => 'Format';

  @override
  String get groupVideo => 'Video';

  @override
  String get groupAudio => 'Audio';

  @override
  String get groupOther => 'Other';

  @override
  String get groupTrim => 'Fragment';

  @override
  String get groupLoudness => 'Loudness';

  @override
  String get groupAnimation => 'Animation';

  @override
  String get groupDownloadQuality => 'Quality';

  @override
  String get groupDownloadExtras => 'Extras';

  @override
  String get presetsTitle => 'Presets';

  @override
  String get savePreset => 'Save as preset';

  @override
  String get presetNameLabel => 'Preset name';

  @override
  String get builtinPresets => 'Built-in';

  @override
  String get userPresets => 'My presets';

  @override
  String get userPresetsEmpty => 'Nothing yet. Set up Convert and press \"Save as preset\".';

  @override
  String get importPresets => 'Import';

  @override
  String get exportPresets => 'Export';

  @override
  String presetsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count presets',
      one: 'Imported $count preset',
    );
    return '$_temp0';
  }

  @override
  String presetsExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count presets',
      one: 'Exported $count preset',
    );
    return '$_temp0';
  }

  @override
  String get presetsImportFailed => 'This is not a Kadra presets file.';

  @override
  String get presetTelegram => 'For Telegram';

  @override
  String get presetTelegramDesc => 'H.264 up to 1080p with fast start; plays right in the chat.';

  @override
  String get presetYoutube => 'For YouTube';

  @override
  String get presetYoutubeDesc => 'High quality (CRF 18), AAC 320 kb/s 48 kHz; YouTube re-encodes anyway.';

  @override
  String get presetDiscord => 'For Discord (≤10 MB)';

  @override
  String get presetDiscordDesc => 'Two-pass to 9.5 MB, up to 720p; fits the free limit.';

  @override
  String get presetEditProres => 'For editing (ProRes)';

  @override
  String get presetEditProresDesc => 'ProRes 422 HQ + PCM: easy to edit, large files.';

  @override
  String get presetEditDnxhr => 'For editing (DNxHR)';

  @override
  String get presetEditDnxhrDesc => 'DNxHR HQ + PCM for Avid and DaVinci Resolve.';

  @override
  String get presetArchive => 'Lossless archive';

  @override
  String get presetArchiveDesc => 'FFV1 + FLAC in MKV: bit-exact, no quality loss.';

  @override
  String get presetMaxCompression => 'Maximum compression';

  @override
  String get presetMaxCompressionDesc => 'AV1 10-bit + Opus: smallest files at good quality, but slow to encode.';

  @override
  String get presetCompress => 'Just compress';

  @override
  String get presetCompressDesc => 'H.264, slightly lower quality, up to 1080p; usually 2–5× smaller.';

  @override
  String get codecCopy => 'Copy (no re-encode)';

  @override
  String get codecNoVideo => 'No video';

  @override
  String get codecNoAudio => 'No audio';

  @override
  String get codecFfv1 => 'FFV1 (lossless)';

  @override
  String get codecFlac => 'FLAC (lossless)';

  @override
  String get codecAlac => 'ALAC (lossless)';

  @override
  String get speedFastest => 'fastest';

  @override
  String get speedFast => 'fast';

  @override
  String get speedMedium => 'medium';

  @override
  String get speedSlow => 'slow';

  @override
  String get speedSlowest => 'slowest';

  @override
  String get rateQuality => 'Quality';

  @override
  String get rateBitrate => 'Bitrate';

  @override
  String get rateCbr => 'Constant';

  @override
  String get rateTargetSize => 'File size';

  @override
  String get zoneBetterQuality => 'better quality';

  @override
  String get zoneSmallerFile => 'smaller file';

  @override
  String get zoneSmoother => 'smoother';

  @override
  String get pContainer => 'Container (file format)';

  @override
  String get pContainerHint => 'What wraps the video and audio';

  @override
  String get pContainerHelp =>
      'The container is the \"box\" holding the tracks. MP4 plays everywhere (phones, browsers, messengers). MKV accepts almost any codec and subtitles; good for archiving. MOV is for Apple and editing. WebM is for the web (VP9/AV1 + Opus). Audio only: MP3, M4A, Opus, FLAC, WAV. Default: MP4.';

  @override
  String get pVideoCodec => 'Video codec';

  @override
  String get pVideoCodecHint => 'How the picture is compressed';

  @override
  String get pVideoCodecHelp =>
      'H.264: maximum compatibility. H.265: 30–50% smaller at the same quality but not supported everywhere. AV1: smaller still, slower to encode (fast on new GPUs). VP9: for WebM. ProRes and DNxHR: for editing (large files). FFV1: lossless. \"Copy\": instant and lossless if the container fits. Default: H.264.';

  @override
  String get pAudioCodec => 'Audio codec';

  @override
  String get pAudioCodecHint => 'How the audio is compressed';

  @override
  String get pHardware => 'Hardware encoding';

  @override
  String pHardwareOn(String name) {
    return 'Using the GPU: $name';
  }

  @override
  String pHardwareOff(String name) {
    return 'Encoding on the CPU: $name';
  }

  @override
  String get pHardwareHelp =>
      'The GPU (NVENC, Quick Sync, AMF, VAAPI) encodes 5–20× faster than the CPU, but quality per file size is slightly lower. Turn on for quick jobs, off for archiving and smallest size. Without a suitable GPU the CPU is used. Default: on.';

  @override
  String get pEncoder => 'Encoder';

  @override
  String get pEncoderHint => 'A specific implementation from the ffmpeg build';

  @override
  String get pRateMode => 'Mode';

  @override
  String get pRateModeHint => 'How size and quality are controlled';

  @override
  String get pRateModeHelp =>
      '\"Quality\" (CRF/CQ) is nearly always best: constant quality, size adapts to scene complexity. \"Bitrate\": average kb/s, predictable size. \"Constant\": the same rate throughout, for streaming and old players. \"File size\": enter the megabytes you need (e.g. a messenger limit); bitrate is computed, two-pass when possible. Default: Quality.';

  @override
  String pQuality(String scale) {
    return 'Quality ($scale)';
  }

  @override
  String get pQualityHint => 'Lower number: better quality, bigger file';

  @override
  String pQualityHelp(int value) {
    return 'This is the encoder\'s \"constant quality\": every scene is encoded to look equally good. A change of 6 roughly doubles or halves the size. For x264: 18 is visually lossless, 23 is standard, 28 is noticeably worse. AV1/VP9 use a scale up to 63. Default for this encoder: $value.';
  }

  @override
  String get pVideoBitrate => 'Video bitrate';

  @override
  String get pVideoBitrateHint => 'Kilobits per second for video';

  @override
  String get pVideoBitrateHelp =>
      'H.264 guide: 1080p 4000–8000, 720p 2500–5000, 480p 1000–2000 kb/s. H.265/AV1 need about 30–50% less.';

  @override
  String get pTargetSize => 'File size';

  @override
  String get pTargetSizeHint => 'The result will not exceed this';

  @override
  String get pTargetSizeHelp =>
      'The bitrate is computed from duration: (size × 8) / seconds − audio, with 3% headroom for the container. Too small a size for a long video looks blurry; lower the resolution. Discord: 10 MB (use 9.5), Telegram bots: 50 MB.';

  @override
  String get pTwoPass => 'Two-pass';

  @override
  String get pTwoPassHint => 'Hits the size more precisely, takes twice as long';

  @override
  String get pTwoPassHelp =>
      'The first pass analyzes the video, the second distributes bits: more to complex scenes, less to simple ones. Best quality at a given size. Not needed in Quality mode. Default: on.';

  @override
  String get pSpeed => 'Encoding speed';

  @override
  String get pSpeedHint => 'Slower: smaller file at the same quality';

  @override
  String get pSpeedHelp =>
      'The encoder speed preset (x264 veryfast…veryslow, NVENC p1…p7, SVT-AV1 12…4). Quality is set separately; a slower preset just compresses better. \"Medium\" is a good balance; \"slow\" saves 5–10% for 2–3× the time. Default: medium.';

  @override
  String get pResolution => 'Resolution';

  @override
  String get pResolutionHint => 'Downscale to this height (never upscales)';

  @override
  String get pResolutionHelp =>
      'The aspect ratio is kept and the width rounded to even. Lowering the resolution is the most effective way to shrink: 1080p → 720p roughly halves the file. Default: keep original.';

  @override
  String get pFps => 'Frame rate';

  @override
  String get pFpsHint => 'Frames per second';

  @override
  String get pTenBit => '10-bit';

  @override
  String get pTenBitHint => 'Less banding on gradients, needed for HDR';

  @override
  String get pTenBitHelp =>
      '10 bits per channel remove banding in skies and shadows and slightly improve H.265/AV1 compression. Old devices and some browsers cannot play 10-bit H.264. Default: off.';

  @override
  String get pProfile => 'Profile';

  @override
  String get pProfileHint => 'Codec compatibility constraints';

  @override
  String get pIntermediateProfileHint => 'Quality and size of the editing format';

  @override
  String get pIntermediateProfileHelp =>
      'ProRes: proxy < lt < standard < hq < 4444 < 4444xq. DNxHR: lb < sq < hq < hqx (10-bit) < 444. HQ is usually enough for editing. Default: HQ.';

  @override
  String get pTune => 'Tune';

  @override
  String get pTuneHint => 'Optimize for the type of content';

  @override
  String get pTuneHelp =>
      'film: live action, animation: cartoons, grain: keep film grain, stillimage: slideshows, zerolatency: low-latency streaming. Default: none.';

  @override
  String get pKeyint => 'Keyframe interval';

  @override
  String get pKeyintHint => 'How often playback can start from any point';

  @override
  String get pKeyintHelp =>
      'More frequent keyframes mean faster seeking and more precise fast trims, but larger files. YouTube and streaming recommend 2 seconds. Default: auto (encoder decides).';

  @override
  String get pAudioBitrate => 'Audio bitrate';

  @override
  String get pAudioBitrateHint => 'Higher: better sound, bigger file';

  @override
  String get pAudioBitrateHelp =>
      'Guide: AAC 128 is fine for speech and music, 192–256 for music, 320 is the maximum. Opus already sounds good at 96. MP3 320 is the format limit. Default: depends on the codec.';

  @override
  String get pChannels => 'Channels';

  @override
  String get pChannelsHint => 'E.g. downmix 5.1 to stereo';

  @override
  String get pSampleRate => 'Sample rate';

  @override
  String get pSampleRateHint => '48 kHz for video, 44.1 kHz for music';

  @override
  String get pFaststart => 'Fast start';

  @override
  String get pFaststartHint => 'Starts playing in a browser before fully downloaded';

  @override
  String get pFaststartHelp =>
      'Moves the index (moov) to the start of MP4/MOV. Needed for websites and messengers, costs nothing. Default: on.';

  @override
  String get pKeepSubs => 'Keep subtitles';

  @override
  String get pKeepSubsHint => 'Copy subtitle tracks as is';

  @override
  String get pKeepMetadata => 'Keep metadata';

  @override
  String get pKeepMetadataHint => 'Tags, chapters, capture date. Turn off to strip them';

  @override
  String get pTrimMode => 'Trim method';

  @override
  String get trimFast => 'Fast';

  @override
  String get trimPrecise => 'Frame-accurate';

  @override
  String get trimFastHint => 'Instant and lossless; starts at the nearest keyframe';

  @override
  String get trimPreciseHint => 'Re-encodes: exact boundaries, takes longer';

  @override
  String get pTrimModeHelp =>
      'Video is stored in groups of frames that start with a keyframe. Fast trimming copies data as is, so it may start slightly before your point, at the nearest keyframe (usually 0–5 s). Frame-accurate re-encodes the fragment and cuts exactly; quality is barely affected.';

  @override
  String get pStart => 'Start';

  @override
  String get pStartHint => 'HH:MM:SS.ms or seconds';

  @override
  String get pEnd => 'End';

  @override
  String pEndHint(String total) {
    return 'File duration: $total';
  }

  @override
  String keyframeStartHint(String time) {
    return 'Will actually start at $time (keyframe)';
  }

  @override
  String setStartHere(String time) {
    return 'Start = $time';
  }

  @override
  String setEndHere(String time) {
    return 'End = $time';
  }

  @override
  String trimLength(String time) {
    return 'Fragment: $time';
  }

  @override
  String get pTrack => 'Track';

  @override
  String get pTrackHint => 'Which audio track to extract';

  @override
  String get pExtractFormat => 'Format';

  @override
  String get pExtractFormatHint => 'Re-encode to the chosen format';

  @override
  String get pExtractFormatHelp =>
      '\"As is\" copies the audio unchanged: instant and lossless, the file type matches the codec. Choose MP3/AAC/Opus for a specific player format, FLAC/WAV for lossless editing.';

  @override
  String get extractAsIs => 'As is (no re-encode)';

  @override
  String extractCopyHint(String ext) {
    return 'You will get a lossless .$ext file';
  }

  @override
  String get pTrackMode => 'Action';

  @override
  String get trackReplace => 'Replace';

  @override
  String get trackAdd => 'Add';

  @override
  String get trackRemove => 'Remove audio';

  @override
  String get trackReplaceHint => 'Drop the old audio and use the new one';

  @override
  String get trackAddHint => 'Keep existing tracks and add another (e.g. a dub)';

  @override
  String get trackRemoveHint => 'Make the video silent';

  @override
  String get pAudioFile => 'Audio file';

  @override
  String get pAudioFileHint => 'Audio can come from any audio or video file';

  @override
  String get pShortest => 'Stop at the shortest track';

  @override
  String get pShortestHint => 'End the result when video or audio ends';

  @override
  String get pLanguage => 'Track language';

  @override
  String get pLanguageHint => 'Players show it in the track menu';

  @override
  String get losslessVideoTag => 'video not re-encoded';

  @override
  String get videoCopiedNote => 'Video is copied: fast and lossless';

  @override
  String get pLoudTarget => 'Target loudness';

  @override
  String pLoudTargetHint(String lufs, String tp) {
    return '$lufs LUFS, peaks at most $tp dBTP';
  }

  @override
  String get pLoudTargetHelp =>
      'LUFS is perceived loudness. Platforms turn down anything too loud, so it is best to hit their target: YouTube and Spotify −14, podcasts (Apple) −16, TV per EBU R128 −23. True Peak limits peaks so MP3/AAC compression does not distort.';

  @override
  String get loudStreaming => 'YouTube, Spotify';

  @override
  String get loudPodcast => 'Podcast';

  @override
  String get loudBroadcast => 'TV (EBU R128)';

  @override
  String get loudApple => 'Apple Music';

  @override
  String get pTwoPassLoud => 'Two-pass normalization';

  @override
  String get pTwoPassLoudOn => 'Measure first, then adjust precisely';

  @override
  String get pTwoPassLoudOff => 'One pass: faster, but adjusts dynamically';

  @override
  String get pTwoPassLoudHelp =>
      'The first pass measures the whole file, the second applies one gain everywhere: dynamics are preserved and the result hits the target. One-pass mode adjusts on the fly and may pump. Default: two-pass.';

  @override
  String normalizeNote(String codec) {
    return 'Audio will be re-encoded ($codec), video copied';
  }

  @override
  String get pAnimFormat => 'Format';

  @override
  String get pAnimFormatHint => 'GIF works everywhere; WebP and APNG look better and are smaller';

  @override
  String get pAnimFormatHelp =>
      'GIF is limited to 256 colors, so an optimal palette is built for the clip. WebP gives full-color animation 2–5× smaller. APNG is lossless but heavy. Default: GIF.';

  @override
  String get pDuration => 'Duration';

  @override
  String get pDurationHint => 'Empty means to the end';

  @override
  String get pGifFps => 'Frames per second';

  @override
  String get pGifFpsHint => '10–15 is usually enough';

  @override
  String get pGifWidth => 'Width';

  @override
  String get pGifWidthHint => 'Height follows the aspect ratio';

  @override
  String get pDither => 'Dithering';

  @override
  String get pDitherHint => 'How missing colors are simulated';

  @override
  String get pDitherHelp =>
      'Sierra: soft and clean (default). Floyd–Steinberg: more detail, more noise. Bayer: regular pattern, compresses well. None: banding on gradients but smaller files.';

  @override
  String get pStaticBg => 'Static background';

  @override
  String get pStaticBgHint => 'Better colors when only part of the frame moves';

  @override
  String get pWebpQuality => 'WebP quality';

  @override
  String get pWebpQualityHint => '75 is a good balance';

  @override
  String get pLoop => 'Loop';

  @override
  String get pLoopHint => 'Repeat the animation forever';

  @override
  String gifFrames(int count) {
    return '$count frames';
  }

  @override
  String get urlsLabel => 'Links';

  @override
  String get urlsHint => 'Paste one or more links (video, playlist or channel)';

  @override
  String pasteFromClipboard(String url) {
    return 'Paste from clipboard: $url';
  }

  @override
  String get analyzeLinks => 'Get info';

  @override
  String get downloadWithoutAnalysis => 'Download now';

  @override
  String get download => 'Download';

  @override
  String downloadN(int count) {
    return 'Download ($count)';
  }

  @override
  String downloadsQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads queued',
      one: '$count download queued',
    );
    return '$_temp0';
  }

  @override
  String get downloadsNeedYtdlpTitle => 'yt-dlp is required';

  @override
  String get denoHint => 'Tip: install Deno in Components for YouTube; without it some formats are unavailable.';

  @override
  String selectedOf(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get selectAll => 'All';

  @override
  String get selectNone => 'None';

  @override
  String get rangesHint => 'Numbers: 1,3,5-10';

  @override
  String availableQualities(String list) {
    return 'Available: $list';
  }

  @override
  String get exactFormat => 'Exact format (optional)';

  @override
  String get exactFormatAuto => 'Automatic from quality below';

  @override
  String get videoOnly => 'video only';

  @override
  String get pYtQuality => 'Quality';

  @override
  String get pYtQualityHint => 'Best available or at most the chosen height';

  @override
  String get ytBest => 'Best';

  @override
  String ytUpTo(String height) {
    return 'up to $height';
  }

  @override
  String get ytAudioOnly => 'Audio only';

  @override
  String get pYtAudioFormat => 'Audio format';

  @override
  String get pYtAudioFormatHint => 'Format to save the audio in';

  @override
  String get pYtContainerHint => 'MP4 for compatibility, MKV without limits';

  @override
  String get pYtContainerHelp =>
      'Sites often serve video and audio separately; yt-dlp merges them with ffmpeg into the chosen container. For MP4, H.264/AAC is preferred to avoid re-encoding. \"As on the site\" keeps the original format (often WebM).';

  @override
  String get ytContainerAuto => 'As on the site';

  @override
  String get pYtSubs => 'Subtitles';

  @override
  String get pYtSubsHint => 'Download and embed creator subtitles';

  @override
  String get pYtAutoSubs => 'Automatic subtitles';

  @override
  String get pYtAutoSubsHint => 'Generated by the site (e.g. YouTube)';

  @override
  String get pYtSubLangs => 'Subtitle languages';

  @override
  String get pYtSubLangsHint => 'Comma-separated: ru,en or all';

  @override
  String get pYtEmbed => 'Cover, metadata and chapters';

  @override
  String get pYtEmbedHint => 'Embed into the file';

  @override
  String get pSponsorBlock => 'SponsorBlock';

  @override
  String get pSponsorBlockHint => 'Creator sponsor segments';

  @override
  String get pSponsorBlockHelp =>
      'Uses the sponsor.ajay.app database. \"Mark\" adds chapters; \"Remove\" cuts sponsor segments, self-promotion and subscribe reminders (re-encodes around cuts).';

  @override
  String get sbOff => 'Off';

  @override
  String get sbMark => 'Mark as chapters';

  @override
  String get sbRemove => 'Remove';

  @override
  String get pCookies => 'Browser cookies';

  @override
  String get pCookiesHint => 'For private, age-restricted and \"confirm you are not a bot\"';

  @override
  String get pCookiesHelp =>
      'yt-dlp reads your login cookies from the chosen browser, as if the video were opened there. Close the browser first (Chrome locks its cookie file). Cookies go nowhere except to the site itself.';

  @override
  String get pArchive => 'Skip already downloaded';

  @override
  String get pArchiveHint => 'Keep a list of downloaded videos in the output folder';

  @override
  String get pTemplate => 'File name template';

  @override
  String get pTemplateHint => 'yt-dlp fields: %(title)s, %(id)s, %(uploader)s…';

  @override
  String get pTemplateHelp =>
      'E.g. \"%(uploader)s/%(title)s.%(ext)s\" sorts videos into channel folders. All fields are in the yt-dlp docs (OUTPUT TEMPLATE).';

  @override
  String get pRateLimit => 'Rate limit';

  @override
  String get pRateLimitHint => 'E.g. 5M = 5 MB/s; empty means unlimited';

  @override
  String get pProxy => 'Proxy';

  @override
  String get pProxyHint => 'http://, https:// or socks5://';

  @override
  String get setNextToSource => 'Save next to the source';

  @override
  String get setNextToSourceHint => 'Put results in the same folder as the source file';

  @override
  String get setAria2 => 'Download with aria2c';

  @override
  String get setAria2Hint => 'Multi-connection downloads when aria2c is installed';

  @override
  String get setAria2Help =>
      'aria2c opens several connections and is often faster with slow servers. For YouTube the built-in concurrent fragments are usually enough. Default: off.';
}
