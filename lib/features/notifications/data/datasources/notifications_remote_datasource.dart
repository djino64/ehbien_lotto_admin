// lib/features/notifications/data/datasources/notifications_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ehbien_lotto_admin/core/constants/firestore_paths.dart';
import 'package:ehbien_lotto_admin/core/errors/app_exception.dart';
import 'package:ehbien_lotto_admin/core/utils/code_generator.dart';
import 'package:ehbien_lotto_admin/features/notifications/data/models/app_notification_model.dart';

abstract class NotificationsRemoteDatasource {
  Stream<List<AppNotificationModel>> watchAllNotifications();
  Stream<List<AppNotificationModel>> watchUnread();
  Future<String> sendNotification({
    String? agentId,
    required String type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  });
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> broadcastToAll({
    required String type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  });
}

class NotificationsRemoteDatasourceImpl
    implements NotificationsRemoteDatasource {
  final FirebaseFirestore _firestore;

  NotificationsRemoteDatasourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference get _col =>
      _firestore.collection(FirestorePaths.notifications);

  @override
  Stream<List<AppNotificationModel>> watchAllNotifications() {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(AppNotificationModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Stream<List<AppNotificationModel>> watchUnread() {
    return _col
        .where('lu', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(AppNotificationModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Future<String> sendNotification({
    String? agentId,
    required String type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final id = CodeGenerator.firestoreId();
      await _col.doc(id).set({
        'agentId':   agentId,
        'type':      type,
        'titre':     titre,
        'message':   message,
        'lu':        false,
        'data':      data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
      return id;
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _col.doc(id).update({'lu': true});
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final snap = await _col
          .where('lu', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'lu': true});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }

  @override
  Future<void> broadcastToAll({
    required String type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // agentId = null signifie broadcast global
      await sendNotification(
        agentId: null,
        type:    type,
        titre:   titre,
        message: message,
        data:    data,
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Erreur', code: e.code);
    }
  }
}