import '../../../core/time/diary_day_key.dart';
import '../domain/message.dart';
import '../domain/message_repository.dart';

final class InMemoryMessageRepository implements MessageRepository {
  final Map<String, Message> _messagesById = <String, Message>{};
  final Map<(MessageRole, String), String> _idByRequestAndRole =
      <(MessageRole, String), String>{};

  @override
  Future<void> upsert(Message message) async {
    final existingById = _messagesById[message.id];
    if (existingById != null &&
        (existingById.requestId != message.requestId ||
            existingById.role != message.role)) {
      throw StateError('A message ID cannot change request identity.');
    }

    final requestIdentity = (message.role, message.requestId);
    final existingId = _idByRequestAndRole[requestIdentity];
    if (existingId != null && existingId != message.id) {
      throw StateError('The request already has a message for this role.');
    }

    _messagesById[message.id] = message;
    _idByRequestAndRole[requestIdentity] = message.id;
  }

  @override
  Future<Message?> findUserByRequestId(String requestId) async {
    final id = _idByRequestAndRole[(MessageRole.user, requestId)];
    return id == null ? null : _messagesById[id];
  }

  @override
  Future<List<Message>> listForDay(DiaryDayKey dayKey) async {
    final messages =
        _messagesById.values
            .where((message) => message.dayKey == dayKey)
            .toList()
          ..sort((left, right) {
            final byCreatedAt = left.createdAtUtc.compareTo(right.createdAtUtc);
            return byCreatedAt != 0 ? byCreatedAt : left.id.compareTo(right.id);
          });

    return List<Message>.unmodifiable(messages);
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
    final dayKeys =
        _messagesById.values.map((message) => message.dayKey).toSet().toList()
          ..sort(_compareDayKeys);
    return List<DiaryDayKey>.unmodifiable(dayKeys);
  }

  static int _compareDayKeys(DiaryDayKey left, DiaryDayKey right) {
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
  }
}
