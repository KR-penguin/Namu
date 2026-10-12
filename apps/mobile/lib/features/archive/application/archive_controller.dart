import 'package:flutter/foundation.dart';

import '../../diary/domain/diary_entry.dart';
import '../../diary/domain/diary_repository.dart';

final class ArchiveController extends ChangeNotifier {
  ArchiveController({required this.repository});

  final DiaryRepository repository;

  List<DiaryEntry> _allEntries = const [];
  List<DiaryEntry> _entries = const [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _isDisposed = false;
  Object? _error;

  List<DiaryEntry> get entries => _entries;
  String get searchQuery => _searchQuery;
  bool get hasStoredEntries => _allEntries.isNotEmpty;
  bool get hasActiveSearch => _normalizeSearchText(_searchQuery).isNotEmpty;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  Object? get error => _error;

  Future<void> reload() async {
    if (_isLoading || _isDisposed) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await repository.listAll();
      if (_isDisposed) {
        return;
      }
      final sorted = loaded.toList()..sort(_compareEntries);
      _allEntries = List<DiaryEntry>.unmodifiable(sorted);
      _applySearch();
      _hasLoaded = true;
    } catch (error) {
      if (!_isDisposed) {
        _error = error;
        _hasLoaded = true;
      }
      rethrow;
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  void updateSearchQuery(String query) {
    if (_isDisposed || query == _searchQuery) {
      return;
    }
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  static int _compareEntries(DiaryEntry left, DiaryEntry right) {
    final byUpdated = right.updatedAtUtc.compareTo(left.updatedAtUtc);
    return byUpdated != 0 ? byUpdated : left.id.compareTo(right.id);
  }

  void _applySearch() {
    final normalizedQuery = _normalizeSearchText(_searchQuery);
    if (normalizedQuery.isEmpty) {
      _entries = _allEntries;
      return;
    }

    final terms = normalizedQuery.split(' ');
    _entries = List<DiaryEntry>.unmodifiable(
      _allEntries.where((entry) {
        final searchableText = _normalizeSearchText(
          '${entry.dayKey.labelDate} ${entry.mood} ${entry.oneLineSummary}',
        );
        return terms.every(searchableText.contains);
      }),
    );
  }

  static String _normalizeSearchText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
