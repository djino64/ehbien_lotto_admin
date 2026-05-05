// lib/features/agents/presentation/pages/agents_list_page.dart

import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/widgets/agent_card.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/empty_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/inputs/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AgentsListPage extends ConsumerStatefulWidget {
  const AgentsListPage({super.key});

  @override
  ConsumerState<AgentsListPage> createState() => _AgentsListPageState();
}

class _AgentsListPageState extends ConsumerState<AgentsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agents    = ref.watch(agentsFilteredProvider);
    final isLoading = ref.watch(agentsStreamProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Barre d'outils ─────────────────────────────────
        _AgentsToolbar(),

        const SizedBox(height: AppSpacing.md),

        // ── Stats rapides ──────────────────────────────────
        _AgentsStats(),

        const SizedBox(height: AppSpacing.md),

        // ── Onglets filtres ────────────────────────────────
        Card(
          child: TabBar(
            controller: _tabController,
            labelColor:         AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor:     AppColors.primary,
            onTap: (_) => setState(() {}),
            tabs: const [
              Tab(text: 'Tous'),
              Tab(text: 'Actifs'),
              Tab(text: 'Bloqués'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Liste ──────────────────────────────────────────
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _AgentsList(
                  agents:        agents,
                  tabIndex:      _tabController.index,
                ),
        ),
      ],
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────

class _AgentsToolbar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            hint: 'Rechercher un agent...',
            onChanged: (q) => ref
                .read(agentsSearchQueryProvider.notifier)
                .state = q,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: () => context.go(RouteNames.agentForm),
          icon:  const Icon(Icons.person_add_rounded, size: 18),
          label: const Text('Nouvel agent'),
        ),
      ],
    );
  }
}

// ── Stats rapides ─────────────────────────────────────────────

class _AgentsStats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];
    final actifs  = agents.where((a) => a.isActif).length;
    final bloques = agents.where((a) => a.isBloque).length;
    final inactifs = agents.where((a) =>
        a.status == AgentStatus.inactif).length;

    return Row(
      children: [
        _StatChip(
          label: 'Total',
          value: '${agents.length}',
          color: AppColors.primary,
          icon:  Icons.group_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Actifs',
          value: '$actifs',
          color: AppColors.success,
          icon:  Icons.check_circle_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Inactifs',
          value: '$inactifs',
          color: Colors.grey,
          icon:  Icons.pause_circle_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          label: 'Bloqués',
          value: '$bloques',
          color: AppColors.danger,
          icon:  Icons.block_rounded,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w800,
                  color:      color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color:    color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Liste filtrée ─────────────────────────────────────────────

class _AgentsList extends StatelessWidget {
  final List<AgentEntity> agents;
  final int               tabIndex;

  const _AgentsList({
    required this.agents,
    required this.tabIndex,
  });

  List<AgentEntity> get _filtered {
    return switch (tabIndex) {
      1 => agents.where((a) => a.isActif).toList(),
      2 => agents.where((a) => a.isBloque).toList(),
      _ => agents,
    };
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    if (list.isEmpty) {
      return EmptyState(
        icon:    Icons.group_off_rounded,
        message: 'Aucun agent trouvé',
        action: ElevatedButton.icon(
          onPressed: () => context.go(RouteNames.agentForm),
          icon:  const Icon(Icons.person_add_rounded, size: 16),
          label: const Text('Ajouter un agent'),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        crossAxisSpacing:   AppSpacing.md,
        mainAxisSpacing:    AppSpacing.md,
        childAspectRatio:   1.15,
      ),
      itemCount:   list.length,
      itemBuilder: (_, i) => AgentCard(agent: list[i]),
    );
  }
}