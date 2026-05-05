// lib/features/agents/data/datasources/agents_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/core/utils/code_generator.dart';
import 'package:ehbien_lotto_admin/features/agents/data/models/agent_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AgentsRemoteDatasource {
  Stream<List<AgentModel>> watchAllAgents();
  Stream<List<AgentModel>> watchAgentsBySuccursale(String succursaleId);
  Future<AgentModel> getAgentById(String id);
  Future<AgentModel?> getAgentByUserId(String userId);
  Future<String> createAgent({
    required String nom,
    required String phone,
    required String succursaleId,
    required String motDePasseTemp,
    required double limiteJournaliere,
  });
  Future<void> updateAgent({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<void> updateAgentStatus(String id, String status);
  Future<void> resetPassword(String userId, String newPassword);
  Future<void> deleteAgent(String id);
}

class AgentsRemoteDatasourceImpl implements AgentsRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth     _auth;

  AgentsRemoteDatasourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth      auth,
  })  : _firestore = firestore,
        _auth      = auth;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.agents);

  @override
  Stream<List<AgentModel>> watchAllAgents() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(AgentModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Stream<List<AgentModel>> watchAgentsBySuccursale(
      String succursaleId) {
    return _col
        .where('succursaleId', isEqualTo: succursaleId)
        .orderBy('nom')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(AgentModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Future<AgentModel> getAgentById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) {
        throw const FirestoreException(
          'Agent introuvable.',
          code: 'not-found',
        );
      }
      return AgentModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<AgentModel?> getAgentByUserId(String userId) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return AgentModel.fromFirestore(snap.docs.first);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<String> createAgent({
    required String nom,
    required String phone,
    required String succursaleId,
    required String motDePasseTemp,
    required double limiteJournaliere,
  }) async {
    try {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      final email  = '$digits@ehbienlotto.com';

      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email,
        password: motDePasseTemp,
      );
      final userId = credential.user!.uid;

      await _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .set({
        'phone':     phone,
        'role':      'vendeur',
        'status':    'actif',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final agentId = CodeGenerator.firestoreId();
      await _col.doc(agentId).set({
        'userId':            userId,
        'succursaleId':      succursaleId,
        'nom':               nom,
        'phone':             phone,
        'status':            'actif',
        'limiteJournaliere': limiteJournaliere,
        'motDePasseTemp':    true,
        'createdAt':         FieldValue.serverTimestamp(),
        'updatedAt':         FieldValue.serverTimestamp(),
      });

      return agentId;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Erreur création',
        code: e.code,
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> updateAgent({
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
  Future<void> updateAgentStatus(String id, String status) async {
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
  Future<void> resetPassword(String userId, String newPassword) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .get();
      final email = doc.data()?['email'] as String?;
      if (email != null && email.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
      }
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> deleteAgent(String id) async {
    try {
      await _col.doc(id).update({
        'status':    'inactif',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}