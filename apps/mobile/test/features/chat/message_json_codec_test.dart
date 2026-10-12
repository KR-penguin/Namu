import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/data/message_json_codec.dart';
import 'package:namu/features/chat/domain/message.dart';

void main() {
  const codec = MessageJsonCodec();
  final dayKey = DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 8),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );

  test('round-trips every persisted message field', () {
    final message = Message(
      id: 'message-1',
      requestId: 'request-1',
      dayKey: dayKey,
      role: MessageRole.user,
      text: '산책했어',
      photoAssetId: 'photo-1',
      createdAtUtc: DateTime.utc(2026, 10, 4, 8, 30),
      status: MessageStatus.failed,
    );

    final decoded = codec.decode(codec.encode(message));

    expect(decoded.id, message.id);
    expect(decoded.requestId, message.requestId);
    expect(decoded.dayKey, message.dayKey);
    expect(decoded.role, message.role);
    expect(decoded.text, message.text);
    expect(decoded.photoAssetId, message.photoAssetId);
    expect(decoded.createdAtUtc, message.createdAtUtc);
    expect(decoded.status, message.status);
  });

  test('rejects missing, extra, or unknown enum data', () {
    final valid = codec.encode(
      Message(
        id: 'message-1',
        requestId: 'request-1',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '산책했어',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 30),
        status: MessageStatus.sent,
      ),
    );

    final missingId = Map<String, Object?>.from(valid)..remove('id');
    expect(() => codec.decode(missingId), throwsFormatException);
    expect(
      () => codec.decode({...valid, 'unexpected': true}),
      throwsFormatException,
    );
    expect(
      () => codec.decode({...valid, 'role': 'system'}),
      throwsFormatException,
    );
    expect(
      () => codec.decode({...valid, 'status': 'unknown'}),
      throwsFormatException,
    );
  });

  test('rejects malformed day and timestamp data', () {
    final valid = codec.encode(
      Message(
        id: 'message-1',
        requestId: 'request-1',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '산책했어',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 30),
        status: MessageStatus.sent,
      ),
    );

    expect(
      () => codec.decode({...valid, 'createdAtUtc': 'not-a-date'}),
      throwsFormatException,
    );
    expect(
      () => codec.decode({
        ...valid,
        'dayKey': {
          ...(valid['dayKey']! as Map<String, Object?>),
          'labelDate': '2026-02-31',
        },
      }),
      throwsFormatException,
    );
  });
}
