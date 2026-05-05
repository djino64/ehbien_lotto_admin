// lib/features/notifications/domain/repositories/app_notifications_repository.dart

import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/entities/app_notification_entity.dart';

abstract class AppNotificationsRepository {
  Stream<List<AppNotificationEntity>> watchAllNotifications();
  Stream<List<AppNotificationEntity>> watchUnread();
  Future<EitherFailure<String>> sendNotification({
    String? agentId,
    required NotificationType type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  });
  Future<EitherVoid> markAsRead(String id);
  Future<EitherVoid> markAllAsRead();
  Future<EitherVoid> deleteNotification(String id);
  Future<EitherVoid> broadcastToAll({
    required NotificationType type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  });
}