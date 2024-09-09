import 'package:runtime_digital_fingerprint/runtime_digital_fingerprint.dart';
import 'package:test/test.dart';

/// Run Network tests
///
/// Run on GitHub Actions to test multiple platforms.
void main() {

  group('Network test group', () {

    setUp(() {

    });

    //
    // Tests that ipAddress() returns a string with the expected pattern.
    //
    test('IP address test', () async {

      /// regex for 000.000.000.000 format of IP address
      const String ipAddressRegexStr = r'\d+.\d+.\d+.\d+';

      RegExp ipAddressRegex = RegExp('^$ipAddressRegexStr\$');

      String ipAddress = await Network.iPAddress();

      expect(ipAddressRegex.hasMatch(ipAddress), true);

    });

    //
    // Tests that macAddress() returns a string with the expected pattern.
    //
    test('MAC address test', () async {

      /// regex for 01:23:45:67:89:AB format of MAC address
      ///
      /// https://en.wikipedia.org/wiki/MAC_address#Notational_conventions
      const String macAddressRegexStr = r'[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}';

      RegExp macAddressRegex = RegExp('^$macAddressRegexStr\$');

      String macAddress = await Network.macAddress();

      expect(macAddressRegex.hasMatch(macAddress), true);

    });
  });
}
