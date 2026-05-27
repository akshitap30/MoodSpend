import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF111111);
  static const Color card = Color(0xFF161616);
  static const Color cardElevated = Color(0xFF1C1C1C);

  // Borders
  static const Color border = Color(0xFF222222);
  static const Color borderMuted = Color(0xFF1A1A1A);

  // Accents
  static const Color accentLime = Color(0xFFC8F135);
  static const Color accentCoral = Color(0xFFFF6B35);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF444444);

  // Semantic
  static const Color success = Color(0xFF2DD4BF);
  static const Color danger = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFAA00);

  // Chart palette
  static const List<Color> chartPalette = [
    Color(0xFFC8F135),
    Color(0xFF2DD4BF),
    Color(0xFFFF6B35),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
  ];
}
