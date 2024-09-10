import 'dart:io' show Platform, Process, ProcessResult;

import 'memory_amount.dart';
import 'regexp_apis.dart';

/// Collection of hardware information about this machine.
abstract class Hardware {

  /// The physical memory installed in this machine.
  ///
  /// Not intended to be used for performance optimization.
  ///
  /// Returns [MemoryAmount] that describes the amount of physical memory.
  ///
  /// Throws [StateError] on error.
  ///
  /// See README for implementation details.
  static Future<MemoryAmount> physicalMemory() async {

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

      ProcessResult result = await Process.run('system_profiler', ['SPHardwareDataType']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // Hardware:
      //
      //     Hardware Overview:
      //
      //       ...
      //       Memory: 128 GB
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp(r'Memory:\s*(\d+) ([a-zA-Z]+)\n');

      RegExpMatch? match = regExp.firstMatch(stdout);

      if (match == null) {
        throw StateError('match is null');
      }

      if (match.groupCount != 2) {
        throw StateError('match.groupCount is not 2: ${match.groupCount}');
      }

      String? valueStr = match.group(1);

      if (valueStr == null) {
        throw StateError('match group 1 is null');
      }

      String? unitStr = match.group(2);

      if (unitStr == null) {
        throw StateError('match group 2 is null');
      }

      int value = int.parse(valueStr);

      MemoryUnit unit = MemoryUnit.parse(unitStr);

      return MemoryAmount(value, unit);

    } else if (Platform.isLinux) {

      ProcessResult result = await Process.run('cat', ['/proc/meminfo']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // MemTotal:        1994356 kB
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp(r'MemTotal:\s*(\d+) ([a-zA-Z]+)');

      RegExpMatch? match = regExp.firstMatch(stdout);

      if (match == null) {
        throw StateError('match is null');
      }

      if (match.groupCount != 2) {
        throw StateError('match.groupCount is not 2: ${match.groupCount}');
      }

      String? valueStr = match.group(1);

      if (valueStr == null) {
        throw StateError('match group 1 is null');
      }

      String? unitStr = match.group(2);

      if (unitStr == null) {
        throw StateError('match group 2 is null');
      }

      int value = int.parse(valueStr);

      MemoryUnit unit = MemoryUnit.parse(unitStr);

      return MemoryAmount(value, unit);

    } else if (Platform.isWindows) {

      ProcessResult result = await Process.run('systeminfo', []);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // Total Physical Memory: 8,187 MB
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp(r'Total Physical Memory:\s*([0-9,]+) ([a-zA-Z]+)');

      RegExpMatch? match = regExp.firstMatch(stdout);

      if (match == null) {
        throw StateError('match is null');
      }

      if (match.groupCount != 2) {
        throw StateError('match.groupCount is not 2: ${match.groupCount}');
      }

      String? valueStr = match.group(1);

      if (valueStr == null) {
        throw StateError('match group 1 is null');
      }

      String? unitStr = match.group(2);

      if (unitStr == null) {
        throw StateError('match group 2 is null');
      }

      //
      // valueStr may have commas, so remove before parsing
      //

      int value = int.parse(valueStr.replaceAll(',', ''));

      MemoryUnit unit = MemoryUnit.parse(unitStr);

      return MemoryAmount(value, unit);

    } else {
      throw UnsupportedError('unhandled platform');
    }
  }

  /// The GPU installed in this machine.
  ///
  /// Not intended to be used for performance optimization.
  ///
  /// Returns [String] that describes the GPU or `null` if a GPU could not be
  /// determined.
  ///
  /// Throws [StateError] on error.
  ///
  /// See README for implementation details.
  static Future<String?> gpu() async {

    if (Platform.isMacOS) {

      ProcessResult result = await Process.run('system_profiler', ['SPDisplaysDataType']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      //     Apple M3 Max:
      //
      //       Chipset Model: Apple M3 Max
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      if (stdout.isEmpty) {
        return null;
      }

      RegExp regExp = RegExp(r'Chipset Model:\s*(.*)\n');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isLinux) {

      ProcessResult result = await Process.run('lspci', []);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // 00:0a.0 VGA compatible controller: Red Hat, Inc. Virtio 1.0 GPU (rev 01)
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      if (stdout.isEmpty) {
        return null;
      }

      RegExp regExp = RegExp(r'VGA compatible controller:\s*(.*)\n');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isWindows) {

      ProcessResult result = await Process.run('wmic', ['path', 'win32_VideoController', 'get', 'name']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // Name
      // Parallels Display Adapter (WDDM)
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      if (stdout.isEmpty) {
        return null;
      }

      RegExp regExp = RegExp(r'Name\s*\r\r\n(.*)\s*\r\r\n');

      return regExp.onlyMatch(stdout);

    } else {
      throw UnsupportedError('unhandled platform');
    }
  }

  /// The CPU installed in this machine.
  ///
  /// Not intended to be used for performance optimization.
  ///
  /// Returns [String] that describes the CPU.
  ///
  /// Throws [StateError] on error.
  ///
  /// See README for implementation details.
  static Future<String> cpu() async {

    if (Platform.isMacOS) {

      ProcessResult result = await Process.run('system_profiler', ['SPHardwareDataType']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      //       Chip: Apple M3 Max
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp(r'Chip:\s*(.*)\n');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isLinux) {

      ProcessResult result = await Process.run('lscpu', []);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      //   Model name:             -
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp(r'Model name:\s*(.*)\n');

      return regExp.onlyMatch(stdout);

    } else if (Platform.isWindows) {

      ProcessResult result = await Process.run('wmic', ['cpu', 'get', 'name']);

      if (result.exitCode != 0) {
        throw StateError('Unexpected exit code. exitCode: ${result.exitCode} stderr: ${result.stderr} stdout: ${result.stdout}');
      }

      // output is something like:
      //
      // Name
      // Apple Silicon
      //

      // result.stdout is actually dynamic
      String stdout = result.stdout;

      RegExp regExp = RegExp(r'Name\s*\r\r\n(.*)\s*\r\r\n');

      return regExp.onlyMatch(stdout);

    } else {
      throw UnsupportedError('unhandled platform');
    }
  }
}













