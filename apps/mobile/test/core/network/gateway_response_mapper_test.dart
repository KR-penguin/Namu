import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/network/gateway_http_transport.dart';
import 'package:namu/core/network/gateway_response_mapper.dart';

void main() {
  test('accepts only the successful status', () {
    expect(() => throwForGatewayError(_response(200)), returnsNormally);
  });

  test('maps attestation and idempotency failures distinctly', () {
    final attestation = _capture(
      () => throwForGatewayError(_response(403, code: 'invalid_attestation')),
    );
    final conflict = _capture(
      () => throwForGatewayError(_response(409, code: 'idempotency_conflict')),
    );

    expect(attestation.category, GatewayExceptionCategory.invalidAttestation);
    expect(conflict.category, GatewayExceptionCategory.idempotencyConflict);
  });

  test('maps model safety, timeout, and invalid-output codes distinctly', () {
    final cases = <String, GatewayExceptionCategory>{
      'safety_blocked': GatewayExceptionCategory.safetyBlocked,
      'model_timeout': GatewayExceptionCategory.modelTimeout,
      'model_truncated': GatewayExceptionCategory.modelTruncated,
      'invalid_model_response': GatewayExceptionCategory.invalidModelResponse,
    };

    for (final entry in cases.entries) {
      final error = _capture(
        () => throwForGatewayError(_response(502, code: entry.key)),
      );
      expect(error.category, entry.value);
      expect(error.toString(), isNot(contains(entry.key)));
    }
  });

  test('parses a bounded Retry-After delta and ignores malformed values', () {
    final valid = _capture(
      () => throwForGatewayError(
        _response(429, code: 'rate_limited', retryAfter: '12'),
      ),
    );
    final excessive = _capture(
      () => throwForGatewayError(
        _response(429, code: 'rate_limited', retryAfter: '999999'),
      ),
    );
    final malformed = _capture(
      () => throwForGatewayError(
        _response(429, code: 'rate_limited', retryAfter: 'private'),
      ),
    );

    expect(valid.retryAfter, const Duration(seconds: 12));
    expect(excessive.retryAfter, const Duration(hours: 24));
    expect(malformed.retryAfter, isNull);
  });

  test('falls back to redacted status mapping for malformed error bodies', () {
    final unauthorized = _capture(
      () => throwForGatewayError(_response(401, rawBody: 'private')),
    );
    final server = _capture(
      () => throwForGatewayError(_response(503, rawBody: '{not-json')),
    );

    expect(unauthorized.category, GatewayExceptionCategory.unauthorized);
    expect(server.category, GatewayExceptionCategory.server);
    expect(server.toString(), isNot(contains('not-json')));
  });
}

GatewayHttpResponse _response(
  int status, {
  String? code,
  String? retryAfter,
  String? rawBody,
}) {
  return GatewayHttpResponse(
    statusCode: status,
    headers: <String, String>{'retry-after': ?retryAfter},
    bodyBytes: utf8.encode(
      rawBody ??
          jsonEncode(<String, Object?>{
            'error': <String, Object?>{'code': ?code},
          }),
    ),
  );
}

GatewayException _capture(void Function() action) {
  try {
    action();
  } on GatewayException catch (error) {
    return error;
  }
  fail('Expected a GatewayException.');
}
