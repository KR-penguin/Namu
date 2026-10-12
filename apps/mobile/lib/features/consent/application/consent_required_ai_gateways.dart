import '../../chat/domain/chat_reply_gateway.dart';
import '../../chat/domain/message.dart';
import '../../diary/domain/diary_generation_gateway.dart';
import '../../diary/domain/diary_generation_output.dart';
import '../domain/ai_data_consent_repository.dart';

final class AiDataConsentRequiredException implements Exception {
  const AiDataConsentRequiredException();

  @override
  String toString() => 'AI data transmission consent is required';
}

final class ConsentRequiredChatReplyGateway implements ChatReplyGateway {
  const ConsentRequiredChatReplyGateway({
    required this.consentRepository,
    required this.delegate,
  });

  final AiDataConsentRepository consentRepository;
  final ChatReplyGateway delegate;

  @override
  Future<ChatReply> replyTo(Message pendingUserMessage) async {
    await _requireCurrentConsent(consentRepository);
    return delegate.replyTo(pendingUserMessage);
  }
}

final class ConsentRequiredDiaryGenerationGateway
    implements DiaryGenerationGateway {
  const ConsentRequiredDiaryGenerationGateway({
    required this.consentRepository,
    required this.delegate,
  });

  final AiDataConsentRepository consentRepository;
  final DiaryGenerationGateway delegate;

  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) async {
    await _requireCurrentConsent(consentRepository);
    return delegate.generate(request);
  }
}

Future<void> _requireCurrentConsent(AiDataConsentRepository repository) async {
  final consent = await repository.load();
  if (!consent.allowsAiRequests) {
    throw const AiDataConsentRequiredException();
  }
}
