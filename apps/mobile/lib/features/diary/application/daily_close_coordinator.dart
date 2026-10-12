import 'dart:async';

import '../../../core/l10n/ai_response_locale.dart';
import '../../../core/time/diary_day_key.dart';
import '../../chat/domain/message_repository.dart';
import '../../persona/domain/ai_persona.dart';
import '../../persona/domain/ai_persona_repository.dart';
import '../domain/diary_generation_gateway.dart';
import '../domain/diary_repository.dart';
import '../domain/weather_snapshot.dart';
import 'create_diary_draft.dart';
import 'daily_close_schedule.dart';

typedef DailyCloseWeatherProvider = Future<WeatherSnapshot> Function(
  DiaryDayKey dayKey,
);
typedef DailyCloseUtcClock = DateTime Function();
typedef ActiveDiaryDayChanged = void Function(DiaryDayKey dayKey);
typedef PrepareForDailyCloseForeground = Future<void> Function();

abstract interface class DailyCloseTimer {
  void cancel();
}

abstract interface class DailyCloseTimerScheduler {
  DailyCloseTimer schedule(Duration delay, Future<void> Function() callback);
}

final class DailyCloseRunResult {
  DailyCloseRunResult._({
    required Iterable<DiaryDayKey> generatedDays,
    required this.skippedBecauseInProgress,
    this.failedDay,
    this.error,
  }) : generatedDays = List<DiaryDayKey>.unmodifiable(generatedDays);

  factory DailyCloseRunResult.completed({
    Iterable<DiaryDayKey> generatedDays = const <DiaryDayKey>[],
  }) {
    return DailyCloseRunResult._(
      generatedDays: generatedDays,
      skippedBecauseInProgress: false,
    );
  }

  factory DailyCloseRunResult.failed({
    required Iterable<DiaryDayKey> generatedDays,
    required Object error,
    DiaryDayKey? failedDay,
  }) {
    return DailyCloseRunResult._(
      generatedDays: generatedDays,
      skippedBecauseInProgress: false,
      failedDay: failedDay,
      error: error,
    );
  }

  factory DailyCloseRunResult.concurrentSkip() {
    return DailyCloseRunResult._(
      generatedDays: const <DiaryDayKey>[],
      skippedBecauseInProgress: true,
    );
  }

  final List<DiaryDayKey> generatedDays;
  final bool skippedBecauseInProgress;
  final DiaryDayKey? failedDay;
  final Object? error;
}

/// Best-effort in-process daily diary generation with foreground repair.
///
/// Mobile operating systems do not guarantee execution at midnight. The timer
/// improves the active-app experience, while every foreground event repairs
/// message days that have closed without a diary.
final class DailyCloseCoordinator {
  DailyCloseCoordinator({
    required this.messageRepository,
    required this.diaryRepository,
    required this.generationGateway,
    required this.responseLocaleProvider,
    required this.personaRepository,
    required this.weatherProvider,
    required this.utcNow,
    required this.schedule,
    required this.timerScheduler,
    required this.foregroundEvents,
    required this.nextEntryId,
    this.onActiveDayChanged,
    this.prepareForForeground,
  });

  final MessageRepository messageRepository;
  final DiaryRepository diaryRepository;
  final DiaryGenerationGateway generationGateway;
  final AiResponseLocale Function() responseLocaleProvider;
  final AiPersonaRepository personaRepository;
  final DailyCloseWeatherProvider weatherProvider;
  final DailyCloseUtcClock utcNow;
  final DiaryDaySchedule schedule;
  final DailyCloseTimerScheduler timerScheduler;
  final Stream<void> foregroundEvents;
  final String Function() nextEntryId;
  final ActiveDiaryDayChanged? onActiveDayChanged;
  final PrepareForDailyCloseForeground? prepareForForeground;

  StreamSubscription<void>? _foregroundSubscription;
  DailyCloseTimer? _timer;
  Completer<void>? _activeReconcile;
  Future<void>? _disposeOperation;
  DiaryDayKey? _lastNotifiedActiveDay;
  bool _isDisposed = false;

  Future<DailyCloseRunResult> start() {
    _ensureActive();
    _foregroundSubscription ??= foregroundEvents.listen((_) {
      if (_isDisposed) {
        return;
      }
      unawaited(_onForegroundEvent());
    });
    return onForeground();
  }

  Future<void> _onForegroundEvent() async {
    try {
      await prepareForForeground?.call();
    } catch (_) {
      // The last valid time-zone rules remain usable after a refresh failure.
    }
    if (_isDisposed) {
      return;
    }
    await onForeground();
  }

  Future<DailyCloseRunResult> onForeground() {
    _ensureActive();
    _notifyActiveDay();
    _scheduleNextBoundary();
    return reconcilePastDays();
  }

