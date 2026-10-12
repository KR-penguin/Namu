import '../../diary/domain/diary_entry.dart';
import '../domain/memory_fact.dart';
import '../domain/memory_fact_repository.dart';

/// Materializes AI-proposed diary memories as user-controlled candidates.
///
/// The deterministic identity makes an interrupted finalization retry safe.
/// Existing rows are returned unchanged so a retry cannot undo an approval or
/// edit. Callers invoke this only at the draft-to-finalized transition; it is
/// intentionally not a startup reconciler, because that could recreate a
/// memory the user later deleted.
final class CreateMemoryCandidates {
  const CreateMemoryCandidates({
    required this.repository,
    required this.utcNow,
  });

  final MemoryFactRepository repository;
  final DateTime Function() utcNow;

  Future<List<MemoryFact>> call(DiaryEntry entry) async {
    if (entry.status != DiaryEntryStatus.finalized) {
      throw StateError('Memory candidates require a finalized diary.');
    }
    final createdAtUtc = utcNow();
    if (!createdAtUtc.isUtc) {
      throw StateError('utcNow must return a UTC instant.');
    }
    if (createdAtUtc.isBefore(entry.updatedAtUtc)) {
      throw StateError('Memory candidates cannot predate the finalized diary.');
    }

    final result = <MemoryFact>[];
    for (var index = 0; index < entry.memoryCandidates.length; index++) {
      final id = '${entry.id}:memory:$index';
      final existing = await repository.findById(id);
      if (existing != null) {
        result.add(existing);
        continue;
      }

      final candidate = entry.memoryCandidates[index];
      final fact = MemoryFact(
        id: id,
        fact: candidate.fact,
        sourceMessageIds: candidate.sourceMessageIds,
        category: MemoryCategory.other,
        // The generation contract does not classify sensitivity yet. Treat an
        // unknown classification conservatively and require explicit approval.
        sensitivity: MemorySensitivity.sensitive,
        status: MemoryStatus.candidate,
        createdAtUtc: createdAtUtc,
        updatedAtUtc: createdAtUtc,
      );
      await repository.save(fact);
      result.add(fact);
    }
    return List<MemoryFact>.unmodifiable(result);
  }
}
