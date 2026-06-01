import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0056D2); // Bright royal blue
  static const Color background = Color(0xFFF8F9FA); // Very light gray
  static const Color success = Color(0xFF2FBF71);
  static const Color danger = Color(0xFFE15554);
  static const Color onPrimary = Colors.white;
  static const double borderRadius = 16.0;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: Colors.grey.shade600,
      surface: Colors.white,
      background: background,
      error: danger,
    );

    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
