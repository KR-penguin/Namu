import 'package:flutter/widgets.dart';

import '../core/l10n/ai_response_locale.dart';
import 'app_localizations.dart';

const Locale namuFallbackLocale = Locale('en');
// Flutter gen_l10n requires a language-only Chinese fallback. The resolver
// admits only Simplified Chinese device locales and rejects Hant regions.
const Locale namuSimplifiedChineseLocale = Locale('zh');

Locale resolveNamuLocale(List<Locale>? preferredLocales) {
  if (preferredLocales == null || preferredLocales.isEmpty) {
    return namuFallbackLocale;
  }
  for (final locale in preferredLocales) {
    switch (locale.languageCode) {
      case 'ko':
        return const Locale('ko');
      case 'en':
        return const Locale('en');
      case 'ja':
        return const Locale('ja');
      case 'es':
        return const Locale('es');
      case 'zh':
        final traditionalRegion = switch (locale.countryCode?.toUpperCase()) {
          'TW' || 'HK' || 'MO' => true,
          _ => false,
        };
        if (locale.scriptCode == 'Hant' || traditionalRegion) {
          continue;
        }
        return namuSimplifiedChineseLocale;
    }
  }
  return namuFallbackLocale;
}

AiResponseLocale resolveNamuAiResponseLocale(List<Locale>? preferredLocales) {
  return switch (resolveNamuLocale(preferredLocales).languageCode) {
    'ko' => AiResponseLocale.ko,
    'ja' => AiResponseLocale.ja,
    'zh' => AiResponseLocale.zhHans,
    'es' => AiResponseLocale.es,
    _ => AiResponseLocale.en,
  };
}

AppLocalizations namuLocalizationsFor(Locale locale) {
  return lookupAppLocalizations(resolveNamuLocale(<Locale>[locale]));
}

extension NamuBuildContextLocalizations on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) ??
        namuLocalizationsFor(const Locale('ko'));
  }
}
