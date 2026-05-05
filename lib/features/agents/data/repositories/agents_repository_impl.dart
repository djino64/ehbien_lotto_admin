// lib/features/agents/data/repositories/agents_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/agents/data/datasources/agents_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/agents/data/models/agent_model.dart';
import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';
import 'package:ehbien_lotto_admin/features/agents/domain/repositories/agents_repository.dart';

class AgentsRepositoryImpl implements AgentsRepository {
  final AgentsRemoteDatasource _datasource;

  AgentsRepositoryImpl(this._datasource);

  @override
  Stream<List<AgentEntity>> watchAllAgents() {
    return _datasource.watchAllAgents().map(
      (List<AgentModel> list) => list
          .map((AgentModel m) => m.toEntity())
          .toList(),
    );
  }

  @override
  Stream<List<AgentEntity>> watchAgentsBySuccursale(
      String succursaleId) {
    return _datasource
        .watchAgentsBySuccursale(succursaleId)
        .map(
          (List<AgentModel> list) => list
              .map((AgentModel m) => m.toEntity())
              .toList(),
        );
  }

  @override
  Future<EitherFailure<AgentEntity>> getAgentById(String id) async {
    try {
      final model = await _datasource.getAgentById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<String>> createAgent({
    required String nom,
    required String phone,
    required String succursaleId,
    required String motDePasseTemp,
    required double limiteJournaliere,
  }) async {
    try {
      final id = await _datasource.createAgent(
        nom:               nom,
        phone:             phone,
        succursaleId:      succursaleId,
        motDePasseTemp:    motDePasseTemp,
        limiteJournaliere: limiteJournaliere,
      );
      return Right(id);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateAgent({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _datasource.updateAgent(id: id, data: data);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateAgentStatus(
      String id, AgentStatus status) async {
    try {
      await _datasource.updateAgentStatus(id, status.name);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> resetPassword(
      String userId, String newPassword) async {
    try {
      await _datasource.resetPassword(userId, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> deleteAgent(String id) async {
    try {
      await _datasource.deleteAgent(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}