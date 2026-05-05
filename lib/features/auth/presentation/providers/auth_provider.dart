import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/auth/domain/entities/auth_session_entity.dart';
import 'package:ehbien_lotto_admin/features/auth/domain/repositories/auth_repository.dart';

final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) =>
    AuthRemoteDatasourceImpl(auth: ref.watch(firebaseAuthProvider), firestore: ref.watch(firestoreProvider)));

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepositoryImpl(ref.watch(authDatasourceProvider)));

final authSessionProvider = StreamProvider<AuthSessionEntity?>((ref) =>
    ref.watch(authRepositoryProvider).authStateChanges);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}
  Future<String?> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithEmail(email: email, password: password);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }
  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
