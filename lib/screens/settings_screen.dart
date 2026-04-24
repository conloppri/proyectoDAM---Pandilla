import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/providers/theme_provider.dart';
import 'package:pandilla/core/services/notification_services.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool automaticMode = true;
  bool darkMode = false;
  bool notif = true;

  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notif = prefs.getBool("notifications_state") ?? true;
    automaticMode = prefs.getString("theme_mode") == "system";
  }

  final TextStyle settingTitleStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();
    String selectedLang = localeProvider.locale==const Locale("en")?AppLocalizations.of(context)!.english:AppLocalizations.of(context)!.spanish;
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    darkMode = (themeProvider.themeMode == ThemeMode.dark);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings),
      backgroundColor: AppColors.primary,),
      body: SafeArea(
          child: Expanded(
            child: ListView(
              padding: const EdgeInsetsGeometry.all(20),
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.language, style: settingTitleStyle),
                  subtitle: Text(selectedLang),
                  onTap: (){
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.language),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height*0.8,
                          width: double.maxFinite,
                          child: ListView(
                            children: [
                              ListTile(
                              title: Text(AppLocalizations.of(context)!.spanish),
                              onTap: (){
                                localeProvider.setLocale(const Locale("es"));
                                selectedLang = AppLocalizations.of(context)!.spanish;
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                              ListTile(
                                title: Text(AppLocalizations.of(context)!.english),
                                onTap: (){
                                  localeProvider.setLocale(const Locale("en"));
                                  selectedLang = AppLocalizations.of(context)!.english;
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
                const Divider(),
                CheckboxListTile(value: automaticMode ,
                  title: Text("Modo automático", style: settingTitleStyle,),
                  onChanged: (bool? value) async {
                    context.read<ThemeProvider>().setTheme(ThemeMode.system);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("theme_mode", "system");
                  setState(() {
                    automaticMode = value!;
                  });
                },
                ),
                const Divider(),
                IgnorePointer(
                  ignoring: automaticMode,
                  child: SwitchListTile(value: darkMode,
                      title: Text("Modo oscuro", style: TextStyle(color: automaticMode?Colors.black12:Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                      onChanged: (value){
                    if(value){
                      context.read<ThemeProvider>().setTheme(ThemeMode.dark);
                    }else{
                      context.read<ThemeProvider>().setTheme(ThemeMode.light);
                    }
                    setState(() {
                      darkMode = value;
                    });
                  }),
                ),
                const Divider(),
              SwitchListTile(value: notif,
                  title: Text("Notificaciones", style: settingTitleStyle,),
                  onChanged: (value){
                NotificationServices.setNotificationState(value);
              })
              ],
            ),
          )),
    );
  }
}
