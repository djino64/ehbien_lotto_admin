import 'package:flutter/material.dart';
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  final double breakpoint;
  const ResponsiveLayout({super.key, required this.mobile, required this.desktop, this.breakpoint = 900});
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 900;
  static bool isMobile(BuildContext context)  => MediaQuery.sizeOf(context).width < 900;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return constraints.maxWidth >= breakpoint ? desktop : mobile;
    });
  }
}
