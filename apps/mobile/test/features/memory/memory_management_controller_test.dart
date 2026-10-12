import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/memory/application/memory_management_controller.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact_repository.dart';

void main() {
  test(
    'reload exposes loading and orders candidates before saved memories',
    () async {
      final pending = Completer<List<MemoryFact>>();
      final repository = _MemoryFactRepository(loads: [() => pending.future]);
      final controller = MemoryManagementController(
        repository: repository,
        utcNow: () => DateTime.utc(2026, 10, 4, 15),
      );

      final reload = controller.reload();

      expect(controller.isLoading, isTrue);
      expect(controller.hasLoaded, isFalse);
      expect(controller.error, isNull);

      final active = _fact(
        id: 'active',
        status: MemoryStatus.active,
        updatedAtUtc: DateTime.utc(2026, 10, 4, 14),
      );
      final candidate = _fact(
        id: 'candidate',
        sensitivity: MemorySensitivity.sensitive,
        updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
      );
      final inactive = _fact(
        id: 'inactive',
        status: MemoryStatus.inactive,
        updatedAtUtc: DateTime.utc(2026, 10, 4, 16),
      );
      pending.complete([inactive, active, candidate]);
      await reload;

      expect(controller.isLoading, isFalse);
      expect(controller.hasLoaded, isTrue);
      expect(controller.facts.map((fact) => fact.id), [
        'candidate',
        'active',
        'inactive',
      ]);
      expect(
        () => controller.facts.add(active),
        throwsUnsupportedError,
        reason: 'Presentation callers must not mutate controller state.',
      );
      expect(
        repository.saveCalls,
        0,
        reason: 'Loading even a sensitive candidate must never approve it.',
      );
    },
  );

  test(
    'reload reports a private error state, retains data, and recovers',
    () async {
      final first = _fact(id: 'first', status: MemoryStatus.active);
      final recovered = _fact(id: 'recovered');
      final repository = _MemoryFactRepository(
        loads: [
          () async => [first],
          () async => throw StateError('database includes private detail'),
          () async => [recovered],
        ],
      );
      final controller = MemoryManagementController(
        repository: repository,
        utcNow: () => DateTime.utc(2026, 10, 4, 15),
      );

      await controller.reload();
      await expectLater(controller.reload(), throwsStateError);

      expect(controller.error, isA<StateError>());
      expect(controller.facts.single.id, 'first');

      await controller.reload();

      expect(controller.error, isNull);
      expect(controller.facts.single.id, 'recovered');
      expect(repository.listAllCalls, 3);
    },
  );

  test('explicit approval activates a sensitive candidate', () async {
    final candidate = _fact(
      id: 'sensitive',
      sensitivity: MemorySensitivity.sensitive,
    );
    final repository = _MemoryFactRepository()..seed(candidate);
    final approvedAtUtc = DateTime.utc(2026, 10, 4, 15);
    final controller = MemoryManagementController(
      repository: repository,
      utcNow: () => approvedAtUtc,
    );
    await controller.reload();

    await controller.approve('sensitive');

    expect(controller.facts.single.status, MemoryStatus.active);
    expect(controller.facts.single.updatedAtUtc, approvedAtUtc);
    expect(repository.saveCalls, 1);
  });

  test(
    'failed approval retains the candidate and clears its busy state',
    () async {
      final candidate = _fact(id: 'candidate');
      final repository = _MemoryFactRepository(
        saveError: StateError('private candidate text'),
      )..seed(candidate);
      final controller = MemoryManagementController(
        repository: repository,
        utcNow: () => DateTime.utc(2026, 10, 4, 15),
      );
      await controller.reload();

      final approval = controller.approve('candidate');
      expect(controller.isMutating('candidate'), isTrue);
      await expectLater(approval, throwsStateError);

      expect(controller.isMutating('candidate'), isFalse);
      expect(controller.facts.single.status, MemoryStatus.candidate);
    },
  );

  test(
    'edit replaces only the selected fact and normalizes its wording',
    () async {
      final first = _fact(id: 'first', status: MemoryStatus.active);
      final second = _fact(id: 'second', status: MemoryStatus.inactive);
      final repository = _MemoryFactRepository()
        ..seed(first)
        ..seed(second);
      final editedAtUtc = DateTime.utc(2026, 10, 4, 15);
      final controller = MemoryManagementController(
        repository: repository,
        utcNow: () => editedAtUtc,
      );
      await controller.reload();

      await controller.edit(id: 'first', fact: '  사용자는 주말에 산책한다.  ');

      final edited = controller.facts.singleWhere((fact) => fact.id == 'first');
      expect(edited.fact, '사용자는 주말에 산책한다.');
      expect(edited.status, MemoryStatus.active);
      expect(edited.updatedAtUtc, editedAtUtc);
      expect(
        controller.facts.singleWhere((fact) => fact.id == 'second'),
        same(second),
      );
    },
  );

  test('failed edit and delete retain the current local view', () async {
    final original = _fact(id: 'memory', status: MemoryStatus.active);
    final repository = _MemoryFactRepository()..seed(original);
    final controller = MemoryManagementController(
      repository: repository,
      utcNow: () => DateTime.utc(2026, 10, 4, 15),
    );
    await controller.reload();

    repository.saveError = StateError('do not expose this fact');
    await expectLater(
      controller.edit(id: 'memory', fact: '새 문구'),
      throwsStateError,
    );
    expect(controller.facts.single, same(original));
    expect(controller.isMutating('memory'), isFalse);

    repository
      ..saveError = null
      ..deleteError = StateError('do not expose source IDs');
    await expectLater(controller.delete('memory'), throwsStateError);
    expect(controller.facts.single, same(original));
    expect(controller.isMutating('memory'), isFalse);
  });

  test('successful delete removes only the selected fact', () async {
    final repository = _MemoryFactRepository()
      ..seed(_fact(id: 'keep', status: MemoryStatus.active))
      ..seed(_fact(id: 'delete'));
    final controller = MemoryManagementController(
      repository: repository,
      utcNow: () => DateTime.utc(2026, 10, 4, 15),
    );
    await controller.reload();

    await controller.delete('delete');

    expect(controller.facts.map((fact) => fact.id), ['keep']);
    expect(await repository.findById('delete'), isNull);
  });

  test('pauses and resumes an approved memory without deleting it', () async {
    final repository = _MemoryFactRepository()
      ..seed(_fact(id: 'memory', status: MemoryStatus.active));
    final controller = MemoryManagementController(
      repository: repository,
      utcNow: () => DateTime.utc(2026, 10, 4, 15),
    );
    await controller.reload();

    await controller.setActive('memory', active: false);

    expect(controller.facts.single.status, MemoryStatus.inactive);
    expect(await repository.findById('memory'), isNotNull);

    await controller.setActive('memory', active: true);

    expect(controller.facts.single.status, MemoryStatus.active);
    expect(repository.saveCalls, 2);
  });

  test('does not toggle an unapproved candidate', () async {
    final repository = _MemoryFactRepository()..seed(_fact(id: 'candidate'));
    final controller = MemoryManagementController(
      repository: repository,
      utcNow: () => DateTime.utc(2026, 10, 4, 15),
    );
    await controller.reload();

    await expectLater(
      controller.setActive('candidate', active: false),
      throwsStateError,
    );

    expect(controller.facts.single.status, MemoryStatus.candidate);
    expect(repository.saveCalls, 0);
    expect(controller.isMutating('candidate'), isFalse);
  });
}

