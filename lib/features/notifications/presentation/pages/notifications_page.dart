// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:ehbien_lotto_admin/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/widgets/send_notification_dialog.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        final types = [
          null,
          NotificationType.message,
          NotificationType.tirage,
          NotificationType.resultat,
          NotificationType.gagnant,
          NotificationType.blocage,
        ];
        ref.read(notificationTypeFilterProvider.notifier).state =
            types[_tab.index];
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all         = ref.watch(notificationsStreamProvider).valueOrNull ?? [];
    final filtered    = ref.watch(notificationsFilteredProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final isLoading   = ref.watch(notificationsNotifierProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Toolbar ────────────────────────────────────────
        _NotificationsToolbar(
          unreadCount: unreadCount,
          onSend: () async {
            final sent = await SendNotificationDialog.show(context);
            if (sent == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Notification envoyée'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior:        SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          onMarkAllRead: () async {
            final ok = await ConfirmDialog.show(
              context,
              title:        'Tout marquer comme lu ?',
              message:      '$unreadCount notification${unreadCount > 1 ? 's' : ''} seront marquées comme lues.',
              confirmLabel: 'Confirmer',
            );
            if (ok == true) {
              await ref
                  .read(notificationsNotifierProvider.notifier)
                  .markAllAsRead();
            }
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Stats ──────────────────────────────────────────
        _NotificationsStats(notifications: all),

        const SizedBox(height: AppSpacing.md),

        // ── Onglets filtres ────────────────────────────────
        Card(
          child: TabBar(
            controller:          _tab,
            labelColor:          AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor:      AppColors.primary,
            isScrollable:        true,
            tabAlignment:        TabAlignment.start,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'Toutes (${all.length})'),
              const Tab(text: 'Messages'),
              const Tab(text: 'Tirages'),
              const Tab(text: 'Résultats'),
              const Tab(text: 'Gagnants'),
              const Tab(text: 'Blocages'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Liste ──────────────────────────────────────────
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const EmptyState(
                      icon:    Icons.notifications_off_rounded,
                      message: 'Aucune notification',
                    )
                  : ListView.separated(
                      itemCount:    filtered.length,
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.xl,
                      ),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) =>
                          NotificationTile(notification: filtered[i]),
                    ),
        ),
      ],
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────

class _NotificationsToolbar extends StatelessWidget {
  final int          unreadCount;
  final VoidCallback onSend;
  final VoidCallback onMarkAllRead;

  const _NotificationsToolbar({
    required this.unreadCount,
    required this.onSend,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical:   AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color:        AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.mark_email_unread_rounded,
                  size:  16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 6),
                Text(
                  '$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize:   13,
                    color:      AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        if (unreadCount > 0)
          OutlinedButton.icon(
            onPressed: onMarkAllRead,
            icon:  const Icon(Icons.done_all_rounded, size: 16),
            label: const Text('Tout marquer lu'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: const BorderSide(
                color: AppColors.success,
              ),
            ),
          ),

        const SizedBox(width: AppSpacing.sm),

        ElevatedButton.icon(
          onPressed: onSend,
          icon:  const Icon(Icons.send_rounded, size: 16),
          label: const Text('Nouvelle notification'),
        ),
      ],
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────

class _NotificationsStats extends StatelessWidget {
  final List<AppNotificationEntity> notifications;

  const _NotificationsStats({required this.notifications});

  @override
  Widget build(BuildContext context) {
    final total      = notifications.length;
    final nonLues    = notifications.where((n) => !n.lu).length;
    final broadcasts = notifications.where((n) => n.isBroadcast).length;
    final gagnants   = notifications
        .where((n) => n.type == NotificationType.gagnant)
        .length;

    return Wrap(
      spacing:    AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatPill(
          label: 'Total',
          value: '$total',
          color: AppColors.primary,
          icon:  Icons.notifications_rounded,
        ),
        _StatPill(
          label: 'Non lues',
          value: '$nonLues',
          color: AppColors.info,
          icon:  Icons.mark_email_unread_rounded,
        ),
        _StatPill(
          label: 'Broadcasts',
          value: '$broadcasts',
          color: AppColors.warning,
          icon:  Icons.public_rounded,
        ),
        _StatPill(
          label: 'Gagnants',
          value: '$gagnants',
          color: AppColors.success,
          icon:  Icons.star_rounded,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String   label;
  final String   value;
  final Color    color;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical:   AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w800,
              color:      color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color:    color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}