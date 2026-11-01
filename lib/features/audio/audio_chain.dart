/// Whole-file audio processing (stage 3): effect chains and denoise,
/// background music with ducking, speech recognition (whisper filter).
/// Video, subtitles and other streams are copied untouched.
library;

import 'package:path/path.dart' as p;

import '../../core/engine/containers.dart';
import '../../core/engine/encoders.dart';
import '../../core/engine/ffmpeg_command.dart';
import '../../core/probe/media_info.dart';
import '../../core/queue/job_steps.dart';
import '../audio_editor/engine/effects.dart';
import '../edit/graphs.dart' show fnum, secs;

/// One step of an audio chain: an effect from the editor catalog, or
/// RNNoise (`arnndn`) with a downloaded model.
class ChainItem {
  const ChainItem.fx(this.fxId, this.values) : rnnoiseModel = null, mix = 1;
  const ChainItem.rnnoise(this.rnnoiseModel, {this.mix = 1}) : fxId = rnnoiseId, values = const {};

  static const rnnoiseId = 'rnnoise';
  final String fxId;
  final FxValues values;
  final String? rnnoiseModel;

  /// arnndn mix: 1 = only denoised, lower keeps some original.
  final double mix;

  bool get isRnnoise => fxId == rnnoiseId;
}

/// Effects usable on a whole file: plain filters that need no measuring;
/// length-changing ones only for audio-only files (video would desync).
bool fxUsableOnFile(FxDef d, {required bool hasVideo}) =>
    d.kind == FxKind.filter && d.measure == FxMeasure.none && d.build != null && !(hasVideo && d.changesLength);

/// True when no item changes the length (tempo, speed, repeat…).
bool chainKeepsLength(List<ChainItem> items) => items.every((i) => i.isRnnoise || !fxById(i.fxId).changesLength);

/// The `-af` chain for [items].
List<String> chainFilters(List<ChainItem> items, FxContext ctx) => [
  for (final it in items)
    if (it.isRnnoise)
      'arnndn=m=${escapeFilterValue(it.rnnoiseModel!)}${it.mix < 0.999 ? ':mix=${fnum(it.mix, 2)}' : ''}'
    else
      fxById(it.fxId).build!(it.values, ctx),
];

FxContext fileFxContext(MediaInfo info, {int stream = 0}) {
  final a = info.audioStreams.elementAtOrNull(stream);
  final sr = a?.sampleRate ?? 48000;
  return FxContext(
    sampleRate: sr,
    channels: a?.channels ?? 2,
    frames: ((info.duration?.inMicroseconds ?? 0) * sr / 1e6).round(),
  );
}

/// Output container for processed audio: the source's when it can hold
/// the re-encoded audio, otherwise MKV (video) or FLAC (audio only).
String audioFxExt(MediaInfo info) {
  final e = p.extension(info.path).replaceFirst('.', '').toLowerCase();
  if (containers.containsKey(e)) return e;
  return info.videoStreams.isEmpty ? 'flac' : 'mkv';
}

List<String> _audioCodecArgs(MediaInfo info, String ext, {int stream = 0}) {
  final a = info.audioStreams.elementAtOrNull(stream);
  final choice = audioChoiceFor(ext, sourceCodec: a?.codecName);
  final spec = audioEncoders[choice] ?? audioEncoders[AudioCodecChoice.aac]!;
  // Keep at least the source bitrate for lossy codecs.
  final src = (a?.bitRate ?? 0) ~/ 1000;
  final kbps = spec.defaultKbps == null ? null : (src > spec.defaultKbps! ? src.clamp(0, 512) : null);
  return spec.args(kbps: kbps);
}

