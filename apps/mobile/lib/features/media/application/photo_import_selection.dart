/// Picker output kept opaque so platform file types do not enter application code.
final class PhotoImportSelection {
  const PhotoImportSelection({
    required this.token,
    required this.mimeType,
    required this.byteLength,
  });

  final String token;
  final String mimeType;
  final int byteLength;
}
