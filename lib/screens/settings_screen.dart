import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/core/providers/theme_provider.dart';
import 'package:pandilla/core/services/notification_services.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/providers/locale_provider.dart';

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
  /// Indica si el tema está en modo automático (según sistema).
  bool automaticMode = true;

  /// Indica si el modo oscuro está activo.
  bool darkMode = false;

  /// Indica si las notificaciones están activadas.
  bool notif = true;

  /// Carga las preferencias guardadas en almacenamiento local.
  ///
  /// Inicializa los valores de:
  /// - estado de notificaciones
  /// - modo de tema
  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    notif = prefs.getBool("notifications_state") ?? true;
    automaticMode = prefs.getString("theme_mode") == "system";

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

    /// Texto del idioma seleccionado actualmente.
    String selectedLang = localeProvider.locale == const Locale("en")
        ? loc.english
        : loc.spanish;

    final ThemeProvider themeProvider = context.watch<ThemeProvider>();

    /// Determina si el modo oscuro está activo según el provider.
    darkMode = (themeProvider.themeMode == ThemeMode.dark);
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
              onChanged: (bool? value) async {
                context.read<ThemeProvider>().setTheme(ThemeMode.system);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("theme_mode", "system");
                setState(() {
                  //Variable que permite activar el Switch de modo oscuro
                  automaticMode = value!;
                });
              },
            ),
            const Divider(),

            /// Selector de modo oscuro (deshabilitado si automático está activo)
            IgnorePointer(
              ignoring:
                  automaticMode, //Si está activado el modo automático, este Widget ignorará las interacciones
              child: SwitchListTile(
                value: darkMode,
                title: Text(
                  loc.dark_mode,
                  style: automaticMode
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
                    context.read<ThemeProvider>().setTheme(ThemeMode.dark);
                  } else {
                    //Si el switch está apagado => Modo claro
                    context.read<ThemeProvider>().setTheme(ThemeMode.light);
                  }
                  setState(() {
                    darkMode = value;
                  });
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
          ],
        ),
      ),
    );
  }
}
