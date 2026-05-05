// lib/shared/theme/app_theme.dart

import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ColorScheme.fromSeed(
      seedColor:  AppColors.primary,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base.copyWith(
        primary:   AppColors.primary,
        secondary: AppColors.accent,
        surface:   AppColors.surfaceLight,
        error:     AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.sm + 4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color:    Colors.grey.shade200,
        thickness: 1,
        space:     1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor:       Colors.white,
        elevation:             0,
        scrolledUnderElevation: 1,
        foregroundColor:       AppColors.primary,
      ),
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme {
    final base = ColorScheme.fromSeed(
      seedColor:  AppColors.primary,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base.copyWith(
        primary:   AppColors.primaryLight,
        secondary: AppColors.accent,
        surface:   AppColors.surfaceDark,
        error:     AppColors.danger,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      cardTheme: CardThemeData(
        elevation: 0,
        color:     AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: Color(0xFF2D3748)),
        ),
      ),
      fontFamily: 'Inter',
    );
  }
}