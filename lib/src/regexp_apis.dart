
/// Extension for RegExp
extension OnlyMatching on RegExp {

  /// Return the only match or throw [StateError]
  String onlyMatch(String input) {

    RegExpMatch? match = firstMatch(input);

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
  }
}
