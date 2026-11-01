/// Turns raw ffmpeg / yt-dlp stderr into a known problem category.
/// The UI maps [ToolErrorKind] to a localized, human-friendly message;
/// the full log stays available behind a button.
library;

enum ToolErrorKind {
  toolMissing,
  fileNotFound,
  permissionDenied,
  diskFull,
  invalidData,
  encoderMissing,
  decoderMissing,
  filterMissing,
  codecContainerMismatch,
  oddDimensions,
  hwEncoderUnavailable,
  invalidArgument,
  streamNotFound,
  outputSameAsInput,
  networkError,
  ytdlpUnsupportedUrl,
  ytdlpLoginRequired,
  ytdlpUnavailable,
  canceled,
  unknown,
}

class ToolError {
  const ToolError(this.kind, {this.detail, this.line});

  final ToolErrorKind kind;

  /// Extracted name (encoder, filter, path...) when available.
  final String? detail;

  /// The log line that matched, shown under the friendly message.
  final String? line;

  @override
  String toString() => 'ToolError($kind, $detail)';
}

class _Rule {
  const _Rule(this.pattern, this.kind, {this.detailGroup});
  final RegExp pattern;
  final ToolErrorKind kind;
  final int? detailGroup;
}

final _rules = <_Rule>[
  // Hardware encoders first: their failures often also print generic lines.
  _Rule(RegExp(r'Cannot load (nvcuda\.dll|libcuda\.so[.\d]*|nvEncodeAPI64\.dll|libnvidia-encode\.so[.\d]*)'),
      ToolErrorKind.hwEncoderUnavailable, detailGroup: 1),
  _Rule(RegExp(r'OpenEncodeSessionEx failed|No NVENC capable devices found|No capable devices found'),
      ToolErrorKind.hwEncoderUnavailable),
  _Rule(RegExp(r'(?:Error creating a MFX session|MFX session|Failed to create a VAAPI device|Failed to initialise VAAPI|DLL amfrt64\.dll failed to open|AMF failed)'),
      ToolErrorKind.hwEncoderUnavailable),
  _Rule(RegExp(r"Unknown encoder '([^']+)'"), ToolErrorKind.encoderMissing, detailGroup: 1),
  _Rule(RegExp(r"Encoder '?([\w-]+)'? not found"), ToolErrorKind.encoderMissing, detailGroup: 1),
  _Rule(RegExp(r"Unknown decoder '([^']+)'"), ToolErrorKind.decoderMissing, detailGroup: 1),
  _Rule(RegExp(r"Decoder \(codec ([\w-]+)\) not found"), ToolErrorKind.decoderMissing, detailGroup: 1),
  _Rule(RegExp(r"No (?:such )?filter(?: named)?:? '([^']+)'"), ToolErrorKind.filterMissing, detailGroup: 1),
  _Rule(RegExp(r"Filter '?([\w-]+)'? not found"), ToolErrorKind.filterMissing, detailGroup: 1),
  _Rule(RegExp(r'codec not currently supported in container|Could not find tag for codec ([\w-]+)'),
      ToolErrorKind.codecContainerMismatch, detailGroup: 1),
  _Rule(RegExp(r'(?:width|height) not divisible by 2|not divisible by 2', caseSensitive: false), ToolErrorKind.oddDimensions),
  _Rule(RegExp(r'Output (.+) same as Input'), ToolErrorKind.outputSameAsInput, detailGroup: 1),
  _Rule(RegExp(r'No space left on device'), ToolErrorKind.diskFull),
  _Rule(RegExp(r'(.+?): Permission denied'), ToolErrorKind.permissionDenied, detailGroup: 1),
  _Rule(RegExp(r'(.+?): No such file or directory'), ToolErrorKind.fileNotFound, detailGroup: 1),
  _Rule(RegExp(r'(.+?): Invalid data found when processing input'), ToolErrorKind.invalidData, detailGroup: 1),
  _Rule(RegExp(r'moov atom not found'), ToolErrorKind.invalidData),
  _Rule(RegExp(r"Stream map '([^']*)' matches no streams|Stream specifier '([^']*)'.*matches no streams"),
      ToolErrorKind.streamNotFound, detailGroup: 1),
  _Rule(RegExp(r"Unrecognized option '([^']+)'"), ToolErrorKind.invalidArgument, detailGroup: 1),
  _Rule(RegExp(r'Option ([\w:-]+) not found'), ToolErrorKind.invalidArgument, detailGroup: 1),
  _Rule(RegExp(r'Error (?:applying|setting) option'), ToolErrorKind.invalidArgument),
  // yt-dlp
  _Rule(RegExp(r'ERROR: Unsupported URL: (\S+)'), ToolErrorKind.ytdlpUnsupportedUrl, detailGroup: 1),
  _Rule(RegExp(r'Sign in to confirm|login required|Use --cookies|This video is private|members-only', caseSensitive: false),
      ToolErrorKind.ytdlpLoginRequired),
  _Rule(RegExp(r'ERROR: .*(Video unavailable|This video is not available|HTTP Error 404)'), ToolErrorKind.ytdlpUnavailable),
  _Rule(RegExp(r'(?:Connection refused|Connection reset|Network is unreachable|Temporary failure in name resolution|getaddrinfo failed|timed out)', caseSensitive: false),
      ToolErrorKind.networkError),
];

/// Finds the most specific known problem in [log]. Rules are ordered by
/// priority; within a rule the last matching line wins (closest to failure).
ToolError translateToolError(Iterable<String> log, {bool canceled = false, String? startError}) {
  if (canceled) return const ToolError(ToolErrorKind.canceled);
  if (startError != null) return ToolError(ToolErrorKind.toolMissing, line: startError);
  final lines = log.toList();
  for (final rule in _rules) {
    for (var i = lines.length - 1; i >= 0; i--) {
      final m = rule.pattern.firstMatch(lines[i]);
      if (m == null) continue;
      String? detail;
      final g = rule.detailGroup;
      if (g != null) {
        detail = m.group(g);
        // Some rules have alternative groups.
        for (var k = 1; detail == null && k <= m.groupCount; k++) {
          detail = m.group(k);
        }
      }
      return ToolError(rule.kind, detail: detail?.trim(), line: lines[i].trim());
    }
  }
  final last = lines.lastWhere((l) => l.trim().isNotEmpty, orElse: () => '');
  return ToolError(ToolErrorKind.unknown, line: last.isEmpty ? null : last.trim());
}
