import 'package:flutter/foundation.dart';

import '../domain/memory_fact.dart';
import '../domain/memory_fact_repository.dart';
import 'approve_memory_fact.dart';
import 'delete_memory_fact.dart';
import 'edit_memory_fact.dart';
import 'set_memory_fact_active.dart';

typedef MemoryUtcClock = DateTime Function();

final class MemoryManagementController extends ChangeNotifier {
  MemoryManagementController({required this.repository, MemoryUtcClock? utcNow})
    : _utcNow = utcNow ?? _systemUtcNow,
      _approveMemoryFact = ApproveMemoryFact(repository: repository),
      _editMemoryFact = EditMemoryFact(repository: repository),
      _deleteMemoryFact = DeleteMemoryFact(repository: repository),
      _setMemoryFactActive = SetMemoryFactActive(repository: repository);

  final MemoryFactRepository repository;
  final MemoryUtcClock _utcNow;
  final ApproveMemoryFact _approveMemoryFact;
  final EditMemoryFact _editMemoryFact;
  final DeleteMemoryFact _deleteMemoryFact;
  final SetMemoryFactActive _setMemoryFactActive;

  List<MemoryFact> _facts = const [];
  final Set<String> _mutatingIds = <String>{};
  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _isDisposed = false;
  Object? _error;

  List<MemoryFact> get facts => _facts;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get isMutatingAny => _mutatingIds.isNotEmpty;
  Object? get error => _error;

  bool isMutating(String memoryFactId) {
    return _mutatingIds.contains(memoryFactId.trim());
  }

  Future<void> reload() async {
    if (_isLoading || isMutatingAny || _isDisposed) {
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
      _facts = _sorted(loaded);
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

  Future<void> approve(String memoryFactId) {
    final id = _requireId(memoryFactId);
    return _runMutation(id, () async {
      final current = _findLoadedFact(id);
      if (current.status != MemoryStatus.candidate) {
        throw StateError('Only a memory candidate can be approved.');
      }
      final approved = await _approveMemoryFact(
        memoryFactId: id,
        approvedAtUtc: _utcNow(),
      );
      _replace(approved);
    });
  }

  Future<void> edit({required String id, required String fact}) {
    final normalizedId = _requireId(id);
    return _runMutation(normalizedId, () async {
      _findLoadedFact(normalizedId);
      final edited = await _editMemoryFact(
        memoryFactId: normalizedId,
        fact: fact,
        editedAtUtc: _utcNow(),
      );
      _replace(edited);
    });
  }

  Future<void> delete(String memoryFactId) {
    final id = _requireId(memoryFactId);
    return _runMutation(id, () async {
      _findLoadedFact(id);
      await _deleteMemoryFact(memoryFactId: id);
      if (_isDisposed) {
        return;
      }
      _facts = List<MemoryFact>.unmodifiable(
        _facts.where((fact) => fact.id != id),
      );
    });
  }

  Future<void> setActive(String memoryFactId, {required bool active}) {
    final id = _requireId(memoryFactId);
    return _runMutation(id, () async {
      _findLoadedFact(id);
      final updated = await _setMemoryFactActive(
        memoryFactId: id,
        active: active,
        changedAtUtc: _utcNow(),
      );
      _replace(updated);
    });
  }

  Future<void> _runMutation(String id, Future<void> Function() mutation) async {
    if (_isDisposed) {
      throw StateError('Memory management is no longer available.');
    }
    if (_isLoading) {
      throw StateError('Memories are still loading.');
    }
    if (!_mutatingIds.add(id)) {
      throw StateError('This memory is already being changed.');
    }
    notifyListeners();

    try {
      await mutation();
    } finally {
      _mutatingIds.remove(id);
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  MemoryFact _findLoadedFact(String id) {
    for (final fact in _facts) {
      if (fact.id == id) {
        return fact;
      }
    }
    throw MemoryFactNotFoundException(id);
  }

  void _replace(MemoryFact updated) {
    if (_isDisposed) {
      return;
    }
    _facts = _sorted([
      for (final fact in _facts)
        if (fact.id == updated.id) updated else fact,
    ]);
  }

  static List<MemoryFact> _sorted(Iterable<MemoryFact> facts) {
    final result = facts.toList()
      ..sort((left, right) {
        final byStatus = _statusRank(left.status)
            .compareTo(_statusRank(right.status));
        if (byStatus != 0) {
          return byStatus;
        }
        final byUpdated = right.updatedAtUtc.compareTo(left.updatedAtUtc);
        return byUpdated != 0 ? byUpdated : left.id.compareTo(right.id);
      });
    return List<MemoryFact>.unmodifiable(result);
  }

  static int _statusRank(MemoryStatus status) {
    return switch (status) {
      MemoryStatus.candidate => 0,
      MemoryStatus.active => 1,
      MemoryStatus.inactive => 2,
    };
  }

  static String _requireId(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, 'memoryFactId', 'must not be blank');
    }
    return normalized;
  }

  static DateTime _systemUtcNow() => DateTime.now().toUtc();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
