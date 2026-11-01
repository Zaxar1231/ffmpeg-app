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
}
