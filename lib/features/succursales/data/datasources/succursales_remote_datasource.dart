// lib/features/succursales/data/datasources/succursales_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/core/utils/code_generator.dart';
import 'package:ehbien_lotto_admin/features/succursales/data/models/succursale_model.dart';

abstract class SuccursalesRemoteDatasource {
  Stream<List<SuccursaleModel>> watchAllSuccursales();
  Future<SuccursaleModel> getSuccursaleById(String id);
  Future<String> createSuccursale({
    required String nom,
    required String adresse,
    String? telephone,
  });
  Future<void> updateSuccursale({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<void> updateSuccursaleStatus(String id, String status);
  Future<void> deleteSuccursale(String id);
}

class SuccursalesRemoteDatasourceImpl implements SuccursalesRemoteDatasource {
  final FirebaseFirestore _firestore;

  SuccursalesRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.succursales);

  @override
  Stream<List<SuccursaleModel>> watchAllSuccursales() {
    return _col
        .orderBy('nom')
        .snapshots()
        .map((snap) =>
            snap.docs.map(SuccursaleModel.fromFirestore).toList());
  }

  @override
  Future<SuccursaleModel> getSuccursaleById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) {
        throw const FirestoreException(
            'Succursale introuvable.', code: 'not-found');
      }
      return SuccursaleModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<String> createSuccursale({
    required String nom,
    required String adresse,
    String? telephone,
  }) async {
    try {
      final id = CodeGenerator.firestoreId();
      await _col.doc(id).set({
        'nom':       nom,
        'adresse':   adresse,
        'telephone': telephone,
        'status':    'actif',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return id;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> updateSuccursale({
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
  Future<void> updateSuccursaleStatus(String id, String status) async {
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
  Future<void> deleteSuccursale(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}