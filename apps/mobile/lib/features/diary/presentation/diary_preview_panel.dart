import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../core/time/diary_day_key.dart';
import '../../../l10n/namu_formatters.dart';
import '../../../l10n/namu_localizations.dart';
import '../../media/presentation/local_photo.dart';
import '../domain/diary_entry.dart';
import '../domain/diary_generation_output.dart';
import '../domain/weather_snapshot.dart';

class DiaryPreviewPanel extends StatelessWidget {
  const DiaryPreviewPanel({
    required this.dayKey,
    required this.entry,
    required this.isGenerating,
    required this.canGenerate,
    this.onBack,
    this.onGenerate,
    this.onFinalize,
    this.onEdit,
    this.onShare,
    this.photoBytesLoader,
    super.key,
  });

  final DiaryDayKey dayKey;
  final DiaryEntry? entry;
  final bool isGenerating;
  final bool canGenerate;
  final VoidCallback? onBack;
  final VoidCallback? onGenerate;
  final VoidCallback? onFinalize;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('diary.preview.panel'),
      color: const Color(0xFFF4F1EA),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewHeader(onBack: onBack, entryStatus: entry?.status),
                  const SizedBox(height: 18),
                  if (entry == null)
                    _EmptyDiary(
                      isGenerating: isGenerating,
                      canGenerate: canGenerate,
                      onGenerate: onGenerate,
                    )
                  else ...[
                    _DiaryCard(
                      entry: entry!,
                      photoBytesLoader: photoBytesLoader,
                    ),
                    const SizedBox(height: 16),
                    _DiaryActions(
                      status: entry!.status,
                      onEdit: onEdit,
                      onFinalize: onFinalize,
                      onShare: onShare,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry!.status == DiaryEntryStatus.finalized
                          ? context.l10n.diaryPreviewFinalizedHelp
                          : context.l10n.diaryPreviewDraftHelp,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFF6F716C)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.onBack, required this.entryStatus});

  final VoidCallback? onBack;
  final DiaryEntryStatus? entryStatus;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (onBack != null) ...[
          IconButton.outlined(
            key: const Key('diary.preview.back'),
            onPressed: onBack,
            tooltip: context.l10n.commonBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.diaryPreviewTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entryStatus == null
                    ? context.l10n.diaryPreviewCreateSubtitle
                    : context.l10n.diaryPreviewStoredSubtitle,
                maxLines: 2,
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6F716C),
                ),
              ),
            ],
          ),
        ),
        if (entryStatus != null) ...[
          const SizedBox(width: 12),
          _StatusBadge(status: entryStatus!),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DiaryEntryStatus status;

  @override
  Widget build(BuildContext context) {
    final finalized = status == DiaryEntryStatus.finalized;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: finalized ? const Color(0xFFDDE9DE) : const Color(0xFFF4E9DA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.commonDiaryStatus(status.name),
        style: TextStyle(
          color: finalized ? const Color(0xFF355F4B) : const Color(0xFF795439),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyDiary extends StatelessWidget {
  const _EmptyDiary({
    required this.isGenerating,
    required this.canGenerate,
    required this.onGenerate,
  });

  final bool isGenerating;
  final bool canGenerate;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        key: const Key('diary.empty'),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2DED4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x123A392F),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5ECE6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  size: 34,
                  color: Color(0xFF355F4B),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                context.l10n.diaryPreviewEmptyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 9),
              Text(
                canGenerate
                    ? context.l10n.diaryPreviewEmptyCanGenerate
                    : context.l10n.diaryPreviewEmptyNeedsChat,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.45),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('diary.generate'),
                onPressed: !canGenerate || isGenerating ? null : onGenerate,
                icon: isGenerating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  isGenerating
                      ? context.l10n.diaryPreviewGenerating
                      : context.l10n.diaryPreviewGenerate,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF355F4B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaryCard extends StatefulWidget {
  const _DiaryCard({required this.entry, required this.photoBytesLoader});

  final DiaryEntry entry;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  State<_DiaryCard> createState() => _DiaryCardState();
}

class _DiaryCardState extends State<_DiaryCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant _DiaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntry = oldWidget.entry;
    final entry = widget.entry;
    if (oldEntry.id != entry.id ||
        oldEntry.version != entry.version ||
        oldEntry.updatedAtUtc != entry.updatedAtUtc) {
      _currentPage = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) _pageController.jumpToPage(0);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPage(int page, int pageCount) {
    if (!_pageController.hasClients || page < 0 || page >= pageCount) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final dark = entry.theme == DiaryTheme.dark;
    final background = dark ? const Color(0xFF171A18) : const Color(0xFFFFFEFB);
    final foreground = dark ? const Color(0xFFF5F1E8) : const Color(0xFF242722);
    final secondary = dark ? const Color(0xFFCFD2CB) : const Color(0xFF61655D);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth * 5 / 4;
        final pages = _DiaryPreviewPaginator(
          contentWidth: cardWidth - 36,
          firstPageBodyHeight:
              cardHeight - 36 - _DiaryPage.firstPageHeaderHeight,
          followingPageBodyHeight:
              cardHeight - 36 - _DiaryPage.followingPageHeaderHeight,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.localeOf(context),
        ).paginate(entry.blocks);
        final currentPage = _currentPage.clamp(0, pages.length - 1);
        if (currentPage != _currentPage) {
          _currentPage = currentPage;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(currentPage);
            }
          });
        }

        return Column(
          children: [
            AspectRatio(
              key: const Key('diary.entry.card'),
              aspectRatio: 4 / 5,
              child: PageView.builder(
                key: const Key('diary.entry.pages'),
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) => _DiaryPage(
                  key: ValueKey('diary.page.$index'),
                  entry: entry,
                  page: pages[index],
                  background: background,
                  foreground: foreground,
                  secondary: secondary,
                  dark: dark,
                  photoBytesLoader: widget.photoBytesLoader,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _DiaryPageIndicator(
              currentPage: currentPage,
              pageCount: pages.length,
              onPrevious: currentPage == 0
                  ? null
                  : () => _showPage(currentPage - 1, pages.length),
              onNext: currentPage == pages.length - 1
                  ? null
                  : () => _showPage(currentPage + 1, pages.length),
            ),
          ],
        );
      },
    );
  }
}

