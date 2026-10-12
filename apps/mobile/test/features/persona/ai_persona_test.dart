import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

void main() {
  group('AiPersona', () {
    test('provides a safe usable default persona', () {
      final persona = AiPersona.safeDefault();

      expect(persona.id, isNotEmpty);
      expect(persona.name, isNotEmpty);
      expect(persona.avatarSeed, isNotEmpty);
      expect(persona.tone, isNotEmpty);
      expect(persona.customInstructions, isEmpty);
      expect(persona.reactionLength, ReactionLength.balanced);
    });

    test('builds a safe default from localized display copy', () {
      final persona = AiPersona.safeDefault(
        name: ' Moa ',
        tone: ' Warm and curious ',
      );

      expect(persona.name, 'Moa');
      expect(persona.tone, 'Warm and curious');
      expect(persona.id, 'default');
      expect(persona.avatarSeed, 'moa-default');
    });

    test('normalizes surrounding whitespace', () {
      final persona = AiPersona(
        id: ' persona-1 ',
        name: ' 모아 ',
        avatarSeed: ' seed-1 ',
        tone: ' 다정하게 ',
        customInstructions: ' 이모지는 가끔만 사용해 줘. ',
        reactionLength: ReactionLength.concise,
      );

      expect(persona.id, 'persona-1');
      expect(persona.name, '모아');
      expect(persona.avatarSeed, 'seed-1');
      expect(persona.tone, '다정하게');
      expect(persona.customInstructions, '이모지는 가끔만 사용해 줘.');
    });

    test('rejects blank required text fields', () {
      AiPersona create({
        String id = 'persona-1',
        String name = '모아',
        String avatarSeed = 'seed-1',
        String tone = '따뜻하게',
      }) {
        return AiPersona(
          id: id,
          name: name,
          avatarSeed: avatarSeed,
          tone: tone,
          customInstructions: '',
          reactionLength: ReactionLength.balanced,
        );
      }

      expect(() => create(id: ' '), throwsArgumentError);
      expect(() => create(name: '\n'), throwsArgumentError);
      expect(() => create(avatarSeed: ''), throwsArgumentError);
      expect(() => create(tone: '\t'), throwsArgumentError);
    });

    test('rejects custom instructions beyond the supported bound', () {
      expect(
        () => AiPersona(
          id: 'persona-1',
          name: '모아',
          avatarSeed: 'seed-1',
          tone: '따뜻하게',
          customInstructions: 'a' * (AiPersona.maxCustomInstructionsLength + 1),
          reactionLength: ReactionLength.expressive,
        ),
        throwsArgumentError,
      );
    });
  });
}
