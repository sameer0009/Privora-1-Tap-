import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF00FF66);
  static const Color secondaryGreen = Color(0xFF003314);
  static const Color backgroundBlack = Color(0xFF080808);
  static const Color surfaceGrey = Color(0xFF141414);
  static const Color errorRed = Color(0xFFFF3333);
  static const Color textMain = Colors.white;
  static const Color textDim = Colors.white54;

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    primaryColor: primaryGreen,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: primaryGreen,
      surface: surfaceGrey,
      error: errorRed,
      onPrimary: Colors.black,
      onSurface: textMain,
    ),

    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2, color: textMain),
      headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textMain),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, color: textMain),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, color: textDim),
      labelSmall: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: primaryGreen),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryGreen),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceGrey,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 1)),
      labelStyle: const TextStyle(color: textDim),
      floatingLabelStyle: const TextStyle(color: primaryGreen),
    ),

    cardTheme: CardThemeData(
      color: surfaceGrey,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
