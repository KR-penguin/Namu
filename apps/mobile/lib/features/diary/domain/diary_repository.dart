import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';

typedef DiaryDraftBuilder = DiaryEntry Function(int nextVersion);

abstract interface class DiaryRepository {
  /// Returns the highest-version snapshot for the exact [dayKey].
  Future<DiaryEntry?> findLatestForDay(DiaryDayKey dayKey);

  /// Returns every snapshot ordered by updated UTC descending, then ID.
  Future<List<DiaryEntry>> listAll();

  /// Inserts a snapshot or replaces the snapshot with the same ID.
  Future<void> save(DiaryEntry entry);

  /// Deletes the snapshot with [id]. Missing IDs are ignored.
  Future<void> deleteById(String id);

  /// Atomically returns the existing entry for [generationId], or creates one.
  ///
  /// A new entry receives one plus the largest version belonging to the exact
  /// [dayKey]. Implementations must enforce unique generation IDs and unique
  /// `(dayKey, version)` pairs at their storage boundary.
  Future<DiaryEntry> createDraftIfAbsent({
    required String generationId,
    required DiaryDayKey dayKey,
    required DiaryDraftBuilder build,
  });
}
