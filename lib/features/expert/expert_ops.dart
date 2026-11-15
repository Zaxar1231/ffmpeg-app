/// Expert tools (stage 5): raw command parsing for the command editor,
/// templates, and help lookups (`ffmpeg -h <kind>=<name>`).
library;

import 'package:path/path.dart' as p;

import '../../core/engine/shell_quote.dart';
import '../../core/engine/capabilities.dart';
import '../../core/engine/ffmpeg_command.dart' show lameSafe, usesLame;
import '../../core/queue/queue_models.dart';

class ParsedCommand {
  const ParsedCommand(this.tool, this.args, {this.inputs = const [], this.output});
  final JobTool tool;

  /// Arguments without the executable, with the app's safety options added.
  final List<String> args;
  final List<String> inputs;

  /// Last non-option argument of an ffmpeg command (null for ffprobe).
  final String? output;
}

class CommandParseError implements Exception {
  const CommandParseError(this.kind);

  /// `syntax`, `empty`, `executable`, `noInput`, `placeholder`.
  final String kind;
}

/// Parses text typed in the command editor. The executable may be written
/// or omitted (`ffmpeg`, `ffmpeg.exe`, a full path, or `ffprobe`). For
/// ffmpeg, `-nostdin` (never wait for keyboard input), `-y` (unless `-n`)
/// and `-progress pipe:1 -nostats` (progress bar) are added when missing.
ParsedCommand parseCommand(String text) {
  final List<String> raw;
  try {
    // Line continuations from shells: `\` (bash) and `^` (cmd) at line end.
    raw = splitCommandLine(text.replaceAll(RegExp(r'[\\^]\r?\n'), ' ').replaceAll(RegExp(r'\r?\n'), ' '));
  } on FormatException {
    throw const CommandParseError('syntax');
  }
  if (raw.isEmpty) throw const CommandParseError('empty');
  if (raw.any((a) => a.contains('{in}') || a.contains('{out}'))) throw const CommandParseError('placeholder');
  var tool = JobTool.ffmpeg;
  var args = raw;
  final exe = p.basenameWithoutExtension(raw.first.replaceAll(r'\', '/')).toLowerCase();
  if (exe == 'ffmpeg' || exe == 'ffprobe') {
    tool = exe == 'ffprobe' ? JobTool.ffprobe : JobTool.ffmpeg;
    args = raw.sublist(1);
  } else if (exe == 'yt-dlp' || exe == 'ffplay') {
    throw const CommandParseError('executable');
  }
  final inputs = <String>[];
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '-i') inputs.add(args[i + 1]);
  }
  if (tool == JobTool.ffprobe) {
    if (args.isEmpty) throw const CommandParseError('noInput');
    final input = inputs.isNotEmpty ? inputs : [if (!args.last.startsWith('-')) args.last];
    return ParsedCommand(tool, ['-hide_banner', ...args.where((a) => a != '-hide_banner')], inputs: input);
  }
  if (inputs.isEmpty) throw const CommandParseError('noInput');
  final out = args.isNotEmpty && !args.last.startsWith('-') && (args.length < 2 || args[args.length - 2] != '-i')
      ? args.last
      : null;
  final extra = <String>[
    if (!args.contains('-nostdin')) '-nostdin',
    if (!args.contains('-y') && !args.contains('-n')) '-y',
    if (!args.contains('-progress')) ...['-progress', 'pipe:1'],
    if (!args.contains('-nostats') && !args.contains('-stats')) '-nostats',
    if (!args.contains('-hide_banner')) '-hide_banner',
  ];
  // MP3: see lameSafe (NaN or absurd samples make LAME fail with -12).
  final lame = out != null && usesLame(args) && !args.contains('-sample_fmt')
      ? [...args.sublist(0, args.length - 1), ...lameSafe, args.last]
      : args;
  return ParsedCommand(tool, [...extra, ...lame], inputs: inputs, output: out);
}

