// lib/features/ventes/presentation/providers/ventes_provider.dart

import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/providers/succursales_provider.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/providers/tickets_provider.dart';
import 'package:ehbien_lotto_admin/features/ventes/domain/entities/vente_summary_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Période sélectionnée ──────────────────────────────────────
enum VentePeriode { jour, semaine, mois }

final ventePeriodeProvider =
    StateProvider<VentePeriode>((ref) => VentePeriode.jour);

// ── Résumé ventes ─────────────────────────────────────────────
final ventesSummaryProvider =
    Provider<List<VenteSummaryEntity>>((ref) {
  final tickets      = ref.watch(ticketsStreamProvider).valueOrNull ?? [];
  final agents       = ref.watch(agentsStreamProvider).valueOrNull ?? [];
  final succursales  = ref.watch(succursalesStreamProvider).valueOrNull ?? [];
  final periode      = ref.watch(ventePeriodeProvider);

  final now  = DateTime.now();
  final from = switch (periode) {
    VentePeriode.jour    => DateTime(now.year, now.month, now.day),
    VentePeriode.semaine =>
        now.subtract(Duration(days: now.weekday - 1)),
    VentePeriode.mois    => DateTime(now.year, now.month, 1),
  };

  final filtered =
      tickets.where((t) => t.createdAt.isAfter(from)).toList();

  final agentsMap      = {for (final a in agents)      a.id: a};
  final succursalesMap = {for (final s in succursales) s.id: s.nom};

  // Grouper par agent
  final Map<String, List<dynamic>> byAgent = {};
  for (final t in filtered) {
    byAgent.putIfAbsent(t.agentId, () => []).add(t);
  }

  return byAgent.entries.map((entry) {
    final agent        = agentsMap[entry.key];
    final agentTickets = entry.value;

    final montantTotal = agentTickets.fold<double>(
      0.0,
      (sum, t) => sum + (t.montantTotal as double),
    );
    final gainsTotaux = agentTickets
        .where((t) => t.gagnant == true)
        .fold<double>(
          0.0,
          (sum, t) => sum + ((t.gainTotal as double?) ?? 0.0),
        );

    return VenteSummaryEntity(
      agentId:       entry.key,
      agentNom:      agent?.nom ?? 'Inconnu',
      succursaleId:  agent?.succursaleId ?? '',
      succursaleNom: succursalesMap[agent?.succursaleId] ?? '',
      nombreTickets: agentTickets.length,
      montantTotal:  montantTotal,
      gainsTotaux:   gainsTotaux,
      recette:       montantTotal - gainsTotaux,
      date:          from,
    );
  }).toList()
    ..sort((a, b) => b.montantTotal.compareTo(a.montantTotal));
});

// ── Totaux globaux ────────────────────────────────────────────
final ventesTotauxProvider = Provider<Map<String, double>>((ref) {
  final summary = ref.watch(ventesSummaryProvider);
  return {
    'montantTotal': summary.fold(0.0, (s, v) => s + v.montantTotal),
    'gainsTotaux':  summary.fold(0.0, (s, v) => s + v.gainsTotaux),
    'recette':      summary.fold(0.0, (s, v) => s + v.recette),
  };
});