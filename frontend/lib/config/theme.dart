import 'package:flutter/material.dart';

class AppTheme {
  static const Color green = Color(0xFF00B09B);
  static const Color red = Color(0xFFE74C3C);
  static const Color gold = Color(0xFFF0A500);
  static const Color blue = Color(0xFF3498DB);
  static const Color violet = Color(0xFF9B59B6);
  static const Color dark = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color cardSurface = Color(0xFF1C2333);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: dark,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: green,
          secondary: blue,
          error: red,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: cardSurface,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: green,
          unselectedLabelColor: Colors.white54,
          indicatorColor: green,
        ),
      );
}
