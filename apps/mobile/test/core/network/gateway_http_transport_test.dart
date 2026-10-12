import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/network/gateway_http_transport.dart';

void main() {
  final endpoint = Uri.parse('https://gateway.example.com/v1/chat/reply');

  test('sends an abortable JSON request and returns bounded bytes', () async {
    http.BaseRequest? captured;
    final transport = GatewayHttpTransport(
      client: _StreamingClient((request) async {
        captured = request;
        return _response(200, <List<int>>[
          utf8.encode('{"ok":'),
          utf8.encode('true}'),
        ]);
      }),
      requestTimeout: const Duration(seconds: 1),
      maxResponseBodyBytes: 64,
    );

    final response = await transport.postJson(
      endpoint: endpoint,
      headers: const <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
      bodyBytes: utf8.encode('{"request":1}'),
    );

    expect(captured, isA<http.AbortableRequest>());
    expect(captured!.method, 'POST');
    expect(response.statusCode, 200);
    expect(utf8.decode(response.bodyBytes), '{"ok":true}');
  });

  test('rejects a non-JSON response without exposing its body', () async {
    const privateBody = 'private proxy page';
    final transport = GatewayHttpTransport(
      client: _StreamingClient(
        (_) async => _response(200, <List<int>>[
          utf8.encode(privateBody),
        ], contentType: 'text/html'),
      ),
      requestTimeout: const Duration(seconds: 1),
    );

    final error = await _capture(
      transport.postJson(
        endpoint: endpoint,
        headers: const {},
        bodyBytes: utf8.encode('{}'),
      ),
    );

    expect(error.category, GatewayExceptionCategory.invalidResponse);
    expect(error.toString(), isNot(contains(privateBody)));
  });

  test('aborts and rejects a chunked response over the byte limit', () async {
    final client = _StreamingClient(
      (_) async => _response(200, <List<int>>[
        <int>[1, 2, 3, 4],
        <int>[5],
      ]),
    );
    final transport = GatewayHttpTransport(
      client: client,
      requestTimeout: const Duration(seconds: 1),
      maxResponseBodyBytes: 4,
    );

    final error = await _capture(
      transport.postJson(
        endpoint: endpoint,
        headers: const {},
        bodyBytes: utf8.encode('{}'),
      ),
    );

    expect(error.category, GatewayExceptionCategory.responseTooLarge);
    expect(client.lastRequestAbortTrigger, completes);
  });

  test('completes the abort trigger when the request times out', () async {
    final client = _AbortWaitingClient();
    final transport = GatewayHttpTransport(
      client: client,
      requestTimeout: const Duration(milliseconds: 1),
    );

    final error = await _capture(
      transport.postJson(
        endpoint: endpoint,
        headers: const {},
        bodyBytes: utf8.encode('{}'),
      ),
    );

    expect(error.category, GatewayExceptionCategory.timeout);
    await client.abortObserved;
    expect(client.sawAbort, isTrue);
  });

  test('redacts transport failures', () async {
    const privateDetail = 'socket failed while sending private diary text';
    final transport = GatewayHttpTransport(
      client: _StreamingClient(
        (_) async => throw http.ClientException(privateDetail),
      ),
      requestTimeout: const Duration(seconds: 1),
    );

    final error = await _capture(
      transport.postJson(
        endpoint: endpoint,
        headers: const {},
        bodyBytes: utf8.encode('{}'),
      ),
    );

    expect(error.category, GatewayExceptionCategory.network);
    expect(error.toString(), isNot(contains(privateDetail)));
  });
}

http.StreamedResponse _response(
  int status,
  Iterable<List<int>> chunks, {
  String contentType = 'application/json; charset=utf-8',
}) {
  return http.StreamedResponse(
    Stream<List<int>>.fromIterable(chunks),
    status,
    headers: <String, String>{'content-type': contentType},
  );
}

Future<GatewayException> _capture(Future<Object?> future) async {
  try {
    await future;
  } on GatewayException catch (error) {
    return error;
  }
  fail('Expected a GatewayException.');
}

final class _StreamingClient extends http.BaseClient {
  _StreamingClient(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  handler;
  Future<void>? lastRequestAbortTrigger;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request case http.Abortable(:final abortTrigger)) {
      lastRequestAbortTrigger = abortTrigger;
    }
    return handler(request);
  }
}

final class _AbortWaitingClient extends http.BaseClient {
  bool sawAbort = false;
  final Completer<void> _abortObserved = Completer<void>();

  Future<void> get abortObserved => _abortObserved.future;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final abortTrigger = (request as http.Abortable).abortTrigger!;
    await abortTrigger;
    sawAbort = true;
    _abortObserved.complete();
    throw http.RequestAbortedException(request.url);
  }
}
