/// Hardware acceleration detection: listed hwaccels + encoders present in the
/// build, then a tiny trial encode per hardware encoder (a listed encoder is
/// often unusable: no GPU, old driver, missing runtime DLL).
library;

import 'dart:io';

import 'capabilities.dart';
import 'process_runner.dart';

enum HwVendor { nvidia, intel, amd, vaapi, vulkan, other }

enum VideoCodecFamily { h264, hevc, av1, vp9 }

class HwEncoderInfo {
  const HwEncoderInfo(this.name, this.vendor, this.family);
  final String name;
  final HwVendor vendor;
  final VideoCodecFamily family;
}

/// Hardware encoders we know how to trial and use, in preference order
/// within each codec family (dedicated encoders first, generic APIs last).
const knownHwEncoders = <HwEncoderInfo>[
  HwEncoderInfo('h264_nvenc', HwVendor.nvidia, VideoCodecFamily.h264),
  HwEncoderInfo('hevc_nvenc', HwVendor.nvidia, VideoCodecFamily.hevc),
  HwEncoderInfo('av1_nvenc', HwVendor.nvidia, VideoCodecFamily.av1),
  HwEncoderInfo('h264_qsv', HwVendor.intel, VideoCodecFamily.h264),
  HwEncoderInfo('hevc_qsv', HwVendor.intel, VideoCodecFamily.hevc),
  HwEncoderInfo('av1_qsv', HwVendor.intel, VideoCodecFamily.av1),
  HwEncoderInfo('vp9_qsv', HwVendor.intel, VideoCodecFamily.vp9),
  HwEncoderInfo('h264_amf', HwVendor.amd, VideoCodecFamily.h264),
  HwEncoderInfo('hevc_amf', HwVendor.amd, VideoCodecFamily.hevc),
  HwEncoderInfo('av1_amf', HwVendor.amd, VideoCodecFamily.av1),
  HwEncoderInfo('h264_vaapi', HwVendor.vaapi, VideoCodecFamily.h264),
  HwEncoderInfo('hevc_vaapi', HwVendor.vaapi, VideoCodecFamily.hevc),
  HwEncoderInfo('av1_vaapi', HwVendor.vaapi, VideoCodecFamily.av1),
  HwEncoderInfo('vp9_vaapi', HwVendor.vaapi, VideoCodecFamily.vp9),
  HwEncoderInfo('h264_vulkan', HwVendor.vulkan, VideoCodecFamily.h264),
  HwEncoderInfo('hevc_vulkan', HwVendor.vulkan, VideoCodecFamily.hevc),
  HwEncoderInfo('av1_vulkan', HwVendor.vulkan, VideoCodecFamily.av1),
];

/// Decode hwaccels in preference order per platform.
List<String> preferredDecodeOrder({required bool windows}) => windows
    ? const ['cuda', 'd3d12va', 'd3d11va', 'qsv', 'vulkan', 'dxva2']
    : const ['cuda', 'vaapi', 'qsv', 'vulkan', 'vdpau'];

const defaultVaapiDevice = '/dev/dri/renderD128';

/// Arguments for a ~0.1 s trial encode that writes nothing to disk.
List<String> trialEncodeArgs(String encoder, {String vaapiDevice = defaultVaapiDevice}) {
  final isVaapi = encoder.endsWith('_vaapi');
  final isVulkan = encoder.endsWith('_vulkan');
  return [
    '-hide_banner',
    '-nostdin',
    '-v',
    'error',
    if (isVaapi) ...['-vaapi_device', vaapiDevice],
    if (isVulkan) ...['-init_hw_device', 'vulkan=vk', '-filter_hw_device', 'vk'],
    '-f',
    'lavfi',
    '-i',
    'color=c=black:s=256x256:r=25:d=0.2',
    '-frames:v',
    '3',
    if (isVaapi || isVulkan) ...['-vf', 'format=nv12,hwupload'],
    '-c:v',
    encoder,
    '-f',
    'null',
    '-',
  ];
}

class HwAccelReport {
  const HwAccelReport({
    required this.hwaccels,
    required this.working,
    required this.failed,
  });

  static const none = HwAccelReport(hwaccels: {}, working: [], failed: {});

  /// From `ffmpeg -hwaccels` (decode side).
  final Set<String> hwaccels;

  /// Encoders that passed the trial encode, in [knownHwEncoders] order.
  final List<HwEncoderInfo> working;

  /// Encoder → first error line.
  final Map<String, String> failed;

  HwEncoderInfo? bestFor(VideoCodecFamily family) {
    for (final e in working) {
      if (e.family == family) return e;
    }
    return null;
  }

  String? bestDecode({required bool windows}) {
    for (final h in preferredDecodeOrder(windows: windows)) {
      if (hwaccels.contains(h)) return h;
    }
    return null;
  }

  Set<HwVendor> get vendors => {for (final e in working) e.vendor};

  Map<String, Object?> toJson() => {
        'hwaccels': hwaccels.toList(),
        'working': working.map((e) => e.name).toList(),
        'failed': failed,
      };

  factory HwAccelReport.fromJson(Map<String, Object?> j) {
    final working = (j['working'] as List? ?? const []).cast<String>().toSet();
    return HwAccelReport(
      hwaccels: (j['hwaccels'] as List? ?? const []).cast<String>().toSet(),
      working: knownHwEncoders.where((e) => working.contains(e.name)).toList(),
      failed: (j['failed'] as Map? ?? const {}).cast<String, String>(),
    );
  }
}

Future<HwAccelReport> detectHwAccel({
  required ProcessRunner runner,
  required String ffmpegPath,
  required FfmpegCapabilities caps,
  Duration perTrialTimeout = const Duration(seconds: 15),
}) async {
  final candidates = knownHwEncoders.where((e) => caps.hasEncoder(e.name)).where((e) {
    // VAAPI is Linux-only; AMF/D3D are Windows-first. Skip the impossible.
    if (e.vendor == HwVendor.vaapi) return !Platform.isWindows && File(defaultVaapiDevice).existsSync();
    return true;
  }).toList();

  final results = await Future.wait(candidates.map((e) async {
    final r = await runner.capture(ffmpegPath, trialEncodeArgs(e.name), timeout: perTrialTimeout);
    return (e, r);
  }));

  final working = <HwEncoderInfo>[];
  final failed = <String, String>{};
  for (final (e, r) in results) {
    if (r.ok) {
      working.add(e);
    } else {
      final msg = r.timedOut
          ? 'timeout'
          : r.stderr.split('\n').map((l) => l.trim()).firstWhere((l) => l.isNotEmpty, orElse: () => 'exit ${r.exitCode}');
      failed[e.name] = msg;
    }
  }
  return HwAccelReport(hwaccels: caps.hwaccels, working: working, failed: failed);
}
