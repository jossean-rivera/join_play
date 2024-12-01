import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData customThemeData = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF189AB4),
    onPrimary: Colors.white,
    secondary: const Color(0xFFD4F1F4),
    onSecondary: Colors.black87,
    error: Colors.red[300]!,
    onError: Colors.white,
    surface: const Color(0xFF05445E),
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF05445E),
  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
    ),
    // ···
    titleLarge: GoogleFonts.oswald(
      fontSize: 42,
      fontStyle: FontStyle.italic,
    ),
    bodyMedium: GoogleFonts.merriweather(),
    displaySmall: GoogleFonts.pacifico(),
  ),
  // Set global style for TextButton
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF75E6DA), // Link color globally
      textStyle: GoogleFonts.merriweather(), // Optional: Custom font
    ),
  ),
);
