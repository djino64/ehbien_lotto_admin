// lib/features/audit_logs/data/models/audit_log_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/features/audit_logs/domain/entities/audit_log_entity.dart';

class AuditLogModel {
  final String id;
  final String userId;
  final String userEmail;
  final String action;
  final String collection;
  final String? documentId;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final DateTime createdAt;

  const AuditLogModel({
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

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      id:           doc.id,
      userId:       d['userId']     as String? ?? '',
      userEmail:    d['userEmail']  as String? ?? '',
      action:       d['action']     as String? ?? 'update',
      collection:   d['collection'] as String? ?? '',
      documentId:   d['documentId'] as String?,
      before:       d['before'] != null
                      ? Map<String, dynamic>.from(d['before'] as Map)
                      : null,
      after:        d['after'] != null
                      ? Map<String, dynamic>.from(d['after'] as Map)
                      : null,
      createdAt:    (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AuditLogEntity toEntity() => AuditLogEntity(
    id:          id,
    userId:      userId,
    userEmail:   userEmail,
    action:      _parseAction(action),
    collection:  collection,
    documentId:  documentId,
    before:      before,
    after:       after,
    createdAt:   createdAt,
  );

  static AuditAction _parseAction(String a) => switch (a) {
    'create'  => AuditAction.create,
    'delete'  => AuditAction.delete,
    'login'   => AuditAction.login,
    'logout'  => AuditAction.logout,
    'publish' => AuditAction.publish,
    'block'   => AuditAction.block,
    'unblock' => AuditAction.unblock,
    _         => AuditAction.update,
  };
}