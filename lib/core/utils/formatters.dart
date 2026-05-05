import 'package:intl/intl.dart';
class AppFormatters {
  AppFormatters._();
  static final _currency = NumberFormat('#,##0.00', 'fr_HT');
  static final _compact  = NumberFormat.compact(locale: 'fr');
  static String currency(double amount) => '${_currency.format(amount)} G';
  static String compact(num value)      => _compact.format(value);
  static String phone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    return d.length == 8 ? '${d.substring(0,4)}-${d.substring(4)}' : raw;
  }
}
