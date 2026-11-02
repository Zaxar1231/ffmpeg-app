import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Locations of everything the app writes. Created on demand.
class AppPaths {
  AppPaths(this.root);

  /// Per-user app data. Windows: `%APPDATA%\Kadra\Kadra` (from the exe version
  /// resources CompanyName/ProductName); Linux: `~/.local/share/dev.kadra.kadra`.
  final String root;

  String get components => p.join(root, 'components');
  String get downloadsTemp => p.join(root, 'tmp', 'downloads');
  String get logs => p.join(root, 'logs');
  String get database => p.join(root, 'kadra.sqlite');
  String get componentState => p.join(components, 'state.json');
  String get hwCache => p.join(root, 'hwaccel.json');
  String get recipes => p.join(root, 'recipes.json');
  String get watchers => p.join(root, 'watchers.json');

  static Future<AppPaths> resolve() async {
    final dir = await getApplicationSupportDirectory();
    final paths = AppPaths(dir.path);
    for (final d in [paths.components, paths.downloadsTemp, paths.logs]) {
      await Directory(d).create(recursive: true);
    }
    return paths;
  }

  /// Default folder for results: the user's Videos (or home) + /Kadra.
  static String defaultOutputDir() {
    final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? Directory.systemTemp.path;
    final videos = p.join(home, 'Videos');
    return p.join(Directory(videos).existsSync() ? videos : home, 'Kadra');
  }
}
