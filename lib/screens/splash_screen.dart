import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';

/// Pantalla inicial de la aplicación (Splash Screen).
///
/// Se muestra al arrancar la app y se encarga de comprobar
/// el estado de la sesión del usuario para redirigir a la
/// pantalla correspondiente.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Estado de la SplashScreen.
///
/// Ejecuta la comprobación de sesión una vez renderizado el primer frame.
class _SplashScreenState extends State<SplashScreen> {

  /// Metodo que se ejecuta al inicializar el estado.
  ///
  /// Se utiliza `addPostFrameCallback` para lanzar la comprobación
  /// de sesión después de que el primer frame haya sido renderizado.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback)=>currentSession());
  }

  /// Construye la interfaz de la pantalla de carga.
  ///
  /// Muestra el logo de la aplicación centrado en pantalla.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Image(image: AssetImage("assets/icon.png")),
      ),
    );
  }

  /// Comprueba si existe una sesión activa de usuario.
  ///
  /// Si el usuario está autenticado, redirige a la pantalla principal.
  /// En caso contrario, redirige a la pantalla de inicio de sesión.
  ///
  /// Utiliza `Navigator.pushReplacementNamed` para reemplazar la
  /// pantalla actual y evitar que el usuario pueda volver atrás.
  void currentSession() {
    User? user = FirebaseAuth.instance.currentUser;
    if(user!=null){
      Navigator.pushReplacementNamed(context, '/home');
    }else{
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
