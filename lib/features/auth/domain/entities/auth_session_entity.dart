import 'package:equatable/equatable.dart';
class AuthSessionEntity extends Equatable {
  final String uid;
  final String email;
  final String role;
  final bool emailVerified;
  final DateTime? lastSignIn;
  const AuthSessionEntity({required this.uid, required this.email, required this.role, required this.emailVerified, this.lastSignIn});
  bool get isAdmin => role == 'admin';
  @override
  List<Object?> get props => [uid, email, role, emailVerified, lastSignIn];
}
