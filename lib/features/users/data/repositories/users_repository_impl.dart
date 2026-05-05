// lib/features/users/data/repositories/users_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/users/data/datasources/users_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/users/domain/entities/user_entity.dart';
import 'package:ehbien_lotto_admin/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDatasource _datasource;

  UsersRepositoryImpl(this._datasource);

  @override
  Stream<List<UserEntity>> watchAllUsers() {
    return _datasource
        .watchAllUsers()
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<EitherFailure<UserEntity>> getUserById(String uid) async {
    try {
      final model = await _datasource.getUserById(uid);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateUserStatus(
      String uid, UserStatus status) async {
    try {
      await _datasource.updateUserStatus(uid, status.name);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateUserRole(String uid, UserRole role) async {
    try {
      await _datasource.updateUserRole(uid, role.name);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> deleteUser(String uid) async {
    try {
      await _datasource.deleteUser(uid);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}