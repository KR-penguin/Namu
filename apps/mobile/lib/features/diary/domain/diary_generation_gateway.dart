import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

final class DiaryGenerationRequest {
  DiaryGenerationRequest({
    required this.responseLocale,
    required this.generationId,
    required this.dayKey,
    required this.weather,
    required this.persona,
    required Iterable<Message> messages,
  }) : messages = List<Message>.unmodifiable(messages) {
    if (generationId.trim().isEmpty) {
      throw ArgumentError.value(
        generationId,
        'generationId',
        'must not be blank',
      );
    }
    if (this.messages.any((message) => message.dayKey != dayKey)) {
      throw ArgumentError(
        'messages must all belong to the requested DiaryDayKey',
      );
    }
  }

  final AiResponseLocale responseLocale;
  final String generationId;
  final DiaryDayKey dayKey;
  final WeatherSnapshot weather;
  final AiPersona persona;
  final List<Message> messages;
}

abstract interface class DiaryGenerationGateway {
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request);
}
