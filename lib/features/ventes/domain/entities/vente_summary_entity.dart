// lib/features/ventes/domain/entities/vente_summary_entity.dart

import 'package:equatable/equatable.dart';

class VenteSummaryEntity extends Equatable {
  final String agentId;
  final String agentNom;
  final String succursaleId;
  final String succursaleNom;
  final int    nombreTickets;
  final double montantTotal;
  final double gainsTotaux;
  final double recette;
  final DateTime date;

  const VenteSummaryEntity({
    required this.agentId,
    required this.agentNom,
    required this.succursaleId,
    required this.succursaleNom,
    required this.nombreTickets,
    required this.montantTotal,
    required this.gainsTotaux,
    required this.recette,
    required this.date,
  });

  double get tauxRecette =>
      montantTotal > 0 ? (recette / montantTotal) : 0.0;

  @override
  List<Object?> get props =>
      [agentId, succursaleId, date, montantTotal];
}