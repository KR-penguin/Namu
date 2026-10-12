import '../network/gateway_exception.dart';
import '../../l10n/app_localizations.dart';

enum AiGatewayOperation { chatReply, diaryDraft }

String gatewayFailureMessage(
  Object error, {
  required AiGatewayOperation operation,
  required AppLocalizations l10n,
}) {
  final preserved = switch (operation) {
    AiGatewayOperation.chatReply => l10n.gatewayPreservedChat,
    AiGatewayOperation.diaryDraft => l10n.gatewayPreservedDiary,
  };
  if (error is! GatewayException) {
    return switch (operation) {
      AiGatewayOperation.chatReply => l10n.gatewayUnknownChat(preserved),
      AiGatewayOperation.diaryDraft => l10n.gatewayUnknownDiary(preserved),
    };
  }

  return switch (error.category) {
    GatewayExceptionCategory.unconfigured => l10n.gatewayUnconfigured(
      preserved,
    ),
    GatewayExceptionCategory.unauthorized => l10n.gatewayUnauthorized(
      preserved,
    ),
    GatewayExceptionCategory.invalidAttestation =>
      l10n.gatewayInvalidAttestation(preserved),
    GatewayExceptionCategory.rateLimited => l10n.gatewayRateLimited(
      _retryGuidance(error.retryAfter, l10n),
      preserved,
    ),
    GatewayExceptionCategory.requestTooLarge => switch (operation) {
      AiGatewayOperation.chatReply => l10n.gatewayRequestTooLargeChat,
      AiGatewayOperation.diaryDraft => l10n.gatewayRequestTooLargeDiary(
        preserved,
      ),
    },
    GatewayExceptionCategory.responseTooLarge => l10n.gatewayResponseTooLarge(
      preserved,
    ),
    GatewayExceptionCategory.idempotencyConflict => switch (operation) {
      AiGatewayOperation.chatReply => l10n.gatewayIdempotencyConflictChat,
      AiGatewayOperation.diaryDraft => l10n.gatewayIdempotencyConflictDiary(
        preserved,
      ),
    },
    GatewayExceptionCategory.rejected => l10n.gatewayRejected(preserved),
    GatewayExceptionCategory.safetyBlocked => switch (operation) {
      AiGatewayOperation.chatReply => l10n.gatewaySafetyBlockedChat(preserved),
      AiGatewayOperation.diaryDraft => l10n.gatewaySafetyBlockedDiary(
        preserved,
      ),
    },
    GatewayExceptionCategory.modelTimeout ||
    GatewayExceptionCategory.timeout => l10n.gatewayTimeout(preserved),
    GatewayExceptionCategory.modelTruncated => l10n.gatewayTruncated(preserved),
    GatewayExceptionCategory.invalidModelResponse ||
    GatewayExceptionCategory.invalidResponse => l10n.gatewayInvalidResponse(
      preserved,
    ),
    GatewayExceptionCategory.server => l10n.gatewayServerUnavailable(preserved),
    GatewayExceptionCategory.network => l10n.gatewayNetworkUnavailable(
      preserved,
    ),
  };
}

String _retryGuidance(Duration? retryAfter, AppLocalizations l10n) {
  final seconds = retryAfter?.inSeconds ?? 0;
  if (seconds <= 0) {
    return l10n.gatewayRetrySoon;
  }
  if (seconds < Duration.secondsPerMinute) {
    return l10n.gatewayRetryAfterSeconds(seconds);
  }
  if (seconds < Duration.secondsPerHour) {
    final minutes =
        (seconds + Duration.secondsPerMinute - 1) ~/ Duration.secondsPerMinute;
    return l10n.gatewayRetryAfterMinutes(minutes);
  }
  final hours =
      (seconds + Duration.secondsPerHour - 1) ~/ Duration.secondsPerHour;
  return l10n.gatewayRetryAfterHours(hours);
}
