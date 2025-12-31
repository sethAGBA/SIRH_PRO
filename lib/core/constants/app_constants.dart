import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0EA5E9);
  static const Color primaryDark = Color(0xFF0284C7);
  static const Color sidebarTop = Color(0xFF0F172A);
  static const Color sidebarBottom = Color(0xFF111827);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color alert = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
}

class AppSpacing {
  static const double pagePadding = 24;
  static const double cardRadius = 16;
}

Color appTextPrimary(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface;
}

Color appTextMuted(BuildContext context) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return onSurface.withOpacity(0.6);
}

Color appCardColor(BuildContext context) {
  return Theme.of(context).cardColor;
}

Color appBorderColor(BuildContext context) {
  return Theme.of(context).dividerColor;
}
