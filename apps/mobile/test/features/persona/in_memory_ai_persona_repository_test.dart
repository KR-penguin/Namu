import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/persona/data/in_memory_ai_persona_repository.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

void main() {
  test('starts empty and returns the last saved persona', () async {
    final repository = InMemoryAiPersonaRepository();
    final persona = AiPersona(
      id: 'persona-1',
      name: '다온',
      avatarSeed: 'leaf',
      tone: '다정하고 솔직하게',
      customInstructions: '질문은 한 번에 하나만 해줘.',
      reactionLength: ReactionLength.balanced,
    );

    expect(await repository.load(), isNull);
    await repository.save(persona);

    expect(await repository.load(), same(persona));
  });
}
