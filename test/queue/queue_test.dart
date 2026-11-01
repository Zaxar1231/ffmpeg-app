import 'package:flutter_test/flutter_test.dart';
import 'package:kadra/core/db/database.dart';
import 'package:kadra/core/queue/queue_models.dart';
import 'package:kadra/core/settings/app_settings.dart';

QueueItem item(String id, {int priority = 0, int minute = 0, JobStatus status = JobStatus.queued}) => QueueItem(
      job: Job(
        id: id,
        kind: 'test',
        title: id,
        tool: 'ffmpeg',
        argsJson: '["-version"]',
        status: status.name,
        priority: priority,
        attempts: 0,
        maxRetries: 0,
        createdAt: DateTime(2026, 1, 1, 0, minute),
      ),
    );

void main() {
  test('pickNext: priority first, then FIFO, only queued', () {
    expect(pickNext([item('a', minute: 2), item('b', minute: 1)])!.id, 'b');
    expect(pickNext([item('a', minute: 1), item('b', minute: 2, priority: 5)])!.id, 'b');
    expect(pickNext([item('a', status: JobStatus.running), item('b', status: JobStatus.completed)]), isNull);
    expect(pickNext(const []), isNull);
  });

  test('QueueItem decodes args and flags', () {
    final i = item('x');
    expect(i.args, ['-version']);
    expect(i.tool, JobTool.ffmpeg);
    expect(i.isFinished, isFalse);
    expect(i.extra, isEmpty);
  });

  test('settings: roundtrip and tolerant parsing', () {
    const s = AppSettings(maxParallelJobs: 3, customFfmpegPath: '/x/ffmpeg', advancedMode: true);
    final back = AppSettings.fromMap(s.toMap());
    expect(back.maxParallelJobs, 3);
    expect(back.customFfmpegPath, '/x/ffmpeg');
    expect(back.advancedMode, isTrue);

    final bad = AppSettings.fromMap({'maxParallelJobs': 999, 'themeMode': 'nope', 'retryCount': 'x', 'outputDir': ''});
    expect(bad.maxParallelJobs, 16);
    expect(bad.themeMode, const AppSettings().themeMode);
    expect(bad.retryCount, 0);
    expect(bad.outputDir, isNull);

    expect(s.copyWith(customFfmpegPath: () => null).customFfmpegPath, isNull);
    expect(s.copyWith(maxParallelJobs: 2).customFfmpegPath, '/x/ffmpeg');
  });
}
