import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/chat/domain/message.dart';

abstract interface class MessageRepository {
  /// Inserts a new message or replaces the message with the same [Message.id].
  Future<void> upsert(Message message);

  /// Returns the single user message associated with an idempotency key.
  Future<Message?> findUserByRequestId(String requestId);

  /// Returns only exact [dayKey] matches, ordered by UTC creation time.
  Future<List<Message>> listForDay(DiaryDayKey dayKey);

  /// Reconciles persisted user sends that were interrupted while `pending`.
  ///
  /// A pending user message with a saved, sent assistant message for the same
  /// request is completed as `sent`. A pending user message without one is
  /// marked `failed` so the user can explicitly retry with the original IDs.
  /// Implementations must scope user mutations to [dayKey], preserve all
  /// message content and identities, and apply the reconciliation atomically
  /// when their storage engine supports transactions.
  ///
  /// Callers must not run this while a live send is in flight.
  Future<void> recoverInterruptedSendsForDay(DiaryDayKey dayKey);

  /// Returns unique message day identities in calendar and identity order.
  ///
  /// The ordering is label date, timezone ID, cutoff, then policy version. It
  /// lets foreground repair discover missed days without loading message
  /// content for every day.
  Future<List<DiaryDayKey>> listDayKeysOldestFirst();
}