class _DiaryPageIndicator extends StatelessWidget {
  const _DiaryPageIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: context.l10n.diaryPreviewPageSemantics(currentPage + 1, pageCount),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: const Key('diary.page.previous'),
            onPressed: onPrevious,
            tooltip: context.l10n.diaryPreviewPreviousPageTooltip,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.diaryPreviewPageIndicator(currentPage + 1, pageCount),
            key: const Key('diary.page.indicator'),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF555A54),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const Key('diary.page.next'),
            onPressed: onNext,
            tooltip: context.l10n.diaryPreviewNextPageTooltip,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _DiaryPage extends StatelessWidget {
  const _DiaryPage({
    required this.entry,
    required this.page,
    required this.background,
    required this.foreground,
    required this.secondary,
    required this.dark,
    required this.photoBytesLoader,
    super.key,
  });

  static const double firstPageHeaderHeight = 157;
  static const double followingPageHeaderHeight = 58;

  final DiaryEntry entry;
  final _DiaryPreviewPage page;
  final Color background;
  final Color foreground;
  final Color secondary;
  final bool dark;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? const Color(0xFF343934) : const Color(0xFFE2DED4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3A392F),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: page.isFirst
                    ? firstPageHeaderHeight
                    : followingPageHeaderHeight,
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: page.isFirst
                      ? _FirstPageHeader(
                          entry: entry,
                          foreground: foreground,
                          secondary: secondary,
                          dark: dark,
                        )
                      : _FollowingPageHeader(
                          dayKey: entry.dayKey,
                          foreground: foreground,
                          dark: dark,
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < page.items.length; index++) ...[
                      _DiaryPageItemView(
                        item: page.items[index],
                        foreground: secondary,
                        dark: dark,
                        photoBytesLoader: photoBytesLoader,
                      ),
                      if (index != page.items.length - 1)
                        const SizedBox(height: _DiaryPreviewPaginator.itemGap),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstPageHeader extends StatelessWidget {
  const _FirstPageHeader({
    required this.entry,
    required this.foreground,
    required this.secondary,
    required this.dark,
  });

  final DiaryEntry entry;
  final Color foreground;
  final Color secondary;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeading(dayKey: entry.dayKey, foreground: foreground),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          color: dark ? const Color(0xFF343934) : const Color(0xFFEAE5DB),
        ),
        const SizedBox(height: 8),
        _DayDetails(
          weather: entry.weather,
          mood: entry.mood,
          foreground: secondary,
          dark: dark,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.diaryPreviewOneLineLabel,
          style: const TextStyle(
            color: Color(0xFFB58B5C),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Expanded(
          child: Text(
            entry.oneLineSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Divider(
          height: 1,
          color: dark ? const Color(0xFF343934) : const Color(0xFFEAE5DB),
        ),
      ],
    );
  }
}

class _FollowingPageHeader extends StatelessWidget {
  const _FollowingPageHeader({
    required this.dayKey,
    required this.foreground,
    required this.dark,
  });

  final DiaryDayKey dayKey;
  final Color foreground;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CardHeading(dayKey: dayKey, foreground: foreground),
        const SizedBox(height: 10),
        Divider(
          height: 1,
          color: dark ? const Color(0xFF343934) : const Color(0xFFEAE5DB),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

/// Uses the same content-order policy as the fixed-size share renderer while
/// measuring against the responsive preview card and current text scale.
final class _DiaryPreviewPaginator {
  const _DiaryPreviewPaginator({
    required this.contentWidth,
    required this.firstPageBodyHeight,
    required this.followingPageBodyHeight,
    required this.textDirection,
    required this.textScaler,
    required this.locale,
  });

  static const double itemGap = 9;
  static const TextStyle bodyTextStyle = TextStyle(fontSize: 13, height: 1.5);

  final double contentWidth;
  final double firstPageBodyHeight;
  final double followingPageBodyHeight;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final Locale locale;

  List<_DiaryPreviewPage> paginate(List<DiaryBlock> blocks) {
    final pages = <_DiaryPreviewPage>[
      _DiaryPreviewPage(index: 0, isFirst: true),
    ];
    var page = pages.single;
    var usedHeight = 0.0;

    double pageCapacity() =>
        page.isFirst ? firstPageBodyHeight : followingPageBodyHeight;

    void nextPage() {
      page = _DiaryPreviewPage(index: pages.length, isFirst: false);
      pages.add(page);
      usedHeight = 0;
    }

    double availableHeight() {
      final gap = page.items.isEmpty ? 0.0 : itemGap;
      return pageCapacity() - usedHeight - gap;
    }

    void addItem(_DiaryPreviewPageItem item) {
      if (page.items.isNotEmpty) usedHeight += itemGap;
      page.items.add(item);
      usedHeight += item.height;
    }

    for (var blockIndex = 0; blockIndex < blocks.length; blockIndex += 1) {
      switch (blocks[blockIndex]) {
        case DiaryTextBlock(:final text):
          final units = _previewTextClusters(text.trim());
          var start = 0;
          var segmentIndex = 0;
          while (start < units.length) {
            var available = availableHeight();
            final oneLineHeight = _measureText('M');
            if (available + 0.01 < oneLineHeight) {
              nextPage();
              available = availableHeight();
            }

            final fit = _fitText(
              units: units,
              start: start,
              maxHeight: available,
            );
            if (fit.end <= start) {
              // Platform accessibility scaling would have to make even one
              // glyph taller than a continuation page to reach this branch.
              // Keep the content reachable by dedicating a scrollable page.
              final remaining = units.sublist(start).join().trim();
              addItem(
                _DiaryTextPageItem(
                  blockIndex: blockIndex,
                  segmentIndex: segmentIndex,
                  text: remaining,
                  height: available,
                  scrollable: true,
                ),
              );
              start = units.length;
              continue;
            }

            final segment = units.sublist(start, fit.end).join().trim();
            if (segment.isNotEmpty) {
              addItem(
                _DiaryTextPageItem(
                  blockIndex: blockIndex,
                  segmentIndex: segmentIndex,
                  text: segment,
                  height: fit.height,
                ),
              );
              segmentIndex += 1;
            }
            start = fit.end;
            while (start < units.length && units[start].trim().isEmpty) {
              start += 1;
            }
            if (start < units.length) nextPage();
          }
        case DiaryPhotoBlock(:final photoAssetId):
          final preferredHeight = (contentWidth * 0.72).clamp(
            0.0,
            followingPageBodyHeight,
          );
          var available = availableHeight();
          if ((page.items.isNotEmpty && available < preferredHeight) ||
              (page.isFirst &&
                  page.items.isEmpty &&
                  available < 180 &&
                  followingPageBodyHeight > available)) {
            nextPage();
            available = availableHeight();
          }
          addItem(
            _DiaryPhotoPageItem(
              blockIndex: blockIndex,
              photoAssetId: photoAssetId,
              height: preferredHeight.clamp(0.0, available),
            ),
          );
      }
    }

    return List<_DiaryPreviewPage>.unmodifiable(pages);
  }

  _DiaryTextFit _fitText({
    required List<String> units,
    required int start,
    required double maxHeight,
  }) {
    var low = start + 1;
    var high = units.length;
    var bestEnd = start;
    var bestHeight = 0.0;
    while (low <= high) {
      final middle = low + ((high - low) ~/ 2);
      final candidate = units.sublist(start, middle).join().trim();
      final height = _measureText(candidate);
      if (height <= maxHeight + 0.01) {
        bestEnd = middle;
        bestHeight = height;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    if (bestEnd <= start) return const _DiaryTextFit(end: 0, height: 0);

    if (bestEnd < units.length) {
      final minimumWordBoundary = start + ((bestEnd - start) * 0.6).floor();
      for (var index = bestEnd - 1; index >= minimumWordBoundary; index -= 1) {
        if (units[index].trim().isEmpty) {
          bestEnd = index + 1;
          bestHeight = _measureText(
            units.sublist(start, bestEnd).join().trim(),
          );
          break;
        }
      }
    }
    return _DiaryTextFit(end: bestEnd, height: bestHeight);
  }

  double _measureText(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: bodyTextStyle),
      textDirection: textDirection,
      textScaler: textScaler,
      locale: locale,
    )..layout(maxWidth: contentWidth);
    return painter.height;
  }
}

final class _DiaryPreviewPage {
  _DiaryPreviewPage({required this.index, required this.isFirst});

  final int index;
  final bool isFirst;
  final List<_DiaryPreviewPageItem> items = <_DiaryPreviewPageItem>[];
}

sealed class _DiaryPreviewPageItem {
  const _DiaryPreviewPageItem({required this.blockIndex, required this.height});

  final int blockIndex;
  final double height;
}

final class _DiaryTextPageItem extends _DiaryPreviewPageItem {
  const _DiaryTextPageItem({
    required super.blockIndex,
    required this.segmentIndex,
    required this.text,
    required super.height,
    this.scrollable = false,
  });

  final int segmentIndex;
  final String text;
  final bool scrollable;
}

final class _DiaryPhotoPageItem extends _DiaryPreviewPageItem {
  const _DiaryPhotoPageItem({
    required super.blockIndex,
    required this.photoAssetId,
    required super.height,
  });

  final String photoAssetId;
}

final class _DiaryTextFit {
  const _DiaryTextFit({required this.end, required this.height});

  final int end;
  final double height;
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.dayKey, required this.foreground});

  final DiaryDayKey dayKey;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF355F4B),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.eco_outlined,
            color: const Color(0xFFF1E9D7),
            size: 17,
            semanticLabel: context.l10n.diaryPreviewBrandSemantics,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.diaryPreviewBrandHeading,
                style: const TextStyle(
                  color: Color(0xFF58906F),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                NamuFormatters.fullDate(
                  dayKey.labelDate,
                  Localizations.localeOf(context),
                ),
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.more_horiz_rounded, color: foreground, size: 21),
      ],
    );
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({
    required this.weather,
    required this.mood,
    required this.foreground,
    required this.dark,
  });

  final WeatherSnapshot weather;
  final String mood;
  final Color foreground;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          weather.provenance == WeatherProvenance.noWeather
              ? Icons.cloud_off_outlined
              : Icons.wb_sunny_outlined,
          size: 16,
          color: const Color(0xFFC98B4F),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            _formatWeather(context, weather),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF44372B) : const Color(0xFFF4E9DA),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_satisfied_alt_rounded,
                size: 14,
                color: Color(0xFFB87B4D),
              ),
              const SizedBox(width: 4),
              Text(
                mood,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFB87B4D),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatWeather(BuildContext context, WeatherSnapshot weather) {
    if (weather.provenance == WeatherProvenance.noWeather) {
      return context.l10n.diaryWeatherNone;
    }
    final source = weather.provenance == WeatherProvenance.manual
        ? context.l10n.diaryWeatherManualSource
        : weather.providerId!;
    final condition = weather.condition!;
    final value = weather.temperatureCelsius;
    if (value == null) {
      return context.l10n.diaryWeatherSourceAndCondition(source, condition);
    }
    final locale = Localizations.localeOf(context);
    final temperature = NumberFormat(
      '0.#',
      locale.toLanguageTag(),
    ).format(value);
    return context.l10n.diaryWeatherSourceConditionTemperature(
      source,
      condition,
      temperature,
    );
  }
}

