// lib/features/settings/domain/repositories/app_settings_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/entities/app_setting_entity.dart';

abstract class AppSettingsRepository {
  Stream<List<AppSettingEntity>> watchAllSettings();
  Future<EitherFailure<AppSettingEntity?>> getSettingByKey(
      String key);
  Future<EitherVoid> upsertSetting({
    required String  key,
    required dynamic valeur,
    required String  description,
    required String  updatedBy,
  });
  Future<EitherVoid> deleteSetting(String key);
}