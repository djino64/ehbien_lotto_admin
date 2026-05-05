import 'package:intl/intl.dart';
import 'package:ehbien_lotto_admin/core/constants/app_constants.dart';
extension DateTimeExt on DateTime {
  String get toDisplayDate     => DateFormat(AppConstants.dateFormat).format(this);
  String get toDisplayDateTime => DateFormat(AppConstants.dateTimeFormat).format(this);
  String get toDisplayTime     => DateFormat(AppConstants.timeFormat).format(this);
  bool get isToday {
    final n = DateTime.now();
    return year == n.year && month == n.month && day == n.day;
  }
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay   => DateTime(year, month, day, 23, 59, 59, 999);
}
