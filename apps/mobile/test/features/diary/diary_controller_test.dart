import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/data/in_memory_message_repository.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/diary/application/diary_controller.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

void main() {
  late DiaryDayKey dayKey;
  late InMemoryMessageRepository messageRepository;
  late InMemoryDiaryRepository diaryRepository;
  late List<String> ids;

  setUp(() {
    dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    messageRepository = InMemoryMessageRepository();
    diaryRepository = InMemoryDiaryRepository();
    ids = ['generation-1', 'diary-1', 'generation-2', 'diary-2'];
  });

  DiaryController buildController(DiaryGenerationGateway gateway) {
    return DiaryController(
      dayKey: dayKey,
      diaryRepository: diaryRepository,
      messageRepository: messageRepository,
      generationGateway: gateway,
      responseLocaleProvider: () => AiResponseLocale.ko,
      personaProvider: AiPersona.safeDefault,
      weatherProvider: () async => const WeatherSnapshot.noWeather(),
      nextId: () => ids.removeAt(0),
      utcNow: () => DateTime.utc(2026, 10, 4, 10),
    );
  }

  test(
    'reads the latest response locale for every generation attempt',
    () async {
      await messageRepository.upsert(_message(dayKey));
      var responseLocale = AiResponseLocale.en;
      var attempts = 0;
      final gateway = _FakeDiaryGateway((_) async {
        attempts += 1;
        if (attempts == 1) {
          throw StateError('offline');
        }
        return _output();
      });
      final controller = DiaryController(
        dayKey: dayKey,
        diaryRepository: diaryRepository,
        messageRepository: messageRepository,
        generationGateway: gateway,
        responseLocaleProvider: () => responseLocale,
        personaProvider: AiPersona.safeDefault,
        weatherProvider: () async => const WeatherSnapshot.noWeather(),
        nextId: () => ids.removeAt(0),
        utcNow: () => DateTime.utc(2026, 10, 4, 10),
      );
      await controller.load();

      await expectLater(controller.generate(), throwsStateError);
      responseLocale = AiResponseLocale.ja;
      await controller.generate();

      expect(
        gateway.requests.map((request) => request.responseLocale),
        <AiResponseLocale>[AiResponseLocale.en, AiResponseLocale.ja],
      );
    },
  );

  test('loads the latest snapshot and whether source messages exist', () async {
    await messageRepository.upsert(_message(dayKey));
    final existing = _entry(dayKey)
        .finalize(updatedAtUtc: DateTime.utc(2026, 10, 4, 11));
    await diaryRepository.save(existing);
    final controller = buildController(
      _FakeDiaryGateway((_) => throw StateError('must not be called')),
    );

    await controller.load();

    expect(controller.entry?.id, 'existing-diary');
    expect(controller.canGenerate, isTrue);
    expect(controller.isLoading, isFalse);
  });

  test('switches to a new active day and loads only that diary', () async {
    final nextDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 5, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    await diaryRepository.save(_entry(dayKey));
    await diaryRepository.save(
      DiaryEntry(
        id: 'next-diary',
        dayKey: nextDay,
        version: 1,
        status: DiaryEntryStatus.draft,
        weather: const WeatherSnapshot.noWeather(),
        mood: '상쾌함',
        oneLineSummary: '새로운 하루',
        theme: DiaryTheme.light,
        blocks: const [DiaryTextBlock(text: '다음 날 본문')],
        memoryCandidates: const [],
        sourceMessageIds: const [],
        generationId: 'next-generation',
        generatedAtUtc: DateTime.utc(2026, 10, 5, 9),
        updatedAtUtc: DateTime.utc(2026, 10, 5, 9),
      ),
    );
    final controller = buildController(
      _FakeDiaryGateway((_) => throw StateError('must not be called')),
    );
    await controller.load();

    await controller.switchDay(nextDay);

    expect(controller.dayKey, nextDay);
    expect(controller.entry?.id, 'next-diary');
  });

  test('a previous-day generation cannot replace the new-day UI', () async {
    final nextDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 5, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    await messageRepository.upsert(_message(dayKey));
    final response = Completer<DiaryGenerationOutput>();
    final gateway = _FakeDiaryGateway((_) => response.future);
    final controller = buildController(gateway);
    await controller.load();

    final generation = controller.generate();
    await Future<void>.delayed(Duration.zero);
    await controller.switchDay(nextDay);
    response.complete(_output());
    await generation;

    expect(controller.dayKey, nextDay);
    expect(controller.entry, isNull);
    expect(await diaryRepository.findLatestForDay(dayKey), isNotNull);
  });

  test('generates, validates, and stores a diary draft', () async {
    await messageRepository.upsert(_message(dayKey));
    final gateway = _FakeDiaryGateway((request) async {
      expect(request.generationId, 'generation-1');
      expect(request.messages.single.id, 'message-1');
      expect(request.persona.name, '모아');
      return _output();
    });
    final controller = buildController(gateway);
    await controller.load();

    await controller.generate();

    expect(controller.entry?.id, 'diary-1');
    expect(controller.entry?.status, DiaryEntryStatus.draft);
    expect(controller.entry?.sourceMessageIds, ['message-1']);
    expect(
      await diaryRepository.findLatestForDay(dayKey),
      same(controller.entry),
    );
    expect(controller.error, isNull);
  });

  test('retries a failed generation with the same idempotency key', () async {
    await messageRepository.upsert(_message(dayKey));
    var attempts = 0;
    final gateway = _FakeDiaryGateway((_) async {
      attempts += 1;
      if (attempts == 1) {
        throw StateError('offline');
      }
      return _output();
    });
    final controller = buildController(gateway);
    await controller.load();

    await expectLater(controller.generate(), throwsStateError);
    final idsAfterFailure = List<String>.from(ids);
    await controller.generate();

    expect(gateway.requests.map((request) => request.generationId), [
      'generation-1',
      'generation-1',
    ]);
    expect(ids, idsAfterFailure.skip(1));
    expect(controller.entry, isNotNull);
  });

  test('finalizes and persists the loaded draft', () async {
    await diaryRepository.save(_entry(dayKey));
    final controller = buildController(
      _FakeDiaryGateway((_) => throw StateError('must not be called')),
    );
    await controller.load();

    await controller.finalize();

    expect(controller.entry?.status, DiaryEntryStatus.finalized);
    expect(
      (await diaryRepository.findLatestForDay(dayKey))?.status,
      DiaryEntryStatus.finalized,
    );
  });

  test('edits and persists user-controlled diary fields', () async {
    await diaryRepository.save(_entry(dayKey));
    final controller = buildController(
      _FakeDiaryGateway((_) => throw StateError('must not be called')),
    );
    await controller.load();

    await controller.edit(
      mood: '뿌듯함',
      oneLineSummary: '내가 직접 다듬은 오늘의 한 줄',
      theme: DiaryTheme.dark,
      blocks: const <DiaryBlock>[
        DiaryTextBlock(text: '사용자가 고친 본문'),
        DiaryPhotoBlock(photoAssetId: 'photo-1'),
      ],
    );

    final saved = await diaryRepository.findLatestForDay(dayKey);
    expect(controller.entry, same(saved));
    expect(saved?.mood, '뿌듯함');
    expect(saved?.oneLineSummary, '내가 직접 다듬은 오늘의 한 줄');
    expect(saved?.theme, DiaryTheme.dark);
    expect(saved?.blocks, hasLength(2));
    expect(controller.isSaving, isFalse);
  });

  test('rejects generation when the day has no messages', () async {
    final controller = buildController(
      _FakeDiaryGateway((_) => throw StateError('must not be called')),
    );
    await controller.load();

    await expectLater(controller.generate(), throwsStateError);

    expect(controller.isGenerating, isFalse);
    expect(controller.entry, isNull);
  });
}

