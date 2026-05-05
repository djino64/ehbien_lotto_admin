// lib/features/audit_logs/presentation/providers/audit_logs_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/audit_logs/data/models/audit_log_model.dart';
import 'package:ehbien_lotto_admin/features/audit_logs/domain/entities/audit_log_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Stream audit logs ─────────────────────────────────────────
final auditLogsStreamProvider =
    StreamProvider<List<AuditLogEntity>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.auditLogs)
      .orderBy('createdAt', descending: true)
      .limit(200)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => AuditLogModel.fromFirestore(d).toEntity())
          .toList());
});

// ── Filtre collection ─────────────────────────────────────────
final auditCollectionFilterProvider =
    StateProvider<String?>((ref) => null);

final auditLogsFilteredProvider =
    Provider<List<AuditLogEntity>>((ref) {
  final all        = ref.watch(auditLogsStreamProvider).valueOrNull ?? [];
  final collection = ref.watch(auditCollectionFilterProvider);
  if (collection == null) return all;
  return all.where((l) => l.collection == collection).toList();
});

// ── Helper : écrire un log ────────────────────────────────────
// Appelé depuis les autres notifiers après chaque action sensible
Future<void> writeAuditLog({
  required FirebaseFirestore firestore,
  required String userId,
  required String userEmail,
  required AuditAction action,
  required String collection,
  String? documentId,
  Map<String, dynamic>? before,
  Map<String, dynamic>? after,
}) async {
  try {
    await firestore.collection(FirestorePaths.auditLogs).add({
      'userId':     userId,
      'userEmail':  userEmail,
      'action':     action.name,
      'collection': collection,
      'documentId': documentId,
      'before':     before,
      'after':      after,
      'createdAt':  FieldValue.serverTimestamp(),
    });
  } catch (_) {
    // L'audit log ne doit jamais bloquer l'action principale
  }
}