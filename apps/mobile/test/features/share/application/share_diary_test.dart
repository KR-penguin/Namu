import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/share/application/share_diary.dart';
import 'package:namu/features/share/domain/diary_share_renderer.dart';
import 'package:namu/features/share/domain/share_sheet_launcher.dart';

void main() {
  test(
    'renders a finalized diary and opens the sheet with validated output',
    () async {
      final entry = _entry(DiaryEntryStatus.finalized);
      final renderResult = _renderResult();
      final renderer = _FakeRenderer(result: renderResult);
      final launcher = _FakeLauncher(result: ShareSheetOutcome.opened);
      final shareDiary = ShareDiary(renderer: renderer, launcher: launcher);

      final outcome = await shareDiary(entry, localizedCopy: _localizedCopy);

      expect(outcome, ShareSheetOutcome.opened);
      expect(renderer.entries, [same(entry)]);
      expect(renderer.localizedCopies, [same(_localizedCopy)]);
      expect(launcher.requests, hasLength(1));
      expect(launcher.requests.single.artifacts, renderResult.artifacts);
      expect(launcher.requests.single.caption, renderResult.caption);
    },
  );

  test('rejects a draft before rendering or launching', () async {
    final renderer = _FakeRenderer(result: _renderResult());
    final launcher = _FakeLauncher(result: ShareSheetOutcome.completed);
    final shareDiary = ShareDiary(renderer: renderer, launcher: launcher);

    await expectLater(
      shareDiary(_entry(DiaryEntryStatus.draft), localizedCopy: _localizedCopy),
      throwsA(
        isA<ShareDiaryValidationException>().having(
          (error) => error.reason,
          'reason',
          ShareDiaryValidationReason.notFinalized,
        ),
      ),
    );

    expect(renderer.entries, isEmpty);
    expect(launcher.requests, isEmpty);
  });

  test('rejects empty artifacts and blank or zero-byte files', () async {
    final invalidResults = <DiaryShareRenderResult>[
      DiaryShareRenderResult(artifacts: const [], caption: '하루 기록'),
      _renderResult(path: '   '),
      _renderResult(byteLength: 0),
    ];

    for (final result in invalidResults) {
      final launcher = _FakeLauncher(result: ShareSheetOutcome.completed);
      final shareDiary = ShareDiary(
        renderer: _FakeRenderer(result: result),
        launcher: launcher,
      );

      await expectLater(
        shareDiary(
          _entry(DiaryEntryStatus.finalized),
          localizedCopy: _localizedCopy,
        ),
        throwsA(isA<ShareDiaryValidationException>()),
      );
      expect(launcher.requests, isEmpty);
    }
  });

  test('rejects non-PNG metadata, extension, and export dimensions', () async {
    final invalidResults = <DiaryShareRenderResult>[
      _renderResult(mimeType: 'image/jpeg'),
      _renderResult(path: '/exports/page-1.jpg'),
      _renderResult(width: 1079),
      _renderResult(height: 1349),
    ];

    for (final result in invalidResults) {
      final launcher = _FakeLauncher(result: ShareSheetOutcome.completed);
      final shareDiary = ShareDiary(
        renderer: _FakeRenderer(result: result),
        launcher: launcher,
      );

      await expectLater(
        shareDiary(
          _entry(DiaryEntryStatus.finalized),
          localizedCopy: _localizedCopy,
        ),
        throwsA(isA<ShareDiaryValidationException>()),
      );
      expect(launcher.requests, isEmpty);
    }
  });

  test('rejects duplicate normalized export paths', () async {
    final first = _artifact(path: '/exports/page-1.png');
    final duplicate = _artifact(path: '/exports/./page-1.png');
    final launcher = _FakeLauncher(result: ShareSheetOutcome.completed);
    final shareDiary = ShareDiary(
      renderer: _FakeRenderer(
        result: DiaryShareRenderResult(
          artifacts: [first, duplicate],
          caption: '하루 기록',
        ),
      ),
      launcher: launcher,
    );

    await expectLater(
      shareDiary(
        _entry(DiaryEntryStatus.finalized),
        localizedCopy: _localizedCopy,
      ),
      throwsA(
        isA<ShareDiaryValidationException>().having(
          (error) => error.reason,
          'reason',
          ShareDiaryValidationReason.duplicatePath,
        ),
      ),
    );
    expect(launcher.requests, isEmpty);
  });

  test('rejects a blank caption', () async {
    final launcher = _FakeLauncher(result: ShareSheetOutcome.completed);
    final shareDiary = ShareDiary(
      renderer: _FakeRenderer(result: _renderResult(caption: '   ')),
      launcher: launcher,
    );

    await expectLater(
      shareDiary(
        _entry(DiaryEntryStatus.finalized),
        localizedCopy: _localizedCopy,
      ),
      throwsA(
        isA<ShareDiaryValidationException>().having(
          (error) => error.reason,
          'reason',
          ShareDiaryValidationReason.emptyCaption,
        ),
      ),
    );
    expect(launcher.requests, isEmpty);
  });

  test('forwards only share-sheet outcomes without claiming a post', () async {
    for (final expected in ShareSheetOutcome.values) {
      final shareDiary = ShareDiary(
        renderer: _FakeRenderer(result: _renderResult()),
        launcher: _FakeLauncher(result: expected),
      );

      expect(
        await shareDiary(
          _entry(DiaryEntryStatus.finalized),
          localizedCopy: _localizedCopy,
        ),
        expected,
      );
    }
  });
}

