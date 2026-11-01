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
  String get toolSplitDesc => 'By length, into equal parts, by chapters or at marked points.';

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
  String get pShortest => 'End with the shortest';

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

  @override
  String get toolAudioEditor => 'Audio editor';

  @override
  String get toolAudioEditorDesc => 'Multitrack editor: editing, effects, generators, analysis, recording.';

  @override
  String get cut => 'Cut';

  @override
  String get paste => 'Paste';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String undoX(String action) {
    return 'Undo $action';
  }

  @override
  String redoX(String action) {
    return 'Redo $action';
  }

  @override
  String get preview => 'Preview';

  @override
  String get generate => 'Generate';

  @override
  String get export => 'Export';

  @override
  String get record => 'Record';

  @override
  String get stop => 'Stop';

  @override
  String get mute => 'Mute';

  @override
  String get solo => 'Solo';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get zoomIn => 'Zoom in (Ctrl+=)';

  @override
  String get zoomOut => 'Zoom out (Ctrl+−)';

  @override
  String get zoomSelection => 'Zoom to selection (Ctrl+E)';

  @override
  String get zoomFit => 'Fit project (Ctrl+F)';

  @override
  String get unitDb => 'dB';

  @override
  String get unitMs => 'ms';

  @override
  String get unitSemitones => 'semitones';

  @override
  String get unitBpm => 'BPM';

  @override
  String get unitDbOct => 'dB/oct';

  @override
  String get menuFile => 'File';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuGenerate => 'Generate';

  @override
  String get menuEffects => 'Effects';

  @override
  String get menuAnalyze => 'Analyze';

  @override
  String get menuTracks => 'Tracks';

  @override
  String get aeNew => 'New project';

  @override
  String get aeOpenProject => 'Open project…';

  @override
  String get aeSaveProject => 'Save project';

  @override
  String get aeSaveProjectAs => 'Save project as…';

  @override
  String get aeImport => 'Import audio…';

  @override
  String get aeImportLabels => 'Import labels…';

  @override
  String get aeExportLabels => 'Export labels…';

  @override
  String get aeDelete => 'Delete';

  @override
  String get aeSilence => 'Silence audio';

  @override
  String get aeTrim => 'Trim to selection';

  @override
  String get aeDuplicate => 'Duplicate to new track';

  @override
  String get aeSplitNew => 'Split to new track';

  @override
  String get aeCrossfade => 'Crossfade at cursor';

  @override
  String get aeSelectAll => 'Select all';

  @override
  String get aeNoiseProfile => 'Get noise profile from selection';

  @override
  String get addLabel => 'Add label';

  @override
  String get editLabel => 'Edit label';

  @override
  String get labelText => 'Label text';

  @override
  String get labelHint => 'Click: select, double-click: rename, right-click: delete';

  @override
  String get labelsTrack => 'Labels';

  @override
  String labelsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels added',
      one: '$count label added',
    );
    return '$_temp0';
  }

  @override
  String get aeAddTrack => 'Add track from file…';

  @override
  String get aeMixRender => 'Mix and render to new track';

  @override
  String get aeSplitStereo => 'Split stereo to mono';

  @override
  String get aeSpectrogramView => 'Show spectrogram';

  @override
  String get aeWaveformView => 'Show waveform';

  @override
  String get aeClearEnvelope => 'Clear envelope';

  @override
  String get aeRemoveTrack => 'Remove track';

  @override
  String get trackName => 'Track name';

  @override
  String get trackGain => 'Track gain';

  @override
  String get trackPan => 'Pan';

  @override
  String get aePlayHint => 'Play / pause (Space)';

  @override
  String get aePlaySelection => 'Play selection (Shift+Space)';

  @override
  String get aeLoop => 'Loop selection';

  @override
  String get toolSelect => 'Selection tool';

  @override
  String get toolShift => 'Time shift tool';

  @override
  String get toolEnvelope => 'Envelope tool';

  @override
  String aeCursorAt(String time) {
    return 'Cursor: $time';
  }

  @override
  String aeSelectionInfo(String start, String end, String length) {
    return 'Selection: $start – $end ($length)';
  }

  @override
  String get aeEmptyTitle => 'Audio editor';

  @override
  String get aeEmptyBody => 'Drop audio or video here, open a project or start recording.';

  @override
  String get aeNeedSelection => 'Select a region first.';

  @override
  String get aeStatusHint =>
      'Drag on the waveform to select; Ctrl+wheel zooms, Shift+wheel scrolls; click a track name to select it.';

  @override
  String applyToSelection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Applies to the selection on $count tracks',
      one: 'Applies to the selection on $count track',
    );
    return '$_temp0';
  }

  @override
  String applyToWholeTracks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No selection: applies to $count whole tracks',
      one: 'No selection: applies to the whole track',
    );
    return '$_temp0';
  }

  @override
  String get fxBrokenInBuild =>
      'This filter crashes in the installed ffmpeg build. Choose another build or roll back in Components.';

  @override
  String get fxStereoOnly => 'This effect needs stereo; mono tracks are skipped.';

  @override
  String get fxDartDsp => 'ffmpeg has no such effect; Kadra processes it with its own DSP.';

  @override
  String get useNoiseProfile => 'Use the noise profile';

  @override
  String get noNoiseProfile => 'No profile: select a noise-only part and choose Edit → Get noise profile.';

  @override
  String noiseProfileReady(String seconds) {
    return 'Noise profile: $seconds s';
  }

  @override
  String get noiseProfileShort => 'noise profile';

  @override
  String get controlTrack => 'Control track (voice)';

  @override
  String get chooseTrack => 'Choose a track';

  @override
  String get flatten => 'Flatten';

  @override
  String get generateReplaces => 'The selection will be replaced with the generated audio.';

  @override
  String get generateInserts => 'The audio will be inserted at the cursor.';

  @override
  String get dtmfDigits => 'Digits and symbols (0–9, *, #, A–D)';

  @override
  String get anStats => 'Statistics and loudness';

  @override
  String get anSpectrum => 'Plot spectrum';

  @override
  String get anSounds => 'Label sounds';

  @override
  String get anSilence => 'Find silence';

  @override
  String get anBeats => 'Beat finder';

  @override
  String get anClipping => 'Find clipping';

  @override
  String get findAndLabel => 'Find and label';

  @override
  String channelN(int n) {
    return 'Channel $n';
  }

  @override
  String get statPeak => 'Peak';

  @override
  String get statRms => 'RMS';

  @override
  String get statDc => 'DC offset';

  @override
  String get statClipped => 'Clipped samples';

  @override
  String get statIntegrated => 'Integrated loudness';

  @override
  String get statLra => 'Loudness range';

  @override
  String get statTruePeak => 'True peak';

  @override
  String get exportAudio => 'Export audio…';

  @override
  String get exportAll => 'Whole project';

  @override
  String get exportSelection => 'Selection';

  @override
  String get exportByLabels => 'By labels (multiple files)';

  @override
  String get aeExportSelection => 'Export selection…';

  @override
  String get aeExportByLabels => 'Export by labels…';

  @override
  String get metadataTitle => 'Metadata';

  @override
  String get metaTitle => 'Title';

  @override
  String get metaArtist => 'Artist';

  @override
  String get metaAlbum => 'Album';

  @override
  String get metaYear => 'Year';

  @override
  String get metaGenre => 'Genre';

  @override
  String get metaTrack => 'Track number';

  @override
  String get metaComment => 'Comment';

  @override
  String get recordTitle => 'Recording';

  @override
  String get noRecordingDevices => 'No recording devices found.';

  @override
  String get recordHint => 'The recording becomes a new track at the cursor.';

  @override
  String get histImport => 'import';

  @override
  String get histDelete => 'delete';

  @override
  String get histSilence => 'silence';

  @override
  String get histTrim => 'trim';

  @override
  String get histPaste => 'paste';

  @override
  String get histDuplicate => 'duplicate';

  @override
  String get histSplitNew => 'split to new track';

  @override
  String get histCrossfade => 'crossfade';

  @override
  String get histRemoveTrack => 'remove track';

  @override
  String get histMoveTrack => 'move track';

  @override
  String get histMixRender => 'mix and render';

  @override
  String get histSplitStereo => 'split stereo';

  @override
  String get histLabels => 'labels';

  @override
  String get histRecord => 'recording';

  @override
  String get histTrack => 'track change';

  @override
  String get fxcVolume => 'Volume and compression';

  @override
  String get fxcFades => 'Fading';

  @override
  String get fxcEq => 'EQ and filters';

  @override
  String get fxcNoise => 'Noise removal and repair';

  @override
  String get fxcPitchTempo => 'Pitch and tempo';

  @override
  String get fxcDelayReverb => 'Delay and reverb';

  @override
  String get fxcDistortion => 'Distortion and modulation';

  @override
  String get fxcSpecial => 'Special';

  @override
  String get fxAmplify => 'Amplify';

  @override
  String get fxAmplifyDesc => 'Makes the audio louder or quieter by a number of decibels.';

  @override
  String get fxNormalize => 'Normalize';

  @override
  String get fxNormalizeDesc => 'Raises the level so the peak hits the target; can remove DC offset.';

  @override
  String get fxLoudness => 'Loudness normalization';

  @override
  String get fxLoudnessDesc => 'Brings perceived loudness to an EBU R128 target (two passes).';

  @override
  String get fxCompressor => 'Compressor';

  @override
  String get fxCompressorDesc => 'Reduces the difference between loud and quiet parts.';

  @override
  String get fxLimiter => 'Limiter';

  @override
  String get fxLimiterDesc => 'Keeps peaks below a ceiling.';

  @override
  String get fxGate => 'Noise gate';

  @override
  String get fxGateDesc => 'Mutes audio below a threshold (pauses between phrases).';

  @override
  String get fxAutoDuck => 'Auto duck';

  @override
  String get fxAutoDuckDesc => 'Lowers music while the voice on another track plays.';

  @override
  String get fxDynamicNormalizer => 'Dynamic normalizer';

  @override
  String get fxDynamicNormalizerDesc => 'Evens out loudness over time while keeping short-term dynamics.';

  @override
  String get fxSpeechNormalizer => 'Speech normalizer';

  @override
  String get fxSpeechNormalizerDesc => 'Evens out speech: quiet phrases louder, loud ones quieter.';

  @override
  String get fxFadeIn => 'Fade in';

  @override
  String get fxFadeOut => 'Fade out';

  @override
  String get fxStudioFadeOut => 'Studio fade out';

  @override
  String get fxAdjustableFade => 'Adjustable fade';

  @override
  String get fxAdjustableFadeDesc => 'Changes volume from one percentage to another across the selection.';

  @override
  String get fxBassTreble => 'Bass and treble';

  @override
  String get fxBassTrebleDesc => 'Boosts or cuts low and high frequencies.';

  @override
  String get fxGraphicEq => 'Graphic EQ';

  @override
  String get fxGraphicEqDesc => '18 bands from 65 Hz to 20 kHz.';

  @override
  String get fxParametricEq => 'Parametric EQ';

  @override
  String get fxParametricEqDesc => 'Four bands, each with frequency, gain and Q.';

  @override
  String get fxHighPass => 'High-pass filter';

  @override
  String get fxLowPass => 'Low-pass filter';

  @override
  String get fxBandPass => 'Band-pass filter';

  @override
  String get fxNotch => 'Notch filter';

  @override
  String get fxNotchDesc => 'Removes a narrow frequency band (e.g. a whistle).';

  @override
  String get fxHumRemoval => 'Hum removal';

  @override
  String get fxHumRemovalDesc => 'Removes 50/60 Hz mains hum and its harmonics.';

  @override
  String get fxDeesser => 'De-esser';

  @override
  String get fxDeesserDesc => 'Softens harsh \"s\" and \"sh\" sounds.';

  @override
  String get fxExciter => 'Exciter';

  @override
  String get fxExciterDesc => 'Adds brightness and clarity to the highs.';

  @override
  String get fxNoiseReduction => 'Noise reduction';

  @override
  String get fxNoiseReductionDesc =>
      'Removes steady noise (hiss, hum). Works best with a noise profile from a part without speech.';

  @override
  String get fxNlmDenoise => 'NLM denoise';

  @override
  String get fxNlmDenoiseDesc => 'Non-local means denoising: gentler but slower.';

  @override
  String get fxClickRemoval => 'Click removal';

  @override
  String get fxClickRemovalDesc => 'Removes clicks and crackle (vinyl recordings).';

  @override
  String get fxClipFix => 'Clip fix';

  @override
  String get fxClipFixDesc => 'Reconstructs clipped peaks.';

  @override
  String get fxChangePitch => 'Change pitch';

  @override
  String get fxChangePitchDesc => 'Changes pitch without changing tempo.';

  @override
  String get fxChangeTempo => 'Change tempo';

  @override
  String get fxChangeTempoDesc => 'Changes tempo without changing pitch.';

  @override
  String get fxChangeSpeed => 'Change speed';

  @override
  String get fxChangeSpeedDesc => 'Changes speed and pitch together, like a tape deck.';

  @override
  String get fxSlidingSpeed => 'Sliding speed';

  @override
  String get fxSlidingSpeedDesc => 'Speed changes smoothly from the start to the end of the selection.';

  @override
  String get fxPaulstretch => 'Paulstretch';

  @override
  String get fxPaulstretchDesc => 'Extreme time stretching: turns sound into ambient textures.';

  @override
  String get fxEcho => 'Echo';

  @override
  String get fxEchoDesc => 'Repeats the sound with decay.';

  @override
  String get fxReverb => 'Reverb';

  @override
  String get fxReverbDesc => 'The sound of a space, from a room to a cathedral.';

  @override
  String get fxDistortion => 'Distortion';

  @override
  String get fxDistortionDesc => 'Overdrive of different kinds: soft tube-like or hard.';

  @override
  String get fxBitcrusher => 'Bitcrusher';

  @override
  String get fxBitcrusherDesc => 'Reduces bit depth and sample rate for an 8-bit sound.';

  @override
  String get fxPhaser => 'Phaser';

  @override
  String get fxFlanger => 'Flanger';

  @override
  String get fxChorus => 'Chorus';

  @override
  String get fxTremolo => 'Tremolo';

  @override
  String get fxTremoloDesc => 'Periodically changes volume.';

  @override
  String get fxVibrato => 'Vibrato';

  @override
  String get fxVibratoDesc => 'Periodically changes pitch.';

  @override
  String get fxWahwah => 'Wahwah';

  @override
  String get fxWahwahDesc => 'A sweeping resonant filter, like a guitar pedal.';

  @override
  String get fxAutoPan => 'Auto pan';

  @override
  String get fxAutoPanDesc => 'Sound moves between the channels.';

  @override
  String get fxInvert => 'Invert';

  @override
  String get fxInvertDesc => 'Flips the waveform (phase).';

  @override
  String get fxReverse => 'Reverse';

  @override
  String get fxReverseDesc => 'Plays the selection backwards.';

  @override
  String get fxRepeat => 'Repeat';

  @override
  String get fxRepeatDesc => 'Repeats the selection a number of times.';

  @override
  String get fxTruncateSilence => 'Truncate silence';

  @override
  String get fxTruncateSilenceDesc => 'Shortens long pauses.';

  @override
  String get fxVocalRemove => 'Vocal reduction';

  @override
  String get fxVocalRemoveDesc => 'Removes centre-panned audio (usually vocals) while keeping the bass.';

  @override
  String get fxVocalIsolate => 'Vocal isolation';

  @override
  String get fxVocalIsolateDesc => 'Keeps the centre of the stereo image in the voice range.';

  @override
  String get fxSwapChannels => 'Swap channels';

  @override
  String get fxMonoMix => 'Mono mix';

  @override
  String get fxStereoWiden => 'Stereo widener';

  @override
  String get fxStereoWidenDesc => 'Makes the stereo image wider.';

  @override
  String get fxBalance => 'Balance';

  @override
  String get fxHaas => 'Haas effect';

  @override
  String get fxHaasDesc => 'Turns mono into wide stereo by slightly delaying one channel.';

  @override
  String get fxFadeDesc => 'Smoothly changes volume across the selection.';

  @override
  String get fxPassDesc => 'Lets only the wanted frequencies through; the slope sets how sharply the rest is cut.';

  @override
  String get fxModulationDesc => 'A classic delay-modulation effect.';

  @override
  String get fxChannelsDesc => 'Stereo channel tools.';

  @override
  String get fxpGain => 'Gain';

  @override
  String get fxpPeak => 'Peak';

  @override
  String get fxpRemoveDc => 'Remove DC offset';

  @override
  String get fxpIndependent => 'Channels independently';

  @override
  String get fxpLufs => 'Target loudness';

  @override
  String get fxpTruePeak => 'True peak ceiling';

  @override
  String get fxpThreshold => 'Threshold';

  @override
  String get fxpRatio => 'Ratio';

  @override
  String get fxpAttack => 'Attack';

  @override
  String get fxpRelease => 'Release';

  @override
  String get fxpMakeup => 'Make-up gain';

  @override
  String get fxpKnee => 'Knee';

  @override
  String get fxpLimit => 'Limit';

  @override
  String get fxpReduction => 'Reduction';

  @override
  String get fxpGateReduction => 'Reduction below threshold';

  @override
  String get fxpDuck => 'Duck amount';

  @override
  String get fxpFrame => 'Frame length';

  @override
  String get fxpGauss => 'Smoothing (frames)';

  @override
  String get fxpPeakLin => 'Target peak';

  @override
  String get fxpMaxGain => 'Max gain';

  @override
  String get fxpExpansion => 'Max expansion';

  @override
  String get fxpCompression => 'Max compression';

  @override
  String get fxpCurve => 'Curve';

  @override
  String get fxpFrom => 'Initial volume';

  @override
  String get fxpTo => 'Final volume';

  @override
  String get fxpShape => 'Scale';

  @override
  String get fxpBass => 'Bass';

  @override
  String get fxpTreble => 'Treble';

  @override
  String get fxpFreq => 'Frequency';

  @override
  String get fxpSlope => 'Roll-off';

  @override
  String get fxpOctaves => 'Width, octaves';

  @override
  String get fxpQ => 'Q';

  @override
  String get fxpMains => 'Mains frequency';

  @override
  String get fxpHarmonics => 'Harmonics';

  @override
  String get fxpIntensity => 'Intensity';

  @override
  String get fxpMaxReduction => 'Max reduction';

  @override
  String get fxpFreqPos => 'Frequency position';

  @override
  String get fxpAmount => 'Amount';

  @override
  String get fxpDrive => 'Drive';

  @override
  String get fxpFloor => 'Noise floor';

  @override
  String get fxpTrackNoise => 'Track changing noise';

  @override
  String get fxpStrength => 'Strength';

  @override
  String get fxpWindow => 'Window';

  @override
  String get fxpSemitones => 'Shift';

  @override
  String get fxpFormants => 'Preserve formants (voice)';

  @override
  String get fxpHq => 'High quality';

  @override
  String get fxpPercent => 'Change';

  @override
  String get fxpStretch => 'Stretch factor';

  @override
  String get fxpDelay => 'Delay';

  @override
  String get fxpDecay => 'Decay';

  @override
  String get fxpReverbTime => 'Reverb time';

  @override
  String get fxpPredelay => 'Pre-delay';

  @override
  String get fxpDamping => 'Damping';

  @override
  String get fxpWet => 'Wet level';

  @override
  String get fxpDry => 'Dry level';

  @override
  String get fxpType => 'Type';

  @override
  String get fxpOutput => 'Output level';

  @override
  String get fxpBits => 'Bit depth';

  @override
  String get fxpDownsample => 'Sample reduction';

  @override
  String get fxpMix => 'Mix';

  @override
  String get fxpSpeed => 'Speed';

  @override
  String get fxpDepth => 'Depth';

  @override
  String get fxpRegen => 'Feedback';

  @override
  String get fxpResonance => 'Resonance';

  @override
  String get fxpOffset => 'Frequency offset';

  @override
  String get fxpTimes => 'Times';

  @override
  String get fxpMinSilence => 'Minimum silence';

  @override
  String get fxpKeep => 'Keep pause';

  @override
  String get fxpKeepBass => 'Keep bass below';

  @override
  String get fxpLow => 'Low cut';

  @override
  String get fxpHigh => 'High cut';

  @override
  String get fxpBalance => 'Balance';

  @override
  String get fxpWaveform => 'Waveform';

  @override
  String get fxpAmp => 'Amplitude';

  @override
  String get fxpFreqStart => 'Start frequency';

  @override
  String get fxpFreqEnd => 'End frequency';

  @override
  String get fxpLog => 'Logarithmic sweep';

  @override
  String get fxpColor => 'Noise color';

  @override
  String get fxpBpm => 'Tempo';

  @override
  String get fxpBeats => 'Beats per bar';

  @override
  String fxpBandFreq(int n) {
    return 'Band $n: frequency';
  }

  @override
  String fxpBandGain(int n) {
    return 'Band $n: gain';
  }

  @override
  String fxpBandQ(int n) {
    return 'Band $n: Q';
  }

  @override
  String get curveLinear => 'linear';

  @override
  String get curveQsin => 'quarter sine';

  @override
  String get curveHsin => 'half sine';

  @override
  String get curveEsin => 'exponential sine';

  @override
  String get curveLog => 'logarithmic';

  @override
  String get curveIpar => 'inverted parabola';

  @override
  String get curveQua => 'quadratic';

  @override
  String get curveCub => 'cubic';

  @override
  String get curveSqu => 'square root';

  @override
  String get curveCbr => 'cubic root';

  @override
  String get curvePar => 'parabola';

  @override
  String get curveExp => 'exponential';

  @override
  String get shapeLinear => 'linear';

  @override
  String get shapeDb => 'in decibels';

  @override
  String get waveSine => 'sine';

  @override
  String get waveSquare => 'square';

  @override
  String get waveSawtooth => 'sawtooth';

  @override
  String get waveTriangle => 'triangle';

  @override
  String get noiseWhite => 'white';

  @override
  String get noisePink => 'pink';

  @override
  String get noiseBrown => 'brown';

  @override
  String get noiseBlue => 'blue';

  @override
  String get noiseViolet => 'violet';

  @override
  String get noiseVelvet => 'velvet';

  @override
  String get clipHard => 'hard clip';

  @override
  String get clipTanh => 'tanh';

  @override
  String get clipAtan => 'arctangent';

  @override
  String get clipCubic => 'cubic';

  @override
  String get clipExp => 'exponential';

  @override
  String get clipAlg => 'algebraic';

  @override
  String get clipQuintic => 'quintic';

  @override
  String get clipSin => 'sine';

  @override
  String get clipErf => 'error function';

  @override
  String get genTone => 'Tone';

  @override
  String get genChirp => 'Chirp';

  @override
  String get genNoise => 'Noise';

  @override
  String get genSilence => 'Silence';

  @override
  String get genMetronome => 'Rhythm track';

  @override
  String get genDtmf => 'DTMF tones';

  @override
  String get off => 'off';

  @override
  String get vertical => 'vertical';

  @override
  String get noAudioTag => 'no audio';

  @override
  String get addFiles => 'Add files';

  @override
  String needMoreClips(int n) {
    return 'Add at least $n files';
  }

  @override
  String get nothingChanged => 'Nothing is changed yet — set at least one parameter';

  @override
  String resultLength(String d) {
    return 'Result length: $d';
  }

  @override
  String get groupEditOutput => 'Output';

  @override
  String get pEditContainerHint => 'Container of the result';

  @override
  String get pEditQuality => 'Quality';

  @override
  String get pEditQualityHint => 'Video is re-encoded; audio is copied when untouched';

  @override
  String get pEditQualityHelp =>
      '“High” is visually lossless (CRF 18 for x264), bigger file. “Normal” is the encoder default (CRF 23). “Smaller” gives a noticeably smaller file, fine detail may soften (CRF 28). The codec follows the source when the container supports it.';

  @override
  String get editQualityHigh => 'High';

  @override
  String get editQualityBalanced => 'Normal';

  @override
  String get editQualitySmall => 'Smaller';

  @override
  String get pEditSpeedHint => 'Faster gives a bigger file at the same quality';

  @override
  String get previewBefore => 'Before';

  @override
  String get previewSplit => 'Split';

  @override
  String get previewAfter => 'After';

  @override
  String get rectHintOne => 'Drag to draw the area; drag its corner to resize';

  @override
  String get rectHintMany => 'Draw areas with the mouse (up to 12); drag them or their corner';

  @override
  String get groupFragments => 'Fragments';

  @override
  String get pCutMode => 'Marked fragments';

  @override
  String get cutModeRemove => 'Remove';

  @override
  String get cutModeKeep => 'Keep only them';

  @override
  String get cutModeRemoveHint => 'Marked parts are removed, the rest is joined';

  @override
  String get cutModeKeepHint => 'Only the marked parts remain, in time order';

  @override
  String get cutHowTo => 'Find a spot in the player and press “Start”, then “End”. Mark as many fragments as you need.';

  @override
  String markFragmentStart(String t) {
    return 'Start: $t';
  }

  @override
  String markFragmentEnd(String t) {
    return 'End: $t';
  }

  @override
  String get playFragment => 'Play fragment';

  @override
  String get cutNoRanges => 'Mark at least one fragment';

  @override
  String get cutNothingLeft => 'Nothing would be left';

  @override
  String get pLosslessCut => 'Without re-encoding';

  @override
  String get losslessCutOnHint => 'Instant and lossless, but cuts snap to keyframes';

  @override
  String get losslessCutOffHint => 'Frame-accurate; video is re-encoded';

  @override
  String get pLosslessCutHelp =>
      'Video is compressed in groups of frames, and a part can start without re-encoding only on a keyframe (usually every 1–10 seconds). In fast mode a fragment may therefore start a little earlier than marked. For frame accuracy turn this off: the file is re-encoded, which takes longer.';

  @override
  String get groupClips => 'Files';

  @override
  String get groupJoin => 'Join';

  @override
  String get pLosslessJoin => 'Without re-encoding';

  @override
  String get losslessJoinOnHint => 'Instant; files must share codec and size';

  @override
  String get losslessJoinOffHint => 'Any files: brought to one size and frame rate';

  @override
  String get pLosslessJoinHelp =>
      'Joining without re-encoding suits parts of one recording (same camera or stream). If files differ in codec, resolution or audio format, the result may not play — turn this off then.';

  @override
  String concatMismatch(String what) {
    return 'Files differ: $what. Without re-encoding the result may not play.';
  }

  @override
  String get mismatchCodec => 'video codec';

  @override
  String get mismatchSize => 'resolution';

  @override
  String get mismatchPixfmt => 'pixel format';

  @override
  String get mismatchAudio => 'audio presence';

  @override
  String get mismatchAudioCodec => 'audio format';

  @override
  String get mismatchVideo => 'video presence';

  @override
  String get groupFrame => 'Frame';

  @override
  String get pJoinSize => 'Frame size';

  @override
  String get pJoinSizeHint => 'Other files are fitted with bars';

  @override
  String joinSizeFirst(String size) {
    return 'As the first ($size)';
  }

  @override
  String get groupTransition => 'Transition between files';

  @override
  String get pTransition => 'Effect';

  @override
  String get pTransitionHint => 'How one file gives way to the next';

  @override
  String get pTransitionDuration => 'Transition length';

  @override
  String get pTransitionDurationHint => 'Files overlap by this much';

  @override
  String get clipShorterThanTransition => 'A file is shorter than two transitions — shorten the transition';

  @override
  String get groupFades => 'Fade in and out';

  @override
  String get pFadeIn => 'Fade in from black';

  @override
  String get pFadeInHint => 'At the start; sound fades in too';

  @override
  String get pFadeOut => 'Fade out to black';

  @override
  String get pFadeOutHint => 'At the end; sound fades out too';

  @override
  String get xfFade => 'Cross-fade';

  @override
  String get xfDissolve => 'Dissolve';

  @override
  String get xfFadeBlack => 'Through black';

  @override
  String get xfFadeWhite => 'Through white';

  @override
  String get xfCircleOpen => 'Circle open';

  @override
  String get xfCircleClose => 'Circle close';

  @override
  String get xfCircleCrop => 'Circle crop';

  @override
  String get xfRectCrop => 'Rectangle crop';

  @override
  String get xfRadial => 'Radial';

  @override
  String get xfPixelize => 'Pixelize';

  @override
  String get xfDistance => 'Distance';

  @override
  String get xfBlur => 'Blur';

  @override
  String get xfZoom => 'Zoom in';

  @override
  String xfWipe(String dir) {
    return 'Wipe $dir';
  }

  @override
  String xfSlide(String dir) {
    return 'Slide $dir';
  }

  @override
  String xfSmooth(String dir) {
    return 'Smooth wipe $dir';
  }

  @override
  String xfDiagonal(String dir) {
    return 'Diagonal $dir';
  }

  @override
  String xfSqueeze(String dir) {
    return 'Squeeze $dir';
  }

  @override
  String xfOpen(String dir) {
    return 'Open $dir';
  }

  @override
  String get groupSplit => 'Split';

  @override
  String get pSplitMode => 'How to split';

  @override
  String get pSplitModeHint => 'Parts are saved as name_001, name_002…';

  @override
  String get splitEvery => 'By length';

  @override
  String get splitParts => 'Into N parts';

  @override
  String get splitChapters => 'By chapters';

  @override
  String get splitTimes => 'At points';

  @override
  String get pSplitEvery => 'Part length';

  @override
  String get pSplitParts => 'Number of parts';

  @override
  String get pSplitPartsHint => 'Equal in length';

  @override
  String addCutPoint(String t) {
    return 'Cut here: $t';
  }

  @override
  String get splitNoPoints => 'No cut points';

  @override
  String splitFiles(int n) {
    return 'Files: $n';
  }

  @override
  String get pSplitPrecise => 'Frame-accurate';

  @override
  String get splitPreciseOnHint => 'Video is re-encoded, cuts exactly where set';

  @override
  String get splitPreciseOffHint => 'Instant and lossless; cuts at nearest keyframes';

  @override
  String get splitKeyframeNote => 'Without re-encoding parts start on keyframes, so their lengths may differ slightly.';

  @override
  String get groupCrop => 'Crop';

  @override
  String get pCropEdit => 'Select area';

  @override
  String get pCropEditHint => 'Turn on and draw what to keep on the frame';

  @override
  String cropRectLabel(String size, String x, String y) {
    return '$size at $x, $y';
  }

  @override
  String get cropAutodetect => 'Detect black bars';

  @override
  String get cropReset => 'Reset';

  @override
  String get cropNothingFound => 'No black bars found';

  @override
  String get groupRotate => 'Rotate and flip';

  @override
  String get pRotate => 'Rotate';

  @override
  String get pRotateHint => 'Clockwise';

  @override
  String get pFlipH => 'Flip horizontally';

  @override
  String get pFlipHHint => 'Mirror: left becomes right';

  @override
  String get pFlipV => 'Flip vertically';

  @override
  String get pFlipVHint => 'Top becomes bottom';

  @override
  String get pAngle => 'Tilt';

  @override
  String get pAngleHint => 'Straighten a tilted horizon; corners are filled with black';

  @override
  String get makeVertical => 'Vertical 9:16';

  @override
  String get pAspect => 'Aspect ratio';

  @override
  String get pAspectHint => '9:16 for Shorts, Reels, TikTok; 1:1 and 4:5 for feeds';

  @override
  String get pFrameHeight => 'Frame height';

  @override
  String get pFrameHeightHint => 'Width follows the aspect ratio';

  @override
  String get pFit => 'How to fit';

  @override
  String get fitFit => 'Bars';

  @override
  String get fitFill => 'Fill';

  @override
  String get fitBlur => 'Blurred background';

  @override
  String get fitStretch => 'Stretch';

  @override
  String get fitFitHint => 'The whole picture, black bars at the sides';

  @override
  String get fitFillHint => 'The frame is filled, picture edges are cut';

  @override
  String get fitBlurHint => 'The whole picture over its blurred copy — like on social media';

  @override
  String get fitStretchHint => 'The picture is distorted to the new frame';

  @override
  String frameSizeResult(String from, String to) {
    return 'Frame: $from → $to';
  }

  @override
  String get groupSpeed => 'Speed';

  @override
  String get pSpeedFactor => 'Factor';

  @override
  String get pSpeedFactorHint => 'Above 1 is faster, below 1 is slow motion';

  @override
  String get pSpeedAudio => 'Audio';

  @override
  String get speedAudioKeep => 'Same pitch';

  @override
  String get speedAudioPitch => 'Like a record';

  @override
  String get speedAudioMute => 'Remove';

  @override
  String get speedAudioKeepHint => 'Tempo changes, voices keep their pitch';

  @override
  String get speedAudioPitchHint => 'Faster raises the pitch, slower lowers it';

  @override
  String get speedAudioMuteHint => 'The result has no audio';

  @override
  String get pReverse => 'Reverse';

  @override
  String get pReverseHint => 'Video and audio play backwards';

  @override
  String get groupFrameRate => 'Frame rate';

  @override
  String get pSpeedFps => 'Frames per second';

  @override
  String pSpeedFpsHint(String fps) {
    return 'Source has $fps';
  }

  @override
  String get pInterpolate => 'Smooth motion';

  @override
  String get pInterpolateHint => 'Synthesizes in-between frames (for slow motion)';

  @override
  String get pInterpolateHelp =>
      'The minterpolate filter estimates motion and creates new frames between existing ones. Slow motion looks smooth instead of choppy. It is very slow and may show artifacts on fast scenes.';

  @override
  String get reverseMemoryWarning =>
      'Reversing keeps the whole clip in memory: long files may run out of RAM. Trim a short part first.';

  @override
  String get interpolateSlowWarning => 'Smooth motion is very slow — a minute of video may take tens of minutes.';

  @override
  String get atempoQualityNote => 'At extreme tempo changes pitch-preserved audio may sound metallic.';

  @override
  String get groupRestore => 'Restoration';

  @override
  String get pDeinterlace => 'Deinterlace';

  @override
  String get pDeinterlaceHint => 'For TV recordings, tapes, old camcorders';

  @override
  String get deinterlaceDetected => 'The file is interlaced — recommended';

  @override
  String get pDeinterlaceHelp =>
      'Interlaced video shows half-frames, and motion shows horizontal combing. bwdif is the modern quality filter; yadif is the classic one, a bit faster.';

  @override
  String get pVideoDenoise => 'Denoise';

  @override
  String get pVideoDenoiseHint => 'Removes grain and digital noise';

  @override
  String get pVideoDenoiseHelp =>
      'Light–strong use the fast hqdn3d filter: stronger is cleaner but looks plastic. NLMeans keeps detail noticeably better but is tens of times slower.';

  @override
  String get levelLight => 'Light';

  @override
  String get levelMedium => 'Medium';

  @override
  String get levelStrong => 'Strong';

  @override
  String get denoiseNlmeans => 'NLMeans (quality, slow)';

  @override
  String get pSharpen => 'Sharpen';

  @override
  String get pSharpenHint => 'Emphasizes detail; cannot fix a blurry shot';

  @override
  String get sharpenCas => 'Adaptive (CAS)';

  @override
  String get groupStabilize => 'Stabilization';

  @override
  String get pStabilize => 'Remove shake';

  @override
  String get pStabilizeHint => 'Two passes: motion analysis, then correction';

  @override
  String get pStabilizeDeshakeHint => 'No vidstab in this build — simple deshake is used';

  @override
  String get pStabilizeHelp =>
      'First the camera motion is tracked through the whole file, then frames are shifted and slightly zoomed to hide the shake. Frame edges are cropped a little. The preview does not show stabilization — only the result does.';

  @override
  String get pShakiness => 'Shakiness';

  @override
  String get pShakinessHint => 'How shaky the source is (1–10)';

  @override
  String get pSmoothing => 'Smoothing';

  @override
  String get pSmoothingHint => 'Higher is smoother but crops more';

  @override
  String get vidstabMissing =>
      'This ffmpeg build lacks libvidstab — the simpler deshake filter is used. Install a full build in Components for quality stabilization.';

  @override
  String get nlmeansSlowWarning => 'NLMeans is very slow: about a frame per second at Full HD.';

  @override
  String get stepAnalyzeMotion => 'motion analysis';

  @override
  String get groupColorBasic => 'Basics';

  @override
  String get pBrightness => 'Brightness';

  @override
  String get pBrightnessHint => '0 means unchanged';

  @override
  String get pContrast => 'Contrast';

  @override
  String get pContrastHint => '1 means unchanged';

  @override
  String get pSaturation => 'Saturation';

  @override
  String get pSaturationHint => '0 is black and white, 1 is unchanged';

  @override
  String get pGamma => 'Gamma';

  @override
  String get pGammaHint => 'Brightens or darkens midtones';

  @override
  String get pHue => 'Hue';

  @override
  String get pHueHint => 'Shifts all colors around the color wheel';

  @override
  String get pTemperature => 'Color temperature';

  @override
  String get pTemperatureHint => 'Lower is warmer (yellower), higher is cooler (bluer); 6500 K is neutral';

  @override
  String get groupLook => 'Look';

  @override
  String get pLook => 'Preset look';

  @override
  String get pLookHint => 'Applied after the basics';

  @override
  String get lookGrayscale => 'Black & white';

  @override
  String get lookSepia => 'Sepia';

  @override
  String get lookVintage => 'Vintage';

  @override
  String get lookCrossProcess => 'Cross process';

  @override
  String get lookNegative => 'Negative';

  @override
  String get lookStrongContrast => 'Strong contrast';

  @override
  String get lookLighter => 'Lighter';

  @override
  String get lookDarker => 'Darker';

  @override
  String get pVignette => 'Vignette';

  @override
  String get pVignetteHint => 'Darkened frame edges';

  @override
  String get pLut => 'LUT file';

  @override
  String get pLutHint => '.cube or .3dl — a ready color grade';

  @override
  String get pLutHelp =>
      'A LUT (look-up table) is a ready color grade from DaVinci Resolve, Premiere or a camera maker (e.g. converting a Log profile to normal). It is applied before the other settings.';

  @override
  String get pLutMix => 'LUT strength';

  @override
  String get pLutMixHint => 'Blend with the original colors';

  @override
  String get groupWatermark => 'Logo';

  @override
  String get pWatermarkImage => 'Image';

  @override
  String get pWatermarkImageHint => 'A PNG with transparency works best';

  @override
  String get pPosition => 'Position';

  @override
  String get pPositionHint => 'Corner or edge of the frame';

  @override
  String get pWatermarkSize => 'Size';

  @override
  String get pWatermarkSizeHint => 'Width relative to the video width';

  @override
  String get pOpacity => 'Opacity';

  @override
  String get pOpacityHint => 'Lower is more transparent';

  @override
  String get groupText => 'Text';

  @override
  String get pOverlayText => 'Caption';

  @override
  String get pOverlayTextHint => 'Any text, including % : , \' [ ]';

  @override
  String get pFontSize => 'Font size';

  @override
  String get pFontSizeHint => 'Relative to the video height';

  @override
  String get pFontColor => 'Color';

  @override
  String get pFontColorHint => 'Letter color';

  @override
  String get colorWhite => 'white';

  @override
  String get colorBlack => 'black';

  @override
  String get colorYellow => 'yellow';

  @override
  String get colorRed => 'red';

  @override
  String get colorBlue => 'blue';

  @override
  String get pTextBox => 'Background box';

  @override
  String get pTextBoxHint => 'Translucent box behind the text; otherwise an outline';

  @override
  String get pFontFile => 'Font';

  @override
  String get pFontFileHint => 'Default is the system sans-serif font';

  @override
  String get pTimecode => 'Timecode';

  @override
  String get pTimecodeHint => 'Time since the start on every frame';

  @override
  String get pTimecodePosition => 'Timecode position';

  @override
  String get groupWhen => 'Margin and timing';

  @override
  String get pMargin => 'Edge margin';

  @override
  String get pMarginHint => 'Relative to the video height';

  @override
  String get pShowFrom => 'Show from';

  @override
  String get pShowFromHint => 'Empty means from the start';

  @override
  String get pShowTo => 'Show until';

  @override
  String get pShowToHint => 'Empty means to the end';

  @override
  String get overlayEmpty => 'Choose an image, enter text or turn on the timecode';

  @override
  String get cornerTopLeft => 'top left';

  @override
  String get cornerTop => 'top center';

  @override
  String get cornerTopRight => 'top right';

  @override
  String get cornerLeft => 'center left';

  @override
  String get cornerCenter => 'center';

  @override
  String get cornerRight => 'center right';

  @override
  String get cornerBottomLeft => 'bottom left';

  @override
  String get cornerBottom => 'bottom center';

  @override
  String get cornerBottomRight => 'bottom right';

  @override
  String get groupBlur => 'Hiding';

  @override
  String get pBlurMode => 'Method';

  @override
  String get blurModeBlur => 'Blur';

  @override
  String get blurModePixel => 'Pixelate';

  @override
  String get blurModeDelogo => 'Remove logo';

  @override
  String get blurModeBox => 'Black box';

  @override
  String get blurModeBlurHint => 'Faces, license plates, screens';

  @override
  String get blurModePixelHint => 'Large squares, like on the news';

  @override
  String get blurModeDelogoHint => 'Fills the area from surrounding pixels — for small logos on a plain background';

  @override
  String get blurModeBoxHint => 'A black rectangle';

  @override
  String get pStrength => 'Strength';

  @override
  String get pBlurStrengthHint => 'How strongly to hide';

  @override
  String get pBlurWhole => 'Whole frame';

  @override
  String get pBlurWholeHint => 'Blur the entire picture';

  @override
  String get pEditRegions => 'Draw areas';

  @override
  String get pEditRegionsHint => 'Turn off to see the result in the preview';

  @override
  String get groupRegions => 'Areas';

  @override
  String get regionTimeHint => 'Each area can have a time window: empty means the whole video';

  @override
  String get blurNoRegions => 'Draw at least one area on the frame';

  @override
  String get groupLayout => 'Layout';

  @override
  String get pLayout => 'Arrangement';

  @override
  String get pLayoutHint => 'Height or width follows the first video';

  @override
  String get layoutSide => 'Side by side';

  @override
  String get layoutTop => 'Stacked';

  @override
  String get layoutGrid => '2×2 grid';

  @override
  String get layoutPip => 'Picture in picture';

  @override
  String get pPipPositionHint => 'Where the small window goes';

  @override
  String get pPipSize => 'Window size';

  @override
  String get pPipSizeHint => 'Relative to the main video width';

  @override
  String get pStackAudio => 'Audio';

  @override
  String get pStackAudioHint => 'Which audio the result has';

  @override
  String get stackAudioFirst => 'From the first video';

  @override
  String get stackAudioMix => 'Mix all';

  @override
  String get stackAudioNone => 'No audio';

  @override
  String get shortestOnHint => 'The result lasts while all videos play';

  @override
  String get shortestOffHint => 'Until the longest ends; finished ones freeze on the last frame';

  @override
  String get groupLoop => 'Repeat';

  @override
  String get pLoopMode => 'Mode';

  @override
  String get loopRepeat => 'Repeat';

  @override
  String get loopBoomerang => 'Boomerang';

  @override
  String get loopRepeatHint => 'The video plays several times in a row';

  @override
  String get loopBoomerangHint => 'Forward, then backward — a seamless loop';

  @override
  String get pLoopTimes => 'How many times';

  @override
  String get pLoopTimesHint => 'Total number of plays';

  @override
  String get pBoomerangAudio => 'With audio';

  @override
  String get pBoomerangAudioHint => 'Audio also plays backwards';

  @override
  String get groupToneMap => 'Tone mapping';

  @override
  String hdrSourceInfo(String trc, String prim, String bits) {
    return 'Source: transfer $trc, primaries $prim, $bits-bit';
  }

  @override
  String notHdrWarning(String trc) {
    return 'The file does not look like HDR (transfer: $trc) — the result may look wrong';
  }

  @override
  String get pToneCurve => 'Curve';

  @override
  String get pToneCurveHelp =>
      'HDR video holds brightness a normal screen cannot show. The curve decides how to compress it into the normal range. Hable keeps detail in highlights and shadows (a good default), Möbius keeps midtone colors more accurate, Reinhard gives a soft, bright result.';

  @override
  String get toneHableHint => 'Keeps highlight detail — a good default';

  @override
  String get toneMobiusHint => 'More accurate midtone colors';

  @override
  String get toneReinhardHint => 'Soft, bright result';

  @override
  String get toneBt2390Hint => 'The ITU broadcast standard';

  @override
  String get pDesat => 'Highlight desaturation';

  @override
  String get pDesatHint => 'Tames oversaturated colors in bright areas';

  @override
  String get pPlacebo => 'On the GPU (libplacebo)';

  @override
  String get pPlaceboHint => 'Faster and better; needs a Vulkan GPU';

  @override
  String get groupResults => 'Results';

  @override
  String get groupMeasure => 'Measurement';

  @override
  String get measure => 'Measure';

  @override
  String get pAudioTrack => 'Audio track';

  @override
  String get pAudioTrackHint => 'Which track to measure';

  @override
  String get pLoudnessTarget => 'Compare with';

  @override
  String get pLoudnessTargetHint => 'Platform loudness target';

  @override
  String get groupWhatIsLufs => 'What the numbers mean';

  @override
  String get lufsExplained =>
      'Integrated loudness (LUFS) is the average loudness of the whole file as people hear it. Platforms normalize loudness: YouTube and Spotify bring everything to −14 LUFS, so a track that is too loud is simply turned down, and a quiet one sounds weaker than the rest.\n\nTrue Peak is the real signal peak after conversion to analog; above −1 dBTP distortion may appear after MP3/AAC encoding.\n\nLoudness range (LRA) shows how different quiet and loud parts are: 5–10 LU for music, over 15 for films with quiet dialog and explosions.';

  @override
  String get statIntegratedNote => 'average of the whole file';

  @override
  String get statTruePeakNote => 'highest peak';

  @override
  String get statLraNote => 'loudness spread';

  @override
  String get statMaxMomentary => 'Max momentary';

  @override
  String get statMaxShort => 'Max short-term';

  @override
  String get loudnessLegend =>
      'Thin line: momentary loudness (0.4 s); thick: short-term (3 s); dashed: platform target.';

  @override
  String loudnessOnTarget(String name) {
    return 'Loudness matches the $name target.';
  }

  @override
  String loudnessTooLoud(String name, String db) {
    return '$db dB louder than the $name target — the platform will turn it down.';
  }

  @override
  String loudnessTooQuiet(String name, String db) {
    return '$db dB quieter than the $name target — it will sound weaker than others.';
  }

  @override
  String truePeakOver(String tp, String limit) {
    return 'Peak $tp dBTP is above the allowed $limit dBTP — distortion is possible.';
  }

  @override
  String get openNormalize => 'Normalize loudness';

  @override
  String get groupPicture => 'Picture';

  @override
  String get pPicKind => 'What to draw';

  @override
  String get picWave => 'Waveform';

  @override
  String get picSpectrum => 'Spectrogram';

  @override
  String get picWaveHint => 'Wave shape: level over time';

  @override
  String get picSpectrumHint => 'Frequencies over time: shows noise, hum, cut-offs';

  @override
  String get pPicSize => 'Size';

  @override
  String get pPicSizeHint => 'In pixels';

  @override
  String get pSplitChannels => 'Separate channels';

  @override
  String get pSplitChannelsHint => 'Left and right one above the other';

  @override
  String get pWaveColorHint => 'Wave color';

  @override
  String get pWaveScale => 'Scale';

  @override
  String get pWaveScaleHint => 'Logarithmic shows quiet parts better';

  @override
  String get scaleLinear => 'linear';

  @override
  String get scaleLog => 'logarithmic';

  @override
  String get scaleSqrt => 'square root';

  @override
  String get scaleCbrt => 'cubic root';

  @override
  String get pSpectrumColors => 'Palette';

  @override
  String get pSpectrumColorsHint => 'Colors for levels';

  @override
  String get pLogFrequency => 'Logarithmic frequency scale';

  @override
  String get pLogFrequencyHint => 'More room for low frequencies, as the ear hears';

  @override
  String get pLegend => 'Legend';

  @override
  String get pLegendHint => 'Time and frequency axes';

  @override
  String get savePng => 'Save PNG';

  @override
  String savedTo(String path) {
    return 'Saved: $path';
  }

  @override
  String get groupDetect => 'Detector';

  @override
  String get pDetectKind => 'What to find';

  @override
  String get detectSilence => 'Silence';

  @override
  String get detectBlack => 'Black frames';

  @override
  String get detectFreeze => 'Frozen frames';

  @override
  String get detectScenes => 'Scene changes';

  @override
  String get detectCrop => 'Black bars';

  @override
  String get detectSilenceHint => 'Pauses in audio — e.g. to cut them out';

  @override
  String get detectBlackHint => 'Fades to black, ad breaks, empty starts';

  @override
  String get detectFreezeHint => 'Stuck picture, lost signal';

  @override
  String get detectScenesHint => 'Moments of editing cuts';

  @override
  String get detectCropHint => 'Bars at the frame edges that can be cropped';

  @override
  String get pSilenceLevel => 'Silence threshold';

  @override
  String get pSilenceLevelHint => 'Anything quieter counts as silence';

  @override
  String get pBlackLevel => 'Black threshold';

  @override
  String get pBlackLevelHint => 'How dark a pixel counts as black';

  @override
  String get pFreezeNoise => 'Noise tolerance';

  @override
  String get pFreezeNoiseHint => 'Higher also counts slightly noisy frames as frozen';

  @override
  String get pSceneThreshold => 'Sensitivity';

  @override
  String get pSceneThresholdHint => 'Lower finds more cuts, including false ones';

  @override
  String get pMinDuration => 'Minimum length';

  @override
  String get pMinDurationHint => 'Shorter parts are ignored';

  @override
  String get detectRun => 'Find';

  @override
  String foundCount(int n) {
    return 'Found: $n';
  }

  @override
  String moreFound(int n) {
    return '…and $n more';
  }

  @override
  String sceneScore(String v) {
    return 'score $v';
  }

  @override
  String get saveCsv => 'Save CSV';

  @override
  String get cutFound => 'Cut out the findings';

  @override
  String get splitAtFound => 'Split at these points';

  @override
  String cropFound(String size, String x, String y) {
    return 'Can be cropped to $size at $x, $y';
  }

  @override
  String get openCropTool => 'Open in Crop & scale';

  @override
  String get groupCompare => 'Comparison';

  @override
  String get referenceFile => 'Original';

  @override
  String get distortedFile => 'Compressed version';

  @override
  String get distortedFileHint => 'Choose the file whose quality to assess';

  @override
  String get qualityScaledNote => 'Frame sizes differ — the compressed version is scaled to the original size.';

  @override
  String get vmafMissing =>
      'This build has no VMAF — only PSNR and SSIM are computed. VMAF is in the full ffmpeg build (Components).';

  @override
  String get compareRun => 'Compare';

  @override
  String get groupWhatMetrics => 'What the metrics mean';

  @override
  String get metricsExplained =>
      'VMAF (0–100) is Netflix’s score that best matches how people see quality: above 93 looks identical, 80–93 is good, below 60 shows visible defects.\n\nPSNR (dB) is the mathematical pixel difference: above 40 is excellent, 30–35 shows losses.\n\nSSIM (0–1) is structural similarity: 0.98 and up is nearly identical.\n\nFiles are compared frame by frame from the start, so they must begin with the same frame.';

  @override
  String psnrMin(String v) {
    return 'worst frame $v dB';
  }

  @override
  String get qualityExcellent => 'excellent';

  @override
  String get qualityGood => 'good';

  @override
  String get qualityFair => 'visible losses';

  @override
  String get qualityPoor => 'poor';

  @override
  String get vmafVerdictExcellent => 'The compressed version looks identical to the original.';

  @override
  String get vmafVerdictGood => 'Good quality: differences show only on close comparison.';

  @override
  String get vmafVerdictFair => 'Losses are visible — try a higher quality.';

  @override
  String get vmafVerdictPoor => 'Heavy quality loss.';
}
