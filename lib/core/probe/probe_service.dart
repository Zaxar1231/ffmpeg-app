import 'dart:convert';

import '../engine/process_runner.dart';
import 'media_info.dart';

class ProbeException implements Exception {
  ProbeException(this.message, {this.log = ''});
  final String message;
  final String log;
  @override
  String toString() => 'ProbeException: $message';
}

/// `ffprobe -v error -print_format json -show_format -show_streams -show_chapters <file>`
List<String> probeArgs(String path) => [
      '-v',
      'error',
      '-print_format',
      'json',
      '-show_format',
      '-show_streams',
      '-show_chapters',
      path,
    ];

class ProbeService {
  const ProbeService({required this.runner, required this.ffprobePath});

  final ProcessRunner runner;
  final String ffprobePath;

  Future<MediaInfo> probe(String path) async {
    final r = await runner.capture(ffprobePath, probeArgs(path), timeout: const Duration(seconds: 60));
    if (r.startFailed) throw ProbeException('ffprobe not found', log: r.stderr);
    if (!r.ok) throw ProbeException(r.stderr.trim().isEmpty ? 'ffprobe exit ${r.exitCode}' : r.stderr.trim(), log: r.stderr);
    final Object? json;
    try {
      json = jsonDecode(r.stdout);
    } on FormatException catch (e) {
      throw ProbeException('Invalid ffprobe output: ${e.message}', log: r.stdout);
    }
    if (json is! Map) throw ProbeException('Invalid ffprobe output');
    return MediaInfo.fromJson(path, json.cast<String, dynamic>());
  }
}
