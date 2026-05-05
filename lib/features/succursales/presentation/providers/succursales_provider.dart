// lib/features/succursales/presentation/providers/succursales_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/succursales/data/datasources/succursales_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/succursales/data/repositories/succursales_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/succursales/domain/entities/succursale_entity.dart';
import 'package:ehbien_lotto_admin/features/succursales/domain/repositories/succursales_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final succursalesDatasourceProvider =
    Provider<SuccursalesRemoteDatasource>((ref) {
  return SuccursalesRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final succursalesRepositoryProvider =
    Provider<SuccursalesRepository>((ref) {
  return SuccursalesRepositoryImpl(
    ref.watch(succursalesDatasourceProvider),
  );
});

// ── Stream toutes les succursales ─────────────────────────────
final succursalesStreamProvider =
    StreamProvider<List<SuccursaleEntity>>((ref) {
  return ref
      .watch(succursalesRepositoryProvider)
      .watchAllSuccursales();
});

// ── Succursale par ID ─────────────────────────────────────────
final succursaleByIdProvider =
    FutureProvider.family<SuccursaleEntity?, String>((ref, id) async {
  final result = await ref
      .watch(succursalesRepositoryProvider)
      .getSuccursaleById(id);
  return result.fold((_) => null, (s) => s);
});

// ── Map ID → Nom ──────────────────────────────────────────────
final succursalesMapProvider = Provider<Map<String, String>>((ref) {
  final list = ref.watch(succursalesStreamProvider).valueOrNull ?? [];
  return {for (final s in list) s.id: s.nom};
});

// ── Notifier ──────────────────────────────────────────────────
class SuccursalesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> create({
    required String nom,
    required String adresse,
    String? telephone,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(succursalesRepositoryProvider)
        .createSuccursale(
          nom:       nom,
          adresse:   adresse,
          telephone: telephone,
        );
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  // Renommé en 'edit' pour éviter le conflit avec AsyncNotifier.update
  Future<String?> edit({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(succursalesRepositoryProvider)
        .updateSuccursale(id: id, data: data);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> updateStatus(
    String id,
    SuccursaleStatus status,
  ) async {
    state = const AsyncLoading();
    final result = await ref
        .read(succursalesRepositoryProvider)
        .updateSuccursaleStatus(id, status);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> delete(String id) async {
    state = const AsyncLoading();
    final result = await ref
        .read(succursalesRepositoryProvider)
        .deleteSuccursale(id);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }
}

final succursalesNotifierProvider =
    AsyncNotifierProvider<SuccursalesNotifier, void>(
  SuccursalesNotifier.new,
);