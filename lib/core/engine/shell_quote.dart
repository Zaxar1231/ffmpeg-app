/// Quoting used only for *displaying* commands (copy to a terminal).
/// Processes are always started with an argument list, never via a shell.
library;

final _posixSafe = RegExp(r'^[A-Za-z0-9_@%+=:,./-]+$');
final _winSafe = RegExp(r'^[A-Za-z0-9_@%+=:,./\\-]+$');

String quoteArg(String arg, {bool windows = false}) {
  if (arg.isEmpty) return windows ? '""' : "''";
  if (windows) {
    if (_winSafe.hasMatch(arg)) return arg;
    // cmd.exe / PowerShell compatible enough for paths and filtergraphs.
    return '"${arg.replaceAll('"', r'\"')}"';
  }
  if (_posixSafe.hasMatch(arg)) return arg;
  return "'${arg.replaceAll("'", r"'\''")}'";
}

String quoteCommand(List<String> args, {bool windows = false}) =>
    args.map((a) => quoteArg(a, windows: windows)).join(' ');

/// Splits a command line typed by the user into arguments.
/// Supports single quotes, double quotes and backslash escapes (POSIX-like),
/// which is what the expert command editor accepts on every platform.
List<String> splitCommandLine(String input) {
  final result = <String>[];
  final current = StringBuffer();
  var inSingle = false;
  var inDouble = false;
  var hasToken = false;
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (inSingle) {
      if (c == "'") {
        inSingle = false;
      } else {
        current.write(c);
      }
      continue;
    }
    if (inDouble) {
      if (c == '"') {
        inDouble = false;
      } else if (c == r'\' && i + 1 < input.length && (input[i + 1] == '"' || input[i + 1] == r'\')) {
        current.write(input[++i]);
      } else {
        current.write(c);
      }
      continue;
    }
    if (c == "'") {
      inSingle = true;
      hasToken = true;
    } else if (c == '"') {
      inDouble = true;
      hasToken = true;
    } else if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
      if (hasToken) {
        result.add(current.toString());
        current.clear();
        hasToken = false;
      }
    } else if (c == r'\' && i + 1 < input.length && input[i + 1] != r'\' && RegExp(r"""[\s'"]""").hasMatch(input[i + 1])) {
      current.write(input[++i]);
      hasToken = true;
    } else {
      current.write(c);
      hasToken = true;
    }
  }
  if (inSingle || inDouble) {
    throw const FormatException('Unterminated quote');
  }
  if (hasToken) result.add(current.toString());
  return result;
}
