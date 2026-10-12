import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/data/in_memory_message_repository.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/diary/application/daily_close_coordinator.dart';
import 'package:namu/features/diary/application/daily_close_schedule.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/persona/data/in_memory_ai_persona_repository.dart';

void main() {
  late DateTime now;
  late InMemoryMessageRepository messages;
  late InMemoryDiaryRepository diaries;
  late InMemoryAiPersonaRepository personas;
  late _FakeTimerScheduler timers;
  late StreamController<void> foregroundEvents;
  late List<String> entryIds;
  late AiResponseLocale responseLocale;

  setUp(() {
    now = DateTime.utc(2026, 10, 4, 14, 59, 59, 999);
    messages = InMemoryMessageRepository();
    diaries = InMemoryDiaryRepository();
    personas = InMemoryAiPersonaRepository();
    timers = _FakeTimerScheduler();
    foregroundEvents = StreamController<void>.broadcast(sync: true);
    entryIds = <String>['entry-1', 'entry-2', 'entry-3'];
    responseLocale = AiResponseLocale.ko;
  });

  tearDown(() async {
    await foregroundEvents.close();
  });

  DailyCloseCoordinator buildCoordinator(
    DiaryGenerationGateway gateway, {
    void Function(DiaryDayKey dayKey)? onActiveDayChanged,
    Future<void> Function()? prepareForForeground,
  }) {
    return DailyCloseCoordinator(
      messageRepository: messages,
      diaryRepository: diaries,
      generationGateway: gateway,
      responseLocaleProvider: () => responseLocale,
      personaRepository: personas,
      weatherProvider: (_) async => const WeatherSnapshot.noWeather(),
      utcNow: () => now,
      schedule: LocalMidnightDiarySchedule(
        timeZoneAt: (_) => TimeZoneSnapshot(
          timeZoneId: 'Asia/Seoul',
          utcOffset: const Duration(hours: 9),
        ),
      ),
      timerScheduler: timers,
      foregroundEvents: foregroundEvents.stream,
      nextEntryId: () => entryIds.removeAt(0),
      onActiveDayChanged: onActiveDayChanged,
      prepareForForeground: prepareForForeground,
    );
  }

  test('uses the latest response locale when a closed day retries', () async {
    now = DateTime.utc(2026, 10, 4, 1);
    final pastDay = _day(2026, 10, 3);
    await messages.upsert(_message('message-1', pastDay));
    var attempts = 0;
    final gateway = _FakeDiaryGateway((_) async {
      attempts += 1;
      if (attempts == 1) {
        throw StateError('offline');
      }
      return _output();
    });
    final coordinator = buildCoordinator(gateway);

    final first = await coordinator.start();
    expect(first.error, isA<StateError>());
    responseLocale = AiResponseLocale.es;
    final second = await coordinator.onForeground();

    expect(second.generatedDays, <DiaryDayKey>[pastDay]);
    expect(
      gateway.requests.map((request) => request.responseLocale),
      <AiResponseLocale>[AiResponseLocale.ko, AiResponseLocale.es],
    );
    await coordinator.dispose();
  });

  test(
    'active app closes the just-finished day at its next midnight',
    () async {
      final closingDay = _day(2026, 10, 4);
      await messages.upsert(_message('message-1', closingDay));
      final gateway = _FakeDiaryGateway.success();
      final coordinator = buildCoordinator(gateway);

      await coordinator.start();
      expect(timers.lastDelay, const Duration(milliseconds: 1));
      expect(gateway.requests, isEmpty);

      now = DateTime.utc(2026, 10, 4, 15);
      await timers.fireActive();

      final saved = await diaries.findLatestForDay(closingDay);
      expect(saved?.status, DiaryEntryStatus.draft);
      expect(saved?.sourceMessageIds, <String>['message-1']);
      expect(gateway.requests.single.dayKey, closingDay);
      expect(timers.lastDelay, const Duration(days: 1));

      await coordinator.dispose();
    },
  );

  test(
    'foreground correction processes missing past days oldest first',
    () async {
      now = DateTime.utc(2026, 10, 4, 1);
      final oldest = _day(2026, 10, 1);
      final existingDay = _day(2026, 10, 2);
      final newest = _day(2026, 10, 3);
      final current = _day(2026, 10, 4);
      await messages.upsert(_message('newest-message', newest));
      await messages.upsert(_message('current-message', current));
      await messages.upsert(_message('oldest-message', oldest));
      await messages.upsert(_message('existing-message', existingDay));
      await diaries.save(_existingEntry(existingDay));
      final gateway = _FakeDiaryGateway.success();
      final coordinator = buildCoordinator(gateway);

      final result = await coordinator.start();

      expect(result.generatedDays, <DiaryDayKey>[oldest, newest]);
      expect(gateway.requests.map((request) => request.dayKey), <DiaryDayKey>[
        oldest,
        newest,
      ]);
      expect(await diaries.findLatestForDay(current), isNull);
      expect(await diaries.findLatestForDay(existingDay), isNotNull);

      await coordinator.dispose();
    },
  );

  test('notifies the active day on start and before midnight repair', () async {
    final notifiedDays = <DiaryDayKey>[];
    final coordinator = buildCoordinator(
      _FakeDiaryGateway.success(),
      onActiveDayChanged: notifiedDays.add,
    );

    await coordinator.start();
    expect(notifiedDays.map((day) => day.labelDate.toString()), ['2026-10-04']);

    now = DateTime.utc(2026, 10, 4, 15);
    await timers.fireActive();

    expect(notifiedDays.map((day) => day.labelDate.toString()), [
      '2026-10-04',
      '2026-10-05',
    ]);

    await coordinator.dispose();
  });

  test(
    'empty days and days with an existing diary never call the gateway',
    () async {
      final existingDay = _day(2026, 10, 3);
      await messages.upsert(_message('message-1', existingDay));
      await diaries.save(_existingEntry(existingDay));
      final gateway = _FakeDiaryGateway.success();
      final coordinator = buildCoordinator(gateway);

      await coordinator.start();
      now = DateTime.utc(2026, 10, 4, 15);
      await timers.fireActive();

      expect(gateway.requests, isEmpty);
      expect(entryIds, <String>['entry-1', 'entry-2', 'entry-3']);

      await coordinator.dispose();
    },
  );

  test(
    'a concurrent reconcile is skipped instead of generating twice',
    () async {
      now = DateTime.utc(2026, 10, 4, 1);
      final pastDay = _day(2026, 10, 3);
      await messages.upsert(_message('message-1', pastDay));
      final response = Completer<DiaryGenerationOutput>();
      final gateway = _FakeDiaryGateway((_) => response.future);
      final coordinator = buildCoordinator(gateway);

      final first = coordinator.reconcilePastDays();
      await gateway.firstRequest;
      final concurrent = await coordinator.reconcilePastDays();
      response.complete(_output());
      final completed = await first;

      expect(concurrent.skippedBecauseInProgress, isTrue);
      expect(completed.generatedDays, <DiaryDayKey>[pastDay]);
      expect(gateway.requests, hasLength(1));

      await coordinator.dispose();
    },
  );

  test(
    'failed generation retries on foreground with the same idempotency key',
    () async {
      now = DateTime.utc(2026, 10, 4, 1);
      final pastDay = _day(2026, 10, 3);
      final original = _message('message-1', pastDay);
      await messages.upsert(original);
      var attempt = 0;
      final gateway = _FakeDiaryGateway((_) async {
        attempt += 1;
        if (attempt == 1) {
          throw StateError('offline');
        }
        return _output();
      });
      var coordinator = buildCoordinator(gateway);

      final failed = await coordinator.start();
      expect(failed.error, isA<StateError>());
      expect(failed.failedDay, pastDay);
      expect(await diaries.findLatestForDay(pastDay), isNull);
      final preserved = await messages.listForDay(pastDay);
      expect(preserved, hasLength(1));
      expect(preserved.single, same(original));

      await coordinator.dispose();
      coordinator = buildCoordinator(gateway);
      final retried = await coordinator.start();

      expect(retried.error, isNull);
      expect(retried.generatedDays, <DiaryDayKey>[pastDay]);
      expect(gateway.requests, hasLength(2));
      expect(
        gateway.requests.map((request) => request.generationId).toSet(),
        hasLength(1),
      );
      expect(
        gateway.requests.first.generationId,
        startsWith('daily-close-v1|2026-10-03|'),
      );

      await coordinator.dispose();
    },
  );

  test(
    'injected foreground lifecycle triggers correction after restart',
    () async {
      now = DateTime.utc(2026, 10, 4, 1);
      final gateway = _FakeDiaryGateway.success();
      final coordinator = buildCoordinator(gateway);
      await coordinator.start();
      final pastDay = _day(2026, 10, 3);
      await messages.upsert(_message('late-restored-message', pastDay));

      foregroundEvents.add(null);
      await gateway.firstRequest;

      expect(gateway.requests.single.dayKey, pastDay);
      await coordinator.dispose();
    },
  );

  test('refreshes runtime context before foreground correction', () async {
    now = DateTime.utc(2026, 10, 4, 1);
    final events = <String>[];
    final pastDay = _day(2026, 10, 3);
    final gateway = _FakeDiaryGateway((_) async {
      events.add('generate');
      return _output();
    });
    final coordinator = buildCoordinator(
      gateway,
      prepareForForeground: () async {
        events.add('prepare');
      },
    );
    await coordinator.start();
    await messages.upsert(_message('late-restored-message', pastDay));

    foregroundEvents.add(null);
    await gateway.firstRequest;

    expect(events, ['prepare', 'generate']);
    await coordinator.dispose();
  });

  test(
    'dispose waits for an in-flight repair before storage can close',
    () async {
      now = DateTime.utc(2026, 10, 4, 1);
      final pastDay = _day(2026, 10, 3);
      await messages.upsert(_message('message-1', pastDay));
      final response = Completer<DiaryGenerationOutput>();
      final gateway = _FakeDiaryGateway((_) => response.future);
      final coordinator = buildCoordinator(gateway);
      final run = coordinator.start();
      await gateway.firstRequest;

      var disposeCompleted = false;
      final dispose = coordinator.dispose().then((_) {
        disposeCompleted = true;
      });
      var repeatedDisposeCompleted = false;
      final repeatedDispose = coordinator.dispose().then((_) {
        repeatedDisposeCompleted = true;
      });
      await Future<void>.delayed(Duration.zero);
      expect(disposeCompleted, isFalse);
      expect(repeatedDisposeCompleted, isFalse);

      response.complete(_output());
      await run;
      await dispose;
      await repeatedDispose;

      expect(disposeCompleted, isTrue);
      expect(repeatedDisposeCompleted, isTrue);
      expect(await diaries.findLatestForDay(pastDay), isNotNull);
    },
  );
}

