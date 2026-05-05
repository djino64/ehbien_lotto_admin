// lib/features/dashboard/presentation/widgets/stats_row.dart

import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/cards/stat_card.dart';
import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final DashboardStatsEntity stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final cards  = _buildCards();

        if (isWide) {
          return Row(
            children: cards
                .map((c) => Expanded(child: c))
                .expand((w) => [w, const SizedBox(width: AppSpacing.md)])
                .toList()
              ..removeLast(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.4,
          children: cards,
        );
      },
    );
  }

  List<Widget> _buildCards() {
    return [
      StatCard(
        title:        'Ventes du jour',
        value:        stats.totalVentesJour.toCurrency,
        icon:         Icons.attach_money_rounded,
        color:        AppColors.primary,
        subtitle:     '${stats.totalTicketsJour} tickets vendus',
        trend:        '+12%',
        trendPositive: true,
      ),
      StatCard(
        title:        'Agents actifs',
        value:        '${stats.totalAgentsActifs}',
        icon:         Icons.group_rounded,
        color:        AppColors.info,
        subtitle:     'Sur le terrain aujourd\'hui',
      ),
      StatCard(
        title:        'Gains à payer',
        value:        stats.totalGainsAPayer.toCurrency,
        icon:         Icons.emoji_events_rounded,
        color:        AppColors.warning,
        subtitle:     'Tickets gagnants non payés',
        trend:        stats.totalGainsAPayer > 0 ? 'En attente' : null,
        trendPositive: false,
      ),
      StatCard(
        title:        'Recettes nettes',
        value:        stats.totalRecettes.toCurrency,
        icon:         Icons.account_balance_rounded,
        color:        AppColors.success,
        subtitle:     'Ventes - gains payés',
        trend:        '+8%',
        trendPositive: true,
      ),
      StatCard(
        title:        'Ventes semaine',
        value:        stats.totalVentesSemaine.toCurrency,
        icon:         Icons.calendar_view_week_rounded,
        color:        AppColors.primaryLight,
        subtitle:     'Cette semaine',
      ),
      StatCard(
        title:        'Tirages ouverts',
        value:        '${stats.totalTiragesOuverts}',
        icon:         Icons.access_time_filled_rounded,
        color:        AppColors.accent,
        subtitle:     'En cours actuellement',
      ),
    ];
  }
}

// ── Skeleton loader ───────────────────────────────────────────

class StatsRowSkeleton extends StatelessWidget {
  const StatsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(6, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: i < 5 ? AppSpacing.md : 0,
            ),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: _ShimmerBox(),
          ),
        );
      }),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.4, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_animation.value),
          borderRadius:
              BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
    );
  }
}