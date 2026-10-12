enum GatewayExceptionCategory {
  unconfigured,
  unauthorized,
  invalidAttestation,
  rateLimited,
  requestTooLarge,
  responseTooLarge,
  idempotencyConflict,
  rejected,
  safetyBlocked,
  modelTimeout,
  modelTruncated,
  invalidModelResponse,
  server,
  timeout,
  network,
  invalidResponse,
}

final class GatewayException implements Exception {
  const GatewayException._(this.category, {this.statusCode, this.retryAfter});

  const GatewayException.unconfigured()
    : this._(GatewayExceptionCategory.unconfigured);

  const GatewayException.unauthorized(int statusCode)
    : this._(GatewayExceptionCategory.unauthorized, statusCode: statusCode);

  const GatewayException.invalidAttestation(int statusCode)
    : this._(
        GatewayExceptionCategory.invalidAttestation,
        statusCode: statusCode,
      );

  const GatewayException.rateLimited(int statusCode, {Duration? retryAfter})
    : this._(
        GatewayExceptionCategory.rateLimited,
        statusCode: statusCode,
        retryAfter: retryAfter,
      );

  const GatewayException.requestTooLarge({int? statusCode})
    : this._(GatewayExceptionCategory.requestTooLarge, statusCode: statusCode);

  const GatewayException.responseTooLarge({int? statusCode})
    : this._(GatewayExceptionCategory.responseTooLarge, statusCode: statusCode);

  const GatewayException.idempotencyConflict(int statusCode)
    : this._(
        GatewayExceptionCategory.idempotencyConflict,
        statusCode: statusCode,
      );

  const GatewayException.rejected(int statusCode)
    : this._(GatewayExceptionCategory.rejected, statusCode: statusCode);

  const GatewayException.safetyBlocked(int statusCode)
    : this._(GatewayExceptionCategory.safetyBlocked, statusCode: statusCode);

  const GatewayException.modelTimeout(int statusCode)
    : this._(GatewayExceptionCategory.modelTimeout, statusCode: statusCode);

  const GatewayException.modelTruncated(int statusCode)
    : this._(GatewayExceptionCategory.modelTruncated, statusCode: statusCode);

  const GatewayException.invalidModelResponse(int statusCode)
    : this._(
        GatewayExceptionCategory.invalidModelResponse,
        statusCode: statusCode,
      );

  const GatewayException.server(int statusCode)
    : this._(GatewayExceptionCategory.server, statusCode: statusCode);

  const GatewayException.timeout() : this._(GatewayExceptionCategory.timeout);

  const GatewayException.network() : this._(GatewayExceptionCategory.network);

  const GatewayException.invalidResponse({int? statusCode})
    : this._(GatewayExceptionCategory.invalidResponse, statusCode: statusCode);

  final GatewayExceptionCategory category;
  final int? statusCode;
  final Duration? retryAfter;

  @override
  String toString() {
    final status = statusCode == null ? '' : ', statusCode: $statusCode';
    return 'GatewayException(category: ${category.name}$status)';
  }
}
