//Básicos
import 'package:flutter/material.dart';
//Componentes personlizados
import 'package:pandilla/components/color_picker.dart';
//Colores y estilos
import 'package:pandilla/core/app_colors.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
//Providers y servicios
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla encargada de la creación de una nueva nota dentro de un grupo.
///
/// Permite al usuario introducir:
/// - Título de la nota
/// - Descripción o contenido
/// - Color de la nota mediante un selector
///
/// Finalmente guarda la nota en la base de datos asociada al grupo actual.
class NoteCreatorScreen extends StatefulWidget {
  /// Identificador del grupo donde se guardará la nota.
  final String groupUID;
  /// Nombre del grupo (solo usado para mostrarlo en la AppBar).
  final String groupName;

  const NoteCreatorScreen({
    super.key,
    required this.groupUID,
    required this.groupName,
  });

  @override
  State<NoteCreatorScreen> createState() => _NoteCreatorScreenState();
}

/// Estado de la pantalla de creación de notas.
///
/// Gestiona:
/// - Datos introducidos por el usuario (título, descripción)
/// - Color seleccionado para la nota
class _NoteCreatorScreenState extends State<NoteCreatorScreen> {
  /// Título introducido por el usuario.
  String _title = "";

  /// Descripción o contenido de la nota.
  String _description = "";

  /// Color seleccionado para la nota.
  String _selectedColor = "pink";

  /// Decoración reutilizable para los contenedores de entrada.
  ///
  /// Aplica color base del módulo de notas y bordes redondeados.
  BoxDecoration boxDecoration = BoxDecoration(
      color: AppColors.notes_primary,
      borderRadius: BorderRadius.circular(12)
  );

  /// Construye la interfaz de la pantalla.
  ///
  /// Incluye:
  /// - Campo de título
  /// - Campo de descripción
  /// - Selector de color
  /// - Botones de guardar y cancelar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: AppColors.notes_primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        /// Layout vertical de los elementos
        child: Column(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// Título de la pantalla
            Text(
              AppLocalizations.of(context)!.new_note,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.notes_primary,
              ),
            ),
            /// Campo de título de la nota
            Container(
              padding: const EdgeInsetsGeometry.all(20),
              decoration: boxDecoration,
              child: TextField(
                maxLength: 15,
                decoration: InputDecoration(
                  filled: true,
                 fillColor: AppColors.notes_secondary,
                 enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.notes_primary),
                   borderRadius: BorderRadius.circular(10)
                  ),
                  labelText: AppLocalizations.of(context)!.title,
                ),
                onChanged: (value) => _title = value,
              ),
            ),

            /// Campo de descripción de la nota
            Container(
              padding: const EdgeInsetsGeometry.all(20),
              decoration: boxDecoration,
              child: TextField(
                maxLength: 300,
                minLines: 8,
                maxLines: 20,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.notes_secondary,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.notes_primary),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  labelText: AppLocalizations.of(context)!.body_note,
                ),
                onChanged: (value) => _description = value,
              ),
            ),
            /// Selector de color de la nota
            Container(
              padding: const EdgeInsetsGeometry.all(12),
              decoration: boxDecoration,
              child: Column(
                spacing: 10,
                children: [
                  Text(AppLocalizations.of(context)!.note_color, style: const TextStyle(color: Colors.white, fontSize: 15),),
                  /// Widget personalizado de selección de color
                  ColorPicker(
                    onColorSelected: (color) => _selectedColor = color,
                    selectedColor: _selectedColor,
                  ),
                ],
              ),
            ),
            /// Botones de acción (guardar / cancelar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// Botón para descartar la nota
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.discard,
                    style: TextStyle(
                      color: AppColors.notes_secondary,
                      fontSize: 20,
                    ),
                  ),
                ),
                /// Botón para guardar la nota
                ElevatedButton(
                  onPressed: () {
                    if (_title == "" || _description == "") { //comprueba que los campos no estén vacíos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.all_fields_required,
                          ),
                        ),
                      );
                    } else {//Crea la nota
                      createNote(
                        widget.groupUID,
                        _title,
                        _description,
                        _selectedColor,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(
                      color: AppColors.notes_secondary,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
