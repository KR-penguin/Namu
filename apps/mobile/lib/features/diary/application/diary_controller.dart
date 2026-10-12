// The public `dayKey` constructor name initializes private mutable rollover state.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../core/l10n/ai_response_locale.dart';
import '../../../core/time/diary_day_key.dart';
import '../../chat/domain/message.dart';
import '../../chat/domain/message_repository.dart';
import '../../persona/domain/ai_persona.dart';
import '../domain/diary_entry.dart';
import '../domain/diary_generation_gateway.dart';
import '../domain/diary_generation_output.dart';
import '../domain/diary_repository.dart';
import '../domain/weather_snapshot.dart';
import 'create_diary_draft.dart';

typedef DiaryPersonaProvider = AiPersona Function();
typedef DiaryWeatherProvider = Future<WeatherSnapshot> Function();

final class DiaryController extends ChangeNotifier {
  DiaryController({
    required DiaryDayKey dayKey,
    required this.diaryRepository,
    required this.messageRepository,
    required this.generationGateway,
    required this.responseLocaleProvider,
    required this.personaProvider,
    required this.weatherProvider,
    required this.nextId,
    required this.utcNow,
  }) : _dayKey = dayKey;

  DiaryDayKey _dayKey;
  final DiaryRepository diaryRepository;
  final MessageRepository messageRepository;
  final DiaryGenerationGateway generationGateway;
  final AiResponseLocale Function() responseLocaleProvider;
  final DiaryPersonaProvider personaProvider;
  final DiaryWeatherProvider weatherProvider;
  final String Function() nextId;
  final DateTime Function() utcNow;

  DiaryEntry? _entry;
  List<Message> _sourceMessages = const [];
  String? _pendingGenerationId;
  int _activeLoadCount = 0;
  bool _isGenerating = false;
  bool _isSaving = false;
  Object? _error;

  DiaryEntry? get entry => _entry;
  DiaryDayKey get dayKey => _dayKey;
  bool get canGenerate => _sourceMessages.isNotEmpty;
  bool get isLoading => _activeLoadCount > 0;
  bool get isGenerating => _isGenerating;
  bool get isSaving => _isSaving;
  Object? get error => _error;

  Future<void> load() async {
    final targetDay = dayKey;
    _activeLoadCount += 1;
    _error = null;
    notifyListeners();

    try {
      final loadedEntry = await diaryRepository.findLatestForDay(targetDay);
      final loadedMessages = await messageRepository.listForDay(targetDay);
      if (dayKey == targetDay) {
        _entry = loadedEntry;
        _sourceMessages = loadedMessages;
      }
    } catch (error) {
      if (dayKey == targetDay) {
        _error = error;
      }
      rethrow;
    } finally {
      _activeLoadCount -= 1;
      notifyListeners();
    }
  }

  Future<void> switchDay(DiaryDayKey nextDay) async {
    if (nextDay == dayKey) {
      return;
    }
    _dayKey = nextDay;
    _entry = null;
    _sourceMessages = const [];
    _pendingGenerationId = null;
    _error = null;
    notifyListeners();
    await load();
  }

  Future<void> refreshSources() async {
    final targetDay = dayKey;
    try {
      final sourceMessages = await messageRepository.listForDay(targetDay);
      if (dayKey == targetDay) {
        _sourceMessages = sourceMessages;
      }
      notifyListeners();
    } catch (error) {
      if (dayKey == targetDay) {
        _error = error;
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> generate() async {
    if (_isGenerating) {
      throw StateError('A diary generation is already in progress.');
    }
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final generationDay = dayKey;
      final sourceMessages = await messageRepository.listForDay(generationDay);
      if (dayKey == generationDay) {
        _sourceMessages = sourceMessages;
      }
      if (sourceMessages.isEmpty) {
        throw StateError('A diary requires at least one source message.');
      }

      final generationId = _pendingGenerationId ??= nextId();
      final weather = await weatherProvider();
      final output = await generationGateway.generate(
        DiaryGenerationRequest(
          responseLocale: responseLocaleProvider(),
          generationId: generationId,
          dayKey: generationDay,
          weather: weather,
          persona: personaProvider(),
          messages: sourceMessages,
        ),
      );
      final createDraft = CreateDiaryDraft(
        repository: diaryRepository,
        nextId: nextId,
        utcNow: utcNow,
      );
      final createdEntry = await createDraft(
        CreateDiaryDraftCommand(
          generationId: generationId,
          dayKey: generationDay,
          weather: weather,
          output: output,
          sourceMessageIds: [for (final message in sourceMessages) message.id],
        ),
      );
      if (dayKey == generationDay) {
        _entry = createdEntry;
        _pendingGenerationId = null;
      }
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> finalize() async {
    final current = _entry;
    if (current == null) {
      throw StateError('There is no diary to finalize.');
    }
    if (current.status == DiaryEntryStatus.finalized) {
      return;
    }
    if (_isSaving) {
      throw StateError('The diary is already being saved.');
    }
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final finalized = current.finalize(updatedAtUtc: utcNow());
      await diaryRepository.save(finalized);
      if (dayKey == finalized.dayKey) {
        _entry = finalized;
      }
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> edit({
    WeatherSnapshot? weather,
    required String mood,
    required String oneLineSummary,
    required DiaryTheme theme,
    required Iterable<DiaryBlock> blocks,
  }) async {
    final current = _entry;
    if (current == null) {
      throw StateError('There is no diary to edit.');
    }
    if (_isSaving) {
      throw StateError('The diary is already being saved.');
    }
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final revised = current.revise(
        weather: weather ?? current.weather,
        mood: mood,
        oneLineSummary: oneLineSummary,
        theme: theme,
        blocks: blocks,
        updatedAtUtc: utcNow(),
      );
      await diaryRepository.save(revised);
      if (dayKey == revised.dayKey) {
        _entry = revised;
      }
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
