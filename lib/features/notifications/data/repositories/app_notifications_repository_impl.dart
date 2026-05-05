// lib/features/notifications/data/repositories/app_notifications_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:ehbien_lotto_admin/core/errors/error_handler.dart';
import 'package:ehbien_lotto_admin/core/typedefs/typedefs.dart';
import 'package:ehbien_lotto_admin/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/repositories/app_notifications_repository.dart';

class AppNotificationsRepositoryImpl
    implements AppNotificationsRepository {
  final NotificationsRemoteDatasource _datasource;

  AppNotificationsRepositoryImpl(this._datasource);

  @override
  Stream<List<AppNotificationEntity>> watchAllNotifications() {
    return _datasource
        .watchAllNotifications()
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<AppNotificationEntity>> watchUnread() {
    return _datasource
        .watchUnread()
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<EitherFailure<String>> sendNotification({
    String? agentId,
    required NotificationType type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final id = await _datasource.sendNotification(
        agentId: agentId,
        type:    type.name,
        titre:   titre,
        message: message,
        data:    data,
      );
      return Right(id);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> markAsRead(String id) async {
    try {
      await _datasource.markAsRead(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> markAllAsRead() async {
    try {
      await _datasource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> deleteNotification(String id) async {
    try {
      await _datasource.deleteNotification(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<EitherVoid> broadcastToAll({
    required NotificationType type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _datasource.broadcastToAll(
        type:    type.name,
        titre:   titre,
        message: message,
        data:    data,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}