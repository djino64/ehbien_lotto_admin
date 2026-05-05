// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/error_state.dart';
import 'package:ehbien_lotto_admin/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:ehbien_lotto_admin/features/dashboard/presentation/widgets/stats_row.dart';
import 'package:ehbien_lotto_admin/features/dashboard/presentation/widgets/sales_chart.dart';
import 'package:ehbien_lotto_admin/features/dashboard/presentation/widgets/recent_tickets_table.dart';
import 'package:ehbien_lotto_admin/features/dashboard/presentation/widgets/succursale_overview_card.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/providers/tirages_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh toutes les 5 minutes
    Future.delayed(const Duration(minutes: 5), _refresh);
  }

  void _refresh() {
    if (!mounted) return;
    ref.read(dashboardRefreshProvider.notifier).state++;
    Future.delayed(const Duration(minutes: 5), _refresh);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsRefreshableProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(dashboardRefreshProvider.notifier).state++;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            _DashboardHeader(onRefresh: _refresh),

            const SizedBox(height: AppSpacing.lg),

            // ── Stats cards ───────────────────────────────────
            statsAsync.when(
              loading: () => const StatsRowSkeleton(),
              error:   (e, _) => ErrorState(
                message: 'Impossible de charger les statistiques.',
                onRetry: _refresh,
              ),
              data: (stats) => StatsRow(stats: stats),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Graphiques + tirages ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Graphique ventes
                const Expanded(
                  flex: 3,
                  child: SalesChart(),
                ),
                const SizedBox(width: AppSpacing.md),
                // Tirages ouverts
                Expanded(
                  flex: 2,
                  child: _TiragesOuvertsCard(),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Tableau derniers tickets + succursales ────────
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: RecentTicketsTable(),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: SuccursaleOverviewCard(),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Header avec date et actions rapides ───────────────────────

class _DashboardHeader extends StatelessWidget {
  final VoidCallback onRefresh;

  const _DashboardHeader({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche',
    ];
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    final dateStr =
        '${weekdays[now.weekday - 1]} ${now.day} ${months[now.month - 1]} ${now.year}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Actualiser'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton.icon(
          onPressed: () => context.go(RouteNames.tiragesList),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Nouveau tirage'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tirages ouverts ───────────────────────────────────────────

class _TiragesOuvertsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiragesAsync = ref.watch(tiragesOuvertsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time_filled_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Tirages ouverts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(RouteNames.tiragesList),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            tiragesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => const Text('Erreur de chargement'),
              data: (tirages) {
                if (tirages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        'Aucun tirage ouvert',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Column(
                  children: tirages.take(5).map((t) {
                    return _TirageListTile(tirage: t);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TirageListTile extends StatelessWidget {
  final dynamic tirage;
  const _TirageListTile({required this.tirage});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.casino_rounded,
          color: AppColors.success,
          size: 18,
        ),
      ),
      title: Text(
        tirage.nom as String,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _formatTime(tirage.heurePrevu as DateTime),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Ouvert',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () => context.go(
        RouteNames.tiragesList,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}