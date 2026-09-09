import 'package:flutter/material.dart';

abstract final class AppColors {
  static const park = Color(0xFF9FC69A);
  static const splashBackground = Color(0xFFFFF3D9);
  static const navigationBackground = Color(0xFFFFF8E8);
  static const selected = Color(0xFF375A3C);
  static const placeholderBackground = Color(0xFFF4EEDF);
  static const text = Color(0xFF28352A);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.selected,
      brightness: Brightness.light,
      surface: AppColors.navigationBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.park,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.text),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.navigationBackground,
        indicatorColor: Color(0xFFDDE9D6),
        elevation: 0,
        height: 74,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
