import 'package:namu/features/chat/domain/message.dart';

final class ChatReply {
  ChatReply({
    required this.messageId,
    required this.text,
    required this.createdAtUtc,
  }) {
    if (messageId.trim().isEmpty) {
      throw ArgumentError.value(messageId, 'messageId', 'must not be blank');
    }
    if (text.trim().isEmpty) {
      throw ArgumentError.value(text, 'text', 'must not be blank');
    }
    if (!createdAtUtc.isUtc) {
      throw ArgumentError.value(createdAtUtc, 'createdAtUtc', 'must be in UTC');
    }
  }

  final String messageId;
  final String text;
  final DateTime createdAtUtc;
}

abstract interface class ChatReplyGateway {
  /// The gateway must treat [Message.requestId] as an idempotency key.
  Future<ChatReply> replyTo(Message pendingUserMessage);
}
