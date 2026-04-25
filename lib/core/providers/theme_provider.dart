import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider encargado de gestionar el tema de la aplicación.
///
/// Permite:
/// - Cambiar entre modo claro, oscuro o sistema
/// - Guardar la preferencia del usuario en almacenamiento local
/// - Cargar el tema al iniciar la aplicación
class ThemeProvider extends ChangeNotifier{
  /// Clave utilizada para guardar el tema en SharedPreferences.
  static const _key = "theme_mode";

  /// Modo de tema actual de la aplicación.
  ThemeMode _themeMode = ThemeMode.system;

  /// Getter del tema actual.
  ThemeMode get themeMode => _themeMode;

  /// Inicializa el tema cargando la preferencia guardada.
  ///
  /// Si no existe configuración previa, usa el modo del sistema.
  init() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(_key);

    switch(value){
      case 'light': //Claro
        _themeMode = ThemeMode.light;
        break;
      case 'dark': //Oscuro
        _themeMode = ThemeMode.dark;
        break;
      default: //Sistema
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  /// Cambia el tema de la aplicación.
  ///
  /// - Actualiza el estado interno
  /// - Guarda la preferencia en almacenamiento local
  /// - Notifica a los listeners para reconstruir la UI
  ///
  /// - [mode] Modo de tema seleccionado desde la aplicación.
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';

    await prefs.setString(_key, value);

    notifyListeners();
  }

}