import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/chat/domain/message_repository.dart';

final class FakeMessageRepository implements MessageRepository {
  final Map<String, Message> _messagesById = <String, Message>{};
  Object? listError;

  List<Message> get messages =>
      List<Message>.unmodifiable(_messagesById.values);

  @override
  Future<Message?> findUserByRequestId(String requestId) async {
    for (final message in _messagesById.values) {
      if (message.requestId == requestId && message.role == MessageRole.user) {
        return message;
      }
    }
    return null;
  }

  @override
  Future<List<Message>> listForDay(DiaryDayKey dayKey) async {
    final error = listError;
    if (error != null) {
      throw error;
    }

    final result =
        _messagesById.values
            .where((message) => message.dayKey == dayKey)
            .toList()
          ..sort((left, right) {
            final byCreatedAt = left.createdAtUtc.compareTo(right.createdAtUtc);
            return byCreatedAt != 0 ? byCreatedAt : left.id.compareTo(right.id);
          });

    return result;
  }

  @override
  Future<void> recoverInterruptedSendsForDay(DiaryDayKey dayKey) async {
    final answeredRequestIds = _messagesById.values
        .where(
          (message) =>
              message.role == MessageRole.assistant &&
              message.status == MessageStatus.sent,
        )
        .map((message) => message.requestId)
        .toSet();
    final pendingUsers = _messagesById.values
        .where(
          (message) =>
              message.dayKey == dayKey &&
              message.role == MessageRole.user &&
              message.status == MessageStatus.pending,
        )
        .toList(growable: false);
    for (final message in pendingUsers) {
      _messagesById[message.id] = message.withStatus(
        answeredRequestIds.contains(message.requestId)
            ? MessageStatus.sent
            : MessageStatus.failed,
      );
    }
  }

  @override
  Future<List<DiaryDayKey>> listDayKeysOldestFirst() async {
    final error = listError;
    if (error != null) {
      throw error;
    }
    final dayKeys =
        _messagesById.values.map((message) => message.dayKey).toSet().toList()
          ..sort((left, right) {
            final leftDate = left.labelDate;
            final rightDate = right.labelDate;
            final byYear = leftDate.year.compareTo(rightDate.year);
            if (byYear != 0) return byYear;
            final byMonth = leftDate.month.compareTo(rightDate.month);
            if (byMonth != 0) return byMonth;
            final byDay = leftDate.day.compareTo(rightDate.day);
            if (byDay != 0) return byDay;
            final byTimeZone = left.timeZoneId.compareTo(right.timeZoneId);
            if (byTimeZone != 0) return byTimeZone;
            final byCutoff = left.cutoff.compareTo(right.cutoff);
            if (byCutoff != 0) return byCutoff;
            return left.policyVersion.compareTo(right.policyVersion);
          });
    return List<DiaryDayKey>.unmodifiable(dayKeys);
  }

  @override
  Future<void> upsert(Message message) async {
    _messagesById[message.id] = message;
  }
}
