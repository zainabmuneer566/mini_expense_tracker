import 'package:flutter/material.dart';

/// Central place for the app palette (indigo/violet primary + teal accent).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF5B4BDB);
  static const primaryLight = Color(0xFF7C5CFF);
  static const accent = Color(0xFF14B8A6);
  static const background = Color(0xFFF5F6FB);
  static const surface = Colors.white;
  static const textDark = Color(0xFF1E1B3A);
  static const textMuted = Color(0xFF6B7280);
  static const danger = Color(0xFFE5484D);

  static const headerGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
