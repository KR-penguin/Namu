import 'package:namu/features/persona/domain/ai_persona.dart';

abstract interface class AiPersonaRepository {
  Future<AiPersona?> load();

  Future<void> save(AiPersona persona);
}
