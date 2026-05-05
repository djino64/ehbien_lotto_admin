// lib/features/users/domain/repositories/users_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/users/domain/entities/user_entity.dart';

abstract interface class UsersRepository {
  Stream<List<UserEntity>> watchAllUsers();
  Future<EitherFailure<UserEntity>> getUserById(String uid);
  Future<EitherVoid> updateUserStatus(String uid, UserStatus status);
  Future<EitherVoid> updateUserRole(String uid, UserRole role);
  Future<EitherVoid> deleteUser(String uid);
}