import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'gateway_exception.dart';
import 'gateway_request_body.dart';

final class GatewayHttpResponse {
  GatewayHttpResponse({
    required this.statusCode,
    required Map<String, String> headers,
    required List<int> bodyBytes,
  }) : headers = Map<String, String>.unmodifiable(headers),
       bodyBytes = Uint8List.fromList(bodyBytes);

  final int statusCode;
  final Map<String, String> headers;
  final Uint8List bodyBytes;
}

/// Sends one bounded JSON request and aborts the underlying HTTP operation on
/// deadline or response overflow.
///
/// This adapter deliberately owns no retry policy. Chat and diary operations
/// are idempotent, but only an explicit user/application retry may start a new
/// attempt so safety blocks and malformed responses are never retried here.
final class GatewayHttpTransport {
  GatewayHttpTransport({
    required this.client,
    required this.requestTimeout,
    this.maxResponseBodyBytes = defaultGatewayRequestBodyLimitBytes,
  }) {
    if (requestTimeout <= Duration.zero) {
      throw ArgumentError.value(
        requestTimeout,
        'requestTimeout',
        'must be positive',
      );
    }
    if (maxResponseBodyBytes <= 0) {
      throw ArgumentError.value(
        maxResponseBodyBytes,
        'maxResponseBodyBytes',
        'must be positive',
      );
    }
  }

  final http.Client client;
  final Duration requestTimeout;
  final int maxResponseBodyBytes;

  Future<GatewayHttpResponse> postJson({
    required Uri endpoint,
    required Map<String, String> headers,
    required List<int> bodyBytes,
  }) async {
    final abort = Completer<void>();
    final elapsed = Stopwatch()..start();
    final request =
        http.AbortableRequest('POST', endpoint, abortTrigger: abort.future)
          ..headers.addAll(headers)
          ..bodyBytes = Uint8List.fromList(bodyBytes);

    try {
      final response = await client
          .send(request)
          .timeout(
            _remaining(elapsed),
            onTimeout: () {
              _abort(abort);
              throw const GatewayException.timeout();
            },
          );
      final declaredLength = response.contentLength;
      if (declaredLength != null && declaredLength > maxResponseBodyBytes) {
        _abort(abort);
        throw GatewayException.responseTooLarge(
          statusCode: response.statusCode,
        );
      }
      final hasJsonContentType = _isJson(response.headers['content-type']);

      final bytes = BytesBuilder(copy: false);
      var received = 0;
      await (() async {
        await for (final chunk in response.stream) {
          received += chunk.length;
          if (received > maxResponseBodyBytes) {
            _abort(abort);
            throw GatewayException.responseTooLarge(
              statusCode: response.statusCode,
            );
          }
          bytes.add(chunk);
        }
      })().timeout(
        _remaining(elapsed),
        onTimeout: () {
          _abort(abort);
          throw const GatewayException.timeout();
        },
      );
      if (!hasJsonContentType) {
        throw GatewayException.invalidResponse(statusCode: response.statusCode);
      }
      return GatewayHttpResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        bodyBytes: bytes.takeBytes(),
      );
    } on GatewayException {
      rethrow;
    } on http.RequestAbortedException {
      throw const GatewayException.network();
    } on http.ClientException {
      throw const GatewayException.network();
    } on TimeoutException {
      _abort(abort);
      throw const GatewayException.timeout();
    } catch (_) {
      throw const GatewayException.network();
    }
  }

  Duration _remaining(Stopwatch elapsed) {
    final remaining = requestTimeout - elapsed.elapsed;
    return remaining > Duration.zero
        ? remaining
        : const Duration(microseconds: 1);
  }

  static void _abort(Completer<void> abort) {
    if (!abort.isCompleted) {
      abort.complete();
    }
  }

  static bool _isJson(String? contentType) {
    return contentType?.split(';').first.trim().toLowerCase() ==
        'application/json';
  }
}
