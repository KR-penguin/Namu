import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

enum DiaryEntryStatus { draft, finalized }

final class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.dayKey,
    required this.version,
    required this.status,
    required this.weather,
    required this.mood,
    required this.oneLineSummary,
    required this.theme,
    required Iterable<DiaryBlock> blocks,
    required Iterable<DiaryMemoryCandidate> memoryCandidates,
    required Iterable<String> sourceMessageIds,
    required this.generationId,
    required this.generatedAtUtc,
    required this.updatedAtUtc,
  }) : blocks = List<DiaryBlock>.unmodifiable(blocks),
       memoryCandidates = List<DiaryMemoryCandidate>.unmodifiable(
         memoryCandidates,
       ),
       sourceMessageIds = List<String>.unmodifiable(sourceMessageIds) {
    _requireNonBlank(id, 'id');
    _requireNonBlank(generationId, 'generationId');
    _requireNonBlank(mood, 'mood');
    _requireNonBlank(oneLineSummary, 'oneLineSummary');
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'must be positive');
    }
    if (!generatedAtUtc.isUtc) {
      throw ArgumentError.value(
        generatedAtUtc,
        'generatedAtUtc',
        'must be in UTC',
      );
    }
    if (!updatedAtUtc.isUtc) {
      throw ArgumentError.value(updatedAtUtc, 'updatedAtUtc', 'must be in UTC');
    }
    if (updatedAtUtc.isBefore(generatedAtUtc)) {
      throw ArgumentError.value(
        updatedAtUtc,
        'updatedAtUtc',
        'must not be before generatedAtUtc',
      );
    }
    if (this.blocks.isEmpty) {
      throw ArgumentError.value(this.blocks, 'blocks', 'must not be empty');
    }

    final sourceIds = <String>{};
    for (final sourceMessageId in this.sourceMessageIds) {
      _requireNonBlank(sourceMessageId, 'sourceMessageIds');
      if (!sourceIds.add(sourceMessageId)) {
        throw ArgumentError.value(
          sourceMessageId,
          'sourceMessageIds',
          'must not contain duplicates',
        );
      }
    }

    for (final block in this.blocks) {
      switch (block) {
        case DiaryTextBlock(:final text):
          _requireNonBlank(text, 'blocks.text');
        case DiaryPhotoBlock(:final photoAssetId):
          _requireNonBlank(photoAssetId, 'blocks.photoAssetId');
      }
    }

    for (final candidate in this.memoryCandidates) {
      _requireNonBlank(candidate.fact, 'memoryCandidates.fact');
      for (final sourceMessageId in candidate.sourceMessageIds) {
        if (!sourceIds.contains(sourceMessageId)) {
          throw ArgumentError.value(
            sourceMessageId,
            'memoryCandidates.sourceMessageIds',
            'must refer to a diary source message',
          );
        }
      }
    }
  }

  final String id;
  final DiaryDayKey dayKey;
  final int version;
  final DiaryEntryStatus status;
  final WeatherSnapshot weather;
  final String mood;
  final String oneLineSummary;
  final DiaryTheme theme;
  final List<DiaryBlock> blocks;
  final List<DiaryMemoryCandidate> memoryCandidates;
  final List<String> sourceMessageIds;
  final String generationId;
  final DateTime generatedAtUtc;
  final DateTime updatedAtUtc;

  DiaryEntry finalize({required DateTime updatedAtUtc}) {
    return DiaryEntry(
      id: id,
      dayKey: dayKey,
      version: version,
      status: DiaryEntryStatus.finalized,
      weather: weather,
      mood: mood,
      oneLineSummary: oneLineSummary,
      theme: theme,
      blocks: blocks,
      memoryCandidates: memoryCandidates,
      sourceMessageIds: sourceMessageIds,
      generationId: generationId,
      generatedAtUtc: generatedAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  DiaryEntry revise({
    required WeatherSnapshot weather,
    required String mood,
    required String oneLineSummary,
    required DiaryTheme theme,
    required Iterable<DiaryBlock> blocks,
    required DateTime updatedAtUtc,
  }) {
    if (updatedAtUtc.isBefore(this.updatedAtUtc)) {
      throw ArgumentError.value(
        updatedAtUtc,
        'updatedAtUtc',
        'must not be before the current snapshot update',
      );
    }
    return DiaryEntry(
      id: id,
      dayKey: dayKey,
      version: version,
      status: status,
      weather: weather,
      mood: mood,
      oneLineSummary: oneLineSummary,
      theme: theme,
      blocks: blocks,
      memoryCandidates: memoryCandidates,
      sourceMessageIds: sourceMessageIds,
      generationId: generationId,
      generatedAtUtc: generatedAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  static void _requireNonBlank(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'must not be blank');
    }
  }
}
