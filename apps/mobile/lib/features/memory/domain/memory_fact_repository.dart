import 'package:namu/features/memory/domain/memory_fact.dart';

abstract interface class MemoryFactRepository {
  Future<MemoryFact?> findById(String id);

  Future<List<MemoryFact>> listAll();

  Future<List<MemoryFact>> listBySourceMessageId(String sourceMessageId);

  Future<void> save(MemoryFact fact);

  Future<void> deleteById(String id);
}

final class MemoryFactNotFoundException implements Exception {
  const MemoryFactNotFoundException(this.memoryFactId);

  final String memoryFactId;

  @override
  String toString() => 'MemoryFactNotFoundException($memoryFactId)';
}
