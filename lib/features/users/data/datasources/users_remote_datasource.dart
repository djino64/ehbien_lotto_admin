// lib/features/users/data/datasources/users_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/features/users/data/models/user_model.dart';

abstract class UsersRemoteDatasource {
  Stream<List<UserModel>> watchAllUsers();
  Future<UserModel> getUserById(String uid);
  Future<void> updateUserStatus(String uid, String status);
  Future<void> updateUserRole(String uid, String role);
  Future<void> deleteUser(String uid);
}

class UsersRemoteDatasourceImpl implements UsersRemoteDatasource {
  final FirebaseFirestore _firestore;

  UsersRemoteDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.users);

  @override
  Stream<List<UserModel>> watchAllUsers() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map(UserModel.fromFirestore)
            .toList());
  }

  @override
  Future<UserModel> getUserById(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) {
        throw const FirestoreException(
          'Utilisateur introuvable.',
          code: 'not-found',
        );
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur Firestore', code: e.code);
    }
  }

  @override
  Future<void> updateUserStatus(String uid, String status) async {
    try {
      await _col.doc(uid).update({
        'status':    status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _col.doc(uid).update({
        'role':      role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _col.doc(uid).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}