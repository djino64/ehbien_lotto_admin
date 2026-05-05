// lib/features/notifications/presentation/widgets/notification_tile.dart

import 'package:ehbien_lotto_admin/core/extensions/datetime_ext.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationTile extends ConsumerWidget {
  final AppNotificationEntity notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (color, icon) = _typeStyle(notification.type);

    return Dismissible(
      key:       Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color:        AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: AppColors.danger,
        ),
      ),
      onDismissed: (_) => ref
          .read(notificationsNotifierProvider.notifier)
          .delete(notification.id),
      child: InkWell(
        onTap: () {
          if (!notification.lu) {
            ref
                .read(notificationsNotifierProvider.notifier)
                .markAsRead(notification.id);
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: notification.lu
                ? Colors.transparent
                : color.withOpacity(0.04),
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: notification.lu
                  ? Colors.grey.shade100
                  : color.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icône type ───────────────────────────
              Container(
                width:  40,
                height: 40,
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── Contenu ──────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: TextStyle(
                              fontSize:   13,
                              fontWeight: notification.lu
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color:      AppColors.primary,
                            ),
                          ),
                        ),
                        if (!notification.lu)
                          Container(
                            width:  8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color:    Colors.grey.shade600,
                        height:   1.4,
                      ),
                      maxLines:  2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical:   2,
                          ),
                          decoration: BoxDecoration(
                            color:        color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _typeLabel(notification.type),
                            style: TextStyle(
                              fontSize:   10,
                              color:      color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Date
                        Text(
                          notification.createdAt.toDisplayDateTime,
                          style: TextStyle(
                            fontSize: 10,
                            color:    Colors.grey.shade400,
                          ),
                        ),

                        // Broadcast badge
                        if (notification.isBroadcast) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical:   2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size:  10,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Tous',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color:    Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, IconData) _typeStyle(NotificationType t) => switch (t) {
    NotificationType.tirage   => (AppColors.info,    Icons.access_time_filled_rounded),
    NotificationType.resultat => (AppColors.success, Icons.emoji_events_rounded),
    NotificationType.gagnant  => (AppColors.warning, Icons.star_rounded),
    NotificationType.blocage  => (AppColors.danger,  Icons.block_rounded),
    NotificationType.message  => (AppColors.primary, Icons.message_rounded),
  };

  String _typeLabel(NotificationType t) => switch (t) {
    NotificationType.tirage   => 'Tirage',
    NotificationType.resultat => 'Résultat',
    NotificationType.gagnant  => 'Gagnant',
    NotificationType.blocage  => 'Blocage',
    NotificationType.message  => 'Message',
  };
}