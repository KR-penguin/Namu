// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MessageRecordsTable extends MessageRecords
    with TableInfo<$MessageRecordsTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayYearMeta = const VerificationMeta(
    'dayYear',
  );
  @override
  late final GeneratedColumn<int> dayYear = GeneratedColumn<int>(
    'day_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMonthMeta = const VerificationMeta(
    'dayMonth',
  );
  @override
  late final GeneratedColumn<int> dayMonth = GeneratedColumn<int>(
    'day_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayDayMeta = const VerificationMeta('dayDay');
  @override
  late final GeneratedColumn<int> dayDay = GeneratedColumn<int>(
    'day_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayTimeZoneIdMeta = const VerificationMeta(
    'dayTimeZoneId',
  );
  @override
  late final GeneratedColumn<String> dayTimeZoneId = GeneratedColumn<String>(
    'day_time_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayCutoffMicrosMeta = const VerificationMeta(
    'dayCutoffMicros',
  );
  @override
  late final GeneratedColumn<int> dayCutoffMicros = GeneratedColumn<int>(
    'day_cutoff_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayPolicyVersionMeta = const VerificationMeta(
    'dayPolicyVersion',
  );
  @override
  late final GeneratedColumn<int> dayPolicyVersion = GeneratedColumn<int>(
    'day_policy_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTextMeta = const VerificationMeta(
    'messageText',
  );
  @override
  late final GeneratedColumn<String> messageText = GeneratedColumn<String>(
    'message_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoAssetIdMeta = const VerificationMeta(
    'photoAssetId',
  );
  @override
  late final GeneratedColumn<String> photoAssetId = GeneratedColumn<String>(
    'photo_asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestId,
    dayYear,
    dayMonth,
    dayDay,
    dayTimeZoneId,
    dayCutoffMicros,
    dayPolicyVersion,
    role,
    messageText,
    photoAssetId,
    createdAtUtc,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('day_year')) {
      context.handle(
        _dayYearMeta,
        dayYear.isAcceptableOrUnknown(data['day_year']!, _dayYearMeta),
      );
    } else if (isInserting) {
      context.missing(_dayYearMeta);
    }
    if (data.containsKey('day_month')) {
      context.handle(
        _dayMonthMeta,
        dayMonth.isAcceptableOrUnknown(data['day_month']!, _dayMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMonthMeta);
    }
    if (data.containsKey('day_day')) {
      context.handle(
        _dayDayMeta,
        dayDay.isAcceptableOrUnknown(data['day_day']!, _dayDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayDayMeta);
    }
    if (data.containsKey('day_time_zone_id')) {
      context.handle(
        _dayTimeZoneIdMeta,
        dayTimeZoneId.isAcceptableOrUnknown(
          data['day_time_zone_id']!,
          _dayTimeZoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayTimeZoneIdMeta);
    }
    if (data.containsKey('day_cutoff_micros')) {
      context.handle(
        _dayCutoffMicrosMeta,
        dayCutoffMicros.isAcceptableOrUnknown(
          data['day_cutoff_micros']!,
          _dayCutoffMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayCutoffMicrosMeta);
    }
    if (data.containsKey('day_policy_version')) {
      context.handle(
        _dayPolicyVersionMeta,
        dayPolicyVersion.isAcceptableOrUnknown(
          data['day_policy_version']!,
          _dayPolicyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayPolicyVersionMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('message_text')) {
      context.handle(
        _messageTextMeta,
        messageText.isAcceptableOrUnknown(
          data['message_text']!,
          _messageTextMeta,
        ),
      );
    }
    if (data.containsKey('photo_asset_id')) {
      context.handle(
        _photoAssetIdMeta,
        photoAssetId.isAcceptableOrUnknown(
          data['photo_asset_id']!,
          _photoAssetIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {requestId, role},
  ];
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      dayYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_year'],
      )!,
      dayMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_month'],
      )!,
      dayDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_day'],
      )!,
      dayTimeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_time_zone_id'],
      )!,
      dayCutoffMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_cutoff_micros'],
      )!,
      dayPolicyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_policy_version'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      messageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_text'],
      ),
      photoAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_asset_id'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $MessageRecordsTable createAlias(String alias) {
    return $MessageRecordsTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final String id;
  final String requestId;
  final int dayYear;
  final int dayMonth;
  final int dayDay;
  final String dayTimeZoneId;
  final int dayCutoffMicros;
  final int dayPolicyVersion;
  final String role;
  final String? messageText;
  final String? photoAssetId;

  /// UTC microseconds since Unix epoch, preserving deterministic subsecond order.
  final int createdAtUtc;
  final String status;
  const MessageRow({
    required this.id,
    required this.requestId,
    required this.dayYear,
    required this.dayMonth,
    required this.dayDay,
    required this.dayTimeZoneId,
    required this.dayCutoffMicros,
    required this.dayPolicyVersion,
    required this.role,
    this.messageText,
    this.photoAssetId,
    required this.createdAtUtc,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_id'] = Variable<String>(requestId);
    map['day_year'] = Variable<int>(dayYear);
    map['day_month'] = Variable<int>(dayMonth);
    map['day_day'] = Variable<int>(dayDay);
    map['day_time_zone_id'] = Variable<String>(dayTimeZoneId);
    map['day_cutoff_micros'] = Variable<int>(dayCutoffMicros);
    map['day_policy_version'] = Variable<int>(dayPolicyVersion);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || messageText != null) {
      map['message_text'] = Variable<String>(messageText);
    }
    if (!nullToAbsent || photoAssetId != null) {
      map['photo_asset_id'] = Variable<String>(photoAssetId);
    }
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['status'] = Variable<String>(status);
    return map;
  }

  MessageRecordsCompanion toCompanion(bool nullToAbsent) {
    return MessageRecordsCompanion(
      id: Value(id),
      requestId: Value(requestId),
      dayYear: Value(dayYear),
      dayMonth: Value(dayMonth),
      dayDay: Value(dayDay),
      dayTimeZoneId: Value(dayTimeZoneId),
      dayCutoffMicros: Value(dayCutoffMicros),
      dayPolicyVersion: Value(dayPolicyVersion),
      role: Value(role),
      messageText: messageText == null && nullToAbsent
          ? const Value.absent()
          : Value(messageText),
      photoAssetId: photoAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoAssetId),
      createdAtUtc: Value(createdAtUtc),
      status: Value(status),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String>(json['requestId']),
      dayYear: serializer.fromJson<int>(json['dayYear']),
      dayMonth: serializer.fromJson<int>(json['dayMonth']),
      dayDay: serializer.fromJson<int>(json['dayDay']),
      dayTimeZoneId: serializer.fromJson<String>(json['dayTimeZoneId']),
      dayCutoffMicros: serializer.fromJson<int>(json['dayCutoffMicros']),
      dayPolicyVersion: serializer.fromJson<int>(json['dayPolicyVersion']),
      role: serializer.fromJson<String>(json['role']),
      messageText: serializer.fromJson<String?>(json['messageText']),
      photoAssetId: serializer.fromJson<String?>(json['photoAssetId']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String>(requestId),
      'dayYear': serializer.toJson<int>(dayYear),
      'dayMonth': serializer.toJson<int>(dayMonth),
      'dayDay': serializer.toJson<int>(dayDay),
      'dayTimeZoneId': serializer.toJson<String>(dayTimeZoneId),
      'dayCutoffMicros': serializer.toJson<int>(dayCutoffMicros),
      'dayPolicyVersion': serializer.toJson<int>(dayPolicyVersion),
      'role': serializer.toJson<String>(role),
      'messageText': serializer.toJson<String?>(messageText),
      'photoAssetId': serializer.toJson<String?>(photoAssetId),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'status': serializer.toJson<String>(status),
    };
  }

  MessageRow copyWith({
    String? id,
    String? requestId,
    int? dayYear,
    int? dayMonth,
    int? dayDay,
    String? dayTimeZoneId,
    int? dayCutoffMicros,
    int? dayPolicyVersion,
    String? role,
    Value<String?> messageText = const Value.absent(),
    Value<String?> photoAssetId = const Value.absent(),
    int? createdAtUtc,
    String? status,
  }) => MessageRow(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    dayYear: dayYear ?? this.dayYear,
    dayMonth: dayMonth ?? this.dayMonth,
    dayDay: dayDay ?? this.dayDay,
    dayTimeZoneId: dayTimeZoneId ?? this.dayTimeZoneId,
    dayCutoffMicros: dayCutoffMicros ?? this.dayCutoffMicros,
    dayPolicyVersion: dayPolicyVersion ?? this.dayPolicyVersion,
    role: role ?? this.role,
    messageText: messageText.present ? messageText.value : this.messageText,
    photoAssetId: photoAssetId.present ? photoAssetId.value : this.photoAssetId,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    status: status ?? this.status,
  );
  MessageRow copyWithCompanion(MessageRecordsCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      dayYear: data.dayYear.present ? data.dayYear.value : this.dayYear,
      dayMonth: data.dayMonth.present ? data.dayMonth.value : this.dayMonth,
      dayDay: data.dayDay.present ? data.dayDay.value : this.dayDay,
      dayTimeZoneId: data.dayTimeZoneId.present
          ? data.dayTimeZoneId.value
          : this.dayTimeZoneId,
      dayCutoffMicros: data.dayCutoffMicros.present
          ? data.dayCutoffMicros.value
          : this.dayCutoffMicros,
      dayPolicyVersion: data.dayPolicyVersion.present
          ? data.dayPolicyVersion.value
          : this.dayPolicyVersion,
      role: data.role.present ? data.role.value : this.role,
      messageText: data.messageText.present
          ? data.messageText.value
          : this.messageText,
      photoAssetId: data.photoAssetId.present
          ? data.photoAssetId.value
          : this.photoAssetId,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('dayYear: $dayYear, ')
          ..write('dayMonth: $dayMonth, ')
          ..write('dayDay: $dayDay, ')
          ..write('dayTimeZoneId: $dayTimeZoneId, ')
          ..write('dayCutoffMicros: $dayCutoffMicros, ')
          ..write('dayPolicyVersion: $dayPolicyVersion, ')
          ..write('role: $role, ')
          ..write('messageText: $messageText, ')
          ..write('photoAssetId: $photoAssetId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    requestId,
    dayYear,
    dayMonth,
    dayDay,
    dayTimeZoneId,
    dayCutoffMicros,
    dayPolicyVersion,
    role,
    messageText,
    photoAssetId,
    createdAtUtc,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.dayYear == this.dayYear &&
          other.dayMonth == this.dayMonth &&
          other.dayDay == this.dayDay &&
          other.dayTimeZoneId == this.dayTimeZoneId &&
          other.dayCutoffMicros == this.dayCutoffMicros &&
          other.dayPolicyVersion == this.dayPolicyVersion &&
          other.role == this.role &&
          other.messageText == this.messageText &&
          other.photoAssetId == this.photoAssetId &&
          other.createdAtUtc == this.createdAtUtc &&
          other.status == this.status);
}

class MessageRecordsCompanion extends UpdateCompanion<MessageRow> {
  final Value<String> id;
  final Value<String> requestId;
  final Value<int> dayYear;
  final Value<int> dayMonth;
  final Value<int> dayDay;
  final Value<String> dayTimeZoneId;
  final Value<int> dayCutoffMicros;
  final Value<int> dayPolicyVersion;
  final Value<String> role;
  final Value<String?> messageText;
  final Value<String?> photoAssetId;
  final Value<int> createdAtUtc;
  final Value<String> status;
  final Value<int> rowid;
  const MessageRecordsCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.dayYear = const Value.absent(),
    this.dayMonth = const Value.absent(),
    this.dayDay = const Value.absent(),
    this.dayTimeZoneId = const Value.absent(),
    this.dayCutoffMicros = const Value.absent(),
    this.dayPolicyVersion = const Value.absent(),
    this.role = const Value.absent(),
    this.messageText = const Value.absent(),
    this.photoAssetId = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageRecordsCompanion.insert({
    required String id,
    required String requestId,
    required int dayYear,
    required int dayMonth,
    required int dayDay,
    required String dayTimeZoneId,
    required int dayCutoffMicros,
    required int dayPolicyVersion,
    required String role,
    this.messageText = const Value.absent(),
    this.photoAssetId = const Value.absent(),
    required int createdAtUtc,
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       requestId = Value(requestId),
       dayYear = Value(dayYear),
       dayMonth = Value(dayMonth),
       dayDay = Value(dayDay),
       dayTimeZoneId = Value(dayTimeZoneId),
       dayCutoffMicros = Value(dayCutoffMicros),
       dayPolicyVersion = Value(dayPolicyVersion),
       role = Value(role),
       createdAtUtc = Value(createdAtUtc),
       status = Value(status);
  static Insertable<MessageRow> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<int>? dayYear,
    Expression<int>? dayMonth,
    Expression<int>? dayDay,
    Expression<String>? dayTimeZoneId,
    Expression<int>? dayCutoffMicros,
    Expression<int>? dayPolicyVersion,
    Expression<String>? role,
    Expression<String>? messageText,
    Expression<String>? photoAssetId,
    Expression<int>? createdAtUtc,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (dayYear != null) 'day_year': dayYear,
      if (dayMonth != null) 'day_month': dayMonth,
      if (dayDay != null) 'day_day': dayDay,
      if (dayTimeZoneId != null) 'day_time_zone_id': dayTimeZoneId,
      if (dayCutoffMicros != null) 'day_cutoff_micros': dayCutoffMicros,
      if (dayPolicyVersion != null) 'day_policy_version': dayPolicyVersion,
      if (role != null) 'role': role,
      if (messageText != null) 'message_text': messageText,
      if (photoAssetId != null) 'photo_asset_id': photoAssetId,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? requestId,
    Value<int>? dayYear,
    Value<int>? dayMonth,
    Value<int>? dayDay,
    Value<String>? dayTimeZoneId,
    Value<int>? dayCutoffMicros,
    Value<int>? dayPolicyVersion,
    Value<String>? role,
    Value<String?>? messageText,
    Value<String?>? photoAssetId,
    Value<int>? createdAtUtc,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return MessageRecordsCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      dayYear: dayYear ?? this.dayYear,
      dayMonth: dayMonth ?? this.dayMonth,
      dayDay: dayDay ?? this.dayDay,
      dayTimeZoneId: dayTimeZoneId ?? this.dayTimeZoneId,
      dayCutoffMicros: dayCutoffMicros ?? this.dayCutoffMicros,
      dayPolicyVersion: dayPolicyVersion ?? this.dayPolicyVersion,
      role: role ?? this.role,
      messageText: messageText ?? this.messageText,
      photoAssetId: photoAssetId ?? this.photoAssetId,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (dayYear.present) {
      map['day_year'] = Variable<int>(dayYear.value);
    }
    if (dayMonth.present) {
      map['day_month'] = Variable<int>(dayMonth.value);
    }
    if (dayDay.present) {
      map['day_day'] = Variable<int>(dayDay.value);
    }
    if (dayTimeZoneId.present) {
      map['day_time_zone_id'] = Variable<String>(dayTimeZoneId.value);
    }
    if (dayCutoffMicros.present) {
      map['day_cutoff_micros'] = Variable<int>(dayCutoffMicros.value);
    }
    if (dayPolicyVersion.present) {
      map['day_policy_version'] = Variable<int>(dayPolicyVersion.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (messageText.present) {
      map['message_text'] = Variable<String>(messageText.value);
    }
    if (photoAssetId.present) {
      map['photo_asset_id'] = Variable<String>(photoAssetId.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageRecordsCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('dayYear: $dayYear, ')
          ..write('dayMonth: $dayMonth, ')
          ..write('dayDay: $dayDay, ')
          ..write('dayTimeZoneId: $dayTimeZoneId, ')
          ..write('dayCutoffMicros: $dayCutoffMicros, ')
          ..write('dayPolicyVersion: $dayPolicyVersion, ')
          ..write('role: $role, ')
          ..write('messageText: $messageText, ')
          ..write('photoAssetId: $photoAssetId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayYearMeta = const VerificationMeta(
    'dayYear',
  );
  @override
  late final GeneratedColumn<int> dayYear = GeneratedColumn<int>(
    'day_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMonthMeta = const VerificationMeta(
    'dayMonth',
  );
  @override
  late final GeneratedColumn<int> dayMonth = GeneratedColumn<int>(
    'day_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayDayMeta = const VerificationMeta('dayDay');
  @override
  late final GeneratedColumn<int> dayDay = GeneratedColumn<int>(
    'day_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayTimeZoneIdMeta = const VerificationMeta(
    'dayTimeZoneId',
  );
  @override
  late final GeneratedColumn<String> dayTimeZoneId = GeneratedColumn<String>(
    'day_time_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayCutoffMicrosMeta = const VerificationMeta(
    'dayCutoffMicros',
  );
  @override
  late final GeneratedColumn<int> dayCutoffMicros = GeneratedColumn<int>(
    'day_cutoff_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayPolicyVersionMeta = const VerificationMeta(
    'dayPolicyVersion',
  );
  @override
  late final GeneratedColumn<int> dayPolicyVersion = GeneratedColumn<int>(
    'day_policy_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _snapshotSchemaVersionMeta =
      const VerificationMeta('snapshotSchemaVersion');
  @override
  late final GeneratedColumn<int> snapshotSchemaVersion = GeneratedColumn<int>(
    'snapshot_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generationIdMeta = const VerificationMeta(
    'generationId',
  );
  @override
  late final GeneratedColumn<String> generationId = GeneratedColumn<String>(
    'generation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtUtcMeta = const VerificationMeta(
    'generatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> generatedAtUtc = GeneratedColumn<int>(
    'generated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayYear,
    dayMonth,
    dayDay,
    dayTimeZoneId,
    dayCutoffMicros,
    dayPolicyVersion,
    version,
    status,
    snapshotSchemaVersion,
    snapshotJson,
    generationId,
    generatedAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day_year')) {
      context.handle(
        _dayYearMeta,
        dayYear.isAcceptableOrUnknown(data['day_year']!, _dayYearMeta),
      );
    } else if (isInserting) {
      context.missing(_dayYearMeta);
    }
    if (data.containsKey('day_month')) {
      context.handle(
        _dayMonthMeta,
        dayMonth.isAcceptableOrUnknown(data['day_month']!, _dayMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMonthMeta);
    }
    if (data.containsKey('day_day')) {
      context.handle(
        _dayDayMeta,
        dayDay.isAcceptableOrUnknown(data['day_day']!, _dayDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayDayMeta);
    }
    if (data.containsKey('day_time_zone_id')) {
      context.handle(
        _dayTimeZoneIdMeta,
        dayTimeZoneId.isAcceptableOrUnknown(
          data['day_time_zone_id']!,
          _dayTimeZoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayTimeZoneIdMeta);
    }
    if (data.containsKey('day_cutoff_micros')) {
      context.handle(
        _dayCutoffMicrosMeta,
        dayCutoffMicros.isAcceptableOrUnknown(
          data['day_cutoff_micros']!,
          _dayCutoffMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayCutoffMicrosMeta);
    }
    if (data.containsKey('day_policy_version')) {
      context.handle(
        _dayPolicyVersionMeta,
        dayPolicyVersion.isAcceptableOrUnknown(
          data['day_policy_version']!,
          _dayPolicyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayPolicyVersionMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('snapshot_schema_version')) {
      context.handle(
        _snapshotSchemaVersionMeta,
        snapshotSchemaVersion.isAcceptableOrUnknown(
          data['snapshot_schema_version']!,
          _snapshotSchemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotSchemaVersionMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('generation_id')) {
      context.handle(
        _generationIdMeta,
        generationId.isAcceptableOrUnknown(
          data['generation_id']!,
          _generationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generationIdMeta);
    }
    if (data.containsKey('generated_at_utc')) {
      context.handle(
        _generatedAtUtcMeta,
        generatedAtUtc.isAcceptableOrUnknown(
          data['generated_at_utc']!,
          _generatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {generationId},
    {
      dayYear,
      dayMonth,
      dayDay,
      dayTimeZoneId,
      dayCutoffMicros,
      dayPolicyVersion,
      version,
    },
  ];
  @override
  DiaryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dayYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_year'],
      )!,
      dayMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_month'],
      )!,
      dayDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_day'],
      )!,
      dayTimeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_time_zone_id'],
      )!,
      dayCutoffMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_cutoff_micros'],
      )!,
      dayPolicyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_policy_version'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      snapshotSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshot_schema_version'],
      )!,
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      generationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generation_id'],
      )!,
      generatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generated_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class DiaryEntryRow extends DataClass implements Insertable<DiaryEntryRow> {
  final String id;
  final int dayYear;
  final int dayMonth;
  final int dayDay;
  final String dayTimeZoneId;
  final int dayCutoffMicros;
  final int dayPolicyVersion;
  final int version;
  final String status;
  final int snapshotSchemaVersion;
  final String snapshotJson;
  final String generationId;
  final int generatedAtUtc;
  final int updatedAtUtc;
  const DiaryEntryRow({
    required this.id,
    required this.dayYear,
    required this.dayMonth,
    required this.dayDay,
    required this.dayTimeZoneId,
    required this.dayCutoffMicros,
    required this.dayPolicyVersion,
    required this.version,
    required this.status,
    required this.snapshotSchemaVersion,
    required this.snapshotJson,
    required this.generationId,
    required this.generatedAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_year'] = Variable<int>(dayYear);
    map['day_month'] = Variable<int>(dayMonth);
    map['day_day'] = Variable<int>(dayDay);
    map['day_time_zone_id'] = Variable<String>(dayTimeZoneId);
    map['day_cutoff_micros'] = Variable<int>(dayCutoffMicros);
    map['day_policy_version'] = Variable<int>(dayPolicyVersion);
    map['version'] = Variable<int>(version);
    map['status'] = Variable<String>(status);
    map['snapshot_schema_version'] = Variable<int>(snapshotSchemaVersion);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    map['generation_id'] = Variable<String>(generationId);
    map['generated_at_utc'] = Variable<int>(generatedAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      dayYear: Value(dayYear),
      dayMonth: Value(dayMonth),
      dayDay: Value(dayDay),
      dayTimeZoneId: Value(dayTimeZoneId),
      dayCutoffMicros: Value(dayCutoffMicros),
      dayPolicyVersion: Value(dayPolicyVersion),
      version: Value(version),
      status: Value(status),
      snapshotSchemaVersion: Value(snapshotSchemaVersion),
      snapshotJson: Value(snapshotJson),
      generationId: Value(generationId),
      generatedAtUtc: Value(generatedAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory DiaryEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntryRow(
      id: serializer.fromJson<String>(json['id']),
      dayYear: serializer.fromJson<int>(json['dayYear']),
      dayMonth: serializer.fromJson<int>(json['dayMonth']),
      dayDay: serializer.fromJson<int>(json['dayDay']),
      dayTimeZoneId: serializer.fromJson<String>(json['dayTimeZoneId']),
      dayCutoffMicros: serializer.fromJson<int>(json['dayCutoffMicros']),
      dayPolicyVersion: serializer.fromJson<int>(json['dayPolicyVersion']),
      version: serializer.fromJson<int>(json['version']),
      status: serializer.fromJson<String>(json['status']),
      snapshotSchemaVersion: serializer.fromJson<int>(
        json['snapshotSchemaVersion'],
      ),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      generationId: serializer.fromJson<String>(json['generationId']),
      generatedAtUtc: serializer.fromJson<int>(json['generatedAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dayYear': serializer.toJson<int>(dayYear),
      'dayMonth': serializer.toJson<int>(dayMonth),
      'dayDay': serializer.toJson<int>(dayDay),
      'dayTimeZoneId': serializer.toJson<String>(dayTimeZoneId),
      'dayCutoffMicros': serializer.toJson<int>(dayCutoffMicros),
      'dayPolicyVersion': serializer.toJson<int>(dayPolicyVersion),
      'version': serializer.toJson<int>(version),
      'status': serializer.toJson<String>(status),
      'snapshotSchemaVersion': serializer.toJson<int>(snapshotSchemaVersion),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'generationId': serializer.toJson<String>(generationId),
      'generatedAtUtc': serializer.toJson<int>(generatedAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  DiaryEntryRow copyWith({
    String? id,
    int? dayYear,
    int? dayMonth,
    int? dayDay,
    String? dayTimeZoneId,
    int? dayCutoffMicros,
    int? dayPolicyVersion,
    int? version,
    String? status,
    int? snapshotSchemaVersion,
    String? snapshotJson,
    String? generationId,
    int? generatedAtUtc,
    int? updatedAtUtc,
  }) => DiaryEntryRow(
    id: id ?? this.id,
    dayYear: dayYear ?? this.dayYear,
    dayMonth: dayMonth ?? this.dayMonth,
    dayDay: dayDay ?? this.dayDay,
    dayTimeZoneId: dayTimeZoneId ?? this.dayTimeZoneId,
    dayCutoffMicros: dayCutoffMicros ?? this.dayCutoffMicros,
    dayPolicyVersion: dayPolicyVersion ?? this.dayPolicyVersion,
    version: version ?? this.version,
    status: status ?? this.status,
    snapshotSchemaVersion: snapshotSchemaVersion ?? this.snapshotSchemaVersion,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    generationId: generationId ?? this.generationId,
    generatedAtUtc: generatedAtUtc ?? this.generatedAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  DiaryEntryRow copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntryRow(
      id: data.id.present ? data.id.value : this.id,
      dayYear: data.dayYear.present ? data.dayYear.value : this.dayYear,
      dayMonth: data.dayMonth.present ? data.dayMonth.value : this.dayMonth,
      dayDay: data.dayDay.present ? data.dayDay.value : this.dayDay,
      dayTimeZoneId: data.dayTimeZoneId.present
          ? data.dayTimeZoneId.value
          : this.dayTimeZoneId,
      dayCutoffMicros: data.dayCutoffMicros.present
          ? data.dayCutoffMicros.value
          : this.dayCutoffMicros,
      dayPolicyVersion: data.dayPolicyVersion.present
          ? data.dayPolicyVersion.value
          : this.dayPolicyVersion,
      version: data.version.present ? data.version.value : this.version,
      status: data.status.present ? data.status.value : this.status,
      snapshotSchemaVersion: data.snapshotSchemaVersion.present
          ? data.snapshotSchemaVersion.value
          : this.snapshotSchemaVersion,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      generationId: data.generationId.present
          ? data.generationId.value
          : this.generationId,
      generatedAtUtc: data.generatedAtUtc.present
          ? data.generatedAtUtc.value
          : this.generatedAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntryRow(')
          ..write('id: $id, ')
          ..write('dayYear: $dayYear, ')
          ..write('dayMonth: $dayMonth, ')
          ..write('dayDay: $dayDay, ')
          ..write('dayTimeZoneId: $dayTimeZoneId, ')
          ..write('dayCutoffMicros: $dayCutoffMicros, ')
          ..write('dayPolicyVersion: $dayPolicyVersion, ')
          ..write('version: $version, ')
          ..write('status: $status, ')
          ..write('snapshotSchemaVersion: $snapshotSchemaVersion, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('generationId: $generationId, ')
          ..write('generatedAtUtc: $generatedAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayYear,
    dayMonth,
    dayDay,
    dayTimeZoneId,
    dayCutoffMicros,
    dayPolicyVersion,
    version,
    status,
    snapshotSchemaVersion,
    snapshotJson,
    generationId,
    generatedAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntryRow &&
          other.id == this.id &&
          other.dayYear == this.dayYear &&
          other.dayMonth == this.dayMonth &&
          other.dayDay == this.dayDay &&
          other.dayTimeZoneId == this.dayTimeZoneId &&
          other.dayCutoffMicros == this.dayCutoffMicros &&
          other.dayPolicyVersion == this.dayPolicyVersion &&
          other.version == this.version &&
          other.status == this.status &&
          other.snapshotSchemaVersion == this.snapshotSchemaVersion &&
          other.snapshotJson == this.snapshotJson &&
          other.generationId == this.generationId &&
          other.generatedAtUtc == this.generatedAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntryRow> {
  final Value<String> id;
  final Value<int> dayYear;
  final Value<int> dayMonth;
  final Value<int> dayDay;
  final Value<String> dayTimeZoneId;
  final Value<int> dayCutoffMicros;
  final Value<int> dayPolicyVersion;
  final Value<int> version;
  final Value<String> status;
  final Value<int> snapshotSchemaVersion;
  final Value<String> snapshotJson;
  final Value<String> generationId;
  final Value<int> generatedAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int> rowid;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.dayYear = const Value.absent(),
    this.dayMonth = const Value.absent(),
    this.dayDay = const Value.absent(),
    this.dayTimeZoneId = const Value.absent(),
    this.dayCutoffMicros = const Value.absent(),
    this.dayPolicyVersion = const Value.absent(),
    this.version = const Value.absent(),
    this.status = const Value.absent(),
    this.snapshotSchemaVersion = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.generationId = const Value.absent(),
    this.generatedAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    required String id,
    required int dayYear,
    required int dayMonth,
    required int dayDay,
    required String dayTimeZoneId,
    required int dayCutoffMicros,
    required int dayPolicyVersion,
    required int version,
    required String status,
    required int snapshotSchemaVersion,
    required String snapshotJson,
    required String generationId,
    required int generatedAtUtc,
    required int updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayYear = Value(dayYear),
       dayMonth = Value(dayMonth),
       dayDay = Value(dayDay),
       dayTimeZoneId = Value(dayTimeZoneId),
       dayCutoffMicros = Value(dayCutoffMicros),
       dayPolicyVersion = Value(dayPolicyVersion),
       version = Value(version),
       status = Value(status),
       snapshotSchemaVersion = Value(snapshotSchemaVersion),
       snapshotJson = Value(snapshotJson),
       generationId = Value(generationId),
       generatedAtUtc = Value(generatedAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<DiaryEntryRow> custom({
    Expression<String>? id,
    Expression<int>? dayYear,
    Expression<int>? dayMonth,
    Expression<int>? dayDay,
    Expression<String>? dayTimeZoneId,
    Expression<int>? dayCutoffMicros,
    Expression<int>? dayPolicyVersion,
    Expression<int>? version,
    Expression<String>? status,
    Expression<int>? snapshotSchemaVersion,
    Expression<String>? snapshotJson,
    Expression<String>? generationId,
    Expression<int>? generatedAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayYear != null) 'day_year': dayYear,
      if (dayMonth != null) 'day_month': dayMonth,
      if (dayDay != null) 'day_day': dayDay,
      if (dayTimeZoneId != null) 'day_time_zone_id': dayTimeZoneId,
      if (dayCutoffMicros != null) 'day_cutoff_micros': dayCutoffMicros,
      if (dayPolicyVersion != null) 'day_policy_version': dayPolicyVersion,
      if (version != null) 'version': version,
      if (status != null) 'status': status,
      if (snapshotSchemaVersion != null)
        'snapshot_schema_version': snapshotSchemaVersion,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (generationId != null) 'generation_id': generationId,
      if (generatedAtUtc != null) 'generated_at_utc': generatedAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? dayYear,
    Value<int>? dayMonth,
    Value<int>? dayDay,
    Value<String>? dayTimeZoneId,
    Value<int>? dayCutoffMicros,
    Value<int>? dayPolicyVersion,
    Value<int>? version,
    Value<String>? status,
    Value<int>? snapshotSchemaVersion,
    Value<String>? snapshotJson,
    Value<String>? generationId,
    Value<int>? generatedAtUtc,
    Value<int>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      dayYear: dayYear ?? this.dayYear,
      dayMonth: dayMonth ?? this.dayMonth,
      dayDay: dayDay ?? this.dayDay,
      dayTimeZoneId: dayTimeZoneId ?? this.dayTimeZoneId,
      dayCutoffMicros: dayCutoffMicros ?? this.dayCutoffMicros,
      dayPolicyVersion: dayPolicyVersion ?? this.dayPolicyVersion,
      version: version ?? this.version,
      status: status ?? this.status,
      snapshotSchemaVersion:
          snapshotSchemaVersion ?? this.snapshotSchemaVersion,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      generationId: generationId ?? this.generationId,
      generatedAtUtc: generatedAtUtc ?? this.generatedAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dayYear.present) {
      map['day_year'] = Variable<int>(dayYear.value);
    }
    if (dayMonth.present) {
      map['day_month'] = Variable<int>(dayMonth.value);
    }
    if (dayDay.present) {
      map['day_day'] = Variable<int>(dayDay.value);
    }
    if (dayTimeZoneId.present) {
      map['day_time_zone_id'] = Variable<String>(dayTimeZoneId.value);
    }
    if (dayCutoffMicros.present) {
      map['day_cutoff_micros'] = Variable<int>(dayCutoffMicros.value);
    }
    if (dayPolicyVersion.present) {
      map['day_policy_version'] = Variable<int>(dayPolicyVersion.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snapshotSchemaVersion.present) {
      map['snapshot_schema_version'] = Variable<int>(
        snapshotSchemaVersion.value,
      );
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (generationId.present) {
      map['generation_id'] = Variable<String>(generationId.value);
    }
    if (generatedAtUtc.present) {
      map['generated_at_utc'] = Variable<int>(generatedAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('dayYear: $dayYear, ')
          ..write('dayMonth: $dayMonth, ')
          ..write('dayDay: $dayDay, ')
          ..write('dayTimeZoneId: $dayTimeZoneId, ')
          ..write('dayCutoffMicros: $dayCutoffMicros, ')
          ..write('dayPolicyVersion: $dayPolicyVersion, ')
          ..write('version: $version, ')
          ..write('status: $status, ')
          ..write('snapshotSchemaVersion: $snapshotSchemaVersion, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('generationId: $generationId, ')
          ..write('generatedAtUtc: $generatedAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaAssetRecordsTable extends MediaAssetRecords
    with TableInfo<$MediaAssetRecordsTable, MediaAssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAssetRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayYearMeta = const VerificationMeta(
    'dayYear',
  );
  @override
  late final GeneratedColumn<int> dayYear = GeneratedColumn<int>(
    'day_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMonthMeta = const VerificationMeta(
    'dayMonth',
  );
  @override
  late final GeneratedColumn<int> dayMonth = GeneratedColumn<int>(
    'day_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayDayMeta = const VerificationMeta('dayDay');
  @override
  late final GeneratedColumn<int> dayDay = GeneratedColumn<int>(
    'day_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayTimeZoneIdMeta = const VerificationMeta(
    'dayTimeZoneId',
  );
  @override
  late final GeneratedColumn<String> dayTimeZoneId = GeneratedColumn<String>(
    'day_time_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayCutoffMicrosMeta = const VerificationMeta(
    'dayCutoffMicros',
  );
  @override
  late final GeneratedColumn<int> dayCutoffMicros = GeneratedColumn<int>(
    'day_cutoff_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayPolicyVersionMeta = const VerificationMeta(
    'dayPolicyVersion',
  );
  @override
  late final GeneratedColumn<int> dayPolicyVersion = GeneratedColumn<int>(
    'day_policy_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storageKeyMeta = const VerificationMeta(
    'storageKey',
  );
  @override
  late final GeneratedColumn<String> storageKey = GeneratedColumn<String>(
    'storage_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  @override
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayYear,
    dayMonth,
    dayDay,
    dayTimeZoneId,
    dayCutoffMicros,
    dayPolicyVersion,
    storageKey,
    mimeType,
    byteLength,
    createdAtUtc,
    lifecycle,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day_year')) {
      context.handle(
        _dayYearMeta,
        dayYear.isAcceptableOrUnknown(data['day_year']!, _dayYearMeta),
      );
    } else if (isInserting) {
      context.missing(_dayYearMeta);
    }
    if (data.containsKey('day_month')) {
      context.handle(
        _dayMonthMeta,
        dayMonth.isAcceptableOrUnknown(data['day_month']!, _dayMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMonthMeta);
    }
    if (data.containsKey('day_day')) {
      context.handle(
        _dayDayMeta,
        dayDay.isAcceptableOrUnknown(data['day_day']!, _dayDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayDayMeta);
    }
    if (data.containsKey('day_time_zone_id')) {
      context.handle(
        _dayTimeZoneIdMeta,
        dayTimeZoneId.isAcceptableOrUnknown(
          data['day_time_zone_id']!,
          _dayTimeZoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayTimeZoneIdMeta);
    }
    if (data.containsKey('day_cutoff_micros')) {
      context.handle(
        _dayCutoffMicrosMeta,
        dayCutoffMicros.isAcceptableOrUnknown(
          data['day_cutoff_micros']!,
          _dayCutoffMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayCutoffMicrosMeta);
    }
    if (data.containsKey('day_policy_version')) {
      context.handle(
        _dayPolicyVersionMeta,
        dayPolicyVersion.isAcceptableOrUnknown(
          data['day_policy_version']!,
          _dayPolicyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayPolicyVersionMeta);
    }
    if (data.containsKey('storage_key')) {
      context.handle(
        _storageKeyMeta,
        storageKey.isAcceptableOrUnknown(data['storage_key']!, _storageKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_storageKeyMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    } else if (isInserting) {
      context.missing(_byteLengthMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {storageKey},
  ];
  @override
  MediaAssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dayYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_year'],
      )!,
      dayMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_month'],
      )!,
      dayDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_day'],
      )!,
      dayTimeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_time_zone_id'],
      )!,
      dayCutoffMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_cutoff_micros'],
      )!,
      dayPolicyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_policy_version'],
      )!,
      storageKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_key'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
    );
  }

  @override
  $MediaAssetRecordsTable createAlias(String alias) {
    return $MediaAssetRecordsTable(attachedDatabase, alias);
  }
}

class MediaAssetRow extends DataClass implements Insertable<MediaAssetRow> {
  final String id;
  final int dayYear;
  final int dayMonth;
  final int dayDay;
  final String dayTimeZoneId;
  final int dayCutoffMicros;
  final int dayPolicyVersion;
  final String storageKey;
  final String mimeType;
  final int byteLength;
  final int createdAtUtc;
  final String lifecycle;
  const MediaAssetRow({
    required this.id,
    required this.dayYear,
    required this.dayMonth,
    required this.dayDay,
    required this.dayTimeZoneId,
    required this.dayCutoffMicros,
    required this.dayPolicyVersion,
    required this.storageKey,
    required this.mimeType,
    required this.byteLength,
    required this.createdAtUtc,
    required this.lifecycle,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_year'] = Variable<int>(dayYear);
    map['day_month'] = Variable<int>(dayMonth);
    map['day_day'] = Variable<int>(dayDay);
    map['day_time_zone_id'] = Variable<String>(dayTimeZoneId);
    map['day_cutoff_micros'] = Variable<int>(dayCutoffMicros);
    map['day_policy_version'] = Variable<int>(dayPolicyVersion);
    map['storage_key'] = Variable<String>(storageKey);
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_length'] = Variable<int>(byteLength);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['lifecycle'] = Variable<String>(lifecycle);
    return map;
  }

  MediaAssetRecordsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetRecordsCompanion(
      id: Value(id),
      dayYear: Value(dayYear),
      dayMonth: Value(dayMonth),
      dayDay: Value(dayDay),
      dayTimeZoneId: Value(dayTimeZoneId),
      dayCutoffMicros: Value(dayCutoffMicros),
      dayPolicyVersion: Value(dayPolicyVersion),
      storageKey: Value(storageKey),
      mimeType: Value(mimeType),
      byteLength: Value(byteLength),
      createdAtUtc: Value(createdAtUtc),
      lifecycle: Value(lifecycle),
    );
  }

  factory MediaAssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAssetRow(
      id: serializer.fromJson<String>(json['id']),
      dayYear: serializer.fromJson<int>(json['dayYear']),
      dayMonth: serializer.fromJson<int>(json['dayMonth']),
      dayDay: serializer.fromJson<int>(json['dayDay']),
      dayTimeZoneId: serializer.fromJson<String>(json['dayTimeZoneId']),
      dayCutoffMicros: serializer.fromJson<int>(json['dayCutoffMicros']),
      dayPolicyVersion: serializer.fromJson<int>(json['dayPolicyVersion']),
      storageKey: serializer.fromJson<String>(json['storageKey']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteLength: serializer.fromJson<int>(json['byteLength']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dayYear': serializer.toJson<int>(dayYear),
      'dayMonth': serializer.toJson<int>(dayMonth),
      'dayDay': serializer.toJson<int>(dayDay),
      'dayTimeZoneId': serializer.toJson<String>(dayTimeZoneId),
      'dayCutoffMicros': serializer.toJson<int>(dayCutoffMicros),
      'dayPolicyVersion': serializer.toJson<int>(dayPolicyVersion),
      'storageKey': serializer.toJson<String>(storageKey),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteLength': serializer.toJson<int>(byteLength),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'lifecycle': serializer.toJson<String>(lifecycle),
    };
  }

  MediaAssetRow copyWith({
    String? id,
    int? dayYear,
    int? dayMonth,
    int? dayDay,
    String? dayTimeZoneId,
    int? dayCutoffMicros,
    int? dayPolicyVersion,
    String? storageKey,
    String? mimeType,
    int? byteLength,
    int? createdAtUtc,
    String? lifecycle,
  }) => MediaAssetRow(
    id: id ?? this.id,
    dayYear: dayYear ?? this.dayYear,
    dayMonth: dayMonth ?? this.dayMonth,
    dayDay: dayDay ?? this.dayDay,
    dayTimeZoneId: dayTimeZoneId ?? this.dayTimeZoneId,
    dayCutoffMicros: dayCutoffMicros ?? this.dayCutoffMicros,
    dayPolicyVersion: dayPolicyVersion ?? this.dayPolicyVersion,
    storageKey: storageKey ?? this.storageKey,
    mimeType: mimeType ?? this.mimeType,
    byteLength: byteLength ?? this.byteLength,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    lifecycle: lifecycle ?? this.lifecycle,
  );
  MediaAssetRow copyWithCompanion(MediaAssetRecordsCompanion data) {
    return MediaAssetRow(
      id: data.id.present ? data.id.value : this.id,
      dayYear: data.dayYear.present ? data.dayYear.value : this.dayYear,
      dayMonth: data.dayMonth.present ? data.dayMonth.value : this.dayMonth,
      dayDay: data.dayDay.present ? data.dayDay.value : this.dayDay,
      dayTimeZoneId: data.dayTimeZoneId.present
          ? data.dayTimeZoneId.value
          : this.dayTimeZoneId,
      dayCutoffMicros: data.dayCutoffMicros.present
          ? data.dayCutoffMicros.value
          : this.dayCutoffMicros,
      dayPolicyVersion: data.dayPolicyVersion.present
          ? data.dayPolicyVersion.value
          : this.dayPolicyVersion,
      storageKey: data.storageKey.present
          ? data.storageKey.value
          : this.storageKey,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetRow(')
          ..write('id: $id, ')
          ..write('dayYear: $dayYear, ')
          ..write('dayMonth: $dayMonth, ')
          ..write('dayDay: $dayDay, ')
          ..write('dayTimeZoneId: $dayTimeZoneId, ')
          ..write('dayCutoffMicros: $dayCutoffMicros, ')
          ..write('dayPolicyVersion: $dayPolicyVersion, ')
          ..write('storageKey: $storageKey, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteLength: $byteLength, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('lifecycle: $lifecycle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayYear,
    dayMonth,
    dayDay,
    dayTimeZoneId,
    dayCutoffMicros,
    dayPolicyVersion,
    storageKey,
    mimeType,
    byteLength,
    createdAtUtc,
    lifecycle,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAssetRow &&
          other.id == this.id &&
          other.dayYear == this.dayYear &&
          other.dayMonth == this.dayMonth &&
          other.dayDay == this.dayDay &&
          other.dayTimeZoneId == this.dayTimeZoneId &&
          other.dayCutoffMicros == this.dayCutoffMicros &&
          other.dayPolicyVersion == this.dayPolicyVersion &&
          other.storageKey == this.storageKey &&
          other.mimeType == this.mimeType &&
          other.byteLength == this.byteLength &&
          other.createdAtUtc == this.createdAtUtc &&
          other.lifecycle == this.lifecycle);
}

class MediaAssetRecordsCompanion extends UpdateCompanion<MediaAssetRow> {
  final Value<String> id;
  final Value<int> dayYear;
  final Value<int> dayMonth;
  final Value<int> dayDay;
  final Value<String> dayTimeZoneId;
  final Value<int> dayCutoffMicros;
  final Value<int> dayPolicyVersion;
  final Value<String> storageKey;
  final Value<String> mimeType;
  final Value<int> byteLength;
  final Value<int> createdAtUtc;
  final Value<String> lifecycle;
  final Value<int> rowid;
  const MediaAssetRecordsCompanion({
    this.id = const Value.absent(),
    this.dayYear = const Value.absent(),
    this.dayMonth = const Value.absent(),
    this.dayDay = const Value.absent(),
    this.dayTimeZoneId = const Value.absent(),
    this.dayCutoffMicros = const Value.absent(),
    this.dayPolicyVersion = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaAssetRecordsCompanion.insert({
    required String id,
    required int dayYear,
    required int dayMonth,
    required int dayDay,
    required String dayTimeZoneId,
    required int dayCutoffMicros,
    required int dayPolicyVersion,
    required String storageKey,
    required String mimeType,
    required int byteLength,
    required int createdAtUtc,
    required String lifecycle,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayYear = Value(dayYear),
       dayMonth = Value(dayMonth),
       dayDay = Value(dayDay),
       dayTimeZoneId = Value(dayTimeZoneId),
       dayCutoffMicros = Value(dayCutoffMicros),
       dayPolicyVersion = Value(dayPolicyVersion),
       storageKey = Value(storageKey),
       mimeType = Value(mimeType),
       byteLength = Value(byteLength),
       createdAtUtc = Value(createdAtUtc),
       lifecycle = Value(lifecycle);
  static Insertable<MediaAssetRow> custom({
    Expression<String>? id,
    Expression<int>? dayYear,
    Expression<int>? dayMonth,
    Expression<int>? dayDay,
    Expression<String>? dayTimeZoneId,
    Expression<int>? dayCutoffMicros,
    Expression<int>? dayPolicyVersion,
    Expression<String>? storageKey,
    Expression<String>? mimeType,
    Expression<int>? byteLength,
    Expression<int>? createdAtUtc,
    Expression<String>? lifecycle,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayYear != null) 'day_year': dayYear,
      if (dayMonth != null) 'day_month': dayMonth,
      if (dayDay != null) 'day_day': dayDay,
      if (dayTimeZoneId != null) 'day_time_zone_id': dayTimeZoneId,
      if (dayCutoffMicros != null) 'day_cutoff_micros': dayCutoffMicros,
      if (dayPolicyVersion != null) 'day_policy_version': dayPolicyVersion,
      if (storageKey != null) 'storage_key': storageKey,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteLength != null) 'byte_length': byteLength,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaAssetRecordsCompanion copyWith({
    Value<String>? id,
    Value<int>? dayYear,
    Value<int>? dayMonth,
    Value<int>? dayDay,
    Value<String>? dayTimeZoneId,
    Value<int>? dayCutoffMicros,
    Value<int>? dayPolicyVersion,
    Value<String>? storageKey,
    Value<String>? mimeType,
    Value<int>? byteLength,
    Value<int>? createdAtUtc,
    Value<String>? lifecycle,
    Value<int>? rowid,
  }) {
    return MediaAssetRecordsCompanion(
      id: id ?? this.id,
      dayYear: dayYear ?? this.dayYear,
      dayMonth: dayMonth ?? this.dayMonth,
      dayDay: dayDay ?? this.dayDay,
      dayTimeZoneId: dayTimeZoneId ?? this.dayTimeZoneId,
      dayCutoffMicros: dayCutoffMicros ?? this.dayCutoffMicros,
      dayPolicyVersion: dayPolicyVersion ?? this.dayPolicyVersion,
      storageKey: storageKey ?? this.storageKey,
      mimeType: mimeType ?? this.mimeType,
      byteLength: byteLength ?? this.byteLength,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      lifecycle: lifecycle ?? this.lifecycle,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dayYear.present) {
      map['day_year'] = Variable<int>(dayYear.value);
    }
    if (dayMonth.present) {
      map['day_month'] = Variable<int>(dayMonth.value);
    }
    if (dayDay.present) {
      map['day_day'] = Variable<int>(dayDay.value);
    }
    if (dayTimeZoneId.present) {
      map['day_time_zone_id'] = Variable<String>(dayTimeZoneId.value);
    }
    if (dayCutoffMicros.present) {
      map['day_cutoff_micros'] = Variable<int>(dayCutoffMicros.value);
    }
    if (dayPolicyVersion.present) {
      map['day_policy_version'] = Variable<int>(dayPolicyVersion.value);
    }
    if (storageKey.present) {
      map['storage_key'] = Variable<String>(storageKey.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetRecordsCompanion(')
          ..write('id: $id, ')
          ..write('dayYear: $dayYear, ')
          ..write('dayMonth: $dayMonth, ')
          ..write('dayDay: $dayDay, ')
          ..write('dayTimeZoneId: $dayTimeZoneId, ')
          ..write('dayCutoffMicros: $dayCutoffMicros, ')
          ..write('dayPolicyVersion: $dayPolicyVersion, ')
          ..write('storageKey: $storageKey, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteLength: $byteLength, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiPersonaRecordsTable extends AiPersonaRecords
    with TableInfo<$AiPersonaRecordsTable, AiPersonaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiPersonaRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonKeyMeta = const VerificationMeta(
    'singletonKey',
  );
  @override
  late final GeneratedColumn<int> singletonKey = GeneratedColumn<int>(
    'singleton_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personaNameMeta = const VerificationMeta(
    'personaName',
  );
  @override
  late final GeneratedColumn<String> personaName = GeneratedColumn<String>(
    'persona_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarSeedMeta = const VerificationMeta(
    'avatarSeed',
  );
  @override
  late final GeneratedColumn<String> avatarSeed = GeneratedColumn<String>(
    'avatar_seed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toneMeta = const VerificationMeta('tone');
  @override
  late final GeneratedColumn<String> tone = GeneratedColumn<String>(
    'tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customInstructionsMeta =
      const VerificationMeta('customInstructions');
  @override
  late final GeneratedColumn<String> customInstructions =
      GeneratedColumn<String>(
        'custom_instructions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _reactionLengthMeta = const VerificationMeta(
    'reactionLength',
  );
  @override
  late final GeneratedColumn<String> reactionLength = GeneratedColumn<String>(
    'reaction_length',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonKey,
    personaId,
    personaName,
    avatarSeed,
    tone,
    customInstructions,
    reactionLength,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_persona';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiPersonaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_key')) {
      context.handle(
        _singletonKeyMeta,
        singletonKey.isAcceptableOrUnknown(
          data['singleton_key']!,
          _singletonKeyMeta,
        ),
      );
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personaIdMeta);
    }
    if (data.containsKey('persona_name')) {
      context.handle(
        _personaNameMeta,
        personaName.isAcceptableOrUnknown(
          data['persona_name']!,
          _personaNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personaNameMeta);
    }
    if (data.containsKey('avatar_seed')) {
      context.handle(
        _avatarSeedMeta,
        avatarSeed.isAcceptableOrUnknown(data['avatar_seed']!, _avatarSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarSeedMeta);
    }
    if (data.containsKey('tone')) {
      context.handle(
        _toneMeta,
        tone.isAcceptableOrUnknown(data['tone']!, _toneMeta),
      );
    } else if (isInserting) {
      context.missing(_toneMeta);
    }
    if (data.containsKey('custom_instructions')) {
      context.handle(
        _customInstructionsMeta,
        customInstructions.isAcceptableOrUnknown(
          data['custom_instructions']!,
          _customInstructionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customInstructionsMeta);
    }
    if (data.containsKey('reaction_length')) {
      context.handle(
        _reactionLengthMeta,
        reactionLength.isAcceptableOrUnknown(
          data['reaction_length']!,
          _reactionLengthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reactionLengthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonKey};
  @override
  AiPersonaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiPersonaRow(
      singletonKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_key'],
      )!,
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      )!,
      personaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_name'],
      )!,
      avatarSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_seed'],
      )!,
      tone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone'],
      )!,
      customInstructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_instructions'],
      )!,
      reactionLength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reaction_length'],
      )!,
    );
  }

  @override
  $AiPersonaRecordsTable createAlias(String alias) {
    return $AiPersonaRecordsTable(attachedDatabase, alias);
  }
}

class AiPersonaRow extends DataClass implements Insertable<AiPersonaRow> {
  final int singletonKey;
  final String personaId;
  final String personaName;
  final String avatarSeed;
  final String tone;
  final String customInstructions;
  final String reactionLength;
  const AiPersonaRow({
    required this.singletonKey,
    required this.personaId,
    required this.personaName,
    required this.avatarSeed,
    required this.tone,
    required this.customInstructions,
    required this.reactionLength,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_key'] = Variable<int>(singletonKey);
    map['persona_id'] = Variable<String>(personaId);
    map['persona_name'] = Variable<String>(personaName);
    map['avatar_seed'] = Variable<String>(avatarSeed);
    map['tone'] = Variable<String>(tone);
    map['custom_instructions'] = Variable<String>(customInstructions);
    map['reaction_length'] = Variable<String>(reactionLength);
    return map;
  }

  AiPersonaRecordsCompanion toCompanion(bool nullToAbsent) {
    return AiPersonaRecordsCompanion(
      singletonKey: Value(singletonKey),
      personaId: Value(personaId),
      personaName: Value(personaName),
      avatarSeed: Value(avatarSeed),
      tone: Value(tone),
      customInstructions: Value(customInstructions),
      reactionLength: Value(reactionLength),
    );
  }

  factory AiPersonaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiPersonaRow(
      singletonKey: serializer.fromJson<int>(json['singletonKey']),
      personaId: serializer.fromJson<String>(json['personaId']),
      personaName: serializer.fromJson<String>(json['personaName']),
      avatarSeed: serializer.fromJson<String>(json['avatarSeed']),
      tone: serializer.fromJson<String>(json['tone']),
      customInstructions: serializer.fromJson<String>(
        json['customInstructions'],
      ),
      reactionLength: serializer.fromJson<String>(json['reactionLength']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonKey': serializer.toJson<int>(singletonKey),
      'personaId': serializer.toJson<String>(personaId),
      'personaName': serializer.toJson<String>(personaName),
      'avatarSeed': serializer.toJson<String>(avatarSeed),
      'tone': serializer.toJson<String>(tone),
      'customInstructions': serializer.toJson<String>(customInstructions),
      'reactionLength': serializer.toJson<String>(reactionLength),
    };
  }

  AiPersonaRow copyWith({
    int? singletonKey,
    String? personaId,
    String? personaName,
    String? avatarSeed,
    String? tone,
    String? customInstructions,
    String? reactionLength,
  }) => AiPersonaRow(
    singletonKey: singletonKey ?? this.singletonKey,
    personaId: personaId ?? this.personaId,
    personaName: personaName ?? this.personaName,
    avatarSeed: avatarSeed ?? this.avatarSeed,
    tone: tone ?? this.tone,
    customInstructions: customInstructions ?? this.customInstructions,
    reactionLength: reactionLength ?? this.reactionLength,
  );
  AiPersonaRow copyWithCompanion(AiPersonaRecordsCompanion data) {
    return AiPersonaRow(
      singletonKey: data.singletonKey.present
          ? data.singletonKey.value
          : this.singletonKey,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      personaName: data.personaName.present
          ? data.personaName.value
          : this.personaName,
      avatarSeed: data.avatarSeed.present
          ? data.avatarSeed.value
          : this.avatarSeed,
      tone: data.tone.present ? data.tone.value : this.tone,
      customInstructions: data.customInstructions.present
          ? data.customInstructions.value
          : this.customInstructions,
      reactionLength: data.reactionLength.present
          ? data.reactionLength.value
          : this.reactionLength,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiPersonaRow(')
          ..write('singletonKey: $singletonKey, ')
          ..write('personaId: $personaId, ')
          ..write('personaName: $personaName, ')
          ..write('avatarSeed: $avatarSeed, ')
          ..write('tone: $tone, ')
          ..write('customInstructions: $customInstructions, ')
          ..write('reactionLength: $reactionLength')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonKey,
    personaId,
    personaName,
    avatarSeed,
    tone,
    customInstructions,
    reactionLength,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiPersonaRow &&
          other.singletonKey == this.singletonKey &&
          other.personaId == this.personaId &&
          other.personaName == this.personaName &&
          other.avatarSeed == this.avatarSeed &&
          other.tone == this.tone &&
          other.customInstructions == this.customInstructions &&
          other.reactionLength == this.reactionLength);
}

class AiPersonaRecordsCompanion extends UpdateCompanion<AiPersonaRow> {
  final Value<int> singletonKey;
  final Value<String> personaId;
  final Value<String> personaName;
  final Value<String> avatarSeed;
  final Value<String> tone;
  final Value<String> customInstructions;
  final Value<String> reactionLength;
  const AiPersonaRecordsCompanion({
    this.singletonKey = const Value.absent(),
    this.personaId = const Value.absent(),
    this.personaName = const Value.absent(),
    this.avatarSeed = const Value.absent(),
    this.tone = const Value.absent(),
    this.customInstructions = const Value.absent(),
    this.reactionLength = const Value.absent(),
  });
  AiPersonaRecordsCompanion.insert({
    this.singletonKey = const Value.absent(),
    required String personaId,
    required String personaName,
    required String avatarSeed,
    required String tone,
    required String customInstructions,
    required String reactionLength,
  }) : personaId = Value(personaId),
       personaName = Value(personaName),
       avatarSeed = Value(avatarSeed),
       tone = Value(tone),
       customInstructions = Value(customInstructions),
       reactionLength = Value(reactionLength);
  static Insertable<AiPersonaRow> custom({
    Expression<int>? singletonKey,
    Expression<String>? personaId,
    Expression<String>? personaName,
    Expression<String>? avatarSeed,
    Expression<String>? tone,
    Expression<String>? customInstructions,
    Expression<String>? reactionLength,
  }) {
    return RawValuesInsertable({
      if (singletonKey != null) 'singleton_key': singletonKey,
      if (personaId != null) 'persona_id': personaId,
      if (personaName != null) 'persona_name': personaName,
      if (avatarSeed != null) 'avatar_seed': avatarSeed,
      if (tone != null) 'tone': tone,
      if (customInstructions != null) 'custom_instructions': customInstructions,
      if (reactionLength != null) 'reaction_length': reactionLength,
    });
  }

  AiPersonaRecordsCompanion copyWith({
    Value<int>? singletonKey,
    Value<String>? personaId,
    Value<String>? personaName,
    Value<String>? avatarSeed,
    Value<String>? tone,
    Value<String>? customInstructions,
    Value<String>? reactionLength,
  }) {
    return AiPersonaRecordsCompanion(
      singletonKey: singletonKey ?? this.singletonKey,
      personaId: personaId ?? this.personaId,
      personaName: personaName ?? this.personaName,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      tone: tone ?? this.tone,
      customInstructions: customInstructions ?? this.customInstructions,
      reactionLength: reactionLength ?? this.reactionLength,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonKey.present) {
      map['singleton_key'] = Variable<int>(singletonKey.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (personaName.present) {
      map['persona_name'] = Variable<String>(personaName.value);
    }
    if (avatarSeed.present) {
      map['avatar_seed'] = Variable<String>(avatarSeed.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(tone.value);
    }
    if (customInstructions.present) {
      map['custom_instructions'] = Variable<String>(customInstructions.value);
    }
    if (reactionLength.present) {
      map['reaction_length'] = Variable<String>(reactionLength.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiPersonaRecordsCompanion(')
          ..write('singletonKey: $singletonKey, ')
          ..write('personaId: $personaId, ')
          ..write('personaName: $personaName, ')
          ..write('avatarSeed: $avatarSeed, ')
          ..write('tone: $tone, ')
          ..write('customInstructions: $customInstructions, ')
          ..write('reactionLength: $reactionLength')
          ..write(')'))
        .toString();
  }
}

class $MemoryFactRecordsTable extends MemoryFactRecords
    with TableInfo<$MemoryFactRecordsTable, MemoryFactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryFactRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factMeta = const VerificationMeta('fact');
  @override
  late final GeneratedColumn<String> fact = GeneratedColumn<String>(
    'fact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdsSchemaVersionMeta =
      const VerificationMeta('sourceIdsSchemaVersion');
  @override
  late final GeneratedColumn<int> sourceIdsSchemaVersion = GeneratedColumn<int>(
    'source_ids_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdsJsonMeta = const VerificationMeta(
    'sourceIdsJson',
  );
  @override
  late final GeneratedColumn<String> sourceIdsJson = GeneratedColumn<String>(
    'source_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensitivityMeta = const VerificationMeta(
    'sensitivity',
  );
  @override
  late final GeneratedColumn<String> sensitivity = GeneratedColumn<String>(
    'sensitivity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<int> createdAtUtc = GeneratedColumn<int>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtc = GeneratedColumn<int>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fact,
    sourceIdsSchemaVersion,
    sourceIdsJson,
    category,
    sensitivity,
    status,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryFactRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fact')) {
      context.handle(
        _factMeta,
        fact.isAcceptableOrUnknown(data['fact']!, _factMeta),
      );
    } else if (isInserting) {
      context.missing(_factMeta);
    }
    if (data.containsKey('source_ids_schema_version')) {
      context.handle(
        _sourceIdsSchemaVersionMeta,
        sourceIdsSchemaVersion.isAcceptableOrUnknown(
          data['source_ids_schema_version']!,
          _sourceIdsSchemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceIdsSchemaVersionMeta);
    }
    if (data.containsKey('source_ids_json')) {
      context.handle(
        _sourceIdsJsonMeta,
        sourceIdsJson.isAcceptableOrUnknown(
          data['source_ids_json']!,
          _sourceIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceIdsJsonMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('sensitivity')) {
      context.handle(
        _sensitivityMeta,
        sensitivity.isAcceptableOrUnknown(
          data['sensitivity']!,
          _sensitivityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensitivityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryFactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryFactRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fact'],
      )!,
      sourceIdsSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_ids_schema_version'],
      )!,
      sourceIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ids_json'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      sensitivity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensitivity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $MemoryFactRecordsTable createAlias(String alias) {
    return $MemoryFactRecordsTable(attachedDatabase, alias);
  }
}

class MemoryFactRow extends DataClass implements Insertable<MemoryFactRow> {
  final String id;
  final String fact;
  final int sourceIdsSchemaVersion;
  final String sourceIdsJson;
  final String category;
  final String sensitivity;
  final String status;
  final int createdAtUtc;
  final int updatedAtUtc;
  const MemoryFactRow({
    required this.id,
    required this.fact,
    required this.sourceIdsSchemaVersion,
    required this.sourceIdsJson,
    required this.category,
    required this.sensitivity,
    required this.status,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fact'] = Variable<String>(fact);
    map['source_ids_schema_version'] = Variable<int>(sourceIdsSchemaVersion);
    map['source_ids_json'] = Variable<String>(sourceIdsJson);
    map['category'] = Variable<String>(category);
    map['sensitivity'] = Variable<String>(sensitivity);
    map['status'] = Variable<String>(status);
    map['created_at_utc'] = Variable<int>(createdAtUtc);
    map['updated_at_utc'] = Variable<int>(updatedAtUtc);
    return map;
  }

  MemoryFactRecordsCompanion toCompanion(bool nullToAbsent) {
    return MemoryFactRecordsCompanion(
      id: Value(id),
      fact: Value(fact),
      sourceIdsSchemaVersion: Value(sourceIdsSchemaVersion),
      sourceIdsJson: Value(sourceIdsJson),
      category: Value(category),
      sensitivity: Value(sensitivity),
      status: Value(status),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory MemoryFactRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryFactRow(
      id: serializer.fromJson<String>(json['id']),
      fact: serializer.fromJson<String>(json['fact']),
      sourceIdsSchemaVersion: serializer.fromJson<int>(
        json['sourceIdsSchemaVersion'],
      ),
      sourceIdsJson: serializer.fromJson<String>(json['sourceIdsJson']),
      category: serializer.fromJson<String>(json['category']),
      sensitivity: serializer.fromJson<String>(json['sensitivity']),
      status: serializer.fromJson<String>(json['status']),
      createdAtUtc: serializer.fromJson<int>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<int>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fact': serializer.toJson<String>(fact),
      'sourceIdsSchemaVersion': serializer.toJson<int>(sourceIdsSchemaVersion),
      'sourceIdsJson': serializer.toJson<String>(sourceIdsJson),
      'category': serializer.toJson<String>(category),
      'sensitivity': serializer.toJson<String>(sensitivity),
      'status': serializer.toJson<String>(status),
      'createdAtUtc': serializer.toJson<int>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<int>(updatedAtUtc),
    };
  }

  MemoryFactRow copyWith({
    String? id,
    String? fact,
    int? sourceIdsSchemaVersion,
    String? sourceIdsJson,
    String? category,
    String? sensitivity,
    String? status,
    int? createdAtUtc,
    int? updatedAtUtc,
  }) => MemoryFactRow(
    id: id ?? this.id,
    fact: fact ?? this.fact,
    sourceIdsSchemaVersion:
        sourceIdsSchemaVersion ?? this.sourceIdsSchemaVersion,
    sourceIdsJson: sourceIdsJson ?? this.sourceIdsJson,
    category: category ?? this.category,
    sensitivity: sensitivity ?? this.sensitivity,
    status: status ?? this.status,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  MemoryFactRow copyWithCompanion(MemoryFactRecordsCompanion data) {
    return MemoryFactRow(
      id: data.id.present ? data.id.value : this.id,
      fact: data.fact.present ? data.fact.value : this.fact,
      sourceIdsSchemaVersion: data.sourceIdsSchemaVersion.present
          ? data.sourceIdsSchemaVersion.value
          : this.sourceIdsSchemaVersion,
      sourceIdsJson: data.sourceIdsJson.present
          ? data.sourceIdsJson.value
          : this.sourceIdsJson,
      category: data.category.present ? data.category.value : this.category,
      sensitivity: data.sensitivity.present
          ? data.sensitivity.value
          : this.sensitivity,
      status: data.status.present ? data.status.value : this.status,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryFactRow(')
          ..write('id: $id, ')
          ..write('fact: $fact, ')
          ..write('sourceIdsSchemaVersion: $sourceIdsSchemaVersion, ')
          ..write('sourceIdsJson: $sourceIdsJson, ')
          ..write('category: $category, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('status: $status, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fact,
    sourceIdsSchemaVersion,
    sourceIdsJson,
    category,
    sensitivity,
    status,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryFactRow &&
          other.id == this.id &&
          other.fact == this.fact &&
          other.sourceIdsSchemaVersion == this.sourceIdsSchemaVersion &&
          other.sourceIdsJson == this.sourceIdsJson &&
          other.category == this.category &&
          other.sensitivity == this.sensitivity &&
          other.status == this.status &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class MemoryFactRecordsCompanion extends UpdateCompanion<MemoryFactRow> {
  final Value<String> id;
  final Value<String> fact;
  final Value<int> sourceIdsSchemaVersion;
  final Value<String> sourceIdsJson;
  final Value<String> category;
  final Value<String> sensitivity;
  final Value<String> status;
  final Value<int> createdAtUtc;
  final Value<int> updatedAtUtc;
  final Value<int> rowid;
  const MemoryFactRecordsCompanion({
    this.id = const Value.absent(),
    this.fact = const Value.absent(),
    this.sourceIdsSchemaVersion = const Value.absent(),
    this.sourceIdsJson = const Value.absent(),
    this.category = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryFactRecordsCompanion.insert({
    required String id,
    required String fact,
    required int sourceIdsSchemaVersion,
    required String sourceIdsJson,
    required String category,
    required String sensitivity,
    required String status,
    required int createdAtUtc,
    required int updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fact = Value(fact),
       sourceIdsSchemaVersion = Value(sourceIdsSchemaVersion),
       sourceIdsJson = Value(sourceIdsJson),
       category = Value(category),
       sensitivity = Value(sensitivity),
       status = Value(status),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<MemoryFactRow> custom({
    Expression<String>? id,
    Expression<String>? fact,
    Expression<int>? sourceIdsSchemaVersion,
    Expression<String>? sourceIdsJson,
    Expression<String>? category,
    Expression<String>? sensitivity,
    Expression<String>? status,
    Expression<int>? createdAtUtc,
    Expression<int>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fact != null) 'fact': fact,
      if (sourceIdsSchemaVersion != null)
        'source_ids_schema_version': sourceIdsSchemaVersion,
      if (sourceIdsJson != null) 'source_ids_json': sourceIdsJson,
      if (category != null) 'category': category,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (status != null) 'status': status,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryFactRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? fact,
    Value<int>? sourceIdsSchemaVersion,
    Value<String>? sourceIdsJson,
    Value<String>? category,
    Value<String>? sensitivity,
    Value<String>? status,
    Value<int>? createdAtUtc,
    Value<int>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return MemoryFactRecordsCompanion(
      id: id ?? this.id,
      fact: fact ?? this.fact,
      sourceIdsSchemaVersion:
          sourceIdsSchemaVersion ?? this.sourceIdsSchemaVersion,
      sourceIdsJson: sourceIdsJson ?? this.sourceIdsJson,
      category: category ?? this.category,
      sensitivity: sensitivity ?? this.sensitivity,
      status: status ?? this.status,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fact.present) {
      map['fact'] = Variable<String>(fact.value);
    }
    if (sourceIdsSchemaVersion.present) {
      map['source_ids_schema_version'] = Variable<int>(
        sourceIdsSchemaVersion.value,
      );
    }
    if (sourceIdsJson.present) {
      map['source_ids_json'] = Variable<String>(sourceIdsJson.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sensitivity.present) {
      map['sensitivity'] = Variable<String>(sensitivity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<int>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<int>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryFactRecordsCompanion(')
          ..write('id: $id, ')
          ..write('fact: $fact, ')
          ..write('sourceIdsSchemaVersion: $sourceIdsSchemaVersion, ')
          ..write('sourceIdsJson: $sourceIdsJson, ')
          ..write('category: $category, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('status: $status, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessageRecordsTable messageRecords = $MessageRecordsTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $MediaAssetRecordsTable mediaAssetRecords =
      $MediaAssetRecordsTable(this);
  late final $AiPersonaRecordsTable aiPersonaRecords = $AiPersonaRecordsTable(
    this,
  );
  late final $MemoryFactRecordsTable memoryFactRecords =
      $MemoryFactRecordsTable(this);
  late final Index messagesDayCreatedAtIdIdx = Index(
    'messages_day_created_at_id_idx',
    'CREATE INDEX messages_day_created_at_id_idx ON messages (day_year, day_month, day_day, day_time_zone_id, day_cutoff_micros, day_policy_version, created_at_utc, id)',
  );
  late final Index diaryEntriesDayVersionIdx = Index(
    'diary_entries_day_version_idx',
    'CREATE INDEX diary_entries_day_version_idx ON diary_entries (day_year, day_month, day_day, day_time_zone_id, day_cutoff_micros, day_policy_version, version DESC)',
  );
  late final Index diaryEntriesUpdatedAtIdIdx = Index(
    'diary_entries_updated_at_id_idx',
    'CREATE INDEX diary_entries_updated_at_id_idx ON diary_entries (updated_at_utc DESC, id)',
  );
  late final Index mediaAssetsDayCreatedAtIdIdx = Index(
    'media_assets_day_created_at_id_idx',
    'CREATE INDEX media_assets_day_created_at_id_idx ON media_assets (day_year, day_month, day_day, day_time_zone_id, day_cutoff_micros, day_policy_version, created_at_utc, id)',
  );
  late final Index memoryFactsUpdatedAtIdIdx = Index(
    'memory_facts_updated_at_id_idx',
    'CREATE INDEX memory_facts_updated_at_id_idx ON memory_facts (updated_at_utc DESC, id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messageRecords,
    diaryEntries,
    mediaAssetRecords,
    aiPersonaRecords,
    memoryFactRecords,
    messagesDayCreatedAtIdIdx,
    diaryEntriesDayVersionIdx,
    diaryEntriesUpdatedAtIdIdx,
    mediaAssetsDayCreatedAtIdIdx,
    memoryFactsUpdatedAtIdIdx,
  ];
}

typedef $$MessageRecordsTableCreateCompanionBuilder =
    MessageRecordsCompanion Function({
      required String id,
      required String requestId,
      required int dayYear,
      required int dayMonth,
      required int dayDay,
      required String dayTimeZoneId,
      required int dayCutoffMicros,
      required int dayPolicyVersion,
      required String role,
      Value<String?> messageText,
      Value<String?> photoAssetId,
      required int createdAtUtc,
      required String status,
      Value<int> rowid,
    });
typedef $$MessageRecordsTableUpdateCompanionBuilder =
    MessageRecordsCompanion Function({
      Value<String> id,
      Value<String> requestId,
      Value<int> dayYear,
      Value<int> dayMonth,
      Value<int> dayDay,
      Value<String> dayTimeZoneId,
      Value<int> dayCutoffMicros,
      Value<int> dayPolicyVersion,
      Value<String> role,
      Value<String?> messageText,
      Value<String?> photoAssetId,
      Value<int> createdAtUtc,
      Value<String> status,
      Value<int> rowid,
    });

class $$MessageRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MessageRecordsTable> {
  $$MessageRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayYear => $composableBuilder(
    column: $table.dayYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayMonth => $composableBuilder(
    column: $table.dayMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayDay => $composableBuilder(
    column: $table.dayDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoAssetId => $composableBuilder(
    column: $table.photoAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageRecordsTable> {
  $$MessageRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayYear => $composableBuilder(
    column: $table.dayYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayMonth => $composableBuilder(
    column: $table.dayMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayDay => $composableBuilder(
    column: $table.dayDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoAssetId => $composableBuilder(
    column: $table.photoAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageRecordsTable> {
  $$MessageRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<int> get dayYear =>
      $composableBuilder(column: $table.dayYear, builder: (column) => column);

  GeneratedColumn<int> get dayMonth =>
      $composableBuilder(column: $table.dayMonth, builder: (column) => column);

  GeneratedColumn<int> get dayDay =>
      $composableBuilder(column: $table.dayDay, builder: (column) => column);

  GeneratedColumn<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoAssetId => $composableBuilder(
    column: $table.photoAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$MessageRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageRecordsTable,
          MessageRow,
          $$MessageRecordsTableFilterComposer,
          $$MessageRecordsTableOrderingComposer,
          $$MessageRecordsTableAnnotationComposer,
          $$MessageRecordsTableCreateCompanionBuilder,
          $$MessageRecordsTableUpdateCompanionBuilder,
          (
            MessageRow,
            BaseReferences<_$AppDatabase, $MessageRecordsTable, MessageRow>,
          ),
          MessageRow,
          PrefetchHooks Function()
        > {
  $$MessageRecordsTableTableManager(
    _$AppDatabase db,
    $MessageRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<int> dayYear = const Value.absent(),
                Value<int> dayMonth = const Value.absent(),
                Value<int> dayDay = const Value.absent(),
                Value<String> dayTimeZoneId = const Value.absent(),
                Value<int> dayCutoffMicros = const Value.absent(),
                Value<int> dayPolicyVersion = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> messageText = const Value.absent(),
                Value<String?> photoAssetId = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageRecordsCompanion(
                id: id,
                requestId: requestId,
                dayYear: dayYear,
                dayMonth: dayMonth,
                dayDay: dayDay,
                dayTimeZoneId: dayTimeZoneId,
                dayCutoffMicros: dayCutoffMicros,
                dayPolicyVersion: dayPolicyVersion,
                role: role,
                messageText: messageText,
                photoAssetId: photoAssetId,
                createdAtUtc: createdAtUtc,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String requestId,
                required int dayYear,
                required int dayMonth,
                required int dayDay,
                required String dayTimeZoneId,
                required int dayCutoffMicros,
                required int dayPolicyVersion,
                required String role,
                Value<String?> messageText = const Value.absent(),
                Value<String?> photoAssetId = const Value.absent(),
                required int createdAtUtc,
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => MessageRecordsCompanion.insert(
                id: id,
                requestId: requestId,
                dayYear: dayYear,
                dayMonth: dayMonth,
                dayDay: dayDay,
                dayTimeZoneId: dayTimeZoneId,
                dayCutoffMicros: dayCutoffMicros,
                dayPolicyVersion: dayPolicyVersion,
                role: role,
                messageText: messageText,
                photoAssetId: photoAssetId,
                createdAtUtc: createdAtUtc,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessageRecordsTable, MessageRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MessageRecordsTable,
                    MessageRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageRecordsTable,
      MessageRow,
      $$MessageRecordsTableFilterComposer,
      $$MessageRecordsTableOrderingComposer,
      $$MessageRecordsTableAnnotationComposer,
      $$MessageRecordsTableCreateCompanionBuilder,
      $$MessageRecordsTableUpdateCompanionBuilder,
      (
        MessageRow,
        BaseReferences<_$AppDatabase, $MessageRecordsTable, MessageRow>,
      ),
      MessageRow,
      PrefetchHooks Function()
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      required String id,
      required int dayYear,
      required int dayMonth,
      required int dayDay,
      required String dayTimeZoneId,
      required int dayCutoffMicros,
      required int dayPolicyVersion,
      required int version,
      required String status,
      required int snapshotSchemaVersion,
      required String snapshotJson,
      required String generationId,
      required int generatedAtUtc,
      required int updatedAtUtc,
      Value<int> rowid,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<String> id,
      Value<int> dayYear,
      Value<int> dayMonth,
      Value<int> dayDay,
      Value<String> dayTimeZoneId,
      Value<int> dayCutoffMicros,
      Value<int> dayPolicyVersion,
      Value<int> version,
      Value<String> status,
      Value<int> snapshotSchemaVersion,
      Value<String> snapshotJson,
      Value<String> generationId,
      Value<int> generatedAtUtc,
      Value<int> updatedAtUtc,
      Value<int> rowid,
    });

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayYear => $composableBuilder(
    column: $table.dayYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayMonth => $composableBuilder(
    column: $table.dayMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayDay => $composableBuilder(
    column: $table.dayDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snapshotSchemaVersion => $composableBuilder(
    column: $table.snapshotSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generatedAtUtc => $composableBuilder(
    column: $table.generatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayYear => $composableBuilder(
    column: $table.dayYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayMonth => $composableBuilder(
    column: $table.dayMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayDay => $composableBuilder(
    column: $table.dayDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snapshotSchemaVersion => $composableBuilder(
    column: $table.snapshotSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generatedAtUtc => $composableBuilder(
    column: $table.generatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayYear =>
      $composableBuilder(column: $table.dayYear, builder: (column) => column);

  GeneratedColumn<int> get dayMonth =>
      $composableBuilder(column: $table.dayMonth, builder: (column) => column);

  GeneratedColumn<int> get dayDay =>
      $composableBuilder(column: $table.dayDay, builder: (column) => column);

  GeneratedColumn<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get snapshotSchemaVersion => $composableBuilder(
    column: $table.snapshotSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get generationId => $composableBuilder(
    column: $table.generationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get generatedAtUtc => $composableBuilder(
    column: $table.generatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntryRow,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (
            DiaryEntryRow,
            BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntryRow>,
          ),
          DiaryEntryRow,
          PrefetchHooks Function()
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> dayYear = const Value.absent(),
                Value<int> dayMonth = const Value.absent(),
                Value<int> dayDay = const Value.absent(),
                Value<String> dayTimeZoneId = const Value.absent(),
                Value<int> dayCutoffMicros = const Value.absent(),
                Value<int> dayPolicyVersion = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> snapshotSchemaVersion = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<String> generationId = const Value.absent(),
                Value<int> generatedAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                dayYear: dayYear,
                dayMonth: dayMonth,
                dayDay: dayDay,
                dayTimeZoneId: dayTimeZoneId,
                dayCutoffMicros: dayCutoffMicros,
                dayPolicyVersion: dayPolicyVersion,
                version: version,
                status: status,
                snapshotSchemaVersion: snapshotSchemaVersion,
                snapshotJson: snapshotJson,
                generationId: generationId,
                generatedAtUtc: generatedAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int dayYear,
                required int dayMonth,
                required int dayDay,
                required String dayTimeZoneId,
                required int dayCutoffMicros,
                required int dayPolicyVersion,
                required int version,
                required String status,
                required int snapshotSchemaVersion,
                required String snapshotJson,
                required String generationId,
                required int generatedAtUtc,
                required int updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => DiaryEntriesCompanion.insert(
                id: id,
                dayYear: dayYear,
                dayMonth: dayMonth,
                dayDay: dayDay,
                dayTimeZoneId: dayTimeZoneId,
                dayCutoffMicros: dayCutoffMicros,
                dayPolicyVersion: dayPolicyVersion,
                version: version,
                status: status,
                snapshotSchemaVersion: snapshotSchemaVersion,
                snapshotJson: snapshotJson,
                generationId: generationId,
                generatedAtUtc: generatedAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiaryEntriesTable, DiaryEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DiaryEntriesTable,
                    DiaryEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntryRow,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (
        DiaryEntryRow,
        BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntryRow>,
      ),
      DiaryEntryRow,
      PrefetchHooks Function()
    >;
typedef $$MediaAssetRecordsTableCreateCompanionBuilder =
    MediaAssetRecordsCompanion Function({
      required String id,
      required int dayYear,
      required int dayMonth,
      required int dayDay,
      required String dayTimeZoneId,
      required int dayCutoffMicros,
      required int dayPolicyVersion,
      required String storageKey,
      required String mimeType,
      required int byteLength,
      required int createdAtUtc,
      required String lifecycle,
      Value<int> rowid,
    });
typedef $$MediaAssetRecordsTableUpdateCompanionBuilder =
    MediaAssetRecordsCompanion Function({
      Value<String> id,
      Value<int> dayYear,
      Value<int> dayMonth,
      Value<int> dayDay,
      Value<String> dayTimeZoneId,
      Value<int> dayCutoffMicros,
      Value<int> dayPolicyVersion,
      Value<String> storageKey,
      Value<String> mimeType,
      Value<int> byteLength,
      Value<int> createdAtUtc,
      Value<String> lifecycle,
      Value<int> rowid,
    });

class $$MediaAssetRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaAssetRecordsTable> {
  $$MediaAssetRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayYear => $composableBuilder(
    column: $table.dayYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayMonth => $composableBuilder(
    column: $table.dayMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayDay => $composableBuilder(
    column: $table.dayDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaAssetRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaAssetRecordsTable> {
  $$MediaAssetRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayYear => $composableBuilder(
    column: $table.dayYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayMonth => $composableBuilder(
    column: $table.dayMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayDay => $composableBuilder(
    column: $table.dayDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaAssetRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaAssetRecordsTable> {
  $$MediaAssetRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayYear =>
      $composableBuilder(column: $table.dayYear, builder: (column) => column);

  GeneratedColumn<int> get dayMonth =>
      $composableBuilder(column: $table.dayMonth, builder: (column) => column);

  GeneratedColumn<int> get dayDay =>
      $composableBuilder(column: $table.dayDay, builder: (column) => column);

  GeneratedColumn<String> get dayTimeZoneId => $composableBuilder(
    column: $table.dayTimeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayCutoffMicros => $composableBuilder(
    column: $table.dayCutoffMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayPolicyVersion => $composableBuilder(
    column: $table.dayPolicyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);
}

class $$MediaAssetRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaAssetRecordsTable,
          MediaAssetRow,
          $$MediaAssetRecordsTableFilterComposer,
          $$MediaAssetRecordsTableOrderingComposer,
          $$MediaAssetRecordsTableAnnotationComposer,
          $$MediaAssetRecordsTableCreateCompanionBuilder,
          $$MediaAssetRecordsTableUpdateCompanionBuilder,
          (
            MediaAssetRow,
            BaseReferences<
              _$AppDatabase,
              $MediaAssetRecordsTable,
              MediaAssetRow
            >,
          ),
          MediaAssetRow,
          PrefetchHooks Function()
        > {
  $$MediaAssetRecordsTableTableManager(
    _$AppDatabase db,
    $MediaAssetRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAssetRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAssetRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAssetRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> dayYear = const Value.absent(),
                Value<int> dayMonth = const Value.absent(),
                Value<int> dayDay = const Value.absent(),
                Value<String> dayTimeZoneId = const Value.absent(),
                Value<int> dayCutoffMicros = const Value.absent(),
                Value<int> dayPolicyVersion = const Value.absent(),
                Value<String> storageKey = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> byteLength = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetRecordsCompanion(
                id: id,
                dayYear: dayYear,
                dayMonth: dayMonth,
                dayDay: dayDay,
                dayTimeZoneId: dayTimeZoneId,
                dayCutoffMicros: dayCutoffMicros,
                dayPolicyVersion: dayPolicyVersion,
                storageKey: storageKey,
                mimeType: mimeType,
                byteLength: byteLength,
                createdAtUtc: createdAtUtc,
                lifecycle: lifecycle,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int dayYear,
                required int dayMonth,
                required int dayDay,
                required String dayTimeZoneId,
                required int dayCutoffMicros,
                required int dayPolicyVersion,
                required String storageKey,
                required String mimeType,
                required int byteLength,
                required int createdAtUtc,
                required String lifecycle,
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetRecordsCompanion.insert(
                id: id,
                dayYear: dayYear,
                dayMonth: dayMonth,
                dayDay: dayDay,
                dayTimeZoneId: dayTimeZoneId,
                dayCutoffMicros: dayCutoffMicros,
                dayPolicyVersion: dayPolicyVersion,
                storageKey: storageKey,
                mimeType: mimeType,
                byteLength: byteLength,
                createdAtUtc: createdAtUtc,
                lifecycle: lifecycle,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaAssetRecordsTable, MediaAssetRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MediaAssetRecordsTable,
                    MediaAssetRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaAssetRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaAssetRecordsTable,
      MediaAssetRow,
      $$MediaAssetRecordsTableFilterComposer,
      $$MediaAssetRecordsTableOrderingComposer,
      $$MediaAssetRecordsTableAnnotationComposer,
      $$MediaAssetRecordsTableCreateCompanionBuilder,
      $$MediaAssetRecordsTableUpdateCompanionBuilder,
      (
        MediaAssetRow,
        BaseReferences<_$AppDatabase, $MediaAssetRecordsTable, MediaAssetRow>,
      ),
      MediaAssetRow,
      PrefetchHooks Function()
    >;
typedef $$AiPersonaRecordsTableCreateCompanionBuilder =
    AiPersonaRecordsCompanion Function({
      Value<int> singletonKey,
      required String personaId,
      required String personaName,
      required String avatarSeed,
      required String tone,
      required String customInstructions,
      required String reactionLength,
    });
typedef $$AiPersonaRecordsTableUpdateCompanionBuilder =
    AiPersonaRecordsCompanion Function({
      Value<int> singletonKey,
      Value<String> personaId,
      Value<String> personaName,
      Value<String> avatarSeed,
      Value<String> tone,
      Value<String> customInstructions,
      Value<String> reactionLength,
    });

class $$AiPersonaRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AiPersonaRecordsTable> {
  $$AiPersonaRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personaId => $composableBuilder(
    column: $table.personaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personaName => $composableBuilder(
    column: $table.personaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarSeed => $composableBuilder(
    column: $table.avatarSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customInstructions => $composableBuilder(
    column: $table.customInstructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactionLength => $composableBuilder(
    column: $table.reactionLength,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiPersonaRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiPersonaRecordsTable> {
  $$AiPersonaRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personaId => $composableBuilder(
    column: $table.personaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personaName => $composableBuilder(
    column: $table.personaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarSeed => $composableBuilder(
    column: $table.avatarSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customInstructions => $composableBuilder(
    column: $table.customInstructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactionLength => $composableBuilder(
    column: $table.reactionLength,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiPersonaRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiPersonaRecordsTable> {
  $$AiPersonaRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personaId =>
      $composableBuilder(column: $table.personaId, builder: (column) => column);

  GeneratedColumn<String> get personaName => $composableBuilder(
    column: $table.personaName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarSeed => $composableBuilder(
    column: $table.avatarSeed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<String> get customInstructions => $composableBuilder(
    column: $table.customInstructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reactionLength => $composableBuilder(
    column: $table.reactionLength,
    builder: (column) => column,
  );
}

class $$AiPersonaRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiPersonaRecordsTable,
          AiPersonaRow,
          $$AiPersonaRecordsTableFilterComposer,
          $$AiPersonaRecordsTableOrderingComposer,
          $$AiPersonaRecordsTableAnnotationComposer,
          $$AiPersonaRecordsTableCreateCompanionBuilder,
          $$AiPersonaRecordsTableUpdateCompanionBuilder,
          (
            AiPersonaRow,
            BaseReferences<_$AppDatabase, $AiPersonaRecordsTable, AiPersonaRow>,
          ),
          AiPersonaRow,
          PrefetchHooks Function()
        > {
  $$AiPersonaRecordsTableTableManager(
    _$AppDatabase db,
    $AiPersonaRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiPersonaRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiPersonaRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiPersonaRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                Value<String> personaId = const Value.absent(),
                Value<String> personaName = const Value.absent(),
                Value<String> avatarSeed = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<String> customInstructions = const Value.absent(),
                Value<String> reactionLength = const Value.absent(),
              }) => AiPersonaRecordsCompanion(
                singletonKey: singletonKey,
                personaId: personaId,
                personaName: personaName,
                avatarSeed: avatarSeed,
                tone: tone,
                customInstructions: customInstructions,
                reactionLength: reactionLength,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                required String personaId,
                required String personaName,
                required String avatarSeed,
                required String tone,
                required String customInstructions,
                required String reactionLength,
              }) => AiPersonaRecordsCompanion.insert(
                singletonKey: singletonKey,
                personaId: personaId,
                personaName: personaName,
                avatarSeed: avatarSeed,
                tone: tone,
                customInstructions: customInstructions,
                reactionLength: reactionLength,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiPersonaRecordsTable, AiPersonaRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AiPersonaRecordsTable,
                    AiPersonaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiPersonaRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiPersonaRecordsTable,
      AiPersonaRow,
      $$AiPersonaRecordsTableFilterComposer,
      $$AiPersonaRecordsTableOrderingComposer,
      $$AiPersonaRecordsTableAnnotationComposer,
      $$AiPersonaRecordsTableCreateCompanionBuilder,
      $$AiPersonaRecordsTableUpdateCompanionBuilder,
      (
        AiPersonaRow,
        BaseReferences<_$AppDatabase, $AiPersonaRecordsTable, AiPersonaRow>,
      ),
      AiPersonaRow,
      PrefetchHooks Function()
    >;
typedef $$MemoryFactRecordsTableCreateCompanionBuilder =
    MemoryFactRecordsCompanion Function({
      required String id,
      required String fact,
      required int sourceIdsSchemaVersion,
      required String sourceIdsJson,
      required String category,
      required String sensitivity,
      required String status,
      required int createdAtUtc,
      required int updatedAtUtc,
      Value<int> rowid,
    });
typedef $$MemoryFactRecordsTableUpdateCompanionBuilder =
    MemoryFactRecordsCompanion Function({
      Value<String> id,
      Value<String> fact,
      Value<int> sourceIdsSchemaVersion,
      Value<String> sourceIdsJson,
      Value<String> category,
      Value<String> sensitivity,
      Value<String> status,
      Value<int> createdAtUtc,
      Value<int> updatedAtUtc,
      Value<int> rowid,
    });

class $$MemoryFactRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryFactRecordsTable> {
  $$MemoryFactRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fact => $composableBuilder(
    column: $table.fact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceIdsSchemaVersion => $composableBuilder(
    column: $table.sourceIdsSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoryFactRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryFactRecordsTable> {
  $$MemoryFactRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fact => $composableBuilder(
    column: $table.fact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceIdsSchemaVersion => $composableBuilder(
    column: $table.sourceIdsSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryFactRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryFactRecordsTable> {
  $$MemoryFactRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fact =>
      $composableBuilder(column: $table.fact, builder: (column) => column);

  GeneratedColumn<int> get sourceIdsSchemaVersion => $composableBuilder(
    column: $table.sourceIdsSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$MemoryFactRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryFactRecordsTable,
          MemoryFactRow,
          $$MemoryFactRecordsTableFilterComposer,
          $$MemoryFactRecordsTableOrderingComposer,
          $$MemoryFactRecordsTableAnnotationComposer,
          $$MemoryFactRecordsTableCreateCompanionBuilder,
          $$MemoryFactRecordsTableUpdateCompanionBuilder,
          (
            MemoryFactRow,
            BaseReferences<
              _$AppDatabase,
              $MemoryFactRecordsTable,
              MemoryFactRow
            >,
          ),
          MemoryFactRow,
          PrefetchHooks Function()
        > {
  $$MemoryFactRecordsTableTableManager(
    _$AppDatabase db,
    $MemoryFactRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryFactRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryFactRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryFactRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fact = const Value.absent(),
                Value<int> sourceIdsSchemaVersion = const Value.absent(),
                Value<String> sourceIdsJson = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> sensitivity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAtUtc = const Value.absent(),
                Value<int> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryFactRecordsCompanion(
                id: id,
                fact: fact,
                sourceIdsSchemaVersion: sourceIdsSchemaVersion,
                sourceIdsJson: sourceIdsJson,
                category: category,
                sensitivity: sensitivity,
                status: status,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fact,
                required int sourceIdsSchemaVersion,
                required String sourceIdsJson,
                required String category,
                required String sensitivity,
                required String status,
                required int createdAtUtc,
                required int updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => MemoryFactRecordsCompanion.insert(
                id: id,
                fact: fact,
                sourceIdsSchemaVersion: sourceIdsSchemaVersion,
                sourceIdsJson: sourceIdsJson,
                category: category,
                sensitivity: sensitivity,
                status: status,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryFactRecordsTable, MemoryFactRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MemoryFactRecordsTable,
                    MemoryFactRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoryFactRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryFactRecordsTable,
      MemoryFactRow,
      $$MemoryFactRecordsTableFilterComposer,
      $$MemoryFactRecordsTableOrderingComposer,
      $$MemoryFactRecordsTableAnnotationComposer,
      $$MemoryFactRecordsTableCreateCompanionBuilder,
      $$MemoryFactRecordsTableUpdateCompanionBuilder,
      (
        MemoryFactRow,
        BaseReferences<_$AppDatabase, $MemoryFactRecordsTable, MemoryFactRow>,
      ),
      MemoryFactRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessageRecordsTableTableManager get messageRecords =>
      $$MessageRecordsTableTableManager(_db, _db.messageRecords);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$MediaAssetRecordsTableTableManager get mediaAssetRecords =>
      $$MediaAssetRecordsTableTableManager(_db, _db.mediaAssetRecords);
  $$AiPersonaRecordsTableTableManager get aiPersonaRecords =>
      $$AiPersonaRecordsTableTableManager(_db, _db.aiPersonaRecords);
  $$MemoryFactRecordsTableTableManager get memoryFactRecords =>
      $$MemoryFactRecordsTableTableManager(_db, _db.memoryFactRecords);
}
