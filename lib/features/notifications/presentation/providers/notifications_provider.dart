// lib/features/notifications/presentation/providers/notifications_provider.dart

import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:ehbien_lotto_admin/features/notifications/data/repositories/app_notifications_repository_impl.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/repositories/app_notifications_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Datasource ────────────────────────────────────────────────
final notificationsDatasourceProvider =
    Provider<NotificationsRemoteDatasource>((ref) {
  return NotificationsRemoteDatasourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────
final notificationsRepositoryProvider =
    Provider<AppNotificationsRepository>((ref) {
  return AppNotificationsRepositoryImpl(
    ref.watch(notificationsDatasourceProvider),
  );
});

// ── Stream toutes les notifications ──────────────────────────
final notificationsStreamProvider =
    StreamProvider<List<AppNotificationEntity>>((ref) {
  return ref
      .watch(notificationsRepositoryProvider)
      .watchAllNotifications();
});

// ── Stream non lues ───────────────────────────────────────────
final unreadNotificationsProvider =
    StreamProvider<List<AppNotificationEntity>>((ref) {
  return ref.watch(notificationsRepositoryProvider).watchUnread();
});

// ── Compteur non lues ─────────────────────────────────────────
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(unreadNotificationsProvider).valueOrNull?.length ?? 0;
});

// ── Filtre type ───────────────────────────────────────────────
final notificationTypeFilterProvider =
    StateProvider<NotificationType?>((ref) => null);

final notificationsFilteredProvider =
    Provider<List<AppNotificationEntity>>((ref) {
  final all    = ref.watch(notificationsStreamProvider).valueOrNull ?? [];
  final filter = ref.watch(notificationTypeFilterProvider);
  if (filter == null) return all;
  return all.where((n) => n.type == filter).toList();
});

// ── Notifier ──────────────────────────────────────────────────
class NotificationsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> send({
    String? agentId,
    required NotificationType type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(notificationsRepositoryProvider)
        .sendNotification(
          agentId: agentId,
          type:    type,
          titre:   titre,
          message: message,
          data:    data,
        );
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> broadcast({
    required NotificationType type,
    required String titre,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(notificationsRepositoryProvider)
        .broadcastToAll(
          type:    type,
          titre:   titre,
          message: message,
          data:    data,
        );
    state = const AsyncData(null);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<void> markAsRead(String id) async {
    await ref
        .read(notificationsRepositoryProvider)
        .markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await ref
        .read(notificationsRepositoryProvider)
        .markAllAsRead();
  }

  Future<void> delete(String id) async {
    await ref
        .read(notificationsRepositoryProvider)
        .deleteNotification(id);
  }
}

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, void>(
  NotificationsNotifier.new,
);