import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/persona/application/save_persona.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';
import 'package:namu/features/persona/domain/ai_persona_repository.dart';

void main() {
  test(
    'SavePersona stores the validated persona through the repository port',
    () async {
      final repository = _FakeAiPersonaRepository();
      final persona = AiPersona(
        id: 'persona-1',
        name: '모아',
        avatarSeed: 'forest',
        tone: '친근하고 차분하게',
        customInstructions: '답을 재촉하지 마.',
        reactionLength: ReactionLength.balanced,
      );

      await SavePersona(repository: repository)(persona);

      expect(repository.saved, same(persona));
    },
  );
}

final class _FakeAiPersonaRepository implements AiPersonaRepository {
  AiPersona? saved;

  @override
  Future<AiPersona?> load() async => saved;

  @override
  Future<void> save(AiPersona persona) async {
    saved = persona;
  }
}
