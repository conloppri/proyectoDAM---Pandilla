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
      secondary: AppColors.lightmodeSecondary
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
      fillColor: AppColors.whiteNoAlpha,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black)
      ),
    )
  );
  static final darkTheme = ThemeData(
    useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.black,

      scaffoldBackgroundColor: AppColors.darkmodeBG,

      colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: AppColors.lightmodeSecondary
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightmodeSecondary,
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)
        ),
      )
  );
}