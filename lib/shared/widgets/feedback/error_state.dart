// lib/shared/widgets/feedback/error_state.dart

import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String       message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.danger, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}