class _DiaryPageItemView extends StatelessWidget {
  const _DiaryPageItemView({
    required this.item,
    required this.foreground,
    required this.dark,
    required this.photoBytesLoader,
  });

  final _DiaryPreviewPageItem item;
  final Color foreground;
  final bool dark;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: item.height,
      child: switch (item) {
        _DiaryTextPageItem(
          :final blockIndex,
          :final segmentIndex,
          :final text,
          :final scrollable,
        ) =>
          scrollable
              ? SingleChildScrollView(
                  child: Text(
                    text,
                    key: Key('diary.block.$blockIndex.segment.$segmentIndex'),
                    style: _DiaryPreviewPaginator.bodyTextStyle.copyWith(
                      color: foreground,
                    ),
                  ),
                )
              : Text(
                  text,
                  key: Key('diary.block.$blockIndex.segment.$segmentIndex'),
                  style: _DiaryPreviewPaginator.bodyTextStyle.copyWith(
                    color: foreground,
                  ),
                ),
        _DiaryPhotoPageItem(:final photoAssetId) => Semantics(
          container: true,
          image: true,
          label: context.l10n.commonAttachedPhoto,
          excludeSemantics: true,
          child: ClipRRect(
            key: Key('diary.photo.$photoAssetId'),
            borderRadius: BorderRadius.circular(16),
            child: LocalPhoto(
              assetId: photoAssetId,
              loadBytes: photoBytesLoader,
              cacheWidth: 1200,
              backgroundColor: dark
                  ? const Color(0xFF2E3932)
                  : const Color(0xFFDCE8E1),
              foregroundColor: const Color(0xFF58906F),
            ),
          ),
        ),
      },
    );
  }
}

