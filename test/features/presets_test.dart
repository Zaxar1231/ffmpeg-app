import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/db/database.dart';
import 'package:kadra/core/presets/preset_repository.dart';
import 'package:kadra/features/convert/convert_params.dart';

void main() {
  test('save, rename, export, import, delete', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = PresetRepository(db);
    final id = await repo.save(toolId: 'convert', name: 'Mine', params: const ConvertParams(quality: 20).toJson());
    await repo.rename(id, 'Renamed');
    final all = await repo.all();
    expect(all.single.name, 'Renamed');
    expect(ConvertParams.fromJson(all.single.params).quality, 20);

    final text = exportPresets(all);
    expect(await repo.importText(text), 1);
    expect((await repo.all()).length, 2);
    expect(() => parsePresetExport('{"foo": 1}'), throwsFormatException);
    expect(() => parsePresetExport('not json'), throwsFormatException);

    await repo.delete(id);
    expect((await repo.all()).length, 1);
    await db.close();
  });
}
