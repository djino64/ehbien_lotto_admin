// lib/features/blocages/data/datasources/blocages_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/core/utils/code_generator.dart';
import 'package:ehbien_lotto_admin/features/blocages/data/models/blocage_model.dart';

abstract class BlocagesRemoteDatasource {
  Stream<List<BlocageModel>> watchAllBlocages();
  Stream<List<BlocageModel>> watchBlocagesByAgent(String agentId);
  Future<String> createBlocage({
    required String boule,
    String? typeJeu,
    String? agentId,
    String? succursaleId,
    String? tirageId,
    required bool global,
    required bool permanent,
    DateTime? expiresAt,
    required String createdBy,
  });
  Future<void> deleteBlocage(String id);
  Future<bool> isBlocageActif({
    required String boule,
    String? typeJeu,
    String? agentId,
  });
}

class BlocagesRemoteDatasourceImpl implements BlocagesRemoteDatasource {
  final FirebaseFirestore _firestore;

  BlocagesRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.blockedNumbers);

  @override
  Stream<List<BlocageModel>> watchAllBlocages() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(BlocageModel.fromFirestore).toList());
  }

  @override
  Stream<List<BlocageModel>> watchBlocagesByAgent(String agentId) {
    return _col
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(BlocageModel.fromFirestore).toList());
  }

  @override
  Future<String> createBlocage({
    required String boule,
    String? typeJeu,
    String? agentId,
    String? succursaleId,
    String? tirageId,
    required bool global,
    required bool permanent,
    DateTime? expiresAt,
    required String createdBy,
  }) async {
    try {
      final id = CodeGenerator.firestoreId();
      await _col.doc(id).set({
        'boule':        boule,
        'typeJeu':      typeJeu,
        'agentId':      agentId,
        'succursaleId': succursaleId,
        'tirageId':     tirageId,
        'global':       global,
        'permanent':    permanent,
        'expiresAt':    expiresAt != null
                          ? Timestamp.fromDate(expiresAt)
                          : null,
        'createdBy':    createdBy,
        'createdAt':    FieldValue.serverTimestamp(),
      });
      return id;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> deleteBlocage(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<bool> isBlocageActif({
    required String boule,
    String? typeJeu,
    String? agentId,
  }) async {
    try {
      // Vérifie blocage global
      Query query = _col.where('boule', isEqualTo: boule)
          .where('global', isEqualTo: true);

      if (typeJeu != null) {
        query = query.where('typeJeu', isEqualTo: typeJeu);
      }

      final snap = await query.get();
      if (snap.docs.isNotEmpty) return true;

      // Vérifie blocage spécifique à l'agent
      if (agentId != null) {
        final agentSnap = await _col
            .where('boule',   isEqualTo: boule)
            .where('agentId', isEqualTo: agentId)
            .get();
        return agentSnap.docs.isNotEmpty;
      }

      return false;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}