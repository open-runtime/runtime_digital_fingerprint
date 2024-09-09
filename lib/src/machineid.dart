import 'dart:io' show Platform, Process, ProcessResult;

/// regex for 8-4-4-4-12 format of UUID
///
/// https://en.wikipedia.org/wiki/Universally_unique_identifier#Textual_representation
const String _uuidRegexStr = r'[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}';

/// A unique identifier for this machine.
abstract class MachineId {

  /// A unique identifier for this machine.
  ///
  /// Throws [StateError] on error.
  ///
  /// See README for implementation details
  static Future<String> machineId() async {

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

      ProcessResult result = await Process.run('ioreg', ['-rd1', '-c', 'IOPlatformExpertDevice']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // +-o  <...>
      //{
      // ...
      //  "IOPlatformUUID" = "XXX"
      //}
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp('"IOPlatformUUID" = "($_uuidRegexStr)"');

      RegExpMatch? match = regExp.firstMatch(stdout);

      if (match == null) {
        throw StateError('match is null');
      }

      if (match.groupCount != 1) {
        throw StateError('match.groupCount is not 1: ${match.groupCount}');
      }

      String? m = match.group(1);

      if (m == null) {
        throw StateError('match group 1 is null');
      }

      return m;

    } else if (Platform.isLinux) {

      ProcessResult result = await Process.run('cat', ['/var/lib/dbus/machine-id']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp(r'([a-z0-9]{32})');

      RegExpMatch? match = regExp.firstMatch(stdout);

      if (match == null) {
        throw StateError('match is null');
      }

      if (match.groupCount != 1) {
        throw StateError('match.groupCount is not 1: ${match.groupCount}');
      }

      String? m = match.group(1);

      if (m == null) {
        throw StateError('match group 1 is null');
      }

      return m;

    } else if (Platform.isWindows) {

      ProcessResult result = await Process.run('reg', ['query', r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography', '/v', 'MachineGuid']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp('MachineGuid    REG_SZ    ($_uuidRegexStr)');

      RegExpMatch? match = regExp.firstMatch(stdout);

      if (match == null) {
        throw StateError('match is null');
      }

      if (match.groupCount != 1) {
        throw StateError('match.groupCount is not 1: ${match.groupCount}');
      }

      String? m = match.group(1);

      if (m == null) {
        throw StateError('match group 1 is null');
      }

      return m;

    } else {
      throw UnsupportedError('unhandled platform: ${Platform.operatingSystem}');
    }
  }
}













