// lib/features/agents/presentation/widgets/agent_limit_indicator.dart

import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AgentLimitIndicator extends StatelessWidget {
  final double current;
  final double max;
  final bool showLabel;

  const AgentLimitIndicator({
    super.key,
    required this.current,
    required this.max,
    this.showLabel = true,
  });

  double get _percent =>
      max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

  Color get _color {
    if (_percent >= 1.0) return AppColors.danger;
    if (_percent >= 0.8) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Limite journalière',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '${current.toCurrency} / ${max.toCurrency}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:           _percent,
            minHeight:       6,
            backgroundColor: Colors.grey.shade100,
            valueColor:      AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }
}