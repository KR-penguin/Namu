import 'dart:convert';

import 'gateway_exception.dart';
import 'gateway_http_transport.dart';

const int _maximumRetryAfterSeconds = 24 * 60 * 60;

/// Throws a redacted typed error for every non-success Gateway response.
///
/// Error bodies are treated as untrusted input. Only a short allowlisted code
/// is inspected; the body itself never crosses the network adapter boundary.
void throwForGatewayError(GatewayHttpResponse response) {
  final statusCode = response.statusCode;
  if (statusCode == 200) {
    return;
  }

  final publicCode = _decodePublicCode(response.bodyBytes);
  switch (publicCode) {
    case 'invalid_attestation':
      throw GatewayException.invalidAttestation(statusCode);
    case 'idempotency_conflict':
      throw GatewayException.idempotencyConflict(statusCode);
    case 'safety_blocked':
      throw GatewayException.safetyBlocked(statusCode);
    case 'model_timeout':
      throw GatewayException.modelTimeout(statusCode);
    case 'model_truncated':
      throw GatewayException.modelTruncated(statusCode);
    case 'invalid_model_response':
      throw GatewayException.invalidModelResponse(statusCode);
  }

  if (statusCode == 401 || statusCode == 403) {
    throw GatewayException.unauthorized(statusCode);
  }
  if (statusCode == 429) {
    throw GatewayException.rateLimited(
      statusCode,
      retryAfter: _parseRetryAfter(response.headers['retry-after']),
    );
  }
  if (statusCode == 413) {
    throw GatewayException.requestTooLarge(statusCode: statusCode);
  }
  if (statusCode == 409) {
    throw GatewayException.idempotencyConflict(statusCode);
  }
  if (statusCode == 400 || statusCode == 415 || statusCode == 422) {
    throw GatewayException.rejected(statusCode);
  }
  if (statusCode >= 500 && statusCode <= 599) {
    throw GatewayException.server(statusCode);
  }
  throw GatewayException.invalidResponse(statusCode: statusCode);
}

String? _decodePublicCode(List<int> bytes) {
  try {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final error = decoded['error'];
    if (error is! Map<String, dynamic>) {
      return null;
    }
    final code = error['code'];
    if (code is! String ||
        code.isEmpty ||
        code.length > 64 ||
        !RegExp(r'^[a-z0-9_]+$').hasMatch(code)) {
      return null;
    }
    return code;
  } on FormatException {
    return null;
  }
}

Duration? _parseRetryAfter(String? rawValue) {
  if (rawValue == null || !RegExp(r'^\d{1,10}$').hasMatch(rawValue)) {
    return null;
  }
  final parsed = int.tryParse(rawValue);
  if (parsed == null) {
    return null;
  }
  return Duration(seconds: parsed.clamp(0, _maximumRetryAfterSeconds));
}
