// lib/features/rapports/presentation/widgets/rapport_filter_panel.dart

import 'package:ehbien_lotto_admin/features/rapports/presentation/providers/rapports_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RapportFilterPanel extends ConsumerStatefulWidget {
  const RapportFilterPanel({super.key});

  @override
  ConsumerState<RapportFilterPanel> createState() =>
      _RapportFilterPanelState();
}

class _RapportFilterPanelState
    extends ConsumerState<RapportFilterPanel> {
  final _fromCtrl = TextEditingController();
  final _toCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    final periode = ref.read(rapportPeriodeProvider);
    _fromCtrl.text = _fmt(periode.from);
    _toCtrl.text   = _fmt(periode.to);
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate(bool isFrom) async {
    final now     = DateTime.now();
    final current = ref.read(rapportPeriodeProvider);
    final initial = isFrom ? current.from : current.to;

    final date = await showDatePicker(
      context:     context,
      initialDate: initial,
      firstDate:   DateTime(now.year - 3),
      lastDate:    DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      if (isFrom) {
        _fromCtrl.text = _fmt(date);
        ref.read(rapportPeriodeProvider.notifier).state =
            RapportPeriode(from: date, to: current.to);
      } else {
        _toCtrl.text = _fmt(date);
        ref.read(rapportPeriodeProvider.notifier).state =
            RapportPeriode(from: current.from, to: date);
      }
    }
  }

  void _setPreset(String preset) {
    final now = DateTime.now();
    final RapportPeriode periode;

    switch (preset) {
      case 'today':
        periode = RapportPeriode(
          from: DateTime(now.year, now.month, now.day),
          to:   DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case 'week':
        final start =
            now.subtract(Duration(days: now.weekday - 1));
        periode = RapportPeriode(
          from: DateTime(start.year, start.month, start.day),
          to:   now,
        );
      case 'month':
        periode = RapportPeriode(
          from: DateTime(now.year, now.month, 1),
          to:   now,
        );
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        periode = RapportPeriode(
          from: lastMonth,
          to:   DateTime(now.year, now.month, 0, 23, 59, 59),
        );
      default:
        return;
    }

    ref.read(rapportPeriodeProvider.notifier).state = periode;
    setState(() {
      _fromCtrl.text = _fmt(periode.from);
      _toCtrl.text   = _fmt(periode.to);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre ──────────────────────────────────────
            const Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size:  18,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Période d\'analyse',
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Presets ────────────────────────────────────
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _PresetChip(
                  label: 'Aujourd\'hui',
                  onTap: () => _setPreset('today'),
                ),
                _PresetChip(
                  label: 'Cette semaine',
                  onTap: () => _setPreset('week'),
                ),
                _PresetChip(
                  label: 'Ce mois',
                  onTap: () => _setPreset('month'),
                ),
                _PresetChip(
                  label: 'Mois dernier',
                  onTap: () => _setPreset('last_month'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Dates personnalisées ───────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fromCtrl,
                    readOnly:   true,
                    onTap:      () => _pickDate(true),
                    decoration: const InputDecoration(
                      labelText:  'Date début',
                      prefixIcon: Icon(Icons.calendar_today_rounded,
                          size: 16),
                      isDense:    true,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size:  16,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _toCtrl,
                    readOnly:   true,
                    onTap:      () => _pickDate(false),
                    decoration: const InputDecoration(
                      labelText:  'Date fin',
                      prefixIcon: Icon(Icons.calendar_today_rounded,
                          size: 16),
                      isDense:    true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String       label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed:       onTap,
      backgroundColor: AppColors.primary.withOpacity(0.05),
      side: BorderSide(
        color: AppColors.primary.withOpacity(0.2),
      ),
      labelStyle: const TextStyle(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}