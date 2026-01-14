import 'package:flutter/material.dart';

const kPrimary = Color(0xFF10B981);
const inputBorderColor = Color(0xFFE6EDE9);
const scaffoldBackgroundColor = Color(0xFFF7FDFB);
const kSecondary = Color(0xFF47A4EF);
final kPrimaryBackground = kPrimary.withValues(alpha: 0.15);
final gradientColor = <Color>[ Color(0xFF34D399),Color(0xFF10B981),];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    primaryColor: kPrimary,
    fontFamily: 'Pretendard',
    fontFamilyFallback: const ["Pretendard", "Apple SD Gothic Neo", "Noto Sans KR", "Roboto"],
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
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: inputBorderColor, width: 1.6),
      ),
    ),

    scaffoldBackgroundColor: scaffoldBackgroundColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
    ),

    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: const Color(0xFFFEFFFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: inputBorderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 1.3),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: const BorderSide(color: inputBorderColor, width: 1.0),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
        color: Colors.black,
      ),
      scrolledUnderElevation: 0.7,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: scaffoldBackgroundColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scaffoldBackgroundColor,
    ),
  );
}

InputDecoration inputDecorationWithHint(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF829180)),
  );
}


InputDecoration inputDecorationWithHintIcon(String hint, Icon icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF829180)),
    suffixIcon: icon,
    suffixIconColor: Color(0xFF829180),
  );
}