import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends  ChangeNotifier{
  Locale? _locale;

  Locale? get locale => _locale;

  setLocale(Locale locale) async{
    _locale = locale;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", locale.languageCode);

    notifyListeners();
  }

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