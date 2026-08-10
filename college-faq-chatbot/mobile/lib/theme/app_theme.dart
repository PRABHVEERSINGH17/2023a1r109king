import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF0F1419);
  static const surface = Color(0xFF1A2332);
  static const surfaceLight = Color(0xFF243044);
  static const border = Color(0xFF2D3A4F);
  static const primary = Color(0xFF3B82F6);
  static const botBubble = Color(0xFF1E2A3D);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: surface),
      useMaterial3: true,
    );
  }
}
