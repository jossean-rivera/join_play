import 'package:flutter/cupertino.dart';
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

CupertinoThemeData customCupertinoThemeData = CupertinoThemeData(
  primaryColor: CustomColors.blueGrotto,
  barBackgroundColor: CustomColors.navyBlue,
  scaffoldBackgroundColor: CustomColors.navyBlue,
  textTheme: CupertinoTextThemeData(
    textStyle: GoogleFonts.raleway(
      color: CupertinoColors.white,
      fontSize: 16,
    ),
    actionTextStyle: GoogleFonts.oswald(
      color: CustomColors.babyBlue,
      fontSize: 18,
    ),
    tabLabelTextStyle: GoogleFonts.oswald(
      color: CustomColors.babyBlue,
      fontSize: 14,
    ),
    navLargeTitleTextStyle: GoogleFonts.oswald(
      fontSize: 42,
      color: CustomColors.babyBlue,
      fontWeight: FontWeight.bold,
    ),
    navTitleTextStyle: GoogleFonts.oswald(
      fontSize: 20,
      color: CustomColors.babyBlue,
    ),
  ),
);

class CustomTheme {
  // Function to generate a 3D Text Widget
  static Widget threeDText({
    required String text,
    required double fontSize,
    required Color textColor,
    required Color shadowColor,
    double shadowOffsetX = 3,
    double shadowOffsetY = 3,
    double blurRadius = 4,
  }) {
    return Stack(
      children: [
        // Shadow Layer
        Positioned(
          left: shadowOffsetX,
          top: shadowOffsetY,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: '.SF UI Text',
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: shadowColor, // Shadow color
            ),
          ),
        ),
        // Main Text Layer
        Text(
          text,
          style: TextStyle(
            fontFamily: '.SF UI T',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor, // Main text color
            shadows: [
              Shadow(
                offset: Offset(shadowOffsetX, shadowOffsetY),
                blurRadius: blurRadius,
                color: shadowColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Custom Cupertino Input Decoration
  static BoxDecoration cupertinoInputDecoration() {
    return BoxDecoration(
      color: CustomColors.navyBlue,
      border: Border.all(
        color: CustomColors.babyBlue,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  // Custom Cupertino Button Style
  static Widget cupertinoButton({
    required VoidCallback onPressed,
    required String text,
    Color backgroundColor = CustomColors.blueGreen,
    Color textColor = CupertinoColors.white,
  }) {
    return CupertinoButton(
      color: backgroundColor,
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.oswald(
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }
}
