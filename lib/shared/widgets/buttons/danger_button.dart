// lib/shared/widgets/buttons/danger_button.dart

import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DangerButton extends StatelessWidget {
  final String       label;
  final VoidCallback? onPressed;

  const DangerButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}