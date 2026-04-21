import 'package:shared_preferences/shared_preferences.dart';

class PreferencesServices {
  static const String _keyLanguage = "language";
  static const String _keyTheme = "theme_mode";

  //LANGUAGE
  static setLanguege(String code)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  static Future<String?> getLanguage()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  //THEME
  static setThemeMode(String mode)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode);
  }

  static Future<String?> getThemeMode()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme);
  }


}