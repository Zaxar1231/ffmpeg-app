// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolMeta = const VerificationMeta('tool');
  @override
  late final GeneratedColumn<String> tool = GeneratedColumn<String>(
    'tool',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _argsJsonMeta = const VerificationMeta('argsJson');
  @override
  late final GeneratedColumn<String> argsJson = GeneratedColumn<String>(
    'args_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputPathMeta = const VerificationMeta('inputPath');
  @override
  late final GeneratedColumn<String> inputPath = GeneratedColumn<String>(
    'input_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputPathMeta = const VerificationMeta('outputPath');
  @override
  late final GeneratedColumn<String> outputPath = GeneratedColumn<String>(
    'output_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationUsMeta = const VerificationMeta('durationUs');
  @override
  late final GeneratedColumn<int> durationUs = GeneratedColumn<int>(
    'duration_us',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxRetriesMeta = const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
    'max_retries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorKindMeta = const VerificationMeta('errorKind');
  @override
  late final GeneratedColumn<String> errorKind = GeneratedColumn<String>(
    'error_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorDetailMeta = const VerificationMeta('errorDetail');
  @override
  late final GeneratedColumn<String> errorDetail = GeneratedColumn<String>(
    'error_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logMeta = const VerificationMeta('log');
  @override
  late final GeneratedColumn<String> log = GeneratedColumn<String>(
    'log',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputSizeMeta = const VerificationMeta('outputSize');
  @override
  late final GeneratedColumn<int> outputSize = GeneratedColumn<int>(
    'output_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraJsonMeta = const VerificationMeta('extraJson');
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    tool,
    argsJson,
    inputPath,
    outputPath,
    durationUs,
    status,
    priority,
    attempts,
    maxRetries,
    createdAt,
    startedAt,
    finishedAt,
    errorKind,
    errorDetail,
    log,
    outputSize,
    extraJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(Insertable<Job> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('tool')) {
      context.handle(_toolMeta, tool.isAcceptableOrUnknown(data['tool']!, _toolMeta));
    } else if (isInserting) {
      context.missing(_toolMeta);
    }
    if (data.containsKey('args_json')) {
      context.handle(_argsJsonMeta, argsJson.isAcceptableOrUnknown(data['args_json']!, _argsJsonMeta));
    } else if (isInserting) {
      context.missing(_argsJsonMeta);
    }
    if (data.containsKey('input_path')) {
      context.handle(_inputPathMeta, inputPath.isAcceptableOrUnknown(data['input_path']!, _inputPathMeta));
    }
    if (data.containsKey('output_path')) {
      context.handle(_outputPathMeta, outputPath.isAcceptableOrUnknown(data['output_path']!, _outputPathMeta));
    }
    if (data.containsKey('duration_us')) {
      context.handle(_durationUsMeta, durationUs.isAcceptableOrUnknown(data['duration_us']!, _durationUsMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta, priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta, attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(_maxRetriesMeta, maxRetries.isAcceptableOrUnknown(data['max_retries']!, _maxRetriesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta, startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(_finishedAtMeta, finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('error_kind')) {
      context.handle(_errorKindMeta, errorKind.isAcceptableOrUnknown(data['error_kind']!, _errorKindMeta));
    }
    if (data.containsKey('error_detail')) {
      context.handle(_errorDetailMeta, errorDetail.isAcceptableOrUnknown(data['error_detail']!, _errorDetailMeta));
    }
    if (data.containsKey('log')) {
      context.handle(_logMeta, log.isAcceptableOrUnknown(data['log']!, _logMeta));
    }
    if (data.containsKey('output_size')) {
      context.handle(_outputSizeMeta, outputSize.isAcceptableOrUnknown(data['output_size']!, _outputSizeMeta));
    }
    if (data.containsKey('extra_json')) {
      context.handle(_extraJsonMeta, extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      tool: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}tool'])!,
      argsJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}args_json'])!,
      inputPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}input_path']),
      outputPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}output_path']),
      durationUs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration_us']),
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      attempts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      maxRetries: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      startedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      finishedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      errorKind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}error_kind']),
      errorDetail: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}error_detail']),
      log: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}log']),
      outputSize: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}output_size']),
      extraJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}extra_json']),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class Job extends DataClass implements Insertable<Job> {
  final String id;

  /// Feature that created the job, e.g. `integrity`, `convert`.
  final String kind;
  final String title;

  /// `ffmpeg`, `ffprobe`, `yt-dlp`.
  final String tool;

  /// JSON list of arguments (executable resolved at run time).
  final String argsJson;
  final String? inputPath;
  final String? outputPath;
  final int? durationUs;

  /// queued | running | paused | completed | failed | canceled
  final String status;
  final int priority;
  final int attempts;
  final int maxRetries;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? errorKind;
  final String? errorDetail;
  final String? log;
  final int? outputSize;

  /// Free-form JSON for feature-specific data (e.g. parsed analysis result).
  final String? extraJson;
  const Job({
    required this.id,
    required this.kind,
    required this.title,
    required this.tool,
    required this.argsJson,
    this.inputPath,
    this.outputPath,
    this.durationUs,
    required this.status,
    required this.priority,
    required this.attempts,
    required this.maxRetries,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.errorKind,
    this.errorDetail,
    this.log,
    this.outputSize,
    this.extraJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['tool'] = Variable<String>(tool);
    map['args_json'] = Variable<String>(argsJson);
    if (!nullToAbsent || inputPath != null) {
      map['input_path'] = Variable<String>(inputPath);
    }
    if (!nullToAbsent || outputPath != null) {
      map['output_path'] = Variable<String>(outputPath);
    }
    if (!nullToAbsent || durationUs != null) {
      map['duration_us'] = Variable<int>(durationUs);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<int>(priority);
    map['attempts'] = Variable<int>(attempts);
    map['max_retries'] = Variable<int>(maxRetries);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || errorKind != null) {
      map['error_kind'] = Variable<String>(errorKind);
    }
    if (!nullToAbsent || errorDetail != null) {
      map['error_detail'] = Variable<String>(errorDetail);
    }
    if (!nullToAbsent || log != null) {
      map['log'] = Variable<String>(log);
    }
    if (!nullToAbsent || outputSize != null) {
      map['output_size'] = Variable<int>(outputSize);
    }
    if (!nullToAbsent || extraJson != null) {
      map['extra_json'] = Variable<String>(extraJson);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      tool: Value(tool),
      argsJson: Value(argsJson),
      inputPath: inputPath == null && nullToAbsent ? const Value.absent() : Value(inputPath),
      outputPath: outputPath == null && nullToAbsent ? const Value.absent() : Value(outputPath),
      durationUs: durationUs == null && nullToAbsent ? const Value.absent() : Value(durationUs),
      status: Value(status),
      priority: Value(priority),
      attempts: Value(attempts),
      maxRetries: Value(maxRetries),
      createdAt: Value(createdAt),
      startedAt: startedAt == null && nullToAbsent ? const Value.absent() : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent ? const Value.absent() : Value(finishedAt),
      errorKind: errorKind == null && nullToAbsent ? const Value.absent() : Value(errorKind),
      errorDetail: errorDetail == null && nullToAbsent ? const Value.absent() : Value(errorDetail),
      log: log == null && nullToAbsent ? const Value.absent() : Value(log),
      outputSize: outputSize == null && nullToAbsent ? const Value.absent() : Value(outputSize),
      extraJson: extraJson == null && nullToAbsent ? const Value.absent() : Value(extraJson),
    );
  }

  factory Job.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      tool: serializer.fromJson<String>(json['tool']),
      argsJson: serializer.fromJson<String>(json['argsJson']),
      inputPath: serializer.fromJson<String?>(json['inputPath']),
      outputPath: serializer.fromJson<String?>(json['outputPath']),
      durationUs: serializer.fromJson<int?>(json['durationUs']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      attempts: serializer.fromJson<int>(json['attempts']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      errorKind: serializer.fromJson<String?>(json['errorKind']),
      errorDetail: serializer.fromJson<String?>(json['errorDetail']),
      log: serializer.fromJson<String?>(json['log']),
      outputSize: serializer.fromJson<int?>(json['outputSize']),
      extraJson: serializer.fromJson<String?>(json['extraJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'tool': serializer.toJson<String>(tool),
      'argsJson': serializer.toJson<String>(argsJson),
      'inputPath': serializer.toJson<String?>(inputPath),
      'outputPath': serializer.toJson<String?>(outputPath),
      'durationUs': serializer.toJson<int?>(durationUs),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<int>(priority),
      'attempts': serializer.toJson<int>(attempts),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'errorKind': serializer.toJson<String?>(errorKind),
      'errorDetail': serializer.toJson<String?>(errorDetail),
      'log': serializer.toJson<String?>(log),
      'outputSize': serializer.toJson<int?>(outputSize),
      'extraJson': serializer.toJson<String?>(extraJson),
    };
  }

  Job copyWith({
    String? id,
    String? kind,
    String? title,
    String? tool,
    String? argsJson,
    Value<String?> inputPath = const Value.absent(),
    Value<String?> outputPath = const Value.absent(),
    Value<int?> durationUs = const Value.absent(),
    String? status,
    int? priority,
    int? attempts,
    int? maxRetries,
    DateTime? createdAt,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<String?> errorKind = const Value.absent(),
    Value<String?> errorDetail = const Value.absent(),
    Value<String?> log = const Value.absent(),
    Value<int?> outputSize = const Value.absent(),
    Value<String?> extraJson = const Value.absent(),
  }) => Job(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    tool: tool ?? this.tool,
    argsJson: argsJson ?? this.argsJson,
    inputPath: inputPath.present ? inputPath.value : this.inputPath,
    outputPath: outputPath.present ? outputPath.value : this.outputPath,
    durationUs: durationUs.present ? durationUs.value : this.durationUs,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    attempts: attempts ?? this.attempts,
    maxRetries: maxRetries ?? this.maxRetries,
    createdAt: createdAt ?? this.createdAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    errorKind: errorKind.present ? errorKind.value : this.errorKind,
    errorDetail: errorDetail.present ? errorDetail.value : this.errorDetail,
    log: log.present ? log.value : this.log,
    outputSize: outputSize.present ? outputSize.value : this.outputSize,
    extraJson: extraJson.present ? extraJson.value : this.extraJson,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      tool: data.tool.present ? data.tool.value : this.tool,
      argsJson: data.argsJson.present ? data.argsJson.value : this.argsJson,
      inputPath: data.inputPath.present ? data.inputPath.value : this.inputPath,
      outputPath: data.outputPath.present ? data.outputPath.value : this.outputPath,
      durationUs: data.durationUs.present ? data.durationUs.value : this.durationUs,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      maxRetries: data.maxRetries.present ? data.maxRetries.value : this.maxRetries,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      errorKind: data.errorKind.present ? data.errorKind.value : this.errorKind,
      errorDetail: data.errorDetail.present ? data.errorDetail.value : this.errorDetail,
      log: data.log.present ? data.log.value : this.log,
      outputSize: data.outputSize.present ? data.outputSize.value : this.outputSize,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('tool: $tool, ')
          ..write('argsJson: $argsJson, ')
          ..write('inputPath: $inputPath, ')
          ..write('outputPath: $outputPath, ')
          ..write('durationUs: $durationUs, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('errorKind: $errorKind, ')
          ..write('errorDetail: $errorDetail, ')
          ..write('log: $log, ')
          ..write('outputSize: $outputSize, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    tool,
    argsJson,
    inputPath,
    outputPath,
    durationUs,
    status,
    priority,
    attempts,
    maxRetries,
    createdAt,
    startedAt,
    finishedAt,
    errorKind,
    errorDetail,
    log,
    outputSize,
    extraJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.tool == this.tool &&
          other.argsJson == this.argsJson &&
          other.inputPath == this.inputPath &&
          other.outputPath == this.outputPath &&
          other.durationUs == this.durationUs &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.attempts == this.attempts &&
          other.maxRetries == this.maxRetries &&
          other.createdAt == this.createdAt &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.errorKind == this.errorKind &&
          other.errorDetail == this.errorDetail &&
          other.log == this.log &&
          other.outputSize == this.outputSize &&
          other.extraJson == this.extraJson);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> tool;
  final Value<String> argsJson;
  final Value<String?> inputPath;
  final Value<String?> outputPath;
  final Value<int?> durationUs;
  final Value<String> status;
  final Value<int> priority;
  final Value<int> attempts;
  final Value<int> maxRetries;
  final Value<DateTime> createdAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String?> errorKind;
  final Value<String?> errorDetail;
  final Value<String?> log;
  final Value<int?> outputSize;
  final Value<String?> extraJson;
  final Value<int> rowid;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.tool = const Value.absent(),
    this.argsJson = const Value.absent(),
    this.inputPath = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.durationUs = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.attempts = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.errorKind = const Value.absent(),
    this.errorDetail = const Value.absent(),
    this.log = const Value.absent(),
    this.outputSize = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsCompanion.insert({
    required String id,
    required String kind,
    required String title,
    required String tool,
    required String argsJson,
    this.inputPath = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.durationUs = const Value.absent(),
    required String status,
    this.priority = const Value.absent(),
    this.attempts = const Value.absent(),
    this.maxRetries = const Value.absent(),
    required DateTime createdAt,
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.errorKind = const Value.absent(),
    this.errorDetail = const Value.absent(),
    this.log = const Value.absent(),
    this.outputSize = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       title = Value(title),
       tool = Value(tool),
       argsJson = Value(argsJson),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<Job> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? tool,
    Expression<String>? argsJson,
    Expression<String>? inputPath,
    Expression<String>? outputPath,
    Expression<int>? durationUs,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<int>? attempts,
    Expression<int>? maxRetries,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? errorKind,
    Expression<String>? errorDetail,
    Expression<String>? log,
    Expression<int>? outputSize,
    Expression<String>? extraJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (tool != null) 'tool': tool,
      if (argsJson != null) 'args_json': argsJson,
      if (inputPath != null) 'input_path': inputPath,
      if (outputPath != null) 'output_path': outputPath,
      if (durationUs != null) 'duration_us': durationUs,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (attempts != null) 'attempts': attempts,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (createdAt != null) 'created_at': createdAt,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (errorKind != null) 'error_kind': errorKind,
      if (errorDetail != null) 'error_detail': errorDetail,
      if (log != null) 'log': log,
      if (outputSize != null) 'output_size': outputSize,
      if (extraJson != null) 'extra_json': extraJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? tool,
    Value<String>? argsJson,
    Value<String?>? inputPath,
    Value<String?>? outputPath,
    Value<int?>? durationUs,
    Value<String>? status,
    Value<int>? priority,
    Value<int>? attempts,
    Value<int>? maxRetries,
    Value<DateTime>? createdAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<String?>? errorKind,
    Value<String?>? errorDetail,
    Value<String?>? log,
    Value<int?>? outputSize,
    Value<String?>? extraJson,
    Value<int>? rowid,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      tool: tool ?? this.tool,
      argsJson: argsJson ?? this.argsJson,
      inputPath: inputPath ?? this.inputPath,
      outputPath: outputPath ?? this.outputPath,
      durationUs: durationUs ?? this.durationUs,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attempts: attempts ?? this.attempts,
      maxRetries: maxRetries ?? this.maxRetries,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      errorKind: errorKind ?? this.errorKind,
      errorDetail: errorDetail ?? this.errorDetail,
      log: log ?? this.log,
      outputSize: outputSize ?? this.outputSize,
      extraJson: extraJson ?? this.extraJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (tool.present) {
      map['tool'] = Variable<String>(tool.value);
    }
    if (argsJson.present) {
      map['args_json'] = Variable<String>(argsJson.value);
    }
    if (inputPath.present) {
      map['input_path'] = Variable<String>(inputPath.value);
    }
    if (outputPath.present) {
      map['output_path'] = Variable<String>(outputPath.value);
    }
    if (durationUs.present) {
      map['duration_us'] = Variable<int>(durationUs.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (errorKind.present) {
      map['error_kind'] = Variable<String>(errorKind.value);
    }
    if (errorDetail.present) {
      map['error_detail'] = Variable<String>(errorDetail.value);
    }
    if (log.present) {
      map['log'] = Variable<String>(log.value);
    }
    if (outputSize.present) {
      map['output_size'] = Variable<int>(outputSize.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('tool: $tool, ')
          ..write('argsJson: $argsJson, ')
          ..write('inputPath: $inputPath, ')
          ..write('outputPath: $outputPath, ')
          ..write('durationUs: $durationUs, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('errorKind: $errorKind, ')
          ..write('errorDetail: $errorDetail, ')
          ..write('log: $log, ')
          ..write('outputSize: $outputSize, ')
          ..write('extraJson: $extraJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PresetsTable extends Presets with TableInfo<$PresetsTable, Preset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolIdMeta = const VerificationMeta('toolId');
  @override
  late final GeneratedColumn<String> toolId = GeneratedColumn<String>(
    'tool_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta('paramsJson');
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta('builtIn');
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("built_in" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, toolId, name, paramsJson, builtIn, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presets';
  @override
  VerificationContext validateIntegrity(Insertable<Preset> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tool_id')) {
      context.handle(_toolIdMeta, toolId.isAcceptableOrUnknown(data['tool_id']!, _toolIdMeta));
    } else if (isInserting) {
      context.missing(_toolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('params_json')) {
      context.handle(_paramsJsonMeta, paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta));
    } else if (isInserting) {
      context.missing(_paramsJsonMeta);
    }
    if (data.containsKey('built_in')) {
      context.handle(_builtInMeta, builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Preset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preset(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      toolId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}tool_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      paramsJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}params_json'])!,
      builtIn: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}built_in'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PresetsTable createAlias(String alias) {
    return $PresetsTable(attachedDatabase, alias);
  }
}

class Preset extends DataClass implements Insertable<Preset> {
  final String id;
  final String toolId;
  final String name;
  final String paramsJson;
  final bool builtIn;
  final DateTime createdAt;
  const Preset({
    required this.id,
    required this.toolId,
    required this.name,
    required this.paramsJson,
    required this.builtIn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tool_id'] = Variable<String>(toolId);
    map['name'] = Variable<String>(name);
    map['params_json'] = Variable<String>(paramsJson);
    map['built_in'] = Variable<bool>(builtIn);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PresetsCompanion toCompanion(bool nullToAbsent) {
    return PresetsCompanion(
      id: Value(id),
      toolId: Value(toolId),
      name: Value(name),
      paramsJson: Value(paramsJson),
      builtIn: Value(builtIn),
      createdAt: Value(createdAt),
    );
  }

  factory Preset.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preset(
      id: serializer.fromJson<String>(json['id']),
      toolId: serializer.fromJson<String>(json['toolId']),
      name: serializer.fromJson<String>(json['name']),
      paramsJson: serializer.fromJson<String>(json['paramsJson']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'toolId': serializer.toJson<String>(toolId),
      'name': serializer.toJson<String>(name),
      'paramsJson': serializer.toJson<String>(paramsJson),
      'builtIn': serializer.toJson<bool>(builtIn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Preset copyWith({String? id, String? toolId, String? name, String? paramsJson, bool? builtIn, DateTime? createdAt}) =>
      Preset(
        id: id ?? this.id,
        toolId: toolId ?? this.toolId,
        name: name ?? this.name,
        paramsJson: paramsJson ?? this.paramsJson,
        builtIn: builtIn ?? this.builtIn,
        createdAt: createdAt ?? this.createdAt,
      );
  Preset copyWithCompanion(PresetsCompanion data) {
    return Preset(
      id: data.id.present ? data.id.value : this.id,
      toolId: data.toolId.present ? data.toolId.value : this.toolId,
      name: data.name.present ? data.name.value : this.name,
      paramsJson: data.paramsJson.present ? data.paramsJson.value : this.paramsJson,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preset(')
          ..write('id: $id, ')
          ..write('toolId: $toolId, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('builtIn: $builtIn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, toolId, name, paramsJson, builtIn, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preset &&
          other.id == this.id &&
          other.toolId == this.toolId &&
          other.name == this.name &&
          other.paramsJson == this.paramsJson &&
          other.builtIn == this.builtIn &&
          other.createdAt == this.createdAt);
}

class PresetsCompanion extends UpdateCompanion<Preset> {
  final Value<String> id;
  final Value<String> toolId;
  final Value<String> name;
  final Value<String> paramsJson;
  final Value<bool> builtIn;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PresetsCompanion({
    this.id = const Value.absent(),
    this.toolId = const Value.absent(),
    this.name = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PresetsCompanion.insert({
    required String id,
    required String toolId,
    required String name,
    required String paramsJson,
    this.builtIn = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       toolId = Value(toolId),
       name = Value(name),
       paramsJson = Value(paramsJson),
       createdAt = Value(createdAt);
  static Insertable<Preset> custom({
    Expression<String>? id,
    Expression<String>? toolId,
    Expression<String>? name,
    Expression<String>? paramsJson,
    Expression<bool>? builtIn,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (toolId != null) 'tool_id': toolId,
      if (name != null) 'name': name,
      if (paramsJson != null) 'params_json': paramsJson,
      if (builtIn != null) 'built_in': builtIn,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? toolId,
    Value<String>? name,
    Value<String>? paramsJson,
    Value<bool>? builtIn,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PresetsCompanion(
      id: id ?? this.id,
      toolId: toolId ?? this.toolId,
      name: name ?? this.name,
      paramsJson: paramsJson ?? this.paramsJson,
      builtIn: builtIn ?? this.builtIn,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (toolId.present) {
      map['tool_id'] = Variable<String>(toolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetsCompanion(')
          ..write('id: $id, ')
          ..write('toolId: $toolId, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('builtIn: $builtIn, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $PresetsTable presets = $PresetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [jobs, presets];
}

typedef $$JobsTableCreateCompanionBuilder = JobsCompanion Function({
  required String id,
  required String kind,
  required String title,
  required String tool,
  required String argsJson,
  Value<String?> inputPath,
  Value<String?> outputPath,
  Value<int?> durationUs,
  required String status,
  Value<int> priority,
  Value<int> attempts,
  Value<int> maxRetries,
  required DateTime createdAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> errorKind,
  Value<String?> errorDetail,
  Value<String?> log,
  Value<int?> outputSize,
  Value<String?> extraJson,
  Value<int> rowid,
});
typedef $$JobsTableUpdateCompanionBuilder = JobsCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> title,
  Value<String> tool,
  Value<String> argsJson,
  Value<String?> inputPath,
  Value<String?> outputPath,
  Value<int?> durationUs,
  Value<String> status,
  Value<int> priority,
  Value<int> attempts,
  Value<int> maxRetries,
  Value<DateTime> createdAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> errorKind,
  Value<String?> errorDetail,
  Value<String?> log,
  Value<int?> outputSize,
  Value<String?> extraJson,
  Value<int> rowid,
});

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tool => $composableBuilder(column: $table.tool, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get argsJson =>
      $composableBuilder(column: $table.argsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputPath =>
      $composableBuilder(column: $table.inputPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outputPath =>
      $composableBuilder(column: $table.outputPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationUs =>
      $composableBuilder(column: $table.durationUs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRetries =>
      $composableBuilder(column: $table.maxRetries, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt =>
      $composableBuilder(column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorKind =>
      $composableBuilder(column: $table.errorKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorDetail =>
      $composableBuilder(column: $table.errorDetail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get log => $composableBuilder(column: $table.log, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get outputSize =>
      $composableBuilder(column: $table.outputSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => ColumnFilters(column));
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tool =>
      $composableBuilder(column: $table.tool, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get argsJson =>
      $composableBuilder(column: $table.argsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputPath =>
      $composableBuilder(column: $table.inputPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outputPath =>
      $composableBuilder(column: $table.outputPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationUs =>
      $composableBuilder(column: $table.durationUs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRetries =>
      $composableBuilder(column: $table.maxRetries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt =>
      $composableBuilder(column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorKind =>
      $composableBuilder(column: $table.errorKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorDetail =>
      $composableBuilder(column: $table.errorDetail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get log =>
      $composableBuilder(column: $table.log, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get outputSize =>
      $composableBuilder(column: $table.outputSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => ColumnOrderings(column));
}

class $$JobsTableAnnotationComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get tool => $composableBuilder(column: $table.tool, builder: (column) => column);

  GeneratedColumn<String> get argsJson => $composableBuilder(column: $table.argsJson, builder: (column) => column);

  GeneratedColumn<String> get inputPath => $composableBuilder(column: $table.inputPath, builder: (column) => column);

  GeneratedColumn<String> get outputPath => $composableBuilder(column: $table.outputPath, builder: (column) => column);

  GeneratedColumn<int> get durationUs => $composableBuilder(column: $table.durationUs, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get maxRetries => $composableBuilder(column: $table.maxRetries, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt => $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt =>
      $composableBuilder(column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<String> get errorKind => $composableBuilder(column: $table.errorKind, builder: (column) => column);

  GeneratedColumn<String> get errorDetail =>
      $composableBuilder(column: $table.errorDetail, builder: (column) => column);

  GeneratedColumn<String> get log => $composableBuilder(column: $table.log, builder: (column) => column);

  GeneratedColumn<int> get outputSize => $composableBuilder(column: $table.outputSize, builder: (column) => column);

  GeneratedColumn<String> get extraJson => $composableBuilder(column: $table.extraJson, builder: (column) => column);
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          Job,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (Job, BaseReferences<_$AppDatabase, $JobsTable, Job>),
          Job,
          PrefetchHooks Function()
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> tool = const Value.absent(),
                Value<String> argsJson = const Value.absent(),
                Value<String?> inputPath = const Value.absent(),
                Value<String?> outputPath = const Value.absent(),
                Value<int?> durationUs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> maxRetries = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> errorKind = const Value.absent(),
                Value<String?> errorDetail = const Value.absent(),
                Value<String?> log = const Value.absent(),
                Value<int?> outputSize = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                kind: kind,
                title: title,
                tool: tool,
                argsJson: argsJson,
                inputPath: inputPath,
                outputPath: outputPath,
                durationUs: durationUs,
                status: status,
                priority: priority,
                attempts: attempts,
                maxRetries: maxRetries,
                createdAt: createdAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
                errorKind: errorKind,
                errorDetail: errorDetail,
                log: log,
                outputSize: outputSize,
                extraJson: extraJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String title,
                required String tool,
                required String argsJson,
                Value<String?> inputPath = const Value.absent(),
                Value<String?> outputPath = const Value.absent(),
                Value<int?> durationUs = const Value.absent(),
                required String status,
                Value<int> priority = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> maxRetries = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> errorKind = const Value.absent(),
                Value<String?> errorDetail = const Value.absent(),
                Value<String?> log = const Value.absent(),
                Value<int?> outputSize = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                tool: tool,
                argsJson: argsJson,
                inputPath: inputPath,
                outputPath: outputPath,
                durationUs: durationUs,
                status: status,
                priority: priority,
                attempts: attempts,
                maxRetries: maxRetries,
                createdAt: createdAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
                errorKind: errorKind,
                errorDetail: errorDetail,
                log: log,
                outputSize: outputSize,
                extraJson: extraJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable<$JobsTable, Job>(table), BaseReferences<_$AppDatabase, $JobsTable, Job>(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      Job,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (Job, BaseReferences<_$AppDatabase, $JobsTable, Job>),
      Job,
      PrefetchHooks Function()
    >;
typedef $$PresetsTableCreateCompanionBuilder = PresetsCompanion Function({
  required String id,
  required String toolId,
  required String name,
  required String paramsJson,
  Value<bool> builtIn,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PresetsTableUpdateCompanionBuilder = PresetsCompanion Function({
  Value<String> id,
  Value<String> toolId,
  Value<String> name,
  Value<String> paramsJson,
  Value<bool> builtIn,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PresetsTableFilterComposer extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolId =>
      $composableBuilder(column: $table.toolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paramsJson =>
      $composableBuilder(column: $table.paramsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PresetsTableOrderingComposer extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolId =>
      $composableBuilder(column: $table.toolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paramsJson =>
      $composableBuilder(column: $table.paramsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PresetsTableAnnotationComposer extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get toolId => $composableBuilder(column: $table.toolId, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get paramsJson => $composableBuilder(column: $table.paramsJson, builder: (column) => column);

  GeneratedColumn<bool> get builtIn => $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PresetsTable,
          Preset,
          $$PresetsTableFilterComposer,
          $$PresetsTableOrderingComposer,
          $$PresetsTableAnnotationComposer,
          $$PresetsTableCreateCompanionBuilder,
          $$PresetsTableUpdateCompanionBuilder,
          (Preset, BaseReferences<_$AppDatabase, $PresetsTable, Preset>),
          Preset,
          PrefetchHooks Function()
        > {
  $$PresetsTableTableManager(_$AppDatabase db, $PresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> toolId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> paramsJson = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PresetsCompanion(
                id: id,
                toolId: toolId,
                name: name,
                paramsJson: paramsJson,
                builtIn: builtIn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String toolId,
                required String name,
                required String paramsJson,
                Value<bool> builtIn = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PresetsCompanion.insert(
                id: id,
                toolId: toolId,
                name: name,
                paramsJson: paramsJson,
                builtIn: builtIn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PresetsTable, Preset>(table),
                  BaseReferences<_$AppDatabase, $PresetsTable, Preset>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PresetsTable,
      Preset,
      $$PresetsTableFilterComposer,
      $$PresetsTableOrderingComposer,
      $$PresetsTableAnnotationComposer,
      $$PresetsTableCreateCompanionBuilder,
      $$PresetsTableUpdateCompanionBuilder,
      (Preset, BaseReferences<_$AppDatabase, $PresetsTable, Preset>),
      Preset,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$PresetsTableTableManager get presets => $$PresetsTableTableManager(_db, _db.presets);
}
