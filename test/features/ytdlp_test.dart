import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/progress.dart';
import 'package:kadra/core/ytdlp/ytdlp.dart';

void main() {
  test('info: single video with formats and subtitles', () {
    final i = YtInfo.fromJson({
      'id': 'abc',
      'title': 'Hello',
      'uploader': 'Me',
      'duration': 125.5,
      'webpage_url': 'https://site/v/abc',
      'thumbnails': [
        {'url': 'https://t/1.jpg'},
        {'url': 'https://t/2.jpg'},
      ],
      'subtitles': {
        'ru': [{}],
      },
      'automatic_captions': {
        'en': [{}],
      },
      'formats': [
        {'format_id': 'sb0', 'ext': 'mhtml', 'format_note': 'storyboard', 'vcodec': 'none', 'acodec': 'none'},
        {'format_id': '140', 'ext': 'm4a', 'vcodec': 'none', 'acodec': 'mp4a.40.2', 'filesize': 1000},
        {'format_id': '137', 'ext': 'mp4', 'vcodec': 'avc1', 'acodec': 'none', 'height': 1080, 'fps': 30},
        {'format_id': '22', 'ext': 'mp4', 'vcodec': 'avc1', 'acodec': 'mp4a', 'height': 720, 'filesize_approx': 5000},
      ],
    });
    expect(i.isPlaylist, isFalse);
    expect(i.duration, const Duration(milliseconds: 125500));
    expect(i.thumbnail, 'https://t/2.jpg');
    expect(i.heights, [1080, 720]);
    expect(i.hasSubtitles, isTrue);
    expect(i.hasAutoSubtitles, isTrue);
    expect(i.formats.firstWhere((f) => f.id == '22').filesize, 5000);
    expect(i.formats.first.isStoryboard, isTrue);
  });

  test('info: flat playlist', () {
    final i = YtInfo.fromJson({
      '_type': 'playlist',
      'title': 'List',
      'entries': [
        {'_type': 'url', 'id': 'a', 'url': 'https://site/v/a', 'title': 'A', 'duration': 60},
        null,
        {'_type': 'url', 'id': 'c', 'url': 'https://site/v/c', 'title': 'C'},
      ],
    });
    expect(i.isPlaylist, isTrue);
    expect(i.entries.map((e) => e.index), [1, 3]);
    expect(i.entries.first.duration, const Duration(minutes: 1));
  });

  test('format selectors', () {
    expect(ytdlpFormatArgs(const YtDownloadParams()), ['-f', 'bv*+ba/b', '-S', 'vcodec:h264,res,acodec:m4a']);
    expect(ytdlpFormatArgs(const YtDownloadParams(quality: YtQuality.maxHeight, maxHeight: 720, container: 'mkv')), [
      '-f',
      'bv*[height<=720]+ba/b[height<=720]/bv*+ba/b',
    ]);
    expect(ytdlpFormatArgs(const YtDownloadParams(quality: YtQuality.audioOnly)), [
      '-f',
      'ba/b',
      '-x',
      '--audio-format',
      'mp3',
      '--audio-quality',
      '0',
    ]);
    const vOnly = YtFormat(id: '137', vcodec: 'avc1', acodec: 'none');
    expect(
      ytdlpFormatArgs(
        const YtDownloadParams(quality: YtQuality.format, formatId: '137'),
        chosen: vOnly,
      ),
      ['-f', '137+ba/137'],
    );
  });

  test('download args', () {
    final a = ytdlpDownloadArgs(
      url: 'https://site/v/a',
      outputDir: '/out',
      p: const YtDownloadParams(
        subtitles: true,
        sponsorBlock: SponsorBlockMode.remove,
        cookiesFromBrowser: 'firefox',
        archiveFile: '/out/.a.txt',
      ),
      tools: const YtTools(ffmpeg: '/ff/ffmpeg', deno: '/d/deno', concurrentFragments: 8),
    );
    expect(a, containsAllInOrder(['--progress-template', ytdlpProgressTemplate]));
    expect(a, containsAllInOrder(['--print', 'after_move:[kadra-file] %(filepath)s']));
    expect(a, containsAllInOrder(['-N', '8', '--ffmpeg-location', '/ff/ffmpeg', '--js-runtimes', 'deno:/d/deno']));
    expect(
      a,
      containsAllInOrder(['--merge-output-format', 'mp4', '--write-subs', '--sub-langs', 'ru,en', '--embed-subs']),
    );
    expect(a, containsAllInOrder(['--sponsorblock-remove', 'sponsor,selfpromo,interaction']));
    expect(a, containsAllInOrder(['--cookies-from-browser', 'firefox', '--download-archive', '/out/.a.txt']));
    expect(a.sublist(a.length - 5), ['-P', '/out', '-o', '%(title)s [%(id)s].%(ext)s', 'https://site/v/a']);
    expect(a, contains('--no-playlist'));
  });

  test('progress lines (captured from a real yt-dlp run)', () {
    final p = parseYtdlpProgressLine('[kadra] 1047552|2848208|NA|3185537.64|0|NA|NA|downloading')!;
    expect(p.downloadedBytes, 1047552);
    expect(p.totalBytes, 2848208);
    expect(p.fraction, closeTo(0.3678, 0.001));
    expect(p.bytesPerSecond, closeTo(3185537.64, 0.1));
    expect(p.eta, Duration.zero);
    final f = parseYtdlpProgressLine('[kadra] 2848208|2848208|NA|2811534.67|NA|NA|NA|finished')!;
    expect(f.fraction, 1);
    final frag = parseYtdlpProgressLine('[kadra] 500|NA|NA|NA|NA|3|12|downloading')!;
    expect(frag.fraction, 0.25);
    expect(parseYtdlpProgressLine('[download] 50%'), isNull);
  });

  test('urls and ranges', () {
    expect(extractUrls('look https://a.b/c?x=1 and\nhttp://d.e/f, https://a.b/c?x=1'), [
      'https://a.b/c?x=1',
      'http://d.e/f',
    ]);
    expect(parseItemRanges('1, 3,5-7, x, 9-8', max: 6), {1, 3, 5, 6});
  });
}
