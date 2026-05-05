// lib/features/agents/presentation/widgets/agent_status_badge.dart

import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AgentStatusBadge extends StatelessWidget {
  final AgentStatus status;
  final bool large;

  const AgentStatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      AgentStatus.actif    => (AppColors.success, 'Actif',    Icons.check_circle_rounded),
      AgentStatus.inactif  => (Colors.grey,       'Inactif',  Icons.pause_circle_rounded),
      AgentStatus.bloque   => (AppColors.danger,  'Bloqué',   Icons.block_rounded),
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