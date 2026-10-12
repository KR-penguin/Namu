import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';

typedef ReplyHandler = Future<ChatReply> Function(Message pendingUserMessage);

final class FakeChatReplyGateway implements ChatReplyGateway {
  FakeChatReplyGateway({required this.onReply});

  final ReplyHandler onReply;
  final List<Message> requests = <Message>[];

  @override
  Future<ChatReply> replyTo(Message pendingUserMessage) async {
    requests.add(pendingUserMessage);
    return onReply(pendingUserMessage);
  }
}
