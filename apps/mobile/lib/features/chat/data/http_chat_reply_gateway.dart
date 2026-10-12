import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/core/network/gateway_config.dart';
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/network/gateway_http_transport.dart';
import 'package:namu/core/network/gateway_request_body.dart';
import 'package:namu/core/network/gateway_response_mapper.dart';
import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

typedef GatewayHeaderProvider = Future<Map<String, String>> Function();
typedef ChatContextProvider = Future<ChatRequestContext> Function(
  Message pendingUserMessage,
);

final class ChatRequestContext {
  ChatRequestContext({
    required this.responseLocale,
    required this.persona,
    required Iterable<Message> recentMessages,
    required Iterable<MemoryFact> memoryFacts,
  }) : recentMessages = List<Message>.unmodifiable(recentMessages),
       memoryFacts = List<MemoryFact>.unmodifiable(memoryFacts);

  factory ChatRequestContext.empty({
    AiResponseLocale responseLocale = AiResponseLocale.en,
  }) => ChatRequestContext(
    responseLocale: responseLocale,
    persona: AiPersona.safeDefault(),
    recentMessages: const [],
    memoryFacts: const [],
  );

  final AiResponseLocale responseLocale;
  final AiPersona persona;
  final List<Message> recentMessages;
  final List<MemoryFact> memoryFacts;
}

