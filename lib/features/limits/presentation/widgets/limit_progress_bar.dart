// lib/features/limits/presentation/widgets/limit_progress_bar.dart

import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/limits/domain/entities/limit_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class LimitProgressBar extends StatelessWidget {
  final LimitEntity limit;
  final bool        compact;

  const LimitProgressBar({
    super.key,
    required this.limit,
    this.compact = false,
  });

  Color get _color {
    final pct = limit.percentUsed;
    if (pct >= 1.0) return AppColors.danger;
    if (pct >= 0.8) return AppColors.warning;
    if (pct >= 0.5) return AppColors.info;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull();
  }

  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(limit.percentUsed * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize:   11,
                fontWeight: FontWeight.w700,
                color:      _color,
              ),
            ),
            Text(
              limit.currentAmount.toCurrency,
              style: TextStyle(
                fontSize: 11,
                color:    Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:           limit.percentUsed,
            minHeight:       6,
            backgroundColor: Colors.grey.shade100,
            valueColor:      AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }

  Widget _buildFull() {
    return Container(
      padding:    const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        _color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ──────────────────────────────────
          Row(
            children: [
              _TypeLabel(limit: limit),
              const Spacer(),
              if (limit.isAtLimit)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical:   3,
                  ),
                  decoration: BoxDecoration(
                    color:        AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size:  12,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Limite atteinte',
                        style: TextStyle(
                          fontSize:   11,
                          color:      AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Barre ────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:           limit.percentUsed,
              minHeight:       10,
              backgroundColor: Colors.grey.shade100,
              valueColor:      AlwaysStoppedAnimation<Color>(_color),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Chiffres ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Utilisé : ${limit.currentAmount.toCurrency}',
                style: TextStyle(
                  fontSize:   12,
                  color:      _color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Max : ${limit.maxGlobal.toCurrency}',
                style: TextStyle(
                  fontSize: 12,
                  color:    Colors.grey.shade500,
                ),
              ),
              Text(
                '${(limit.percentUsed * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w800,
                  color:      _color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeLabel extends StatelessWidget {
  final LimitEntity limit;
  const _TypeLabel({required this.limit});

  @override
  Widget build(BuildContext context) {
    final scope = limit.isGlobal ? 'Global' : 'Agent';
    final jeu   = limit.typeJeu ?? 'Tous jeux';
    final boule = limit.boule != null ? ' • Boule ${limit.boule}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$scope$boule',
          style: const TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w700,
            color:      AppColors.primary,
          ),
        ),
        Text(
          jeu,
          style: TextStyle(
            fontSize: 11,
            color:    Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}