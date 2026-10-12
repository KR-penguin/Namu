import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/l10n/ai_response_locale.dart';

void main() {
  test('exposes only the five allowlisted Gateway locale tags', () {
    expect(
      AiResponseLocale.values.map((locale) => locale.wireTag).toList(),
      <String>['ko', 'en', 'ja', 'zh-Hans', 'es'],
    );
  });
}