final class HttpChatReplyGateway implements ChatReplyGateway {
  factory HttpChatReplyGateway({
    required http.Client client,
    required GatewayConfig config,
    required GatewayHeaderProvider authHeaders,
    ChatContextProvider? contextProvider,
    Duration requestTimeout = const Duration(seconds: 20),
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
    return HttpChatReplyGateway._(
      client,
      config,
      authHeaders,
      contextProvider ?? (_) async => ChatRequestContext.empty(),
      requestTimeout,
      maxRequestBodyBytes,
      maxResponseBodyBytes,
    );
  }

  HttpChatReplyGateway._(
    http.Client client,
    this._config,
    this._authHeaders,
    this._contextProvider,
    this._requestTimeout,
    this._maxRequestBodyBytes,
    int maxResponseBodyBytes,
  ) : _transport = GatewayHttpTransport(
        client: client,
        requestTimeout: _requestTimeout,
        maxResponseBodyBytes: maxResponseBodyBytes,
      );

  static const int requestSchemaVersion = 2;
  static const int responseSchemaVersion = 1;
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
  final GatewayHeaderProvider _authHeaders;
  final ChatContextProvider _contextProvider;
  final Duration _requestTimeout;
  final int _maxRequestBodyBytes;
  final GatewayHttpTransport _transport;

  @override
  Future<ChatReply> replyTo(Message pendingUserMessage) async {
    final endpoint = _config.chatReplyUri;
    if (endpoint == null) {
      throw const GatewayException.unconfigured();
    }

    try {
      return await _send(endpoint, pendingUserMessage);
    } on GatewayException {
      rethrow;
    } on TimeoutException {
      throw const GatewayException.timeout();
    } on http.ClientException {
      throw const GatewayException.network();
    }
  }

  Future<ChatReply> _send(Uri endpoint, Message pendingUserMessage) async {
    final context = await _loadContext(pendingUserMessage);
    final requestBody = encodeBoundedGatewayJson(<String, Object?>{
      'schemaVersion': requestSchemaVersion,
      'responseLocale': context.responseLocale.wireTag,
      'requestId': pendingUserMessage.requestId,
      'messageId': pendingUserMessage.id,
      'text': pendingUserMessage.text,
      'photoAssetId': pendingUserMessage.photoAssetId,
      'createdAtUtc': pendingUserMessage.createdAtUtc.toIso8601String(),
      'dayKey': <String, Object>{
        'labelDate': pendingUserMessage.dayKey.labelDate.toString(),
        'timeZoneId': pendingUserMessage.dayKey.timeZoneId,
        'cutoffMinutes': pendingUserMessage.dayKey.cutoff.inMinutes,
        'policyVersion': pendingUserMessage.dayKey.policyVersion,
      },
      'persona': _encodePersona(context.persona),
      'recentMessages': _recentMessages(context, pendingUserMessage),
      'activeMemories': _activeMemories(context),
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
      'Idempotency-Key': pendingUserMessage.requestId,
    });

    final response = await _transport.postJson(
      endpoint: endpoint,
      headers: headers,
      bodyBytes: requestBody,
    );
    throwForGatewayError(response);
    return _decodeReply(response.bodyBytes);
  }

  Future<Map<String, String>> _loadAuthHeaders() async {
    try {
      return await _authHeaders().timeout(_requestTimeout);
    } on TimeoutException {
      throw const GatewayException.timeout();
    } catch (_) {
      // Credential-provider failures may contain token details. Do not let the
      // provider's error text cross this adapter boundary.
      throw const GatewayException.network();
    }
  }

  Future<ChatRequestContext> _loadContext(Message pendingUserMessage) async {
    try {
      return await _contextProvider(pendingUserMessage)
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw const GatewayException.timeout();
    } catch (_) {
      // Repository/provider errors may include private content. Keep them
      // behind the same redacted transport boundary as credential failures.
      throw const GatewayException.network();
    }
  }

  Map<String, Object> _encodePersona(AiPersona persona) => <String, Object>{
    'id': persona.id,
    'name': persona.name,
    'avatarSeed': persona.avatarSeed,
    'tone': persona.tone,
    'customInstructions': persona.customInstructions,
    'reactionLength': persona.reactionLength.name,
  };

  List<Map<String, Object?>> _recentMessages(
    ChatRequestContext context,
    Message pendingUserMessage,
  ) {
    final messages =
        context.recentMessages
            .where(
              (message) =>
                  message.id != pendingUserMessage.id &&
                  message.dayKey == pendingUserMessage.dayKey,
            )
            .toList()
          ..sort((left, right) {
            final byInstant = left.createdAtUtc.compareTo(right.createdAtUtc);
            return byInstant != 0 ? byInstant : left.id.compareTo(right.id);
          });
    final limited = messages.length <= 30
        ? messages
        : messages.sublist(messages.length - 30);
    return <Map<String, Object?>>[
      for (final message in limited)
        <String, Object?>{
          'id': message.id,
          'role': message.role.name,
          'text': message.text,
          'photoAssetId': message.photoAssetId,
          'createdAtUtc': message.createdAtUtc.toIso8601String(),
        },
    ];
  }

  List<Map<String, Object>> _activeMemories(ChatRequestContext context) {
    final memories =
        context.memoryFacts
            .where((memory) => memory.status == MemoryStatus.active)
            .toList()
          ..sort((left, right) {
            final byUpdated = right.updatedAtUtc.compareTo(left.updatedAtUtc);
            return byUpdated != 0 ? byUpdated : left.id.compareTo(right.id);
          });
    final limited = memories.length <= 20 ? memories : memories.sublist(0, 20);
    return <Map<String, Object>>[
      for (final memory in limited)
        <String, Object>{
          'id': memory.id,
          'fact': memory.fact,
          'category': memory.category.name,
          'updatedAtUtc': memory.updatedAtUtc.toIso8601String(),
        },
    ];
  }

  ChatReply _decodeReply(List<int> bodyBytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected an object.');
      }

      const expectedKeys = <String>{
        'schemaVersion',
        'messageId',
        'text',
        'createdAtUtc',
      };
      if (decoded.length != expectedKeys.length ||
          !expectedKeys.every(decoded.containsKey)) {
        throw const FormatException('Unexpected response fields.');
      }

      final responseSchemaVersion = decoded['schemaVersion'];
      final messageId = decoded['messageId'];
      final text = decoded['text'];
      final rawCreatedAtUtc = decoded['createdAtUtc'];
      if (responseSchemaVersion is! int ||
          responseSchemaVersion != HttpChatReplyGateway.responseSchemaVersion ||
          messageId is! String ||
          messageId.trim().isEmpty ||
          text is! String ||
          text.trim().isEmpty ||
          rawCreatedAtUtc is! String ||
          !rawCreatedAtUtc.endsWith('Z')) {
        throw const FormatException('Invalid response fields.');
      }

      final createdAtUtc = DateTime.tryParse(rawCreatedAtUtc);
      if (createdAtUtc == null || !createdAtUtc.isUtc) {
        throw const FormatException('Invalid UTC timestamp.');
      }

      return ChatReply(
        messageId: messageId,
        text: text,
        createdAtUtc: createdAtUtc,
      );
    } on FormatException {
      throw const GatewayException.invalidResponse();
    } on ArgumentError {
      throw const GatewayException.invalidResponse();
    }
  }
}
