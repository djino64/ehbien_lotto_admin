extension StringExt on String {
  bool get isBlank    => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;
  String get capitalized => isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  bool isValidPhone() => RegExp(r'^\+?[\d\s\-]{8,15}$').hasMatch(trim());
  bool isValidEmail() => RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(trim());
  String truncate(int max, {String ellipsis = '...'}) => length <= max ? this : '${substring(0, max)}$ellipsis';
}
extension NullableStringExt on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  String get orEmpty => this ?? '';
}
