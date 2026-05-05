import 'package:intl/intl.dart';
extension NumExt on num {
  String get toCurrency {
    final f = NumberFormat('#,##0.00', 'fr_HT');
    return '${f.format(this)} G';
  }
  String get toCompact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000)    return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }
}
