// lib/features/limits/data/datasources/limits_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/core/utils/code_generator.dart';
import 'package:ehbien_lotto_admin/features/limits/data/models/limit_model.dart';

abstract class LimitsRemoteDatasource {
  Stream<List<LimitModel>> watchAllLimits();
  Stream<List<LimitModel>> watchLimitsByAgent(String agentId);
  Future<String> createLimit({
    String? agentId,
    String? tirageId,
    String? typeJeu,
    String? boule,
    required double maxParBoule,
    required double maxGlobal,
  });
  Future<void> updateLimit({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<void> deleteLimit(String id);
  Future<bool> checkLimitExceeded({
    required String boule,
    required String typeJeu,
    required double montant,
    String? agentId,
    String? tirageId,
  });
  Future<void> incrementLimitAmount(String limitId, double amount);
}

class LimitsRemoteDatasourceImpl implements LimitsRemoteDatasource {
  final FirebaseFirestore _firestore;

  LimitsRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.limits);

  @override
  Stream<List<LimitModel>> watchAllLimits() {
    return _col
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot snap) => snap.docs
              .map(
                LimitModel.fromFirestore,
              )
              .toList(),
        );
  }

  @override
  Stream<List<LimitModel>> watchLimitsByAgent(String agentId) {
    return _col
        .where('agentId', isEqualTo: agentId)
        .snapshots()
        .map(
          (QuerySnapshot snap) => snap.docs
              .map(
                LimitModel.fromFirestore,
              )
              .toList(),
        );
  }

  @override
  Future<String> createLimit({
    String? agentId,
    String? tirageId,
    String? typeJeu,
    String? boule,
    required double maxParBoule,
    required double maxGlobal,
  }) async {
    try {
      final id = CodeGenerator.firestoreId();
      await _col.doc(id).set({
        'agentId':       agentId,
        'tirageId':      tirageId,
        'typeJeu':       typeJeu,
        'boule':         boule,
        'maxParBoule':   maxParBoule,
        'maxGlobal':     maxGlobal,
        'currentAmount': 0.0,
        'updatedAt':     FieldValue.serverTimestamp(),
      });
      return id;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> updateLimit({
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
  Future<void> deleteLimit(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<bool> checkLimitExceeded({
    required String boule,
    required String typeJeu,
    required double montant,
    String? agentId,
    String? tirageId,
  }) async {
    try {
      Query query = _col
          .where('boule',   isEqualTo: boule)
          .where('typeJeu', isEqualTo: typeJeu);

      if (agentId == null) {
        query = query.where('agentId', isNull: true);
      } else {
        query = query.where('agentId', isEqualTo: agentId);
      }

      final snap = await query.get();
      for (final doc in snap.docs) {
        final limit = LimitModel.fromFirestore(doc);
        if (limit.currentAmount + montant > limit.maxParBoule) {
          return true;
        }
        if (limit.currentAmount + montant > limit.maxGlobal) {
          return true;
        }
      }
      return false;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> incrementLimitAmount(
      String limitId, double amount) async {
    try {
      await _col.doc(limitId).update({
        'currentAmount': FieldValue.increment(amount),
        'updatedAt':     FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}