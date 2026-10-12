import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/memory/data/in_memory_memory_fact_repository.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';

void main() {
  test('saves by identity and lists newest updates first', () async {
    final repository = InMemoryMemoryFactRepository();
    final earlier = _fact('memory-b', DateTime.utc(2026, 10, 4, 9));
    final later = _fact('memory-a', DateTime.utc(2026, 10, 4, 10));

    await repository.save(earlier);
    await repository.save(later);
    await repository.save(
      earlier.edit(
        fact: '사용자는 토요일 아침에 산책한다.',
        updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
      ),
    );

    final all = await repository.listAll();
    expect(all.map((fact) => fact.id), ['memory-b', 'memory-a']);
    expect(all.first.fact, '사용자는 토요일 아침에 산책한다.');
  });

  test(
    'finds every fact linked to a source and deletes idempotently',
    () async {
      final repository = InMemoryMemoryFactRepository();
      await repository.save(_fact('memory-a', DateTime.utc(2026, 10, 4, 9)));
      await repository.save(
        MemoryFact(
          id: 'memory-b',
          fact: '사용자는 숲을 좋아한다.',
          sourceMessageIds: const ['message-2'],
          category: MemoryCategory.preference,
          sensitivity: MemorySensitivity.standard,
          status: MemoryStatus.active,
          createdAtUtc: DateTime.utc(2026, 10, 4, 10),
          updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
        ),
      );

      expect(
        (await repository.listBySourceMessageId('message-1')).single.id,
        'memory-a',
      );
      await repository.deleteById('memory-a');
      await repository.deleteById('memory-a');

      expect(await repository.findById('memory-a'), isNull);
    },
  );
}

MemoryFact _fact(String id, DateTime updatedAtUtc) {
  return MemoryFact(
    id: id,
    fact: '사용자는 아침에 산책한다.',
    sourceMessageIds: const ['message-1'],
    category: MemoryCategory.routine,
    sensitivity: MemorySensitivity.standard,
    status: MemoryStatus.active,
    createdAtUtc: DateTime.utc(2026, 10, 4, 8),
    updatedAtUtc: updatedAtUtc,
  );
}
