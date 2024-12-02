import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomColors {
  static const Color navyBlue = Color(0xFF032533);
  static const Color blueGrotto = Color(0xFF189AB4);
  static const Color blueGreen = Color(0xFF75E6DA);
  static const Color babyBlue = Color.fromARGB(255, 193, 235, 239);
  static const Color lightError = Color.fromARGB(223, 231, 164, 160);
  static const Color darkError = Color.fromARGB(255, 131, 38, 52);
  static const Color darkerError = Color.fromARGB(255, 71, 20, 28);
  static const Color lightGrey = Color.fromARGB(255, 212, 236, 239);
}

ThemeData customThemeData = ThemeData(
    useMaterial3: true,

    // Set color pallete
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: CustomColors.babyBlue,
      onPrimary: CustomColors.navyBlue,
      secondary: CustomColors.lightGrey,
      onSecondary: CustomColors.navyBlue,
      error: CustomColors.darkError,
      onError: Colors.white,
      surface: CustomColors.navyBlue,
      onSurface: Colors.white,
    ),

    // Set background of scafolds
    scaffoldBackgroundColor: CustomColors.navyBlue,
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
      titleMedium: GoogleFonts.oswald(fontStyle: FontStyle.italic),
      titleSmall: GoogleFonts.oswald(),
      headlineLarge: GoogleFonts.oswald(fontStyle: FontStyle.italic),
      headlineMedium: GoogleFonts.oswald(fontStyle: FontStyle.italic),
      headlineSmall: GoogleFonts.oswald(),
      bodyMedium: GoogleFonts.raleway(),
      displaySmall: GoogleFonts.raleway(fontStyle: FontStyle.italic),
    ),
    // Set global style for TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF75E6DA), // Link color globally
        textStyle: GoogleFonts.merriweather(), // Optional: Custom font
      ),
    ),

    // Global InputDecorationTheme for TextFormField and others
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: WidgetStateTextStyle.resolveWith((state) {
        if (state.contains(WidgetState.error)) {
          return const TextStyle(color: CustomColors.lightError);
        }

        return const TextStyle(color: Colors.white);
      }), // Label text color
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: CustomColors.babyBlue, // Focused border color
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.white, // Enabled (unfocused) border color
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: CustomColors.lightError, // Error border color
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: CustomColors.lightError, // Focused error border color
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      floatingLabelStyle: const TextStyle(color: Colors.white),
      errorStyle: const TextStyle(color: CustomColors.lightError),
      hintStyle: const TextStyle(color: Colors.white), // Hint text color
    ),
    filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(GoogleFonts.oswald(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.normal)))));
