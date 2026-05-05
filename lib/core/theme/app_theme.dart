import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color primary = Color(0xFF1A237E);       // deep indigo
  static const Color accent = Color(0xFF8B9E5A);        // olive green
  static const Color background = Color(0xFF121212);    // dark background
  static const Color surface = Color(0xFF1E1E1E);       // card surface
  static const Color onSurface = Color(0xFFE0E0E0);     // text on dark
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onSurface: onSurface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurface,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }
}
