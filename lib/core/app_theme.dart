import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
/// Clase que define los temas principales de la aplicación.
///
/// Contiene la configuración global de estilos visuales para el modo claro
/// y modo oscuro, incluyendo colores, botones, campos de texto y esquema
/// de colores.
///
/// Esta clase permite mantener una apariencia consistente en toda la app
/// y facilita el cambio dinámico de tema.
class AppTheme {

  /// Tema claro de la aplicación.
  ///
  /// Define colores claros para fondos, botones y campos de texto,
  /// optimizado para entornos con buena iluminación.
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.black,

    scaffoldBackgroundColor: Colors.white.withAlpha(245),

    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: AppColors.lightmodeSecondary,
    ),

    /// Configuración global de botones elevados en tema claro.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsetsGeometry.all(12),
        elevation: 5
      ),
    ),

    /// Configuración global de campos de texto en tema claro.
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.black87),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
  );

  /// Tema oscuro de la aplicación.
  ///
  /// Diseñado para entornos con poca luz, utilizando colores oscuros
  /// para reducir la fatiga visual del usuario.
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.black,

    scaffoldBackgroundColor: AppColors.darkmodeBG.withAlpha(245),

    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: AppColors.lightmodeSecondary,
    ),

    /// Configuración global de botones elevados en tema oscuro.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsetsGeometry.all(12),
        elevation: 5
      ),
    ),

    /// Configuración global de campos de texto en tema oscuro.
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightmodeSecondary,
      labelStyle: TextStyle(color: Colors.white),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
  );
}
