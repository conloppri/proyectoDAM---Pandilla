//Básicos
import 'package:flutter/material.dart';
//Componentes personlizados
import 'package:pandilla/components/color_picker.dart';
//Colores y estilos
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
//Providers y servicios
import '../../../l10n/app_localizations.dart';

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
      color: AppColors.notesPrimary,
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
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Stack(
      children: [
        //Background de la pantalla
        Positioned.fill(child: Image.asset("assets/images/app_background.png", fit: BoxFit.cover)),
        Scaffold(
          appBar: AppBar(
            title: Text(widget.groupName),
            backgroundColor: AppColors.notesPrimary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              /// Columna de los elementos de la nota
              child: Column(
                spacing: 15,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /// Título de la pantalla
                  Text(
                    loc.new_note,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.notesPrimary,
                    ),
                  ),
                  /// Campo de título de la nota
                  Container(
                    padding: const EdgeInsetsGeometry.all(20),
                    decoration: boxDecoration,
                    child: TextField(
                      maxLength: 15,
                      maxLines: 1,
                      decoration: InputDecoration(
                        filled: true,
                       fillColor: AppColors.notesSecondary,
                       enabledBorder: AppStyles.noteEditorOutlineInput,
                        labelText: loc.title,
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
                        fillColor: AppColors.notesSecondary,
                        enabledBorder: AppStyles.noteEditorOutlineInput,
                        labelText: loc.body_note,
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
                        Text(loc.note_color, style: const TextStyle(color: Colors.white, fontSize: 15)),
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
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(MediaQuery.of(context).size.width *0.4, MediaQuery.of(context).size.height *0.05)
                        ),
                        child: Text(
                          loc.discard,
                          style: AppStyles.buttonTextStyle
                        ),
                      ),
                      /// Botón para guardar la nota
                      ElevatedButton(
                        onPressed: () {
                          if (_title == "" || _description == "") { //comprueba que los campos no estén vacíos
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc.all_fields_required,
                                ),
                              ),
                            );
                          } else {//Crea la nota
                            try {
                              createNote(
                                widget.groupUID,
                                _title,
                                _description,
                                _selectedColor,
                              );
                            } catch (e) {
                              debugPrint("Error al crear la nota: $e");
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.error_try_again)));
                            }
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(MediaQuery.of(context).size.width *0.4, MediaQuery.of(context).size.height *0.05)
                        ),
                        child: Text(
                          loc.save,
                          style: AppStyles.buttonTextStyle
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
