import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';

void main() {
  group('MemoryFact', () {
    test('normalizes text and owns an immutable source message collection', () {
      final mutableSources = <String>[' message-1 ', 'message-2'];
      final fact = _fact(
        fact: ' 사용자는 등산을 좋아한다. ',
        sourceMessageIds: mutableSources,
      );

      mutableSources.add('message-3');

      expect(fact.fact, '사용자는 등산을 좋아한다.');
      expect(fact.sourceMessageIds, ['message-1', 'message-2']);
      expect(
        () => fact.sourceMessageIds.add('message-4'),
        throwsUnsupportedError,
      );
    });

    test('rejects blank facts and missing, blank, or duplicate sources', () {
      expect(() => _fact(fact: ' '), throwsArgumentError);
      expect(() => _fact(sourceMessageIds: const []), throwsArgumentError);
      expect(
        () => _fact(sourceMessageIds: const ['message-1', ' ']),
        throwsArgumentError,
      );
      expect(
        () => _fact(sourceMessageIds: const ['message-1', 'message-1']),
        throwsArgumentError,
      );
    });

    test('requires UTC creation and update timestamps', () {
      final localTime = DateTime(2026, 10, 4, 9);

      expect(() => _fact(createdAtUtc: localTime), throwsArgumentError);
      expect(() => _fact(updatedAtUtc: localTime), throwsArgumentError);
    });

    test('does not allow an update earlier than creation', () {
      expect(
        () => _fact(
          createdAtUtc: DateTime.utc(2026, 10, 4, 10),
          updatedAtUtc: DateTime.utc(2026, 10, 4, 9, 59, 59),
        ),
        throwsArgumentError,
      );
    });

    test('rejects automatic activation of a sensitive fact', () {
      final candidate = _fact(sensitivity: MemorySensitivity.sensitive);

      expect(
        () => candidate.activateAutomatically(
          updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
        ),
        throwsStateError,
      );
    });

    test('allows explicit approval of a sensitive fact', () {
      final candidate = _fact(sensitivity: MemorySensitivity.sensitive);
      final approvedAt = DateTime.utc(2026, 10, 4, 11);

      final approved = candidate.approve(updatedAtUtc: approvedAt);

      expect(approved.status, MemoryStatus.active);
      expect(approved.updatedAtUtc, approvedAt);
      expect(approved.sensitivity, MemorySensitivity.sensitive);
    });
  });
}

MemoryFact _fact({
  String fact = '사용자는 등산을 좋아한다.',
  List<String> sourceMessageIds = const ['message-1'],
  MemorySensitivity sensitivity = MemorySensitivity.standard,
  DateTime? createdAtUtc,
  DateTime? updatedAtUtc,
}) {
  return MemoryFact(
    id: 'memory-1',
    fact: fact,
    sourceMessageIds: sourceMessageIds,
    category: MemoryCategory.preference,
    sensitivity: sensitivity,
    status: MemoryStatus.candidate,
    createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: updatedAtUtc ?? DateTime.utc(2026, 10, 4, 10),
  );
}
