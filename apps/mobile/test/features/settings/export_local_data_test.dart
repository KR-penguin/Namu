import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/chat/data/in_memory_message_repository.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/consent/domain/ai_data_consent.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/media/data/in_memory_media_repository.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/memory/data/in_memory_memory_fact_repository.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/persona/data/in_memory_ai_persona_repository.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';
import 'package:namu/features/settings/application/export_local_data.dart';
import 'package:namu/features/settings/domain/local_data_export.dart';

void main() {
  final dayKey = DiaryDayKey.restore(
    labelDate: LocalDate(2026, 10, 10),
    timeZoneId: 'Asia/Seoul',
    cutoff: Duration.zero,
    policyVersion: 1,
  );
  final now = DateTime.utc(2026, 10, 10, 12, 34, 56);

  test(
    'exports a versioned JSON snapshot only after an explicit call',
    () async {
      final messages = InMemoryMessageRepository();
      await messages.upsert(
        Message(
          id: 'message-1',
          requestId: 'request-1',
          dayKey: dayKey,
          role: MessageRole.user,
          text: '오늘은 천천히 걸었어',
          photoAssetId: 'photo-1',
          createdAtUtc: now.subtract(const Duration(hours: 1)),
          status: MessageStatus.sent,
        ),
      );

      final diaries = InMemoryDiaryRepository();
      await diaries.save(
        DiaryEntry(
          id: 'diary-1',
          dayKey: dayKey,
          version: 1,
          status: DiaryEntryStatus.finalized,
          weather: WeatherSnapshot.manual(
            condition: '맑음',
            temperatureCelsius: 18,
          ),
          mood: '평온',
          oneLineSummary: '천천히 걸으며 숨을 고른 하루',
          theme: DiaryTheme.light,
          blocks: const [
            DiaryTextBlock(text: '오후의 길을 오래 걸었다.'),
            DiaryPhotoBlock(photoAssetId: 'photo-1'),
          ],
          memoryCandidates: const [],
          sourceMessageIds: const ['message-1'],
          generationId: 'generation-1',
          generatedAtUtc: now,
          updatedAtUtc: now,
        ),
      );

      final media = InMemoryMediaRepository();
      final stagedMedia = MediaAsset(
        id: 'photo-1',
        dayKey: dayKey,
        storageKey: 'media/private-original.jpg',
        mimeType: MediaMimeType.jpeg,
        byteLength: 1234,
        createdAtUtc: now.subtract(const Duration(hours: 1)),
        lifecycle: MediaLifecycle.staging,
      );
      await media.insert(stagedMedia);
      await media.update(stagedMedia.withLifecycle(MediaLifecycle.ready));

      final persona = InMemoryAiPersonaRepository();
      await persona.save(
        AiPersona(
          id: 'persona-1',
          name: '모아',
          avatarSeed: 'leaf',
          tone: '따뜻하게',
          customInstructions: '질문은 한 번에 하나씩',
          reactionLength: ReactionLength.balanced,
        ),
      );

      final memories = InMemoryMemoryFactRepository();
      await memories.save(
        MemoryFact(
          id: 'memory-1',
          fact: '산책을 좋아한다',
          sourceMessageIds: const ['message-1'],
          category: MemoryCategory.preference,
          sensitivity: MemorySensitivity.standard,
          status: MemoryStatus.active,
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

      final consent = InMemoryAiDataConsentRepository(
        initial: AiDataConsent.accepted(decidedAtUtc: now),
      );
      final store = _RecordingStore();
      final launcher = _RecordingLauncher(LocalDataExportOutcome.opened);
      final export = ExportLocalData(
        messageRepository: messages,
        diaryRepository: diaries,
        mediaRepository: media,
        personaRepository: persona,
        memoryFactRepository: memories,
        aiDataConsentRepository: consent,
        store: store,
        launcher: launcher,
        utcNow: () => now,
      );

      expect(store.writeCalls, 0);
      expect(launcher.launchCalls, 0);

      final outcome = await export(shareText: 'Namu export');

      expect(outcome, LocalDataExportOutcome.opened);
      expect(store.writeCalls, 1);
      expect(launcher.launchCalls, 1);
      expect(launcher.shareTexts, ['Namu export']);
      final document = jsonDecode(utf8.decode(store.bytes!)) as Map;
      expect(document['format'], 'namu-local-data-export');
      expect(document['schemaVersion'], 1);
      expect(document['exportedAtUtc'], '2026-10-10T12:34:56.000Z');
      expect(document['restoreSupported'], isFalse);
      expect(document['snapshotConsistency'], 'bestEffort');
      expect(document['photoFilesIncluded'], isFalse);
      expect(document['renderedDiaryImagesIncluded'], isFalse);
      expect((document['messages'] as List).single['id'], 'message-1');
      expect((document['diaries'] as List).single['id'], 'diary-1');
      expect((document['memoryFacts'] as List).single['id'], 'memory-1');
      expect((document['persona'] as Map)['id'], 'persona-1');
      expect((document['aiDataConsent'] as Map)['choice'], 'accepted');
      final exportedMedia = (document['mediaAssets'] as List).single as Map;
      expect(exportedMedia['id'], 'photo-1');
      expect(exportedMedia['fileIncluded'], isFalse);
      expect(exportedMedia, isNot(contains('storageKey')));
      expect(
        utf8.decode(store.bytes!),
        isNot(contains('private-original.jpg')),
      );
    },
  );

  test(
    'deduplicates photo references and records missing metadata safely',
    () async {
      final messages = InMemoryMessageRepository();
      await messages.upsert(
        Message(
          id: 'message-1',
          requestId: 'request-1',
          dayKey: dayKey,
          role: MessageRole.user,
          photoAssetId: 'missing-photo',
          createdAtUtc: now,
          status: MessageStatus.sent,
        ),
      );
      final diaries = InMemoryDiaryRepository();
      await diaries.save(
        DiaryEntry(
          id: 'diary-1',
          dayKey: dayKey,
          version: 1,
          status: DiaryEntryStatus.finalized,
          weather: const WeatherSnapshot.noWeather(),
          mood: '차분',
          oneLineSummary: '사진 한 장',
          theme: DiaryTheme.dark,
          blocks: const [DiaryPhotoBlock(photoAssetId: 'missing-photo')],
          memoryCandidates: const [],
          sourceMessageIds: const ['message-1'],
          generationId: 'generation-1',
          generatedAtUtc: now,
          updatedAtUtc: now,
        ),
      );
      final store = _RecordingStore();
      final export = ExportLocalData(
        messageRepository: messages,
        diaryRepository: diaries,
        mediaRepository: InMemoryMediaRepository(),
        personaRepository: InMemoryAiPersonaRepository(),
        memoryFactRepository: InMemoryMemoryFactRepository(),
        aiDataConsentRepository: InMemoryAiDataConsentRepository(),
        store: store,
        launcher: _RecordingLauncher(LocalDataExportOutcome.dismissed),
        utcNow: () => now,
      );

      expect(
        await export(shareText: 'Namu export'),
        LocalDataExportOutcome.dismissed,
      );

      final document = jsonDecode(utf8.decode(store.bytes!)) as Map;
      expect(document['mediaAssets'], isEmpty);
      expect(document['missingMediaAssetIds'], ['missing-photo']);
    },
  );

  test('does not open the share sheet when writing fails', () async {
    final launcher = _RecordingLauncher(LocalDataExportOutcome.completed);
    final export = ExportLocalData(
      messageRepository: InMemoryMessageRepository(),
      diaryRepository: InMemoryDiaryRepository(),
      mediaRepository: InMemoryMediaRepository(),
      personaRepository: InMemoryAiPersonaRepository(),
      memoryFactRepository: InMemoryMemoryFactRepository(),
      aiDataConsentRepository: InMemoryAiDataConsentRepository(),
      store: _FailingStore(),
      launcher: launcher,
      utcNow: () => now,
    );

    await expectLater(
      export(shareText: 'Namu export'),
      throwsA(isA<LocalDataExportException>()),
    );
    expect(launcher.launchCalls, 0);
  });
}

final class _RecordingStore implements LocalDataExportStore {
  int writeCalls = 0;
  Uint8List? bytes;

  @override
  Future<LocalDataExportArtifact> write({
    required Uint8List bytes,
    required DateTime exportedAtUtc,
  }) async {
    writeCalls += 1;
    this.bytes = bytes;
    return LocalDataExportArtifact(
      path: '/private/exports/namu-data.json',
      mimeType: 'application/json',
      byteLength: bytes.length,
    );
  }
}

final class _FailingStore implements LocalDataExportStore {
  @override
  Future<LocalDataExportArtifact> write({
    required Uint8List bytes,
    required DateTime exportedAtUtc,
  }) {
    throw const LocalDataExportException(LocalDataExportFailure.writeFailed);
  }
}

final class _RecordingLauncher implements LocalDataExportLauncher {
  _RecordingLauncher(this.outcome);

  final LocalDataExportOutcome outcome;
  int launchCalls = 0;
  final List<String> shareTexts = [];

  @override
  Future<LocalDataExportOutcome> launch(
    LocalDataExportArtifact artifact, {
    required String shareText,
  }) async {
    launchCalls += 1;
    shareTexts.add(shareText);
    return outcome;
  }
}
