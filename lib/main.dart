import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/group_provider.dart';
import 'package:pandilla/core/user_provider.dart';
import 'package:pandilla/screens/log_screen.dart';
import 'package:pandilla/screens/main_screen.dart';

import 'package:pandilla/screens/profile/profile_editor_screen.dart';
import 'package:pandilla/screens/settings_screen.dart';
import 'package:pandilla/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightmode_BG,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkmode_BG,
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es', 'ES'), Locale('en_EN')],
      locale: Locale('es', 'ES'),
      home: SplashScreen(),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LogScreen(),
        '/home': (context) => MainScreen(),
        '/profileEditor': (context) => ProfileEditorScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
