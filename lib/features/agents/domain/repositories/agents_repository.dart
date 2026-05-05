// lib/features/agents/domain/repositories/agents_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';

abstract class AgentsRepository {
  Stream<List<AgentEntity>> watchAllAgents();
  Stream<List<AgentEntity>> watchAgentsBySuccursale(String succursaleId);
  Future<EitherFailure<AgentEntity>> getAgentById(String id);
  Future<EitherFailure<String>> createAgent({
    required String nom,
    required String phone,
    required String succursaleId,
    required String motDePasseTemp,
    required double limiteJournaliere,
  });
  Future<EitherVoid> updateAgent({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<EitherVoid> updateAgentStatus(String id, AgentStatus status);
  Future<EitherVoid> resetPassword(String userId, String newPassword);
  Future<EitherVoid> deleteAgent(String id);
}