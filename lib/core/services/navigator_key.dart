import 'package:flutter/material.dart';

/// Clave global del Navigator de la aplicación.
///
/// Permite acceder al sistema de navegación desde fuera del árbol de widgets,
/// por ejemplo para navegar sin necesidad de un BuildContext (notificaciones,
/// redirecciones globales, listeners, etc.).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();