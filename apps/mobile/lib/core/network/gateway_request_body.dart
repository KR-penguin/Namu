import 'dart:convert';

import 'gateway_exception.dart';

/// Matches the AI Gateway's default `NAMU_JSON_BODY_LIMIT_BYTES` value.
///
/// Deployments that intentionally use a different server limit can inject the
/// same value into each HTTP gateway. A server-side 413 is still mapped to the
/// same typed failure when the deployment is more restrictive than the app.
const int defaultGatewayRequestBodyLimitBytes = 256 * 1024;

List<int> encodeBoundedGatewayJson(
  Map<String, Object?> payload, {
  required int maxBytes,
}) {
  final bytes = utf8.encode(jsonEncode(payload));
  if (bytes.length > maxBytes) {
    throw const GatewayException.requestTooLarge();
  }
  return bytes;
}
