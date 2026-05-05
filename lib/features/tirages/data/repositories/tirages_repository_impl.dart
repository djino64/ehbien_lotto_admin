// lib/features/tirages/data/repositories/tirages_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/tirages/data/datasources/tirages_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/result_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/repositories/tirages_repository.dart';

class TiragesRepositoryImpl implements TiragesRepository {
  final TiragesRemoteDatasource _datasource;

  TiragesRepositoryImpl(this._datasource);

  @override
  Stream<List<TirageEntity>> watchAllTirages() {
    return _datasource
        .watchAllTirages()
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TirageEntity>> watchTiragesByStatus(TirageStatus status) {
    return _datasource
        .watchTiragesByStatus(status.name)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<EitherFailure<TirageEntity>> getTirageById(String id) async {
    try {
      final model = await _datasource.getTirageById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<String>> createTirage({
    required String nom,
    required String type,
    required DateTime heurePrevu,
  }) async {
    try {
      final id = await _datasource.createTirage(
        nom: nom, type: type, heurePrevu: heurePrevu,
      );
      return Right(id);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateTirage({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _datasource.updateTirage(id: id, data: data);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateTirageStatus(String id, TirageStatus status) async {
    try {
      await _datasource.updateTirageStatus(id, status.name);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<String>> publishResult({
    required String tirageId,
    required List<String> boules,
    required String publishedBy,
  }) async {
    try {
      final id = await _datasource.publishResult(
        tirageId:    tirageId,
        boules:      boules,
        publishedBy: publishedBy,
      );
      return Right(id);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<ResultEntity?>> getResultByTirageId(
      String tirageId) async {
    try {
      final model = await _datasource.getResultByTirageId(tirageId);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}