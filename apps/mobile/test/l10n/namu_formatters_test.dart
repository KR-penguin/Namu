import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/l10n/namu_formatters.dart';

void main() {
  setUpAll(() async {
    for (final locale in const ['ko', 'en', 'ja', 'zh', 'es']) {
      await initializeDateFormatting(locale);
    }
  });

  group('NamuFormatters', () {
    final date = LocalDate(2026, 10, 4);

    test('formats a full date in every supported locale', () {
      expect(
        NamuFormatters.fullDate(date, const Locale('ko')),
        contains('2026년'),
      );
      expect(
        NamuFormatters.fullDate(date, const Locale('en')),
        contains('October'),
      );
      expect(
        NamuFormatters.fullDate(date, const Locale('ja')),
        contains('2026年'),
      );
      expect(
        NamuFormatters.fullDate(date, const Locale('zh')),
        contains('2026年'),
      );
      expect(
        NamuFormatters.fullDate(date, const Locale('es')),
        contains('octubre'),
      );
    });

    test('uses the locale decimal separator for temperatures', () {
      expect(NamuFormatters.temperature(20.5, const Locale('en')), '20.5 °C');
      expect(NamuFormatters.temperature(20.5, const Locale('es')), '20,5 °C');
      expect(NamuFormatters.decimal(20.5, const Locale('en')), '20.5');
      expect(NamuFormatters.decimal(20.5, const Locale('es')), '20,5');
    });

    test('parses localized decimal input without accepting trailing text', () {
      expect(NamuFormatters.tryParseDecimal('20,5', const Locale('es')), 20.5);
      expect(
        NamuFormatters.tryParseDecimal('-3.25', const Locale('en')),
        -3.25,
      );
      expect(
        NamuFormatters.tryParseDecimal('20,5 degrees', const Locale('es')),
        isNull,
      );
      expect(NamuFormatters.tryParseDecimal('', const Locale('ko')), isNull);
    });
  });
}
