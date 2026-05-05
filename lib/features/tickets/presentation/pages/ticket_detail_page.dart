// lib/features/tickets/presentation/pages/ticket_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ehbien_lotto_admin/core/extensions/datetime_ext.dart';
import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/providers/tickets_provider.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/widgets/ticket_items_table.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/widgets/ticket_status_badge.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/error_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/loading_overlay.dart';

class TicketDetailPage extends ConsumerWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketByIdProvider(ticketId));
    final itemsAsync  = ref.watch(ticketItemsProvider(ticketId));
    final isLoading   = ref.watch(ticketsNotifierProvider).isLoading;

    return ticketAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => ErrorState(message: e.toString()),
      data:    (ticket) {
        if (ticket == null) {
          return const ErrorState(message: 'Ticket introuvable.');
        }

        return LoadingOverlay(
          isLoading: isLoading,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ────────────────────────────
                    _TicketDetailHeader(ticket: ticket),

                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Infos principales ─────────────
                        Expanded(
                          flex: 3,
                          child: _TicketInfoCard(ticket: ticket),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // ── Actions ───────────────────────
                        Expanded(
                          flex: 2,
                          child: _TicketActionsCard(ticket: ticket),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Items ─────────────────────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.list_alt_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Jeux joués',
                                  style: TextStyle(
                                    fontSize:   14,
                                    fontWeight: FontWeight.w700,
                                    color:      AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            itemsAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) =>
                                  const Text('Erreur chargement items'),
                              data: (items) =>
                                  TicketItemsTable(items: items),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────

class _TicketDetailHeader extends StatelessWidget {
  final TicketEntity ticket;
  const _TicketDetailHeader({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon:      const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(RouteNames.ticketsList),
          tooltip:   'Retour',
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Ticket ${ticket.codeUnique}',
                    style: const TextStyle(
                      fontSize:   22,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TicketStatusBadge(status: ticket.status, large: true),
                ],
              ),
              Text(
                'Créé le ${ticket.createdAt.toDisplayDateTime}',
                style: TextStyle(
                  fontSize: 12,
                  color:    Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        // Copier le code
        IconButton(
          icon:      const Icon(Icons.copy_rounded, size: 18),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: ticket.codeUnique));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code copié'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          tooltip: 'Copier le code',
        ),
      ],
    );
  }
}

// ── Infos principales ─────────────────────────────────────────

class _TicketInfoCard extends StatelessWidget {
  final TicketEntity ticket;
  const _TicketInfoCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon:  Icons.info_outline_rounded,
              label: 'Informations',
            ),
            const SizedBox(height: AppSpacing.md),

            _InfoRow(
              icon:  Icons.badge_rounded,
              label: 'Agent',
              value: ticket.agentNom ?? ticket.agentId,
            ),
            _InfoRow(
              icon:  Icons.store_rounded,
              label: 'Succursale',
              value: ticket.succursaleNom ?? ticket.succursaleId,
            ),
            _InfoRow(
              icon:  Icons.casino_rounded,
              label: 'Tirage',
              value: ticket.tirageNom ?? ticket.tirageId,
            ),
            const Divider(),
            _InfoRow(
              icon:  Icons.attach_money_rounded,
              label: 'Montant total',
              value: ticket.montantTotal.toCurrency,
              bold:  true,
            ),
            if (ticket.gainTotal != null)
              _InfoRow(
                icon:  Icons.emoji_events_rounded,
                label: 'Gain',
                value: ticket.gainTotal!.toCurrency,
                bold:  true,
                color: AppColors.success,
              ),
            if (ticket.validatedAt != null)
              _InfoRow(
                icon:  Icons.check_circle_rounded,
                label: 'Validé le',
                value: ticket.validatedAt!.toDisplayDateTime,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Actions ───────────────────────────────────────────────────

class _TicketActionsCard extends ConsumerWidget {
  final TicketEntity ticket;
  const _TicketActionsCard({required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon:  Icons.touch_app_rounded,
              label: 'Actions',
            ),
            const SizedBox(height: AppSpacing.md),

            // Marquer gagnant
            if (ticket.status == TicketStatus.valide)
              _ActionTile(
                icon:    Icons.emoji_events_rounded,
                label:   'Marquer comme gagnant',
                color:   AppColors.warning,
                onTap: () => _showGainDialog(context, ref),
              ),

            // Marquer payé
            if (ticket.status == TicketStatus.gagnant && !ticket.paye)
              _ActionTile(
                icon:  Icons.payments_rounded,
                label: 'Confirmer le paiement',
                color: AppColors.success,
                onTap: () => ref
                    .read(ticketsNotifierProvider.notifier)
                    .markAsPaid(ticket.id),
              ),

            // Marquer perdant
            if (ticket.status == TicketStatus.valide)
              _ActionTile(
                icon:  Icons.thumb_down_rounded,
                label: 'Marquer comme perdant',
                color: Colors.grey,
                onTap: () => ref
                    .read(ticketsNotifierProvider.notifier)
                    .updateStatus(ticket.id, TicketStatus.perdant),
              ),

            // Annuler
            if (ticket.status == TicketStatus.brouillon ||
                ticket.status == TicketStatus.valide)
              _ActionTile(
                icon:        Icons.cancel_rounded,
                label:       'Annuler le ticket',
                color:       AppColors.danger,
                destructive: true,
                onTap: () => _cancelTicket(context, ref),
              ),

            // Résumé financier
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            _FinanceSummary(ticket: ticket),
          ],
        ),
      ),
    );
  }

  Future<void> _showGainDialog(
      BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final gain = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
        ),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Montant du gain'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saisissez le montant total à payer pour le ticket ${ticket.codeUnique}.',
              style: TextStyle(
                fontSize: 13,
                color:    Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller:   ctrl,
              autofocus:    true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText:  'Gain (G)',
                prefixIcon: Icon(Icons.attach_money_rounded),
                suffixText: 'G',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(
              ctx,
              double.tryParse(ctrl.text),
            ),
            icon:  const Icon(Icons.check_rounded, size: 16),
            label: const Text('Confirmer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
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

  Future<void> _cancelTicket(
      BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le ticket ?'),
        content: Text(
          'Le ticket ${ticket.codeUnique} sera marqué comme annulé. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(ticketsNotifierProvider.notifier)
          .updateStatus(ticket.id, TicketStatus.annule);
    }
  }
}

// ── Résumé financier ──────────────────────────────────────────

class _FinanceSummary extends StatelessWidget {
  final TicketEntity ticket;
  const _FinanceSummary({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FinanceRow(
          label: 'Montant misé',
          value: ticket.montantTotal.toCurrency,
          bold:  true,
        ),
        if (ticket.gainTotal != null) ...[
          _FinanceRow(
            label: 'Gain',
            value: ticket.gainTotal!.toCurrency,
            color: AppColors.success,
            bold:  true,
          ),
          _FinanceRow(
            label: 'Bénéfice net',
            value: (ticket.montantTotal - ticket.gainTotal!).toCurrency,
            color: ticket.montantTotal > ticket.gainTotal!
                ? AppColors.primary
                : AppColors.danger,
            bold: true,
          ),
        ],
        _FinanceRow(
          label: 'Payé',
          value: ticket.paye ? 'Oui' : 'Non',
          color: ticket.paye ? AppColors.success : Colors.grey,
        ),
      ],
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String  label;
  final String  value;
  final Color?  color;
  final bool    bold;

  const _FinanceRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color:    Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize:   13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color:      color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w700,
            color:      AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     bold;
  final Color?   color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.bold  = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:    Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize:   13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color:      color ?? AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final bool         destructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical:   AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color:        color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size:  12,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}