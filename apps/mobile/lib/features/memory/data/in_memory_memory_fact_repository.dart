import '../domain/memory_fact.dart';
import '../domain/memory_fact_repository.dart';

final class InMemoryMemoryFactRepository implements MemoryFactRepository {
  final Map<String, MemoryFact> _factsById = <String, MemoryFact>{};

  @override
  Future<MemoryFact?> findById(String id) async => _factsById[id];

  @override
  Future<List<MemoryFact>> listAll() async {
    final result = _factsById.values.toList()
      ..sort((left, right) {
        final byUpdated = right.updatedAtUtc.compareTo(left.updatedAtUtc);
        return byUpdated != 0 ? byUpdated : left.id.compareTo(right.id);
      });
    return List<MemoryFact>.unmodifiable(result);
  }

  @override
  Future<List<MemoryFact>> listBySourceMessageId(String sourceMessageId) async {
    final result =
        _factsById.values
            .where((fact) => fact.sourceMessageIds.contains(sourceMessageId))
            .toList()
          ..sort((left, right) => left.id.compareTo(right.id));
    return List<MemoryFact>.unmodifiable(result);
  }

  @override
  Future<void> save(MemoryFact fact) async {
    _factsById[fact.id] = fact;
  }

  @override
  Future<void> deleteById(String id) async {
    _factsById.remove(id);
  }
}