/// Text for the editor from a job's arguments (`ffmpeg …`).
String commandToText(JobTool tool, List<String> args, {bool windows = false}) {
  final exe = switch (tool) {
    JobTool.ffmpeg => 'ffmpeg',
    JobTool.ffprobe => 'ffprobe',
    JobTool.ytdlp => 'yt-dlp',
  };
  // Hide the app's own plumbing to keep the command readable.
  final a = <String>[];
  for (var i = 0; i < args.length; i++) {
    final x = args[i];
    if (x == '-progress' && i + 1 < args.length) {
      i++;
      continue;
    }
    if (x == '-nostats' || x == '-nostdin') continue;
    a.add(x);
  }
  return quoteCommand([exe, ...a], windows: windows);
}

class CommandTemplate {
  const CommandTemplate(this.id, this.text, {this.ext});
  final String id;

  /// Output extension (null = same as the input).
  final String? ext;

  /// `{in}` / `{out}` are replaced with the chosen files.
  final String text;
}

const commandTemplates = [
  CommandTemplate(
    'h264',
    'ffmpeg -i "{in}" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 160k "{out}"',
    ext: 'mp4',
  ),
  CommandTemplate('cutCopy', 'ffmpeg -ss 00:00:10 -i "{in}" -t 30 -map 0 -c copy "{out}"'),
  CommandTemplate('frame', 'ffmpeg -ss 5 -i "{in}" -frames:v 1 "{out}"', ext: 'png'),
  CommandTemplate('mp3', 'ffmpeg -i "{in}" -vn -c:a libmp3lame -q:a 2 "{out}"', ext: 'mp3'),
  CommandTemplate(
    'speed2x',
    'ffmpeg -i "{in}" -filter_complex "[0:v]setpts=PTS/2[v];[0:a]atempo=2[a]" -map "[v]" -map "[a]" "{out}"',
    ext: 'mp4',
  ),
  CommandTemplate(
    'gifPalette',
    'ffmpeg -i "{in}" -vf "fps=12,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" "{out}"',
  ),
  CommandTemplate('probe', 'ffprobe -show_format -show_streams "{in}"'),
];

String fillTemplate(String text, {String? input, String? output}) =>
    text.replaceAll('{in}', input ?? '{in}').replaceAll('{out}', output ?? '{out}');

/// Kinds for `ffmpeg -h <kind>=<name>`.
const helpKinds = ['filter', 'encoder', 'decoder', 'muxer', 'demuxer', 'bsf', 'protocol'];

List<String> helpArgs(String kind, String name) => ['-hide_banner', '-h', '$kind=${name.trim()}'];

// ---------------------------------------------------------------- completion

enum CompletionKind { option, videoEncoder, audioEncoder, subtitleEncoder, anyEncoder, format, filter, hwaccel }

/// What is being typed at the cursor: the kind of name, the typed prefix and
/// where it starts in the text (to replace it on accept).
class CompletionContext {
  const CompletionContext(this.kind, this.prefix, this.start);
  final CompletionKind kind;
  final String prefix;
  final int start;
}

const _filterOptions = {'-vf', '-af', '-filter:v', '-filter:a', '-filter_complex', '-lavfi', '-filter'};

/// Common ffmpeg options offered after `-` (all are in `ffmpeg -h full`).
const commonOptions = [
  '-i',
  '-c',
  '-c:v',
  '-c:a',
  '-c:s',
  '-map',
  '-vf',
  '-af',
  '-filter_complex',
  '-ss',
  '-to',
  '-t',
  '-f',
  '-crf',
  '-b:v',
  '-b:a',
  '-maxrate',
  '-bufsize',
  '-preset',
  '-tune',
  '-profile:v',
  '-pix_fmt',
  '-r',
  '-g',
  '-ar',
  '-ac',
  '-an',
  '-vn',
  '-sn',
  '-y',
  '-n',
  '-hwaccel',
  '-metadata',
  '-map_metadata',
  '-map_chapters',
  '-movflags',
  '-shortest',
  '-frames:v',
  '-q:v',
  '-q:a',
  '-threads',
  '-disposition',
  '-itsoffset',
  '-loop',
];

