// lib/features/dashboard/presentation/widgets/sales_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/providers/rapports_provider.dart';

class SalesChart extends ConsumerStatefulWidget {
  const SalesChart({super.key});

  @override
  ConsumerState<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends ConsumerState<SalesChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final stats   = ref.watch(rapportStatsProvider);
    final barData = _buildBarData(stats);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre ──────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.insert_chart_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Ventes du mois',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                _ChartLegend(),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Chart ──────────────────────────────────────
            SizedBox(
              height: 220,
              child: barData.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune donnée pour ce mois',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _maxY(barData),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppColors.primary,
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, _, rod, __) {
                              return BarTooltipItem(
                                'G ${rod.toY.toStringAsFixed(0)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          touchCallback: (event, response) {
                            setState(() {
                              _touchedIndex = response
                                      ?.spot?.touchedBarGroupIndex ??
                                  -1;
                            });
                          },
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
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= barData.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    barData[idx].label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 24,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 48,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _formatY(value),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _maxY(barData) / 4,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade100,
                            strokeWidth: 1,
                          ),
                        ),
                        barGroups: barData.asMap().entries.map((e) {
                          final isTouched = e.key == _touchedIndex;
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY:   e.value.value,
                                color: isTouched
                                    ? AppColors.accent
                                    : AppColors.primary,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                backDrawRodData:
                                    BackgroundBarChartRodData(
                                  show: true,
                                  toY: _maxY(barData),
                                  color: Colors.grey.shade50,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_BarItem> _buildBarData(Map<String, dynamic> stats) {
    final ventesParJour =
        stats['ventesParJour'] as Map<String, double>? ?? {};
    if (ventesParJour.isEmpty) return [];

    final sorted = ventesParJour.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sorted.map((e) {
      final parts = e.key.split('-');
      final day   = parts.length >= 3 ? parts[2] : e.key;
      return _BarItem(label: day, value: e.value);
    }).toList();
  }

  double _maxY(List<_BarItem> data) {
    if (data.isEmpty) return 100;
    final max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  String _formatY(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}

class _BarItem {
  final String label;
  final double value;
  const _BarItem({required this.label, required this.value});
}

class _ChartLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: AppColors.primary, label: 'Ventes'),
        SizedBox(width: AppSpacing.sm),
        _LegendDot(color: AppColors.accent, label: 'Sélectionné'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color  color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color:  color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}