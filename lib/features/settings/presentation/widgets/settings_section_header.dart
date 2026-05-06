// lib/features/settings/presentation/widgets/settings_section_header.dart

import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String   title;
  final IconData icon;
  final String?  subtitle;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        top:    AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size:  18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.primary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color:    Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Divider(color: Colors.grey.shade200),
          ),
        ],
      ),
    );
  }
}