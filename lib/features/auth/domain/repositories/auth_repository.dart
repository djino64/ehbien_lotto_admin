import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/auth/domain/entities/auth_session_entity.dart';
abstract class AuthRepository {
  Stream<AuthSessionEntity?> get authStateChanges;
  Future<EitherFailure<AuthSessionEntity>> signInWithEmail({required String email, required String password});
  Future<EitherVoid> signOut();
  Future<EitherVoid> sendPasswordResetEmail(String email);
}
