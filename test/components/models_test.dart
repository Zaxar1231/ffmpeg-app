import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/components/models.dart';

void main() {
  test('model catalog: unique ids and file names, https, sha256', () {
    expect(modelCatalog.map((m) => m.id).toSet(), hasLength(modelCatalog.length));
    expect(modelCatalog.map((m) => m.fileName).toSet(), hasLength(modelCatalog.length));
    for (final m in modelCatalog) {
      expect(m.url, startsWith('https://'));
      expect(m.sha256, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(m.size, greaterThan(100000));
    }
    expect(modelCatalog.where((m) => m.kind == ModelKind.rnnoise), hasLength(5));
  });
}
