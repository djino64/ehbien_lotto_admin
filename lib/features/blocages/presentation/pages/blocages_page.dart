// lib/features/blocages/presentation/pages/blocages_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/features/blocages/domain/entities/blocage_entity.dart';
import 'package:ehbien_lotto_admin/features/blocages/presentation/providers/blocages_provider.dart';
import 'package:ehbien_lotto_admin/features/blocages/presentation/widgets/blocage_form.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/empty_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/dialogs/confirm_dialog.dart';

class BlocagesPage extends ConsumerWidget {
  const BlocagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Liste des blocages ─────────────────────────────
        Expanded(
          flex: 3,
          child: _BlocagesList(),
        ),
        const SizedBox(width: AppSpacing.lg),
        // ── Formulaire nouveau blocage ─────────────────────
        SizedBox(
          width: 380,
          child: _NewBlocagePanel(),
        ),
      ],
    );
  }
}

// ── Liste ─────────────────────────────────────────────────────

class _BlocagesList extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BlocagesList> createState() => _BlocagesListState();
}

class _BlocagesListState extends ConsumerState<_BlocagesList>
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
    final all     = ref.watch(blocagesStreamProvider).valueOrNull ?? [];
    final actifs  = ref.watch(blocagesActifsProvider);
    final globaux = actifs.where((b) => b.global).toList();
    final agents  = actifs.where((b) => !b.global).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stats ──────────────────────────────────────────
        _BlocagesStats(
          total:   all.length,
          actifs:  actifs.length,
          globaux: globaux.length,
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Onglets ────────────────────────────────────────
        Card(
          child: TabBar(
            controller:          _tab,
            labelColor:          AppColors.danger,
            unselectedLabelColor: Colors.grey,
            indicatorColor:      AppColors.danger,
            tabs: const [
              Tab(text: 'Tous'),
              Tab(text: 'Globaux'),
              Tab(text: 'Par agent'),
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
                1 => globaux,
                2 => agents,
                _ => actifs,
              };
              return _BlocagesTable(blocages: list);
            },
          ),
        ),
      ],
    );
  }
}

class _BlocagesStats extends StatelessWidget {
  final int total;
  final int actifs;
  final int globaux;

  const _BlocagesStats({
    required this.total,
    required this.actifs,
    required this.globaux,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          label: 'Total',
          value: '$total',
          color: AppColors.primary,
          icon:  Icons.format_list_numbered_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Actifs',
          value: '$actifs',
          color: AppColors.danger,
          icon:  Icons.block_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Globaux',
          value: '$globaux',
          color: AppColors.warning,
          icon:  Icons.public_rounded,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String   label;
  final String   value;
  final Color    color;
  final IconData icon;

  const _StatChip({
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

class _BlocagesTable extends ConsumerWidget {
  final List<BlocageEntity> blocages;
  const _BlocagesTable({required this.blocages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (blocages.isEmpty) {
      return const EmptyState(
        icon:    Icons.check_circle_outline_rounded,
        message: 'Aucun blocage actif',
      );
    }

    return Card(
      child: Column(
        children: [
          // ── En-tête ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical:   AppSpacing.sm + 4,
            ),
            decoration: BoxDecoration(
              color:        Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: const Row(
              children: [
                _H('Boule',    2),
                _H('Type jeu', 2),
                _H('Portée',   2),
                _H('Durée',    2),
                _H('Créé le',  2),
                _H('Actions',  1),
              ],
            ),
          ),

          // ── Lignes ────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              itemCount:    blocages.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (_, i) =>
                  _BlocageRow(blocage: blocages[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String label;
  final int    flex;
  const _H(this.label, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w600,
          color:      Colors.grey.shade500,
        ),
      ),
    );
  }
}

class _BlocageRow extends ConsumerWidget {
  final BlocageEntity blocage;
  const _BlocageRow({required this.blocage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical:   AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          // Boule
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical:   4,
              ),
              decoration: BoxDecoration(
                color:        AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                blocage.boule,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize:   16,
                  color:      AppColors.danger,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Type jeu
          Expanded(
            flex: 2,
            child: Text(
              blocage.typeJeu != null
                  ? _jeuLabel(blocage.typeJeu!)
                  : 'Tous',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          // Portée
          Expanded(
            flex: 2,
            child: _ScopeBadge(blocage: blocage),
          ),
          // Durée
          Expanded(
            flex: 2,
            child: _DureeBadge(blocage: blocage),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Text(
              '${blocage.createdAt.day.toString().padLeft(2, '0')}/${blocage.createdAt.month.toString().padLeft(2, '0')}/${blocage.createdAt.year}',
              style: TextStyle(
                fontSize: 12,
                color:    Colors.grey.shade500,
              ),
            ),
          ),
          // Action supprimer
          Expanded(
            flex: 1,
            child: IconButton(
              icon:    const Icon(Icons.delete_rounded, size: 16),
              color:   AppColors.danger,
              tooltip: 'Supprimer ce blocage',
              onPressed: () => _delete(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context,
      title:        'Supprimer le blocage ?',
      message:      'La boule ${blocage.boule} ne sera plus bloquée.',
      confirmLabel: 'Supprimer',
      destructive:  true,
    );
    if (confirm == true) {
      await ref
          .read(blocagesNotifierProvider.notifier)
          .deleteBlocage(blocage.id);
    }
  }

  String _jeuLabel(String t) => switch (t) {
    'borlette' => 'Borlette',
    'mariage'  => 'Mariage',
    'lotto3'   => 'Lotto 3',
    'sel'      => 'Sèl',
    _          => t,
  };
}

class _ScopeBadge extends StatelessWidget {
  final BlocageEntity blocage;
  const _ScopeBadge({required this.blocage});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = blocage.global
        ? ('Global',    AppColors.danger,  Icons.public_rounded)
        : blocage.agentId != null
            ? ('Agent',     AppColors.warning, Icons.person_rounded)
            : blocage.succursaleId != null
                ? ('Succursale', AppColors.info,    Icons.store_rounded)
                : ('Tirage',    AppColors.success, Icons.casino_rounded);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize:   12,
            color:      color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DureeBadge extends StatelessWidget {
  final BlocageEntity blocage;
  const _DureeBadge({required this.blocage});

  @override
  Widget build(BuildContext context) {
    if (blocage.permanent) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.all_inclusive_rounded,
            size:  12,
            color: AppColors.danger,
          ),
          SizedBox(width: 4),
          Text(
            'Permanent',
            style: TextStyle(
              fontSize:   12,
              color:      AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (blocage.expiresAt != null) {
      final expired = blocage.isExpired;
      final color   = expired ? Colors.grey : AppColors.warning;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            expired
                ? 'Expiré'
                : '${blocage.expiresAt!.day}/${blocage.expiresAt!.month}',
            style: TextStyle(
              fontSize:   12,
              color:      color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Panneau nouveau blocage ───────────────────────────────────

class _NewBlocagePanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  padding:    const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:        AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    color: AppColors.danger,
                    size:  18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Nouveau blocage',
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
              'Bloquer une boule ou un jeu pour tous les agents ou un agent spécifique.',
              style: TextStyle(
                fontSize: 12,
                color:    Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Formulaire ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: BlocageForm(
                  onSuccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size:  18,
                            ),
                            SizedBox(width: 8),
                            Text('Blocage créé avec succès'),
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