import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/application/chat_controller.dart';
import 'package:namu/features/chat/application/send_message.dart';
import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/chat/presentation/conversation_panel.dart';
import 'package:namu/features/media/presentation/local_photo.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';
import 'package:namu/features/persona/presentation/persona_avatar.dart';
import 'package:namu/l10n/app_localizations.dart';

import 'support/fake_chat_reply_gateway.dart';
import 'support/fake_message_repository.dart';

void main() {
  late FakeMessageRepository repository;
  late List<String> ids;

  setUp(() {
    repository = FakeMessageRepository();
    ids = ['message-1', 'request-1', 'message-2', 'request-2'];
  });

  ChatController buildController(ChatReplyGateway gateway) {
    final dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    return ChatController(
      dayKey: dayKey,
      repository: repository,
      sendMessage: SendMessage(repository: repository, replyGateway: gateway),
      utcNow: () => DateTime.utc(2026, 10, 4, 8),
      nextId: () => ids.removeAt(0),
    );
  }

  Future<void> pumpPanel(
    WidgetTester tester, {
    required ChatController controller,
    VoidCallback? onShowDiary,
    VoidCallback? onAttachPhoto,
    VoidCallback? onEditPersona,
    LocalPhotoBytesLoader? photoBytesLoader,
    bool gatewayConfigured = true,
    AiPersona? persona,
    Size size = const Size(360, 720),
    Locale locale = const Locale('ko'),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ConversationPanel(
            controller: controller,
            persona: persona ?? AiPersona.safeDefault(),
            gatewayConfigured: gatewayConfigured,
            onShowDiary: onShowDiary ?? () {},
            onAttachPhoto: onAttachPhoto,
            onEditPersona: onEditPersona,
            photoBytesLoader: photoBytesLoader,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders an honest empty state without sample messages', (
    tester,
  ) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await pumpPanel(tester, controller: controller, gatewayConfigured: false);

    expect(find.byKey(const Key('conversation.live.panel')), findsOneWidget);
    expect(find.text('모아'), findsOneWidget);
    expect(find.text('AI 연결 필요'), findsOneWidget);
    expect(find.text('오늘 있었던 일을 들려주세요'), findsWidgets);
    expect(find.byKey(const Key('conversation.message.user')), findsNothing);
    expect(
      find.byKey(const Key('conversation.message.assistant')),
      findsNothing,
    );
    expect(find.text('오늘의 일기 보기'), findsOneWidget);
    expect(find.byTooltip('사진 첨부'), findsOneWidget);
    expect(find.byTooltip('메시지 보내기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'localizes English chrome without translating conversation data',
    (tester) async {
      final controller = buildController(
        FakeChatReplyGateway(
          onReply: (_) => throw StateError('must not be called'),
        ),
      );
      await repository.upsert(
        Message(
          id: 'user-existing',
          requestId: 'request-existing-user',
          dayKey: controller.dayKey,
          role: MessageRole.user,
          text: '퇴근길의 노을은 그대로 남겨줘',
          createdAtUtc: DateTime.utc(2026, 10, 4, 8),
          status: MessageStatus.sent,
        ),
      );
      await repository.upsert(
        Message(
          id: 'assistant-existing',
          requestId: 'request-existing-assistant',
          dayKey: controller.dayKey,
          role: MessageRole.assistant,
          text: '사용자가 저장한 AI 답변도 바꾸지 마',
          createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
          status: MessageStatus.sent,
        ),
      );

      await pumpPanel(
        tester,
        controller: controller,
        locale: const Locale('en'),
      );

      expect(find.text('View today’s diary'), findsOneWidget);
      expect(find.byTooltip('Attach photo'), findsOneWidget);
      expect(find.byTooltip('Send message'), findsOneWidget);
      expect(find.text('퇴근길의 노을은 그대로 남겨줘'), findsOneWidget);
      expect(find.text('사용자가 저장한 AI 답변도 바꾸지 마'), findsOneWidget);
    },
  );

  testWidgets('configured endpoint is not presented as a verified connection', (
    tester,
  ) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await pumpPanel(tester, controller: controller);

    expect(find.text('AI 준비됨'), findsOneWidget);
    expect(find.textContaining('Gateway'), findsNothing);
    expect(find.text('AI 연결됨'), findsNothing);
  });

  testWidgets('forwards photo attachment intent', (tester) async {
    var attachCount = 0;
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await pumpPanel(
      tester,
      controller: controller,
      onAttachPhoto: () => attachCount += 1,
    );

    await tester.tap(find.byTooltip('사진 첨부'));
    await tester.pump();

    expect(attachCount, 1);
  });

  testWidgets('opens AI persona settings from the profile action', (
    tester,
  ) async {
    var editCount = 0;
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await pumpPanel(
      tester,
      controller: controller,
      onEditPersona: () => editCount += 1,
    );

    await tester.tap(find.byTooltip('AI 친구 설정'));
    await tester.pump();

    expect(editCount, 1);
  });

  testWidgets('opens today diary from its explicit call to action', (
    tester,
  ) async {
    var callCount = 0;
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await pumpPanel(
      tester,
      controller: controller,
      onShowDiary: () => callCount += 1,
    );

    await tester.tap(find.byKey(const Key('conversation.openDiary')));
    await tester.pump();

    expect(callCount, 1);
  });

  testWidgets('persists a user message and renders the AI reply', (
    tester,
  ) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) async => ChatReply(
          messageId: 'assistant-1',
          text: '노을을 보고 어떤 기분이 들었어?',
          createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
        ),
      ),
    );
    await pumpPanel(tester, controller: controller);

    const localMessage = '퇴근길에 노을이 정말 예뻤어';
    final field = find.byKey(const Key('conversation.composer.field'));
    await tester.enterText(field, localMessage);
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pumpAndSettle();

    expect(find.text(localMessage), findsOneWidget);
    expect(find.text('노을을 보고 어떤 기분이 들었어?'), findsOneWidget);
    expect(find.byKey(const Key('conversation.message.user')), findsOneWidget);
    expect(
      find.byKey(const Key('conversation.message.assistant')),
      findsOneWidget,
    );
    expect(repository.messages, hasLength(2));
    expect(tester.widget<TextField>(field).controller?.text, isEmpty);
  });

  testWidgets('uses the selected avatar in the header and assistant bubble', (
    tester,
  ) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await repository.upsert(
      Message(
        id: 'assistant-existing',
        requestId: 'request-existing',
        dayKey: controller.dayKey,
        role: MessageRole.assistant,
        text: '오늘 이야기를 들려줘.',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8),
        status: MessageStatus.sent,
      ),
    );
    final persona = AiPersona(
      id: 'default',
      name: '다온',
      avatarSeed: 'quiet-moon',
      tone: '차분하게',
      customInstructions: '',
      reactionLength: ReactionLength.balanced,
    );

    await pumpPanel(tester, controller: controller, persona: persona);

    final header = tester.widget<PersonaAvatar>(
      find.byKey(const Key('conversation.avatar.header')),
    );
    final assistant = tester.widget<PersonaAvatar>(
      find.byKey(const Key('conversation.avatar.assistant')),
    );
    expect(header.avatarSeed, 'quiet-moon');
    expect(assistant.avatarSeed, header.avatarSeed);
    expect(find.byIcon(Icons.dark_mode_rounded), findsNWidgets(2));
  });

  testWidgets('renders locally resolved photo bytes inside a chat bubble', (
    tester,
  ) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await repository.upsert(
      Message(
        id: 'photo-message',
        requestId: 'photo-request',
        dayKey: controller.dayKey,
        role: MessageRole.user,
        photoAssetId: 'photo-1',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8),
        status: MessageStatus.sent,
      ),
    );

    await pumpPanel(
      tester,
      controller: controller,
      photoBytesLoader: (_) async => _onePixelPng,
    );

    expect(find.byKey(const Key('localPhoto.image')), findsOneWidget);
    expect(find.byIcon(Icons.photo_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the failed local message and explains retry state', (
    tester,
  ) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => Future<ChatReply>.error(StateError('offline')),
      ),
    );
    await pumpPanel(tester, controller: controller);

    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      '연결이 끊겨도 남겨줘',
    );
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pumpAndSettle();

    expect(find.text('연결이 끊겨도 남겨줘'), findsOneWidget);
    expect(find.text('AI 답변을 받지 못했어요'), findsOneWidget);
    expect(repository.messages.single.status, MessageStatus.failed);
  });

  testWidgets('explains a model safety block without exposing server details', (
    tester,
  ) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) =>
            Future<ChatReply>.error(const GatewayException.safetyBlocked(422)),
      ),
    );
    await pumpPanel(tester, controller: controller);

    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      '기기에 남겨둘 메시지',
    );
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('AI 안전 기준'), findsOneWidget);
    expect(find.textContaining('메시지는 기기에 남아 있어요'), findsOneWidget);
    expect(find.textContaining('422'), findsNothing);
    expect(repository.messages.single.status, MessageStatus.failed);
  });

  testWidgets('shows the bounded retry time for rate limiting', (tester) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => Future<ChatReply>.error(
          const GatewayException.rateLimited(
            429,
            retryAfter: Duration(seconds: 61),
          ),
        ),
      ),
    );
    await pumpPanel(tester, controller: controller);

    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      '잠시 뒤 다시 보낼 메시지',
    );
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('약 2분 후'), findsOneWidget);
    expect(find.textContaining('429'), findsNothing);
  });

  testWidgets('restores an interrupted pending message as retryable on load', (
    tester,
  ) async {
    var gatewayCalls = 0;
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) async {
          gatewayCalls += 1;
          throw StateError('must not be called during recovery');
        },
      ),
    );
    await repository.upsert(
      Message(
        id: 'interrupted-user',
        requestId: 'interrupted-request',
        dayKey: controller.dayKey,
        role: MessageRole.user,
        text: '종료 전에 남은 메시지',
        createdAtUtc: DateTime.utc(2026, 10, 4, 7),
        status: MessageStatus.pending,
      ),
    );

    await pumpPanel(tester, controller: controller);

    expect(gatewayCalls, 0);
    expect(find.text('종료 전에 남은 메시지'), findsOneWidget);
    expect(find.text('AI 답변을 받지 못했어요'), findsOneWidget);
    expect(find.byKey(const Key('conversation.message.retry')), findsOneWidget);
    expect(repository.messages.single.status, MessageStatus.failed);
  });

  testWidgets('retries a failed message from its status action', (
    tester,
  ) async {
    var attempt = 0;
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) async {
          attempt += 1;
          if (attempt == 1) {
            throw StateError('offline');
          }
          return ChatReply(
            messageId: 'assistant-1',
            text: '이번에는 연결됐어.',
            createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
          );
        },
      ),
    );
    await pumpPanel(tester, controller: controller);

    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      '재시도할 메시지',
    );
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('conversation.message.retry')));
    await tester.pumpAndSettle();

    expect(find.text('이번에는 연결됐어.'), findsOneWidget);
    expect(find.byKey(const Key('conversation.message.retry')), findsNothing);
    expect(repository.messages, hasLength(2));
  });

  testWidgets('does not append a message for a blank draft', (tester) async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await pumpPanel(tester, controller: controller);

    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      '   ',
    );
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pump();

    expect(find.byKey(const Key('conversation.message.user')), findsNothing);
    expect(repository.messages, isEmpty);
  });
}

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
  'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);
