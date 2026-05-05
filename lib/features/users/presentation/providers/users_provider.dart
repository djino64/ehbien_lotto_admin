// lib/features/users/presentation/providers/users_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/users/data/datasources/users_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/users/data/repositories/users_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/users/domain/entities/user_entity.dart';
import 'package:ehbien_lotto_admin/features/users/domain/repositories/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final usersDatasourceProvider = Provider<UsersRemoteDatasource>((ref) {
  return UsersRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(ref.watch(usersDatasourceProvider));
});

// ── Stream tous les users ─────────────────────────────────────
final usersStreamProvider = StreamProvider<List<UserEntity>>((ref) {
  return ref.watch(usersRepositoryProvider).watchAllUsers();
});

// ── User par ID ───────────────────────────────────────────────
final userByIdProvider =
    FutureProvider.family<UserEntity?, String>((ref, uid) async {
  final result =
      await ref.watch(usersRepositoryProvider).getUserById(uid);
  return result.fold((_) => null, (u) => u);
});

// ── Notifier ──────────────────────────────────────────────────
class UsersNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> updateStatus(String uid, UserStatus status) async {
    state = const AsyncLoading();
    final result = await ref
        .read(usersRepositoryProvider)
        .updateUserStatus(uid, status);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> updateRole(String uid, UserRole role) async {
    state = const AsyncLoading();
    final result = await ref
        .read(usersRepositoryProvider)
        .updateUserRole(uid, role);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> removeUser(String uid) async {
    state = const AsyncLoading();
    final result =
        await ref.read(usersRepositoryProvider).deleteUser(uid);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }
}

final usersNotifierProvider =
    AsyncNotifierProvider<UsersNotifier, void>(UsersNotifier.new);