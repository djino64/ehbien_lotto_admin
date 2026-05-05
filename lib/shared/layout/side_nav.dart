// lib/shared/layout/side_nav.dart

import 'package:ehbien_lotto_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SideNav extends ConsumerWidget {
  const SideNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location    = GoRouterState.of(context).matchedLocation;
    final unreadCount = ref.watch(unreadCountProvider);

    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // ── Header avec logo ───────────────────────────
          const _SideNavHeader(),

          // ── Items de navigation ────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              children: [

                // ── Dashboard ────────────────────────────
                _NavItem(
                  icon:  Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: RouteNames.dashboard,
                  loc:   location,
                ),

                // ── Section GESTION ───────────────────────
                const _NavSection('GESTION'),

                _NavItem(
                  icon:  Icons.group_rounded,
                  label: 'Agents',
                  route: RouteNames.agentsList,
                  loc:   location,
                ),
                _NavItem(
                  icon:  Icons.store_mall_directory_rounded,
                  label: 'Succursales',
                  route: RouteNames.succursalesList,
                  loc:   location,
                ),
                _NavItem(
                  icon:  Icons.receipt_long_rounded,
                  label: 'Tickets',
                  route: RouteNames.ticketsList,
                  loc:   location,
                ),
                _NavItem(
                  icon:  Icons.access_time_filled_rounded,
                  label: 'Tirages',
                  route: RouteNames.tiragesList,
                  loc:   location,
                ),
                _NavItem(
                  icon:  Icons.attach_money_rounded,
                  label: 'Ventes',
                  route: RouteNames.ventes,
                  loc:   location,
                ),

                // ── Section CONTRÔLE ──────────────────────
                const _NavSection('CONTRÔLE'),

                _NavItem(
                  icon:  Icons.block_rounded,
                  label: 'Blocages',
                  route: RouteNames.blocages,
                  loc:   location,
                ),
                _NavItem(
                  icon:  Icons.tune_rounded,
                  label: 'Limites',
                  route: RouteNames.limits,
                  loc:   location,
                ),
                _NavItem(
                  icon:  Icons.workspace_premium_rounded,
                  label: 'Primes',
                  route: RouteNames.primes,
                  loc:   location,
                ),

                // ── Section ANALYSE ───────────────────────
                const _NavSection('ANALYSE'),

                _NavItem(
                  icon:  Icons.insert_chart_rounded,
                  label: 'Rapports',
                  route: RouteNames.rapports,
                  loc:   location,
                ),

                // Notifications avec badge dynamique
                _NavItemWithBadge(
                  icon:       Icons.notifications_active_rounded,
                  label:      'Notifications',
                  route:      RouteNames.notifications,
                  loc:        location,
                  badgeCount: unreadCount,
                ),

                _NavItem(
                  icon:  Icons.manage_search_rounded,
                  label: 'Audit logs',
                  route: RouteNames.auditLogs,
                  loc:   location,
                ),

                // ── Section SYSTÈME ───────────────────────
                const _NavSection('SYSTÈME'),

                _NavItem(
                  icon:  Icons.admin_panel_settings_rounded,
                  label: 'Utilisateurs',
                  route: RouteNames.usersList,
                  loc:   location,
                ),
                _NavItem(
                  icon:  Icons.settings_rounded,
                  label: 'Paramètres',
                  route: RouteNames.settings,
                  loc:   location,
                ),
              ],
            ),
          ),

          // ── Footer ──────────────────────────────────────
          const _SideNavFooter(),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────

class _SideNavHeader extends StatelessWidget {
  const _SideNavHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width:  36,
              height: 36,
              fit:    BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color:        AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.casino_rounded,
                  color: Colors.white,
                  size:  20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ehbien Lotto',
                  style: TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize:   14,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Administration',
                  style: TextStyle(
                    color:    AppColors.sidebarText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────

class _NavSection extends StatelessWidget {
  final String label;
  const _NavSection(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color:       AppColors.sidebarText,
          fontSize:    10,
          fontWeight:  FontWeight.w600,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ── Item de navigation standard ───────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   route;
  final String   loc;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.loc,
  });

  bool get _active =>
      route == '/' ? loc == '/' : loc.startsWith(route);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical:   1,
      ),
      child: Material(
        color: _active
            ? Colors.white.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor:   Colors.white.withOpacity(0.06),
          onTap:        () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical:   10,
            ),
            child: Row(
              children: [
                // Indicateur actif
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  3,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: _active
                        ? AppColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  icon,
                  size:  18,
                  color: _active
                      ? Colors.white
                      : AppColors.sidebarText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: _active
                          ? Colors.white
                          : AppColors.sidebarText,
                      fontSize:   13,
                      fontWeight: _active
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Item de navigation avec badge ─────────────────────────────

class _NavItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   route;
  final String   loc;
  final int      badgeCount;

  const _NavItemWithBadge({
    required this.icon,
    required this.label,
    required this.route,
    required this.loc,
    required this.badgeCount,
  });

  bool get _active =>
      route == '/' ? loc == '/' : loc.startsWith(route);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical:   1,
      ),
      child: Material(
        color: _active
            ? Colors.white.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor:   Colors.white.withOpacity(0.06),
          onTap:        () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical:   10,
            ),
            child: Row(
              children: [
                // Indicateur actif
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  3,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: _active
                        ? AppColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  icon,
                  size:  18,
                  color: _active
                      ? Colors.white
                      : AppColors.sidebarText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: _active
                          ? Colors.white
                          : AppColors.sidebarText,
                      fontSize:   13,
                      fontWeight: _active
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical:   2,
                    ),
                    decoration: BoxDecoration(
                      color:        AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────

class _SideNavFooter extends ConsumerWidget {
  const _SideNavFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;

    final displayName = session?.email.split('@').first ?? 'Admin';
    final shortName   = displayName.length > 14
        ? displayName.substring(0, 14)
        : displayName;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                shortName.isNotEmpty
                    ? shortName[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                  color:      Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize:   16,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:       MainAxisSize.min,
              children: [
                Text(
                  shortName,
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Super Admin',
                  style: TextStyle(
                    color:    AppColors.sidebarText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Déconnexion
          Tooltip(
            message: 'Déconnexion',
            child: InkWell(
              onTap: () async {
                await ref
                    .read(authNotifierProvider.notifier)
                    .signOut();
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.logout_rounded,
                  size:  16,
                  color: AppColors.sidebarText.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}