import 'dart:io' show Platform;

import 'package:runtime_digital_fingerprint/runtime_digital_fingerprint.dart';
import 'package:test/test.dart';

/// Run MachineId tests
///
/// Run on GitHub Actions to test multiple platforms.
void main() {

  group('MachineId test group', () {

    setUp(() {
      
    });

    //
    // Tests that machineId() returns a string with the expected pattern for each platform.
    //
    // This is an implementation detail but is useful to test.
    //
    test('machineId test', () async {

      // regex for 8-4-4-4-12 format of UUID
      //
      // https://en.wikipedia.org/wiki/Universally_unique_identifier#Textual_representation
      const String uuidRegexStr = r'[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}';

      RegExp uuidRegex = RegExp('^$uuidRegexStr\$');

      String res = await MachineId.machineId();

      if (Platform.isLinux) {

        //
        // machineId on Linux does not follow UUID pattern
        //

        RegExp regExp = RegExp(r'^[a-z0-9]{32}$');

        expect(regExp.hasMatch(res), true);

      } else if (Platform.isWindows) {

        expect(uuidRegex.hasMatch(res), true);

      } else if (Platform.isMacOS) {

        expect(uuidRegex.hasMatch(res), true);

      } else {
        fail('unhandled platform');
      }

    });
  });
}
