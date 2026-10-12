import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/persona/application/persona_controller.dart';
import 'package:namu/features/persona/data/in_memory_ai_persona_repository.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';
import 'package:namu/features/persona/presentation/persona_settings_sheet.dart';

void main() {
  testWidgets('edits and saves the active AI persona', (tester) async {
    final controller = PersonaController(
      repository: InMemoryAiPersonaRepository(),
    );
    addTearDown(controller.dispose);
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => PersonaSettingsSheet(controller: controller),
              ),
              child: const Text('설정 열기'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('설정 열기'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('persona.name.field')), '다온');
    await tester.enterText(
      find.byKey(const Key('persona.tone.field')),
      '차분하고 솔직하게',
    );
    await tester.enterText(
      find.byKey(const Key('persona.instructions.field')),
      '질문은 한 번에 하나만 해줘.',
    );
    await tester.tap(find.byKey(const Key('persona.avatarOption.forest-leaf')));
    await tester.tap(find.text('풍부하게'));
    final saveButton = find.byKey(const Key('persona.save'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(controller.persona.name, '다온');
    expect(controller.persona.avatarSeed, 'forest-leaf');
    expect(controller.persona.tone, '차분하고 솔직하게');
    expect(controller.persona.reactionLength, ReactionLength.expressive);
    expect(find.byType(PersonaSettingsSheet), findsNothing);
  });

  testWidgets('keeps the sheet open and shows validation feedback', (
    tester,
  ) async {
    final controller = PersonaController(
      repository: InMemoryAiPersonaRepository(),
    );
    addTearDown(controller.dispose);
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PersonaSettingsSheet(controller: controller)),
      ),
    );
    await tester.enterText(find.byKey(const Key('persona.name.field')), '   ');
    final saveButton = find.byKey(const Key('persona.save'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('이름과 말투를 확인해 주세요.'), findsOneWidget);
    expect(controller.persona.name, '모아');
  });

  testWidgets('shows only the fixed safe avatar presets', (tester) async {
    final controller = PersonaController(
      repository: InMemoryAiPersonaRepository(),
    );
    addTearDown(controller.dispose);
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PersonaSettingsSheet(controller: controller)),
      ),
    );

    expect(find.byKey(const Key('persona.avatarOption.moa-default')), findsOne);
    expect(find.byKey(const Key('persona.avatarOption.forest-leaf')), findsOne);
    expect(find.byKey(const Key('persona.avatarOption.sunny-spark')), findsOne);
    expect(find.byKey(const Key('persona.avatarOption.quiet-moon')), findsOne);
    expect(find.byKey(const Key('persona.avatarOption.custom')), findsNothing);
  });
}
