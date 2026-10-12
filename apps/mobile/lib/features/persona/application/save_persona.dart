import 'package:namu/features/persona/domain/ai_persona.dart';
import 'package:namu/features/persona/domain/ai_persona_repository.dart';

final class SavePersona {
  const SavePersona({required this.repository});

  final AiPersonaRepository repository;

  Future<void> call(AiPersona persona) => repository.save(persona);
}
