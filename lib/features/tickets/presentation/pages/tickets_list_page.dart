// lib/features/tickets/presentation/pages/tickets_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ehbien_lotto_admin/core/extensions/datetime_ext.dart';
import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/providers/tickets_provider.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/widgets/ticket_filter_bar.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/widgets/ticket_status_badge.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/empty_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/error_state.dart';

class TicketsListPage extends ConsumerWidget {
  const TicketsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsStreamProvider);
    final filtered     = ref.watch(ticketsFilteredProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stats rapides ──────────────────────────────────
        _TicketsStats(),

        const SizedBox(height: AppSpacing.md),

        // ── Filtres ────────────────────────────────────────
        const TicketFilterBar(),

        const SizedBox(height: AppSpacing.md),

        // ── Liste ──────────────────────────────────────────
        Expanded(
          child: ticketsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => ErrorState(message: e.toString()),
            data:    (_) {
              if (filtered.isEmpty) {
                return const EmptyState(
                  icon:    Icons.receipt_long_outlined,
                  message: 'Aucun ticket trouvé',
                );
              }

              return Card(
                child: Column(
                  children: [
                    // ── En-tête tableau ──────────────────
                    _TableHeader(),

                    // ── Lignes ───────────────────────────
                    Expanded(
                      child: ListView.separated(
                        itemCount:    filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _TicketRow(ticket: filtered[i]),
                      ),
                    ),

                    // ── Footer ───────────────────────────
                    _TableFooter(tickets: filtered),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────

class _TicketsStats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketsStreamProvider).valueOrNull ?? [];

    final total    = tickets.length;
    final gagnants = tickets.where((t) => t.isGagnant).length;
    final payes    = tickets.where((t) => t.isPaye).length;
    final annules  = tickets.where((t) => t.isAnnule).length;

    return Row(
      children: [
        _StatPill(label: 'Total',    value: '$total',    color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(label: 'Gagnants', value: '$gagnants', color: AppColors.warning),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(label: 'Payés',    value: '$payes',    color: AppColors.success),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(label: 'Annulés',  value: '$annules',  color: AppColors.danger),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _StatPill({
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

// ── En-tête tableau ───────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          _HeaderCell(label: 'Code',        flex: 2),
          _HeaderCell(label: 'Agent',       flex: 2),
          _HeaderCell(label: 'Succursale',  flex: 2),
          _HeaderCell(label: 'Tirage',      flex: 2),
          _HeaderCell(label: 'Montant',     flex: 1),
          _HeaderCell(label: 'Date',        flex: 1),
          _HeaderCell(label: 'Statut',      flex: 1),
          _HeaderCell(label: 'Actions',     flex: 1),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int    flex;

  const _HeaderCell({required this.label, required this.flex});

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
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Ligne ticket ──────────────────────────────────────────────

class _TicketRow extends ConsumerWidget {
  final TicketEntity ticket;
  const _TicketRow({required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.go('/tickets/${ticket.id}'),
      hoverColor: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.sm + 4,
        ),
        child: Row(
          children: [
            // Code
            Expanded(
              flex: 2,
              child: Text(
                ticket.codeUnique,
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.primary,
                ),
              ),
            ),
            // Agent
            Expanded(
              flex: 2,
              child: Text(
                ticket.agentNom ?? '—',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Succursale
            Expanded(
              flex: 2,
              child: Text(
                ticket.succursaleNom ?? '—',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Tirage
            Expanded(
              flex: 2,
              child: Text(
                ticket.tirageNom ?? '—',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Montant
            Expanded(
              flex: 1,
              child: Text(
                ticket.montantTotal.toCurrency,
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Date
            Expanded(
              flex: 1,
              child: Text(
                ticket.createdAt.toDisplayDate,
                style: TextStyle(
                  fontSize: 12,
                  color:    Colors.grey.shade500,
                ),
              ),
            ),
            // Statut
            Expanded(
              flex: 1,
              child: TicketStatusBadge(status: ticket.status),
            ),
            // Actions
            Expanded(
              flex: 1,
              child: _TicketActions(ticket: ticket),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Actions rapides ───────────────────────────────────────────

class _TicketActions extends ConsumerWidget {
  final TicketEntity ticket;
  const _TicketActions({required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voir détail
        Tooltip(
          message: 'Voir le détail',
          child: IconButton(
            icon:      const Icon(Icons.visibility_rounded, size: 16),
            color:     AppColors.info,
            onPressed: () => context.go('/tickets/${ticket.id}'),
            padding:   EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
        // Marquer gagnant
        if (ticket.status == TicketStatus.valide)
          Tooltip(
            message: 'Marquer gagnant',
            child: IconButton(
              icon:      const Icon(Icons.emoji_events_rounded, size: 16),
              color:     AppColors.warning,
              onPressed: () =>
                  _markAsWinner(context, ref),
              padding:   EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        // Marquer payé
        if (ticket.status == TicketStatus.gagnant && !ticket.paye)
          Tooltip(
            message: 'Marquer payé',
            child: IconButton(
              icon:      const Icon(Icons.payments_rounded, size: 16),
              color:     AppColors.success,
              onPressed: () =>
                  _markAsPaid(context, ref),
              padding:   EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        // Annuler
        if (ticket.status == TicketStatus.brouillon ||
            ticket.status == TicketStatus.valide)
          Tooltip(
            message: 'Annuler le ticket',
            child: IconButton(
              icon:      const Icon(Icons.cancel_rounded, size: 16),
              color:     AppColors.danger,
              onPressed: () => _cancel(context, ref),
              padding:   EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
      ],
    );
  }

  Future<void> _markAsWinner(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final gain = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Montant du gain'),
        content: TextFormField(
          controller: ctrl,
          keyboardType:    TextInputType.number,
          autofocus:       true,
          decoration: const InputDecoration(
            labelText:  'Gain total (G)',
            prefixIcon: Icon(Icons.attach_money_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              double.tryParse(ctrl.text),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (gain != null && gain > 0) {
      await ref
          .read(ticketsNotifierProvider.notifier)
          .markAsWinner(ticket.id, gain);
    }
  }

  Future<void> _markAsPaid(BuildContext context, WidgetRef ref) async {
    await ref
        .read(ticketsNotifierProvider.notifier)
        .markAsPaid(ticket.id);
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    await ref
        .read(ticketsNotifierProvider.notifier)
        .updateStatus(ticket.id, TicketStatus.annule);
  }
}

// ── Footer tableau ────────────────────────────────────────────

class _TableFooter extends StatelessWidget {
  final List<TicketEntity> tickets;
  const _TableFooter({required this.tickets});

  @override
  Widget build(BuildContext context) {
    final total   = tickets.length;
    final montant = tickets.fold(0.0, (s, t) => s + t.montantTotal);
    final gains   = tickets
        .where((t) => t.gagnant)
        .fold(0.0, (s, t) => s + (t.gainTotal ?? 0));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical:   AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.cardRadius),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$total ticket${total > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize:   12,
              color:      Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _FooterStat(
            label: 'Total ventes',
            value: montant.toCurrency,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.lg),
          _FooterStat(
            label: 'Gains à payer',
            value: gains.toCurrency,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.lg),
          _FooterStat(
            label: 'Recette',
            value: (montant - gains).toCurrency,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _FooterStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            fontSize: 12,
            color:    Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w700,
            color:      color,
          ),
        ),
      ],
    );
  }
}