import 'package:flutter/material.dart';

class AppTheme {
  // Main Colors
  static const Color primaryGreen = Color(0xFFC6F048); // Lime Green
  static const Color primaryBlack = Color(0xFF1C1C1E); // Dark Background/Text
  static const Color secondaryBlack = Color(0xFF2C2C2E); // Slightly lighter black
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF2F2F7); // Light Gray Background
  
  // Status Colors
  static const Color errorRed = Color(0xFFFF453A);
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningOrange = Color(0xFFFF9F0A);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'Poppins',
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryBlack,
      surface: surfaceWhite,
      error: errorRed,
      onPrimary: primaryBlack,
      onSecondary: surfaceWhite,
      onSurface: textPrimary,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: textSecondary),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: primaryBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryBlack),
      titleTextStyle: TextStyle(
        color: primaryBlack,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),
  );

  // Background gradient (Legacy support - mapped to solid or new gradient)
  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlack,
      secondaryBlack,
    ],
  );

  // Button gradient (Legacy support)
  static LinearGradient get buttonGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primaryGreen,
      primaryGreen,
    ],
  );

  // Legacy Color mappings for backward compatibility
  static const Color primaryDarkBlue = primaryBlack;
  static const Color secondaryDarkBlue = secondaryBlack;
  static const Color accentBlue = primaryGreen; // Map accent to green
  static const Color lightBlue = primaryGreen; // Map light blue to green
  static const Color success = successGreen;
  static const Color error = errorRed;
  static const Color warning = warningOrange;
  static const Color textGray = textSecondary;
  static const Color textDark = textPrimary;
  
  // Glassmorphic colors (Legacy)
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x80FFFFFF);

  // Theme data
  static ThemeData get darkTheme => lightTheme; // For now forcing light theme as per primary designs
}
