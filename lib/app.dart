import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/theme_controller.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class SirhProApp extends StatefulWidget {
  const SirhProApp({super.key});

  @override
  State<SirhProApp> createState() => _SirhProAppState();
}

class _SirhProAppState extends State<SirhProApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SIRH Pro',
            themeMode: _themeController.mode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}

ThemeData _buildLightTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    cardColor: AppColors.card,
    dividerColor: AppColors.border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    useMaterial3: true,
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.sidebarBottom,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1220),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardColor: const Color(0xFF111827),
    dividerColor: Colors.white.withOpacity(0.08),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    useMaterial3: true,
  );
}
