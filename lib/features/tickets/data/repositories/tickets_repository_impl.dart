// lib/features/tickets/data/repositories/tickets_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/tickets/data/datasources/tickets_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_item_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/repositories/tickets_repository.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsRemoteDatasource _datasource;

  TicketsRepositoryImpl(this._datasource);

  @override
  Stream<List<TicketEntity>> watchAllTickets({int limit = 50}) {
    return _datasource
        .watchAllTickets(limit: limit)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TicketEntity>> watchTicketsByAgent(
      String agentId, {int limit = 50}) {
    return _datasource
        .watchTicketsByAgent(agentId, limit: limit)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TicketEntity>> watchTicketsByTirage(String tirageId) {
    return _datasource
        .watchTicketsByTirage(tirageId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<EitherFailure<TicketEntity>> getTicketById(String id) async {
    try {
      final model = await _datasource.getTicketById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<TicketEntity?>> getTicketByCode(
      String codeUnique) async {
    try {
      final model = await _datasource.getTicketByCode(codeUnique);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<List<TicketItemEntity>>> getTicketItems(
      String ticketId) async {
    try {
      final models = await _datasource.getTicketItems(ticketId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateTicketStatus(
      String id, TicketStatus status) async {
    try {
      await _datasource.updateTicketStatus(id, status.name);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> markTicketAsWinner(String id, double gainTotal) async {
    try {
      await _datasource.markTicketAsWinner(id, gainTotal);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> markTicketAsPaid(String id) async {
    try {
      await _datasource.markTicketAsPaid(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<List<TicketEntity>>> getTicketsByDateRange({
    required DateTime from,
    required DateTime to,
    String? agentId,
    String? succursaleId,
    String? tirageId,
  }) async {
    try {
      final models = await _datasource.getTicketsByDateRange(
        from:          from,
        to:            to,
        agentId:       agentId,
        succursaleId:  succursaleId,
        tirageId:      tirageId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}