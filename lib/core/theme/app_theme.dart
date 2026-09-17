import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 EXACT WEBSITE THEME COLORS BASED ON SFOFINDIA CSS & BOOTSTRAP:
  // --bs-primary: #C89B3C (Gold)
  // --bs-secondary: #0A1F44 (Navy Blue)
  // --bs-dark: #3A0E19 (Deep Maroon)
  // --bs-light: #F5EDE0 (Warm Cream / Linen)
  // --bs-danger: #C1272D (Flame Red)
  // --bs-success: #B49A5A (Wreath Gold-Green)
  // --bs-info: #7A92B8 (Soft desaturated blue)
  // --bs-warning: #E8C26D (Light gold)

  static const Color primaryGold = Color(0xFFC89B3C);
  static const Color primaryGoldDark = Color(0xFFA87E28);
  static const Color primaryGoldLight = Color(0xFFE8C26D);

  static const Color secondaryNavy = Color(0xFF0A1F44);
  static const Color navyDark = Color(0xFF06142E);
  static const Color navySoft = Color(0xFF1E3A8A);

  static const Color darkMaroon = Color(0xFF3A0E19);
  static const Color warmCream = Color(0xFFF5EDE0);
  static const Color warmCreamLight = Color(0xFFFAF6EE);

  static const Color flameRed = Color(0xFFC1272D);
  static const Color wreathGreen = Color(0xFF198754);

  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color surfaceWhite = Colors.white;

  // Modern Slate Palette (matching website Tailwind/Bootstrap clean styles)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDarkBlue = Color(0xFF1E3A8A);

  // Aliases pointing to exact website brand colors
  static const Color navyPrimary = secondaryNavy;
  static const Color saffronPrimary = primaryGold;
  static const Color saffronAccent = primaryGoldLight;
  static const Color goldAccent = primaryGold;
  static const Color tricolorGreen = wreathGreen;
  static const Color backgroundLight = slate50;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryGold,
        secondary: secondaryNavy,
        surface: Colors.white,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: slate50,
        error: flameRed,
      ),
      scaffoldBackgroundColor: slate50,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: textDark,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryNavy,
          side: const BorderSide(color: secondaryNavy, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: slate200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: slate200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: flameRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: flameRed, width: 2),
        ),
        labelStyle: const TextStyle(color: slate600, fontSize: 13, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: slate400, fontSize: 13),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: slate200, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
