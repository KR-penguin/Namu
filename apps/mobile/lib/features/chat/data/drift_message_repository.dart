import 'package:drift/drift.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/chat/domain/message_repository.dart';

final class DriftMessageRepository implements MessageRepository {
  const DriftMessageRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> upsert(Message message) async {
    final companion = _toCompanion(message);

    await _database
        .into(_database.messageRecords)
        .insert(
          companion,
          onConflict: DoUpdate((_) => companion, target: const []),
        );
  }

  @override
  Future<Message?> findUserByRequestId(String requestId) async {
    final query = _database.select(_database.messageRecords)
      ..where(
        (row) =>
            row.requestId.equals(requestId) &
            row.role.equals(MessageRole.user.name),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Message>> listForDay(DiaryDayKey dayKey) async {
    final labelDate = dayKey.labelDate;
    final query = _database.select(_database.messageRecords)
      ..where(
        (row) =>
            row.dayYear.equals(labelDate.year) &
            row.dayMonth.equals(labelDate.month) &
            row.dayDay.equals(labelDate.day) &
            row.dayTimeZoneId.equals(dayKey.timeZoneId) &
            row.dayCutoffMicros.equals(dayKey.cutoff.inMicroseconds) &
            row.dayPolicyVersion.equals(dayKey.policyVersion),
      )
      ..orderBy([
        (row) => OrderingTerm.asc(row.createdAtUtc),
        (row) => OrderingTerm.asc(row.id),
      ]);

    return (await query.get()).map(_toDomain).toList(growable: false);
  }

  @override
  Future<void> recoverInterruptedSendsForDay(DiaryDayKey dayKey) async {
    await _database.transaction(() async {
      final table = _database.messageRecords;
      final labelDate = dayKey.labelDate;
      final pendingQuery = _database.select(table)
        ..where(
          (row) =>
              row.dayYear.equals(labelDate.year) &
              row.dayMonth.equals(labelDate.month) &
              row.dayDay.equals(labelDate.day) &
              row.dayTimeZoneId.equals(dayKey.timeZoneId) &
              row.dayCutoffMicros.equals(dayKey.cutoff.inMicroseconds) &
              row.dayPolicyVersion.equals(dayKey.policyVersion) &
              row.role.equals(MessageRole.user.name) &
              row.status.equals(MessageStatus.pending.name),
        );
      final pendingUsers = await pendingQuery.get();
      if (pendingUsers.isEmpty) {
        return;
      }

      final requestIds = pendingUsers
          .map((message) => message.requestId)
          .toSet();
      final assistantQuery = _database.selectOnly(table)
        ..addColumns([table.requestId])
        ..where(
          table.requestId.isIn(requestIds) &
              table.role.equals(MessageRole.assistant.name) &
              table.status.equals(MessageStatus.sent.name),
        );
      final answeredRequestIds = (await assistantQuery.get())
          .map((row) => row.read(table.requestId)!)
          .toSet();

      for (final message in pendingUsers) {
        final update = _database.update(table)
          ..where(
            (row) =>
                row.id.equals(message.id) &
                row.status.equals(MessageStatus.pending.name),
          );
        await update.write(
          MessageRecordsCompanion(
            status: Value(
              answeredRequestIds.contains(message.requestId)
                  ? MessageStatus.sent.name
                  : MessageStatus.failed.name,
            ),
          ),
        );
      }
    });
  }

  @override
  Future<List<DiaryDayKey>> listDayKeysOldestFirst() async {
    final table = _database.messageRecords;
    final query = _database.selectOnly(table, distinct: true)
      ..addColumns([
        table.dayYear,
        table.dayMonth,
        table.dayDay,
        table.dayTimeZoneId,
        table.dayCutoffMicros,
        table.dayPolicyVersion,
      ])
      ..orderBy([
        OrderingTerm.asc(table.dayYear),
        OrderingTerm.asc(table.dayMonth),
        OrderingTerm.asc(table.dayDay),
        OrderingTerm.asc(table.dayTimeZoneId),
        OrderingTerm.asc(table.dayCutoffMicros),
        OrderingTerm.asc(table.dayPolicyVersion),
      ]);

    return (await query.get())
        .map(
          (row) => DiaryDayKey.restore(
            labelDate: LocalDate(
              row.read(table.dayYear)!,
              row.read(table.dayMonth)!,
              row.read(table.dayDay)!,
            ),
            timeZoneId: row.read(table.dayTimeZoneId)!,
            cutoff: Duration(microseconds: row.read(table.dayCutoffMicros)!),
            policyVersion: row.read(table.dayPolicyVersion)!,
          ),
        )
        .toList(growable: false);
  }

  MessageRecordsCompanion _toCompanion(Message message) {
    return MessageRecordsCompanion.insert(
      id: message.id,
      requestId: message.requestId,
      dayYear: message.dayKey.labelDate.year,
      dayMonth: message.dayKey.labelDate.month,
      dayDay: message.dayKey.labelDate.day,
      dayTimeZoneId: message.dayKey.timeZoneId,
      dayCutoffMicros: message.dayKey.cutoff.inMicroseconds,
      dayPolicyVersion: message.dayKey.policyVersion,
      role: message.role.name,
      messageText: Value(message.text),
      photoAssetId: Value(message.photoAssetId),
      createdAtUtc: message.createdAtUtc.microsecondsSinceEpoch,
      status: message.status.name,
    );
  }

  Message _toDomain(MessageRow row) {
    return Message(
      id: row.id,
      requestId: row.requestId,
      dayKey: DiaryDayKey.restore(
        labelDate: LocalDate(row.dayYear, row.dayMonth, row.dayDay),
        timeZoneId: row.dayTimeZoneId,
        cutoff: Duration(microseconds: row.dayCutoffMicros),
        policyVersion: row.dayPolicyVersion,
      ),
      role: _parseRole(row.role),
      text: row.messageText,
      photoAssetId: row.photoAssetId,
      createdAtUtc: DateTime.fromMicrosecondsSinceEpoch(
        row.createdAtUtc,
        isUtc: true,
      ),
      status: _parseStatus(row.status),
    );
  }

  MessageRole _parseRole(String value) {
    return switch (value) {
      'user' => MessageRole.user,
      'assistant' => MessageRole.assistant,
      _ => throw FormatException('Unsupported persisted message role: $value'),
    };
  }

  MessageStatus _parseStatus(String value) {
    return switch (value) {
      'pending' => MessageStatus.pending,
      'sent' => MessageStatus.sent,
      'failed' => MessageStatus.failed,
      _ => throw FormatException(
        'Unsupported persisted message status: $value',
      ),
    };
  }
}
