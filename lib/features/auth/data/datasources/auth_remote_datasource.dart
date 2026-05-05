import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/features/auth/data/models/auth_session_model.dart';

abstract class AuthRemoteDatasource {
  Stream<AuthSessionModel?> get authStateChanges;
  Future<AuthSessionModel> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AuthRemoteDatasourceImpl({required FirebaseAuth auth, required FirebaseFirestore firestore})
      : _auth = auth, _firestore = firestore;

  @override
  Stream<AuthSessionModel?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((u) async => u == null ? null : await _build(u));

  @override
  Future<AuthSessionModel> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final session = await _build(cred.user!);
      if (session.role != 'admin') {
        await _auth.signOut();
        throw const AuthException('Accès refusé. Compte non administrateur.', code: 'not-admin');
      }
      return session;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erreur auth', code: e.code);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try { await _auth.sendPasswordResetEmail(email: email); }
    on FirebaseAuthException catch (e) { throw AuthException(e.message ?? 'Erreur', code: e.code); }
  }

  Future<AuthSessionModel> _build(User user) async {
    final doc = await _firestore.collection(FirestorePaths.users).doc(user.uid).get();
    final role = doc.data()?['role'] as String? ?? 'vendeur';
    return AuthSessionModel.fromFirebase(user, role);
  }
}
