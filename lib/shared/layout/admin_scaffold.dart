// lib/shared/layout/admin_scaffold.dart

import 'package:ehbien_lotto_admin/shared/layout/responsive_layout.dart';
import 'package:ehbien_lotto_admin/shared/layout/side_nav.dart';
import 'package:ehbien_lotto_admin/shared/layout/top_bar.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  const AdminScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: ResponsiveLayout(
        desktop: Row(
          children: [
            const SideNav(),
            Expanded(
              child: Column(
                children: [
                  const TopBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.contentPadding),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        mobile: Scaffold(
          appBar: AppBar(
            title: const Text('Ehbien Admin'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          drawer: const Drawer(child: SideNav()),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}