import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/engine/shell_quote.dart';

void main() {
  test('quoteArg leaves safe args alone', () {
    expect(quoteArg('-c:v'), '-c:v');
    expect(quoteArg('/a/b.mp4'), '/a/b.mp4');
    expect(quoteArg(r'C:\a\b.mp4', windows: true), r'C:\a\b.mp4');
  });

  test('quoteArg quotes special chars', () {
    expect(quoteArg('a b'), "'a b'");
    expect(quoteArg(''), "''");
    expect(quoteArg('scale=1280:-2,fps=30'), 'scale=1280:-2,fps=30');
    expect(quoteArg('[0:v]scale=2[v]'), "'[0:v]scale=2[v]'");
    expect(quoteArg('say "hi"', windows: true), r'"say \"hi\""');
  });

  test('splitCommandLine handles quotes and escapes', () {
    expect(splitCommandLine('ffmpeg -i "my file.mp4" -vf \'scale=1:2\' out.mkv'), [
      'ffmpeg',
      '-i',
      'my file.mp4',
      '-vf',
      'scale=1:2',
      'out.mkv',
    ]);
    expect(splitCommandLine(r'a\ b c'), ['a b', 'c']);
    expect(splitCommandLine(r'C:\Users\me\in.mp4 ""'), [r'C:\Users\me\in.mp4', '']);
    expect(splitCommandLine('  spaced   out  '), ['spaced', 'out']);
    expect(splitCommandLine(r'"say \"hi\""'), ['say "hi"']);
  });

  test('splitCommandLine rejects unterminated quotes', () {
    expect(() => splitCommandLine('a "b'), throwsFormatException);
  });
}
