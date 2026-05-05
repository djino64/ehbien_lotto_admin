import 'dart:math';
import 'package:uuid/uuid.dart';
class CodeGenerator {
  CodeGenerator._();
  static const _uuid  = Uuid();
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static String ticketCode() {
    final r = Random.secure();
    final p1 = List.generate(4, (_) => _chars[r.nextInt(_chars.length)]).join();
    final p2 = List.generate(4, (_) => _chars[r.nextInt(_chars.length)]).join();
    return '$p1-$p2';
  }
  static String firestoreId() => _uuid.v4();
  static String numericCode(int length) =>
      List.generate(length, (_) => Random.secure().nextInt(10)).join();
}
