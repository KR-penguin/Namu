enum WeatherProvenance { noWeather, manual, provider }

final class WeatherSnapshot {
  const WeatherSnapshot.noWeather()
    : provenance = WeatherProvenance.noWeather,
      condition = null,
      temperatureCelsius = null,
      providerId = null,
      observedAtUtc = null;

  factory WeatherSnapshot.manual({
    required String condition,
    double? temperatureCelsius,
  }) {
    final normalizedCondition = _requireNonBlank(condition, 'condition');
    _validateTemperature(temperatureCelsius);

    return WeatherSnapshot._(
      provenance: WeatherProvenance.manual,
      condition: normalizedCondition,
      temperatureCelsius: temperatureCelsius,
    );
  }

  factory WeatherSnapshot.provider({
    required String condition,
    required String providerId,
    required DateTime observedAtUtc,
    double? temperatureCelsius,
  }) {
    final normalizedCondition = _requireNonBlank(condition, 'condition');
    final normalizedProviderId = _requireNonBlank(providerId, 'providerId');
    _validateTemperature(temperatureCelsius);
    if (!observedAtUtc.isUtc) {
      throw ArgumentError.value(
        observedAtUtc,
        'observedAtUtc',
        'must be in UTC',
      );
    }

    return WeatherSnapshot._(
      provenance: WeatherProvenance.provider,
      condition: normalizedCondition,
      temperatureCelsius: temperatureCelsius,
      providerId: normalizedProviderId,
      observedAtUtc: observedAtUtc,
    );
  }

  const WeatherSnapshot._({
    required this.provenance,
    required this.condition,
    required this.temperatureCelsius,
    this.providerId,
    this.observedAtUtc,
  });

  final WeatherProvenance provenance;
  final String? condition;
  final double? temperatureCelsius;
  final String? providerId;
  final DateTime? observedAtUtc;

  static String _requireNonBlank(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, name, 'must not be blank');
    }
    return normalized;
  }

  static void _validateTemperature(double? value) {
    if (value != null && !value.isFinite) {
      throw ArgumentError.value(value, 'temperatureCelsius', 'must be finite');
    }
  }
}
