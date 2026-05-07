import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/core/providers/theme_provider.dart';
import 'package:pandilla/core/services/notification_services.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/locale_provider.dart';

/// Pantalla de ajustes de la aplicación.
///
/// Permite al usuario configurar:
/// - Idioma
/// - Tema (automático / claro / oscuro)
/// - Estado de las notificaciones
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// Estado de la pantalla de ajustes [SettingsScreen]
///
/// Gestiona los valores actuales de configuración y los sincroniza
/// con almacenamiento local (`SharedPreferences`) y providers.
class _SettingsScreenState extends State<SettingsScreen> {

  /// Indica si las notificaciones están activadas.
  bool notif = true;

  String themeMode = "";

  /// Carga las preferencias guardadas en almacenamiento local.
  ///
  /// Inicializa los valores de:
  /// - estado de notificaciones
  /// - modo de tema
  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notif = prefs.getBool("notifications_state") ?? true;

    setState(() {});
  }

  /// Metodo llamado al inicializar el estado.
  ///
  /// Se encarga de cargar las preferencias guardadas.
  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  /// Construye la interfaz de la pantalla de ajustes.
  ///
  /// Utiliza providers para gestionar idioma y tema dinámicamente.
  @override
  Widget build(BuildContext context) {
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();
    final AppLocalizations loc = AppLocalizations.of(context)!;



    /// Texto del idioma seleccionado actualmente o del sistema, en caso de nulo.
    String selectedLang = (localeProvider.locale?.languageCode ?? Localizations.localeOf(context).languageCode) == "en"
        ? loc.english
        : loc.spanish;

    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    /// Indica si el tema está en modo automático (según sistema).
    bool automaticMode = themeProvider.themeMode == ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsGeometry.all(20),
          children: [
            ///Selector de idiomas
            ListTile(
              title: Text(
                loc.language,
                style: AppStyles.settingTitleStyle,
              ),
              subtitle: Text(selectedLang),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      //Solicitamos el idioma por lista en AlertDialog
                      title: Text(loc.language),
                      content: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: double.maxFinite,
                        child: ListView(
                          children: [
                            /// Opción: Español
                            ListTile(
                              title: Text(
                                loc.spanish,
                              ),
                              onTap: () {
                                localeProvider.setLocale(const Locale("es"));
                                selectedLang = AppLocalizations.of(
                                  context,
                                )!.spanish;
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),

                            /// Opción: Inglés
                            ListTile(
                              title: Text(
                                loc.english,
                              ),
                              onTap: () {
                                localeProvider.setLocale(const Locale("en"));
                                selectedLang = AppLocalizations.of(
                                  context,
                                )!.english;
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(),

            /// Opción de modo automático (tema según sistema)
            CheckboxListTile(
              value: automaticMode,
              title: Text(
                loc.automatic_mode,
                style: AppStyles.settingTitleStyle,
              ),
              onChanged: (bool? value) {
                setState(() {
                  if(value!){
                    themeProvider.setTheme(ThemeMode.system);
                  }else{
                    themeProvider.setTheme(Theme.of(context).brightness == Brightness.dark
                        ?ThemeMode.dark
                        :ThemeMode.light);
                  }
                });
              },
            ),
            const Divider(),

            /// Selector de modo oscuro (deshabilitado si automático está activo)
            IgnorePointer(
              ignoring: automaticMode, //Si está activado el modo automático, este Widget ignorará las interacciones
              child: SwitchListTile(
                value: Theme.of(context).brightness == Brightness.dark,
                title: Text(
                  loc.dark_mode,
                  style:automaticMode
                      ? const TextStyle( //Si esta desactivado, se verá gris
                          color: Colors.black12,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )
                      : AppStyles.settingTitleStyle, //Si está activado, se verá como los demás
                ),
                onChanged: (value) {
                  if (value) {
                    //Si el switch está encedido => Modo oscuro
                    themeProvider.setTheme(ThemeMode.dark);
                  } else {
                    //Si el switch está apagado => Modo claro
                    themeProvider.setTheme(ThemeMode.light);
                  }
                  setState(() {});
                },
              ),
            ),
            const Divider(),

            /// Activación/desactivación de notificaciones
            SwitchListTile(
              value: notif,
              title: Text(
                loc.notifications,
                style: AppStyles.settingTitleStyle,
              ),
              onChanged: (value) {
                NotificationServices.setNotificationState(value);
              },
            ),
            const Divider(),
            ///Información acerca de la aplicación
            ListTile(
              title: Text(loc.about, style: AppStyles.settingTitleStyle),
              onTap: (){
                showDialog(
                  context: context,
                  builder: (context) {
                    ///Diálogo que muestra la informaicón de la aplicación
                    return AlertDialog(
                      title: Text(loc.about),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ///Logo de la app
                              CircleAvatar(
                                backgroundImage: AssetImage("assets/icon_foreground.png"),
                                backgroundColor: AppColors.secondary,
                                radius: 30,
                              ),
                              ///Nombre de la app
                              Text("Pandilla", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),)
                            ],
                          ),

                          const SizedBox(height: 10),

                          ///Descripción
                          Text("${loc.description}:", style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                          Text(loc.app_info),

                          const SizedBox(height: 10,),

                          ///Versión
                          Row(
                            children: [
                              Text("${loc.version}:  ", style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                              const Text("1.0.0",style: TextStyle(fontSize: 20)),
                            ],
                          )
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(loc.close),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider()
          ],
        ),
      ),
    );
  }
}
