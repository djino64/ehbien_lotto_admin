// lib/features/dashboard/domain/repositories/dashboard_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  Future<EitherFailure<DashboardStatsEntity>> getStats();
}