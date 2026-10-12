import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_bytes_reader.dart';
import 'package:namu/features/media/domain/media_repository.dart';
import 'package:namu/features/share/domain/diary_share_output_store.dart';
import 'package:namu/features/share/domain/diary_share_renderer.dart';

enum DiaryShareRenderFailure { notFinalized, tooManyPages, encodingFailed }

final class DiaryShareRenderException implements Exception {
  const DiaryShareRenderException(this.reason);

  final DiaryShareRenderFailure reason;

  @override
  String toString() => 'Diary share rendering failed (${reason.name})';
}

/// Draws a diary snapshot into fixed Instagram-feed-friendly 4:5 PNG pages.
///
/// Original media bytes are decoded into pixels and the complete page is
/// encoded again. This deliberately prevents EXIF and other source metadata
/// from crossing the sharing boundary.
final class CanvasDiaryShareRenderer implements DiaryShareRenderer {
  const CanvasDiaryShareRenderer({
    required this.mediaRepository,
    required this.mediaReader,
    required this.outputStore,
  });

  static const int pixelWidth = 1080;
  static const int pixelHeight = 1350;
  static const int _maximumPages = 100;
  static const double _horizontalInset = 84;
  static const double _contentBottom = 1214;
  static const double _firstPageContentTop = 390;
  static const double _followingPageContentTop = 206;
  static const double _itemGap = 30;
  static const double _maximumPhotoHeight = 610;
  static const double _minimumPhotoHeight = 360;

  final MediaRepository mediaRepository;
  final MediaBytesReader mediaReader;
  final DiaryShareOutputStore outputStore;

  @override
  Future<DiaryShareRenderResult> render(
    DiaryEntry entry,
    DiaryShareLocalizedCopy localizedCopy,
  ) async {
    if (entry.status != DiaryEntryStatus.finalized) {
      throw const DiaryShareRenderException(
        DiaryShareRenderFailure.notFinalized,
      );
    }

    final photos = await _loadPhotos(entry);
    try {
      final palette = _Palette.forTheme(entry.theme);
      final textDirection = _uiTextDirection(localizedCopy.textDirection);
      final pages = _paginate(entry.blocks, photos, palette, textDirection);
      final artifacts = <DiaryShareArtifact>[];
      for (var index = 0; index < pages.length; index += 1) {
        final png = await _drawPage(
          entry: entry,
          page: pages[index],
          pageNumber: index + 1,
          pageCount: pages.length,
          palette: palette,
          localizedCopy: localizedCopy,
          textDirection: textDirection,
        );
        final outputPath = await outputStore.writePng(
          entryId: entry.id,
          version: entry.version,
          updatedAtUtc: entry.updatedAtUtc,
          pageNumber: index + 1,
          bytes: png,
        );
        artifacts.add(
          DiaryShareArtifact(
            path: outputPath,
            mimeType: 'image/png',
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            byteLength: png.length,
          ),
        );
      }

      return DiaryShareRenderResult(
        artifacts: artifacts,
        caption: _captionFor(entry, localizedCopy),
      );
    } finally {
      for (final photo in photos.values) {
        photo.image?.dispose();
      }
    }
  }

  Future<Map<String, _PhotoResource>> _loadPhotos(DiaryEntry entry) async {
    final photos = <String, _PhotoResource>{};
    for (final block in entry.blocks) {
      if (block case DiaryPhotoBlock(:final photoAssetId)) {
        if (!photos.containsKey(photoAssetId)) {
          photos[photoAssetId] = await _loadPhoto(
            photoAssetId,
            expectedDayKey: entry.dayKey,
          );
        }
      }
    }
    return photos;
  }

