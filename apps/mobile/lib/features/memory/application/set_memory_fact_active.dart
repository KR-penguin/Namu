import '../domain/memory_fact.dart';
import '../domain/memory_fact_repository.dart';

/// Applies an explicit, reversible user choice to an already reviewed memory.
final class SetMemoryFactActive {
  const SetMemoryFactActive({required this.repository});

  final MemoryFactRepository repository;

  Future<MemoryFact> call({
    required String memoryFactId,
    required bool active,
    required DateTime changedAtUtc,
  }) async {
    final normalizedId = memoryFactId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        memoryFactId,
        'memoryFactId',
        'must not be blank',
      );
    }
    if (!changedAtUtc.isUtc) {
      throw ArgumentError.value(changedAtUtc, 'changedAtUtc', 'must be in UTC');
    }

    final existing = await repository.findById(normalizedId);
    if (existing == null) {
      throw MemoryFactNotFoundException(normalizedId);
    }
    if (existing.status == MemoryStatus.candidate) {
      throw StateError(
        'A candidate must be approved before it can be toggled.',
      );
    }
    final targetStatus = active ? MemoryStatus.active : MemoryStatus.inactive;
    if (existing.status == targetStatus) {
      return existing;
    }

    final updated = active
        ? existing.approve(updatedAtUtc: changedAtUtc)
        : existing.deactivate(updatedAtUtc: changedAtUtc);
    await repository.save(updated);
    return updated;
  }
}
