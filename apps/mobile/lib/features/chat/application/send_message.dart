import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/chat/domain/message_repository.dart';

final class SendMessageCommand {
  const SendMessageCommand({
    required this.messageId,
    required this.requestId,
    required this.dayKey,
    required this.createdAtUtc,
    this.text,
    this.photoAssetId,
  });

  final String messageId;
  final String requestId;
  final DiaryDayKey dayKey;
  final String? text;
  final String? photoAssetId;
  final DateTime createdAtUtc;
}

final class SendMessage {
  const SendMessage({required this.repository, required this.replyGateway});

  final MessageRepository repository;
  final ChatReplyGateway replyGateway;

  Future<void> call(SendMessageCommand command) async {
    final existing = await repository.findUserByRequestId(command.requestId);
    if (existing?.status == MessageStatus.sent) {
      return;
    }

    final pending =
        existing?.withStatus(MessageStatus.pending) ??
        Message(
          id: command.messageId,
          requestId: command.requestId,
          dayKey: command.dayKey,
          role: MessageRole.user,
          text: command.text,
          photoAssetId: command.photoAssetId,
          createdAtUtc: command.createdAtUtc,
          status: MessageStatus.pending,
        );

    await repository.upsert(pending);

    try {
      final reply = await replyGateway.replyTo(pending);
      final assistantMessage = Message(
        id: reply.messageId,
        requestId: pending.requestId,
        dayKey: pending.dayKey,
        role: MessageRole.assistant,
        text: reply.text,
        createdAtUtc: reply.createdAtUtc,
        status: MessageStatus.sent,
      );

      await repository.upsert(assistantMessage);
      await repository.upsert(pending.withStatus(MessageStatus.sent));
    } catch (_) {
      await repository.upsert(pending.withStatus(MessageStatus.failed));
      rethrow;
    }
  }
}
