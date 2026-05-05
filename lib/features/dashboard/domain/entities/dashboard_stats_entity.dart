// lib/features/dashboard/domain/entities/dashboard_stats_entity.dart

import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final double totalVentesJour;
  final int totalTicketsJour;
  final int totalAgentsActifs;
  final double totalGainsAPayer;
  final double totalRecettes;
  final double totalVentesSemaine;
  final double totalVentesMois;
  final int totalTiragesOuverts;

  const DashboardStatsEntity({
    required this.totalVentesJour,
    required this.totalTicketsJour,
    required this.totalAgentsActifs,
    required this.totalGainsAPayer,
    required this.totalRecettes,
    required this.totalVentesSemaine,
    required this.totalVentesMois,
    required this.totalTiragesOuverts,
  });

  static const empty = DashboardStatsEntity(
    totalVentesJour:     0,
    totalTicketsJour:    0,
    totalAgentsActifs:   0,
    totalGainsAPayer:    0,
    totalRecettes:       0,
    totalVentesSemaine:  0,
    totalVentesMois:     0,
    totalTiragesOuverts: 0,
  );

  @override
  List<Object?> get props => [
    totalVentesJour, totalTicketsJour,
    totalAgentsActifs, totalGainsAPayer,
  ];
}