DiaryDayKey _day(int year, int month, int day) {
  return DiaryDayKey.restore(
    labelDate: LocalDate(year, month, day),
    timeZoneId: 'Asia/Seoul',
    cutoff: Duration.zero,
    policyVersion: DiaryDayKey.v1PolicyVersion,
  );
}

Message _message(String id, DiaryDayKey dayKey) {
  return Message(
    id: id,
    requestId: 'request-$id',
    dayKey: dayKey,
    role: MessageRole.user,
    text: '오늘 이야기',
    createdAtUtc: DateTime.utc(
      dayKey.labelDate.year,
      dayKey.labelDate.month,
      dayKey.labelDate.day,
    ),
    status: MessageStatus.sent,
  );
}

DiaryEntry _existingEntry(DiaryDayKey dayKey) {
  return DiaryEntry(
    id: 'existing-${dayKey.labelDate}',
    dayKey: dayKey,
    version: 1,
    status: DiaryEntryStatus.draft,
    weather: const WeatherSnapshot.noWeather(),
    mood: '차분함',
    oneLineSummary: '이미 만든 일기',
    theme: DiaryTheme.light,
    blocks: const <DiaryBlock>[DiaryTextBlock(text: '기존 본문')],
    memoryCandidates: const <DiaryMemoryCandidate>[],
    sourceMessageIds: const <String>[],
    generationId: 'existing-generation-${dayKey.labelDate}',
    generatedAtUtc: DateTime.utc(2026, 10, 3),
    updatedAtUtc: DateTime.utc(2026, 10, 3),
  );
}

