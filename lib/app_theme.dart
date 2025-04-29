import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Colors
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryGray = Color(0xFF9E9E9E);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF616161);

  // Feature-specific colors
  static const Color japamPurple = Color(0xFF9C27B0);
  static const Color tarapanmTeal = Color(0xFF26A69A);
  static const Color homamOrange = Color(0xFFFF9800);
  static const Color danamGreen = Color(0xFF8BC34A);

  // Background color
  static const Color background = Color(
    0xFFFFC107,
  ); // Yellow background from screenshot
  static const Color cardBackground = Colors.white;

  // Create the app theme
  static ThemeData get theme => ThemeData(
    primaryColor: primaryRed,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primaryRed,
      secondary: primaryYellow,
      surface: cardBackground,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryRed,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: darkGray,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkGray,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkGray,
      ),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: darkGray),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: darkGray),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackground,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryRed,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: primaryGray),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryRed,
      unselectedItemColor: primaryGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
