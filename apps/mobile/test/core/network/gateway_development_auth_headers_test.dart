import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/network/gateway_config.dart';
import 'package:namu/core/network/gateway_development_auth_headers.dart';

void main() {
  test('loopback development config emits the two local markers', () async {
    final headers = GatewayDevelopmentAuthHeaders(
      config: GatewayConfig(
        baseUri: Uri.parse('http://127.0.0.1:8080'),
        allowInsecureLoopback: true,
      ),
      principal: 'preview-user',
    );

    expect(await headers(), <String, String>{
      'Authorization': 'Bearer preview-user',
      'X-App-Attestation': 'development-bypass',
    });
  });

  test('blank or malformed principals fail closed', () async {
    final config = GatewayConfig(
      baseUri: Uri.parse('http://localhost:8080'),
      allowInsecureLoopback: true,
    );

    for (final principal in <String>['', 'two words', 'a\nb']) {
      expect(
        await GatewayDevelopmentAuthHeaders(
          config: config,
          principal: principal,
        )(),
        isEmpty,
      );
    }
  });

  test('never emits development markers for a remote HTTPS gateway', () async {
    final headers = GatewayDevelopmentAuthHeaders(
      config: GatewayConfig(baseUri: Uri.parse('https://gateway.example.com')),
      principal: 'preview-user',
    );

    expect(await headers(), isEmpty);
  });

  test('unconfigured gateway emits no headers', () async {
    const headers = GatewayDevelopmentAuthHeaders(
      config: GatewayConfig.unconfigured(),
      principal: 'preview-user',
    );

    expect(await headers(), isEmpty);
  });
}
