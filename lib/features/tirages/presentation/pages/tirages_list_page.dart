// lib/features/tirages/presentation/pages/tirages_list_page.dart

import 'package:ehbien_lotto_admin/core/extensions/datetime_ext.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/providers/tirages_provider.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/widgets/tirage_status_badge.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/empty_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/inputs/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TiragesListPage extends ConsumerStatefulWidget {
  const TiragesListPage({super.key});

  @override
  ConsumerState<TiragesListPage> createState() => _TiragesListPageState();
}

class _TiragesListPageState extends ConsumerState<TiragesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiragesAsync = ref.watch(tiragesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Toolbar ───────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: SearchField(
                hint:      'Rechercher un tirage...',
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.tirageForm),
              icon:  const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nouveau tirage'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Stats ─────────────────────────────────────────
        tiragesAsync.when(
          loading: () => const SizedBox.shrink(),
          error:   (_, __) => const SizedBox.shrink(),
          data:    (tirages) => _TiragesStats(tirages: tirages),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Onglets ───────────────────────────────────────
        Card(
          child: TabBar(
            controller:           _tabController,
            labelColor:           AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor:       AppColors.primary,
            isScrollable:         true,
            tabAlignment:         TabAlignment.start,
            onTap: (_) => setState(() {}),
            tabs: const [
              Tab(text: 'Tous'),
              Tab(text: 'Ouverts'),
              Tab(text: 'Publiés'),
              Tab(text: 'Fermés'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Liste ─────────────────────────────────────────
        Expanded(
          child: tiragesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Erreur : $e',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
            data: (tirages) {
              final filtered = _filterTirages(tirages);
              if (filtered.isEmpty) {
                return EmptyState(
                  icon:    Icons.casino_outlined,
                  message: 'Aucun tirage trouvé',
                  action: ElevatedButton.icon(
                    onPressed: () => context.go(RouteNames.tirageForm),
                    icon:  const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Créer un tirage'),
                  ),
                );
              }
              return _TiragesList(tirages: filtered);
            },
          ),
        ),
      ],
    );
  }

  List<TirageEntity> _filterTirages(List<TirageEntity> all) {
    var list = all;

    // Filtre onglet
    list = switch (_tabController.index) {
      1 => list.where((t) => t.status == TirageStatus.ouvert).toList(),
      2 => list.where((t) => t.status == TirageStatus.publie).toList(),
      3 => list.where((t) => t.status == TirageStatus.ferme).toList(),
      _ => list,
    };

    // Filtre recherche
    if (_search.isNotEmpty) {
      list = list
          .where((t) =>
              t.nom.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }

    return list;
  }
}

// ── Stats ─────────────────────────────────────────────────────

class _TiragesStats extends StatelessWidget {
  final List<TirageEntity> tirages;
  const _TiragesStats({required this.tirages});

  @override
  Widget build(BuildContext context) {
    final ouverts = tirages.where((t) => t.isOuvert).length;
    final publies = tirages
        .where((t) => t.status == TirageStatus.publie)
        .length;
    final fermes  = tirages
        .where((t) => t.status == TirageStatus.ferme)
        .length;

    return Row(
      children: [
        _Chip(
          label: 'Total',
          value: '${tirages.length}',
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        _Chip(
          label: 'Ouverts',
          value: '$ouverts',
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.sm),
        _Chip(
          label: 'Publiés',
          value: '$publies',
          color: AppColors.info,
        ),
        const SizedBox(width: AppSpacing.sm),
        _Chip(
          label: 'Fermés',
          value: '$fermes',
          color: Colors.grey,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _Chip({
    required this.label,
    required this.value,
    required this.color,
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
          Text(
            value,
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.w800,
              color:      color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:    color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Liste des tirages ─────────────────────────────────────────

class _TiragesList extends ConsumerWidget {
  final List<TirageEntity> tirages;
  const _TiragesList({required this.tirages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount:     tirages.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _TirageRow(tirage: tirages[i]),
    );
  }
}

class _TirageRow extends ConsumerWidget {
  final TirageEntity tirage;
  const _TirageRow({required this.tirage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // ── Icône type ────────────────────────────────
            Container(
              width:  48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _typeEmoji(tirage.type),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Infos ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tirage.nom,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size:  12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tirage.heurePrevu.toDisplayDateTime,
                        style: TextStyle(
                          fontSize: 12,
                          color:    Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _TypeBadge(type: tirage.type),
                    ],
                  ),
                ],
              ),
            ),

            // ── Statut ────────────────────────────────────
            TirageStatusBadge(status: tirage.status),

            const SizedBox(width: AppSpacing.md),

            // ── Actions ───────────────────────────────────
            _TirageActions(tirage: tirage),
          ],
        ),
      ),
    );
  }

  String _typeEmoji(TirageType t) => switch (t) {
    TirageType.borlette => '🎱',
    TirageType.mariage  => '💑',
    TirageType.lotto3   => '🎰',
    TirageType.sel      => '🧂',
  };
}

class _TypeBadge extends StatelessWidget {
  final TirageType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      TirageType.borlette => 'Borlette',
      TirageType.mariage  => 'Mariage',
      TirageType.lotto3   => 'Lotto 3',
      TirageType.sel      => 'Sèl',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize:   10,
          fontWeight: FontWeight.w600,
          color:      AppColors.accent,
        ),
      ),
    );
  }
}

class _TirageActions extends ConsumerWidget {
  final TirageEntity tirage;
  const _TirageActions({required this.tirage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Modifier
        if (tirage.isOuvert)
          _IconBtn(
            icon:    Icons.edit_rounded,
            tooltip: 'Modifier',
            color:   AppColors.primary,
            onTap:   () => context.go('/tirages/${tirage.id}/edit'),
          ),

        // Fermer
        if (tirage.isOuvert)
          _IconBtn(
            icon:    Icons.lock_rounded,
            tooltip: 'Fermer le tirage',
            color:   Colors.orange,
            onTap:   () => _close(context, ref),
          ),

        // Publier résultat
        if (tirage.status == TirageStatus.ferme)
          _IconBtn(
            icon:    Icons.publish_rounded,
            tooltip: 'Publier le résultat',
            color:   AppColors.success,
            onTap:   () => context.go(
              '/tirages/${tirage.id}/publish',
            ),
          ),

        // Réouvrir
        if (tirage.status == TirageStatus.ferme)
          _IconBtn(
            icon:    Icons.lock_open_rounded,
            tooltip: 'Réouvrir',
            color:   AppColors.info,
            onTap:   () => _reopen(context, ref),
          ),

        // Annuler
        if (tirage.isOuvert || tirage.status == TirageStatus.ferme)
          _IconBtn(
            icon:    Icons.cancel_rounded,
            tooltip: 'Annuler',
            color:   AppColors.danger,
            onTap:   () => _cancel(context, ref),
          ),
      ],
    );
  }

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context,
      title:        'Fermer le tirage ?',
      message:      'Les ventes seront arrêtées pour ce tirage.',
      confirmLabel: 'Fermer',
    );
    if (confirm == true) {
      await ref
          .read(tiragesNotifierProvider.notifier)
          .updateStatus(tirage.id, TirageStatus.ferme);
    }
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context,
      title:        'Réouvrir le tirage ?',
      message:      'Les ventes seront à nouveau acceptées.',
      confirmLabel: 'Réouvrir',
    );
    if (confirm == true) {
      await ref
          .read(tiragesNotifierProvider.notifier)
          .updateStatus(tirage.id, TirageStatus.ouvert);
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context,
      title:        'Annuler ce tirage ?',
      message:      'Cette action est irréversible.',
      confirmLabel: 'Annuler le tirage',
      destructive:  true,
    );
    if (confirm == true) {
      await ref
          .read(tiragesNotifierProvider.notifier)
          .updateStatus(tirage.id, TirageStatus.annule);
    }
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String   tooltip;
  final Color    color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}