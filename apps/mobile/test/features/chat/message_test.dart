import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/domain/message.dart';

void main() {
  final dayKey = DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 8),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: Duration(hours: 9),
    ),
  );

  Message buildMessage({
    String? text = '오늘은 산책했어',
    String? photoAssetId,
    DateTime? createdAtUtc,
  }) {
    return Message(
      id: 'message-1',
      requestId: 'request-1',
      dayKey: dayKey,
      role: MessageRole.user,
      text: text,
      photoAssetId: photoAssetId,
      createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 10, 4, 8),
      status: MessageStatus.pending,
    );
  }

  test('requires at least one non-blank text or photo asset id', () {
    expect(
      () => buildMessage(text: null, photoAssetId: null),
      throwsArgumentError,
    );
    expect(
      () => buildMessage(text: '   ', photoAssetId: null),
      throwsArgumentError,
    );
    expect(
      () => buildMessage(text: null, photoAssetId: '   '),
      throwsArgumentError,
    );

    expect(() => buildMessage(), returnsNormally);
    expect(
      () => buildMessage(text: null, photoAssetId: 'photo-1'),
      returnsNormally,
    );
    expect(() => buildMessage(photoAssetId: 'photo-1'), returnsNormally);
  });

  test('requires createdAtUtc to be a UTC instant', () {
    expect(
      () => buildMessage(createdAtUtc: DateTime(2026, 10, 4, 8)),
      throwsArgumentError,
    );
  });

  test('changing status keeps the message identity and content', () {
    final pending = buildMessage(photoAssetId: 'photo-1');

    final sent = pending.withStatus(MessageStatus.sent);

    expect(sent.id, pending.id);
    expect(sent.requestId, pending.requestId);
    expect(sent.dayKey, pending.dayKey);
    expect(sent.role, pending.role);
    expect(sent.text, pending.text);
    expect(sent.photoAssetId, pending.photoAssetId);
    expect(sent.createdAtUtc, pending.createdAtUtc);
    expect(sent.status, MessageStatus.sent);
  });
}
