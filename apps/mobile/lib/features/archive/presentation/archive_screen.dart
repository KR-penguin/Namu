import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/time/diary_day_key.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/namu_localizations.dart';
import '../../diary/domain/diary_entry.dart';
import '../application/archive_controller.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({
    required this.controller,
    required this.onEntrySelected,
    this.onBack,
    super.key,
  });

  final ArchiveController controller;
  final ValueChanged<DiaryEntry> onEntrySelected;
  final VoidCallback? onBack;

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
    _scheduleInitialLoad();
  }

  @override
  void didUpdateWidget(covariant ArchiveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _searchController.text = widget.controller.searchQuery;
      _scheduleInitialLoad();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.controller.hasLoaded ||
          widget.controller.isLoading) {
        return;
      }
      unawaited(_reloadSafely());
    });
  }

  Future<void> _reloadSafely() async {
    try {
      await widget.controller.reload();
    } catch (_) {
      // The controller exposes a retryable, redacted presentation state.
    }
  }

  void _clearSearch() {
    _searchController.clear();
    widget.controller.updateSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('archive.screen'),
      color: const Color(0xFFF4F1EA),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final controller = widget.controller;
            return Column(
              children: [
                _ArchiveHeader(
                  isLoading: controller.isLoading,
                  onBack: widget.onBack,
                  onReload: () => unawaited(_reloadSafely()),
                ),
                if (controller.hasStoredEntries || controller.hasActiveSearch)
                  _ArchiveSearchField(
                    controller: _searchController,
                    onChanged: controller.updateSearchQuery,
                    onClear: _clearSearch,
                  ),
                Expanded(
                  child: _ArchiveBody(
                    controller: controller,
                    onReload: _reloadSafely,
                    onClearSearch: _clearSearch,
                    onEntrySelected: widget.onEntrySelected,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArchiveSearchField extends StatelessWidget {
  const _ArchiveSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
        child: Semantics(
          container: true,
          textField: true,
          label: context.l10n.archiveSearchSemantics,
          child: TextField(
            key: const Key('archive.search.field'),
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: context.l10n.archiveSearchLabel,
              hintText: context.l10n.archiveSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('archive.search.clear'),
                      onPressed: onClear,
                      tooltip: context.l10n.archiveClearSearchTooltip,
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader({
    required this.isLoading,
    required this.onReload,
    required this.onBack,
  });

  final bool isLoading;
  final VoidCallback onReload;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton.outlined(
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
                  context.l10n.archiveTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.archiveSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFF6F716C)),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('archive.reload'),
            onPressed: isLoading ? null : onReload,
            tooltip: context.l10n.archiveReloadTooltip,
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ArchiveBody extends StatelessWidget {
  const _ArchiveBody({
    required this.controller,
    required this.onReload,
    required this.onClearSearch,
    required this.onEntrySelected,
  });

  final ArchiveController controller;
  final Future<void> Function() onReload;
  final VoidCallback onClearSearch;
  final ValueChanged<DiaryEntry> onEntrySelected;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && !controller.hasLoaded) {
      return Center(
        child: Semantics(
          label: context.l10n.archiveLoadingSemantics,
          child: const CircularProgressIndicator(key: Key('archive.loading')),
        ),
      );
    }
    if (controller.error != null && !controller.hasStoredEntries) {
      return _ArchiveError(onRetry: onReload);
    }
    if (!controller.hasStoredEntries) {
      return _ArchiveEmpty(onReload: onReload);
    }
    if (controller.entries.isEmpty && controller.hasActiveSearch) {
      return _ArchiveNoResults(
        onReload: onReload,
        onClear: onClearSearch,
        showReloadError: controller.error != null,
      );
    }

    return RefreshIndicator(
      onRefresh: onReload,
      child: ListView.separated(
        key: const Key('archive.list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount:
            controller.entries.length + (controller.error == null ? 0 : 1),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (controller.error != null && index == 0) {
            return _InlineArchiveError(onRetry: onReload);
          }
          final entryIndex = index - (controller.error == null ? 0 : 1);
          final entry = controller.entries[entryIndex];
          return _ArchiveEntryCard(
            entry: entry,
            onTap: () => onEntrySelected(entry),
          );
        },
      ),
    );
  }
}

class _ArchiveNoResults extends StatelessWidget {
  const _ArchiveNoResults({
    required this.onReload,
    required this.onClear,
    required this.showReloadError,
  });

  final Future<void> Function() onReload;
  final VoidCallback onClear;
  final bool showReloadError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showReloadError)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _InlineArchiveError(onRetry: onReload),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onReload,
            child: CustomScrollView(
              key: const Key('archive.noResults'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          semanticLabel: context.l10n.archiveNoResultsSemantics,
                          size: 42,
                          color: Color(0xFF6F716C),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.archiveNoResultsTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.archiveNoResultsBody,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          key: const Key('archive.noResults.clear'),
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded),
                          label: Text(context.l10n.archiveClearSearchTooltip),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchiveEmpty extends StatelessWidget {
  const _ArchiveEmpty({required this.onReload});

  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('archive.empty'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5ECE6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_stories_outlined,
                    semanticLabel: context.l10n.archiveEmptySemantics,
                    size: 34,
                    color: Color(0xFF355F4B),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.archiveEmptyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.archiveEmptyBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF6F716C), height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchiveError extends StatelessWidget {
  const _ArchiveError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        key: const Key('archive.error'),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              semanticLabel: context.l10n.archiveLoadErrorSemantics,
              size: 42,
              color: Color(0xFF795439),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.archiveLoadErrorTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              context.l10n.archiveStoredDataSafeBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              key: const Key('archive.retry'),
              onPressed: () => unawaited(onRetry()),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineArchiveError extends StatelessWidget {
  const _InlineArchiveError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4E9DA),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.archiveRefreshError,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => unawaited(onRetry()),
              child: Text(context.l10n.commonRetryShort),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveEntryCard extends StatelessWidget {
  const _ArchiveEntryCard({required this.entry, required this.onTap});

  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = _formatDate(entry.dayKey, l10n);
    final status = l10n.commonDiaryStatus(entry.status.name);
    final semanticLabel = l10n.archiveEntrySemantics(
      _formatAccessibleDate(entry.dayKey, l10n),
      entry.mood,
      status,
      entry.oneLineSummary,
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: const Color(0xFFFFFEFB),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2DED4)),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('archive.entry.${entry.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        date,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ArchiveStatusBadge(status: entry.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.archiveMoodLabel(entry.mood),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB87B4D),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.oneLineSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF353832),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    semanticLabel: context.l10n.archiveOpenDiarySemantics,
                    color: Color(0xFF6F716C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveStatusBadge extends StatelessWidget {
  const _ArchiveStatusBadge({required this.status});

  final DiaryEntryStatus status;

  @override
  Widget build(BuildContext context) {
    final finalized = status == DiaryEntryStatus.finalized;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: finalized ? const Color(0xFFDDE9DE) : const Color(0xFFF4E9DA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.commonDiaryStatus(status.name),
        style: TextStyle(
          color: finalized ? const Color(0xFF355F4B) : const Color(0xFF795439),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _formatDate(DiaryDayKey dayKey, AppLocalizations l10n) {
  final date = dayKey.labelDate;
  return l10n.commonFullDateWithWeekday(
    date.year,
    date.month,
    date.day,
    l10n.commonWeekday(_weekdayToken(dayKey)),
  );
}

String _formatAccessibleDate(DiaryDayKey dayKey, AppLocalizations l10n) {
  final date = dayKey.labelDate;
  return l10n.commonFullDate(date.year, date.month, date.day);
}

String _weekdayToken(DiaryDayKey dayKey) {
  final date = dayKey.labelDate;
  final weekday = DateTime.utc(date.year, date.month, date.day).weekday;
  const weekdays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  return weekdays[weekday - 1];
}