Message _message(DiaryDayKey dayKey) {
  return Message(
    id: 'message-1',
    requestId: 'request-1',
    dayKey: dayKey,
    role: MessageRole.user,
    text: '오늘은 산책했어.',
    createdAtUtc: DateTime.utc(2026, 10, 4, 8),
    status: MessageStatus.sent,
  );
}

DiaryGenerationOutput _output() {
  return DiaryGenerationOutput(
    schemaVersion: 1,
    mood: '차분함',
    oneLineSummary: '천천히 걸으며 숨을 고른 하루',
    theme: DiaryTheme.light,
    blocks: const [DiaryTextBlock(text: '오늘은 동네를 천천히 걸었다.')],
    memoryCandidates: [
      DiaryMemoryCandidate(
        fact: '사용자는 산책을 좋아한다.',
        sourceMessageIds: const ['message-1'],
      ),
    ],
  );
}

DiaryEntry _entry(DiaryDayKey dayKey) {
  return DiaryEntry(
    id: 'existing-diary',
    dayKey: dayKey,
    version: 1,
    status: DiaryEntryStatus.draft,
    weather: const WeatherSnapshot.noWeather(),
    mood: '차분함',
    oneLineSummary: '기존 일기',
    theme: DiaryTheme.light,
    blocks: const [DiaryTextBlock(text: '기존 본문')],
    memoryCandidates: const [],
    sourceMessageIds: const ['message-1'],
    generationId: 'existing-generation',
    generatedAtUtc: DateTime.utc(2026, 10, 4, 9),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 9),
  );
}

typedef _GenerateHandler = Future<DiaryGenerationOutput> Function(
  DiaryGenerationRequest request,
);

final class _FakeDiaryGateway implements DiaryGenerationGateway {
  _FakeDiaryGateway(this.handler);

  final _GenerateHandler handler;
  final List<DiaryGenerationRequest> requests = [];

  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) {
    requests.add(request);
    return handler(request);
  }
}
