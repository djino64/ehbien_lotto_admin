// lib/features/dashboard/data/repositories/dashboard_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:ehbien_lotto_admin/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _datasource;

  DashboardRepositoryImpl(this._datasource);

  @override
  Future<EitherFailure<DashboardStatsEntity>> getStats() async {
    try {
      final stats = await _datasource.getStats();
      return Right(stats);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}