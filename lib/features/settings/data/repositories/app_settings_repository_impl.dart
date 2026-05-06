// lib/features/settings/data/repositories/app_settings_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/entities/app_setting_entity.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final SettingsRemoteDatasource _datasource;

  AppSettingsRepositoryImpl(this._datasource);

  @override
  Stream<List<AppSettingEntity>> watchAllSettings() {
    return _datasource
        .watchAllSettings()
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<EitherFailure<AppSettingEntity?>> getSettingByKey(
      String key) async {
    try {
      final model = await _datasource.getSettingByKey(key);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> upsertSetting({
    required String  key,
    required dynamic valeur,
    required String  description,
    required String  updatedBy,
  }) async {
    try {
      await _datasource.upsertSetting(
        key:         key,
        valeur:      valeur,
        description: description,
        updatedBy:   updatedBy,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> deleteSetting(String key) async {
    try {
      await _datasource.deleteSetting(key);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}