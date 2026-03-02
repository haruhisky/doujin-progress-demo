import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── カラーパレット（くすみパステル） ──
  static const Color primary = Color(0xFFD4A0B9);
  static const Color secondary = Color(0xFFB8C5D6);
  static const Color tertiary = Color(0xFFC9B8A8);
  static const Color surface = Color(0xFFFBF8F4);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF5A5252);
  static const Color textLight = Color(0xFF9E9494);
  static const Color borderColor = Color(0xFFEDE7E1);

  // ── 装飾定数 ──
  static const double cardRadius = 16.0;
  static const double buttonRadius = 16.0;
  static const double stickerSize = 48.0;

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static ThemeData get theme {
    final textTheme = GoogleFonts.notoSansJpTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}