/// `ffmpeg -i in -map 0:v? -map 0:a:N -map 0:s? -c copy -af <chain> -c:a <enc> out`
List<JobStep> planAudioChain({
  required MediaInfo info,
  required String output,
  required List<String> filters,
  int stream = 0,
  Duration? duration,
  bool keepLength = true,
}) {
  final ext = p.extension(output).replaceFirst('.', '').toLowerCase();
  final c = containerFor(ext);
  return [
    JobStep(
      totalDuration: duration ?? info.duration,
      args: FfmpegCommand(
        inputs: [FfmpegInput(info.path)],
        outputs: [
          FfmpegOutput(
            output,
            maps: [
              if (!c.audioOnly && info.videoStreams.isNotEmpty) '0:v?',
              '0:a:$stream',
              if (c.subtitles && info.subtitleStreams.isNotEmpty) '0:s?',
            ],
            audioFilters: filters,
            // Echo/reverb tails would make the audio longer than the video.
            duration: keepLength ? info.duration : null,
            options: [
              if (!c.audioOnly) ...['-c:v', 'copy'],
              if (c.subtitles) ...['-c:s', 'copy'],
              ..._audioCodecArgs(info, ext, stream: stream),
              if (c.faststart) ...['-movflags', '+faststart'],
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

/// A short WAV of [start]…[start]+[length] for before/after listening.
List<String> audioPreviewArgs({
  required MediaInfo info,
  required String output,
  required Duration start,
  required Duration length,
  List<String> filters = const [],
  int stream = 0,
}) => FfmpegCommand(
  reportProgress: false,
  inputs: [FfmpegInput(info.path, seek: start > Duration.zero ? start : null, duration: length)],
  outputs: [
    FfmpegOutput(output, maps: ['0:a:$stream'], audioFilters: filters, options: const ['-c:a', 'pcm_s16le']),
  ],
).toArgs();

// =================================================================== music

class MusicParams {
  const MusicParams({
    this.volumeDb = -12,
    this.loop = true,
    this.duck = true,
    this.duckAmount = 8,
    this.fadeOut = const Duration(seconds: 3),
    this.offset = Duration.zero,
    this.keepOriginal = true,
  });

  /// Music level relative to its original.
  final double volumeDb;
  final bool loop;

  /// Lower the music while the main audio (voice) sounds.
  final bool duck;

  /// sidechaincompress ratio (2–20).
  final double duckAmount;
  final Duration fadeOut;

  /// Music starts this late.
  final Duration offset;

  /// Keep the main file's own audio (otherwise music replaces it).
  final bool keepOriginal;
}

/// Mixes [music] under [main]: the result has main's length; video copied.
///   `[1:a]volume,atrim,afade[m];[0:a]asplit[v][sc];[m][sc]sidechaincompress[md];[v][md]amix`
List<JobStep> planMusic({
  required MediaInfo main,
  required MediaInfo music,
  required String output,
  required MusicParams m,
}) {
  final total = main.duration ?? music.duration ?? Duration.zero;
  final ext = p.extension(output).replaceFirst('.', '').toLowerCase();
  final c = containerFor(ext);
  final hasMain = main.audioStreams.isNotEmpty && m.keepOriginal;
  final sr = main.audioStreams.firstOrNull?.sampleRate ?? 48000;
  final musicLen = total - m.offset;
  final musicChain = [
    '[1:a:0]aresample=$sr,aformat=channel_layouts=stereo',
    'volume=${fnum(m.volumeDb, 1)}dB',
    'atrim=duration=${secs(musicLen)}',
    if (m.fadeOut > Duration.zero && musicLen > m.fadeOut)
      'afade=t=out:st=${secs(musicLen - m.fadeOut)}:d=${secs(m.fadeOut)}',
    if (m.offset > Duration.zero) 'adelay=${m.offset.inMilliseconds}:all=1',
  ].join(',');
  final parts = <String>['$musicChain[m]'];
  if (!hasMain) {
    parts.add('[m]apad=whole_dur=${secs(total)}[a]');
  } else if (m.duck) {
    parts
      ..add('[0:a:0]aresample=$sr,aformat=channel_layouts=stereo,asplit=2[v][sc]')
      ..add('[m][sc]sidechaincompress=threshold=0.03:ratio=${fnum(m.duckAmount, 1)}:attack=20:release=400:makeup=1[md]')
      ..add('[v][md]amix=inputs=2:duration=first:normalize=0[a]');
  } else {
    parts
      ..add('[0:a:0]aresample=$sr,aformat=channel_layouts=stereo[v]')
      ..add('[v][m]amix=inputs=2:duration=first:normalize=0[a]');
  }
  final choice = audioChoiceFor(ext, sourceCodec: main.audioStreams.firstOrNull?.codecName);
  return [
    JobStep(
      totalDuration: total,
      args: FfmpegCommand(
        inputs: [
          FfmpegInput(main.path),
          FfmpegInput(music.path, options: m.loop ? const ['-stream_loop', '-1'] : const []),
        ],
        filterComplex: parts.join(';'),
        outputs: [
          FfmpegOutput(
            output,
            maps: [if (!c.audioOnly && main.videoStreams.isNotEmpty) '0:v:0', '[a]'],
            duration: total,
            options: [
              if (!c.audioOnly && main.videoStreams.isNotEmpty) ...['-c:v', 'copy'],
              ...(audioEncoders[choice] ?? audioEncoders[AudioCodecChoice.aac]!).args(),
              if (c.faststart) ...['-movflags', '+faststart'],
            ],
          ),
        ],
      ).toArgs(),
    ),
  ];
}

// ============================================================ transcription

enum TranscriptFormat { srt, text, json }

String transcriptExt(TranscriptFormat f) => switch (f) {
  TranscriptFormat.srt => 'srt',
  TranscriptFormat.text => 'txt',
  TranscriptFormat.json => 'json',
};

/// Languages offered for whisper (`auto` = detect).
const whisperLanguages = [
  'auto',
  'ru',
  'en',
  'uk',
  'be',
  'kk',
  'de',
  'fr',
  'es',
  'it',
  'pt',
  'pl',
  'tr',
  'zh',
  'ja',
  'ko',
  'ar',
];

/// ffmpeg ≥ 8 `whisper` filter (options from libavfilter/af_whisper.c):
/// writes the transcript to [output] while decoding to the null muxer.
List<JobStep> planTranscribe({
  required MediaInfo info,
  required String model,
  required String output,
  String language = 'auto',
  TranscriptFormat format = TranscriptFormat.srt,
  bool useGpu = true,
  int stream = 0,
}) => [
  JobStep(
    totalDuration: info.duration,
    args: FfmpegCommand(
      inputs: [FfmpegInput(info.path)],
      outputs: [
        FfmpegOutput(
          '-',
          maps: ['0:a:$stream'],
          audioFilters: [
            'whisper=model=${escapeFilterValue(model)}:language=$language:use_gpu=${useGpu ? 1 : 0}:'
                'destination=${escapeFilterValue(output)}:format=${format.name}',
          ],
          format: 'null',
        ),
      ],
    ).toArgs(),
  ),
];
