import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/capabilities.dart';
import 'package:kadra/features/expert/expert_ops.dart';

void main() {
  CompletionContext? at(String withCursor) {
    final i = withCursor.indexOf('|');
    return completionAt(withCursor.replaceFirst('|', ''), i);
  }

  test('completion context at the cursor', () {
    var c = at('ffmpeg -i "a b.mp4" -c:v libx2|');
    expect((c!.kind, c.prefix), (CompletionKind.videoEncoder, 'libx2'));
    c = at('ffmpeg -i a.mp4 -c:a |');
    expect((c!.kind, c.prefix), (CompletionKind.audioEncoder, ''));
    c = at('ffmpeg -i a.mp4 -vf "scale=1280:-2,unsh|');
    expect((c!.kind, c.prefix), (CompletionKind.filter, 'unsh'));
    c = at('ffmpeg -i a -filter_complex "[0:v]spl|');
    expect((c!.kind, c.prefix), (CompletionKind.filter, 'spl'));
    expect(at('ffmpeg -i a -vf "scale=12|'), isNull); // inside parameters
    c = at('ffmpeg -i a.mp4 -pre|');
    expect((c!.kind, c.prefix, c.start), (CompletionKind.option, '-pre', 16));
    c = at('ffmpeg -i a.mp4 -f mat|');
    expect(c!.kind, CompletionKind.format);
    expect(at('ffmpeg -i "my fi|'), isNull);
    expect(at('ffmpeg -i a.mp4 out|'), isNull);
  });

  test('candidates from the build', () {
    final caps = FfmpegCapabilities(
      version: '9.0',
      configuration: const [],
      encoders: {
        'libx264': const CodecEntry('libx264', MediaKind.video, 'H.264'),
        'libx265': const CodecEntry('libx265', MediaKind.video, 'H.265'),
        'h264_nvenc': const CodecEntry('h264_nvenc', MediaKind.video, 'NVENC H.264'),
        'aac': const CodecEntry('aac', MediaKind.audio, 'AAC'),
      },
      decoders: const {},
      filters: const {},
      muxers: const {'matroska': 'Matroska', 'mp4': 'MP4'},
      hwaccels: const {'cuda'},
    );
    var r = completionCandidates(const CompletionContext(CompletionKind.videoEncoder, 'libx', 0), caps);
    expect(r.map((e) => e.$1), ['libx264', 'libx265']);
    r = completionCandidates(const CompletionContext(CompletionKind.videoEncoder, '264', 0), caps);
    expect(r.map((e) => e.$1), ['libx264', 'h264_nvenc']); // "contains" matches
    r = completionCandidates(const CompletionContext(CompletionKind.audioEncoder, '', 0), caps);
    expect(r.map((e) => e.$1), ['aac', 'copy']);
    r = completionCandidates(const CompletionContext(CompletionKind.format, 'ma', 0), caps);
    expect(r.single.$1, 'matroska');
  });
}
