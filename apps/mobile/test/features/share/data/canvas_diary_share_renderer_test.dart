import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/media/data/app_owned_media_reader.dart';
import 'package:namu/features/media/data/in_memory_media_repository.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/share/data/canvas_diary_share_renderer.dart';
import 'package:namu/features/share/data/native_diary_share_output_store.dart';
import 'package:namu/features/share/domain/diary_share_output_store.dart';
import 'package:namu/features/share/domain/diary_share_renderer.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testDirectory;
  late Directory appRoot;
  late InMemoryMediaRepository mediaRepository;
  late CanvasDiaryShareRenderer renderer;

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp('namu-render-test-');
    appRoot = Directory(p.join(testDirectory.path, 'app-root'));
    await appRoot.create(recursive: true);
    final paths = _FakeAppStoragePaths(appRoot.path);
    mediaRepository = InMemoryMediaRepository();
    renderer = CanvasDiaryShareRenderer(
      mediaRepository: mediaRepository,
      mediaReader: AppOwnedMediaReader(paths),
      outputStore: NativeDiaryShareOutputStore(paths),
    );
  });

  tearDown(() async {
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('renders deterministic 1080x1350 PNG and a diary caption', () async {
    final entry = _entry(
      blocks: const [DiaryTextBlock(text: '천천히 걸으며 마음을 정리했다.')],
    );

    final first = await renderer.render(entry, _koreanCopy);
    final second = await renderer.render(entry, _koreanCopy);

    expect(first.artifacts, hasLength(1));
    expect(second.artifacts.single.path, first.artifacts.single.path);
    expect(first.caption, '천천히 걸으며 마음을 정리한 날\n\n2026. 10. 04 · 맑음 18°C · 평온함');
    final artifact = first.artifacts.single;
    expect(artifact.mimeType, 'image/png');
    expect(artifact.pixelWidth, 1080);
    expect(artifact.pixelHeight, 1350);
    final firstBytes = await File(artifact.path).readAsBytes();
    final secondBytes = await File(second.artifacts.single.path).readAsBytes();
    expect(firstBytes.take(8), <int>[137, 80, 78, 71, 13, 10, 26, 10]);
    expect(secondBytes, firstBytes);
    final image = await _decode(firstBytes);
    expect((image.width, image.height), (1080, 1350));
    image.dispose();
  });

  test(
    'localized copy drives caption and PNG labels while preserving user text',
    () async {
      final entry = _entry(
        blocks: const [
          DiaryTextBlock(text: '사용자가 직접 쓴 본문'),
          DiaryPhotoBlock(photoAssetId: 'missing-photo'),
        ],
      );
      const englishCopy = DiaryShareLocalizedCopy(
        title: "Today's diary",
        displayDate: 'October 4, 2026',
        displayWeather: 'Sunny 18°C',
        captionMetadata: 'October 4, 2026 · Sunny 18°C · 평온함',
        formatPageNumber: _englishPageNumber,
        photoUnavailableMessage: 'Photo unavailable',
      );
      const japaneseCopy = DiaryShareLocalizedCopy(
        title: '今日の記録',
        displayDate: '2026年10月4日',
        displayWeather: '晴れ 18°C',
        captionMetadata: '2026年10月4日・晴れ 18°C・평온함',
        formatPageNumber: _japanesePageNumber,
        photoUnavailableMessage: '写真を読み込めません',
      );

      final english = await renderer.render(entry, englishCopy);
      final englishBytes = await File(english.artifacts.single.path)
          .readAsBytes();
      final japanese = await renderer.render(entry, japaneseCopy);
      final japaneseBytes = await File(japanese.artifacts.single.path)
          .readAsBytes();

      expect(
        english.caption,
        '천천히 걸으며 마음을 정리한 날\n\n'
        'October 4, 2026 · Sunny 18°C · 평온함',
      );
      expect(
        japanese.caption,
        '천천히 걸으며 마음을 정리한 날\n\n'
        '2026年10月4日・晴れ 18°C・평온함',
      );
      expect(englishBytes, isNot(japaneseBytes));
    },
  );

  test('splits long text into multiple complete PNG pages', () async {
    final entry = _entry(
      blocks: [DiaryTextBlock(text: List.filled(420, '길었던 하루의 생각').join(' '))],
    );

    final result = await renderer.render(entry, _koreanCopy);

    expect(result.artifacts.length, greaterThan(2));
    expect(
      result.artifacts.map((artifact) => artifact.path).toSet(),
      hasLength(result.artifacts.length),
    );
    for (final artifact in result.artifacts) {
      final image = await _decode(await File(artifact.path).readAsBytes());
      expect((image.width, image.height), (1080, 1350));
      image.dispose();
    }
  });

  test(
    'renders app-owned photo pixels without copying source metadata',
    () async {
      final cleanPng = await _solidPng(const ui.Color(0xffff0000));
      final marker = Uint8List.fromList('EXIF_GPS_PRIVATE_MARKER'.codeUnits);
      final sourceBytes = Uint8List.fromList(<int>[...cleanPng, ...marker]);
      final photoFile = File(p.join(appRoot.path, 'media', 'photo.png'));
      await photoFile.parent.create(recursive: true);
      await photoFile.writeAsBytes(sourceBytes, flush: true);
      await _insertReadyAsset(
        repository: mediaRepository,
        assetId: 'photo-1',
        storageKey: 'media/photo.png',
        byteLength: sourceBytes.length,
      );

      final result = await renderer.render(
        _entry(
          blocks: const [
            DiaryTextBlock(text: '사진 전'),
            DiaryPhotoBlock(photoAssetId: 'photo-1'),
            DiaryTextBlock(text: '사진 후'),
          ],
        ),
        _koreanCopy,
      );

      final exported = await File(result.artifacts.single.path).readAsBytes();
      expect(_containsBytes(exported, marker), isFalse);
      expect(exported.length, greaterThan(1000));
    },
  );

  test(
    'missing and corrupt photos become placeholders instead of failures',
    () async {
      final corruptFile = File(p.join(appRoot.path, 'media', 'corrupt.png'));
      await corruptFile.parent.create(recursive: true);
      await corruptFile.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
      await _insertReadyAsset(
        repository: mediaRepository,
        assetId: 'corrupt-photo',
        storageKey: 'media/corrupt.png',
        byteLength: 4,
      );

      final result = await renderer.render(
        _entry(
          blocks: const [
            DiaryPhotoBlock(photoAssetId: 'missing-photo'),
            DiaryPhotoBlock(photoAssetId: 'corrupt-photo'),
          ],
        ),
        _koreanCopy,
      );

      expect(result.artifacts, isNotEmpty);
      for (final artifact in result.artifacts) {
        expect(await File(artifact.path).length(), greaterThan(0));
      }
    },
  );

  test('light and dark themes produce distinct page pixels', () async {
    final light = await renderer.render(
      _entry(theme: DiaryTheme.light),
      _koreanCopy,
    );
    final dark = await renderer.render(
      _entry(
        id: 'diary-dark',
        theme: DiaryTheme.dark,
        updatedAtUtc: DateTime.utc(2026, 10, 4, 17),
      ),
      _koreanCopy,
    );

    final lightBytes = await File(light.artifacts.single.path).readAsBytes();
    final darkBytes = await File(dark.artifacts.single.path).readAsBytes();
    expect(darkBytes, isNot(lightBytes));
  });

  test('encoded export names cannot traverse outside the app root', () async {
    final result = await renderer.render(
      _entry(id: '../../outside/diary'),
      _koreanCopy,
    );

    final normalizedRoot = p.normalize(appRoot.absolute.path);
    final normalizedOutput = p.normalize(result.artifacts.single.path);
    expect(p.isWithin(normalizedRoot, normalizedOutput), isTrue);
    expect(
      await File(p.join(testDirectory.path, 'outside.png')).exists(),
      isFalse,
    );
    final staging = Directory(p.join(appRoot.path, '.share-staging'));
    if (await staging.exists()) {
      expect(await staging.list().toList(), isEmpty);
    }
  });

  test('output store rejects relative storage roots', () async {
    final store = NativeDiaryShareOutputStore(
      const _FakeAppStoragePaths('relative/root'),
    );

    await expectLater(
      store.writePng(
        entryId: 'entry-1',
        version: 1,
        updatedAtUtc: DateTime.utc(2026, 10, 4),
        pageNumber: 1,
        bytes: Uint8List.fromList(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
      ),
      throwsA(
        isA<DiaryShareOutputException>().having(
          (error) => error.reason,
          'reason',
          DiaryShareOutputFailure.invalidRoot,
        ),
      ),
    );
  });

  test('output store refuses a final-path symlink outside the app root', () async {
    final outside = File(p.join(testDirectory.path, 'outside.png'));
    await outside.writeAsBytes(<int>[4, 5, 6], flush: true);
    final outputDirectory = Directory(p.join(appRoot.path, 'exports', 'share'));
    await outputDirectory.create(recursive: true);
    final encodedId = base64Url
        .encode(utf8.encode('entry-1'))
        .replaceAll('=', '');
    final target = Link(
      p.join(
        outputDirectory.path,
        '$encodedId-v1-r${DateTime.utc(2026, 10, 4).microsecondsSinceEpoch}-p001.png',
      ),
    );
    await target.create(outside.path);
    final store = NativeDiaryShareOutputStore(
      _FakeAppStoragePaths(appRoot.path),
    );

    await expectLater(
      store.writePng(
        entryId: 'entry-1',
        version: 1,
        updatedAtUtc: DateTime.utc(2026, 10, 4),
        pageNumber: 1,
        bytes: Uint8List.fromList(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
      ),
      throwsA(
        isA<DiaryShareOutputException>().having(
          (error) => error.reason,
          'reason',
          DiaryShareOutputFailure.invalidRoot,
        ),
      ),
    );
    expect(await outside.readAsBytes(), <int>[4, 5, 6]);
  });
}

const _koreanCopy = DiaryShareLocalizedCopy(
  title: '오늘의 기록',
  displayDate: '2026. 10. 04',
  displayWeather: '맑음 18°C',
  captionMetadata: '2026. 10. 04 · 맑음 18°C · 평온함',
  formatPageNumber: _koreanPageNumber,
  photoUnavailableMessage: '사진을 불러올 수 없어요',
);

String _koreanPageNumber(int pageNumber, int pageCount) =>
    '$pageNumber / $pageCount';

String _englishPageNumber(int pageNumber, int pageCount) =>
    'Page $pageNumber of $pageCount';

String _japanesePageNumber(int pageNumber, int pageCount) =>
    '$pageNumber / $pageCount';

DiaryEntry _entry({
  String id = 'diary-1',
  DiaryTheme theme = DiaryTheme.light,
  List<DiaryBlock> blocks = const [DiaryTextBlock(text: '오후에 동네를 천천히 걸었다.')],
  DateTime? updatedAtUtc,
}) {
  return DiaryEntry(
    id: id,
    dayKey: _dayKey(),
    version: 1,
    status: DiaryEntryStatus.finalized,
    weather: WeatherSnapshot.manual(condition: '맑음', temperatureCelsius: 18),
    mood: '평온함',
    oneLineSummary: '천천히 걸으며 마음을 정리한 날',
    theme: theme,
    blocks: blocks,
    memoryCandidates: const [],
    sourceMessageIds: const ['message-1'],
    generationId: 'generation-1',
    generatedAtUtc: DateTime.utc(2026, 10, 4, 15),
    updatedAtUtc: updatedAtUtc ?? DateTime.utc(2026, 10, 4, 16),
  );
}

DiaryDayKey _dayKey() {
  return DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 8),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );
}

Future<void> _insertReadyAsset({
  required InMemoryMediaRepository repository,
  required String assetId,
  required String storageKey,
  required int byteLength,
}) async {
  final staging = MediaAsset(
    id: assetId,
    dayKey: _dayKey(),
    storageKey: storageKey,
    mimeType: MediaMimeType.png,
    byteLength: byteLength,
    createdAtUtc: DateTime.utc(2026, 10, 4, 14),
    lifecycle: MediaLifecycle.staging,
  );
  await repository.insert(staging);
  await repository.update(staging.withLifecycle(MediaLifecycle.ready));
}

Future<Uint8List> _solidPng(ui.Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 24, 24),
    ui.Paint()..color = color,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(24, 24);
  picture.dispose();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

bool _containsBytes(Uint8List haystack, Uint8List needle) {
  if (needle.isEmpty) return true;
  for (var index = 0; index <= haystack.length - needle.length; index += 1) {
    var matches = true;
    for (var offset = 0; offset < needle.length; offset += 1) {
      if (haystack[index + offset] != needle[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}

final class _FakeAppStoragePaths implements AppStoragePaths {
  const _FakeAppStoragePaths(this.root);

  final String root;

  @override
  Future<String> appStorageRoot() async => root;
}
