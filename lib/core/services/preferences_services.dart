import 'package:shared_preferences/shared_preferences.dart';

/// Clase que centraliza el acceso a SharedPreferences
class PreferencesServices {

  ///Clave para el idioma
  static const String _keyLanguage = "language";

  ///Clave para tema
  static const String _keyTheme = "theme_mode";

  ///Clave para tutorial del MainScreen
  static const String _keyMainTutorial = "main_tutorial";

  ///Clave para tutorial de la pantalla de grupo
  static const String _keyGroupTutorial = "group_tutorial";

  ///Clave para sistema de notificaciones
  static const String _keyNotification = "notifications_state";

  //--------LANGUAGE----------------

  ///Guarda el idioma seleccionado
  ///
  /// - [code] Código de localización
  static setLanguage(String code)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  ///Obtiene el idioma guardado
  static Future<String?> getLanguage()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  //---------------THEME----------------

  ///Guarda el tema seleccionado
  ///
  /// -[mode] Tema seleccionado (Automático/Oscuro/Claro)
  static setThemeMode(String mode)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode);
  }

  ///Obtiene el tema guardado
  static Future<String?> getThemeMode()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme);
  }

  //---------MAIN TUTORIAL------------

  ///Guarda si el tutorial inicial ya ha sido realizado
  ///
  /// - [made] Si ha sido completado (true/false)
  static setMainTutorial(bool made)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMainTutorial, made);
  }

  /// Obtiene si el tutorial inicial ha sido completado como un booleano
  static Future<bool?> getMainTutorial()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMainTutorial);
  }
  //--------------GROUP TUTORIAL---------------------
  ///Guarda si el tutorial de grupo ya ha sido realizado
  ///
  /// - [made] Si ha sido completado (true/false)
  static setGroupTutorial(bool made)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGroupTutorial, made);
  }

  /// Obtiene si el tutorial de grupo ha sido completado como un booleano
  static Future<bool?> getGroupTutorial()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGroupTutorial);
  }

  //--------------NOTIFICATIONS--------------

  /// Guarda si las notificaciones están activas o no
  ///
  /// - [value] Si están activadas o desactivadas (true/false)
  static setNotifications(bool value)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotification, value);
  }

  ///Obtiene si las noticaciones estan activas
  static Future<bool?> getNotifications()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotification);
  }
}