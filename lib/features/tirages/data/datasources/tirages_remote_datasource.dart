// lib/features/tirages/data/datasources/tirages_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/core/utils/code_generator.dart';
import 'package:ehbien_lotto_admin/features/tirages/data/models/result_model.dart';
import 'package:ehbien_lotto_admin/features/tirages/data/models/tirage_model.dart';

abstract class TiragesRemoteDatasource {
  Stream<List<TirageModel>> watchAllTirages();
  Stream<List<TirageModel>> watchTiragesByStatus(String status);
  Future<TirageModel> getTirageById(String id);
  Future<String> createTirage({
    required String nom,
    required String type,
    required DateTime heurePrevu,
  });
  Future<void> updateTirage({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<void> updateTirageStatus(String id, String status);
  Future<String> publishResult({
    required String tirageId,
    required List<String> boules,
    required String publishedBy,
  });
  Future<ResultModel?> getResultByTirageId(String tirageId);
}

class TiragesRemoteDatasourceImpl implements TiragesRemoteDatasource {
  final FirebaseFirestore _firestore;

  TiragesRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.tirages);

  @override
  Stream<List<TirageModel>> watchAllTirages() {
    return _col
        .orderBy('heurePrevu', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(TirageModel.fromFirestore).toList());
  }

  @override
  Stream<List<TirageModel>> watchTiragesByStatus(String status) {
    return _col
        .where('status', isEqualTo: status)
        .orderBy('heurePrevu', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(TirageModel.fromFirestore).toList());
  }

  @override
  Future<TirageModel> getTirageById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) {
        throw const FirestoreException(
            'Tirage introuvable.', code: 'not-found');
      }
      return TirageModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<String> createTirage({
    required String nom,
    required String type,
    required DateTime heurePrevu,
  }) async {
    try {
      final id = CodeGenerator.firestoreId();
      await _col.doc(id).set({
        'nom':        nom,
        'type':       type,
        'heurePrevu': Timestamp.fromDate(heurePrevu),
        'status':     'ouvert',
        'createdAt':  FieldValue.serverTimestamp(),
        'updatedAt':  FieldValue.serverTimestamp(),
      });
      return id;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> updateTirage({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _col.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> updateTirageStatus(String id, String status) async {
    try {
      await _col.doc(id).update({
        'status':    status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<String> publishResult({
    required String tirageId,
    required List<String> boules,
    required String publishedBy,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Créer le résultat dans la sous-collection
      final resultRef = _col
          .doc(tirageId)
          .collection('results')
          .doc(CodeGenerator.firestoreId());

      batch.set(resultRef, {
        'tirageId':    tirageId,
        'boules':      boules,
        'publishedAt': FieldValue.serverTimestamp(),
        'publishedBy': publishedBy,
      });

      // 2. Mettre à jour le statut du tirage
      batch.update(_col.doc(tirageId), {
        'status':    'publie',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return resultRef.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<ResultModel?> getResultByTirageId(String tirageId) async {
    try {
      final snap = await _col
          .doc(tirageId)
          .collection('results')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return ResultModel.fromFirestore(snap.docs.first);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}