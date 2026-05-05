// lib/features/tickets/presentation/widgets/ticket_status_badge.dart

import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TicketStatusBadge extends StatelessWidget {
  final TicketStatus status;
  final bool         large;

  const TicketStatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      TicketStatus.brouillon => (Colors.orange,       'Brouillon', Icons.edit_rounded),
      TicketStatus.valide    => (AppColors.info,       'Validé',    Icons.check_rounded),
      TicketStatus.gagnant   => (AppColors.warning,    'Gagnant',   Icons.emoji_events_rounded),
      TicketStatus.perdant   => (Colors.grey,          'Perdant',   Icons.close_rounded),
      TicketStatus.paye      => (AppColors.success,    'Payé',      Icons.payments_rounded),
      TicketStatus.annule    => (AppColors.danger,     'Annulé',    Icons.cancel_rounded),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical:   large ? 6  : 3,
      ),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 14 : 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color:      color,
              fontSize:   large ? 13 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}