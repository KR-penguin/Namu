import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/local_data_export.dart';

typedef LocalDataSharePlusInvoker = Future<ShareResult> Function(
  ShareParams params,
);

/// Opens the platform share/save activity for one user-requested JSON export.
final class SharePlusLocalDataExportLauncher
    implements LocalDataExportLauncher {
  SharePlusLocalDataExportLauncher() : _invoke = SharePlus.instance.share;

  SharePlusLocalDataExportLauncher.testing(this._invoke);

  final LocalDataSharePlusInvoker _invoke;

  @override
  Future<LocalDataExportOutcome> launch(
    LocalDataExportArtifact artifact, {
    required String shareText,
  }) async {
    try {
      final result = await _invoke(
        ShareParams(
          files: [
            XFile(
              artifact.path,
              mimeType: artifact.mimeType,
              length: artifact.byteLength,
            ),
          ],
          text: shareText,
          downloadFallbackEnabled: false,
          mailToFallbackEnabled: false,
        ),
      );

      return switch (result.status) {
        ShareResultStatus.success => LocalDataExportOutcome.completed,
        ShareResultStatus.dismissed => LocalDataExportOutcome.dismissed,
        ShareResultStatus.unavailable => LocalDataExportOutcome.opened,
      };
    } on MissingPluginException {
      return LocalDataExportOutcome.unavailable;
    } on PlatformException {
      return LocalDataExportOutcome.unavailable;
    } on UnimplementedError {
      return LocalDataExportOutcome.unavailable;
    } on UnsupportedError {
      return LocalDataExportOutcome.unavailable;
    }
  }
}
