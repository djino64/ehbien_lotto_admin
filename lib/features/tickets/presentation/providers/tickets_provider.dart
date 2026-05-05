// lib/features/tickets/presentation/providers/tickets_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/tickets/data/datasources/tickets_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/tickets/data/repositories/tickets_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_item_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/repositories/tickets_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final ticketsDatasourceProvider = Provider<TicketsRemoteDatasource>((ref) {
  return TicketsRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final ticketsRepositoryProvider = Provider<TicketsRepository>((ref) {
  return TicketsRepositoryImpl(ref.watch(ticketsDatasourceProvider));
});

// ── Stream tous les tickets ───────────────────────────────────
final ticketsStreamProvider = StreamProvider<List<TicketEntity>>((ref) {
  return ref.watch(ticketsRepositoryProvider).watchAllTickets();
});

// ── Stream tickets par agent ──────────────────────────────────
final ticketsByAgentProvider =
    StreamProvider.family<List<TicketEntity>, String>((ref, agentId) {
  return ref
      .watch(ticketsRepositoryProvider)
      .watchTicketsByAgent(agentId);
});

// ── Stream tickets par tirage ─────────────────────────────────
final ticketsByTirageProvider =
    StreamProvider.family<List<TicketEntity>, String>((ref, tirageId) {
  return ref
      .watch(ticketsRepositoryProvider)
      .watchTicketsByTirage(tirageId);
});

// ── Ticket par ID ─────────────────────────────────────────────
final ticketByIdProvider =
    FutureProvider.family<TicketEntity?, String>((ref, id) async {
  final result =
      await ref.watch(ticketsRepositoryProvider).getTicketById(id);
  return result.fold((_) => null, (t) => t);
});

// ── Items d'un ticket ─────────────────────────────────────────
final ticketItemsProvider =
    FutureProvider.family<List<TicketItemEntity>, String>(
        (ref, ticketId) async {
  final result = await ref
      .watch(ticketsRepositoryProvider)
      .getTicketItems(ticketId);
  return result.fold((_) => [], (items) => items);
});

// ── Filtre tickets ────────────────────────────────────────────
class TicketFilter {
  final String? agentId;
  final String? succursaleId;
  final String? tirageId;
  final TicketStatus? status;
  final DateTime? from;
  final DateTime? to;

  const TicketFilter({
    this.agentId,
    this.succursaleId,
    this.tirageId,
    this.status,
    this.from,
    this.to,
  });

  TicketFilter copyWith({
    String? agentId,
    String? succursaleId,
    String? tirageId,
    TicketStatus? status,
    DateTime? from,
    DateTime? to,
  }) {
    return TicketFilter(
      agentId:      agentId      ?? this.agentId,
      succursaleId: succursaleId ?? this.succursaleId,
      tirageId:     tirageId     ?? this.tirageId,
      status:       status       ?? this.status,
      from:         from         ?? this.from,
      to:           to           ?? this.to,
    );
  }
}

final ticketFilterProvider =
    StateProvider<TicketFilter>((ref) => const TicketFilter());

final ticketsFilteredProvider =
    Provider<List<TicketEntity>>((ref) {
  final tickets = ref.watch(ticketsStreamProvider).valueOrNull ?? [];
  final filter  = ref.watch(ticketFilterProvider);

  return tickets.where((t) {
    if (filter.agentId != null && t.agentId != filter.agentId) {
      return false;
    }
    if (filter.succursaleId != null &&
        t.succursaleId != filter.succursaleId) {
      return false;
    }
    if (filter.tirageId != null && t.tirageId != filter.tirageId) {
      return false;
    }
    if (filter.status != null && t.status != filter.status) {
      return false;
    }
    if (filter.from != null &&
        t.createdAt.isBefore(filter.from!)) {
      return false;
    }
    if (filter.to != null && t.createdAt.isAfter(filter.to!)) {
      return false;
    }
    return true;
  }).toList();
});

// ── Notifier ──────────────────────────────────────────────────
class TicketsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> updateStatus(String id, TicketStatus status) async {
    state = const AsyncLoading();
    final result = await ref
        .read(ticketsRepositoryProvider)
        .updateTicketStatus(id, status);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> markAsWinner(String id, double gainTotal) async {
    state = const AsyncLoading();
    final result = await ref
        .read(ticketsRepositoryProvider)
        .markTicketAsWinner(id, gainTotal);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> markAsPaid(String id) async {
    state = const AsyncLoading();
    final result = await ref
        .read(ticketsRepositoryProvider)
        .markTicketAsPaid(id);
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }
}

final ticketsNotifierProvider =
    AsyncNotifierProvider<TicketsNotifier, void>(TicketsNotifier.new);