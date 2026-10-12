import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/app/namu_app.dart';
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';

import '../chat/support/fake_message_repository.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('ko', 'KR'),
    ];
  });

  tearDown(() {
    binding.platformDispatcher.clearLocaleTestValue();
    binding.platformDispatcher.clearLocalesTestValue();
  });

  testWidgets('describes a diary safety block as a model safety decision', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.utc(2026, 10, 4, 8);
    final localNow = now.toLocal();
    final dayKey = DiaryDayKey.fromInstant(
      instant: now,
      timeZone: TimeZoneSnapshot(
        timeZoneId: localNow.timeZoneName,
        utcOffset: localNow.timeZoneOffset,
      ),
    );
    final messages = FakeMessageRepository();
    await messages.upsert(
      Message(
        id: 'message-1',
        requestId: 'request-1',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '오늘 기록',
        createdAtUtc: now,
        status: MessageStatus.sent,
      ),
    );

    await tester.pumpWidget(
      NamuApp(
        messageRepository: messages,
        diaryGenerationGateway: const _FailingDiaryGateway(
          GatewayException.safetyBlocked(422),
        ),
        gatewayConfigured: true,
        utcNow: () => now,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('오늘의 일기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('diary.generate')));
    await tester.pumpAndSettle();

    expect(find.textContaining('AI 안전 기준'), findsOneWidget);
    expect(find.textContaining('오늘 기록은 기기에 남아 있어요'), findsOneWidget);
    expect(find.textContaining('422'), findsNothing);
  });
}

final class _FailingDiaryGateway implements DiaryGenerationGateway {
  const _FailingDiaryGateway(this.failure);

  final Object failure;

  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) {
    return Future<DiaryGenerationOutput>.error(failure);
  }
}
