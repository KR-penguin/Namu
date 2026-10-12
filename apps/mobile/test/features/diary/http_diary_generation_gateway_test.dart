import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:namu/core/network/gateway_config.dart';
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/diary/data/http_diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

void main() {
  late DiaryDayKey dayKey;
  late AiPersona persona;
  late List<Message> messages;

  setUp(() {
    dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    persona = AiPersona(
      id: 'persona-1',
      name: '모아',
      avatarSeed: 'warm-tree',
      tone: '따뜻하고 호기심 있게',
      customInstructions: '짧은 질문으로 하루를 돌아보게 해줘.',
      reactionLength: ReactionLength.expressive,
    );
    messages = <Message>[
      _message(
        id: 'message-2',
        requestId: 'request-2',
        dayKey: dayKey,
        role: MessageRole.assistant,
        text: '어떤 풍경이 기억에 남아?',
        photoAssetId: 'photo-1',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 2),
      ),
      _message(
        id: 'message-1',
        requestId: 'request-1',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '오늘은 천천히 산책했어.',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8),
      ),
    ];
  });

  test('posts the exact v2 diary snapshot with locale sorted by UTC', () async {
    late http.Request capturedRequest;
    var headerProviderCalls = 0;
    final client = _CloseTrackingClient(
      MockClient((request) async {
        capturedRequest = request;
        return _jsonResponse(_validOutput());
      }),
    );
    final gateway = HttpDiaryGenerationGateway(
      client: client,
      config: _configured(),
      authHeaders: () async {
        headerProviderCalls += 1;
        return <String, String>{
          'Authorization': 'Bearer injected-token',
          'X-App-Attestation': 'injected-attestation',
          'Content-Type': 'text/plain',
          'Idempotency-Key': 'must-not-win',
        };
      },
    );
    final request = DiaryGenerationRequest(
      responseLocale: AiResponseLocale.zhHans,
      generationId: 'generation-1',
      dayKey: dayKey,
      weather: WeatherSnapshot.provider(
        condition: '맑음',
        temperatureCelsius: 21.5,
        providerId: 'weather-provider',
        observedAtUtc: DateTime.utc(2026, 10, 4, 7, 30),
      ),
      persona: persona,
      messages: messages,
    );

    final output = await gateway.generate(request);

    expect(headerProviderCalls, 1);
    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url,
      Uri.parse('https://gateway.example.com/v1/diary/generate'),
    );
    expect(capturedRequest.headers['authorization'], 'Bearer injected-token');
    expect(
      capturedRequest.headers['x-app-attestation'],
      'injected-attestation',
    );
    expect(capturedRequest.headers['accept'], 'application/json');
    expect(
      capturedRequest.headers['content-type'],
      'application/json; charset=utf-8',
    );
    expect(capturedRequest.headers['idempotency-key'], 'generation-1');
    expect(jsonDecode(capturedRequest.body), <String, Object?>{
      'schemaVersion': 2,
      'responseLocale': 'zh-Hans',
      'generationId': 'generation-1',
      'dayKey': <String, Object>{
        'labelDate': '2026-10-04',
        'timeZoneId': 'Asia/Seoul',
        'cutoffMinutes': 0,
        'policyVersion': 1,
      },
      'weather': <String, Object?>{
        'provenance': 'provider',
        'condition': '맑음',
        'temperatureCelsius': 21.5,
        'providerId': 'weather-provider',
        'observedAtUtc': '2026-10-04T07:30:00.000Z',
      },
      'persona': <String, Object>{
        'id': 'persona-1',
        'name': '모아',
        'avatarSeed': 'warm-tree',
        'tone': '따뜻하고 호기심 있게',
        'customInstructions': '짧은 질문으로 하루를 돌아보게 해줘.',
        'reactionLength': 'expressive',
      },
      'messages': <Object?>[
        <String, Object?>{
          'id': 'message-1',
          'role': 'user',
          'text': '오늘은 천천히 산책했어.',
          'photoAssetId': null,
          'createdAtUtc': '2026-10-04T08:00:00.000Z',
        },
        <String, Object?>{
          'id': 'message-2',
          'role': 'assistant',
          'text': '어떤 풍경이 기억에 남아?',
          'photoAssetId': 'photo-1',
          'createdAtUtc': '2026-10-04T08:02:00.000Z',
        },
      ],
    });
    expect(output.schemaVersion, 1);
    expect(output.blocks.last, isA<DiaryPhotoBlock>());
    expect(output.memoryCandidates.single.sourceMessageIds, <String>[
      'message-1',
      'message-2',
    ]);
    expect(client.wasClosed, isFalse);

    client.close();
  });

  test(
    'sends only an opaque photoAssetId without image bytes or local paths',
    () async {
      var body = <String, Object?>{};
      final gateway = HttpDiaryGenerationGateway(
        client: MockClient((request) async {
          body = (jsonDecode(request.body) as Map).cast<String, Object?>();
          return _jsonResponse(_validOutput());
        }),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
      );

      await gateway.generate(_request(dayKey, persona, messages));

      final encoded = jsonEncode(body);
      final sentMessages = body['messages']! as List<Object?>;
      final photoMessage = (sentMessages.last as Map).cast<String, Object?>();
      expect(photoMessage.keys.toSet(), <String>{
        'id',
        'role',
        'text',
        'photoAssetId',
        'createdAtUtc',
      });
      expect(photoMessage['photoAssetId'], 'photo-1');
      expect(encoded, isNot(contains('localPath')));
      expect(encoded, isNot(contains('storageKey')));
      expect(encoded, isNot(contains('imageBytes')));
      expect(encoded, isNot(contains('base64')));
    },
  );

  test(
    'serializes the explicit no-weather snapshot with exact nulls',
    () async {
      var body = <String, Object?>{};
      final gateway = HttpDiaryGenerationGateway(
        client: MockClient((request) async {
          body = (jsonDecode(request.body) as Map).cast<String, Object?>();
          return _jsonResponse(_validOutput());
        }),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
      );
      final request = DiaryGenerationRequest(
        responseLocale: AiResponseLocale.ko,
        generationId: 'generation-1',
        dayKey: dayKey,
        weather: const WeatherSnapshot.noWeather(),
        persona: persona,
        messages: messages,
      );

      await gateway.generate(request);

      expect(body['weather'], <String, Object?>{
        'provenance': 'noWeather',
        'condition': null,
        'temperatureCelsius': null,
        'providerId': null,
        'observedAtUtc': null,
      });
    },
  );

  test(
    'rejects an oversized UTF-8 request before credentials or HTTP',
    () async {
      var headerProviderCalled = false;
      var clientCalled = false;
      final gateway = HttpDiaryGenerationGateway(
        client: MockClient((_) async {
          clientCalled = true;
          return _jsonResponse(_validOutput());
        }),
        config: _configured(),
        authHeaders: () async {
          headerProviderCalled = true;
          return const <String, String>{};
        },
        maxRequestBodyBytes: 1,
      );

      final exception = await _captureGatewayException(
        gateway.generate(_request(dayKey, persona, messages)),
      );

      expect(exception.category, GatewayExceptionCategory.requestTooLarge);
      expect(exception.statusCode, isNull);
      expect(exception.toString(), isNot(contains(messages.first.text!)));
      expect(headerProviderCalled, isFalse);
      expect(clientCalled, isFalse);
    },
  );

  test(
    'accepts the exact UTF-8 byte limit and rejects one byte less',
    () async {
      late String encodedBody;
      final measuringGateway = HttpDiaryGenerationGateway(
        client: MockClient((request) async {
          encodedBody = request.body;
          return _jsonResponse(_validOutput());
        }),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
      );
      await measuringGateway.generate(_request(dayKey, persona, messages));
      final byteLength = utf8.encode(encodedBody).length;
      expect(byteLength, greaterThan(encodedBody.length));

      var exactBoundaryCalls = 0;
      final exactBoundaryGateway = HttpDiaryGenerationGateway(
        client: MockClient((_) async {
          exactBoundaryCalls += 1;
          return _jsonResponse(_validOutput());
        }),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
        maxRequestBodyBytes: byteLength,
      );
      await exactBoundaryGateway.generate(_request(dayKey, persona, messages));

      final belowBoundaryGateway = HttpDiaryGenerationGateway(
        client: MockClient((_) async {
          fail('HTTP must not be called for a locally rejected request.');
        }),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
        maxRequestBodyBytes: byteLength - 1,
      );
      final exception = await _captureGatewayException(
        belowBoundaryGateway.generate(_request(dayKey, persona, messages)),
      );

      expect(exactBoundaryCalls, 1);
      expect(exception.category, GatewayExceptionCategory.requestTooLarge);
    },
  );

  test('sorts equal timestamps by message id without mutating input', () async {
    var sentMessages = <Object?>[];
    final sameInstant = DateTime.utc(2026, 10, 4, 9);
    final originalMessages = <Message>[
      _message(
        id: 'message-b',
        requestId: 'request-b',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '두 번째',
        createdAtUtc: sameInstant,
      ),
      _message(
        id: 'message-a',
        requestId: 'request-a',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '첫 번째',
        createdAtUtc: sameInstant,
      ),
    ];
    final gateway = HttpDiaryGenerationGateway(
      client: MockClient((request) async {
        final body = (jsonDecode(request.body) as Map).cast<String, Object?>();
        sentMessages = body['messages']! as List<Object?>;
        return _jsonResponse(_textOnlyOutput(sourceMessageId: 'message-a'));
      }),
      config: _configured(),
      authHeaders: () async => const <String, String>{},
    );

    await gateway.generate(
      DiaryGenerationRequest(
        responseLocale: AiResponseLocale.ko,
        generationId: 'generation-1',
        dayKey: dayKey,
        weather: const WeatherSnapshot.noWeather(),
        persona: persona,
        messages: originalMessages,
      ),
    );

    expect(sentMessages.map((item) => (item as Map)['id']), <String>[
      'message-a',
      'message-b',
    ]);
    expect(originalMessages.map((message) => message.id), <String>[
      'message-b',
      'message-a',
    ]);
  });

  test('rejects messages outside the requested DiaryDayKey', () {
    final otherDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 5, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );

    expect(
      () => DiaryGenerationRequest(
        responseLocale: AiResponseLocale.ko,
        generationId: 'generation-1',
        dayKey: dayKey,
        weather: const WeatherSnapshot.noWeather(),
        persona: persona,
        messages: <Message>[
          _message(
            id: 'other-day',
            requestId: 'other-request',
            dayKey: otherDay,
            role: MessageRole.user,
            text: '다른 날짜 메시지',
            createdAtUtc: DateTime.utc(2026, 10, 5, 8),
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  group('response allowlists', () {
    test('rejects a successful response with a non-JSON media type', () async {
      final gateway = HttpDiaryGenerationGateway(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(_validOutput()),
            200,
            headers: const <String, String>{
              'content-type': 'text/plain; charset=utf-8',
            },
          ),
        ),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
      );

      final exception = await _captureGatewayException(
        gateway.generate(_request(dayKey, persona, messages)),
      );

      expect(exception.category, GatewayExceptionCategory.invalidResponse);
    });

    test('aborts a response that exceeds the configured byte limit', () async {
      final gateway = HttpDiaryGenerationGateway(
        client: MockClient((_) async => _jsonResponse(_validOutput())),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
        maxResponseBodyBytes: 1,
      );

      final exception = await _captureGatewayException(
        gateway.generate(_request(dayKey, persona, messages)),
      );

      expect(exception.category, GatewayExceptionCategory.responseTooLarge);
    });

    test('rejects a photo id that was not in the request snapshot', () async {
      final payload = _validOutput()
        ..['blocks'] = <Object?>[
          <String, Object?>{'type': 'photo', 'photoAssetId': 'unknown-photo'},
        ];

      await _expectInvalidOutput(
        dayKey: dayKey,
        persona: persona,
        messages: messages,
        payload: payload,
      );
    });

    test('rejects a source id that was not in the request snapshot', () async {
      final payload = _validOutput()
        ..['memoryCandidates'] = <Object?>[
          <String, Object?>{
            'fact': '사용자는 산책을 좋아한다.',
            'sourceMessageIds': <String>['unknown-message'],
          },
        ];

      await _expectInvalidOutput(
        dayKey: dayKey,
        persona: persona,
        messages: messages,
        payload: payload,
      );
    });

    test('redacts malformed model output', () async {
      const privateBody = '{private malformed model output';
      final gateway = HttpDiaryGenerationGateway(
        client: MockClient((_) async => http.Response(privateBody, 200)),
        config: _configured(),
        authHeaders: () async => const <String, String>{},
      );

      final exception = await _captureGatewayException(
        gateway.generate(_request(dayKey, persona, messages)),
      );

      expect(exception.category, GatewayExceptionCategory.invalidResponse);
      expect(exception.toString(), isNot(contains(privateBody)));
    });
  });

  group('HTTP status mapping', () {
    for (final status in <int>[401, 403]) {
      test('$status is unauthorized', () async {
        await _expectStatus(
          status,
          GatewayExceptionCategory.unauthorized,
          dayKey,
          persona,
          messages,
        );
      });
    }

    test('429 is rate limited', () async {
      await _expectStatus(
        429,
        GatewayExceptionCategory.rateLimited,
        dayKey,
        persona,
        messages,
      );
    });

    test('413 is request too large', () async {
      await _expectStatus(
        413,
        GatewayExceptionCategory.requestTooLarge,
        dayKey,
        persona,
        messages,
      );
    });

    for (final status in <int>[400, 422]) {
      test('$status is rejected', () async {
        await _expectStatus(
          status,
          GatewayExceptionCategory.rejected,
          dayKey,
          persona,
          messages,
        );
      });
    }

    for (final status in <int>[500, 503]) {
      test('$status is a server failure', () async {
        await _expectStatus(
          status,
          GatewayExceptionCategory.server,
          dayKey,
          persona,
          messages,
        );
      });
    }

    for (final status in <int>[204, 302, 404]) {
      test('$status is an invalid protocol response', () async {
        await _expectStatus(
          status,
          GatewayExceptionCategory.invalidResponse,
          dayKey,
          persona,
          messages,
        );
      });
    }
  });

  test('maps a timeout to a redacted typed exception', () async {
    final neverCompletes = Completer<http.Response>();
    final gateway = HttpDiaryGenerationGateway(
      client: MockClient((_) => neverCompletes.future),
      config: _configured(),
      authHeaders: () async => const <String, String>{},
      requestTimeout: const Duration(milliseconds: 1),
    );

    final exception = await _captureGatewayException(
      gateway.generate(_request(dayKey, persona, messages)),
    );

    expect(exception.category, GatewayExceptionCategory.timeout);
  });

  test('redacts HTTP client and credential-provider failures', () async {
    const privateDetail = 'Bearer private-token-value';
    final transportGateway = HttpDiaryGenerationGateway(
      client: MockClient(
        (_) async => throw http.ClientException(privateDetail),
      ),
      config: _configured(),
      authHeaders: () async => const <String, String>{},
    );
    final credentialGateway = HttpDiaryGenerationGateway(
      client: MockClient((_) async => _jsonResponse(_validOutput())),
      config: _configured(),
      authHeaders: () async => throw StateError(privateDetail),
    );

    for (final gateway in <HttpDiaryGenerationGateway>[
      transportGateway,
      credentialGateway,
    ]) {
      final exception = await _captureGatewayException(
        gateway.generate(_request(dayKey, persona, messages)),
      );
      expect(exception.category, GatewayExceptionCategory.network);
      expect(exception.toString(), isNot(contains(privateDetail)));
    }
  });

  test('rejects injected credential headers containing line breaks', () async {
    const privateDetail = 'Bearer private-token\ninvalid';
    final gateway = HttpDiaryGenerationGateway(
      client: MockClient((_) async => _jsonResponse(_validOutput())),
      config: _configured(),
      authHeaders: () async => const <String, String>{
        'Authorization': privateDetail,
      },
    );

    final exception = await _captureGatewayException(
      gateway.generate(_request(dayKey, persona, messages)),
    );

    expect(exception.category, GatewayExceptionCategory.network);
    expect(exception.toString(), isNot(contains(privateDetail)));
  });

  test('fails unconfigured before requesting credentials or HTTP', () async {
    var headerProviderCalled = false;
    var clientCalled = false;
    final gateway = HttpDiaryGenerationGateway(
      client: MockClient((_) async {
        clientCalled = true;
        return _jsonResponse(_validOutput());
      }),
      config: const GatewayConfig.unconfigured(),
      authHeaders: () async {
        headerProviderCalled = true;
        return const <String, String>{};
      },
    );

    final exception = await _captureGatewayException(
      gateway.generate(_request(dayKey, persona, messages)),
    );

    expect(exception.category, GatewayExceptionCategory.unconfigured);
    expect(headerProviderCalled, isFalse);
    expect(clientCalled, isFalse);
  });
}

DiaryGenerationRequest _request(
  DiaryDayKey dayKey,
  AiPersona persona,
  List<Message> messages,
) {
  return DiaryGenerationRequest(
    responseLocale: AiResponseLocale.ko,
    generationId: 'generation-1',
    dayKey: dayKey,
    weather: const WeatherSnapshot.noWeather(),
    persona: persona,
    messages: messages,
  );
}

Message _message({
  required String id,
  required String requestId,
  required DiaryDayKey dayKey,
  required MessageRole role,
  required String text,
  required DateTime createdAtUtc,
  String? photoAssetId,
}) {
  return Message(
    id: id,
    requestId: requestId,
    dayKey: dayKey,
    role: role,
    text: text,
    photoAssetId: photoAssetId,
    createdAtUtc: createdAtUtc,
    status: MessageStatus.sent,
  );
}

GatewayConfig _configured() {
  return GatewayConfig(baseUri: Uri.parse('https://gateway.example.com'));
}

Map<String, Object?> _validOutput() {
  return <String, Object?>{
    'schemaVersion': 1,
    'mood': '평온함',
    'oneLineSummary': '천천히 걸으며 여유를 찾은 하루.',
    'theme': 'light',
    'blocks': <Object?>[
      <String, Object?>{'type': 'text', 'text': '오늘은 천천히 걸으며 주변을 바라봤다.'},
      <String, Object?>{'type': 'photo', 'photoAssetId': 'photo-1'},
    ],
    'memoryCandidates': <Object?>[
      <String, Object?>{
        'fact': '사용자는 천천히 산책하는 것을 좋아한다.',
        'sourceMessageIds': <String>['message-1', 'message-2'],
      },
    ],
  };
}

Map<String, Object?> _textOnlyOutput({required String sourceMessageId}) {
  return <String, Object?>{
    'schemaVersion': 1,
    'mood': '평온함',
    'oneLineSummary': '차분한 하루.',
    'theme': 'light',
    'blocks': <Object?>[
      <String, Object?>{'type': 'text', 'text': '차분하게 하루를 보냈다.'},
    ],
    'memoryCandidates': <Object?>[
      <String, Object?>{
        'fact': '사용자는 차분한 시간을 보냈다.',
        'sourceMessageIds': <String>[sourceMessageId],
      },
    ],
  };
}

http.Response _jsonResponse(Map<String, Object?> body) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    200,
    headers: const <String, String>{'content-type': 'application/json'},
  );
}