  Future<_PhotoResource> _loadPhoto(
    String assetId, {
    required DiaryDayKey expectedDayKey,
  }) async {
    try {
      final asset = await mediaRepository.findById(assetId);
      if (asset == null ||
          asset.lifecycle != MediaLifecycle.ready ||
          asset.dayKey != expectedDayKey) {
        return const _PhotoResource.missing();
      }
      final bytes = await mediaReader.read(asset);
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      ui.ImageDescriptor? descriptor;
      ui.Codec? codec;
      try {
        descriptor = await ui.ImageDescriptor.encoded(buffer);
        if (descriptor.width <= 0 || descriptor.height <= 0) {
          return const _PhotoResource.missing();
        }
        final scale = math.min(
          1.0,
          math.min(
            (pixelWidth - 2 * _horizontalInset) / descriptor.width,
            _maximumPhotoHeight / descriptor.height,
          ),
        );
        final targetWidth = math.max(1, (descriptor.width * scale).round());
        final targetHeight = math.max(1, (descriptor.height * scale).round());
        codec = await descriptor.instantiateCodec(
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
        final frame = await codec.getNextFrame();
        return _PhotoResource.image(frame.image);
      } finally {
        codec?.dispose();
        descriptor?.dispose();
        buffer.dispose();
      }
    } catch (_) {
      // A diary remains shareable when an old local photo was deleted,
      // corrupted, or cannot be decoded on this platform.
      return const _PhotoResource.missing();
    }
  }

  List<_PageLayout> _paginate(
    List<DiaryBlock> blocks,
    Map<String, _PhotoResource> photos,
    _Palette palette,
    ui.TextDirection textDirection,
  ) {
    final pages = <_PageLayout>[_PageLayout(index: 0)];
    var page = pages.single;
    var cursorY = _firstPageContentTop;
    final contentWidth = pixelWidth - 2 * _horizontalInset;

    void nextPage() {
      if (pages.length >= _maximumPages) {
        throw const DiaryShareRenderException(
          DiaryShareRenderFailure.tooManyPages,
        );
      }
      page = _PageLayout(index: pages.length);
      pages.add(page);
      cursorY = _followingPageContentTop;
    }

    for (final block in blocks) {
      switch (block) {
        case DiaryTextBlock(:final text):
          final units = _textClusters(text.trim());
          var start = 0;
          while (start < units.length) {
            final availableHeight = _contentBottom - cursorY;
            if (availableHeight < _minimumTextLineHeight) {
              nextPage();
              continue;
            }
            final fit = _fitText(
              units: units,
              start: start,
              maxWidth: contentWidth,
              maxHeight: availableHeight,
              color: palette.foreground,
              textDirection: textDirection,
            );
            if (fit.end <= start) {
              nextPage();
              continue;
            }
            page.items.add(
              _TextPageItem(
                text: units.sublist(start, fit.end).join().trim(),
                top: cursorY,
                height: fit.height,
              ),
            );
            cursorY += fit.height + _itemGap;
            start = fit.end;
            while (start < units.length && units[start].trim().isEmpty) {
              start += 1;
            }
            if (start < units.length) nextPage();
          }
        case DiaryPhotoBlock(:final photoAssetId):
          final photo = photos[photoAssetId] ?? const _PhotoResource.missing();
          final photoHeight = _photoHeight(photo, contentWidth);
          if (_contentBottom - cursorY < photoHeight) {
            nextPage();
          }
          page.items.add(
            _PhotoPageItem(photo: photo, top: cursorY, height: photoHeight),
          );
          cursorY += photoHeight + _itemGap;
      }
    }
    return pages;
  }

  Future<Uint8List> _drawPage({
    required DiaryEntry entry,
    required _PageLayout page,
    required int pageNumber,
    required int pageCount,
    required _Palette palette,
    required DiaryShareLocalizedCopy localizedCopy,
    required ui.TextDirection textDirection,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      const ui.Rect.fromLTWH(0, 0, 1080, 1350),
    );
    canvas.drawColor(palette.background, ui.BlendMode.src);
    _drawHeader(
      canvas: canvas,
      entry: entry,
      isFirstPage: page.index == 0,
      palette: palette,
      localizedCopy: localizedCopy,
      textDirection: textDirection,
    );

    canvas.save();
    canvas.clipRect(
      const ui.Rect.fromLTRB(
        _horizontalInset,
        _followingPageContentTop,
        pixelWidth - _horizontalInset,
        _contentBottom,
      ),
    );
    for (final item in page.items) {
      switch (item) {
        case _TextPageItem(:final text, :final top):
          final paragraph = _paragraph(
            text,
            maxWidth: pixelWidth - 2 * _horizontalInset,
            fontSize: 39,
            lineHeight: 1.52,
            color: palette.foreground,
            textDirection: textDirection,
          );
          canvas.drawParagraph(paragraph, ui.Offset(_horizontalInset, top));
          paragraph.dispose();
        case _PhotoPageItem(:final photo, :final top, :final height):
          _drawPhoto(
            canvas: canvas,
            photo: photo,
            bounds: ui.Rect.fromLTWH(
              _horizontalInset,
              top,
              pixelWidth - 2 * _horizontalInset,
              height,
            ),
            palette: palette,
            localizedCopy: localizedCopy,
            textDirection: textDirection,
          );
      }
    }
    canvas.restore();

    _drawText(
      canvas,
      localizedCopy.formatPageNumber(pageNumber, pageCount),
      x: _horizontalInset,
      y: 1270,
      width: pixelWidth - 2 * _horizontalInset,
      fontSize: 22,
      color: palette.muted,
      textAlign: ui.TextAlign.right,
      textDirection: textDirection,
    );

    final picture = recorder.endRecording();
    ui.Image? image;
    try {
      image = await picture.toImage(pixelWidth, pixelHeight);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const DiaryShareRenderException(
          DiaryShareRenderFailure.encodingFailed,
        );
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image?.dispose();
      picture.dispose();
    }
  }

  void _drawHeader({
    required ui.Canvas canvas,
    required DiaryEntry entry,
    required bool isFirstPage,
    required _Palette palette,
    required DiaryShareLocalizedCopy localizedCopy,
    required ui.TextDirection textDirection,
  }) {
    final date = localizedCopy.displayDate.trim();
    if (!isFirstPage) {
      _drawText(
        canvas,
        date,
        x: _horizontalInset,
        y: 72,
        width: 560,
        fontSize: 31,
        color: palette.foreground,
        fontWeight: ui.FontWeight.w600,
        textDirection: textDirection,
      );
      _drawText(
        canvas,
        '${localizedCopy.displayWeather.trim()}  ·  ${entry.mood.trim()}',
        x: _horizontalInset,
        y: 128,
        width: pixelWidth - 2 * _horizontalInset,
        fontSize: 24,
        color: palette.muted,
        maxLines: 1,
        textDirection: textDirection,
      );
      canvas.drawRect(
        const ui.Rect.fromLTWH(
          _horizontalInset,
          184,
          pixelWidth - 2 * _horizontalInset,
          2,
        ),
        ui.Paint()..color = palette.rule,
      );
      return;
    }

    _drawText(
      canvas,
      localizedCopy.title.trim(),
      x: _horizontalInset,
      y: 64,
      width: 360,
      fontSize: 23,
      color: palette.accent,
      fontWeight: ui.FontWeight.w700,
      letterSpacing: 1.5,
      textDirection: textDirection,
    );
    _drawText(
      canvas,
      date,
      x: _horizontalInset,
      y: 113,
      width: 600,
      fontSize: 45,
      color: palette.foreground,
      fontWeight: ui.FontWeight.w700,
      textDirection: textDirection,
    );
    _drawText(
      canvas,
      '${localizedCopy.displayWeather.trim()}  ·  ${entry.mood.trim()}',
      x: _horizontalInset,
      y: 184,
      width: pixelWidth - 2 * _horizontalInset,
      fontSize: 25,
      color: palette.muted,
      maxLines: 1,
      textDirection: textDirection,
    );
    _drawText(
      canvas,
      entry.oneLineSummary.trim(),
      x: _horizontalInset,
      y: 250,
      width: pixelWidth - 2 * _horizontalInset,
      fontSize: 31,
      lineHeight: 1.35,
      color: palette.foreground,
      fontWeight: ui.FontWeight.w600,
      maxLines: 2,
      textDirection: textDirection,
    );
    canvas.drawRect(
      const ui.Rect.fromLTWH(
        _horizontalInset,
        360,
        pixelWidth - 2 * _horizontalInset,
        2,
      ),
      ui.Paint()..color = palette.rule,
    );
  }

  void _drawPhoto({
    required ui.Canvas canvas,
    required _PhotoResource photo,
    required ui.Rect bounds,
    required _Palette palette,
    required DiaryShareLocalizedCopy localizedCopy,
    required ui.TextDirection textDirection,
  }) {
    final roundedBounds = ui.RRect.fromRectAndRadius(
      bounds,
      const ui.Radius.circular(30),
    );
    canvas.save();
    canvas.clipRRect(roundedBounds);
    canvas.drawRect(bounds, ui.Paint()..color = palette.photoBackground);
    final image = photo.image;
    if (image != null) {
      final sourceSize = ui.Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final scale = math.max(
        bounds.width / sourceSize.width,
        bounds.height / sourceSize.height,
      );
      final sourceWidth = bounds.width / scale;
      final sourceHeight = bounds.height / scale;
      final source = ui.Rect.fromLTWH(
        (sourceSize.width - sourceWidth) / 2,
        (sourceSize.height - sourceHeight) / 2,
        sourceWidth,
        sourceHeight,
      );
      canvas.drawImageRect(
        image,
        source,
        bounds,
        ui.Paint()..filterQuality = ui.FilterQuality.high,
      );
    } else {
      final iconCenter = ui.Offset(bounds.center.dx, bounds.center.dy - 25);
      canvas.drawCircle(
        iconCenter,
        38,
        ui.Paint()
          ..color = palette.muted
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.drawLine(
        iconCenter.translate(-18, 17),
        iconCenter.translate(0, -6),
        ui.Paint()
          ..color = palette.muted
          ..strokeWidth = 4
          ..strokeCap = ui.StrokeCap.round,
      );
      canvas.drawLine(
        iconCenter.translate(0, -6),
        iconCenter.translate(22, 18),
        ui.Paint()
          ..color = palette.muted
          ..strokeWidth = 4
          ..strokeCap = ui.StrokeCap.round,
      );
      _drawText(
        canvas,
        localizedCopy.photoUnavailableMessage.trim(),
        x: bounds.left,
        y: bounds.center.dy + 42,
        width: bounds.width,
        fontSize: 24,
        color: palette.muted,
        textAlign: ui.TextAlign.center,
        textDirection: textDirection,
      );
    }
    canvas.restore();
  }

  _TextFit _fitText({
    required List<String> units,
    required int start,
    required double maxWidth,
    required double maxHeight,
    required ui.Color color,
    required ui.TextDirection textDirection,
  }) {
    var low = start + 1;
    var high = units.length;
    var bestEnd = start;
    var bestHeight = 0.0;
    while (low <= high) {
      final middle = low + ((high - low) ~/ 2);
      final height = _measureBodyText(
        units.sublist(start, middle).join(),
        maxWidth: maxWidth,
        color: color,
        textDirection: textDirection,
      );
      if (height <= maxHeight + 0.01) {
        bestEnd = middle;
        bestHeight = height;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    if (bestEnd <= start) return const _TextFit(end: 0, height: 0);

    if (bestEnd < units.length) {
      final minimumWordBoundary = start + ((bestEnd - start) * 0.6).floor();
      for (var index = bestEnd - 1; index >= minimumWordBoundary; index -= 1) {
        if (units[index].trim().isEmpty) {
          bestEnd = index + 1;
          bestHeight = _measureBodyText(
            units.sublist(start, bestEnd).join(),
            maxWidth: maxWidth,
            color: color,
            textDirection: textDirection,
          );
          break;
        }
      }
    }
    return _TextFit(end: bestEnd, height: bestHeight);
  }

  double _measureBodyText(
    String text, {
    required double maxWidth,
    required ui.Color color,
    required ui.TextDirection textDirection,
  }) {
    final paragraph = _paragraph(
      text,
      maxWidth: maxWidth,
      fontSize: 39,
      lineHeight: 1.52,
      color: color,
      textDirection: textDirection,
    );
    final height = paragraph.height;
    paragraph.dispose();
    return height;
  }

  ui.Paragraph _paragraph(
    String text, {
    required double maxWidth,
    required double fontSize,
    required double lineHeight,
    required ui.Color color,
    required ui.TextDirection textDirection,
    ui.FontWeight fontWeight = ui.FontWeight.w400,
    ui.TextAlign textAlign = ui.TextAlign.left,
    int? maxLines,
    double? letterSpacing,
  }) {
    final builder =
        ui.ParagraphBuilder(
          ui.ParagraphStyle(
            textDirection: textDirection,
            textAlign: textAlign,
            fontFamily: 'sans-serif',
            fontSize: fontSize,
            height: lineHeight,
            maxLines: maxLines,
            ellipsis: maxLines == null ? null : '…',
          ),
        )..pushStyle(
          ui.TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: lineHeight,
            letterSpacing: letterSpacing,
          ),
        );
    builder.addText(text);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));
    return paragraph;
  }

  void _drawText(
    ui.Canvas canvas,
    String text, {
    required double x,
    required double y,
    required double width,
    required double fontSize,
    required ui.Color color,
    required ui.TextDirection textDirection,
    double lineHeight = 1.2,
    ui.FontWeight fontWeight = ui.FontWeight.w400,
    ui.TextAlign textAlign = ui.TextAlign.left,
    int? maxLines,
    double? letterSpacing,
  }) {
    final paragraph = _paragraph(
      text,
      maxWidth: width,
      fontSize: fontSize,
      lineHeight: lineHeight,
      color: color,
      textDirection: textDirection,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      letterSpacing: letterSpacing,
    );
    canvas.drawParagraph(paragraph, ui.Offset(x, y));
    paragraph.dispose();
  }

  double _photoHeight(_PhotoResource photo, double width) {
    final image = photo.image;
    if (image == null) return 500;
    final aspectHeight = width * image.height / image.width;
    return aspectHeight.clamp(_minimumPhotoHeight, _maximumPhotoHeight);
  }

  String _captionFor(DiaryEntry entry, DiaryShareLocalizedCopy localizedCopy) {
    return '${entry.oneLineSummary.trim()}\n\n'
        '${localizedCopy.captionMetadata.trim()}';
  }

  ui.TextDirection _uiTextDirection(DiaryShareTextDirection direction) {
    return switch (direction) {
      DiaryShareTextDirection.leftToRight => ui.TextDirection.ltr,
      DiaryShareTextDirection.rightToLeft => ui.TextDirection.rtl,
    };
  }

  static const double _minimumTextLineHeight = 62;
}

final class _PageLayout {
  _PageLayout({required this.index});

