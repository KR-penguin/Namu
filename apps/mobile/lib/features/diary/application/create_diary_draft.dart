import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/diary_repository.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

final class CreateDiaryDraftCommand {
  CreateDiaryDraftCommand({
    required this.generationId,
    required this.dayKey,
    required this.weather,
    required this.output,
    required Iterable<String> sourceMessageIds,
  }) : sourceMessageIds = List<String>.unmodifiable(sourceMessageIds);

  final String generationId;
  final DiaryDayKey dayKey;
  final WeatherSnapshot weather;
  final DiaryGenerationOutput output;
  final List<String> sourceMessageIds;
}

final class CreateDiaryDraft {
  const CreateDiaryDraft({
    required this.repository,
    required this.nextId,
    required this.utcNow,
  });

  final DiaryRepository repository;
  final String Function() nextId;
  final DateTime Function() utcNow;

  Future<DiaryEntry> call(CreateDiaryDraftCommand command) {
    if (command.generationId.trim().isEmpty) {
      throw ArgumentError.value(
        command.generationId,
        'generationId',
        'must not be blank',
      );
    }
    if (command.output.schemaVersion !=
        DiaryGenerationOutput.currentSchemaVersion) {
      throw ArgumentError.value(
        command.output.schemaVersion,
        'output.schemaVersion',
        'is not supported',
      );
    }

    return repository.createDraftIfAbsent(
      generationId: command.generationId,
      dayKey: command.dayKey,
      build: (nextVersion) {
        final generatedAtUtc = utcNow();

        return DiaryEntry(
          id: nextId(),
          dayKey: command.dayKey,
          version: nextVersion,
          status: DiaryEntryStatus.draft,
          weather: command.weather,
          mood: command.output.mood,
          oneLineSummary: command.output.oneLineSummary,
          theme: command.output.theme,
          blocks: command.output.blocks,
          memoryCandidates: command.output.memoryCandidates,
          sourceMessageIds: command.sourceMessageIds,
          generationId: command.generationId,
          generatedAtUtc: generatedAtUtc,
          updatedAtUtc: generatedAtUtc,
        );
      },
    );
  }
}
