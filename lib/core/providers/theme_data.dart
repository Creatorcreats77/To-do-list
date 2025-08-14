import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.grey[800],             // Dark Gray
  scaffoldBackgroundColor: Colors.grey[200], // Light Gray background
  colorScheme: ColorScheme.light(
    primary: Colors.grey[800]!,               // Dark Gray
    secondary: Colors.grey[600]!,             // Medium Gray accent
    background: Colors.grey[200]!,            // Light Gray background
    surface: Colors.white,                     // White cards, surfaces
    onPrimary: Colors.white,                   // Text/icon on primary
    onSecondary: Colors.black87,               // Text/icon on secondary
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[800],        // Dark Gray app bar
    foregroundColor: Colors.white,             // White text/icons on app bar
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[300],             // Light Gray for primary
  scaffoldBackgroundColor: Colors.black,      // Black background
  colorScheme: ColorScheme.dark(
    primary: Colors.grey[300]!,                // Light Gray primary
    secondary: Colors.grey[500]!,              // Medium Gray accent
    background: Colors.black,                   // Black background
    surface: Colors.grey[900]!,                 // Dark gray surfaces
    onPrimary: Colors.black87,                  // Text/icon on primary color
    onSecondary: Colors.white70,                 // Text/icon on secondary color
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],          // Dark gray app bar
    foregroundColor: Colors.white,               // White text/icons
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white70),
  ),
);
