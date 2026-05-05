// lib/features/tirages/presentation/widgets/tirage_status_badge.dart

import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TirageStatusBadge extends StatelessWidget {
  final TirageStatus status;
  final bool large;

  const TirageStatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      TirageStatus.ouvert  => (AppColors.success, 'Ouvert',  Icons.lock_open_rounded),
      TirageStatus.ferme   => (Colors.grey,       'Fermé',   Icons.lock_rounded),
      TirageStatus.publie  => (AppColors.primary, 'Publié',  Icons.check_circle_rounded),
      TirageStatus.annule  => (AppColors.danger,  'Annulé',  Icons.cancel_rounded),
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