// lib/features/rapports/presentation/providers/rapports_provider.dart

import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/providers/tickets_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RapportPeriode {
  final DateTime from;
  final DateTime to;
  const RapportPeriode({required this.from, required this.to});
}

final rapportPeriodeProvider = StateProvider<RapportPeriode>((ref) {
  final now = DateTime.now();
  return RapportPeriode(
    from: DateTime(now.year, now.month, 1),
    to:   DateTime(now.year, now.month + 1, 0, 23, 59, 59),
  );
});

final rapportTicketsProvider =
    FutureProvider<List<TicketEntity>>((ref) async {
  final periode = ref.watch(rapportPeriodeProvider);
  final result  = await ref
      .read(ticketsRepositoryProvider)
      .getTicketsByDateRange(
        from: periode.from,
        to:   periode.to,
      );
  return result.fold((_) => [], (tickets) => tickets);
});

final rapportStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final tickets = ref.watch(rapportTicketsProvider).valueOrNull ?? [];

  final totalVentes   = tickets.fold<double>(0.0, (s, t) => s + t.montantTotal);
  final totalGains    = tickets
      .where((t) => t.gagnant)
      .fold<double>(0.0, (s, t) => s + (t.gainTotal ?? 0.0));
  final totalRecettes = totalVentes - totalGains;
  final gagnants      = tickets.where((t) => t.gagnant).length;
  final perdants      = tickets
      .where((t) => t.status == TicketStatus.perdant)
      .length;

  final Map<String, double> ventesParJour = {};
  for (final t in tickets) {
    final key =
        '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}-${t.createdAt.day.toString().padLeft(2, '0')}';
    ventesParJour[key] = (ventesParJour[key] ?? 0.0) + t.montantTotal;
  }

  final Map<String, double> ventesParAgent = {};
  for (final t in tickets) {
    ventesParAgent[t.agentId] =
        (ventesParAgent[t.agentId] ?? 0.0) + t.montantTotal;
  }

  return {
    'totalVentes':     totalVentes,
    'totalGains':      totalGains,
    'totalRecettes':   totalRecettes,
    'nombreTickets':   tickets.length,
    'ticketsGagnants': gagnants,
    'ticketsPerdants': perdants,
    'tauxGagnant':     tickets.isEmpty
        ? 0.0
        : gagnants / tickets.length,
    'ventesParJour':   ventesParJour,
    'ventesParAgent':  ventesParAgent,
  };
});