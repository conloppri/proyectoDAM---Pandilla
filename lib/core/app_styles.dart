import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Clase centralizada que contiene todos los estilos de texto y decoraciones
/// utilizados en la aplicación.
///
/// Esta clase se utiliza para mantener una estructura consistente de diseño
/// (tipografías, colores, bordes y estilos de formularios) evitando la
/// repetición de estilos en los distintos widgets de la app.
class AppStyles {
  //----------GENERAL STYLES-------------
  /// Estilo de texto en negro con negrita.
  static const TextStyle blackBoldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  /// Estilo de texto en negro sin formato adicional.
  static const TextStyle blackFont = TextStyle(color: Colors.black);

  /// Estilo para títulos en AppBar.
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  /// Estilo genérico para títulos principales
  static const TextStyle title = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  /// Estilo de texto para botones.
  static const TextStyle buttonTextStyle = TextStyle(fontSize: 20);

  /// Estilo de texto subrayado usado en acciones de login o enlaces.
  static const TextStyle underlinedLogIn = TextStyle(
    decoration: TextDecoration.underline,
    color: Colors.blueAccent,
  );

  /// Bordes redondeados reutilizables para campos de texto.
  static final OutlineInputBorder outlineInputBorderRounded =
      OutlineInputBorder(borderRadius: BorderRadius.circular(12));

  ///Sombras para containers
  static const BoxShadow boxShadow = BoxShadow(
    color: Colors.black26,
    spreadRadius: 1,
    blurRadius: 5,
    offset: Offset(2,2),
  );

  //--------------SETTINGS STYLES-----------------------
  /// Estilo de título utilizado en la pantalla de ajustes.
  static const TextStyle settingTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  //--------------LOGIN STYLES---------------
  /// Estilo de decoración para campos de texto en login.
  /// Incluye fondo coloreado y estilo de etiqueta.
  static const InputDecoration loginTextFields = InputDecoration(
    filled: true,
    fillColor: AppColors.secondary,
    labelStyle: TextStyle(color: Colors.black87),
  );

  //----------------TUTORIAL STYLES-----------------------
  /// Decoración de contenedor principal en pantallas de tutorial.
  static final BoxDecoration mainScreenBox = BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.primary),
    boxShadow: const [
      boxShadow
    ],
  );

  /// Estilo de texto usado en tutorial.
  static const TextStyle tutorialTextStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 20,
  );

  /// Decoración de cajas utilizadas en tutorial.
  static final BoxDecoration tutorialBox = BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(20),
  );

  //-------------PROFILE STYLES----------------------
  /// Estilo para títulos en la pantalla de perfil.
  static const TextStyle profileTitles = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  /// Estilo de texto secundario en perfil.
  static const TextStyle profileSub = TextStyle(
    color: Colors.white,
    fontSize: 15,
  );

  /// Estilo de campos de texto en perfil.
  static const InputDecoration profileTextFieldStyle = InputDecoration(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  );

  //---------------NOTES---------------------------
  /// Estilo de barra de herramientas en notas.
  static const TextStyle notesToolBar = TextStyle(
    color: AppColors.notesPrimary,
    fontSize: 20,
  );

  /// Estilo del texto "creado por" en notas.
  static const TextStyle notesCreatedByStyle = TextStyle(
    color: Colors.black,
    fontSize: 12,
  );

  /// Estilo del nombre del autor en notas.
  static const TextStyle notesAuthorStyle = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  /// Decoración del editor de notas con borde personalizado.
  static final OutlineInputBorder noteEditorOutlineInput = OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.notesPrimary),
    borderRadius: BorderRadius.circular(12),
  );

  //--------------------INFO STYLES----------------------
  /// Estilo de texto utilizado en pantallas de información.
  static const TextStyle infoTextFields = TextStyle(
    color: AppColors.infoPrimary,
  );

  //--------------CALENDAR STYLES-------------------------
  /// Estilo de texto en campos del calendario.
  static const TextStyle eventTextFields = TextStyle(
    color: AppColors.calendarPrimary,
  );

  /// Estilo de botones del calendario.
  static const TextStyle eventButtonsStyle = TextStyle(
    color: AppColors.calendarPrimary,
    fontSize: 20,
  );

  /// Estilo de títulos en la pantalla del calendario.
  static const TextStyle calendarTitle = TextStyle(
    color: AppColors.calendarPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
