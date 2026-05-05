// lib/shared/widgets/buttons/primary_button.dart

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String       label;
  final VoidCallback? onPressed;
  final bool         loading;
  final IconData?    icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width:  16,
              height: 16,
              child:  CircularProgressIndicator(
                strokeWidth: 2,
                color:       Colors.white,
              ),
            )
          : (icon != null
              ? Icon(icon, size: 18)
              : const SizedBox.shrink()),
      label: Text(label),
    );
  }
}