Future<void> _expectInvalidOutput({
  required DiaryDayKey dayKey,
  required AiPersona persona,
  required List<Message> messages,
  required Map<String, Object?> payload,
}) async {
  final gateway = HttpDiaryGenerationGateway(
    client: MockClient((_) async => _jsonResponse(payload)),
    config: _configured(),
    authHeaders: () async => const <String, String>{},
  );

  final exception = await _captureGatewayException(
    gateway.generate(_request(dayKey, persona, messages)),
  );

  expect(exception.category, GatewayExceptionCategory.invalidResponse);
  expect(exception.toString(), isNot(contains(jsonEncode(payload))));
}

Future<void> _expectStatus(
  int status,
  GatewayExceptionCategory category,
  DiaryDayKey dayKey,
  AiPersona persona,
  List<Message> messages,
) async {
  const privateBody = 'private diary and server details';
  final gateway = HttpDiaryGenerationGateway(
    client: MockClient(
      (_) async => http.Response(
        privateBody,
        status,
        headers: const <String, String>{'content-type': 'application/json'},
      ),
    ),
    config: _configured(),
    authHeaders: () async => const <String, String>{},
  );

  final exception = await _captureGatewayException(
    gateway.generate(_request(dayKey, persona, messages)),
  );

  expect(exception.category, category);
  expect(exception.statusCode, status);
  expect(exception.toString(), isNot(contains(privateBody)));
}

Future<GatewayException> _captureGatewayException(
  Future<Object?> future,
) async {
  try {
    await future;
  } on GatewayException catch (error) {
    return error;
  }
  fail('Expected a GatewayException.');
}

final class _CloseTrackingClient extends http.BaseClient {
  _CloseTrackingClient(this._delegate);

  final http.Client _delegate;
  bool wasClosed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _delegate.send(request);
  }

  @override
  void close() {
    wasClosed = true;
    _delegate.close();
  }
}
