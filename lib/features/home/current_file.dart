import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/probe/media_info.dart';
import '../../core/probe/probe_service.dart';
import '../../core/providers.dart';

class CurrentFile {
  const CurrentFile(this.path, this.info);
  final String path;
  final AsyncValue<MediaInfo> info;
}

/// The file the user dropped or opened on the Home screen.
class CurrentFileController extends Notifier<CurrentFile?> {
  int _generation = 0;

  @override
  CurrentFile? build() => null;

  Future<void> open(String path) async {
    final gen = ++_generation;
    state = CurrentFile(path, const AsyncLoading());
    final probe = ref.read(probeServiceProvider);
    if (probe == null) {
      state = CurrentFile(path, AsyncError(ProbeException('ffprobe not found', toolMissing: true), StackTrace.current));
      return;
    }
    final result = await AsyncValue.guard(() => probe.probe(path));
    if (gen != _generation || !ref.mounted) return;
    state = CurrentFile(path, result);
  }

  Future<void> pickAndOpen() async {
    final f = await openFile();
    if (f != null) await open(f.path);
  }

  Future<void> reload() async {
    final s = state;
    if (s != null) await open(s.path);
  }

  void clear() {
    _generation++;
    state = null;
  }
}

final currentFileProvider = NotifierProvider<CurrentFileController, CurrentFile?>(CurrentFileController.new);