List<String> _previewTextClusters(String text) {
  final clusters = <String>[];
  var previousWasJoiner = false;
  for (final rune in text.runes) {
    final character = String.fromCharCode(rune);
    final continuesCluster =
        clusters.isNotEmpty &&
        (previousWasJoiner ||
            rune == 0x200d ||
            _isPreviewCombiningMark(rune) ||
            _isPreviewVariationSelector(rune) ||
            _isPreviewEmojiModifier(rune));
    if (continuesCluster) {
      clusters[clusters.length - 1] += character;
    } else {
      clusters.add(character);
    }
    previousWasJoiner = rune == 0x200d;
  }
  return clusters;
}

bool _isPreviewCombiningMark(int rune) {
  return (rune >= 0x0300 && rune <= 0x036f) ||
      (rune >= 0x1ab0 && rune <= 0x1aff) ||
      (rune >= 0x1dc0 && rune <= 0x1dff) ||
      (rune >= 0x20d0 && rune <= 0x20ff) ||
      (rune >= 0xfe20 && rune <= 0xfe2f);
}

bool _isPreviewVariationSelector(int rune) {
  return (rune >= 0xfe00 && rune <= 0xfe0f) ||
      (rune >= 0xe0100 && rune <= 0xe01ef);
}

bool _isPreviewEmojiModifier(int rune) {
  return rune >= 0x1f3fb && rune <= 0x1f3ff;
}

class _DiaryActions extends StatelessWidget {
  const _DiaryActions({
    required this.status,
    required this.onEdit,
    required this.onFinalize,
    required this.onShare,
  });

  final DiaryEntryStatus status;
  final VoidCallback? onEdit;
  final VoidCallback? onFinalize;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final finalized = status == DiaryEntryStatus.finalized;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('diary.edit'),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 19),
            label: Text(context.l10n.diaryEditAction),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: const Color(0xFF242722),
              side: const BorderSide(color: Color(0xFFC9C5BB)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            key: finalized
                ? const Key('diary.share')
                : const Key('diary.finalize'),
            onPressed: finalized ? onShare : onFinalize,
            icon: Icon(
              finalized ? Icons.ios_share_rounded : Icons.check_rounded,
              size: 19,
            ),
            label: Text(
              finalized
                  ? context.l10n.diaryShareAction
                  : context.l10n.diaryFinalizeAction,
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFF263D33),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
