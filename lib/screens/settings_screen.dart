import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/providers/theme_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../core/providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  @override
  Widget build(BuildContext context) {
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();
    String selectedLang = localeProvider.locale==const Locale("en")?AppLocalizations.of(context)!.english:AppLocalizations.of(context)!.spanish;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings),
      backgroundColor: AppColors.primary,),
      body: SafeArea(
          child: Expanded(
            child: ListView(
              padding: const EdgeInsetsGeometry.all(20),
              children: [
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.language, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        Text(selectedLang)
                      ],
                    ),
                  ),
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
                Padding(
                  padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.dark_mode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Switch(value: darkMode,
                          onChanged: (value){
                            if(value){
                              context.read<ThemeProvider>().setTheme(ThemeMode.dark);
                            }else{
                              context.read<ThemeProvider>().setTheme(ThemeMode.light);
                            }
                            setState(() {
                              darkMode = value;
                            });
                      })
                    ],
                  ),
                ),
                const Divider(),
            
              ],
            ),
          )),
    );
  }
}
