import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/time/local_date.dart';

abstract final class NamuFormatters {
  static String fullDate(LocalDate date, Locale locale) {
    return DateFormat.yMMMMEEEEd(_intlLocale(locale)).format(_dateTime(date));
  }

  static String mediumDate(LocalDate date, Locale locale) {
    return DateFormat.yMMMd(_intlLocale(locale)).format(_dateTime(date));
  }

  static String temperature(double value, Locale locale) {
    return '${decimal(value, locale)} °C';
  }

  static String decimal(double value, Locale locale) {
    return NumberFormat('0.#', _intlLocale(locale)).format(value);
  }

  static double? tryParseDecimal(String input, Locale locale) {
    final normalized = input.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final value = NumberFormat.decimalPattern(_intlLocale(locale))
        .tryParse(normalized);
    return value?.toDouble();
  }

  static DateTime _dateTime(LocalDate date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  static String _intlLocale(Locale locale) {
    final language = locale.languageCode;
    final script = locale.scriptCode;
    final country = locale.countryCode;
    if (script != null && script.isNotEmpty) {
      return country == null || country.isEmpty
          ? '${language}_$script'
          : '${language}_${script}_$country';
    }
    return country == null || country.isEmpty
        ? language
        : '${language}_$country';
  }
}
