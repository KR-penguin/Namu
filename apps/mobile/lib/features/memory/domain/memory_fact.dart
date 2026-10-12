enum MemoryCategory {
  preference,
  routine,
  relationship,
  place,
  milestone,
  other,
}

enum MemorySensitivity { standard, sensitive }

enum MemoryStatus { candidate, active, inactive }

final class MemoryFact {
  factory MemoryFact({
    required String id,
    required String fact,
    required List<String> sourceMessageIds,
    required MemoryCategory category,
    required MemorySensitivity sensitivity,
    required MemoryStatus status,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
  }) {
    final normalizedId = id.trim();
    final normalizedFact = fact.trim();
    final normalizedSources = sourceMessageIds
        .map((sourceId) => sourceId.trim())
        .toList(growable: false);

    _requireNonBlank(normalizedId, 'id');
    _requireNonBlank(normalizedFact, 'fact');
    if (normalizedSources.isEmpty) {
      throw ArgumentError.value(
        sourceMessageIds,
        'sourceMessageIds',
        'must contain at least one source message',
      );
    }
    for (final sourceId in normalizedSources) {
      _requireNonBlank(sourceId, 'sourceMessageIds');
    }
    if (normalizedSources.toSet().length != normalizedSources.length) {
      throw ArgumentError.value(
        sourceMessageIds,
        'sourceMessageIds',
        'must not contain duplicates',
      );
    }
    _requireUtc(createdAtUtc, 'createdAtUtc');
    _requireUtc(updatedAtUtc, 'updatedAtUtc');
    if (updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError.value(
        updatedAtUtc,
        'updatedAtUtc',
        'must not be earlier than createdAtUtc',
      );
    }

    return MemoryFact._(
      id: normalizedId,
      fact: normalizedFact,
      sourceMessageIds: List<String>.unmodifiable(normalizedSources),
      category: category,
      sensitivity: sensitivity,
      status: status,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  const MemoryFact._({
    required this.id,
    required this.fact,
    required this.sourceMessageIds,
    required this.category,
    required this.sensitivity,
    required this.status,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String fact;
  final List<String> sourceMessageIds;
  final MemoryCategory category;
  final MemorySensitivity sensitivity;
  final MemoryStatus status;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  MemoryFact approve({required DateTime updatedAtUtc}) {
    return _with(status: MemoryStatus.active, updatedAtUtc: updatedAtUtc);
  }

  MemoryFact activateAutomatically({required DateTime updatedAtUtc}) {
    if (sensitivity == MemorySensitivity.sensitive) {
      throw StateError('Sensitive memories require explicit user approval.');
    }
    return _with(status: MemoryStatus.active, updatedAtUtc: updatedAtUtc);
  }

  MemoryFact edit({required String fact, required DateTime updatedAtUtc}) {
    return MemoryFact(
      id: id,
      fact: fact,
      sourceMessageIds: sourceMessageIds,
      category: category,
      sensitivity: sensitivity,
      status: status,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  MemoryFact deactivate({required DateTime updatedAtUtc}) {
    return _with(status: MemoryStatus.inactive, updatedAtUtc: updatedAtUtc);
  }

  MemoryFact _with({
    required MemoryStatus status,
    required DateTime updatedAtUtc,
  }) {
    return MemoryFact(
      id: id,
      fact: fact,
      sourceMessageIds: sourceMessageIds,
      category: category,
      sensitivity: sensitivity,
      status: status,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }

  static void _requireNonBlank(String value, String name) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, name, 'must not be blank');
    }
  }

  static void _requireUtc(DateTime value, String name) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, name, 'must be in UTC');
    }
  }
}
