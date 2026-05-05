// lib/features/rapports/presentation/pages/rapports_page.dart
import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/providers/rapports_provider.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/widgets/export_button_bar.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/widgets/rapport_chart_section.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/widgets/rapport_filter_panel.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RapportsPage extends ConsumerWidget {
  const RapportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(rapportTicketsProvider).isLoading;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RapportFilterPanel(),
          const SizedBox(height: AppSpacing.md),

          if (isLoading)
            const LinearProgressIndicator()
          else
            const _KpiRow(),

          const SizedBox(height: AppSpacing.md),
          const ExportButtonBar(),
          const SizedBox(height: AppSpacing.md),
          const RapportChartSection(),
          const SizedBox(height: AppSpacing.md),

          const _AgentsTable(),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── KPIs ─────────────────────────────────

class _KpiRow extends ConsumerWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(rapportStatsProvider);

    final totalVentes    = (stats['totalVentes'] as double?) ?? 0.0;
    final totalGains     = (stats['totalGains'] as double?) ?? 0.0;
    final totalRecettes  = (stats['totalRecettes'] as double?) ?? 0.0;
    final nombreTickets  = (stats['nombreTickets'] as int?) ?? 0;
    final gagnants       = (stats['ticketsGagnants'] as int?) ?? 0;
    final tauxGagnant    = (stats['tauxGagnant'] as double?) ?? 0.0;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.4,
      children: [
        _KpiCard(
          title: 'Total ventes',
          value: totalVentes.toCurrency,
          icon: Icons.attach_money_rounded,
          color: AppColors.primary,
          subtitle: '$nombreTickets tickets',
        ),
        _KpiCard(
          title: 'Total gains payés',
          value: totalGains.toCurrency,
          icon: Icons.emoji_events_rounded,
          color: AppColors.warning,
          subtitle: '$gagnants tickets gagnants',
        ),
        _KpiCard(
          title: 'Recette nette',
          value: totalRecettes.toCurrency,
          icon: Icons.account_balance_rounded,
          color: AppColors.success,
          subtitle: 'Ventes − gains',
        ),
        _KpiCard(
          title: 'Tickets vendus',
          value: '$nombreTickets',
          icon: Icons.confirmation_number_rounded,
          color: AppColors.info,
          subtitle: 'Sur la période',
        ),
        _KpiCard(
          title: 'Taux de gain',
          value: '${(tauxGagnant * 100).toStringAsFixed(1)}%',
          icon: Icons.percent_rounded,
          color: AppColors.primaryLight,
          subtitle: '$gagnants / $nombreTickets tickets',
        ),
        _KpiCard(
          title: 'Gain moyen',
          value: gagnants > 0
              ? (totalGains / gagnants).toCurrency
              : '—',
          icon: Icons.calculate_rounded,
          color: AppColors.accent,
          subtitle: 'Par ticket gagnant',
        ),
      ],
    );
  }
}

// ── KPI CARD ─────────────────────────────

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── TABLE AGENTS ─────────────────────────

class _AgentsTable extends ConsumerWidget {
  const _AgentsTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(rapportStatsProvider);
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];

    final raw = stats['ventesParAgent'] as Map<String, double>? ?? {};
    if (raw.isEmpty) return const SizedBox.shrink();

    final sorted = raw.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topAgents = sorted.take(20).toList(); // Mwen fikse bug la ici en limitant à 20 agents pour éviter une liste trop longue

    final agentsMap = {for (final a in agents) a.id: a};
    final total = raw.values.fold(0.0, (s, v) => s + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const Text('Classement des agents'),

            const SizedBox(height: AppSpacing.md),

            ...topAgents.asMap().entries.map((e) {
              final rank = e.key + 1;
              final entry = e.value;
              final agent = agentsMap[entry.key];

              final ventes = entry.value;
              final pct = total > 0 ? ventes / total : 0.0;

              return ListTile(
                title: Text(agent?.nom ?? 'Agent'),
                subtitle: Text(agent?.succursaleNom ?? ''),
                trailing: Text('${(pct * 100).toStringAsFixed(1)}%'),
              );
            }),
          ],
        ),
      ),
    );
  }
}