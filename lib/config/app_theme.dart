

import 'package:flutter/material.dart';

class AppTheme {
  // Green shades
  static const Color greenPrimary = Color(0xFF4CAF50);
  static const Color greenLight = Color(0xFF81C784);
  static const Color greenDark = Color(0xFF388E3C);

  // Purple shades
  static const Color purplePrimary = Color(0xFF9C27B0);
  static const Color purpleLight = Color(0xFFBA68C8);
  static const Color purpleDark = Color(0xFF7B1FA2);

  static final ThemeData themeData = ThemeData(
    primaryColor: greenPrimary,
    colorScheme: ColorScheme.light(
      primary: greenPrimary,
      primaryContainer: greenDark,
      secondary: purplePrimary,
      secondaryContainer: purpleDark,
      surface: Colors.white,
      background: Color(0xFFF0F4F0),
      error: Colors.red.shade400,
    ),
    scaffoldBackgroundColor: Color(0xFFF0F4F0),
    appBarTheme: AppBarTheme(
      backgroundColor: greenPrimary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: purplePrimary,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: greenDark,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: greenDark),
      titleMedium: TextStyle(color: greenDark),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: purplePrimary),
      ),
      labelStyle: TextStyle(color: greenDark),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconTheme: IconThemeData(
      color: greenDark,
    ),
    dividerTheme: DividerThemeData(
      color: greenLight.withOpacity(0.5),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: purplePrimary,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: purplePrimary,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Custom color getters
  static Color get success => greenLight;
  static Color get warning => Colors.orange;
  static Color get error => Colors.red.shade400;
  static Color get info => Colors.blue;
}