import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../l10n/namu_localizations.dart';

typedef LocalPhotoBytesLoader = Future<Uint8List> Function(String assetId);

/// Displays app-owned image bytes without exposing storage keys to widgets.
class LocalPhoto extends StatefulWidget {
  const LocalPhoto({
    required this.assetId,
    this.loadBytes,
    this.fit = BoxFit.cover,
    this.cacheWidth = 1200,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  }) : assert(cacheWidth > 0);

  final String assetId;
  final LocalPhotoBytesLoader? loadBytes;
  final BoxFit fit;

  /// Bounds decoded preview size independently from the original image size.
  final int cacheWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<LocalPhoto> createState() => _LocalPhotoState();
}

class _LocalPhotoState extends State<LocalPhoto> {
  Future<Uint8List>? _bytes;

  @override
  void initState() {
    super.initState();
    _startLoad();
  }

  @override
  void didUpdateWidget(covariant LocalPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetId != widget.assetId ||
        oldWidget.loadBytes != widget.loadBytes) {
      _startLoad();
    }
  }

  void _startLoad() {
    final loader = widget.loadBytes;
    _bytes = loader == null ? null : loader(widget.assetId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor =
        widget.backgroundColor ?? colors.surfaceContainerHighest;
    final foregroundColor = widget.foregroundColor ?? colors.onSurfaceVariant;
    final future = _bytes;

    return Semantics(
      image: true,
      label: context.l10n.commonAttachedPhoto,
      child: ColoredBox(
        color: backgroundColor,
        child: future == null
            ? _PhotoFallback(color: foregroundColor)
            : FutureBuilder<Uint8List>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: SizedBox.square(
                        key: const Key('localPhoto.loading'),
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foregroundColor,
                        ),
                      ),
                    );
                  }

                  final bytes = snapshot.data;
                  if (snapshot.hasError || bytes == null || bytes.isEmpty) {
                    return _PhotoFallback(color: foregroundColor);
                  }

                  return Image.memory(
                    bytes,
                    key: const Key('localPhoto.image'),
                    fit: widget.fit,
                    width: double.infinity,
                    height: double.infinity,
                    cacheWidth: widget.cacheWidth,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) =>
                        _PhotoFallback(color: foregroundColor),
                  );
                },
              ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.photo_outlined,
        key: const Key('localPhoto.fallback'),
        color: color,
        size: 30,
      ),
    );
  }
}
