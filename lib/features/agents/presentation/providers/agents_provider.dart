// lib/features/agents/presentation/providers/agents_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/agents/data/datasources/agents_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/agents/data/repositories/agents_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';
import 'package:ehbien_lotto_admin/features/agents/domain/repositories/agents_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final agentsDatasourceProvider =
    Provider<AgentsRemoteDatasource>((ref) {
  return AgentsRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
    auth:      ref.watch(firebaseAuthProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final agentsRepositoryProvider = Provider<AgentsRepository>((ref) {
  return AgentsRepositoryImpl(ref.watch(agentsDatasourceProvider));
});

// ── Stream tous les agents ────────────────────────────────────
final agentsStreamProvider = StreamProvider<List<AgentEntity>>((ref) {
  return ref.watch(agentsRepositoryProvider).watchAllAgents();
});

// ── Stream agents par succursale ──────────────────────────────
final agentsBySuccursaleProvider =
    StreamProvider.family<List<AgentEntity>, String>(
        (ref, succursaleId) {
  return ref
      .watch(agentsRepositoryProvider)
      .watchAgentsBySuccursale(succursaleId);
});

// ── Agent par ID ──────────────────────────────────────────────
final agentByIdProvider =
    FutureProvider.family<AgentEntity?, String>((ref, id) async {
  final result =
      await ref.watch(agentsRepositoryProvider).getAgentById(id);
  return result.fold((_) => null, (agent) => agent);
});

// ── Recherche ─────────────────────────────────────────────────
final agentsSearchQueryProvider = StateProvider<String>((ref) => '');

final agentsFilteredProvider = Provider<List<AgentEntity>>((ref) {
  final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];
  final query  = ref.watch(agentsSearchQueryProvider).toLowerCase();
  if (query.isEmpty) return agents;
  return agents.where((a) {
    return a.nom.toLowerCase().contains(query) ||
        a.phone.toLowerCase().contains(query);
  }).toList();
});

// ── Notifier ──────────────────────────────────────────────────
class AgentsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createAgent({
    required String nom,
    required String phone,
    required String succursaleId,
    required String motDePasseTemp,
    required double limiteJournaliere,
  }) async {
    state = const AsyncLoading();
    final result =
        await ref.read(agentsRepositoryProvider).createAgent(
      nom:               nom,
      phone:             phone,
      succursaleId:      succursaleId,
      motDePasseTemp:    motDePasseTemp,
      limiteJournaliere: limiteJournaliere,
    );
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> updateAgent({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(agentsRepositoryProvider)
        .updateAgent(id: id, data: data);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> updateStatus(String id, AgentStatus status) async {
    state = const AsyncLoading();
    final result = await ref
        .read(agentsRepositoryProvider)
        .updateAgentStatus(id, status);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> resetPassword(
      String userId, String newPassword) async {
    state = const AsyncLoading();
    final result = await ref
        .read(agentsRepositoryProvider)
        .resetPassword(userId, newPassword);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> deleteAgent(String id) async {
    state = const AsyncLoading();
    final result =
        await ref.read(agentsRepositoryProvider).deleteAgent(id);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }
}

final agentsNotifierProvider =
    AsyncNotifierProvider<AgentsNotifier, void>(AgentsNotifier.new);