import 'package:flutter/material.dart';

/// TR Tech modern design tokens — teal ink on soft mist (not purple/dark-default).
class AppColors {
  // Atmosphere
  static const background = Color(0xFFF3F6F8);
  static const backgroundAlt = Color(0xFFE8EEF2);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF7FAFB);
  static const surfaceLight = Color(0xFFEDF3F6);
  static const border = Color(0xFFD5DEE5);
  static const borderStrong = Color(0xFFB7C5CF);

  // Brand
  static const brand = Color(0xFF0B3B44);
  static const brandDeep = Color(0xFF072C33);
  static const primary = Color(0xFF0F766E);
  static const primaryLight = Color(0xFF14B8A6);
  static const primarySoft = Color(0xFFCCFBF1);
  static const accent = Color(0xFFE11D48);

  // Semantic
  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFC2410C);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF0369A1);

  // Text
  static const textPrimary = Color(0xFF102A33);
  static const textSecondary = Color(0xFF5B6F7A);
  static const textMuted = Color(0xFF8A9BA5);
  static const textOnBrand = Color(0xFFF5FBFC);

  // Charts / accents
  static const chart1 = Color(0xFF0F766E);
  static const chart2 = Color(0xFF0369A1);
  static const chart3 = Color(0xFF15803D);
  static const chart4 = Color(0xFFC2410C);
  static const chart5 = Color(0xFFBE123C);

  static const List<Color> heroGradient = [
    Color(0xFF0B3B44),
    Color(0xFF0F5C63),
    Color(0xFF0F766E),
  ];

  static const List<Color> canvasGradient = [
    Color(0xFFF3F6F8),
    Color(0xFFE7F2F1),
    Color(0xFFF3F6F8),
  ];
}
