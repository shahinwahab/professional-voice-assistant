import 'package:flutter/material.dart';
import 'package:pro_voice_assistant/theme/pallete.dart';

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Pallete.backgroundcolor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Pallete.backgroundcolor,
        elevation: 0,
        iconTheme: IconThemeData(color: Pallete.mainFontColor),
        titleTextStyle: TextStyle(
          color: Pallete.mainFontColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Pallete.mainFontColor,
            fontSize: 32,
            fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: Pallete.mainFontColor,
            fontSize: 28,
            fontWeight: FontWeight.bold),
        displaySmall: TextStyle(
            color: Pallete.mainFontColor,
            fontSize: 24,
            fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(
            color: Pallete.mainFontColor,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Pallete.mainFontColor, fontSize: 16),
        bodyMedium: TextStyle(color: Pallete.mainFontColor, fontSize: 14),
      ),
      iconTheme: const IconThemeData(color: Pallete.mainFontColor),
      cardTheme: CardTheme(
        color: Pallete.featureBoxColor.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Pallete.borderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.featureBoxColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Pallete.backgroundcolor.withOpacity(0.5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Pallete.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Pallete.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Pallete.featureBoxColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Pallete.mainFontColor),
      ),
      colorScheme: ColorScheme.dark(
        background: Pallete.backgroundcolor,
        primary: Pallete.featureBoxColor,
        secondary: Pallete.assistantCircleColor,
        surface: Pallete.backgroundcolor,
        onPrimary: Colors.white,
        onBackground: Pallete.mainFontColor,
        onSurface: Pallete.mainFontColor,
      ),
    );
  }
}
