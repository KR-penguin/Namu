import 'gateway_config.dart';

/// Supplies the non-secret markers accepted by the local development Gateway.
///
/// Remote origins always receive an empty map. Production authentication must
/// be provided by a real identity and app-attestation adapter after DEC-03.
final class GatewayDevelopmentAuthHeaders {
  const GatewayDevelopmentAuthHeaders({
    required this.config,
    required this.principal,
  });

  factory GatewayDevelopmentAuthHeaders.fromEnvironment({
    required GatewayConfig config,
  }) {
    const principal = String.fromEnvironment('NAMU_DEVELOPMENT_PRINCIPAL');
    return GatewayDevelopmentAuthHeaders(config: config, principal: principal);
  }

  final GatewayConfig config;
  final String principal;

  Future<Map<String, String>> call() async {
    final baseUri = config.baseUri;
    if (baseUri == null || !_isLoopbackHttp(baseUri) || !_isValid(principal)) {
      return const <String, String>{};
    }
    return <String, String>{
      'Authorization': 'Bearer $principal',
      'X-App-Attestation': 'development-bypass',
    };
  }

  static bool _isLoopbackHttp(Uri uri) {
    if (uri.scheme != 'http') {
      return false;
    }
    final host = uri.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  }

  static bool _isValid(String value) {
    return value == value.trim() &&
        RegExp(r'^[A-Za-z0-9._:@-]{1,128}$').hasMatch(value);
  }
}
