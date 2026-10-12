import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/settings/data/share_plus_local_data_export_launcher.dart';
import 'package:namu/features/settings/domain/local_data_export.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  final artifact = LocalDataExportArtifact(
    path: '/private/exports/namu-local-data.json',
    mimeType: 'application/json',
    byteLength: 42,
  );

  test('passes only the JSON artifact to the platform share sheet', () async {
    late ShareParams captured;
    final launcher = SharePlusLocalDataExportLauncher.testing((params) async {
      captured = params;
      return const ShareResult('', ShareResultStatus.success);
    });

    expect(
      await launcher.launch(artifact, shareText: 'Localized export label'),
      LocalDataExportOutcome.completed,
    );
    expect(captured.files, hasLength(1));
    expect(captured.files!.single.path, artifact.path);
    expect(captured.files!.single.mimeType, 'application/json');
    expect(captured.text, 'Localized export label');
    expect(captured.downloadFallbackEnabled, isFalse);
    expect(captured.mailToFallbackEnabled, isFalse);
  });

  test(
    'maps dismissal and indeterminate platform results without claiming save',
    () async {
      for (final pair in <(ShareResultStatus, LocalDataExportOutcome)>[
        (ShareResultStatus.dismissed, LocalDataExportOutcome.dismissed),
        (ShareResultStatus.unavailable, LocalDataExportOutcome.opened),
      ]) {
        final launcher = SharePlusLocalDataExportLauncher.testing(
          (_) async => ShareResult('', pair.$1),
        );
        expect(
          await launcher.launch(artifact, shareText: 'Localized export label'),
          pair.$2,
        );
      }
    },
  );

  test(
    'maps plugin failures to unavailable without exposing details',
    () async {
      for (final Object error in <Object>[
        MissingPluginException(),
        PlatformException(code: 'private-platform-detail'),
        UnsupportedError('private-platform-detail'),
      ]) {
        final launcher = SharePlusLocalDataExportLauncher.testing(
          (_) async => throw error,
        );
        expect(
          await launcher.launch(artifact, shareText: 'Localized export label'),
          LocalDataExportOutcome.unavailable,
        );
      }
    },
  );
}
