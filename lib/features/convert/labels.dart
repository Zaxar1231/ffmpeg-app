import '../../core/engine/encoders.dart';
import '../../ui/l10n.dart';
import 'convert_params.dart';

String presetName(AppLocalizations l, String id) => switch (id) {
  'telegram' => l.presetTelegram,
  'youtube' => l.presetYoutube,
  'discord' => l.presetDiscord,
  'editProres' => l.presetEditProres,
  'editDnxhr' => l.presetEditDnxhr,
  'archive' => l.presetArchive,
  'maxCompression' => l.presetMaxCompression,
  'compress' => l.presetCompress,
  _ => id,
};

String presetDescription(AppLocalizations l, String id) => switch (id) {
  'telegram' => l.presetTelegramDesc,
  'youtube' => l.presetYoutubeDesc,
  'discord' => l.presetDiscordDesc,
  'editProres' => l.presetEditProresDesc,
  'editDnxhr' => l.presetEditDnxhrDesc,
  'archive' => l.presetArchiveDesc,
  'maxCompression' => l.presetMaxCompressionDesc,
  'compress' => l.presetCompressDesc,
  _ => '',
};

String videoCodecLabel(AppLocalizations l, VideoCodecChoice c) => switch (c) {
  VideoCodecChoice.h264 => 'H.264 (AVC)',
  VideoCodecChoice.hevc => 'H.265 (HEVC)',
  VideoCodecChoice.av1 => 'AV1',
  VideoCodecChoice.vp9 => 'VP9',
  VideoCodecChoice.prores => 'Apple ProRes',
  VideoCodecChoice.dnxhr => 'Avid DNxHR',
  VideoCodecChoice.ffv1 => l.codecFfv1,
  VideoCodecChoice.mjpeg => 'Motion JPEG',
  VideoCodecChoice.copy => l.codecCopy,
  VideoCodecChoice.none => l.codecNoVideo,
};

String audioCodecLabel(AppLocalizations l, AudioCodecChoice c) => switch (c) {
  AudioCodecChoice.aac => 'AAC',
  AudioCodecChoice.opus => 'Opus',
  AudioCodecChoice.mp3 => 'MP3',
  AudioCodecChoice.flac => l.codecFlac,
  AudioCodecChoice.alac => l.codecAlac,
  AudioCodecChoice.pcm16 => 'PCM 16 bit (WAV)',
  AudioCodecChoice.pcm24 => 'PCM 24 bit',
  AudioCodecChoice.ac3 => 'Dolby Digital (AC-3)',
  AudioCodecChoice.eac3 => 'Dolby Digital Plus (E-AC-3)',
  AudioCodecChoice.vorbis => 'Vorbis',
  AudioCodecChoice.copy => l.codecCopy,
  AudioCodecChoice.none => l.codecNoAudio,
};

String speedLabel(AppLocalizations l, SpeedPreset s) => switch (s) {
  SpeedPreset.fastest => l.speedFastest,
  SpeedPreset.fast => l.speedFast,
  SpeedPreset.medium => l.speedMedium,
  SpeedPreset.slow => l.speedSlow,
  SpeedPreset.slowest => l.speedSlowest,
};

String rateModeLabel(AppLocalizations l, RateMode m) => switch (m) {
  RateMode.quality => l.rateQuality,
  RateMode.bitrate => l.rateBitrate,
  RateMode.cbr => l.rateCbr,
  RateMode.targetSize => l.rateTargetSize,
};

String convertIssueText(AppLocalizations l, ConvertIssue i) => switch (i) {
  ConvertIssue.noVideoEncoder => l.issueNoEncoder,
  ConvertIssue.videoNotInContainer => l.issueVideoContainer,
  ConvertIssue.audioNotInContainer => l.issueAudioContainer,
  ConvertIssue.copyNotInContainer => l.issueCopyContainer,
  ConvertIssue.durationUnknown => l.issueDurationUnknown,
  ConvertIssue.targetTooSmall => l.issueTargetTooSmall,
  ConvertIssue.noTenBit => l.issueNoTenBit,
};
