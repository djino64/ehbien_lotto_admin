// lib/features/succursales/data/repositories/succursales_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/succursales/data/datasources/succursales_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/succursales/domain/entities/succursale_entity.dart';
import 'package:ehbien_lotto_admin/features/succursales/domain/repositories/succursales_repository.dart';

class SuccursalesRepositoryImpl implements SuccursalesRepository {
  final SuccursalesRemoteDatasource _datasource;

  SuccursalesRepositoryImpl(this._datasource);

  @override
  Stream<List<SuccursaleEntity>> watchAllSuccursales() {
    return _datasource
        .watchAllSuccursales()
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<EitherFailure<SuccursaleEntity>> getSuccursaleById(String id) async {
    try {
      final model = await _datasource.getSuccursaleById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherFailure<String>> createSuccursale({
    required String nom,
    required String adresse,
    String? telephone,
  }) async {
    try {
      final id = await _datasource.createSuccursale(
        nom: nom, adresse: adresse, telephone: telephone,
      );
      return Right(id);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateSuccursale({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _datasource.updateSuccursale(id: id, data: data);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> updateSuccursaleStatus(
      String id, SuccursaleStatus status) async {
    try {
      await _datasource.updateSuccursaleStatus(id, status.name);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> deleteSuccursale(String id) async {
    try {
      await _datasource.deleteSuccursale(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}