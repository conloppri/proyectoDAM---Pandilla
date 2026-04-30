import 'dart:ui';

/// Clase que centraliza todos los colores de la aplicación.
///
/// Permite mantener una paleta consistente en toda la app,
/// separando colores por módulos (tema general, calendario,
/// notas, listas, información, etc.).
class AppColors{

  /// Color de fondo en modo oscuro.
  static const Color darkmodeBG = Color(0xff273957);

  /// Color secundario para modo claro.
  static const Color lightmodeSecondary = Color(0xff1b3761);

  /// Blanco con transparencia.
  static const Color whiteNoAlpha = Color(0xbdffffff);

  /// Color principal de la aplicación.
  static const Color primary = Color(0xFF1F6C9F);

  /// Color secundario de la aplicación.
  static const Color secondary = Color(0xFF82CDEC);

  /// Color principal del módulo de calendario.
  static const Color calendarPrimary = Color(0xff77aa2c);

  /// Color secundario del módulo de calendario.
  static const Color calendarSecondary = Color(0xffdeefbb);

  /// Color principal del módulo de notas.
  static const Color notesPrimary = Color(0xffd33197);

  /// Color secundario del módulo de notas.
  static const Color notesSecondary = Color(0xffffbdde);

  /// Color principal del módulo de listas.
  static const Color listsPrimary = Color(0xffe4b204);

  /// Color secundario del módulo de listas.
  static const Color listsSecondary = Color(0xffefdb7e);

  /// Color principal del módulo de información/grupos.
  static const Color infoPrimary = Color(0xff02aaaf);

  /// Color secundario del módulo de información/grupos.
  static const Color infoSecondary = Color(0xff89eadd);

  ///Color rosa muy claro, para TextFields en ProfileScreens
  static const Color profileLowerPink = Color(0xffe8c4db);

  ///Color azul muy claro, para TextFields en ProfileScreens
  static const Color profileLowerSecondary = Color(0xffb0dbf8);

  /// Colores disponibles para notas (tema visual).
  static const Color pinkNote = Color(0xffdfa3c9);

  static const Color purpleNote = Color(0xffb980ff);

  static const Color blueNote = Color(0xff98d1ff);

  static const Color greenNote = Color(0xffc9ffa9);

  static const Color yellowNote = Color(0xfffae580);
}