DiaryGenerationOutput _output() {
  return DiaryGenerationOutput(
    schemaVersion: DiaryGenerationOutput.currentSchemaVersion,
    mood: '차분함',
    oneLineSummary: '대화를 돌아본 하루',
    theme: DiaryTheme.light,
    blocks: const <DiaryBlock>[DiaryTextBlock(text: '오늘의 기록')],
    memoryCandidates: const <DiaryMemoryCandidate>[],
  );
}

typedef _GenerateHandler = Future<DiaryGenerationOutput> Function(
  DiaryGenerationRequest request,
);

final class _FakeDiaryGateway implements DiaryGenerationGateway {
  _FakeDiaryGateway(this._handler);

  factory _FakeDiaryGateway.success() {
    return _FakeDiaryGateway((_) async => _output());
  }

  final _GenerateHandler _handler;
  final List<DiaryGenerationRequest> requests = <DiaryGenerationRequest>[];
  final Completer<void> _firstRequest = Completer<void>();

  Future<void> get firstRequest => _firstRequest.future;

  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) {
    requests.add(request);
    if (!_firstRequest.isCompleted) {
      _firstRequest.complete();
    }
    return _handler(request);
  }
}

final class _FakeTimerScheduler implements DailyCloseTimerScheduler {
  _FakeScheduledTimer? _active;

  Duration? get lastDelay => _active?.delay;

  @override
  DailyCloseTimer schedule(Duration delay, Future<void> Function() callback) {
    _active?.cancel();
    return _active = _FakeScheduledTimer(delay, callback);
  }

  Future<void> fireActive() async {
    final active = _active;
    if (active == null) {
      throw StateError('No active timer.');
    }
    await active.fire();
  }
}

final class _FakeScheduledTimer implements DailyCloseTimer {
  _FakeScheduledTimer(this.delay, this._callback);

  final Duration delay;
  final Future<void> Function() _callback;
  bool _cancelled = false;

  @override
  void cancel() {
    _cancelled = true;
  }

  Future<void> fire() async {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    await _callback();
  }
}
