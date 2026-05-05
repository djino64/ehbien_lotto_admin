// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/shared/routing/app_router.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_theme.dart';

class EhbienAdminApp extends ConsumerWidget {
  const EhbienAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title:                    'Ehbien Lotto — Admin',
      debugShowCheckedModeBanner: false,
      theme:                    AppTheme.lightTheme,
      darkTheme:                AppTheme.darkTheme,
      themeMode:                ThemeMode.light,
      routerConfig:             router,
    );
  }
}