// lib/features/tirages/presentation/providers/tirages_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:ehbien_lotto_admin/features/tirages/data/datasources/tirages_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/tirages/data/repositories/tirages_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/result_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/repositories/tirages_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final tiragesDatasourceProvider = Provider<TiragesRemoteDatasource>((ref) {
  return TiragesRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final tiragesRepositoryProvider = Provider<TiragesRepository>((ref) {
  return TiragesRepositoryImpl(ref.watch(tiragesDatasourceProvider));
});

// ── Stream tous les tirages ───────────────────────────────────
final tiragesStreamProvider = StreamProvider<List<TirageEntity>>((ref) {
  return ref.watch(tiragesRepositoryProvider).watchAllTirages();
});

// ── Stream tirages ouverts ────────────────────────────────────
final tiragesOuvertsProvider =
    StreamProvider<List<TirageEntity>>((ref) {
  return ref
      .watch(tiragesRepositoryProvider)
      .watchTiragesByStatus(TirageStatus.ouvert);
});

// ── Tirage par ID ─────────────────────────────────────────────
final tirageByIdProvider =
    FutureProvider.family<TirageEntity?, String>((ref, id) async {
  final result =
      await ref.watch(tiragesRepositoryProvider).getTirageById(id);
  return result.fold((_) => null, (t) => t);
});

// ── Résultat par tirage ───────────────────────────────────────
final resultByTirageProvider =
    FutureProvider.family<ResultEntity?, String>((ref, tirageId) async {
  final result = await ref
      .watch(tiragesRepositoryProvider)
      .getResultByTirageId(tirageId);
  return result.fold((_) => null, (r) => r);
});

// ── Notifier ──────────────────────────────────────────────────
class TiragesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createTirage({
    required String nom,
    required String type,
    required DateTime heurePrevu,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(tiragesRepositoryProvider)
        .createTirage(nom: nom, type: type, heurePrevu: heurePrevu);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> updateTirage({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(tiragesRepositoryProvider)
        .updateTirage(id: id, data: data);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> updateStatus(String id, TirageStatus status) async {
    state = const AsyncLoading();
    final result = await ref
        .read(tiragesRepositoryProvider)
        .updateTirageStatus(id, status);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> publishResult({
    required String tirageId,
    required List<String> boules,
  }) async {
    state = const AsyncLoading();
    final session = ref.read(authSessionProvider).valueOrNull;
    final result = await ref
        .read(tiragesRepositoryProvider)
        .publishResult(
          tirageId:    tirageId,
          boules:      boules,
          publishedBy: session?.uid ?? '',
        );
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }
}

final tiragesNotifierProvider =
    AsyncNotifierProvider<TiragesNotifier, void>(TiragesNotifier.new);