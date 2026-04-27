//Básicos
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/core/app_styles.dart';
//Estilos y colores
import '../core/app_colors.dart';
//Servicios y providers
import '../l10n/app_localizations.dart';
//Pantallas
import 'package:pandilla/screens/notes/note_view_screen.dart';

/// Widget que representa una nota dentro de la aplicación.
///
/// Muestra una tarjeta con:
/// - Título de la nota
/// - Contenido (resumido)
/// - Autor
/// - Color personalizado de la nota
/// - Fecha de última actualización
///
/// Permite navegar al detalle completo de la nota al pulsarla.
class NoteComponent extends StatefulWidget {
  /// Título de la nota.
  final String title;

  /// Contenido principal de la nota.
  final String body;

  /// Color asignado a la nota (clave del mapa de colores).
  final String color;

  /// Nombre del autor de la nota.
  final String author;

  /// Fecha de última actualización de la nota.
  final DateTime lastUpdate;

  /// Identificador único de la nota.
  final String noteID;

  /// UID del autor de la nota.
  final String authorID;

  const NoteComponent({
    super.key,
    required this.title,
    required this.body,
    required this.color,
    required this.author,
    required this.lastUpdate,
    required this.noteID,
    required this.authorID,
  });

  @override
  State<NoteComponent> createState() => _NoteComponentState();
}

/// Estado del widget [NoteComponent].
///
/// Gestiona la información mostrada de la nota
/// y la interacción del usuario con la misma.
class _NoteComponentState extends State<NoteComponent> {
  /// Mapa de colores disponibles para las notas.
  ///
  /// Asocia un identificador de color con su valor real en la app.
  final Map<String, Color> colors = {
    "pink": AppColors.pinkNote,
    "purple": AppColors.purpleNote,
    "blue": AppColors.blueNote,
    "green": AppColors.greenNote,
    "yellow": AppColors.yellowNote,
  };

  /// Construye la interfaz visual de la nota.
  ///
  /// Muestra:
  /// - Autor
  /// - Título
  /// - Contenido (con límite de líneas)
  /// - Fecha de actualización
  ///
  /// Permite navegar a la vista completa de la nota.
  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: colors[widget.color],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Autor de la nota
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "${AppLocalizations.of(context)!.created_by} ${widget.author}",
              style: AppStyles.blackFont,
            ),
          ),

          /// Contenido principal de la nota
          ListTile(
            ///Titulo
            title: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            ///Contenido de la nota
            subtitle: Text(
              widget.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),

            /// Navega a la vista completa de la nota
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteViewScreen(noteID: widget.noteID),
              ),
            ),
          ),

          ///Fecha de última actualización
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              DateFormat("HH:mm dd/MM/yyyy").format(widget.lastUpdate),
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
