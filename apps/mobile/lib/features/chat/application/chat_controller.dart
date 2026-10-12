// The public `dayKey` constructor name initializes private mutable rollover state.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../core/time/diary_day_key.dart';
import '../domain/message.dart';
import '../domain/message_repository.dart';
import 'send_message.dart';

typedef UtcClock = DateTime Function();
typedef ChatIdGenerator = String Function();

final class ChatController extends ChangeNotifier {
  ChatController({
    required DiaryDayKey dayKey,
    required this.repository,
    required this.sendMessage,
    required this.utcNow,
    required this.nextId,
  }) : _dayKey = dayKey;

  DiaryDayKey _dayKey;
  final MessageRepository repository;
  final SendMessage sendMessage;
  final UtcClock utcNow;
  final ChatIdGenerator nextId;

  List<Message> _messages = const [];
  int _activeLoadCount = 0;
  bool _isSending = false;
  Object? _error;

  List<Message> get messages => List.unmodifiable(_messages);
  DiaryDayKey get dayKey => _dayKey;
  bool get isLoading => _activeLoadCount > 0;
  bool get isSending => _isSending;
  Object? get error => _error;

  Future<void> load() async {
    if (isLoading || _isSending) {
      return;
    }
    await _loadDay(dayKey);
  }

  Future<void> switchDay(DiaryDayKey nextDay) async {
    if (nextDay == dayKey) {
      return;
    }
    _dayKey = nextDay;
    _messages = const [];
    _error = null;
    notifyListeners();
    await _loadDay(nextDay);
  }

  Future<void> _loadDay(DiaryDayKey targetDay) async {
    _activeLoadCount += 1;
    _error = null;
    notifyListeners();

    try {
      await repository.recoverInterruptedSendsForDay(targetDay);
      final loadedMessages = await repository.listForDay(targetDay);
      if (dayKey == targetDay) {
        _messages = loadedMessages;
      }
    } catch (error) {
      if (dayKey == targetDay) {
        _error = error;
      }
      rethrow;
    } finally {
      _activeLoadCount -= 1;
      notifyListeners();
    }
  }

  Future<void> sendText(String draft) async {
    final text = draft.trim();
    if (text.isEmpty) {
      return;
    }

    final createdAtUtc = utcNow();
    if (!createdAtUtc.isUtc) {
      throw StateError('utcNow must return a UTC instant.');
    }

    final messageId = nextId();
    final requestId = nextId();
    return _sendCommand(
      SendMessageCommand(
        messageId: messageId,
        requestId: requestId,
        dayKey: dayKey,
        text: text,
        createdAtUtc: createdAtUtc,
      ),
    );
  }

  Future<void> sendPhoto(String photoAssetId, {String? caption}) async {
    final normalizedAssetId = photoAssetId.trim();
    if (normalizedAssetId.isEmpty) {
      throw ArgumentError.value(
        photoAssetId,
        'photoAssetId',
        'must not be blank',
      );
    }
    final normalizedCaption = caption?.trim();
    final createdAtUtc = utcNow();
    if (!createdAtUtc.isUtc) {
      throw StateError('utcNow must return a UTC instant.');
    }

    await _sendCommand(
      SendMessageCommand(
        messageId: nextId(),
        requestId: nextId(),
        dayKey: dayKey,
        text: normalizedCaption == null || normalizedCaption.isEmpty
            ? null
            : normalizedCaption,
        photoAssetId: normalizedAssetId,
        createdAtUtc: createdAtUtc,
      ),
    );
  }

  Future<void> retryFailed(String messageId) async {
    final matches = _messages.where((message) => message.id == messageId);
    if (matches.length != 1) {
      throw StateError('The failed message is not loaded.');
    }
    final message = matches.single;
    if (message.role != MessageRole.user ||
        message.status != MessageStatus.failed ||
        message.dayKey != dayKey) {
      throw StateError('Only a failed user message from this day can retry.');
    }

    await _sendCommand(
      SendMessageCommand(
        messageId: message.id,
        requestId: message.requestId,
        dayKey: message.dayKey,
        text: message.text,
        photoAssetId: message.photoAssetId,
        createdAtUtc: message.createdAtUtc,
      ),
    );
  }

  Future<void> _sendCommand(SendMessageCommand command) async {
    if (_isSending) {
      throw StateError('A message is already being sent.');
    }

    _isSending = true;
    _error = null;
    notifyListeners();

    Object? sendError;
    StackTrace? sendStackTrace;
    try {
      await sendMessage(command);
    } catch (error, stackTrace) {
      _error = error;
      sendError = error;
      sendStackTrace = stackTrace;
    }

    Object? refreshError;
    StackTrace? refreshStackTrace;
    try {
      final refreshDay = dayKey;
      final refreshedMessages = await repository.listForDay(refreshDay);
      if (dayKey == refreshDay) {
        _messages = refreshedMessages;
      }
    } catch (error, stackTrace) {
      _error ??= error;
      refreshError = error;
      refreshStackTrace = stackTrace;
    } finally {
      _isSending = false;
      notifyListeners();
    }

    if (sendError != null) {
      Error.throwWithStackTrace(sendError, sendStackTrace!);
    }
    if (refreshError != null) {
      Error.throwWithStackTrace(refreshError, refreshStackTrace!);
    }
  }
}
