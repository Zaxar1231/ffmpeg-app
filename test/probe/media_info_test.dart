import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/probe/media_info.dart';
import 'package:kadra/core/probe/probe_service.dart';

MediaInfo load(String name) =>
    MediaInfo.fromJson(name, (jsonDecode(File('test/fixtures/$name').readAsStringSync()) as Map).cast<String, dynamic>());

void main() {
  test('probe args', () {
    expect(probeArgs('a b.mp4'),
        ['-v', 'error', '-print_format', 'json', '-show_format', '-show_streams', '-show_chapters', 'a b.mp4']);
  });

  test('mkv with video, audio, chapters, tags', () {
    final m = load('probe_mkv.json');
    expect(m.category, MediaCategory.video);
    expect(m.format.formatName, 'matroska,webm');
    expect(m.format.tags['title'], 'Test Movie');
    expect(m.duration!.inMilliseconds, closeTo(2000, 60));
    final v = m.videoStreams.single;
    expect(v.codecName, 'h264');
    expect(v.width, 320);
    expect(v.height, 240);
    expect(v.frameRate, 25);
    expect(v.bitDepth, 8);
    expect(v.hdr, HdrKind.sdr);
    final a = m.audioStreams.single;
    expect(a.codecName, 'aac');
    expect(a.language, 'rus');
    expect(a.sampleRate, 44100);
    expect(a.duration, isNotNull, reason: 'Matroska DURATION tag');
    expect(m.chapters.map((c) => c.title), ['Intro', 'Main']);
    expect(m.chapters[1].start, const Duration(seconds: 1));
  });

  test('mp3 is audio', () {
    final m = load('probe_mp3.json');
    expect(m.category, MediaCategory.audio);
    expect(m.audioStreams.single.codecName, 'mp3');
    expect(m.format.bitRate, greaterThan(0));
  });

  test('png is an image', () {
    expect(load('probe_png.json').category, MediaCategory.image);
  });

  test('HDR10 and Dolby Vision detection, rotation, 10-bit', () {
    final s = StreamInfo.fromJson({
      'index': 0,
      'codec_type': 'video',
      'codec_name': 'hevc',
      'pix_fmt': 'yuv420p10le',
      'color_transfer': 'smpte2084',
      'color_primaries': 'bt2020',
      'side_data_list': [
        {'side_data_type': 'Mastering display metadata', 'max_luminance': '1000/1'},
        {'side_data_type': 'Display Matrix', 'rotation': -90},
      ],
      'disposition': {'default': 1, 'attached_pic': 0},
    });
    expect(s.hdr, HdrKind.hdr10);
    expect(s.bitDepth, 10);
    expect(s.rotation, -90);
    expect(s.masteringDisplay, isNotNull);
    expect(s.isDefault, isTrue);

    final dv = StreamInfo.fromJson({
      'index': 0,
      'codec_type': 'video',
      'side_data_list': [
        {'side_data_type': 'DOVI configuration record'},
      ],
    });
    expect(dv.hdr, HdrKind.dolbyVision);
    expect(StreamInfo.fromJson({'index': 0, 'codec_type': 'video', 'color_transfer': 'arib-std-b67'}).hdr, HdrKind.hlg);
  });

  test('helpers are tolerant', () {
    expect(parseRational('30000/1001'), closeTo(29.97, 0.001));
    expect(parseRational('0/0'), isNull);
    expect(parseSeconds('N/A'), isNull);
    expect(parseSeconds('1.5'), const Duration(milliseconds: 1500));
    expect(parseIntField('12'), 12);
    expect(parseIntField(null), isNull);
    expect(parseTagDuration('00:01:02.500000000'), const Duration(minutes: 1, seconds: 2, milliseconds: 500));
  });

  test('audio file with cover art is audio, cover is detected', () {
    final m = MediaInfo.fromJson('x.mp3', {
      'format': {'duration': '120.0'},
      'streams': [
        {'index': 0, 'codec_type': 'audio', 'codec_name': 'mp3'},
        {'index': 1, 'codec_type': 'video', 'codec_name': 'mjpeg', 'disposition': {'attached_pic': 1}},
      ],
    });
    expect(m.category, MediaCategory.audio);
    expect(m.coverArt, isNotNull);
    expect(m.videoStreams, isEmpty);
  });
}
