// lib/features/limits/presentation/providers/limits_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/limits/data/datasources/limits_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/limits/data/models/limit_model.dart';
import 'package:ehbien_lotto_admin/features/limits/domain/entities/limit_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final limitsDatasourceProvider =
    Provider<LimitsRemoteDatasource>((ref) {
  return LimitsRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Stream toutes les limites ─────────────────────────────────
final limitsStreamProvider = StreamProvider<List<LimitEntity>>((ref) {
  return ref
      .watch(limitsDatasourceProvider)
      .watchAllLimits()
      .map(
        (List<LimitModel> list) => list
            .map((LimitModel m) => m.toEntity())
            .toList(),
      );
});

// ── Stream limites par agent ──────────────────────────────────
final limitsByAgentProvider =
    StreamProvider.family<List<LimitEntity>, String>((ref, agentId) {
  return ref
      .watch(limitsDatasourceProvider)
      .watchLimitsByAgent(agentId)
      .map(
        (List<LimitModel> list) => list
            .map((LimitModel m) => m.toEntity())
            .toList(),
      );
});

// ── Limites globales ──────────────────────────────────────────
final globalLimitsProvider = Provider<List<LimitEntity>>((ref) {
  final all = ref.watch(limitsStreamProvider).valueOrNull ?? [];
  return all.where((l) => l.isGlobal).toList();
});

// ── Limites à risque (> 80%) ──────────────────────────────────
final limitsAtRiskProvider = Provider<List<LimitEntity>>((ref) {
  final all = ref.watch(limitsStreamProvider).valueOrNull ?? [];
  return all.where((l) => l.percentUsed >= 0.8).toList();
});

// ── Notifier ──────────────────────────────────────────────────
class LimitsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createLimit({
    String? agentId,
    String? tirageId,
    String? typeJeu,
    String? boule,
    required double maxParBoule,
    required double maxGlobal,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(limitsDatasourceProvider).createLimit(
        agentId:     agentId,
        tirageId:    tirageId,
        typeJeu:     typeJeu,
        boule:       boule,
        maxParBoule: maxParBoule,
        maxGlobal:   maxGlobal,
      );
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }

  Future<String?> updateLimit({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(limitsDatasourceProvider)
          .updateLimit(id: id, data: data);
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }

  Future<String?> deleteLimit(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(limitsDatasourceProvider).deleteLimit(id);
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return e.toString();
    }
  }
}

final limitsNotifierProvider =
    AsyncNotifierProvider<LimitsNotifier, void>(LimitsNotifier.new);