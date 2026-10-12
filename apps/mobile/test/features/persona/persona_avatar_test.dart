import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/persona/presentation/persona_avatar.dart';

void main() {
  test('resolves known presets and safely falls back for unknown seeds', () {
    expect(PersonaAvatarPreset.resolve('forest-leaf').seed, 'forest-leaf');
    expect(
      PersonaAvatarPreset.resolve('untrusted-custom-value').seed,
      'moa-default',
    );
    expect(PersonaAvatarPreset.values, hasLength(4));
  });

  testWidgets('renders the icon and an accessible profile label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PersonaAvatar(
          avatarSeed: 'sunny-spark',
          semanticLabel: 'AI 친구 다온의 프로필',
        ),
      ),
    );

    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('AI 친구 다온의 프로필'), findsOneWidget);
  });
}
