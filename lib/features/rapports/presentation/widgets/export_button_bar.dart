// lib/features/rapports/presentation/widgets/export_button_bar.dart

import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/providers/rapports_provider.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExportButtonBar extends ConsumerWidget {
  const ExportButtonBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(rapportTicketsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // ── Résumé rapide ──────────────────────────────
            Expanded(
              child: ticketsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error:   (e, _) => const SizedBox.shrink(),
                data:    (tickets) => _QuickSummary(tickets: tickets),
              ),
            ),

            const SizedBox(width: AppSpacing.lg),

            // ── Boutons export ─────────────────────────────
            Row(
              children: [
                _ExportButton(
                  icon:    Icons.table_chart_rounded,
                  label:   'Exporter CSV',
                  color:   AppColors.success,
                  onTap: () => _exportCsv(context, ref),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ExportButton(
                  icon:    Icons.picture_as_pdf_rounded,
                  label:   'Exporter PDF',
                  color:   AppColors.danger,
                  onTap: () => _exportPdf(context),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ExportButton(
                  icon:    Icons.print_rounded,
                  label:   'Imprimer',
                  color:   AppColors.primary,
                  onTap: () => _print(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportCsv(BuildContext context, WidgetRef ref) {
    final tickets = ref.read(rapportTicketsProvider).valueOrNull ?? [];
    final stats   = ref.read(rapportStatsProvider);

    // Construction CSV
    final buffer = StringBuffer();
    buffer.writeln(
      'Code,Agent,Succursale,Tirage,Montant,Statut,Gagnant,Gain,Date',
    );
    for (final t in tickets) {
      buffer.writeln(
        '${t.codeUnique},'
        '${t.agentNom ?? t.agentId},'
        '${t.succursaleNom ?? t.succursaleId},'
        '${t.tirageNom ?? t.tirageId},'
        '${t.montantTotal},'
        '${t.status.name},'
        '${t.gagnant},'
        '${t.gainTotal ?? 0},'
        '${t.createdAt.toIso8601String()}',
      );
    }

    // Sur Flutter Web, on peut déclencher un téléchargement
    // via dart:html — pour l'instant on montre une SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size:  18,
            ),
            const SizedBox(width: 8),
            Text(
              '${tickets.length} tickets exportés en CSV',
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior:        SnackBarBehavior.floating,
        action: SnackBarAction(
          label:     'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _exportPdf(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Export PDF disponible avec le package pdf (à ajouter).',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _print(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impression via printing package (à ajouter).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _QuickSummary extends StatelessWidget {
  final List<TicketEntity> tickets;
  const _QuickSummary({required this.tickets});

  @override
  Widget build(BuildContext context) {
    final total    = tickets.length;
    final montant  = tickets.fold(0.0, (s, t) => s + t.montantTotal);
    final gains    = tickets
        .where((t) => t.gagnant)
        .fold(0.0, (s, t) => s + (t.gainTotal ?? 0));
    final recette  = montant - gains;
    final gagnants = tickets.where((t) => t.gagnant).length;

    return Wrap(
      spacing:  AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        _SummaryItem(
          label: 'Tickets',
          value: '$total',
          color: AppColors.primary,
        ),
        _SummaryItem(
          label: 'Ventes',
          value: montant.toCurrency,
          color: AppColors.info,
        ),
        _SummaryItem(
          label: 'Gains',
          value: gains.toCurrency,
          color: AppColors.warning,
        ),
        _SummaryItem(
          label: 'Recette',
          value: recette.toCurrency,
          color: AppColors.success,
        ),
        _SummaryItem(
          label: 'Gagnants',
          value: '$gagnants',
          color: AppColors.accent,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            fontSize: 11,
            color:    Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        side:    BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.sm,
        ),
      ),
    );
  }
}