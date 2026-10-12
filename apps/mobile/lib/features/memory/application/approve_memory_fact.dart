import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact_repository.dart';

final class ApproveMemoryFact {
  const ApproveMemoryFact({required this.repository});

  final MemoryFactRepository repository;

  Future<MemoryFact> call({
    required String memoryFactId,
    required DateTime approvedAtUtc,
  }) async {
    final normalizedId = memoryFactId.trim();
    _requireNonBlank(normalizedId);
    _requireUtc(approvedAtUtc, 'approvedAtUtc');

    final existing = await repository.findById(normalizedId);
    if (existing == null) {
      throw MemoryFactNotFoundException(normalizedId);
    }

    // This use case represents an explicit user action; it is the only path that
    // may activate a sensitive candidate.
    final approved = existing.approve(updatedAtUtc: approvedAtUtc);
    await repository.save(approved);
    return approved;
  }

  static void _requireNonBlank(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'memoryFactId', 'must not be blank');
    }
  }

  static void _requireUtc(DateTime value, String name) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, name, 'must be in UTC');
    }
  }
}
