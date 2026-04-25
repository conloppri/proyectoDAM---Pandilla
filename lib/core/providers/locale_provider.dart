import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider encargado de gestionar el idioma (locale) de la aplicación.
///
/// Permite:
/// - Cambiar el idioma de la app
/// - Guardar la preferencia en almacenamiento local
/// - Cargar el idioma guardado al iniciar la app
class LocaleProvider extends  ChangeNotifier{

  /// Idioma actual seleccionado en la aplicación.
  Locale? _locale;

  /// Getter del idioma actual.
  Locale? get locale => _locale;

  /// Cambia el idioma de la aplicación.
  ///
  /// - Actualiza el estado interno
  /// - Guarda la preferencia en `SharedPreferences`
  /// - Notifica a los listeners para reconstruir la UI
  ///
  /// - [locale] Idioma seleccionado desde la aplicación
  setLocale(Locale locale) async{
    _locale = locale;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", locale.languageCode);

    notifyListeners();
  }

  /// Carga el idioma guardado previamente.
  ///
  /// Si no existe un idioma guardado:
  /// - Usa el idioma del sistema del dispositivo
  loadLocale()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString("language");

    if(code!=null){
      _locale = Locale(code);
    }else{
      _locale = WidgetsBinding.instance.platformDispatcher.locale;
    }
    notifyListeners();
  }
}