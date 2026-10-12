import 'package:namu/features/share/domain/diary_share_renderer.dart';

/// Observable outcomes from asking the operating system to share content.
///
/// None of these values means that Instagram, or any other destination,
/// published a post. In particular, [completed] only reflects the platform's
/// share activity result.
enum ShareSheetOutcome { opened, completed, dismissed, unavailable }

final class ShareSheetRequest {
  ShareSheetRequest({
    required Iterable<DiaryShareArtifact> artifacts,
    required this.caption,
  }) : artifacts = List<DiaryShareArtifact>.unmodifiable(artifacts);

  final List<DiaryShareArtifact> artifacts;
  final String caption;
}

abstract interface class ShareSheetLauncher {
  Future<ShareSheetOutcome> launch(ShareSheetRequest request);
}
