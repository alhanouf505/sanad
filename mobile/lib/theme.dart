import 'package:flutter/material.dart';

/// ألوان سند — نفس هوية الموقع.
class SanadColors {
  static const teal900 = Color(0xFF0D3B3E);
  static const teal700 = Color(0xFF12595E);
  static const teal500 = Color(0xFF1A8A86);
  static const teal100 = Color(0xFFD5EBE8);
  static const sand = Color(0xFFF6F3EC);
  static const amber = Color(0xFFE0A458);
  static const coral = Color(0xFFD96B57);
  static const ink = Color(0xFF1C2B2B);
  static const muted = Color(0xFF5F7373);
  static const line = Color(0xFFE2DED4);
}

ThemeData buildSanadTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Tajawal',
    scaffoldBackgroundColor: SanadColors.sand,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SanadColors.teal700,
      primary: SanadColors.teal700,
      secondary: SanadColors.amber,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SanadColors.teal900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SanadColors.line),
      ),
    ),
  );
}
