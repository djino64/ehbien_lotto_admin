// lib/features/succursales/presentation/pages/succursales_list_page.dart

import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/succursales/domain/entities/succursale_entity.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/providers/succursales_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/empty_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/error_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/inputs/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SuccursalesListPage extends ConsumerStatefulWidget {
  const SuccursalesListPage({super.key});

  @override
  ConsumerState<SuccursalesListPage> createState() =>
      _SuccursalesListPageState();
}

class _SuccursalesListPageState extends ConsumerState<SuccursalesListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final succursalesAsync = ref.watch(succursalesStreamProvider);
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Toolbar ─────────────────────────────────────
        _SuccursalesToolbar(
          onSearch: (q) => setState(() => _searchQuery = q),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Stats ────────────────────────────────────────
        succursalesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (succursales) => _SuccursalesStats(
            succursales: succursales,
            agents: agents,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Liste ─────────────────────────────────────────
        Expanded(
          child: succursalesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => ErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(succursalesStreamProvider),
            ),
            data: (succursales) {
              final filtered = _applySearch(succursales);

              if (filtered.isEmpty) {
                return EmptyState(
                  icon: Icons.store_mall_directory_outlined,
                  message: _searchQuery.isEmpty
                      ? 'Aucune succursale créée'
                      : 'Aucune succursale trouvée',
                  action: _searchQuery.isEmpty
                      ? ElevatedButton.icon(
                          onPressed: () =>
                              context.go(RouteNames.succursaleForm),
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 16,
                          ),
                          label: const Text('Créer une succursale'),
                        )
                      : null,
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.3,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _SuccursaleCard(
                  succursale: filtered[i],
                  nombreAgents: agents
                      .where(
                        (a) => a.succursaleId == filtered[i].id,
                      )
                      .length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<SuccursaleEntity> _applySearch(List<SuccursaleEntity> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((s) {
      return s.nom.toLowerCase().contains(q) ||
          s.adresse.toLowerCase().contains(q);
    }).toList();
  }
}

// ── Toolbar ───────────────────────────────────────────────────

class _SuccursalesToolbar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const _SuccursalesToolbar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            hint: 'Rechercher une succursale...',
            onChanged: onSearch,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: () => context.go(RouteNames.succursaleForm),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Nouvelle succursale'),
        ),
      ],
    );
  }
}

// ── Stats rapides ─────────────────────────────────────────────

class _SuccursalesStats extends StatelessWidget {
  final List<SuccursaleEntity> succursales;
  final List<dynamic> agents;

  const _SuccursalesStats({
    required this.succursales,
    required this.agents,
  });

  @override
  Widget build(BuildContext context) {
    final total = succursales.length;
    final actives =
        succursales.where((s) => s.status == SuccursaleStatus.actif).length;
    final inactives = total - actives;

    return Row(
      children: [
        _StatChip(
          label: 'Total',
          value: '$total',
          color: AppColors.primary,
          icon: Icons.store_mall_directory_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Actives',
          value: '$actives',
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Inactives',
          value: '$inactives',
          color: Colors.grey,
          icon: Icons.pause_circle_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Agents total',
          value: '${agents.length}',
          color: AppColors.info,
          icon: Icons.group_rounded,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
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
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Carte succursale ──────────────────────────────────────────

class _SuccursaleCard extends ConsumerWidget {
  final SuccursaleEntity succursale;
  final int nombreAgents;

  const _SuccursaleCard({
    required this.succursale,
    required this.nombreAgents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActif = succursale.status == SuccursaleStatus.actif;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête ──────────────────────────────
            Row(
              children: [
                // Icône
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isActif ? AppColors.success : Colors.grey)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (isActif ? AppColors.success : Colors.grey)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.store_mall_directory_rounded,
                    color: isActif ? AppColors.success : Colors.grey,
                    size: 22,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        succursale.nom,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isActif ? AppColors.success : Colors.grey)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isActif ? AppColors.success : Colors.grey)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActif
                            ? Icons.check_circle_rounded
                            : Icons.pause_circle_rounded,
                        size: 10,
                        color: isActif ? AppColors.success : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isActif ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActif ? AppColors.success : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // ── Adresse ───────────────────────────────
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: succursale.adresse,
              color: Colors.grey.shade500,
            ),

            if (succursale.telephone != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _InfoRow(
                icon: Icons.phone_rounded,
                label: succursale.telephone!,
                color: AppColors.info,
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            // ── Agents ────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.group_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$nombreAgents agent${nombreAgents > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),

            const Spacer(),

            // ── Actions ───────────────────────────────
            Row(
              children: [
                _ActionBtn(
                  icon: Icons.edit_rounded,
                  label: 'Modifier',
                  color: AppColors.primary,
                  onTap: () => context.go(
                    '/succursales/${succursale.id}/edit',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ActionBtn(
                  icon:
                      isActif ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  label: isActif ? 'Désactiver' : 'Activer',
                  color: isActif ? Colors.grey : AppColors.success,
                  onTap: () => _toggleStatus(context, ref),
                ),
                const Spacer(),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  label: 'Supprimer',
                  color: AppColors.danger,
                  onTap: () => _delete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    final newStatus = succursale.status == SuccursaleStatus.actif
        ? SuccursaleStatus.inactif
        : SuccursaleStatus.actif;

    final confirm = await ConfirmDialog.show(
      context,
      title: succursale.status == SuccursaleStatus.actif
          ? 'Désactiver la succursale ?'
          : 'Activer la succursale ?',
      message: succursale.status == SuccursaleStatus.actif
          ? 'La succursale ${succursale.nom} sera désactivée.'
          : 'La succursale ${succursale.nom} sera réactivée.',
      confirmLabel: succursale.status == SuccursaleStatus.actif
          ? 'Désactiver'
          : 'Activer',
      destructive: succursale.status == SuccursaleStatus.actif,
    );

    if (confirm == true && context.mounted) {
      await ref
          .read(succursalesNotifierProvider.notifier)
          .updateStatus(succursale.id, newStatus);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Supprimer la succursale ?',
      message: 'La succursale ${succursale.nom} sera '
          'supprimée définitivement. '
          'Les agents associés ne seront pas supprimés.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );

    if (confirm == true && context.mounted) {
      await ref
          .read(succursalesNotifierProvider.notifier)
          .delete(succursale.id);
    }
  }
}

// ── Sous-widgets ──────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
