import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/l10n/app_localizations.dart';
import 'package:namu/l10n/namu_localizations.dart';

void main() {
  test('exposes the five approved UI locales', () {
    expect(
      AppLocalizations.supportedLocales,
      containsAll(<Locale>[
        const Locale('ko'),
        const Locale('en'),
        const Locale('ja'),
        const Locale('zh'),
        const Locale('es'),
      ]),
    );
    expect(AppLocalizations.supportedLocales, hasLength(5));
  });

  test('resolves regional variants and falls back to English', () {
    expect(
      resolveNamuLocale(const <Locale>[Locale('ko', 'KR')]),
      const Locale('ko'),
    );
    expect(
      resolveNamuLocale(const <Locale>[Locale('en', 'GB')]),
      const Locale('en'),
    );
    expect(
      resolveNamuLocale(const <Locale>[Locale('ja', 'JP')]),
      const Locale('ja'),
    );
    expect(
      resolveNamuLocale(const <Locale>[Locale('zh', 'CN')]),
      const Locale('zh'),
    );
    expect(
      resolveNamuLocale(const <Locale>[Locale('es', 'MX')]),
      const Locale('es'),
    );
    expect(
      resolveNamuLocale(const <Locale>[Locale('zh', 'TW')]),
      const Locale('en'),
    );
    expect(
      resolveNamuLocale(const <Locale>[Locale('fr', 'FR')]),
      const Locale('en'),
    );
    expect(resolveNamuLocale(null), const Locale('en'));
  });

  test('maps the resolved app locale to the supported AI response locale', () {
    expect(
      resolveNamuAiResponseLocale(const <Locale>[Locale('ko', 'KR')]),
      AiResponseLocale.ko,
    );
    expect(
      resolveNamuAiResponseLocale(const <Locale>[Locale('en', 'GB')]),
      AiResponseLocale.en,
    );
    expect(
      resolveNamuAiResponseLocale(const <Locale>[Locale('ja', 'JP')]),
      AiResponseLocale.ja,
    );
    expect(
      resolveNamuAiResponseLocale(const <Locale>[
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
          countryCode: 'CN',
        ),
      ]),
      AiResponseLocale.zhHans,
    );
    expect(
      resolveNamuAiResponseLocale(const <Locale>[Locale('es', 'MX')]),
      AiResponseLocale.es,
    );
    expect(
      resolveNamuAiResponseLocale(const <Locale>[
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      ]),
      AiResponseLocale.en,
    );
    expect(
      resolveNamuAiResponseLocale(const <Locale>[Locale('fr', 'FR')]),
      AiResponseLocale.en,
    );
    expect(resolveNamuAiResponseLocale(null), AiResponseLocale.en);
  });

  testWidgets('loads a distinct settings title for every locale', (
    tester,
  ) async {
    const expected = <(Locale, String)>[
      (Locale('ko'), '설정'),
      (Locale('en'), 'Settings'),
      (Locale('ja'), '設定'),
      (Locale('zh'), '设置'),
      (Locale('es'), 'Ajustes'),
    ];

    for (final entry in expected) {
      await tester.pumpWidget(
        MaterialApp(
          locale: entry.$1,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(builder: (context) => Text(context.l10n.settingsTitle)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.$2), findsOneWidget);
    }
  });

  test('keeps privacy and sharing boundaries in every translation', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = namuLocalizationsFor(locale);
      expect(strings.onboardingLocalStorageBody, isNotEmpty);
      expect(strings.onboardingAiDisclosureBody, isNotEmpty);
      expect(strings.onboardingAiTransferBody, isNotEmpty);
      expect(strings.shareSheetOpenedNotPosted, isNotEmpty);
      expect(strings.exportDialogBody, isNotEmpty);
    }
  });
}
