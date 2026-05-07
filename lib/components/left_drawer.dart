import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/core/providers/user_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:pandilla/features/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';


/// Drawer lateral de navegación.
///
/// Proporciona acceso a las secciones principales de la aplicación:
/// inicio, perfil, ajustes y cierre de sesión.
/// También muestra la información básica del usuario en el encabezado.
class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}
/// Estado del widget [LeftDrawer].
///
/// Gestiona la navegación entre pantallas y la interacción del usuario
/// con las opciones del menú lateral.
class _LeftDrawerState extends State<LeftDrawer> {

  /// Construye el menú lateral de navegación (NavigationDrawer).
  ///
  /// Este widget permite al usuario acceder a las principales secciones de la app,
  /// así como visualizar su información personal en la cabecera.
  ///
  /// La estructura incluye:
  /// - Información del usuario obtenida desde `UserProvider`.
  /// - Opciones de navegación (Home, Perfil, Ajustes, Logout).
  /// - Gestión de sesión mediante FirebaseAuth.
  ///
  /// También se utiliza `AppLocalizations` para soportar traducción de textos.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;

    ///Datos del usuario desde el Provider para utilización en la cabecera del Drawer
    String? userUID = context.watch<UserProvider>().uid;
    String? userName = context.watch<UserProvider>().name;
    String? userAvatar = context.watch<UserProvider>().avatar;
    String? userEmail = context.watch<UserProvider>().email;

    return NavigationDrawer(
      selectedIndex: null,
      /// Maneja la selección de opciones del menú
      onDestinationSelected: (int index) async {
        final navigator = Navigator.of(context);
        navigator.pop();
        if (index == 0) {
          navigator.pushNamedAndRemoveUntil('/home', (route)=>false);
        } else if (index == 1) {
          navigator.push(MaterialPageRoute(builder: (context)=>ProfileScreen(userProfileUID: userUID!)));
        } else if (index == 2) {
          navigator.pushNamed('/settings');
        } else {
          await FirebaseAuth.instance.signOut();
          navigator.pushReplacementNamed('/login');
        }
      },
      children: [
        /// Encabezado del drawer con información del usuario
        DrawerHeader(
          decoration: const BoxDecoration(
            color: AppColors.secondary
          ),
            child: Column(
          children: [
            /// Avatar del usuario
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                "assets/images/$userAvatar",
              )
            ),
            /// Nombre del usuario
            Text(userName!, style: const TextStyle(fontWeight: FontWeight.bold),),
            /// Email del usuario
            Text(userEmail!)
          ],
        )),
        /// Navegación a inicio
        const NavigationDrawerDestination(
          icon: Icon(Icons.home),
          label: Text("Home"),
        ),
        /// Navegación a perfil
        NavigationDrawerDestination(
          icon: const Icon(Icons.person),
          label: Text(loc.profile),
        ),
        /// Navegación a ajustes
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings),
          label: Text(loc.settings),
        ),
        /// Cerrar sesión y navegación a pantalla de LogIn
        NavigationDrawerDestination(
          icon: const Icon(Icons.logout),
          label: Text(loc.logout),
        ),
      ],
    );
  }
}
