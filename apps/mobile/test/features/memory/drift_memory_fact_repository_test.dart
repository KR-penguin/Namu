import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/features/memory/data/drift_memory_fact_repository.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';

void main() {
  late AppDatabase database;
  late DriftMemoryFactRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftMemoryFactRepository(database);
  });

  tearDown(() => database.close());

  test('round-trips every memory field and saves by identity', () async {
    final original = _fact(
      category: MemoryCategory.relationship,
      sensitivity: MemorySensitivity.sensitive,
      status: MemoryStatus.candidate,
      sourceMessageIds: const ['message-2', 'message-1'],
    );
    await repository.save(original);
    final edited = original.edit(
      fact: '사용자의 친구 지수는 대학 동기다.',
      updatedAtUtc: DateTime.utc(2026, 10, 4, 12, 3, 4, 567, 890),
    );

    await repository.save(edited);
    final restored = await repository.findById(original.id);

    expect(restored?.id, edited.id);
    expect(restored?.fact, edited.fact);
    expect(restored?.sourceMessageIds, ['message-2', 'message-1']);
    expect(restored?.category, MemoryCategory.relationship);
    expect(restored?.sensitivity, MemorySensitivity.sensitive);
    expect(restored?.status, MemoryStatus.candidate);
    expect(restored?.createdAtUtc, edited.createdAtUtc);
    expect(restored?.updatedAtUtc, edited.updatedAtUtc);
    expect(
      await database.select(database.memoryFactRecords).get(),
      hasLength(1),
    );
  });

  test('listAll orders updated UTC descending then id', () async {
    final sameInstant = DateTime.utc(2026, 10, 4, 12);
    await repository.save(_fact(id: 'memory-b', updatedAtUtc: sameInstant));
    await repository.save(_fact(id: 'memory-a', updatedAtUtc: sameInstant));
    await repository.save(
      _fact(
        id: 'memory-old',
        updatedAtUtc: sameInstant.subtract(const Duration(microseconds: 1)),
      ),
    );

    expect((await repository.listAll()).map((fact) => fact.id), [
      'memory-a',
      'memory-b',
      'memory-old',
    ]);
  });

  test('listBySourceMessageId matches decoded IDs and orders by id', () async {
    await repository.save(
      _fact(id: 'memory-b', sourceMessageIds: const ['shared', 'other']),
    );
    await repository.save(
      _fact(id: 'memory-a', sourceMessageIds: const ['shared']),
    );
    await repository.save(
      _fact(id: 'unrelated', sourceMessageIds: const ['other']),
    );

    expect(
      (await repository.listBySourceMessageId('shared')).map((fact) => fact.id),
      ['memory-a', 'memory-b'],
    );
  });

  test('deleteById is idempotent', () async {
    await repository.save(_fact());

    await repository.deleteById('memory-1');
    await repository.deleteById('memory-1');

    expect(await repository.findById('memory-1'), isNull);
  });
}

MemoryFact _fact({
  String id = 'memory-1',
  String fact = '사용자는 산책을 좋아한다.',
  List<String> sourceMessageIds = const ['message-1'],
  MemoryCategory category = MemoryCategory.preference,
  MemorySensitivity sensitivity = MemorySensitivity.standard,
  MemoryStatus status = MemoryStatus.active,
  DateTime? createdAtUtc,
  DateTime? updatedAtUtc,
}) {
  final created = createdAtUtc ?? DateTime.utc(2026, 10, 4, 10, 1, 2, 345, 678);
  return MemoryFact(
    id: id,
    fact: fact,
    sourceMessageIds: sourceMessageIds,
    category: category,
    sensitivity: sensitivity,
    status: status,
    createdAtUtc: created,
    updatedAtUtc: updatedAtUtc ?? created,
  );
}
