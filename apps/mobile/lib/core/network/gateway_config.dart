final class GatewayConfig {
  GatewayConfig({required Uri baseUri, bool allowInsecureLoopback = false})
    : baseUri = _validateBaseUri(
        baseUri,
        allowInsecureLoopback: allowInsecureLoopback,
      );

  const GatewayConfig.unconfigured() : baseUri = null;

  /// Reads the URL supplied with
  /// `--dart-define=NAMU_GATEWAY_BASE_URL=https://gateway.example.com`.
  ///
  /// A missing or invalid value stays unconfigured so the app can present a
  /// connection-required state instead of selecting an implicit endpoint.
  factory GatewayConfig.fromEnvironment({bool allowInsecureLoopback = false}) {
    const rawBaseUrl = String.fromEnvironment('NAMU_GATEWAY_BASE_URL');
    if (rawBaseUrl.trim().isEmpty) {
      return const GatewayConfig.unconfigured();
    }

    final candidate = Uri.tryParse(rawBaseUrl.trim());
    if (candidate == null) {
      return const GatewayConfig.unconfigured();
    }

    try {
      return GatewayConfig(
        baseUri: candidate,
        allowInsecureLoopback: allowInsecureLoopback,
      );
    } on ArgumentError {
      return const GatewayConfig.unconfigured();
    }
  }

  final Uri? baseUri;

  bool get isConfigured => baseUri != null;

  Uri? get chatReplyUri => baseUri?.resolve('/v1/chat/reply');

  Uri? get diaryGenerateUri => baseUri?.resolve('/v1/diary/generate');

  static Uri _validateBaseUri(
    Uri candidate, {
    required bool allowInsecureLoopback,
  }) {
    if (!candidate.isAbsolute || candidate.host.isEmpty) {
      throw ArgumentError('baseUri must be an absolute origin');
    }
    if (candidate.userInfo.isNotEmpty ||
        (candidate.path.isNotEmpty && candidate.path != '/') ||
        candidate.hasQuery ||
        candidate.hasFragment) {
      throw ArgumentError(
        'baseUri must not include credentials, a path, query, or fragment',
      );
    }

    if (candidate.scheme == 'https') {
      return candidate;
    }

    final host = candidate.host.toLowerCase();
    final isLoopback =
        host == 'localhost' || host == '127.0.0.1' || host == '::1';
    if (candidate.scheme == 'http' && allowInsecureLoopback && isLoopback) {
      return candidate;
    }

    throw ArgumentError(
      'baseUri must use HTTPS unless loopback HTTP is explicitly enabled',
    );
  }
}
