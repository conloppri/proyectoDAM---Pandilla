//Básicos
import 'package:flutter/material.dart';
import 'package:pandilla/core/app_theme.dart';
import 'package:pandilla/core/services/navigator_key.dart';
//Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//Servicios y providers
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/core/providers/locale_provider.dart';
import 'package:pandilla/core/providers/user_provider.dart';
import 'package:pandilla/core/services/notification_services.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
//Pantallas
import 'package:pandilla/screens/log_screen.dart';
import 'package:pandilla/screens/main_screen.dart';
import 'package:pandilla/screens/profile/profile_editor_screen.dart';
import 'package:pandilla/screens/settings_screen.dart';
import 'package:pandilla/screens/splash_screen.dart';


/// Punto de entrada principal de la aplicación.
///
/// Realiza las inicializaciones necesarias antes de ejecutar la app:
/// - Inicializa Flutter bindings.
/// - Inicializa Firebase.
/// - Configura el sistema de notificaciones.
/// - Registra los providers utilizados en la aplicación.
Future<void> main() async {

  ///inicialización de Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ///Inicialización de servicios de notificación
  NotificationServices.setupTimezone();
  await NotificationServices.init();

  ///Inicializamos ThemeProvider
  final ThemeProvider themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    //Configuración de providers utilizados
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child:  const MyApp(),
    ),
  );
}

/// Widget principal de la aplicación.
///
/// Configura el `MaterialApp`, incluyendo:
/// - Tema claro y oscuro.
/// - Localización (idioma).
/// - Rutas de navegación.
/// - Pantalla inicial.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Construye el árbol principal de la aplicación.
  ///
  /// Obtiene el idioma y el tema desde los providers y los aplica
  /// a la configuración global del `MaterialApp`.
  @override
  Widget build(BuildContext context) {
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,

      //Configuración de temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      //Configuración de localización
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      //Pantalla principal => SplashScreen() = pantalla intermedia para verificar si hay usuario verificado
      home: const SplashScreen(),

      //Rutas para navegación rápida
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LogScreen(),
        '/home': (context) => const MainScreen(),
        '/profileEditor': (context) => const ProfileEditorScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
