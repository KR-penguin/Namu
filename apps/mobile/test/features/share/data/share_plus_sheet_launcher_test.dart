import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/share/data/share_plus_sheet_launcher.dart';
import 'package:namu/features/share/domain/diary_share_renderer.dart';
import 'package:namu/features/share/domain/share_sheet_launcher.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test('passes ordered PNG files and caption to the OS share sheet', () async {
    late ShareParams captured;
    final launcher = SharePlusSheetLauncher.testing((params) async {
      captured = params;
      return const ShareResult('target-app', ShareResultStatus.success);
    });
    final request = ShareSheetRequest(
      artifacts: [
        _artifact('/exports/page-1.png'),
        _artifact('/exports/page-2.png'),
      ],
      caption: '오늘의 기록',
    );

    final outcome = await launcher.launch(request);

    expect(outcome, ShareSheetOutcome.completed);
    expect(captured.text, '오늘의 기록');
    expect(captured.files?.map((file) => file.path), [
      '/exports/page-1.png',
      '/exports/page-2.png',
    ]);
    expect(captured.files?.map((file) => file.mimeType), [
      'image/png',
      'image/png',
    ]);
    expect(captured.downloadFallbackEnabled, isFalse);
    expect(captured.mailToFallbackEnabled, isFalse);
  });

  test('maps plugin success to completed, never posted', () async {
    final launcher = SharePlusSheetLauncher.testing(
      (_) async => const ShareResult('activity', ShareResultStatus.success),
    );

    expect(await launcher.launch(_request()), ShareSheetOutcome.completed);
  });

  test('maps dismissal without claiming external success', () async {
    final launcher = SharePlusSheetLauncher.testing(
      (_) async => const ShareResult('', ShareResultStatus.dismissed),
    );

    expect(await launcher.launch(_request()), ShareSheetOutcome.dismissed);
  });

  test('maps an indeterminate plugin result to opened only', () async {
    final launcher = SharePlusSheetLauncher.testing(
      (_) async => ShareResult.unavailable,
    );

    expect(await launcher.launch(_request()), ShareSheetOutcome.opened);
  });

  test('maps unavailable platform channels to unavailable', () async {
    for (final error in <Object>[
      MissingPluginException('missing'),
      PlatformException(code: 'unavailable', message: '/private/path'),
      UnimplementedError('not supported'),
    ]) {
      final launcher = SharePlusSheetLauncher.testing((_) async => throw error);

      expect(await launcher.launch(_request()), ShareSheetOutcome.unavailable);
    }
  });
}

ShareSheetRequest _request() {
  return ShareSheetRequest(
    artifacts: [_artifact('/exports/page-1.png')],
    caption: '오늘의 기록',
  );
}

DiaryShareArtifact _artifact(String path) {
  return DiaryShareArtifact(
    path: path,
    mimeType: 'image/png',
    pixelWidth: 1080,
    pixelHeight: 1350,
    byteLength: 1024,
  );
}
