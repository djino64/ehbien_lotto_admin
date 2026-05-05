import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ehbien_lotto_admin/core/errors/failure.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';

class ErrorHandler {
  ErrorHandler._();
  static Failure handle(Object error) {
    if (error is FirebaseAuthException) return AuthFailure(_authMsg(error.code), code: error.code);
    if (error is FirebaseException)     return ServerFailure(error.message ?? 'Erreur Firestore', code: error.code);
    if (error is AuthException)         return AuthFailure(error.message, code: error.code);
    if (error is PermissionException)   return PermissionFailure(error.message, code: error.code);
    if (error is ValidationException)   return ValidationFailure(error.message, code: error.code);
    if (error is FirestoreException)    return ServerFailure(error.message, code: error.code);
    if (error is AppException)          return UnknownFailure(error.message, code: error.code);
    return const UnknownFailure('Une erreur inattendue est survenue.');
  }
  static String _authMsg(String? code) => switch (code) {
    'user-not-found'        => 'Aucun compte associé à cet identifiant.',
    'wrong-password'        => 'Mot de passe incorrect.',
    'invalid-email'         => 'Adresse email invalide.',
    'user-disabled'         => 'Ce compte a été désactivé.',
    'too-many-requests'     => 'Trop de tentatives. Réessayez plus tard.',
    'network-request-failed'=> 'Vérifiez votre connexion réseau.',
    _ => 'Erreur d\'authentification.',
  };
}
