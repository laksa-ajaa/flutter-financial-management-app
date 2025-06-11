import 'package:flutter/material.dart';

// Custom color scheme
const primaryColor = Color(0xFF201E43); // Dark blue/purple
const secondaryColor = Color(0xFF134B70); // Medium blue
const accentColor = Color(0xFF508C9B); // Teal/blue-green
const backgroundColor = Color(0xFFEEEEEE); // Light gray

final appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: accentColor,
    background: backgroundColor,
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: accentColor, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: secondaryColor),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: accentColor,
    unselectedItemColor: Colors.grey,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
  ),
);
