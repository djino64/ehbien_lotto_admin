import 'package:cloud_firestore/cloud_firestore.dart';
class AppDateUtils {
  AppDateUtils._();
  static Timestamp startOfDay(DateTime date) =>
      Timestamp.fromDate(DateTime(date.year, date.month, date.day));
  static Timestamp endOfDay(DateTime date) =>
      Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));
  static Timestamp startOfMonth(DateTime date) =>
      Timestamp.fromDate(DateTime(date.year, date.month, 1));
  static Timestamp endOfMonth(DateTime date) =>
      Timestamp.fromDate(DateTime(date.year, date.month + 1, 0, 23, 59, 59));
}
