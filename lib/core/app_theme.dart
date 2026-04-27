import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.black,

    scaffoldBackgroundColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: AppColors.lightmodeSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsetsGeometry.all(12),
      ),
    ),
    textTheme: const TextTheme(),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.whiteNoAlpha,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
  );
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.black,

    scaffoldBackgroundColor: AppColors.darkmodeBG,

    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: AppColors.lightmodeSecondary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsetsGeometry.all(12),
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightmodeSecondary,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
  );
}
