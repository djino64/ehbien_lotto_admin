// lib/features/limits/presentation/pages/limits_page.dart

import 'package:ehbien_lotto_admin/features/limits/domain/entities/limit_entity.dart';
import 'package:ehbien_lotto_admin/features/limits/presentation/providers/limits_provider.dart';
import 'package:ehbien_lotto_admin/features/limits/presentation/widgets/limit_form.dart';
import 'package:ehbien_lotto_admin/features/limits/presentation/widgets/limit_progress_bar.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LimitsPage extends ConsumerWidget {
  const LimitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Liste des limites ──────────────────────────────
        Expanded(
          flex: 3,
          child: _LimitsList(),
        ),
        const SizedBox(width: AppSpacing.lg),
        // ── Formulaire nouvelle limite ─────────────────────
        SizedBox(
          width: 360,
          child: _NewLimitPanel(),
        ),
      ],
    );
  }
}

// ── Liste ─────────────────────────────────────────────────────

class _LimitsList extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LimitsList> createState() => _LimitsListState();
}

class _LimitsListState extends ConsumerState<_LimitsList>
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
    final all      = ref.watch(limitsStreamProvider).valueOrNull ?? [];
    final globales = ref.watch(globalLimitsProvider);
    final atRisk   = ref.watch(limitsAtRiskProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stats ──────────────────────────────────────────
        _LimitsStats(
          total:   all.length,
          atRisk:  atRisk.length,
          reached: all.where((l) => l.isAtLimit).length,
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Alerte limites critiques ───────────────────────
        if (atRisk.isNotEmpty)
          _CriticalAlert(count: atRisk.length),

        if (atRisk.isNotEmpty) const SizedBox(height: AppSpacing.md),

        // ── Onglets ────────────────────────────────────────
        Card(
          child: TabBar(
            controller:          _tab,
            labelColor:          AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor:      AppColors.primary,
            tabs: const [
              Tab(text: 'Toutes'),
              Tab(text: 'Globales'),
              Tab(text: 'À risque'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Liste ──────────────────────────────────────────
        Expanded(
          child: AnimatedBuilder(
            animation: _tab,
            builder: (_, __) {
              final list = switch (_tab.index) {
                1 => globales,
                2 => atRisk,
                _ => all,
              };
              return _LimitsGrid(limits: list);
            },
          ),
        ),
      ],
    );
  }
}

class _LimitsStats extends StatelessWidget {
  final int total;
  final int atRisk;
  final int reached;

  const _LimitsStats({
    required this.total,
    required this.atRisk,
    required this.reached,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: 'Total',
          value: '$total',
          color: AppColors.primary,
          icon:  Icons.tune_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _Chip(
          label: 'À risque (>80%)',
          value: '$atRisk',
          color: AppColors.warning,
          icon:  Icons.warning_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _Chip(
          label: 'Atteintes',
          value: '$reached',
          color: AppColors.danger,
          icon:  Icons.block_rounded,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String   label;
  final String   value;
  final Color    color;
  final IconData icon;

  const _Chip({
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
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize:   18,
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

class _CriticalAlert extends StatelessWidget {
  final int count;
  const _CriticalAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size:  20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$count limite${count > 1 ? 's' : ''} proche${count > 1 ? 's' : ''} du plafond (>80%). Surveillez les ventes.',
              style: const TextStyle(
                fontSize:   13,
                color:      AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitsGrid extends ConsumerWidget {
  final List<LimitEntity> limits;
  const _LimitsGrid({required this.limits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (limits.isEmpty) {
      return const EmptyState(
        icon:    Icons.speed_outlined,
        message: 'Aucune limite configurée',
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        crossAxisSpacing:   AppSpacing.md,
        mainAxisSpacing:    AppSpacing.md,
        childAspectRatio:   2.2,
      ),
      itemCount:   limits.length,
      itemBuilder: (_, i) => _LimitCard(limit: limits[i]),
    );
  }
}

class _LimitCard extends ConsumerWidget {
  final LimitEntity limit;
  const _LimitCard({required this.limit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LimitProgressBar(limit: limit),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon:      const Icon(Icons.delete_rounded, size: 15),
                  color:     AppColors.danger,
                  tooltip:   'Supprimer',
                  padding:   EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28, minHeight: 28,
                  ),
                  onPressed: () => _delete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmDialog.show(
      context,
      title:        'Supprimer la limite ?',
      message:      'Cette limite sera définitivement supprimée.',
      confirmLabel: 'Supprimer',
      destructive:  true,
    );
    if (ok == true) {
      await ref
          .read(limitsNotifierProvider.notifier)
          .deleteLimit(limit.id);
    }
  }
}

// ── Panneau nouvelle limite ───────────────────────────────────

class _NewLimitPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:    const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color: AppColors.primary,
                    size:  18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Nouvelle limite',
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Définissez un plafond de vente par boule, par jeu, par tirage ou par agent.',
              style: TextStyle(
                fontSize: 12,
                color:    Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: LimitForm(
                  onSuccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Limite créée avec succès'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior:        SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}