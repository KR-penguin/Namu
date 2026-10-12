import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/consent/application/ai_data_consent_controller.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/consent/presentation/ai_data_consent_gate.dart';
import 'package:namu/features/consent/presentation/ai_data_consent_settings_sheet.dart';

void main() {
  testWidgets(
    'explains transmission and keeps the product hidden until choice',
    (tester) async {
      final controller = AiDataConsentController(
        repository: InMemoryAiDataConsentRepository(),
        utcNow: () => DateTime.utc(2026, 10, 4),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: AiDataConsentGate(
            controller: controller,
            child: const Text('오늘 화면'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI에게 보내는 정보'), findsOneWidget);
      expect(find.textContaining('설정된 AI Gateway'), findsOneWidget);
      expect(find.textContaining('사진 원본은 보내지 않'), findsOneWidget);
      expect(find.text('오늘 화면'), findsNothing);

      await tester.tap(find.byKey(const Key('ai-consent.accept')));
      await tester.pumpAndSettle();

      expect(controller.allowsAiRequests, isTrue);
      expect(find.text('오늘 화면'), findsOneWidget);
    },
  );

  testWidgets('local-only choice enters the product but keeps AI blocked', (
    tester,
  ) async {
    final controller = AiDataConsentController(
      repository: InMemoryAiDataConsentRepository(),
      utcNow: () => DateTime.utc(2026, 10, 4),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AiDataConsentGate(
          controller: controller,
          child: const Text('오늘 화면'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-consent.decline')));
    await tester.pumpAndSettle();

    expect(controller.allowsAiRequests, isFalse);
    expect(find.text('오늘 화면'), findsOneWidget);
  });

  testWidgets('settings shows current status and supports revocation', (
    tester,
  ) async {
    final controller = AiDataConsentController(
      repository: InMemoryAiDataConsentRepository(),
      utcNow: () => DateTime.utc(2026, 10, 4),
    );
    addTearDown(controller.dispose);
    await controller.load();
    await controller.accept();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiDataConsentSettingsSheet(controller: controller),
        ),
      ),
    );

    expect(find.text('AI 데이터 전송: 동의함'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ai-consent.revoke')));
    await tester.pumpAndSettle();

    expect(controller.allowsAiRequests, isFalse);
    expect(find.text('AI 데이터 전송: 동의하지 않음'), findsOneWidget);
  });
}
