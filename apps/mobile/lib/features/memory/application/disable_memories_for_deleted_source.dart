import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact_repository.dart';

final class DisableMemoriesForDeletedSource {
  const DisableMemoriesForDeletedSource({required this.repository});

  final MemoryFactRepository repository;

  Future<int> call({
    required String sourceMessageId,
    required DateTime disabledAtUtc,
  }) async {
    final normalizedSourceId = sourceMessageId.trim();
    if (normalizedSourceId.isEmpty) {
      throw ArgumentError.value(
        sourceMessageId,
        'sourceMessageId',
        'must not be blank',
      );
    }
    if (!disabledAtUtc.isUtc) {
      throw ArgumentError.value(
        disabledAtUtc,
        'disabledAtUtc',
        'must be in UTC',
      );
    }

    final linkedFacts = await repository.listBySourceMessageId(
      normalizedSourceId,
    );
    var disabledCount = 0;
    for (final fact in linkedFacts) {
      if (fact.status == MemoryStatus.inactive) {
        continue;
      }
      await repository.save(fact.deactivate(updatedAtUtc: disabledAtUtc));
      disabledCount += 1;
    }
    return disabledCount;
  }
}
