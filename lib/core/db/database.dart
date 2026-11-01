import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Queue entries and history (finished jobs stay as history).
class Jobs extends Table {
  TextColumn get id => text()();

  /// Feature that created the job, e.g. `integrity`, `convert`.
  TextColumn get kind => text()();
  TextColumn get title => text()();

  /// `ffmpeg`, `ffprobe`, `yt-dlp`.
  TextColumn get tool => text()();

  /// JSON list of arguments (executable resolved at run time).
  TextColumn get argsJson => text()();
  TextColumn get inputPath => text().nullable()();
  TextColumn get outputPath => text().nullable()();
  IntColumn get durationUs => integer().nullable()();

  /// queued | running | paused | completed | failed | canceled
  TextColumn get status => text()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get errorKind => text().nullable()();
  TextColumn get errorDetail => text().nullable()();
  TextColumn get log => text().nullable()();
  IntColumn get outputSize => integer().nullable()();

  /// Free-form JSON for feature-specific data (e.g. parsed analysis result).
  TextColumn get extraJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Presets extends Table {
  TextColumn get id => text()();
  TextColumn get toolId => text()();
  TextColumn get name => text()();
  TextColumn get paramsJson => text()();
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Jobs, Presets])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open(String path) => AppDatabase(
    driftDatabase(
      name: 'kadra',
      native: DriftNativeOptions(databasePath: () async => path),
    ),
  );

  @override
  int get schemaVersion => 1;

  Future<List<Job>> allJobs() => (select(jobs)..orderBy([(j) => OrderingTerm.asc(j.createdAt)])).get();

  Future<void> upsertJob(JobsCompanion j) => into(jobs).insertOnConflictUpdate(j);

  Future<void> deleteJob(String id) => (delete(jobs)..where((j) => j.id.equals(id))).go();

  Future<int> deleteFinished() => (delete(jobs)..where((j) => j.status.isIn(['completed', 'failed', 'canceled']))).go();

  /// After a crash or restart nothing is running: requeue interrupted jobs.
  Future<int> recoverInterrupted() => (update(
    jobs,
  )..where((j) => j.status.isIn(['running', 'paused']))).write(const JobsCompanion(status: Value('queued')));
}
