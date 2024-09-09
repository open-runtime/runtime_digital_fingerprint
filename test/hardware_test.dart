import 'package:runtime_digital_fingerprint/runtime_digital_fingerprint.dart';
import 'package:test/test.dart';

/// Run Hardware tests
///
/// Run on GitHub Actions to test multiple platforms.
void main() {

  group('Hardware test group', () {

    setUp(() {

    });

    //
    // Tests that cpu() does not throw any exceptions and is not empty string.
    //
    // Example values are:
    // AMD EPYC 7763 64-Core Processor
    // Apple M1 (Virtual)
    // Apple M3 Max
    //
    test('CPU test', () async {

      String cpu = await Hardware.cpu();

      expect(cpu, isNotEmpty);

    });

    //
    // Tests that physicalMemory() does not throw any exceptions.
    //
    test('memory test', () async {

      await Hardware.physicalMemory();

    });

    //
    // Tests that gpu() does not throw any exceptions and is not empty string.
    //
    // Examples values are:
    // null
    // Hyper-V virtual VGA
    // Microsoft Hyper-V Video
    // Apple M3 Max
    //
    test('GPU test', () async {

      String? gpu = await Hardware.gpu();

      //
      // ok if null
      //
      if (gpu == null) {
        return;
      }

      expect(gpu, isNotEmpty);

    });
  });
}
