import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.black,

    scaffoldBackgroundColor: Colors.white,

    colorScheme: ColorScheme.light(
      primary: Colors.black,
      secondary: AppColors.lightmode_secondary
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsetsGeometry.all(12)
      ),
    ),
    textTheme: TextTheme(

    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white_noalpha,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black)
      ),
    )
  );
  static final darkTheme = ThemeData(
    useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.black,

      scaffoldBackgroundColor: AppColors.darkmode_BG,

      colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: AppColors.lightmode_secondary
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightmode_secondary,
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)
        ),
      )
  );
}