/// Finds the completion context at [cursor] in a command line.
CompletionContext? completionAt(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return null;
  final tokens = <String>[];
  final cur = StringBuffer();
  String? quote;
  for (var i = 0; i < cursor; i++) {
    final ch = text[i];
    if (quote != null) {
      if (ch == quote) {
        quote = null;
      } else {
        cur.write(ch);
      }
      continue;
    }
    if (ch == '"' || ch == "'") {
      quote = ch;
    } else if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
      if (cur.isNotEmpty) tokens.add(cur.toString());
      cur.clear();
    } else {
      cur.write(ch);
    }
  }
  final partial = cur.toString();
  final prev = tokens.lastOrNull;
  // Inside a filter graph: the name after the last separator, before any '='.
  if (prev != null && _filterOptions.contains(prev)) {
    final sep = partial.lastIndexOf(RegExp(r'[,;\]\[]'));
    final name = partial.substring(sep + 1);
    if (!RegExp(r'^[a-z0-9_]*$').hasMatch(name)) return null;
    return CompletionContext(CompletionKind.filter, name, cursor - name.length);
  }
  if (quote != null) return null;
  if (partial.startsWith('-')) return CompletionContext(CompletionKind.option, partial, cursor - partial.length);
  if (prev == null || !RegExp(r'^[A-Za-z0-9_.-]*$').hasMatch(partial)) return null;
  final kind = switch (prev) {
    '-c:v' || '-vcodec' || '-codec:v' => CompletionKind.videoEncoder,
    '-c:a' || '-acodec' || '-codec:a' => CompletionKind.audioEncoder,
    '-c:s' || '-scodec' || '-codec:s' => CompletionKind.subtitleEncoder,
    '-c' || '-codec' => CompletionKind.anyEncoder,
    '-f' => CompletionKind.format,
    '-hwaccel' => CompletionKind.hwaccel,
    _ => null,
  };
  if (kind == null) return null;
  return CompletionContext(kind, partial, cursor - partial.length);
}

/// Names of [ctx]'s kind from the installed build, best matches first:
/// prefix matches, then other matches; `copy` for codecs.
List<(String, String)> completionCandidates(CompletionContext ctx, FfmpegCapabilities caps, {int limit = 12}) {
  Iterable<(String, String)> all;
  MediaKind? kind;
  switch (ctx.kind) {
    case CompletionKind.option:
      all = [for (final o in commonOptions) (o, '')];
    case CompletionKind.filter:
      all = [for (final f in caps.filters.values) (f.name, f.description)];
    case CompletionKind.format:
      all = [for (final e in caps.muxers.entries) (e.key, e.value)];
    case CompletionKind.hwaccel:
      all = [for (final h in caps.hwaccels) (h, '')];
    case CompletionKind.videoEncoder ||
        CompletionKind.audioEncoder ||
        CompletionKind.subtitleEncoder ||
        CompletionKind.anyEncoder:
      kind = switch (ctx.kind) {
        CompletionKind.videoEncoder => MediaKind.video,
        CompletionKind.audioEncoder => MediaKind.audio,
        CompletionKind.subtitleEncoder => MediaKind.subtitle,
        _ => null,
      };
      all = [
        ('copy', ''),
        for (final e in caps.encoders.values)
          if (kind == null || e.kind == kind) (e.name, e.description),
      ];
  }
  final q = ctx.prefix.toLowerCase();
  final starts = <(String, String)>[], contains = <(String, String)>[];
  for (final e in all) {
    final n = e.$1.toLowerCase();
    if (n == q) continue;
    if (n.startsWith(q)) {
      starts.add(e);
    } else if (q.isNotEmpty && n.contains(q)) {
      contains.add(e);
    }
  }
  starts.sort((a, b) => a.$1.length != b.$1.length ? a.$1.length - b.$1.length : a.$1.compareTo(b.$1));
  return [...starts, ...contains].take(limit).toList();
}
