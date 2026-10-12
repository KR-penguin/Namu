import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/memory/application/memory_management_controller.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/domain/memory_fact_repository.dart';
import 'package:namu/features/memory/presentation/memory_management_screen.dart';

void main() {
  Widget subject(MemoryManagementController controller) {
    return MaterialApp(home: MemoryManagementScreen(controller: controller));
  }

  testWidgets(
    'shows a labelled loading state followed by an honest empty state',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final pending = Completer<List<MemoryFact>>();
      final repository = _MemoryFactRepository(loads: [() => pending.future]);
      final controller = _controller(repository);

      await tester.pumpWidget(subject(controller));
      await tester.pump();

      expect(find.byKey(const Key('memory.loading')), findsOneWidget);
      expect(find.bySemanticsLabel('기억 목록 불러오는 중'), findsOneWidget);

      pending.complete(const []);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('memory.empty')), findsOneWidget);
      expect(find.text('아직 저장된 기억이 없어요'), findsOneWidget);
      expect(find.textContaining('샘플'), findsNothing);
      semantics.dispose();
    },
  );

  testWidgets('redacts load errors and offers a working retry', (tester) async {
    final recovered = _fact(id: 'recovered', status: MemoryStatus.active);
    final repository = _MemoryFactRepository(
      loads: [
        () async => throw StateError('private database path and fact'),
        () async => [recovered],
      ],
    );
    final controller = _controller(repository);

    await tester.pumpWidget(subject(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('memory.error')), findsOneWidget);
    expect(find.text('기억을 불러오지 못했어요'), findsOneWidget);
    expect(find.textContaining('private database path and fact'), findsNothing);

    await tester.tap(find.byKey(const Key('memory.retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('memory.item.recovered')), findsOneWidget);
    expect(repository.listAllCalls, 2);
  });

  testWidgets('sensitive candidates stay pending until explicit confirmation', (
    tester,
  ) async {
    final repository = _MemoryFactRepository()
      ..seed(
        _fact(
          id: 'sensitive',
          sensitivity: MemorySensitivity.sensitive,
          fact: '사용자는 특정 장소를 자주 방문한다.',
        ),
      );
    final controller = _controller(repository);

    await tester.pumpWidget(subject(controller));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, 0);
    expect(find.text('검토 필요'), findsOneWidget);
    expect(find.text('민감한 기억 · 직접 승인 필요'), findsOneWidget);

    await tester.tap(find.byKey(const Key('memory.approve.sensitive')));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, 0);
    expect(find.text('민감한 기억을 사용할까요?'), findsOneWidget);
    expect(find.textContaining('다음 AI 대화에 사용될 수 있어요'), findsOneWidget);

    await tester.tap(find.byKey(const Key('memory.approve.confirm')));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, 1);
    expect(find.text('사용 중'), findsOneWidget);
    expect(find.text('검토 필요'), findsNothing);
  });

  testWidgets('shows active and inactive states with text, not color alone', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = _MemoryFactRepository()
      ..seed(_fact(id: 'active', status: MemoryStatus.active))
      ..seed(_fact(id: 'inactive', status: MemoryStatus.inactive));
    final controller = _controller(repository);

    await tester.pumpWidget(subject(controller));
    await tester.pumpAndSettle();

    expect(find.text('사용 중'), findsOneWidget);
    expect(find.text('사용 안 함'), findsOneWidget);
    expect(
      find.bySemanticsLabel('기억, 사용자는 산책을 좋아한다., 상태 사용 중, 분류 취향'),
      findsOneWidget,
    );
    expect(find.text('message-private-source'), findsNothing);
    semantics.dispose();
  });

  testWidgets('pauses and resumes an approved memory explicitly', (
    tester,
  ) async {
    final repository = _MemoryFactRepository()
      ..seed(_fact(id: 'memory', status: MemoryStatus.active));
    final controller = _controller(repository);

    await tester.pumpWidget(subject(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('memory.deactivate.memory')));
    await tester.pumpAndSettle();

    expect(find.text('사용 안 함'), findsOneWidget);
    expect(find.byKey(const Key('memory.activate.memory')), findsOneWidget);
    expect(await repository.findById('memory'), isNotNull);

    await tester.tap(find.byKey(const Key('memory.activate.memory')));
    await tester.pumpAndSettle();

    expect(find.text('사용 중'), findsOneWidget);
    expect(find.byKey(const Key('memory.deactivate.memory')), findsOneWidget);
    expect(repository.saveCalls, 2);
  });

  testWidgets('edits wording and deletes only after user confirmation', (
    tester,
  ) async {
    final repository = _MemoryFactRepository()
      ..seed(_fact(id: 'memory', status: MemoryStatus.active));
    final controller = _controller(repository);

    await tester.pumpWidget(subject(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('memory.edit.memory')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('memory.edit.field')),
      '사용자는 저녁 산책을 좋아한다.',
    );
    await tester.tap(find.byKey(const Key('memory.edit.save')));
    await tester.pumpAndSettle();

    expect(find.text('사용자는 저녁 산책을 좋아한다.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('memory.delete.memory')));
    await tester.pumpAndSettle();
    expect(find.text('이 기억을 삭제할까요?'), findsOneWidget);
    expect(repository.deleteCalls, 0);

    await tester.tap(find.byKey(const Key('memory.delete.confirm')));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, 1);
    expect(find.byKey(const Key('memory.empty')), findsOneWidget);
  });

  testWidgets('shows redacted feedback for every mutation failure', (
    tester,
  ) async {
    final candidate = _fact(id: 'candidate');
    final active = _fact(id: 'active', status: MemoryStatus.active);
    final repository = _MemoryFactRepository()
      ..seed(candidate)
      ..seed(active);
    final controller = _controller(repository);

    await tester.pumpWidget(subject(controller));
    await tester.pumpAndSettle();

    repository.saveError = StateError('raw approval fact is private');
    await tester.tap(find.byKey(const Key('memory.approve.candidate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('memory.approve.confirm')));
    await tester.pumpAndSettle();
    expect(find.text('기억을 승인하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(find.textContaining('raw approval fact is private'), findsNothing);

    ScaffoldMessenger.of(tester.element(find.byType(MemoryManagementScreen)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    repository.saveError = StateError('raw status change fact is private');
    await tester.tap(find.byKey(const Key('memory.deactivate.active')));
    await tester.pumpAndSettle();
    expect(find.text('기억 사용을 중지하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(
      find.textContaining('raw status change fact is private'),
      findsNothing,
    );

    ScaffoldMessenger.of(tester.element(find.byType(MemoryManagementScreen)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    repository.saveError = StateError('raw edited fact is private');
    await tester.tap(find.byKey(const Key('memory.edit.active')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('memory.edit.field')),
      '수정할 문장',
    );
    await tester.tap(find.byKey(const Key('memory.edit.save')));
    await tester.pumpAndSettle();
    expect(find.text('기억을 수정하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(find.textContaining('raw edited fact is private'), findsNothing);

    ScaffoldMessenger.of(tester.element(find.byType(MemoryManagementScreen)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    repository
      ..saveError = null
      ..deleteError = StateError('raw source message IDs are private');
    await tester.tap(find.byKey(const Key('memory.delete.active')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('memory.delete.confirm')));
    await tester.pumpAndSettle();
    expect(find.text('기억을 삭제하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(
      find.textContaining('raw source message IDs are private'),
      findsNothing,
    );
  });

  testWidgets('validates an empty edit without mutating stored data', (
    tester,
  ) async {
    final repository = _MemoryFactRepository()
      ..seed(_fact(id: 'memory', status: MemoryStatus.active));
    final controller = _controller(repository);

    await tester.pumpWidget(subject(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('memory.edit.memory')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('memory.edit.field')), '   ');
    await tester.tap(find.byKey(const Key('memory.edit.save')));
    await tester.pump();

    expect(find.text('기억할 문장을 입력해 주세요.'), findsOneWidget);
    expect(repository.saveCalls, 0);
  });

  testWidgets('fits and scrolls on a 320 by 568 viewport without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final longFact = List.filled(25, '아주 긴 기억 문장').join(' ');
    final repository = _MemoryFactRepository();
    for (var index = 0; index < 7; index++) {
      repository.seed(
        _fact(
          id: 'memory-$index',
          fact: longFact,
          status: index.isEven ? MemoryStatus.active : MemoryStatus.inactive,
        ),
      );
    }

    await tester.pumpWidget(subject(_controller(repository)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byKey(const Key('memory.list')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    final scrollable = find.descendant(
      of: find.byKey(const Key('memory.list')),
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      greaterThan(0),
    );
    expect(tester.takeException(), isNull);
  });
}

MemoryManagementController _controller(_MemoryFactRepository repository) {
  return MemoryManagementController(
    repository: repository,
    utcNow: () => DateTime.utc(2026, 10, 4, 15),
  );
}

MemoryFact _fact({
  required String id,
  String fact = '사용자는 산책을 좋아한다.',
  MemoryStatus status = MemoryStatus.candidate,
  MemorySensitivity sensitivity = MemorySensitivity.standard,
}) {
  return MemoryFact(
    id: id,
    fact: fact,
    sourceMessageIds: const ['message-private-source'],
    category: MemoryCategory.preference,
    sensitivity: sensitivity,
    status: status,
    createdAtUtc: DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
  );
}

final class _MemoryFactRepository implements MemoryFactRepository {
  _MemoryFactRepository({this._loads});

  final Map<String, MemoryFact> _facts = <String, MemoryFact>{};
  final List<Future<List<MemoryFact>> Function()>? _loads;
  Object? saveError;
  Object? deleteError;
  int listAllCalls = 0;
  int saveCalls = 0;
  int deleteCalls = 0;

  void seed(MemoryFact fact) {
    _facts[fact.id] = fact;
  }

  @override
  Future<void> deleteById(String id) async {
    deleteCalls += 1;
    if (deleteError case final error?) {
      throw error;
    }
    _facts.remove(id);
  }

  @override
  Future<MemoryFact?> findById(String id) async => _facts[id];

  @override
  Future<List<MemoryFact>> listAll() {
    listAllCalls += 1;
    final loads = _loads;
    if (loads != null && loads.isNotEmpty) {
      return loads.removeAt(0)();
    }
    return Future.value(_facts.values.toList(growable: false));
  }

  @override
  Future<List<MemoryFact>> listBySourceMessageId(String sourceMessageId) async {
    return _facts.values
        .where((fact) => fact.sourceMessageIds.contains(sourceMessageId))
        .toList(growable: false);
  }

  @override
  Future<void> save(MemoryFact fact) async {
    saveCalls += 1;
    if (saveError case final error?) {
      throw error;
    }
    _facts[fact.id] = fact;
  }
}
