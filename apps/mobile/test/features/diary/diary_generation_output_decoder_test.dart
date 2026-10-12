import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/diary/data/diary_generation_output_decoder.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';

void main() {
  const decoder = DiaryGenerationOutputDecoder();
  const allowedPhotoAssetIds = {'photo-1'};
  const allowedSourceMessageIds = {'message-1', 'message-2'};

  DiaryGenerationOutput decode(Map<String, Object?> payload) {
    return decoder.decode(
      jsonEncode(payload),
      allowedPhotoAssetIds: allowedPhotoAssetIds,
      allowedSourceMessageIds: allowedSourceMessageIds,
    );
  }

  group('DiaryGenerationOutputDecoder', () {
    test('decodes a valid v1 output into immutable models', () {
      final output = decode(_validPayload());

      expect(output.schemaVersion, 1);
      expect(output.mood, 'content');
      expect(output.oneLineSummary, 'A quietly satisfying day.');
      expect(output.theme, DiaryTheme.dark);
      expect(output.blocks, hasLength(2));
      expect(output.blocks.first, isA<DiaryTextBlock>());
      expect(
        (output.blocks.first as DiaryTextBlock).text,
        'I took a slow walk after lunch.',
      );
      expect(output.blocks.last, isA<DiaryPhotoBlock>());
      expect((output.blocks.last as DiaryPhotoBlock).photoAssetId, 'photo-1');
      expect(output.memoryCandidates, hasLength(1));
      expect(
        output.memoryCandidates.single.fact,
        'The user enjoys slow walks.',
      );
      expect(output.memoryCandidates.single.sourceMessageIds, [
        'message-1',
        'message-2',
      ]);

      expect(
        () => output.blocks.add(const DiaryTextBlock(text: 'mutate')),
        throwsUnsupportedError,
      );
      expect(
        () => output.memoryCandidates.single.sourceMessageIds.add('message-3'),
        throwsUnsupportedError,
      );
    });

    test('rejects top-level fields outside the v1 contract', () {
      for (final field in ['date', 'weather', 'unexpected']) {
        final payload = _validPayload()..[field] = 'not allowed';

        expect(
          () => decode(payload),
          throwsA(isA<DiaryGenerationContractException>()),
          reason: '$field must not be accepted',
        );
      }
    });

    test('rejects an unknown schema version', () {
      final payload = _validPayload()..['schemaVersion'] = 2;

      expect(
        () => decode(payload),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });

    test('rejects an unknown theme', () {
      final payload = _validPayload()..['theme'] = 'sepia';

      expect(
        () => decode(payload),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });

    test('rejects empty blocks', () {
      final payload = _validPayload()..['blocks'] = <Object?>[];

      expect(
        () => decode(payload),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });

    test('rejects an unknown block type', () {
      final payload = _validPayload()
        ..['blocks'] = <Object?>[
          {'type': 'video', 'photoAssetId': 'photo-1'},
        ];

      expect(
        () => decode(payload),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });

    test('rejects a photoAssetId that was not provided as input', () {
      final payload = _validPayload()
        ..['blocks'] = <Object?>[
          {'type': 'photo', 'photoAssetId': 'photo-unknown'},
        ];

      expect(
        () => decode(payload),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });

    test('rejects a sourceMessageId that was not provided as input', () {
      final payload = _validPayload()
        ..['memoryCandidates'] = <Object?>[
          {
            'fact': 'The user enjoys slow walks.',
            'sourceMessageIds': ['message-unknown'],
          },
        ];

      expect(
        () => decode(payload),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });

    test('rejects additional fields in nested objects', () {
      final payload = _validPayload();
      final blocks = payload['blocks']! as List<Object?>;
      blocks.first = {
        'type': 'text',
        'text': 'I took a slow walk after lunch.',
        'html': '<p>not allowed</p>',
      };

      expect(
        () => decode(payload),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });

    test('rejects malformed JSON with the typed contract exception', () {
      expect(
        () => decoder.decode(
          '{"schemaVersion": 1,',
          allowedPhotoAssetIds: allowedPhotoAssetIds,
          allowedSourceMessageIds: allowedSourceMessageIds,
        ),
        throwsA(isA<DiaryGenerationContractException>()),
      );
    });
  });
}

Map<String, Object?> _validPayload() {
  return {
    'schemaVersion': 1,
    'mood': 'content',
    'oneLineSummary': 'A quietly satisfying day.',
    'theme': 'dark',
    'blocks': <Object?>[
      {'type': 'text', 'text': 'I took a slow walk after lunch.'},
      {'type': 'photo', 'photoAssetId': 'photo-1'},
    ],
    'memoryCandidates': <Object?>[
      {
        'fact': 'The user enjoys slow walks.',
        'sourceMessageIds': ['message-1', 'message-2'],
      },
    ],
  };
}
