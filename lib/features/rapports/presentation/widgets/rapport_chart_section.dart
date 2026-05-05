// lib/features/rapports/presentation/widgets/rapport_chart_section.dart

import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/providers/rapports_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RapportChartSection extends ConsumerStatefulWidget {
  const RapportChartSection({super.key});

  @override
  ConsumerState<RapportChartSection> createState() =>
      _RapportChartSectionState();
}

class _RapportChartSectionState
    extends ConsumerState<RapportChartSection>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre + Onglets ────────────────────────────
            Row(
              children: [
                Container(
                  padding:    const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.insert_chart_rounded,
                    color: AppColors.primary,
                    size:  18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Graphiques',
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.primary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 320,
                  child: TabBar(
                    controller:          _tab,
                    labelColor:          AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor:      AppColors.primary,
                    labelStyle: const TextStyle(fontSize: 12),
                    tabs: const [
                      Tab(text: 'Ventes / jour'),
                      Tab(text: 'Par agent'),
                      Tab(text: 'Répartition'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Contenu ────────────────────────────────────
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tab,
                children: [
                  _VentesParJourChart(),
                  _VentesParAgentChart(),
                  _RepartitionPieChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Graphique ventes par jour ─────────────────────────────────

class _VentesParJourChart extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VentesParJourChart> createState() =>
      _VentesParJourChartState();
}

class _VentesParJourChartState
    extends ConsumerState<_VentesParJourChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(rapportStatsProvider);
    final data  = _buildData(stats);

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée pour cette période',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment:    BarChartAlignment.spaceAround,
        maxY:         _maxY(data) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              rod.toY.toCurrency,
              const TextStyle(
                color:      Colors.white,
                fontSize:   11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          touchCallback: (_, response) => setState(() {
            _touched =
                response?.spot?.touchedBarGroupIndex ?? -1;
          }),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[idx].label,
                    style: TextStyle(
                      fontSize: 10,
                      color:    Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 56,
              getTitlesWidget: (value, _) => Text(
                value.toCompact,
                style: TextStyle(
                  fontSize: 10,
                  color:    Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color:       Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        barGroups: data.asMap().entries.map((e) {
          final touched = e.key == _touched;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY:   e.value.value,
                color: touched ? AppColors.accent : AppColors.primary,
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show:  true,
                  toY:   _maxY(data) * 1.2,
                  color: Colors.grey.shade50,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<_ChartItem> _buildData(Map<String, dynamic> stats) {
    final raw =
        stats['ventesParJour'] as Map<String, double>? ?? {};
    if (raw.isEmpty) return [];
    final sorted = raw.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) {
      final parts = e.key.split('-');
      final day   = parts.length >= 3 ? parts[2] : e.key;
      return _ChartItem(label: day, value: e.value);
    }).toList();
  }

  double _maxY(List<_ChartItem> data) {
    if (data.isEmpty) return 100;
    return data
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
  }
}

// ── Graphique ventes par agent ────────────────────────────────

class _VentesParAgentChart extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VentesParAgentChart> createState() =>
      _VentesParAgentChartState();
}

class _VentesParAgentChartState
    extends ConsumerState<_VentesParAgentChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final stats  = ref.watch(rapportStatsProvider);
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];
    final raw    =
        stats['ventesParAgent'] as Map<String, double>? ?? {};

    if (raw.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Top 8 agents
    final sorted = raw.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(8).toList();

    final agentsMap = {for (final a in agents) a.id: a.nom};
    final maxVal    = top.first.value;

    return BarChart(
      BarChartData(
        alignment:    BarChartAlignment.spaceAround,
        maxY:         maxVal * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItem: (group, _, rod, __) {
              final name = agentsMap[top[group.x].key] ??
                  top[group.x].key.substring(0, 6);
              return BarTooltipItem(
                '$name\n${rod.toY.toCurrency}',
                const TextStyle(
                  color:    Colors.white,
                  fontSize: 11,
                ),
              );
            },
          ),
          touchCallback: (_, r) => setState(
            () => _touched = r?.spot?.touchedBarGroupIndex ?? -1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 32,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx >= top.length) return const SizedBox.shrink();
                final name =
                    agentsMap[top[idx].key] ?? top[idx].key;
                final short = name.length > 6
                    ? name.substring(0, 6)
                    : name;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    short,
                    style: TextStyle(
                      fontSize: 9,
                      color:    Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 52,
              getTitlesWidget: (v, _) => Text(
                v.toCompact,
                style: TextStyle(
                  fontSize: 10,
                  color:    Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color:       Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        barGroups: top.asMap().entries.map((e) {
          final isTouched = e.key == _touched;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY:   e.value.value,
                color: isTouched
                    ? AppColors.accent
                    : AppColors.chartPalette[
                        e.key % AppColors.chartPalette.length],
                width: 22,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Graphique répartition ─────────────────────────────────────

class _RepartitionPieChart extends ConsumerStatefulWidget {
  @override
  ConsumerState<_RepartitionPieChart> createState() =>
      _RepartitionPieChartState();
}

class _RepartitionPieChartState
    extends ConsumerState<_RepartitionPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(rapportStatsProvider);
    final total   = (stats['nombreTickets'] as int?) ?? 0;
    final gagnants = (stats['ticketsGagnants'] as int?) ?? 0;
    final perdants = (stats['ticketsPerdants'] as int?) ?? 0;
    final autres   = total - gagnants - perdants;

    if (total == 0) {
      return const Center(
        child: Text(
          'Aucun ticket pour cette période',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final sections = [
      _PieSection(
        label: 'Gagnants',
        value: gagnants.toDouble(),
        color: AppColors.warning,
      ),
      _PieSection(
        label: 'Perdants',
        value: perdants.toDouble(),
        color: Colors.grey.shade400,
      ),
      _PieSection(
        label: 'En cours',
        value: autres.toDouble(),
        color: AppColors.info,
      ),
    ].where((s) => s.value > 0).toList();

    return Row(
      children: [
        // Pie chart
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (_, r) => setState(
                  () => _touched =
                      r?.touchedSection?.touchedSectionIndex ?? -1,
                ),
              ),
              sections: sections.asMap().entries.map((e) {
                final isTouched = e.key == _touched;
                final pct =
                    (e.value.value / total * 100).toStringAsFixed(1);
                return PieChartSectionData(
                  value:  e.value.value,
                  color:  e.value.color,
                  radius: isTouched ? 90 : 80,
                  title:  '$pct%',
                  titleStyle: TextStyle(
                    fontSize:   isTouched ? 14 : 12,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace:     3,
            ),
          ),
        ),

        // Légende
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections.map((s) {
            final pct =
                (s.value / total * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width:  12,
                    height: 12,
                    decoration: BoxDecoration(
                      color:  s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.label,
                        style: const TextStyle(
                          fontSize:   12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${s.value.toInt()} ($pct%)',
                        style: TextStyle(
                          fontSize: 11,
                          color:    Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PieSection {
  final String label;
  final double value;
  final Color  color;
  const _PieSection({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _ChartItem {
  final String label;
  final double value;
  const _ChartItem({required this.label, required this.value});
}