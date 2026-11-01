import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/capabilities.dart';
import 'package:kadra/core/engine/hwaccel.dart';

String fx(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  test('version and configuration', () {
    final v = parseVersionOutput(fx('ff_version.txt'));
    expect(v.version, '6.1.1-3ubuntu5');
    expect(v.configuration, contains('--enable-gpl'));
    expect(v.configuration, contains('--enable-libx264'));
    final caps = FfmpegCapabilities(
      version: v.version,
      configuration: v.configuration,
      encoders: const {},
      decoders: const {},
      filters: const {},
      muxers: const {},
      hwaccels: const {},
    );
    expect(caps.majorVersion, 6);
    expect(caps.isGpl, isTrue);
    expect(caps.isEnabled('libx264'), isTrue);
  });

  test('git build has no major version', () {
    const caps = FfmpegCapabilities(
      version: 'N-121000-g1234abcd-20251101',
      configuration: [],
      encoders: {},
      decoders: {},
      filters: {},
      muxers: {},
      hwaccels: {},
    );
    expect(caps.majorVersion, isNull);
    const n8 = FfmpegCapabilities(
      version: 'n8.1-12-gabc',
      configuration: [],
      encoders: {},
      decoders: {},
      filters: {},
      muxers: {},
      hwaccels: {},
    );
    expect(n8.majorVersion, 8);
  });

  test('encoders', () {
    final enc = parseCodecList(fx('ff_encoders.txt'));
    expect(enc.length, greaterThan(150));
    expect(enc['libx264']!.kind, MediaKind.video);
    expect(enc['aac']!.kind, MediaKind.audio);
    expect(enc['srt']!.kind, MediaKind.subtitle);
    // Legend lines must not leak in.
    expect(enc.containsKey('='), isFalse);
    expect(enc.keys, isNot(contains('Video')));
  });

  test('decoders', () {
    final dec = parseCodecList(fx('ff_decoders.txt'));
    expect(dec['h264']!.kind, MediaKind.video);
    expect(dec['opus'], isNotNull);
  });

  test('filters', () {
    final f = parseFilterList(fx('ff_filters.txt'));
    expect(f.length, greaterThan(400));
    expect(f['loudnorm']!.io, 'A->A');
    expect(f['scale']!.io, 'V->V');
    expect(f['hstack']!.io, 'N->V');
    expect(f['showwavespic']!.io, 'A->V');
    expect(f['acompressor']!.commands, isTrue);
    expect(f.containsKey('='), isFalse);
  });

  test('muxers', () {
    final m = parseMuxerList(fx('ff_muxers.txt'));
    expect(m.keys, containsAll(['mp4', 'matroska', 'webm', 'mov', 'null', 'segment', 'hls']));
    expect(m.containsKey('D.'), isFalse);
  });

  test('muxers in ffmpeg 7 three-column layout', () {
    const out =
        'File formats:\n D.. = Demuxing supported\n .E. = Muxing supported\n ..d = Is a device\n ---\n'
        '  E  3g2             3GP2\n DE  matroska        Matroska\n  Ed alsa            ALSA audio output\n D   aa   Audible\n';
    final m = parseMuxerList(out);
    expect(m.keys, containsAll(['3g2', 'matroska', 'alsa']));
    expect(m.containsKey('aa'), isFalse);
  });

  test('hwaccels', () {
    expect(parseHwaccels(fx('ff_hwaccels.txt')), {'vdpau', 'cuda', 'vaapi', 'qsv', 'drm', 'opencl', 'vulkan'});
    expect(parseHwaccels('garbage'), isEmpty);
  });

  group('hwaccel', () {
    test('trial args for plain, vaapi and vulkan encoders', () {
      final nv = trialEncodeArgs('h264_nvenc');
      expect(
        nv,
        containsAllInOrder([
          '-f',
          'lavfi',
          '-i',
          'color=c=black:s=256x256:r=25:d=0.2',
          '-c:v',
          'h264_nvenc',
          '-f',
          'null',
          '-',
        ]),
      );
      expect(nv, isNot(contains('-vf')));
      final va = trialEncodeArgs('hevc_vaapi');
      expect(va, containsAllInOrder(['-vaapi_device', '/dev/dri/renderD128', '-i']));
      expect(va, containsAllInOrder(['-vf', 'format=nv12,hwupload', '-c:v', 'hevc_vaapi']));
      final vk = trialEncodeArgs('h264_vulkan');
      expect(vk, containsAllInOrder(['-init_hw_device', 'vulkan=vk', '-filter_hw_device', 'vk']));
    });

    test('report picks best per family and decode order', () {
      final r = HwAccelReport(
        hwaccels: const {'vaapi', 'cuda', 'd3d11va'},
        working: knownHwEncoders.where((e) => ['hevc_qsv', 'h264_nvenc', 'h264_qsv'].contains(e.name)).toList(),
        failed: const {},
      );
      expect(r.bestFor(VideoCodecFamily.h264)!.name, 'h264_nvenc');
      expect(r.bestFor(VideoCodecFamily.hevc)!.name, 'hevc_qsv');
      expect(r.bestFor(VideoCodecFamily.av1), isNull);
      expect(r.bestDecode(windows: true), 'cuda');
      expect(r.bestDecode(windows: false), 'cuda');
      expect(r.vendors, {HwVendor.nvidia, HwVendor.intel});
      final back = HwAccelReport.fromJson(r.toJson());
      expect(back.working.map((e) => e.name), r.working.map((e) => e.name));
    });
  });
}
