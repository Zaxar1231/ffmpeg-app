/// Expert tools (stage 5): raw command parsing for the command editor,
/// templates, and help lookups (`ffmpeg -h <kind>=<name>`).
library;

import 'package:path/path.dart' as p;

import '../../core/engine/shell_quote.dart';
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
  return ParsedCommand(tool, [...extra, ...args], inputs: inputs, output: out);
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
