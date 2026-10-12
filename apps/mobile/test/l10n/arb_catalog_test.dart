import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported locale has the complete message contract', () {
    final english = _readCatalog('app_en.arb');
    final englishMessages = _messageKeys(english);
    final declaredPlaceholders = _declaredPlaceholderNames(english);

    expect(englishMessages, hasLength(270));
    for (final fileName in const [
      'app_ko.arb',
      'app_ja.arb',
      'app_zh.arb',
      'app_es.arb',
    ]) {
      final translated = _readCatalog(fileName);
      expect(
        _messageKeys(translated),
        englishMessages,
        reason: '$fileName must not rely on an English fallback.',
      );
      for (final key in englishMessages) {
        final englishPlaceholders = _placeholderNames(english[key])
            .intersection(declaredPlaceholders);
        final translatedPlaceholders = _placeholderNames(translated[key])
            .intersection(declaredPlaceholders);
        expect(
          translatedPlaceholders,
          englishPlaceholders,
          reason: '$fileName changed the placeholder contract for $key.',
        );
      }
    }
  });
}

Map<String, Object?> _readCatalog(String fileName) {
  final file = File('lib/l10n/$fileName');
  return (jsonDecode(file.readAsStringSync()) as Map<String, Object?>);
}

Set<String> _messageKeys(Map<String, Object?> catalog) {
  return catalog.keys.where((key) => !key.startsWith('@')).toSet();
}

Set<String> _placeholderNames(Object? message) {
  if (message is! String) {
    return const {};
  }
  return RegExp(r'\{([A-Za-z][A-Za-z0-9_]*)')
      .allMatches(message)
      .map((match) => match.group(1)!)
      .toSet();
}

Set<String> _declaredPlaceholderNames(Map<String, Object?> catalog) {
  final result = <String>{};
  for (final entry in catalog.entries) {
    if (!entry.key.startsWith('@') || entry.value is! Map) {
      continue;
    }
    final metadata = entry.value! as Map;
    final placeholders = metadata['placeholders'];
    if (placeholders is Map) {
      result.addAll(placeholders.keys.cast<String>());
    }
  }
  return result;
}
