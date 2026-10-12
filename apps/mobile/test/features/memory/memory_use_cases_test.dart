import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/memory/application/approve_memory_fact.dart';
import 'package:namu/features/memory/application/delete_memory_fact.dart';
import 'package:namu/features/memory/application/disable_memories_for_deleted_source.dart';
import 'package:namu/features/memory/application/edit_memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact_repository.dart';

void main() {
  late _FakeMemoryFactRepository repository;

  setUp(() {
    repository = _FakeMemoryFactRepository();
  });

  test(
    'ApproveMemoryFact explicitly activates a sensitive candidate',
    () async {
      repository.seed(
        _fact(id: 'memory-1', sensitivity: MemorySensitivity.sensitive),
      );
      final approvedAt = DateTime.utc(2026, 10, 4, 11);

      final approved = await ApproveMemoryFact(repository: repository)(
        memoryFactId: 'memory-1',
        approvedAtUtc: approvedAt,
      );

      expect(approved.status, MemoryStatus.active);
      expect(approved.updatedAtUtc, approvedAt);
      expect(repository.byId('memory-1'), same(approved));
    },
  );

  test('EditMemoryFact changes only the fact and update timestamp', () async {
    final original = _fact(
      id: 'memory-1',
      sourceMessageIds: const ['message-1', 'message-2'],
      status: MemoryStatus.active,
      sensitivity: MemorySensitivity.sensitive,
    );
    repository.seed(original);
    final editedAt = DateTime.utc(2026, 10, 4, 12);

    final edited = await EditMemoryFact(repository: repository)(
      memoryFactId: 'memory-1',
      fact: '사용자는 주말에 북한산 등산을 즐긴다.',
      editedAtUtc: editedAt,
    );

    expect(edited.id, original.id);
    expect(edited.sourceMessageIds, original.sourceMessageIds);
    expect(edited.category, original.category);
    expect(edited.sensitivity, original.sensitivity);
    expect(edited.status, original.status);
    expect(edited.createdAtUtc, original.createdAtUtc);
    expect(edited.updatedAtUtc, editedAt);
    expect(edited.fact, '사용자는 주말에 북한산 등산을 즐긴다.');
  });

  test('DeleteMemoryFact removes the selected fact', () async {
    repository.seed(_fact(id: 'memory-1'));

    await DeleteMemoryFact(repository: repository)(memoryFactId: 'memory-1');

    expect(repository.byId('memory-1'), isNull);
  });

  test(
    'source deletion disables every referencing non-inactive fact',
    () async {
      repository
        ..seed(
          _fact(
            id: 'memory-active',
            sourceMessageIds: const ['deleted-message', 'message-2'],
            status: MemoryStatus.active,
          ),
        )
        ..seed(
          _fact(
            id: 'memory-candidate',
            sourceMessageIds: const ['deleted-message'],
          ),
        )
        ..seed(
          _fact(
            id: 'memory-inactive',
            sourceMessageIds: const ['deleted-message'],
            status: MemoryStatus.inactive,
          ),
        )
        ..seed(
          _fact(
            id: 'memory-unrelated',
            sourceMessageIds: const ['message-else'],
            status: MemoryStatus.active,
          ),
        );
      final invalidatedAt = DateTime.utc(2026, 10, 4, 13);

      final disabledCount = await DisableMemoriesForDeletedSource(
        repository: repository,
      )(sourceMessageId: 'deleted-message', disabledAtUtc: invalidatedAt);

      expect(disabledCount, 2);
      expect(repository.byId('memory-active')?.status, MemoryStatus.inactive);
      expect(
        repository.byId('memory-candidate')?.status,
        MemoryStatus.inactive,
      );
      expect(
        repository.byId('memory-inactive')?.updatedAtUtc,
        DateTime.utc(2026, 10, 4, 10),
      );
      expect(repository.byId('memory-unrelated')?.status, MemoryStatus.active);
    },
  );

  test('memory use cases report a missing fact', () async {
    expect(
      () => ApproveMemoryFact(repository: repository)(
        memoryFactId: 'missing',
        approvedAtUtc: DateTime.utc(2026, 10, 4, 11),
      ),
      throwsA(isA<MemoryFactNotFoundException>()),
    );
    expect(
      () => EditMemoryFact(repository: repository)(
        memoryFactId: 'missing',
        fact: '새 사실',
        editedAtUtc: DateTime.utc(2026, 10, 4, 11),
      ),
      throwsA(isA<MemoryFactNotFoundException>()),
    );
  });
}

MemoryFact _fact({
  required String id,
  List<String> sourceMessageIds = const ['message-1'],
  MemoryStatus status = MemoryStatus.candidate,
  MemorySensitivity sensitivity = MemorySensitivity.standard,
}) {
  return MemoryFact(
    id: id,
    fact: '사용자는 등산을 좋아한다.',
    sourceMessageIds: sourceMessageIds,
    category: MemoryCategory.preference,
    sensitivity: sensitivity,
    status: status,
    createdAtUtc: DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
  );
}

final class _FakeMemoryFactRepository implements MemoryFactRepository {
  final Map<String, MemoryFact> _facts = <String, MemoryFact>{};

  void seed(MemoryFact fact) {
    _facts[fact.id] = fact;
  }

  MemoryFact? byId(String id) => _facts[id];

  @override
  Future<void> deleteById(String id) async {
    _facts.remove(id);
  }

  @override
  Future<MemoryFact?> findById(String id) async => _facts[id];

  @override
  Future<List<MemoryFact>> listAll() async => _facts.values.toList();

  @override
  Future<List<MemoryFact>> listBySourceMessageId(String sourceMessageId) async {
    return _facts.values
        .where((fact) => fact.sourceMessageIds.contains(sourceMessageId))
        .toList(growable: false);
  }

  @override
  Future<void> save(MemoryFact fact) async {
    _facts[fact.id] = fact;
  }
}
