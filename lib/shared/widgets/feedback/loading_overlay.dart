import 'package:flutter/material.dart';
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay({super.key, required this.isLoading, required this.child});
  @override
  Widget build(BuildContext context) => Stack(children: [
    child,
    if (isLoading) const Positioned.fill(child: ColoredBox(color: Color(0x55FFFFFF), child: Center(child: CircularProgressIndicator()))),
  ]);
}
