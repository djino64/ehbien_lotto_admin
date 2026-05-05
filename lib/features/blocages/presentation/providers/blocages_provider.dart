// lib/features/blocages/presentation/providers/blocages_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:ehbien_lotto_admin/features/blocages/data/datasources/blocages_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/blocages/domain/entities/blocage_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final blocagesDatasourceProvider =
    Provider<BlocagesRemoteDatasource>((ref) {
  return BlocagesRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Stream tous les blocages ──────────────────────────────────
final blocagesStreamProvider =
    StreamProvider<List<BlocageEntity>>((ref) {
  return ref
      .watch(blocagesDatasourceProvider)
      .watchAllBlocages()
      .map((list) => list.map((m) => m.toEntity()).toList());
});

// ── Stream blocages par agent ─────────────────────────────────
final blocagesByAgentProvider =
    StreamProvider.family<List<BlocageEntity>, String>((ref, agentId) {
  return ref
      .watch(blocagesDatasourceProvider)
      .watchBlocagesByAgent(agentId)
      .map((list) => list.map((m) => m.toEntity()).toList());
});

// ── Filtre actifs seulement ───────────────────────────────────
final blocagesActifsProvider = Provider<List<BlocageEntity>>((ref) {
  final all = ref.watch(blocagesStreamProvider).valueOrNull ?? [];
  return all.where((b) => b.isActive).toList();
});

// ── Notifier ──────────────────────────────────────────────────
class BlocagesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createBlocage({
    required String boule,
    String? typeJeu,
    String? agentId,
    String? succursaleId,
    String? tirageId,
    required bool global,
    required bool permanent,
    DateTime? expiresAt,
  }) async {
    state = const AsyncLoading();
    try {
      final session = ref.read(authSessionProvider).valueOrNull;
      await ref.read(blocagesDatasourceProvider).createBlocage(
        boule:        boule,
        typeJeu:      typeJeu,
        agentId:      agentId,
        succursaleId: succursaleId,
        tirageId:     tirageId,
        global:       global,
        permanent:    permanent,
        expiresAt:    expiresAt,
        createdBy:    session?.uid ?? '',
      );
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }

  Future<String?> deleteBlocage(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(blocagesDatasourceProvider).deleteBlocage(id);
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }
}

final blocagesNotifierProvider =
    AsyncNotifierProvider<BlocagesNotifier, void>(BlocagesNotifier.new);