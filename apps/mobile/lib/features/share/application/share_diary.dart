import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/share/domain/diary_share_renderer.dart';
import 'package:namu/features/share/domain/share_sheet_launcher.dart';
import 'package:path/path.dart' as path;

enum ShareDiaryValidationReason {
  notFinalized,
  emptyArtifacts,
  emptyFile,
  nonPng,
  invalidDimensions,
  duplicatePath,
  emptyCaption,
}

final class ShareDiaryValidationException implements Exception {
  const ShareDiaryValidationException(this.reason);

  final ShareDiaryValidationReason reason;

  @override
  String toString() => 'ShareDiaryValidationException($reason)';
}

/// Renders a finalized diary and opens a user-controlled OS share sheet.
///
/// Returning from this use case never proves that an external service posted
/// the diary. Callers must preserve the meaning of [ShareSheetOutcome].
final class ShareDiary {
  const ShareDiary({required this.renderer, required this.launcher});

  static const int exportWidth = 1080;
  static const int exportHeight = 1350;
  static const String pngMimeType = 'image/png';

  final DiaryShareRenderer renderer;
  final ShareSheetLauncher launcher;

  Future<ShareSheetOutcome> call(
    DiaryEntry entry, {
    required DiaryShareLocalizedCopy localizedCopy,
  }) async {
    if (entry.status != DiaryEntryStatus.finalized) {
      throw const ShareDiaryValidationException(
        ShareDiaryValidationReason.notFinalized,
      );
    }

    final result = await renderer.render(entry, localizedCopy);
    _validate(result);

    return launcher.launch(
      ShareSheetRequest(artifacts: result.artifacts, caption: result.caption),
    );
  }

  static void _validate(DiaryShareRenderResult result) {
    if (result.caption.trim().isEmpty) {
      throw const ShareDiaryValidationException(
        ShareDiaryValidationReason.emptyCaption,
      );
    }
    if (result.artifacts.isEmpty) {
      throw const ShareDiaryValidationException(
        ShareDiaryValidationReason.emptyArtifacts,
      );
    }

    final normalizedPaths = <String>{};
    for (final artifact in result.artifacts) {
      final artifactPath = artifact.path.trim();
      if (artifactPath.isEmpty || artifact.byteLength <= 0) {
        throw const ShareDiaryValidationException(
          ShareDiaryValidationReason.emptyFile,
        );
      }
      if (artifact.mimeType.trim().toLowerCase() != pngMimeType ||
          path.extension(artifactPath).toLowerCase() != '.png') {
        throw const ShareDiaryValidationException(
          ShareDiaryValidationReason.nonPng,
        );
      }
      if (artifact.pixelWidth != exportWidth ||
          artifact.pixelHeight != exportHeight) {
        throw const ShareDiaryValidationException(
          ShareDiaryValidationReason.invalidDimensions,
        );
      }
      if (!normalizedPaths.add(path.normalize(artifactPath))) {
        throw const ShareDiaryValidationException(
          ShareDiaryValidationReason.duplicatePath,
        );
      }
    }
  }
}
