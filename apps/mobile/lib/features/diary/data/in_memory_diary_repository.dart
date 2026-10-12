import '../../../core/time/diary_day_key.dart';
import '../domain/diary_entry.dart';
import '../domain/diary_repository.dart';

final class InMemoryDiaryRepository implements DiaryRepository {
  final Map<String, DiaryEntry> _entriesById = <String, DiaryEntry>{};
  final Map<String, String> _idByGeneration = <String, String>{};

  @override
  Future<DiaryEntry?> findLatestForDay(DiaryDayKey dayKey) async {
    final matches =
        _entriesById.values.where((entry) => entry.dayKey == dayKey).toList()
          ..sort((left, right) {
            final byVersion = right.version.compareTo(left.version);
            return byVersion != 0 ? byVersion : left.id.compareTo(right.id);
          });
    return matches.firstOrNull;
  }

  @override
  Future<List<DiaryEntry>> listAll() async {
    final entries = _entriesById.values.toList()
      ..sort((left, right) {
        final byUpdated = right.updatedAtUtc.compareTo(left.updatedAtUtc);
        return byUpdated != 0 ? byUpdated : left.id.compareTo(right.id);
      });
    return List<DiaryEntry>.unmodifiable(entries);
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    final existing = _entriesById[entry.id];
    if (existing != null &&
        (existing.generationId != entry.generationId ||
            existing.dayKey != entry.dayKey ||
            existing.version != entry.version)) {
      throw StateError('A diary ID cannot change storage identity.');
    }

    final generationOwner = _idByGeneration[entry.generationId];
    if (generationOwner != null && generationOwner != entry.id) {
      throw StateError('A generation ID can create only one diary.');
    }
    final versionConflict = _entriesById.values.any(
      (candidate) =>
          candidate.id != entry.id &&
          candidate.dayKey == entry.dayKey &&
          candidate.version == entry.version,
    );
    if (versionConflict) {
      throw StateError('A day can have only one diary for each version.');
    }

    _entriesById[entry.id] = entry;
    _idByGeneration[entry.generationId] = entry.id;
  }

  @override
  Future<void> deleteById(String id) async {
    final removed = _entriesById.remove(id);
    if (removed != null) {
      _idByGeneration.remove(removed.generationId);
    }
  }

  @override
  Future<DiaryEntry> createDraftIfAbsent({
    required String generationId,
    required DiaryDayKey dayKey,
    required DiaryDraftBuilder build,
  }) async {
    final existingId = _idByGeneration[generationId];
    if (existingId != null) {
      return _entriesById[existingId]!;
    }

    final versions = _entriesById.values
        .where((entry) => entry.dayKey == dayKey)
        .map((entry) => entry.version);
    final nextVersion = versions.isEmpty
        ? 1
        : versions.reduce((left, right) => left > right ? left : right) + 1;
    final entry = build(nextVersion);
    if (entry.generationId != generationId ||
        entry.dayKey != dayKey ||
        entry.version != nextVersion ||
        entry.status != DiaryEntryStatus.draft) {
      throw StateError(
        'Diary draft builder changed generation, day, version, or status.',
      );
    }
    await save(entry);
    return entry;
  }
}
