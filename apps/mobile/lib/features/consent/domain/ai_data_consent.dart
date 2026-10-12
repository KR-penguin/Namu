enum AiDataConsentChoice { undecided, accepted, declined, revoked }

/// The user's decision for the current explanation of AI data transmission.
///
/// A new policy version intentionally invalidates an older acceptance so AI
/// requests fail closed until the changed data flow is explained again.
final class AiDataConsent {
  const AiDataConsent.undecided()
    : policyVersion = currentPolicyVersion,
      choice = AiDataConsentChoice.undecided,
      decidedAtUtc = null;

  factory AiDataConsent.accepted({required DateTime decidedAtUtc}) {
    return AiDataConsent._decided(
      choice: AiDataConsentChoice.accepted,
      decidedAtUtc: decidedAtUtc,
    );
  }

  factory AiDataConsent.declined({required DateTime decidedAtUtc}) {
    return AiDataConsent._decided(
      choice: AiDataConsentChoice.declined,
      decidedAtUtc: decidedAtUtc,
    );
  }

  factory AiDataConsent.revoked({required DateTime decidedAtUtc}) {
    return AiDataConsent._decided(
      choice: AiDataConsentChoice.revoked,
      decidedAtUtc: decidedAtUtc,
    );
  }

  AiDataConsent._decided({required this.choice, required DateTime decidedAtUtc})
    : policyVersion = currentPolicyVersion,
      decidedAtUtc = _requireUtc(decidedAtUtc) {
    if (choice == AiDataConsentChoice.undecided) {
      throw ArgumentError.value(choice, 'choice', 'must be a decision');
    }
  }

  static const int currentPolicyVersion = 1;

  final int policyVersion;
  final AiDataConsentChoice choice;
  final DateTime? decidedAtUtc;

  bool get allowsAiRequests =>
      policyVersion == currentPolicyVersion &&
      choice == AiDataConsentChoice.accepted;

  bool get hasCompletedFirstRun => choice != AiDataConsentChoice.undecided;

  static DateTime _requireUtc(DateTime value) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, 'decidedAtUtc', 'must be in UTC');
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiDataConsent &&
          policyVersion == other.policyVersion &&
          choice == other.choice &&
          decidedAtUtc == other.decidedAtUtc;

  @override
  int get hashCode => Object.hash(policyVersion, choice, decidedAtUtc);
}
