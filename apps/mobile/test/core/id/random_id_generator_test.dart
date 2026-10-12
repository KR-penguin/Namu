import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/id/random_id_generator.dart';

void main() {
  test('creates UUID v4 identifiers with the RFC variant bits', () {
    final generator = RandomIdGenerator(random: Random(42));

    final value = generator.next();

    expect(
      value,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('does not repeat identifiers across a representative sample', () {
    final generator = RandomIdGenerator(random: Random(7));

    final values = List.generate(1000, (_) => generator.next());

    expect(values.toSet(), hasLength(values.length));
  });
}
