import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/auth/domain/entities/auth_session_entity.dart';
import 'package:ehbien_lotto_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:ehbien_lotto_admin/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _ds;
  AuthRepositoryImpl(this._ds);
  @override
  Stream<AuthSessionEntity?> get authStateChanges => _ds.authStateChanges.map((m) => m?.toEntity());
  @override
  Future<EitherFailure<AuthSessionEntity>> signInWithEmail({required String email, required String password}) async {
    try { return Right(await _ds.signInWithEmail(email, password).then((m) => m.toEntity())); }
    catch (e) { return Left(ErrorHandler.handle(e)); }
  }
  @override
  Future<EitherVoid> signOut() async {
    try { await _ds.signOut(); return const Right(null); }
    catch (e) { return Left(ErrorHandler.handle(e)); }
  }
  @override
  Future<EitherVoid> sendPasswordResetEmail(String email) async {
    try { await _ds.sendPasswordResetEmail(email); return const Right(null); }
    catch (e) { return Left(ErrorHandler.handle(e)); }
  }
}
