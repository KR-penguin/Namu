import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/memory/data/memory_source_ids_json_codec.dart';

void main() {
  const codec = MemorySourceIdsJsonCodec();

  test('round-trips source IDs in their original order', () {
    final encoded = codec.encode(['message-2', 'message-1']);

    expect(codec.decode(encoded), ['message-2', 'message-1']);
  });

  test('requires an exact versioned JSON object', () {
    expect(() => codec.decode('not-json'), throwsFormatException);
    expect(() => codec.decode('[]'), throwsFormatException);
    expect(
      () => codec.decode(
        jsonEncode({
          'schemaVersion': 1,
          'sourceMessageIds': ['message-1'],
          'extra': true,
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => codec.decode(
        jsonEncode({
          'schemaVersion': 2,
          'sourceMessageIds': ['message-1'],
        }),
      ),
      throwsFormatException,
    );
  });

  test('rejects empty, blank, non-string, and duplicate source IDs', () {
    for (final ids in <Object?>[
      <Object?>[],
      <Object?>[' '],
      <Object?>[1],
      <Object?>['message-1', 'message-1'],
    ]) {
      expect(
        () => codec.decode(
          jsonEncode({'schemaVersion': 1, 'sourceMessageIds': ids}),
        ),
        throwsFormatException,
      );
    }
  });
}
