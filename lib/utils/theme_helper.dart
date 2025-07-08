import 'package:flutter/material.dart';

/// Helper class for generating MaterialColor swatches for the theme
class ThemeHelper {
  /// MaterialColor for primary purple from Material Design
  static final MaterialColor materialPurple = MaterialColor(
    0xFF673AB7,
    <int, Color>{
      50: Color(0xFFF3E5F5),
      100: Color(0xFFE1BEE7),
      200: Color(0xFFCE93D8),
      300: Color(0xFFBA68C8),
      400: Color(0xFFAB47BC),
      500: Color(0xFF9C27B0),
      600: Color(0xFF8E24AA),
      700: Color(0xFF7B1FA2),
      800: Color(0xFF6A1B9A),
      900: Color(0xFF4A148C),
    },
  );

  /// MaterialAccentColor for the purple accent
  static final MaterialAccentColor materialPurpleAccent = MaterialAccentColor(
    0xFFE040FB,
    <int, Color>{
      100: Color(0xFFEA80FC),
      200: Color(0xFFE040FB),
      400: Color(0xFFD500F9),
      700: Color(0xFFAA00FF),
    },
  );
  
  /// Get light theme for the app
  static ThemeData getLightTheme() {
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFF673AB7),
      primaryContainer: const Color(0xFF512DA8),
      secondary: const Color(0xFF03DAC6),
      secondaryContainer: const Color(0xFF018786),
      surface: const Color(0xFFFFFFFF),
      error: const Color(0xFFB00020),
    );
    
    return ThemeData(
      primaryColor: const Color(0xFF673AB7),
      primaryColorDark: const Color(0xFF512DA8),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Explicit background color
      appBarTheme: const AppBarTheme(
        color: Color(0xFF673AB7),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: const Color(0xFF673AB7),
        ),
      ),
    );
  }

  /// Get dark theme for the app
  static ThemeData getDarkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFFBB86FC),
      primaryContainer: const Color(0xFF512DA8),
      secondary: const Color(0xFF03DAC6),
      secondaryContainer: const Color(0xFF03DAC6),
      surface: const Color(0xFF1E1E1E),
      error: const Color(0xFFCF6679),
    );
    
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFFBB86FC),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212), // Explicit background color
      appBarTheme: const AppBarTheme(
        color: Color(0xFF1E1E1E),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFBB86FC),
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, 
          backgroundColor: const Color(0xFFBB86FC),
        ),
      ),
    );
  }
} 