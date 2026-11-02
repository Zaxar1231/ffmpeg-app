import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/features/automation/recipe.dart';

void main() {
  test('recipes export and import', () {
    const r = Recipe(
      id: 'a1',
      name: 'Для Reels',
      steps: [
        RecipeStep(RecipeOp.vertical, {'mode': 'blur'}),
        RecipeStep(RecipeOp.normalize, {}),
      ],
    );
    final text = exportRecipes([r]);
    expect(jsonDecode(text)['kadra'], 'recipes');
    final back = parseRecipes(text);
    expect(back.single.name, 'Для Reels');
    expect(back.single.steps.map((s) => s.op), [RecipeOp.vertical, RecipeOp.normalize]);
    expect(back.single.steps.first.params['mode'], 'blur');

    // A step from a newer version is dropped, the rest is kept.
    final newer = jsonEncode({
      'recipes': [
        {
          'id': 'x',
          'name': 'Future',
          'steps': [
            {'op': 'teleport', 'params': {}},
            {'op': 'faststart', 'params': {}},
          ],
        },
      ],
    });
    expect(parseRecipes(newer).single.steps.single.op, RecipeOp.faststart);

    for (final bad in ['not json', '{"presets": []}', '{"recipes": []}', '[1, 2]']) {
      expect(() => parseRecipes(bad), throwsFormatException, reason: bad);
    }
  });
}
