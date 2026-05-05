import 'package:flutter/material.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;
  const ConfirmDialog({super.key, required this.title, required this.message, this.confirmLabel = 'Confirmer', this.destructive = false});
  static Future<bool?> show(BuildContext context, {required String title, required String message, String confirmLabel = 'Confirmer', bool destructive = false}) =>
      showDialog<bool>(context: context, builder: (_) => ConfirmDialog(title: title, message: message, confirmLabel: confirmLabel, destructive: destructive));
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: destructive ? ElevatedButton.styleFrom(backgroundColor: AppColors.danger) : null,
        child: Text(confirmLabel),
      ),
    ],
  );
}
