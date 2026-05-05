// lib/features/dashboard/data/models/dashboard_stats_model.dart

import 'package:ehbien_lotto_admin/features/dashboard/domain/entities/dashboard_stats_entity.dart';

// Le dashboard construit ses stats directement dans le datasource
// via des agrégations Firestore. Ce model est un wrapper léger.
class DashboardStatsModel {
  final double totalVentesJour;
  final int    totalTicketsJour;
  final int    totalAgentsActifs;
  final double totalGainsAPayer;
  final double totalRecettes;
  final double totalVentesSemaine;
  final double totalVentesMois;
  final int    totalTiragesOuverts;

  const DashboardStatsModel({
    required this.totalVentesJour,
    required this.totalTicketsJour,
    required this.totalAgentsActifs,
    required this.totalGainsAPayer,
    required this.totalRecettes,
    required this.totalVentesSemaine,
    required this.totalVentesMois,
    required this.totalTiragesOuverts,
  });

  DashboardStatsEntity toEntity() => DashboardStatsEntity(
    totalVentesJour:     totalVentesJour,
    totalTicketsJour:    totalTicketsJour,
    totalAgentsActifs:   totalAgentsActifs,
    totalGainsAPayer:    totalGainsAPayer,
    totalRecettes:       totalRecettes,
    totalVentesSemaine:  totalVentesSemaine,
    totalVentesMois:     totalVentesMois,
    totalTiragesOuverts: totalTiragesOuverts,
  );
}