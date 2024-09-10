
/// A combination of a value and unit representing an amount of memory
///
/// Calling [toString] gives a human-friendly string e.g., '7 GB'
class MemoryAmount {

  /// The integer number of units in this memory amount
  final int value;
  /// The unit of memory in this amount
  final MemoryUnit unit;

  MemoryAmount(this.value, this.unit);

  @override
  String toString() {
    return '$value $unit';
  }
}

/// Multiple-byte units used in describing memory amounts
///
/// https://en.wikipedia.org/wiki/Byte#Multiple-byte_units
enum MemoryUnit {

  /// kB
  kilo,
  /// MB
  mega,
  /// GB
  giga,
  /// MiB
  mebi,
  /// GiB
  gibi;

  /// Parses a [MemoryUnit] from a [String]
  static MemoryUnit parse(String unitStr) {
    switch (unitStr) {
      case 'MB':
        return MemoryUnit.mega;
      case 'kB':
        return MemoryUnit.kilo;
      case 'GB':
        return MemoryUnit.giga;
      case 'MiB':
        return MemoryUnit.mebi;
      case 'GiB':
        return MemoryUnit.gibi;
      default:
        throw StateError('unrecognized unit string: $unitStr');
    }
  }

  @override
  String toString() {
    switch (this) {
      case kilo:
        return 'kB';
      case mega:
        return 'MB';
      case giga:
        return 'GB';
      case mebi:
        return 'MiB';
      case gibi:
        return 'GiB';
    }
  }
}