  final int index;
  final List<_PageItem> items = <_PageItem>[];
}

sealed class _PageItem {
  const _PageItem({required this.top, required this.height});

  final double top;
  final double height;
}

final class _TextPageItem extends _PageItem {
  const _TextPageItem({
    required this.text,
    required super.top,
    required super.height,
  });

  final String text;
}

final class _PhotoPageItem extends _PageItem {
  const _PhotoPageItem({
    required this.photo,
    required super.top,
    required super.height,
  });

  final _PhotoResource photo;
}

final class _PhotoResource {
  const _PhotoResource.image(this.image);
  const _PhotoResource.missing() : image = null;

  final ui.Image? image;
}

final class _TextFit {
  const _TextFit({required this.end, required this.height});

  final int end;
  final double height;
}

final class _Palette {
  const _Palette({
    required this.background,
    required this.foreground,
    required this.muted,
    required this.accent,
    required this.rule,
    required this.photoBackground,
  });

  factory _Palette.forTheme(DiaryTheme theme) {
    return switch (theme) {
      DiaryTheme.light => const _Palette(
        background: ui.Color(0xfff8f6f1),
        foreground: ui.Color(0xff20231f),
        muted: ui.Color(0xff6d716b),
        accent: ui.Color(0xff54705b),
        rule: ui.Color(0x2654705b),
        photoBackground: ui.Color(0xffe8e9e3),
      ),
      DiaryTheme.dark => const _Palette(
        background: ui.Color(0xff111512),
        foreground: ui.Color(0xfff2f1eb),
        muted: ui.Color(0xffaeb4ad),
        accent: ui.Color(0xffa9c9ae),
        rule: ui.Color(0x40a9c9ae),
        photoBackground: ui.Color(0xff252b27),
      ),
    };
  }

