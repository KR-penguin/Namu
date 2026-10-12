enum DiaryTheme { light, dark }

sealed class DiaryBlock {
  const DiaryBlock();
}

final class DiaryTextBlock extends DiaryBlock {
  const DiaryTextBlock({required this.text});

  final String text;
}

final class DiaryPhotoBlock extends DiaryBlock {
  const DiaryPhotoBlock({required this.photoAssetId});

  final String photoAssetId;
}

final class DiaryMemoryCandidate {
  DiaryMemoryCandidate({
    required this.fact,
    required Iterable<String> sourceMessageIds,
  }) : sourceMessageIds = List.unmodifiable(sourceMessageIds);

  final String fact;
  final List<String> sourceMessageIds;
}

final class DiaryGenerationOutput {
  DiaryGenerationOutput({
    required this.schemaVersion,
    required this.mood,
    required this.oneLineSummary,
    required this.theme,
    required Iterable<DiaryBlock> blocks,
    required Iterable<DiaryMemoryCandidate> memoryCandidates,
  }) : blocks = List.unmodifiable(blocks),
       memoryCandidates = List.unmodifiable(memoryCandidates);

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final String mood;
  final String oneLineSummary;
  final DiaryTheme theme;
  final List<DiaryBlock> blocks;
  final List<DiaryMemoryCandidate> memoryCandidates;
}
