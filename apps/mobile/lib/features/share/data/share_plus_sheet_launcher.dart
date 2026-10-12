import 'package:flutter/services.dart';
import 'package:namu/features/share/domain/share_sheet_launcher.dart';
import 'package:share_plus/share_plus.dart';

typedef SharePlusInvoker = Future<ShareResult> Function(ShareParams params);

/// Thin adapter over the platform share sheet exposed by `share_plus`.
final class SharePlusSheetLauncher implements ShareSheetLauncher {
  SharePlusSheetLauncher() : _invoke = SharePlus.instance.share;

  SharePlusSheetLauncher.testing(this._invoke);

  final SharePlusInvoker _invoke;

  @override
  Future<ShareSheetOutcome> launch(ShareSheetRequest request) async {
    try {
      final result = await _invoke(
        ShareParams(
          files: request.artifacts
              .map(
                (artifact) => XFile(
                  artifact.path,
                  mimeType: artifact.mimeType,
                  length: artifact.byteLength,
                ),
              )
              .toList(growable: false),
          text: request.caption,
          downloadFallbackEnabled: false,
          mailToFallbackEnabled: false,
        ),
      );

      return switch (result.status) {
        ShareResultStatus.success => ShareSheetOutcome.completed,
        ShareResultStatus.dismissed => ShareSheetOutcome.dismissed,
        // share_plus cannot determine what happened after presenting the
        // native activity on this platform. Treat it only as opened.
        ShareResultStatus.unavailable => ShareSheetOutcome.opened,
      };
    } on MissingPluginException {
      return ShareSheetOutcome.unavailable;
    } on PlatformException {
      return ShareSheetOutcome.unavailable;
    } on UnimplementedError {
      return ShareSheetOutcome.unavailable;
    } on UnsupportedError {
      return ShareSheetOutcome.unavailable;
    }
  }
}
