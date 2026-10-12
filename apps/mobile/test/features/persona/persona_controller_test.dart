import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/persona/application/persona_controller.dart';
import 'package:namu/features/persona/data/in_memory_ai_persona_repository.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

void main() {
  test('uses the safe default when no persona was saved', () async {
    final controller = PersonaController(
      repository: InMemoryAiPersonaRepository(),
    );

    await controller.load();

    expect(controller.persona.name, '모아');
    expect(controller.isLoading, isFalse);
    expect(controller.error, isNull);
  });

  test(
    'uses the supplied localized default only when storage is empty',
    () async {
      final controller = PersonaController(
        repository: InMemoryAiPersonaRepository(),
        initialPersona: AiPersona.safeDefault(name: 'モア', tone: '温かく好奇心を持って'),
      );

      await controller.load();

      expect(controller.persona.name, 'モア');
      expect(controller.persona.tone, '温かく好奇心を持って');
    },
  );

  test('never translates or replaces a stored persona', () async {
    final repository = InMemoryAiPersonaRepository();
    final stored = AiPersona(
      id: 'user-persona',
      name: 'Luna',
      avatarSeed: 'quiet-moon',
      tone: 'Habla con calma',
      customInstructions: 'No traduzcas mis preferencias.',
      reactionLength: ReactionLength.concise,
    );
    await repository.save(stored);
    final controller = PersonaController(
      repository: repository,
      initialPersona: AiPersona.safeDefault(name: 'モア', tone: '温かく好奇心を持って'),
    );

    await controller.load();

    expect(controller.persona, same(stored));
    expect(controller.persona.name, 'Luna');
    expect(controller.persona.tone, 'Habla con calma');
    expect(
      controller.persona.customInstructions,
      'No traduzcas mis preferencias.',
    );
  });

  test(
    'keeps its first localized default when the locale source changes',
    () async {
      var currentDefault = AiPersona.safeDefault(
        name: 'Moa',
        tone: 'Warm and curious',
      );
      final controller = PersonaController(
        repository: InMemoryAiPersonaRepository(),
        initialPersona: currentDefault,
      );
      currentDefault = AiPersona.safeDefault(name: 'モア', tone: '温かく好奇心を持って');

      await controller.load();

      expect(currentDefault.name, 'モア');
      expect(controller.persona.name, 'Moa');
      expect(controller.persona.tone, 'Warm and curious');
    },
  );

  test('validates, saves, and publishes edited persona fields', () async {
    final repository = InMemoryAiPersonaRepository();
    final controller = PersonaController(repository: repository);
    await controller.load();

    await controller.save(
      name: '다온',
      tone: '차분하고 솔직하게',
      customInstructions: '질문은 한 번에 하나만 해줘.',
      reactionLength: ReactionLength.expressive,
    );

    expect(controller.persona.name, '다온');
    expect(controller.persona.reactionLength, ReactionLength.expressive);
    expect((await repository.load())?.tone, '차분하고 솔직하게');
    expect(controller.isSaving, isFalse);
  });

  test('persists the selected avatar seed with the edited persona', () async {
    final repository = InMemoryAiPersonaRepository();
    final controller = PersonaController(repository: repository);
    await controller.load();

    await controller.save(
      name: '다온',
      avatarSeed: 'forest-leaf',
      tone: '차분하고 솔직하게',
      customInstructions: '',
      reactionLength: ReactionLength.balanced,
    );

    expect(controller.persona.avatarSeed, 'forest-leaf');
    expect((await repository.load())?.avatarSeed, 'forest-leaf');
  });

  test('keeps the previous persona when validation fails', () async {
    final controller = PersonaController(
      repository: InMemoryAiPersonaRepository(),
    );
    await controller.load();

    await expectLater(
      controller.save(
        name: '   ',
        tone: '다정하게',
        customInstructions: '',
        reactionLength: ReactionLength.concise,
      ),
      throwsArgumentError,
    );

    expect(controller.persona.name, '모아');
    expect(controller.isSaving, isFalse);
    expect(controller.error, isA<ArgumentError>());
  });
}
