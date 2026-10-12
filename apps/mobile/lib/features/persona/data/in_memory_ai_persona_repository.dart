import '../domain/ai_persona.dart';
import '../domain/ai_persona_repository.dart';

final class InMemoryAiPersonaRepository implements AiPersonaRepository {
  AiPersona? _persona;

  @override
  Future<AiPersona?> load() async => _persona;

  @override
  Future<void> save(AiPersona persona) async {
    _persona = persona;
  }
}
