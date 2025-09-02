import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors from website CSS
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSidebarBg = Color(0xFFF8F8F8);
  static const Color lightTextColor = Color(0xFF212121);
  static const Color lightPrimaryColor = Color(0xFF366348);
  static const Color lightBlockBg = Color(0xFFF0F0F0);
  static const Color lightBorderColor = Color(0xFFE0E0E0);
  static const Color lightHeaderFooterBg = Color(0xFFF5F5F5);
  static const Color lightScrollbarBg = Color(0xFFF5F5F5);
  static const Color lightScrollbarThumb = Color(0xFF366348);

  // Dark theme colors from website CSS
  static const Color darkBackgroundColor = Color(0xFF121614);
  static const Color darkSidebarBg = Color(0xFF1A1F1C);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkPrimaryColor = Color(0xFF96C5A9);
  static const Color darkBlockBg = Color(0xFF15271D);
  static const Color darkBorderColor = Color(0xFF264532);
  static const Color darkHeaderFooterBg = Color(0xFF0F1C14);
  static const Color darkScrollbarBg = Color(0xFF0F1C14);
  static const Color darkScrollbarThumb = Color(0xFF96C5A9);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimaryColor,
        brightness: Brightness.light,
        primary: lightPrimaryColor,
        onPrimary: lightBackgroundColor,
        surface: lightBackgroundColor,
        onSurface: lightTextColor,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lightHeaderFooterBg,
        foregroundColor: lightTextColor,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: lightTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: lightTextColor, fontSize: 14),
        bodySmall: TextStyle(color: lightTextColor, fontSize: 12),
        titleLarge: TextStyle(
            color: lightTextColor, fontSize: 24, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
            color: lightTextColor, fontSize: 20, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(
            color: lightTextColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: lightBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: lightTextColor),
      dividerColor: lightBorderColor,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(lightScrollbarThumb),
        trackColor: WidgetStateProperty.all(lightScrollbarBg),
        radius: const Radius.circular(6),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        brightness: Brightness.dark,
        primary: darkPrimaryColor,
        onPrimary: darkBackgroundColor,
        surface: darkBackgroundColor,
        onSurface: darkTextColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: darkHeaderFooterBg,
        foregroundColor: darkTextColor,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.422),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: darkTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: darkTextColor, fontSize: 14),
        bodySmall: TextStyle(color: darkTextColor, fontSize: 12),
        titleLarge: TextStyle(
            color: darkTextColor, fontSize: 24, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
            color: darkTextColor, fontSize: 20, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(
            color: darkTextColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: Color(0xFF264532), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: darkBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: darkTextColor),
      dividerColor: darkBorderColor,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(darkScrollbarThumb),
        trackColor: WidgetStateProperty.all(darkScrollbarBg),
        radius: const Radius.circular(6),
      ),
    );
  }
}
