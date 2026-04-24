import 'package:shared_preferences/shared_preferences.dart';

class PreferencesServices {
  static const String _keyLanguage = "language";
  static const String _keyTheme = "theme_mode";
  static const String _keyMainTutorial = "main_tutorial";
  static const String _keyGroupTutorial = "group_tutorial";
  static const String _keyNotification = "notifications_state";

  //LANGUAGE
  static setLanguage(String code)async {
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

  //MAIN TUTORIAL
  static setMainTutorial(bool made)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMainTutorial, made);
  }

  static Future<bool?> getMainTutorial()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMainTutorial);
  }
  //MAIN TUTORIAL
  static setGroupTutorial(bool made)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGroupTutorial, made);
  }

  static Future<bool?> getGroupTutorial()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGroupTutorial);
  }
  //NOTIFICATIONS
  static setNotifications(bool value)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotification, value);
  }

  static Future<bool?> getNotifications()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotification);
  }


}