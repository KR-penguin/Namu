import 'package:namu/features/memory/domain/memory_fact_repository.dart';

final class DeleteMemoryFact {
  const DeleteMemoryFact({required this.repository});

  final MemoryFactRepository repository;

  Future<void> call({required String memoryFactId}) {
    final normalizedId = memoryFactId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        memoryFactId,
        'memoryFactId',
        'must not be blank',
      );
    }
    return repository.deleteById(normalizedId);
  }
}
