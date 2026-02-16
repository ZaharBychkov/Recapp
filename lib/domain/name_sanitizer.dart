class NameSanitizer {
  static String normalize(String input) {
    final trimmed = input.trim();
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }
}
