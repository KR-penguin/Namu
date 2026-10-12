import 'package:namu/features/diary/domain/diary_entry.dart';

/// Writing direction for localized labels drawn into a share image.
///
/// The currently supported app locales are left-to-right. Keeping direction
/// in the context-free render contract prevents the renderer from consulting
/// widget context when another writing direction is added later.
enum DiaryShareTextDirection { leftToRight, rightToLeft }

typedef DiarySharePageNumberFormatter = String Function(
  int pageNumber,
  int pageCount,
);

/// Immutable, already-formatted UI copy for one share operation.
///
/// The presentation layer owns locale selection, date formatting, and weather
/// wording. User-authored diary fields deliberately remain on [DiaryEntry].
final class DiaryShareLocalizedCopy {
  const DiaryShareLocalizedCopy({
    required this.title,
    required this.displayDate,
    required this.displayWeather,
    required this.captionMetadata,
    required this.formatPageNumber,
    required this.photoUnavailableMessage,
    this.textDirection = DiaryShareTextDirection.leftToRight,
  });

  final String title;
  final String displayDate;
  final String displayWeather;
  final String captionMetadata;
  final DiarySharePageNumberFormatter formatPageNumber;
  final String photoUnavailableMessage;
  final DiaryShareTextDirection textDirection;
}

/// One page exported by a [DiaryShareRenderer].
///
/// The path is adapter-owned and is validated by the application use case
/// before it is handed to the operating-system share sheet.
final class DiaryShareArtifact {
  const DiaryShareArtifact({
    required this.path,
    required this.mimeType,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.byteLength,
  });

  final String path;
  final String mimeType;
  final int pixelWidth;
  final int pixelHeight;
  final int byteLength;
}

final class DiaryShareRenderResult {
  DiaryShareRenderResult({
    required Iterable<DiaryShareArtifact> artifacts,
    required this.caption,
  }) : artifacts = List<DiaryShareArtifact>.unmodifiable(artifacts);

  final List<DiaryShareArtifact> artifacts;
  final String caption;
}

/// Produces share-ready PNG pages from a finalized diary entry.
///
/// Implementations may render one or more pages. [ShareDiary] remains the
/// authority for validating the renderer output before any external UI opens.
abstract interface class DiaryShareRenderer {
  Future<DiaryShareRenderResult> render(
    DiaryEntry entry,
    DiaryShareLocalizedCopy localizedCopy,
  );
}
