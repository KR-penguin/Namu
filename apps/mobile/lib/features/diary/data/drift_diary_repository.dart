import 'package:drift/drift.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/diary/data/diary_entry_json_codec.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_repository.dart';

final class DriftDiaryRepository implements DiaryRepository {
  const DriftDiaryRepository(this._database);

  final AppDatabase _database;
  static const DiaryEntryJsonCodec _codec = DiaryEntryJsonCodec();

  @override
  Future<DiaryEntry?> findLatestForDay(DiaryDayKey dayKey) async {
    final query = _database.select(_database.diaryEntries)
      ..where((row) => _sameDay(row, dayKey))
      ..orderBy([
        (row) => OrderingTerm.desc(row.version),
        (row) => OrderingTerm.asc(row.id),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<DiaryEntry>> listAll() async {
    final query = _database.select(_database.diaryEntries)
      ..orderBy([
        (row) => OrderingTerm.desc(row.updatedAtUtc),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return (await query.get()).map(_toDomain).toList(growable: false);
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    await _database
        .into(_database.diaryEntries)
        .insertOnConflictUpdate(_toCompanion(entry));
  }

  @override
  Future<void> deleteById(String id) async {
    await (_database.delete(
      _database.diaryEntries,
    )..where((row) => row.id.equals(id))).go();
  }

  @override
  Future<DiaryEntry> createDraftIfAbsent({
    required String generationId,
    required DiaryDayKey dayKey,
    required DiaryDraftBuilder build,
  }) {
    if (generationId.trim().isEmpty) {
      throw ArgumentError.value(
        generationId,
        'generationId',
        'must not be blank',
      );
    }

    return _database.transaction(() async {
      final existingQuery = _database.select(_database.diaryEntries)
        ..where((row) => row.generationId.equals(generationId));
      final existing = await existingQuery.getSingleOrNull();
      if (existing != null) {
        return _toDomain(existing);
      }

      final latestVersionQuery = _database.select(_database.diaryEntries)
        ..where((row) => _sameDay(row, dayKey))
        ..orderBy([(row) => OrderingTerm.desc(row.version)])
        ..limit(1);
      final latest = await latestVersionQuery.getSingleOrNull();
      final nextVersion = (latest?.version ?? 0) + 1;
      final entry = build(nextVersion);
      _validateBuiltDraft(
        entry,
        generationId: generationId,
        dayKey: dayKey,
        version: nextVersion,
      );

      await _database.into(_database.diaryEntries).insert(_toCompanion(entry));
      return entry;
    });
  }

  Expression<bool> _sameDay($DiaryEntriesTable row, DiaryDayKey dayKey) {
    final date = dayKey.labelDate;
    return row.dayYear.equals(date.year) &
        row.dayMonth.equals(date.month) &
        row.dayDay.equals(date.day) &
        row.dayTimeZoneId.equals(dayKey.timeZoneId) &
        row.dayCutoffMicros.equals(dayKey.cutoff.inMicroseconds) &
        row.dayPolicyVersion.equals(dayKey.policyVersion);
  }

  DiaryEntriesCompanion _toCompanion(DiaryEntry entry) {
    return DiaryEntriesCompanion.insert(
      id: entry.id,
      dayYear: entry.dayKey.labelDate.year,
      dayMonth: entry.dayKey.labelDate.month,
      dayDay: entry.dayKey.labelDate.day,
      dayTimeZoneId: entry.dayKey.timeZoneId,
      dayCutoffMicros: entry.dayKey.cutoff.inMicroseconds,
      dayPolicyVersion: entry.dayKey.policyVersion,
      version: entry.version,
      status: entry.status.name,
      snapshotSchemaVersion: DiaryEntryJsonCodec.currentSchemaVersion,
      snapshotJson: _codec.encode(entry),
      generationId: entry.generationId,
      generatedAtUtc: entry.generatedAtUtc.microsecondsSinceEpoch,
      updatedAtUtc: entry.updatedAtUtc.microsecondsSinceEpoch,
    );
  }

  DiaryEntry _toDomain(DiaryEntryRow row) {
    if (row.snapshotSchemaVersion != DiaryEntryJsonCodec.currentSchemaVersion) {
      throw FormatException(
        'Unsupported persisted diary schema: ${row.snapshotSchemaVersion}',
      );
    }
    final entry = _codec.decode(row.snapshotJson);
    final indexedDay = entry.dayKey;
    final indexedFieldsMatch =
        entry.id == row.id &&
        indexedDay.labelDate.year == row.dayYear &&
        indexedDay.labelDate.month == row.dayMonth &&
        indexedDay.labelDate.day == row.dayDay &&
        indexedDay.timeZoneId == row.dayTimeZoneId &&
        indexedDay.cutoff.inMicroseconds == row.dayCutoffMicros &&
        indexedDay.policyVersion == row.dayPolicyVersion &&
        entry.version == row.version &&
        entry.status.name == row.status &&
        entry.generationId == row.generationId &&
        entry.generatedAtUtc.microsecondsSinceEpoch == row.generatedAtUtc &&
        entry.updatedAtUtc.microsecondsSinceEpoch == row.updatedAtUtc;
    if (!indexedFieldsMatch) {
      throw const FormatException(
        'Persisted diary snapshot does not match its indexed fields.',
      );
    }
    return entry;
  }

  void _validateBuiltDraft(
    DiaryEntry entry, {
    required String generationId,
    required DiaryDayKey dayKey,
    required int version,
  }) {
    if (entry.generationId != generationId ||
        entry.dayKey != dayKey ||
        entry.version != version ||
        entry.status != DiaryEntryStatus.draft) {
      throw StateError(
        'Diary draft builder changed generation, day, version, or status.',
      );
    }
  }
}
