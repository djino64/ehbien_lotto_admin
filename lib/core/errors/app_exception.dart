class AppException implements Exception {
  final String message;
  final String? code;
  final Object? original;
  const AppException(this.message, {this.code, this.original});
  @override
  String toString() => 'AppException($code): $message';
}
class AuthException      extends AppException { const AuthException(super.m, {super.code, super.original}); }
class FirestoreException extends AppException { const FirestoreException(super.m, {super.code, super.original}); }
class PermissionException extends AppException { const PermissionException(super.m, {super.code, super.original}); }
class ValidationException extends AppException { const ValidationException(super.m, {super.code, super.original}); }
