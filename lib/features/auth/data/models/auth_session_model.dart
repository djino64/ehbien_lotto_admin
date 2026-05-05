import 'package:firebase_auth/firebase_auth.dart';
import 'package:ehbien_lotto_admin/features/auth/domain/entities/auth_session_entity.dart';
class AuthSessionModel {
  final String uid;
  final String email;
  final String role;
  final bool emailVerified;
  final DateTime? lastSignIn;
  const AuthSessionModel({required this.uid, required this.email, required this.role, required this.emailVerified, this.lastSignIn});
  factory AuthSessionModel.fromFirebase(User user, String role) => AuthSessionModel(
    uid: user.uid, email: user.email ?? '', role: role,
    emailVerified: user.emailVerified, lastSignIn: user.metadata.lastSignInTime,
  );
  AuthSessionEntity toEntity() => AuthSessionEntity(uid: uid, email: email, role: role, emailVerified: emailVerified, lastSignIn: lastSignIn);
}
