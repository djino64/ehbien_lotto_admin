// lib/features/dashboard/presentation/widgets/recent_tickets_table.dart

import 'package:ehbien_lotto_admin/core/extensions/datetime_ext.dart';
import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/providers/tickets_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecentTicketsTable extends ConsumerWidget {
  const RecentTicketsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsStreamProvider);

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
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.info,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Derniers tickets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(RouteNames.ticketsList),
                  child: const Text('Voir tout'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Table ──────────────────────────────────────
            ticketsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => const Text('Erreur de chargement'),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: Text(
                        'Aucun ticket récent',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(1.5),
                  },
                  children: [
                    // En-tête
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      children: [
                        'Code',
                        'Agent',
                        'Montant',
                        'Date',
                        'Statut',
                      ]
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Text(
                                h,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    // Lignes
                    ...tickets.take(8).map(
                          (t) => TableRow(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF0F0F0),
                                ),
                              ),
                            ),
                            children: [
                              _Cell(
                                child: InkWell(
                                  onTap: () => context.go(
                                    '/tickets/${t.id}',
                                  ),
                                  child: Text(
                                    t.codeUnique,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              _Cell(
                                child: Text(
                                  t.agentNom ?? t.agentId,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _Cell(
                                child: Text(
                                  t.montantTotal.toCurrency,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _Cell(
                                child: Text(
                                  t.createdAt.toDisplayDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              _Cell(child: _StatusBadge(t.status)),
                            ],
                          ),
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final Widget child;
  const _Cell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      TicketStatus.valide    => (AppColors.info,    'Validé'),
      TicketStatus.gagnant   => (AppColors.warning, 'Gagnant'),
      TicketStatus.perdant   => (Colors.grey,       'Perdant'),
      TicketStatus.paye      => (AppColors.success, 'Payé'),
      TicketStatus.annule    => (AppColors.danger,  'Annulé'),
      TicketStatus.brouillon => (Colors.orange,     'Brouillon'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:      color,
          fontSize:   10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}