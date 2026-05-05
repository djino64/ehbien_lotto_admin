import 'package:flutter/material.dart';
class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;
  const EmptyState({super.key, required this.message, this.icon, this.action});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon ?? Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
    const SizedBox(height: 16),
    Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
    if (action != null) ...[const SizedBox(height: 16), action!],
  ]));
}
