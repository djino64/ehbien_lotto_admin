// lib/features/dashboard/presentation/providers/dashboard_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:ehbien_lotto_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final dashboardDatasourceProvider =
    Provider<DashboardRemoteDatasource>((ref) {
  return DashboardRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
      ref.watch(dashboardDatasourceProvider));
});

// ── Stats (rechargées à la demande) ──────────────────────────
final dashboardStatsProvider =
    FutureProvider<DashboardStatsEntity>((ref) async {
  final result =
      await ref.watch(dashboardRepositoryProvider).getStats();
  return result.fold(
    (_)      => DashboardStatsEntity.empty,
    (stats)  => stats,
  );
});

// ── Auto-refresh toutes les 5 minutes ────────────────────────
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

final dashboardStatsRefreshableProvider =
    FutureProvider<DashboardStatsEntity>((ref) async {
  ref.watch(dashboardRefreshProvider); // déclenche le rebuild
  final result =
      await ref.read(dashboardRepositoryProvider).getStats();
  return result.fold(
    (_)      => DashboardStatsEntity.empty,
    (stats)  => stats,
  );
});