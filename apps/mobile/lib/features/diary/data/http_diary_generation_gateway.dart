import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:namu/core/network/gateway_config.dart';
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/network/gateway_http_transport.dart';
import 'package:namu/core/network/gateway_request_body.dart';
import 'package:namu/core/network/gateway_response_mapper.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/diary/data/diary_generation_output_decoder.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

typedef DiaryGatewayHeaderProvider = Future<Map<String, String>> Function();

final class HttpDiaryGenerationGateway implements DiaryGenerationGateway {
  factory HttpDiaryGenerationGateway({
    required http.Client client,
    required GatewayConfig config,
    required DiaryGatewayHeaderProvider authHeaders,
    DiaryGenerationOutputDecoder decoder = const DiaryGenerationOutputDecoder(),
    Duration requestTimeout = const Duration(seconds: 30),
    int maxRequestBodyBytes = defaultGatewayRequestBodyLimitBytes,
    int maxResponseBodyBytes = defaultGatewayRequestBodyLimitBytes,
  }) {
    if (requestTimeout <= Duration.zero) {
      throw ArgumentError.value(
        requestTimeout,
        'requestTimeout',
        'must be positive',
      );
    }
    if (maxRequestBodyBytes <= 0) {
      throw ArgumentError.value(
        maxRequestBodyBytes,
        'maxRequestBodyBytes',
        'must be positive',
      );
    }
    return HttpDiaryGenerationGateway._(
      client,
      config,
      authHeaders,
      decoder,
      requestTimeout,
      maxRequestBodyBytes,
      maxResponseBodyBytes,
    );
  }

  HttpDiaryGenerationGateway._(
    http.Client client,
    this._config,
    this._authHeaders,
    this._decoder,
    this._requestTimeout,
    this._maxRequestBodyBytes,
    int maxResponseBodyBytes,
  ) : _transport = GatewayHttpTransport(
        client: client,
        requestTimeout: _requestTimeout,
        maxResponseBodyBytes: maxResponseBodyBytes,
      );

  static const int requestSchemaVersion = 2;
  static const Set<String> _reservedHeaderNames = <String>{
    'accept',
    'content-type',
    'idempotency-key',
  };
  static const Set<String> _allowedCredentialHeaderNames = <String>{
    'authorization',
    'x-app-attestation',
  };
  static final RegExp _headerNamePattern = RegExp(
    r"^[!#$%&'*+\-.^_`|~0-9A-Za-z]+$",
  );

  final GatewayConfig _config;
  final DiaryGatewayHeaderProvider _authHeaders;
  final DiaryGenerationOutputDecoder _decoder;
  final Duration _requestTimeout;
  final int _maxRequestBodyBytes;
  final GatewayHttpTransport _transport;

  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) async {
    final endpoint = _config.diaryGenerateUri;
    if (endpoint == null) {
      throw const GatewayException.unconfigured();
    }

    try {
      return await _send(endpoint, request);
    } on GatewayException {
      rethrow;
    } on TimeoutException {
      throw const GatewayException.timeout();
    } on http.ClientException {
      throw const GatewayException.network();
    }
  }

  Future<DiaryGenerationOutput> _send(
    Uri endpoint,
    DiaryGenerationRequest request,
  ) async {
    final sortedMessages = request.messages.toList()
      ..sort((left, right) {
        final byInstant = left.createdAtUtc.compareTo(right.createdAtUtc);
        return byInstant != 0 ? byInstant : left.id.compareTo(right.id);
      });
    final requestBody = encodeBoundedGatewayJson(<String, Object?>{
      'schemaVersion': requestSchemaVersion,
      'responseLocale': request.responseLocale.wireTag,
      'generationId': request.generationId,
      'dayKey': _encodeDayKey(request),
      'weather': _encodeWeather(request.weather),
      'persona': _encodePersona(request.persona),
      'messages': <Object?>[
        for (final message in sortedMessages) _encodeMessage(message),
      ],
    }, maxBytes: _maxRequestBodyBytes);
    final providedHeaders = await _loadAuthHeaders();
    final headers = <String, String>{};
    for (final entry in providedHeaders.entries) {
      if (_reservedHeaderNames.contains(entry.key.toLowerCase())) {
        continue;
      }
      if (!_allowedCredentialHeaderNames.contains(entry.key.toLowerCase()) ||
          !_headerNamePattern.hasMatch(entry.key) ||
          entry.value.contains('\r') ||
          entry.value.contains('\n')) {
        throw const GatewayException.network();
      }
      headers[entry.key] = entry.value;
    }
    headers.addAll(<String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Idempotency-Key': request.generationId,
    });
    final response = await _transport.postJson(
      endpoint: endpoint,
      headers: headers,
      bodyBytes: requestBody,
    );
    throwForGatewayError(response);
    return _decodeOutput(response.bodyBytes, request.messages);
  }

  Map<String, Object> _encodeDayKey(DiaryGenerationRequest request) {
    return <String, Object>{
      'labelDate': request.dayKey.labelDate.toString(),
      'timeZoneId': request.dayKey.timeZoneId,
      'cutoffMinutes': request.dayKey.cutoff.inMinutes,
      'policyVersion': request.dayKey.policyVersion,
    };
  }

  Map<String, Object?> _encodeWeather(WeatherSnapshot weather) {
    return <String, Object?>{
      'provenance': weather.provenance.name,
      'condition': weather.condition,
      'temperatureCelsius': weather.temperatureCelsius,
      'providerId': weather.providerId,
      'observedAtUtc': weather.observedAtUtc?.toIso8601String(),
    };
  }

  Map<String, Object> _encodePersona(AiPersona persona) {
    return <String, Object>{
      'id': persona.id,
      'name': persona.name,
      'avatarSeed': persona.avatarSeed,
      'tone': persona.tone,
      'customInstructions': persona.customInstructions,
      'reactionLength': persona.reactionLength.name,
    };
  }

  Map<String, Object?> _encodeMessage(Message message) {
    return <String, Object?>{
      'id': message.id,
      'role': message.role.name,
      'text': message.text,
      // Until explicit photo-analysis consent and upload boundaries exist, the
      // gateway receives only this opaque ordering reference, never bytes.
      'photoAssetId': message.photoAssetId,
      'createdAtUtc': message.createdAtUtc.toIso8601String(),
    };
  }

  Future<Map<String, String>> _loadAuthHeaders() async {
    try {
      return await _authHeaders().timeout(_requestTimeout);
    } on TimeoutException {
      throw const GatewayException.timeout();
    } catch (_) {
      throw const GatewayException.network();
    }
  }

  DiaryGenerationOutput _decodeOutput(
    List<int> bodyBytes,
    List<Message> requestedMessages,
  ) {
    final allowedPhotoAssetIds = requestedMessages
        .map((message) => message.photoAssetId)
        .whereType<String>()
        .toSet();
    final allowedSourceMessageIds = <String>{
      for (final message in requestedMessages) message.id,
    };

    try {
      return _decoder.decode(
        utf8.decode(bodyBytes),
        allowedPhotoAssetIds: allowedPhotoAssetIds,
        allowedSourceMessageIds: allowedSourceMessageIds,
      );
    } on FormatException {
      throw const GatewayException.invalidResponse();
    } on DiaryGenerationContractException {
      throw const GatewayException.invalidResponse();
    }
  }
}
