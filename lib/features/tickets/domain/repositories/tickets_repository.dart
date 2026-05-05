// lib/features/tickets/domain/repositories/tickets_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_item_entity.dart';

abstract class TicketsRepository {
  Stream<List<TicketEntity>> watchAllTickets({int limit = 50});
  Stream<List<TicketEntity>> watchTicketsByAgent(
      String agentId, {int limit = 50});
  Stream<List<TicketEntity>> watchTicketsByTirage(String tirageId);
  Future<EitherFailure<TicketEntity>> getTicketById(String id);
  Future<EitherFailure<TicketEntity?>> getTicketByCode(String codeUnique);
  Future<EitherFailure<List<TicketItemEntity>>> getTicketItems(
      String ticketId);
  Future<EitherVoid> updateTicketStatus(String id, TicketStatus status);
  Future<EitherVoid> markTicketAsWinner(String id, double gainTotal);
  Future<EitherVoid> markTicketAsPaid(String id);
  Future<EitherFailure<List<TicketEntity>>> getTicketsByDateRange({
    required DateTime from,
    required DateTime to,
    String? agentId,
    String? succursaleId,
    String? tirageId,
  });
}