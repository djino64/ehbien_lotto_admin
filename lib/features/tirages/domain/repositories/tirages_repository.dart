// lib/features/tirages/domain/repositories/tirages_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/result_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';

abstract class TiragesRepository {
  Stream<List<TirageEntity>> watchAllTirages();
  Stream<List<TirageEntity>> watchTiragesByStatus(TirageStatus status);
  Future<EitherFailure<TirageEntity>> getTirageById(String id);
  Future<EitherFailure<String>> createTirage({
    required String nom,
    required String type,
    required DateTime heurePrevu,
  });
  Future<EitherVoid> updateTirage({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<EitherVoid> updateTirageStatus(String id, TirageStatus status);
  Future<EitherFailure<String>> publishResult({
    required String tirageId,
    required List<String> boules,
    required String publishedBy,
  });
  Future<EitherFailure<ResultEntity?>> getResultByTirageId(String tirageId);
}