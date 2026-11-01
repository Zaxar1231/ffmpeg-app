import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/error_translator.dart';

ToolError t(String log) => translateToolError(log.split('\n'));

void main() {
  test('missing encoder', () {
    final e = t("[vost#0:0 @ 0x1] Unknown encoder 'libsvtav1'\nError selecting an encoder");
    expect(e.kind, ToolErrorKind.encoderMissing);
    expect(e.detail, 'libsvtav1');
  });

  test('missing filter (old and new wording)', () {
    expect(t("[AVFilterGraph @ 0x1] No such filter: 'whisper'").detail, 'whisper');
    expect(t("No filter named 'arnndn'").kind, ToolErrorKind.filterMissing);
  });

  test('container mismatch suggests another container', () {
    expect(t('[mp4 @ 0x1] Could not find tag for codec pcm_s16le in stream #1, codec not currently supported in container').kind,
        ToolErrorKind.codecContainerMismatch);
  });

  test('file errors', () {
    final nf = t('/x/in.mp4: No such file or directory');
    expect(nf.kind, ToolErrorKind.fileNotFound);
    expect(nf.detail, '/x/in.mp4');
    expect(t('out.mp4: Permission denied').kind, ToolErrorKind.permissionDenied);
    expect(t('in.mp4: Invalid data found when processing input').kind, ToolErrorKind.invalidData);
    expect(t('[mov,mp4 @ 0x1] moov atom not found').kind, ToolErrorKind.invalidData);
    expect(t('av_interleaved_write_frame(): No space left on device').kind, ToolErrorKind.diskFull);
  });

  test('hardware encoder problems win over generic lines', () {
    final e = t('[h264_nvenc @ 0x1] Cannot load nvcuda.dll\n'
        "[vost#0:0/h264_nvenc @ 0x1] Error while opening encoder - maybe incorrect parameters such as bit_rate, rate, width or height\n"
        'Conversion failed!');
    expect(e.kind, ToolErrorKind.hwEncoderUnavailable);
    expect(e.detail, 'nvcuda.dll');
    expect(t('[h264_nvenc @ 0x1] OpenEncodeSessionEx failed: unsupported device (2)').kind, ToolErrorKind.hwEncoderUnavailable);
  });

  test('odd dimensions', () {
    expect(t('[libx264 @ 0x1] height not divisible by 2 (320x241)').kind, ToolErrorKind.oddDimensions);
  });

  test('stream map', () {
    final e = t("Stream map '0:a:3' matches no streams.");
    expect(e.kind, ToolErrorKind.streamNotFound);
    expect(e.detail, '0:a:3');
  });

  test('unrecognized option', () {
    expect(t("Unrecognized option 'foo'.\nError splitting the argument list: Option not found").detail, 'foo');
  });

  test('yt-dlp errors', () {
    expect(t('ERROR: Unsupported URL: https://example.com/x').kind, ToolErrorKind.ytdlpUnsupportedUrl);
    expect(t("ERROR: [youtube] abc: Sign in to confirm you're not a bot").kind, ToolErrorKind.ytdlpLoginRequired);
    expect(t('ERROR: [youtube] abc: Video unavailable').kind, ToolErrorKind.ytdlpUnavailable);
  });

  test('cancel and start errors', () {
    expect(translateToolError(const [], canceled: true).kind, ToolErrorKind.canceled);
    expect(translateToolError(const [], startError: 'ffmpeg: No such file').kind, ToolErrorKind.toolMissing);
  });

  test('unknown keeps the last line', () {
    final e = t('something\nConversion failed!\n');
    expect(e.kind, ToolErrorKind.unknown);
    expect(e.line, 'Conversion failed!');
  });
}
