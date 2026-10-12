import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  group('WeatherSnapshot', () {
    test('represents an explicit no-weather snapshot', () {
      const weather = WeatherSnapshot.noWeather();

      expect(weather.provenance, WeatherProvenance.noWeather);
      expect(weather.condition, isNull);
      expect(weather.temperatureCelsius, isNull);
      expect(weather.providerId, isNull);
      expect(weather.observedAtUtc, isNull);
    });

    test('keeps manual weather distinct from provider weather', () {
      final manual = WeatherSnapshot.manual(
        condition: '맑음',
        temperatureCelsius: 21,
      );
      final provider = WeatherSnapshot.provider(
        condition: '흐림',
        temperatureCelsius: 18.5,
        providerId: 'weather-provider',
        observedAtUtc: DateTime.utc(2026, 10, 4, 8),
      );

      expect(manual.provenance, WeatherProvenance.manual);
      expect(manual.providerId, isNull);
      expect(manual.observedAtUtc, isNull);
      expect(provider.provenance, WeatherProvenance.provider);
      expect(provider.providerId, 'weather-provider');
      expect(provider.observedAtUtc, DateTime.utc(2026, 10, 4, 8));
    });

    test('requires provider observation time to be UTC', () {
      expect(
        () => WeatherSnapshot.provider(
          condition: '맑음',
          providerId: 'weather-provider',
          observedAtUtc: DateTime(2026, 10, 4, 8),
        ),
        throwsArgumentError,
      );
    });
  });
}
