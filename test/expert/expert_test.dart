import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/queue/queue_models.dart';
import 'package:kadra/features/expert/expert_ops.dart';

void main() {
  test('ffmpeg with executable, quotes and continuations', () {
    final c = parseCommand('C:\\ffmpeg\\bin\\ffmpeg.exe -i "my file.mp4" \\\n -vf "scale=640:-2" out.mp4');
    expect(c.tool, JobTool.ffmpeg);
    expect(c.inputs, ['my file.mp4']);
    expect(c.output, 'out.mp4');
    expect(c.args, containsAllInOrder(['-nostdin', '-y', '-progress', 'pipe:1', '-nostats', '-i', 'my file.mp4']));
    expect(c.args.last, 'out.mp4');
  });

  test('without executable; -n is respected; existing options not duplicated', () {
    final c = parseCommand('-n -nostdin -i a.mkv -c copy b.mkv');
    expect(c.args.where((a) => a == '-nostdin'), hasLength(1));
    expect(c.args, isNot(contains('-y')));
  });

  test('ffprobe', () {
    final c = parseCommand('ffprobe -show_streams "x y.mp4"');
    expect(c.tool, JobTool.ffprobe);
    expect(c.inputs, ['x y.mp4']);
    expect(c.args.first, '-hide_banner');
  });

  test('errors', () {
    expect(() => parseCommand(''), throwsA(isA<CommandParseError>()));
    expect(() => parseCommand('ffmpeg -i "unterminated'), throwsA(isA<CommandParseError>()));
    expect(() => parseCommand('ffmpeg -f lavfi'), throwsA(isA<CommandParseError>()));
    expect(() => parseCommand('ffplay x.mp4'), throwsA(isA<CommandParseError>()));
  });

  test('job args back to readable text', () {
    final t = commandToText(JobTool.ffmpeg, [
      '-hide_banner',
      '-nostdin',
      '-y',
      '-progress',
      'pipe:1',
      '-nostats',
      '-i',
      'a b.mp4',
      'o.mp4',
    ]);
    expect(t, "ffmpeg -hide_banner -y -i 'a b.mp4' o.mp4");
    // Round trip through the editor parser.
    expect(parseCommand(t).inputs, ['a b.mp4']);
  });

  test('every template parses once filled', () {
    for (final t in commandTemplates) {
      final c = parseCommand(fillTemplate(t.text, input: '/x/in put.mp4', output: '/x/out.mp4'));
      expect(() => parseCommand(t.text), throwsA(isA<CommandParseError>()));
      expect(c.inputs, ['/x/in put.mp4'], reason: t.id);
    }
  });
}