const _localizedCopy = DiaryShareLocalizedCopy(
  title: 'Today\'s diary',
  displayDate: 'October 4, 2026',
  displayWeather: 'Sunny 18°C',
  captionMetadata: 'October 4, 2026 · Sunny 18°C · Calm',
  formatPageNumber: _pageNumber,
  photoUnavailableMessage: 'Photo unavailable',
);

String _pageNumber(int pageNumber, int pageCount) => '$pageNumber / $pageCount';

DiaryShareRenderResult _renderResult({
  String path = '/exports/page-1.png',
  String mimeType = 'image/png',
  int width = 1080,
  int height = 1350,
  int byteLength = 1024,
  String caption = '천천히 걸으며 마음을 정리한 날',
}) {
  return DiaryShareRenderResult(
    artifacts: [
      _artifact(
        path: path,
        mimeType: mimeType,
        width: width,
        height: height,
        byteLength: byteLength,
      ),
    ],
    caption: caption,
  );
}

DiaryShareArtifact _artifact({
  required String path,
  String mimeType = 'image/png',
  int width = 1080,
  int height = 1350,
  int byteLength = 1024,
}) {
  return DiaryShareArtifact(
    path: path,
    mimeType: mimeType,
    pixelWidth: width,
    pixelHeight: height,
    byteLength: byteLength,
  );
}

DiaryEntry _entry(DiaryEntryStatus status) {
  return DiaryEntry(
    id: 'diary-1',
    dayKey: DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    ),
    version: 1,
    status: status,
    weather: const WeatherSnapshot.noWeather(),
    mood: '평온함',
    oneLineSummary: '천천히 걸으며 마음을 정리한 날',
    theme: DiaryTheme.light,
    blocks: const [DiaryTextBlock(text: '오후에 동네를 천천히 걸었다.')],
    memoryCandidates: const [],
    sourceMessageIds: const ['message-1'],
    generationId: 'generation-1',
    generatedAtUtc: DateTime.utc(2026, 10, 4, 15),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 16),
  );
}

final class _FakeRenderer implements DiaryShareRenderer {
  _FakeRenderer({required this.result});

  final DiaryShareRenderResult result;
  final List<DiaryEntry> entries = [];
  final List<DiaryShareLocalizedCopy> localizedCopies = [];

  @override
  Future<DiaryShareRenderResult> render(
    DiaryEntry entry,
    DiaryShareLocalizedCopy localizedCopy,
  ) async {
    entries.add(entry);
    localizedCopies.add(localizedCopy);
    return result;
  }
}

final class _FakeLauncher implements ShareSheetLauncher {
  _FakeLauncher({required this.result});

  final ShareSheetOutcome result;
  final List<ShareSheetRequest> requests = [];

  @override
  Future<ShareSheetOutcome> launch(ShareSheetRequest request) async {
    requests.add(request);
    return result;
  }
}
