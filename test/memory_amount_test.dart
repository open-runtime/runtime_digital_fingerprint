import 'package:runtime_digital_fingerprint/runtime_digital_fingerprint.dart';
import 'package:test/test.dart';

/// Run MemoryAmount tests
void main() {

  group('MemoryAmount test group', () {

    setUp(() {

    });

    test('MemoryUnit test', () async {

      MemoryUnit unit = MemoryUnit.parse('kB');

      expect(unit, MemoryUnit.kilo);

    });

    test('MemoryAmount test', () async {

      MemoryAmount amount = MemoryAmount(4, MemoryUnit.mega);

      expect(amount.toString(), '4 MB');

    });
  });
}
