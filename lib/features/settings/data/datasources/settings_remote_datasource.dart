// lib/features/settings/data/datasources/settings_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/features/settings/data/models/app_setting_model.dart';

abstract class SettingsRemoteDatasource {
  Stream<List<AppSettingModel>> watchAllSettings();
  Future<AppSettingModel?> getSettingByKey(String key);
  Future<void> upsertSetting({
    required String  key,
    required dynamic valeur,
    required String  description,
    required String  updatedBy,
  });
  Future<void> deleteSetting(String key);
}

class SettingsRemoteDatasourceImpl
    implements SettingsRemoteDatasource {
  final FirebaseFirestore _firestore;

  SettingsRemoteDatasourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.settings);

  @override
  Stream<List<AppSettingModel>> watchAllSettings() {
    return _col.snapshots().map(
          (snap) => snap.docs
              .map(AppSettingModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Future<AppSettingModel?> getSettingByKey(String key) async {
    try {
      final doc = await _col.doc(key).get();
      if (!doc.exists) return null;
      return AppSettingModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> upsertSetting({
    required String  key,
    required dynamic valeur,
    required String  description,
    required String  updatedBy,
  }) async {
    try {
      await _col.doc(key).set(
        {
          'valeur':      valeur,
          'description': description,
          'updatedAt':   FieldValue.serverTimestamp(),
          'updatedBy':   updatedBy,
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> deleteSetting(String key) async {
    try {
      await _col.doc(key).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          e.message ?? 'Erreur', code: e.code);
    }
  }
}