  final ui.Color background;
  final ui.Color foreground;
  final ui.Color muted;
  final ui.Color accent;
  final ui.Color rule;
  final ui.Color photoBackground;
}

List<String> _textClusters(String text) {
  final clusters = <String>[];
  var previousWasJoiner = false;
  for (final rune in text.runes) {
    final character = String.fromCharCode(rune);
    final continuesCluster =
        clusters.isNotEmpty &&
        (previousWasJoiner ||
            rune == 0x200d ||
            _isCombiningMark(rune) ||
            _isVariationSelector(rune) ||
            _isEmojiModifier(rune));
    if (continuesCluster) {
      clusters[clusters.length - 1] += character;
    } else {
      clusters.add(character);
    }
    previousWasJoiner = rune == 0x200d;
  }
  return clusters;
}

bool _isCombiningMark(int rune) {
  return (rune >= 0x0300 && rune <= 0x036f) ||
      (rune >= 0x1ab0 && rune <= 0x1aff) ||
      (rune >= 0x1dc0 && rune <= 0x1dff) ||
      (rune >= 0x20d0 && rune <= 0x20ff) ||
      (rune >= 0xfe20 && rune <= 0xfe2f);
}

bool _isVariationSelector(int rune) {
  return (rune >= 0xfe00 && rune <= 0xfe0f) ||
      (rune >= 0xe0100 && rune <= 0xe01ef);
}

bool _isEmojiModifier(int rune) => rune >= 0x1f3fb && rune <= 0x1f3ff;
