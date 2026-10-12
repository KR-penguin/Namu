final class OnboardingStatus {
  const OnboardingStatus.notCompleted()
    : schemaVersion = currentSchemaVersion,
      completedAtUtc = null;

  OnboardingStatus.completed({required DateTime completedAtUtc})
    : schemaVersion = currentSchemaVersion,
      completedAtUtc = _requireUtc(completedAtUtc);

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime? completedAtUtc;

  bool get isComplete =>
      schemaVersion == currentSchemaVersion && completedAtUtc != null;

  static DateTime _requireUtc(DateTime value) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, 'completedAtUtc', 'must be in UTC');
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingStatus &&
          schemaVersion == other.schemaVersion &&
          completedAtUtc == other.completedAtUtc;

  @override
  int get hashCode => Object.hash(schemaVersion, completedAtUtc);
}