  Future<DailyCloseRunResult> reconcilePastDays() async {
    _ensureActive();
    if (_activeReconcile != null) {
      return DailyCloseRunResult.concurrentSkip();
    }
    final activeReconcile = Completer<void>();
    _activeReconcile = activeReconcile;
    final generatedDays = <DiaryDayKey>[];
    DiaryDayKey? failedDay;

    try {
      final activeDay = schedule.dayKeyAt(_readUtcNow());
      final messageDays = await messageRepository.listDayKeysOldestFirst();
      for (final dayKey in messageDays) {
        if (!_isCalendarDateBefore(dayKey, activeDay)) {
          continue;
        }
        failedDay = dayKey;
        final generated = await _generateIfNeeded(dayKey);
        if (generated) {
          generatedDays.add(dayKey);
        }
        failedDay = null;
      }
      return DailyCloseRunResult.completed(generatedDays: generatedDays);
    } catch (error) {
      return DailyCloseRunResult.failed(
        generatedDays: generatedDays,
        failedDay: failedDay,
        error: error,
      );
    } finally {
      activeReconcile.complete();
      if (identical(_activeReconcile, activeReconcile)) {
        _activeReconcile = null;
      }
    }
  }

  Future<void> dispose() => _disposeOperation ??= _dispose();

  Future<void> _dispose() async {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    await _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
    final activeReconcile = _activeReconcile;
    if (activeReconcile != null) {
      await activeReconcile.future;
    }
  }

  void _scheduleNextBoundary() {
    final now = _readUtcNow();
    final boundary = schedule.nextBoundaryAfter(now);
    final delay = boundary.difference(now);
    if (delay <= Duration.zero) {
      throw StateError('The next diary boundary must be in the future.');
    }

    _timer?.cancel();
    _timer = timerScheduler.schedule(delay, () async {
      if (_isDisposed) {
        return;
      }
      _notifyActiveDay();
      _scheduleNextBoundary();
      await reconcilePastDays();
    });
  }

  void _notifyActiveDay() {
    final callback = onActiveDayChanged;
    if (callback == null) {
      return;
    }
    final activeDay = schedule.dayKeyAt(_readUtcNow());
    if (activeDay == _lastNotifiedActiveDay) {
      return;
    }
    callback(activeDay);
    _lastNotifiedActiveDay = activeDay;
  }

  Future<bool> _generateIfNeeded(DiaryDayKey dayKey) async {
    if (await diaryRepository.findLatestForDay(dayKey) != null) {
      return false;
    }
    final sourceMessages = await messageRepository.listForDay(dayKey);
    if (sourceMessages.isEmpty) {
      return false;
    }

    final generationId = _generationIdFor(dayKey);
    final weather = await weatherProvider(dayKey);
    final persona = await personaRepository.load() ?? AiPersona.safeDefault();
    final output = await generationGateway.generate(
      DiaryGenerationRequest(
        responseLocale: responseLocaleProvider(),
        generationId: generationId,
        dayKey: dayKey,
        weather: weather,
        persona: persona,
        messages: sourceMessages,
      ),
    );

    // A manual generation may have completed while the gateway was running.
    if (await diaryRepository.findLatestForDay(dayKey) != null) {
      return false;
    }
    final createDraft = CreateDiaryDraft(
      repository: diaryRepository,
      nextId: nextEntryId,
      utcNow: _readUtcNow,
    );
    await createDraft(
      CreateDiaryDraftCommand(
        generationId: generationId,
        dayKey: dayKey,
        weather: weather,
        output: output,
        sourceMessageIds: <String>[
          for (final message in sourceMessages) message.id,
        ],
      ),
    );
    return true;
  }

  DateTime _readUtcNow() {
    final now = utcNow();
    if (!now.isUtc) {
      throw StateError('utcNow must return a UTC instant.');
    }
    return now;
  }

  void _ensureActive() {
    if (_isDisposed) {
      throw StateError('DailyCloseCoordinator is disposed.');
    }
  }

  static bool _isCalendarDateBefore(DiaryDayKey candidate, DiaryDayKey active) {
    final candidateDate = candidate.labelDate;
    final activeDate = active.labelDate;
    if (candidateDate.year != activeDate.year) {
      return candidateDate.year < activeDate.year;
    }
    if (candidateDate.month != activeDate.month) {
      return candidateDate.month < activeDate.month;
    }
    return candidateDate.day < activeDate.day;
  }

  static String _generationIdFor(DiaryDayKey dayKey) {
    final value = <String>[
      'daily-close-v1',
      dayKey.labelDate.toString(),
      Uri.encodeComponent(dayKey.timeZoneId),
      dayKey.cutoff.inMicroseconds.toString(),
      dayKey.policyVersion.toString(),
    ].join('|');
    if (value.length > 128) {
      throw StateError('The diary day identity is too long for generation.');
    }
    return value;
  }
}
