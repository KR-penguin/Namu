import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/features/persona/data/drift_ai_persona_repository.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

void main() {
  late AppDatabase database;
  late DriftAiPersonaRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftAiPersonaRepository(database);
  });

  tearDown(() => database.close());

  test('starts empty and round-trips every persona field', () async {
    expect(await repository.load(), isNull);
    final persona = _persona(reactionLength: ReactionLength.expressive);

    await repository.save(persona);
    final restored = await repository.load();

    expect(restored?.id, persona.id);
    expect(restored?.name, persona.name);
    expect(restored?.avatarSeed, persona.avatarSeed);
    expect(restored?.tone, persona.tone);
    expect(restored?.customInstructions, persona.customInstructions);
    expect(restored?.reactionLength, persona.reactionLength);
  });

  test('one singleton row keeps the last saved persona', () async {
    await repository.save(_persona());
    await repository.save(
      _persona(
        id: 'persona-2',
        name: '다온',
        reactionLength: ReactionLength.concise,
      ),
    );

    final rows = await database.select(database.aiPersonaRecords).get();
    expect(rows, hasLength(1));
    expect((await repository.load())?.id, 'persona-2');
    expect((await repository.load())?.name, '다온');
    expect((await repository.load())?.reactionLength, ReactionLength.concise);
  });
}

AiPersona _persona({
  String id = 'persona-1',
  String name = '모아',
  ReactionLength reactionLength = ReactionLength.balanced,
}) {
  return AiPersona(
    id: id,
    name: name,
    avatarSeed: 'forest-leaf',
    tone: '다정하고 솔직하게',
    customInstructions: '질문은 한 번에 하나만 해줘.',
    reactionLength: reactionLength,
  );
}
