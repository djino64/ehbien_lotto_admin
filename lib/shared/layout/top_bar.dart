// lib/shared/layout/top_bar.dart

import 'package:ehbien_lotto_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location    = GoRouterState.of(context).matchedLocation;
    final session     = ref.watch(authSessionProvider).valueOrNull;
    final unreadCount = ref.watch(unreadCountProvider);

    return Container(
      height: AppSpacing.topBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // ── Icône + Titre de la page ───────────────────
          Icon(
            _pageIcon(location),
            size:  20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _pageTitle(location),
            style: const TextStyle(
              fontSize:   17,
              fontWeight: FontWeight.w700,
              color:      AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),

          const Spacer(),

          // ── Actions ───────────────────────────────────
          _TopBarIconButton(
            icon:       Icons.notifications_outlined,
            badge:      unreadCount > 0,
            badgeCount: unreadCount,
            tooltip:    'Notifications',
            onTap:      () => context.go(RouteNames.notifications),
          ),

          const SizedBox(width: AppSpacing.xs),

          _TopBarIconButton(
            icon:    Icons.insert_chart_outlined_rounded,
            tooltip: 'Rapports',
            onTap:   () => context.go(RouteNames.rapports),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Séparateur ────────────────────────────────
          Container(
            width:  1,
            height: 28,
            color:  Colors.grey.shade200,
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Avatar + infos admin ───────────────────────
          _AdminAvatar(
            email:  session?.email,
            onTap:  () => context.go(RouteNames.settings),
          ),
        ],
      ),
    );
  }

  IconData _pageIcon(String loc) => switch (true) {
    _ when loc == '/'                        => Icons.dashboard_rounded,
    _ when loc.startsWith('/agents')         => Icons.group_rounded,
    _ when loc.startsWith('/succursales')    => Icons.store_mall_directory_rounded,
    _ when loc.startsWith('/tickets')        => Icons.receipt_long_rounded,
    _ when loc.startsWith('/tirages')        => Icons.access_time_filled_rounded,
    _ when loc.startsWith('/ventes')         => Icons.attach_money_rounded,
    _ when loc.startsWith('/blocages')       => Icons.block_rounded,
    _ when loc.startsWith('/limits')         => Icons.tune_rounded,
    _ when loc.startsWith('/primes')         => Icons.workspace_premium_rounded,
    _ when loc.startsWith('/rapports')       => Icons.insert_chart_rounded,
    _ when loc.startsWith('/notifications')  => Icons.notifications_active_rounded,
    _ when loc.startsWith('/audit-logs')     => Icons.manage_search_rounded,
    _ when loc.startsWith('/users')          => Icons.admin_panel_settings_rounded,
    _ when loc.startsWith('/settings')       => Icons.settings_rounded,
    _                                        => Icons.circle_rounded,
  };

  String _pageTitle(String loc) => switch (true) {
    _ when loc == '/'                        => 'Dashboard',
    _ when loc.startsWith('/agents')         => 'Agents',
    _ when loc.startsWith('/succursales')    => 'Succursales',
    _ when loc.startsWith('/tickets')        => 'Tickets',
    _ when loc.startsWith('/tirages')        => 'Tirages',
    _ when loc.startsWith('/ventes')         => 'Ventes',
    _ when loc.startsWith('/blocages')       => 'Blocages',
    _ when loc.startsWith('/limits')         => 'Limites',
    _ when loc.startsWith('/primes')         => 'Primes',
    _ when loc.startsWith('/rapports')       => 'Rapports',
    _ when loc.startsWith('/notifications')  => 'Notifications',
    _ when loc.startsWith('/audit-logs')     => 'Audit logs',
    _ when loc.startsWith('/users')          => 'Utilisateurs',
    _ when loc.startsWith('/settings')       => 'Paramètres',
    _                                        => 'Ehbien Admin',
  };
}

// ── Bouton icône avec badge optionnel ─────────────────────────

class _TopBarIconButton extends StatelessWidget {
  final IconData     icon;
  final String       tooltip;
  final VoidCallback onTap;
  final bool         badge;
  final int          badgeCount;

  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge      = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor:   Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size:  22,
                color: Colors.grey.shade600,
              ),
              if (badge && badgeCount > 0)
                Positioned(
                  top:   -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth:  16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar admin ──────────────────────────────────────────────

class _AdminAvatar extends ConsumerWidget {
  final String?      email;
  final VoidCallback onTap;

  const _AdminAvatar({
    required this.email,
    required this.onTap,
  });

  String get _displayName {
    if (email == null) return 'Admin';
    final local = email!.split('@').first;
    return local.length > 12 ? local.substring(0, 12) : local;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical:   AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              width:  34,
              height: 34,
              decoration: BoxDecoration(
                color:        AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_rounded,
                size:  18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.primary,
                  ),
                ),
                const Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 10,
                    color:    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size:  16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}