import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
  @override
  List<Object?> get props => [message, code];
}
class ServerFailure     extends Failure { const ServerFailure(super.m, {super.code}); }
class AuthFailure       extends Failure { const AuthFailure(super.m, {super.code}); }
class PermissionFailure extends Failure { const PermissionFailure(super.m, {super.code}); }
class NotFoundFailure   extends Failure { const NotFoundFailure(super.m, {super.code}); }
class ValidationFailure extends Failure { const ValidationFailure(super.m, {super.code}); }
class NetworkFailure    extends Failure { const NetworkFailure(super.m, {super.code}); }
class UnknownFailure    extends Failure { const UnknownFailure(super.m, {super.code}); }
