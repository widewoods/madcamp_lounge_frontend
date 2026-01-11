import 'package:flutter/material.dart';

const kPrimary = Color(0xFF4C46E5);
const inputBorderColor = Color(0xFFD6D9E6);
const scaffoldBackgroundColor = Color(0xFFF3F3F3);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    primaryColor: kPrimary,
    fontFamilyFallback: const ["Apple SD Gothic Neo", "Noto Sans KR", "Roboto"],
  );

  final commonShape = RoundedRectangleBorder(
    borderRadius: BorderRadiusGeometry.circular(14),
  );

  return base.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: commonShape,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      )
    ),

    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: commonShape,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        )
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),

    scaffoldBackgroundColor: scaffoldBackgroundColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
    ),

    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: inputBorderColor, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 1.6),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
        color: Colors.black,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: scaffoldBackgroundColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
    )
  );
}

InputDecoration inputDecorationWithHint(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9AA0AE)),
  );
}