MemoryFact _fact({
  required String id,
  MemoryStatus status = MemoryStatus.candidate,
  MemorySensitivity sensitivity = MemorySensitivity.standard,
  DateTime? updatedAtUtc,
}) {
  return MemoryFact(
    id: id,
    fact: '사용자는 산책을 좋아한다.',
    sourceMessageIds: const ['message-1'],
    category: MemoryCategory.preference,
    sensitivity: sensitivity,
    status: status,
    createdAtUtc: DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: updatedAtUtc ?? DateTime.utc(2026, 10, 4, 10),
  );
}

final class _MemoryFactRepository implements MemoryFactRepository {
  _MemoryFactRepository({this._loads, this.saveError});

  final Map<String, MemoryFact> _facts = <String, MemoryFact>{};
  final List<Future<List<MemoryFact>> Function()>? _loads;
  Object? saveError;
  Object? deleteError;
  int listAllCalls = 0;
  int saveCalls = 0;

  void seed(MemoryFact fact) {
    _facts[fact.id] = fact;
  }

  @override
  Future<void> deleteById(String id) async {
    if (deleteError case final error?) {
      throw error;
    }
    _facts.remove(id);
  }

  @override
  Future<MemoryFact?> findById(String id) async => _facts[id];

  @override
  Future<List<MemoryFact>> listAll() {
    listAllCalls += 1;
    final loads = _loads;
    if (loads != null && loads.isNotEmpty) {
      return loads.removeAt(0)();
    }
    return Future.value(_facts.values.toList(growable: false));
  }

  @override
  Future<List<MemoryFact>> listBySourceMessageId(String sourceMessageId) async {
    return _facts.values
        .where((fact) => fact.sourceMessageIds.contains(sourceMessageId))
        .toList(growable: false);
  }

  @override
  Future<void> save(MemoryFact fact) async {
    saveCalls += 1;
    if (saveError case final error?) {
      throw error;
    }
    _facts[fact.id] = fact;
  }
}
