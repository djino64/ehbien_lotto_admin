// lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/core/utils/date_utils.dart';
import 'package:ehbien_lotto_admin/features/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract class DashboardRemoteDatasource {
  Future<DashboardStatsEntity> getStats();
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final FirebaseFirestore _firestore;

  DashboardRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<DashboardStatsEntity> getStats() async {
    try {
      final now  = DateTime.now();
      final from = AppDateUtils.startOfDay(now);
      final to   = AppDateUtils.endOfDay(now);

      // Tickets du jour
      final ticketsSnap = await _firestore
          .collection(FirestorePaths.tickets)
          .where('createdAt', isGreaterThanOrEqualTo: from)
          .where('createdAt', isLessThanOrEqualTo: to)
          .get();

      double totalVentesJour = 0;
      double totalGainsAPayer = 0;

      for (final doc in ticketsSnap.docs) {
        final d = doc.data();
        totalVentesJour +=
            (d['montantTotal'] as num?)?.toDouble() ?? 0.0;
        if (d['gagnant'] == true && d['paye'] != true) {
          totalGainsAPayer +=
              (d['gainTotal'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // Agents actifs
      final agentsSnap = await _firestore
          .collection(FirestorePaths.agents)
          .where('status', isEqualTo: 'actif')
          .count()
          .get();

      // Tirages ouverts
      final tiragesSnap = await _firestore
          .collection(FirestorePaths.tirages)
          .where('status', isEqualTo: 'ouvert')
          .count()
          .get();

      // Ventes semaine
      final weekFrom = AppDateUtils.startOfDay(
          now.subtract(Duration(days: now.weekday - 1)));
      final weekSnap = await _firestore
          .collection(FirestorePaths.tickets)
          .where('createdAt', isGreaterThanOrEqualTo: weekFrom)
          .where('createdAt', isLessThanOrEqualTo: to)
          .get();

      double totalVentesSemaine = 0;
      for (final doc in weekSnap.docs) {
        totalVentesSemaine +=
            (doc.data()['montantTotal'] as num?)?.toDouble() ?? 0.0;
      }

      // Ventes mois
      final monthFrom = AppDateUtils.startOfMonth(now);
      final monthSnap = await _firestore
          .collection(FirestorePaths.tickets)
          .where('createdAt', isGreaterThanOrEqualTo: monthFrom)
          .where('createdAt', isLessThanOrEqualTo: to)
          .get();

      double totalVentesMois = 0;
      for (final doc in monthSnap.docs) {
        totalVentesMois +=
            (doc.data()['montantTotal'] as num?)?.toDouble() ?? 0.0;
      }

      return DashboardStatsEntity(
        totalVentesJour:     totalVentesJour,
        totalTicketsJour:    ticketsSnap.docs.length,
        totalAgentsActifs:   agentsSnap.count ?? 0,
        totalGainsAPayer:    totalGainsAPayer,
        totalRecettes:       totalVentesJour - totalGainsAPayer,
        totalVentesSemaine:  totalVentesSemaine,
        totalVentesMois:     totalVentesMois,
        totalTiragesOuverts: tiragesSnap.count ?? 0,
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}