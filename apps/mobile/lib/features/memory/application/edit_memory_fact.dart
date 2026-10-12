import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact_repository.dart';

final class EditMemoryFact {
  const EditMemoryFact({required this.repository});

  final MemoryFactRepository repository;

  Future<MemoryFact> call({
    required String memoryFactId,
    required String fact,
    required DateTime editedAtUtc,
  }) async {
    final normalizedId = memoryFactId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        memoryFactId,
        'memoryFactId',
        'must not be blank',
      );
    }
    if (!editedAtUtc.isUtc) {
      throw ArgumentError.value(editedAtUtc, 'editedAtUtc', 'must be in UTC');
    }

    final existing = await repository.findById(normalizedId);
    if (existing == null) {
      throw MemoryFactNotFoundException(normalizedId);
    }

    final edited = existing.edit(fact: fact, updatedAtUtc: editedAtUtc);
    await repository.save(edited);
    return edited;
  }
}
