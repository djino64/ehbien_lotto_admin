// lib/features/audit_logs/domain/entities/audit_log_entity.dart

import 'package:equatable/equatable.dart';

enum AuditAction {
  create,
  update,
  delete,
  login,
  logout,
  publish,
  block,
  unblock,
}

class AuditLogEntity extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final AuditAction action;
  final String collection;
  final String? documentId;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final DateTime createdAt;

  const AuditLogEntity({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.action,
    required this.collection,
    this.documentId,
    this.before,
    this.after,
    required this.createdAt,
  });

  String get actionLabel => switch (action) {
    AuditAction.create  => 'Création',
    AuditAction.update  => 'Modification',
    AuditAction.delete  => 'Suppression',
    AuditAction.login   => 'Connexion',
    AuditAction.logout  => 'Déconnexion',
    AuditAction.publish => 'Publication',
    AuditAction.block   => 'Blocage',
    AuditAction.unblock => 'Déblocage',
  };

  @override
  List<Object?> get props =>
      [id, userId, action, collection, createdAt];
}