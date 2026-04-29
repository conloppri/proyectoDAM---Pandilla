//Básicos
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Componentes personalizados
import 'package:pandilla/components/color_picker.dart';
import '../../components/paper_background.dart';
//Pantallas
import 'package:pandilla/screens/notes/note_view_screen.dart';
//Providers y servicios
import 'package:provider/provider.dart';
import '../../core/providers/group_provider.dart';
import '../../l10n/app_localizations.dart';
//Firebase
import '../../core/services/firebase_service.dart';
//Estilos y colores
import '../../core/app_colors.dart';
import '../../core/app_styles.dart';

/// Pantalla de edición de una nota existente.
///
/// Permite:
/// - Cargar los datos de una nota desde Firestore
/// - Editar título y contenido
/// - Cambiar el color de la nota
/// - Guardar los cambios en la base de datos
class NoteEditorScreen extends StatefulWidget {
  /// ID de la nota a editar.
  final String noteID;

  /// UID del grupo al que pertenece la nota.
  final String groupUID;

  const NoteEditorScreen({
    super.key,
    required this.noteID,
    required this.groupUID,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

/// Estado de la pantalla de edición de notas.
///
/// Gestiona:
/// - Carga de datos desde Firestore
/// - Controladores de texto
/// - Color seleccionado de la nota
/// - Fecha de última actualización
class _NoteEditorScreenState extends State<NoteEditorScreen> {
  /// Mapa de colores disponibles para la nota.
  final Map<String, Color> colors = {
    "pink": AppColors.pinkNote,
    "purple": AppColors.purpleNote,
    "blue": AppColors.blueNote,
    "green": AppColors.greenNote,
    "yellow": AppColors.yellowNote,
  };

  /// Color actualmente seleccionado (clave del mapa `colors`).
  String _selectedColor = "";

  /// Información completa de la nota cargada desde la base de datos.
  Map noteInfo = {};

  /// Controladores del campos.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  /// Fecha de la última actualización formateada.
  String _lastUpdate = "";

  /// Estilo de texto utilizado en el contenido de la nota.
  final TextStyle textStyle = const TextStyle(fontSize: 18, height: 1.5);

  ///Variable que controla si la información ha llegado antes de mostrarla
  bool loading = true;

  /// Carga la información de la nota desde Firestore.
  ///
  /// - Obtiene los datos del documento
  /// - Inicializa controladores de texto
  /// - Formatea la fecha de creación
  /// - Actualiza el estado de la pantalla
  loadNote() async {
    try {
      noteInfo = await getNote(widget.groupUID, widget.noteID);
      DateTime date = noteInfo["createAt"].toDate();
      _lastUpdate = DateFormat("HH:mm dd/MM/yyyy", "es_ES").format(date);
      _titleController.text = noteInfo["title"];
      _bodyController.text = noteInfo["body"];
      _selectedColor = noteInfo["color"];
      loading = false;
      setState(() {});
    } catch (e) {
      debugPrint("Error cargando información: $e");
    }
  }

  /// Inicialización del estado.
  ///
  /// Se encarga de cargar los datos de la nota al abrir la pantalla.
  @override
  void initState() {
    super.initState();
    loadNote();
  }

  /// Construye la interfaz de edición de la nota.
  ///
  /// Incluye:
  /// - Campos editables de título y contenido
  /// - Selector de color
  /// - Información del autor
  /// - Botón de guardado en la AppBar
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    String? groupUID = context.watch<GroupProvider>().groupUID;
    String? groupName = context.watch<GroupProvider>().groupName;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName!, style: AppStyles.appBarTitle),
        backgroundColor: AppColors.notesPrimary,
        foregroundColor: Colors.white,
        actions: [
          /// Botón para guardar los cambios de la nota en Firestore
          TextButton(
            onPressed: () {
              if (_titleController.text == "" || _bodyController.text == "") {
                //comprueba que los campos no estén vacíos
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loc.all_fields_required,
                    ),
                  ),
                );
              } else {
                //Si está bien, actualiza la nota en la base de datos
                try {
                  updateNote(
                    groupUID!,
                    widget.noteID,
                    _titleController.text,
                    _bodyController.text,
                    _selectedColor,
                  );
                } catch (e) {
                  debugPrint("Error al actualizar nota: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        loc.error_try_again,
                      ),
                    ),
                  );
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteViewScreen(noteID: widget.noteID),
                  ),
                );
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          ///Contenedor de la nota
          child: loading?const Center(child: CircularProgressIndicator()) //Mientras carga la info
          :SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Card.filled(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.notesPrimary, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              color: colors[_selectedColor],
              child: Stack(
                children: [
                  /// Fondo estilo papel rayado
                  Positioned.fill(
                    child: PaperBackground(
                      lineColor: Colors.black,
                      lineSpacing: textStyle.fontSize! * textStyle.height!,
                    ),
                  ),

                  /// Contenido de la nota
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Autor de la nota
                        Row(
                          children: [
                            Text(
                              "${loc.created_by} ",
                              style: AppStyles.notesCreatedByStyle,
                            ),
                            Text(
                              noteInfo["authorName"],
                              style: AppStyles.notesAuthorStyle,
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Campo de título
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: false,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.notesSecondary,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.notesPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// Campo de contenido
                        TextField(
                          controller: _bodyController,
                          style: const TextStyle(color: Colors.black),
                          minLines: 5,
                          maxLines: 10,
                          decoration: InputDecoration(
                            filled: false,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.notesSecondary,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.notesPrimary,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Selector de color
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            loc.note_color,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        ColorPicker(
                          onColorSelected: (color) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          selectedColor: _selectedColor,
                        ),

                        const Spacer(),

                        /// Fecha de última actualización
                        Text(
                          "${loc.last_update} $_lastUpdate",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
