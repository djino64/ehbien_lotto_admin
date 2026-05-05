// lib/features/succursales/domain/repositories/succursales_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/succursales/domain/entities/succursale_entity.dart';

abstract class SuccursalesRepository {
  Stream<List<SuccursaleEntity>> watchAllSuccursales();
  Future<EitherFailure<SuccursaleEntity>> getSuccursaleById(String id);
  Future<EitherFailure<String>> createSuccursale({
    required String nom,
    required String adresse,
    String? telephone,
  });
  Future<EitherVoid> updateSuccursale({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<EitherVoid> updateSuccursaleStatus(
      String id, SuccursaleStatus status);
  Future<EitherVoid> deleteSuccursale(String id);
}