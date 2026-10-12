import 'package:drift/drift.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/features/memory/data/memory_source_ids_json_codec.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact_repository.dart';

final class DriftMemoryFactRepository implements MemoryFactRepository {
  const DriftMemoryFactRepository(this._database);

  static const MemorySourceIdsJsonCodec _sourceIdsCodec =
      MemorySourceIdsJsonCodec();
  final AppDatabase _database;

  @override
  Future<MemoryFact?> findById(String id) async {
    final query = _database.select(_database.memoryFactRecords)
      ..where((row) => row.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<MemoryFact>> listAll() async {
    final query = _database.select(_database.memoryFactRecords)
      ..orderBy([
        (row) => OrderingTerm.desc(row.updatedAtUtc),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return (await query.get()).map(_toDomain).toList(growable: false);
  }

  @override
  Future<List<MemoryFact>> listBySourceMessageId(String sourceMessageId) async {
    final normalized = sourceMessageId.trim();
    if (normalized.isEmpty) {
      return const <MemoryFact>[];
    }
    final facts =
        (await _database.select(_database.memoryFactRecords).get())
            .map(_toDomain)
            .where((fact) => fact.sourceMessageIds.contains(normalized))
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));
    return facts;
  }

  @override
  Future<void> save(MemoryFact fact) async {
    await _database
        .into(_database.memoryFactRecords)
        .insertOnConflictUpdate(
          MemoryFactRecordsCompanion.insert(
            id: fact.id,
            fact: fact.fact,
            sourceIdsSchemaVersion:
                MemorySourceIdsJsonCodec.currentSchemaVersion,
            sourceIdsJson: _sourceIdsCodec.encode(fact.sourceMessageIds),
            category: fact.category.name,
            sensitivity: fact.sensitivity.name,
            status: fact.status.name,
            createdAtUtc: fact.createdAtUtc.microsecondsSinceEpoch,
            updatedAtUtc: fact.updatedAtUtc.microsecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<void> deleteById(String id) async {
    await (_database.delete(
      _database.memoryFactRecords,
    )..where((row) => row.id.equals(id))).go();
  }

  MemoryFact _toDomain(MemoryFactRow row) {
    if (row.sourceIdsSchemaVersion !=
        MemorySourceIdsJsonCodec.currentSchemaVersion) {
      throw FormatException(
        'Unsupported persisted memory source schema: '
        '${row.sourceIdsSchemaVersion}',
      );
    }
    return MemoryFact(
      id: row.id,
      fact: row.fact,
      sourceMessageIds: _sourceIdsCodec.decode(row.sourceIdsJson),
      category: _parseCategory(row.category),
      sensitivity: _parseSensitivity(row.sensitivity),
      status: _parseStatus(row.status),
      createdAtUtc: DateTime.fromMicrosecondsSinceEpoch(
        row.createdAtUtc,
        isUtc: true,
      ),
      updatedAtUtc: DateTime.fromMicrosecondsSinceEpoch(
        row.updatedAtUtc,
        isUtc: true,
      ),
    );
  }

  MemoryCategory _parseCategory(String value) {
    return switch (value) {
      'preference' => MemoryCategory.preference,
      'routine' => MemoryCategory.routine,
      'relationship' => MemoryCategory.relationship,
      'place' => MemoryCategory.place,
      'milestone' => MemoryCategory.milestone,
      'other' => MemoryCategory.other,
      _ => throw FormatException(
        'Unsupported persisted memory category: $value',
      ),
    };
  }

  MemorySensitivity _parseSensitivity(String value) {
    return switch (value) {
      'standard' => MemorySensitivity.standard,
      'sensitive' => MemorySensitivity.sensitive,
      _ => throw FormatException(
        'Unsupported persisted memory sensitivity: $value',
      ),
    };
  }

  MemoryStatus _parseStatus(String value) {
    return switch (value) {
      'candidate' => MemoryStatus.candidate,
      'active' => MemoryStatus.active,
      'inactive' => MemoryStatus.inactive,
      _ => throw FormatException('Unsupported persisted memory status: $value'),
    };
  }
}
