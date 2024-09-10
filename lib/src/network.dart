import 'dart:io' show Platform, Process, ProcessResult;

import 'regexp_apis.dart';

/// regex for 123.123.123.123 format of IP address
const String _ipAddressRegexStr = r'\d+.\d+.\d+.\d+';

/// regex for 01:23:45:67:89:AB format of MAC address
///
/// https://en.wikipedia.org/wiki/MAC_address#Notational_conventions
const String _macAddressRegexStr = r'[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}';

/// regex for 01-23-45-67-89-AB format of MAC address
const String _macAddressHyphensRegexStr = r'[a-zA-Z0-9]{2}-[a-zA-Z0-9]{2}-[a-zA-Z0-9]{2}-[a-zA-Z0-9]{2}-[a-zA-Z0-9]{2}-[a-zA-Z0-9]{2}';

/// Collection of network information about this machine.
abstract class Network {

  /// The IP address of this machine.
  ///
  /// Returns a [String] in `123.123.123.123` format.
  ///
  /// Throws [StateError] on error.
  ///
  /// See README for implementation details.
  static Future<String> iPAddress() async {

    //
    // the current possible values of Platform.operatingSystem are:
    // "android"
    // "fuchsia"
    // "ios"
    // "linux"
    // "macos"
    // "windows"
    //
    // This list may change over time so platform-specific logic should be
    // guarded by the appropriate boolean getter e.g. [isMacOS].
    //
    // from [Platform.operatingSystem]
    //
    if (Platform.isMacOS) {

      String service = await _preferredMacOSNetworkService();

      ProcessResult result = await Process.run('networksetup', ['-getinfo', service]);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // IP address: 192.168.0.174
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp('IP address:\\s*($_ipAddressRegexStr)');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isLinux) {

      ProcessResult result = await Process.run('ifconfig', []);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // inet 10.211.55.3  netmask 255.255.255.0  broadcast 10.211.55.255
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp('inet\\s*($_ipAddressRegexStr)');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isWindows) {

      ProcessResult result = await Process.run('ipconfig', []);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      //    IPv4 Address. . . . . . . . . . . : 10.211.55.4
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp('IPv4 Address[\\s.]*:\\s*($_ipAddressRegexStr)');

      return regExp.onlyMatch(stdout);

    } else {

      throw UnsupportedError('unhandled platform');
    }
  }

  /// The MAC address of this machine.
  ///
  /// Returns a [String] in `01:23:45:67:89:AB` format.
  ///
  /// Throws [StateError] on error.
  ///
  /// See README for implementation details.
  static Future<String> macAddress() async {

    if (Platform.isMacOS) {

      String service = await _preferredMacOSNetworkService();

      ProcessResult result = await Process.run('networksetup', ['-getmacaddress', service]);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // Ethernet Address: 60:3e:5f:3d:51:e2 (Hardware Port: Wi-Fi)
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp('Ethernet Address:\\s*($_macAddressRegexStr)');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isLinux) {

      ProcessResult result = await Process.run('ifconfig', []);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      //         ether 00:1c:42:a1:d2:a8  txqueuelen 1000  (Ethernet)
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp('ether\\s($_macAddressRegexStr)');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isWindows) {

      ProcessResult result = await Process.run('getmac', ['/FO', 'LIST']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // Physical Address: 00-1C-42-90-55-1C
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      //
      // getmac command returns 01-23-45-67-89-AB format, so convert to
      // 01:23:45:67:89:AB before returning
      //

      RegExp regExp = RegExp('Physical Address:\\s*($_macAddressHyphensRegexStr)');

      String match = regExp.onlyMatch(stdout);

      return match.replaceAll("-", ":");

    } else {
      throw UnsupportedError('unhandled platform');
    }
  }

  static Future<String> _preferredMacOSNetworkService() async {

    ProcessResult result = await Process.run('networksetup', ['-listallnetworkservices']);

    // result.stdout is actually dynamic
    String stdout = result.stdout;

    List<String> services = stdout.split('\n');

    if (services.isEmpty) {
      throw StateError('networksetup returned no output');
    }

    if (services[0] == 'An asterisk (*) denotes that a network service is disabled.') {
      services.removeAt(0);
    }

    if (services.isEmpty) {
      throw StateError('networksetup returned bad output');
    }

    String service;
    if (services.contains('Wi-Fi')) {
      service = 'Wi-Fi';
    } else if (services.contains('Ethernet')) {
      service = 'Ethernet';
    } else {
      throw StateError('Could not find Wi-Fi or Ethernet');
    }

    return service;
  }
}













