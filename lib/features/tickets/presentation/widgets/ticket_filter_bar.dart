// lib/features/tickets/presentation/widgets/ticket_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/providers/succursales_provider.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/providers/tirages_provider.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/providers/tickets_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';

class TicketFilterBar extends ConsumerStatefulWidget {
  const TicketFilterBar({super.key});

  @override
  ConsumerState<TicketFilterBar> createState() => _TicketFilterBarState();
}

class _TicketFilterBarState extends ConsumerState<TicketFilterBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(ticketFilterProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ligne principale ──────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (_hasActiveFilters(filter))
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon:  const Icon(Icons.clear_rounded, size: 14),
                    label: const Text('Effacer'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  onPressed: () =>
                      setState(() => _expanded = !_expanded),
                ),
              ],
            ),

            // ── Filtres rapides par statut ─────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label:    'Tous',
                    selected: filter.status == null,
                    onTap:    () => _setStatus(null),
                    color:    AppColors.primary,
                  ),
                  ...TicketStatus.values.map(
                    (s) => _StatusChip(
                      label:    _statusLabel(s),
                      selected: filter.status == s,
                      onTap:    () => _setStatus(s),
                      color:    _statusColor(s),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filtres avancés ───────────────────────────
            if (_expanded) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _AgentFilter()),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _SuccursaleFilter()),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _TirageFilter()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Row(
                children: [
                  Expanded(child: _DateFilter(isFrom: true)),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: _DateFilter(isFrom: false)),
                  Spacer(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters(TicketFilter f) =>
      f.status != null ||
      f.agentId != null ||
      f.succursaleId != null ||
      f.tirageId != null ||
      f.from != null ||
      f.to != null;

  void _clearFilters() {
    ref.read(ticketFilterProvider.notifier).state = const TicketFilter();
  }

  void _setStatus(TicketStatus? status) {
    ref.read(ticketFilterProvider.notifier).state =
        ref.read(ticketFilterProvider).copyWith(status: status);

    if (status == null) {
      ref.read(ticketFilterProvider.notifier).state =
          ref.read(ticketFilterProvider).copyWith();
    }

    ref.read(ticketFilterProvider.notifier).update(
      (f) => TicketFilter(
        agentId:      f.agentId,
        succursaleId: f.succursaleId,
        tirageId:     f.tirageId,
        status:       status,
        from:         f.from,
        to:           f.to,
      ),
    );
  }

  String _statusLabel(TicketStatus s) => switch (s) {
    TicketStatus.brouillon => 'Brouillon',
    TicketStatus.valide    => 'Validé',
    TicketStatus.gagnant   => 'Gagnant',
    TicketStatus.perdant   => 'Perdant',
    TicketStatus.paye      => 'Payé',
    TicketStatus.annule    => 'Annulé',
  };

  Color _statusColor(TicketStatus s) => switch (s) {
    TicketStatus.brouillon => Colors.orange,
    TicketStatus.valide    => AppColors.info,
    TicketStatus.gagnant   => AppColors.warning,
    TicketStatus.perdant   => Colors.grey,
    TicketStatus.paye      => AppColors.success,
    TicketStatus.annule    => AppColors.danger,
  };
}

class _StatusChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final VoidCallback onTap;
  final Color    color;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical:   6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.15)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color:      selected ? color : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ── Filtres avancés ───────────────────────────────────────────

class _AgentFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];
    final filter = ref.watch(ticketFilterProvider);

    return DropdownButtonFormField<String?>(
      initialValue:      filter.agentId,
      decoration: const InputDecoration(
        labelText:   'Agent',
        prefixIcon:  Icon(Icons.person_rounded, size: 18),
        isDense:     true,
      ),
      onChanged: (v) => ref
          .read(ticketFilterProvider.notifier)
          .update(
            (f) => TicketFilter(
              agentId:      v,
              succursaleId: f.succursaleId,
              tirageId:     f.tirageId,
              status:       f.status,
              from:         f.from,
              to:           f.to,
            ),
          ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Tous les agents')),
        ...agents.map(
          (a) => DropdownMenuItem(value: a.id, child: Text(a.nom)),
        ),
      ],
    );
  }
}

class _SuccursaleFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succursales =
        ref.watch(succursalesStreamProvider).valueOrNull ?? [];
    final filter = ref.watch(ticketFilterProvider);

    return DropdownButtonFormField<String?>(
      initialValue:      filter.succursaleId,
      decoration: const InputDecoration(
        labelText:  'Succursale',
        prefixIcon: Icon(Icons.store_rounded, size: 18),
        isDense:    true,
      ),
      onChanged: (v) => ref
          .read(ticketFilterProvider.notifier)
          .update(
            (f) => TicketFilter(
              agentId:      f.agentId,
              succursaleId: v,
              tirageId:     f.tirageId,
              status:       f.status,
              from:         f.from,
              to:           f.to,
            ),
          ),
      items: [
        const DropdownMenuItem(
            value: null, child: Text('Toutes les succursales')),
        ...succursales.map(
          (s) => DropdownMenuItem(value: s.id, child: Text(s.nom)),
        ),
      ],
    );
  }
}

class _TirageFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tirages = ref.watch(tiragesStreamProvider).valueOrNull ?? [];
    final filter  = ref.watch(ticketFilterProvider);

    return DropdownButtonFormField<String?>(
      initialValue:      filter.tirageId,
      decoration: const InputDecoration(
        labelText:  'Tirage',
        prefixIcon: Icon(Icons.casino_rounded, size: 18),
        isDense:    true,
      ),
      onChanged: (v) => ref
          .read(ticketFilterProvider.notifier)
          .update(
            (f) => TicketFilter(
              agentId:      f.agentId,
              succursaleId: f.succursaleId,
              tirageId:     v,
              status:       f.status,
              from:         f.from,
              to:           f.to,
            ),
          ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Tous les tirages')),
        ...tirages.map(
          (t) => DropdownMenuItem(value: t.id, child: Text(t.nom)),
        ),
      ],
    );
  }
}

class _DateFilter extends ConsumerStatefulWidget {
  final bool isFrom;
  const _DateFilter({required this.isFrom});

  @override
  ConsumerState<_DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends ConsumerState<_DateFilter> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context:     context,
      initialDate: now,
      firstDate:   DateTime(now.year - 2),
      lastDate:    DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      _ctrl.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      ref.read(ticketFilterProvider.notifier).update(
        (f) {
          if (widget.isFrom) {
            return TicketFilter(
              agentId:      f.agentId,
              succursaleId: f.succursaleId,
              tirageId:     f.tirageId,
              status:       f.status,
              from:         date,
              to:           f.to,
            );
          } else {
            return TicketFilter(
              agentId:      f.agentId,
              succursaleId: f.succursaleId,
              tirageId:     f.tirageId,
              status:       f.status,
              from:         f.from,
              to:           date,
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      readOnly:   true,
      onTap:      _pickDate,
      decoration: InputDecoration(
        labelText:  widget.isFrom ? 'Date début' : 'Date fin',
        prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        isDense:    true,
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                icon:      const Icon(Icons.clear_rounded, size: 16),
                onPressed: () {
                  _ctrl.clear();
                  ref.read(ticketFilterProvider.notifier).update(
                    (f) => TicketFilter(
                      agentId:      f.agentId,
                      succursaleId: f.succursaleId,
                      tirageId:     f.tirageId,
                      status:       f.status,
                      from:         widget.isFrom ? null : f.from,
                      to:           widget.isFrom ? f.to : null,
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}