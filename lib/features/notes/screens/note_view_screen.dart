//Básicos
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Componentes personalizados
import 'package:pandilla/components/paper_background.dart';
//Estilos y colores
import 'package:pandilla/core/app_styles.dart';
import '../../../core/app_colors.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Servicios y providers
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
//Pantallas
import 'package:pandilla/features/notes/screens/note_editor_screen.dart';

/// Pantalla de visualización de una nota.
///
/// Permite:
/// - Ver el contenido completo de una nota
/// - Ver su autor, título, cuerpo y fecha de última actualización
/// - Editar o eliminar la nota si el usuario es administrador o autor
class NoteViewScreen extends StatefulWidget {
  /// ID de la nota a mostrar.
  final String noteID;

  const NoteViewScreen({super.key, required this.noteID});

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

/// Estado de la pantalla de visualización de notas.
///
/// Gestiona:
/// - Carga de la nota desde Firestore
/// - Permisos de edición/eliminación
/// - Renderizado de la tarjeta con estilo tipo papel
class _NoteViewScreenState extends State<NoteViewScreen> {
  /// Mapa de colores disponibles para las notas.
  final Map<String, Color> colors = {
    "pink": AppColors.pinkNote,
    "purple": AppColors.purpleNote,
    "blue": AppColors.blueNote,
    "green": AppColors.greenNote,
    "yellow": AppColors.yellowNote,
  };

  /// Estilo de texto utilizado en el contenido de la nota.
  final TextStyle textStyle = const TextStyle(fontSize: 18, height: 1.5);

  /// Construye la interfaz de visualización de la nota.
  ///
  /// - Obtiene datos del grupo desde `GroupProvider`
  /// - Obtiene la nota desde Firestore mediante `FutureBuilder`
  /// - Muestra información del autor, título, cuerpo y fecha
  /// - Permite editar o eliminar si el usuario tiene permisos
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    ///Datos de los providers
    String? groupUID = context.watch<GroupProvider>().groupUID;
    String? groupName = context.watch<GroupProvider>().groupName;
    bool? isAdmin = context.watch<GroupProvider>().isAdmin;
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    return Stack(
      children: [
        Positioned.fill(child: Image.asset("assets/images/app_background.png", fit: BoxFit.cover)),
        Scaffold(
          appBar: AppBar(
            title: Text(groupName!, style: AppStyles.appBarTitle),
            backgroundColor: AppColors.notesPrimary,
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            /// Carga de la nota desde Firestore
            child: FutureBuilder(
              future: getNote(groupUID!, widget.noteID),
              builder: (context, snapshot) {
                //Control de la información que nos llega de firestore
                if (snapshot.connectionState == ConnectionState.waiting) {//no hay conexión
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {//Error
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {//sin datos
                  return Text(loc.no_notes);
                }
                //Cargamos los datos
                Map<String, dynamic> noteInfo = snapshot.data!;
                DateTime lastUpdate = noteInfo["lastUpdate"].toDate();
                String authorID = noteInfo["authorUID"];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card.filled(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppColors.notesPrimary, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: colors[noteInfo["color"]],
                      child: Stack(
                        children: [
                          /// Fondo tipo papel rayado
                          Positioned.fill(
                            child: PaperBackground(
                              lineColor: Colors.black,
                              lineSpacing: textStyle.fontSize! * textStyle.height!,
                            ),
                          ),
                          /// Contenido de la nota
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Contenido de la nota
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
                                      const Spacer(),
                                      if (isAdmin! || userUID == authorID)
                                      /// Botón de edición (solo admin o autor)
                                        IconButton(
                                          onPressed: () => Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NoteEditorScreen(
                                                noteID: widget.noteID,
                                                groupUID: groupUID,
                                              ),
                                            ),
                                          ),
                                          icon: const Icon(Icons.edit, color: AppColors.notesPrimary, size: 30,),
                                        ),
                                      if (isAdmin || userUID == authorID)
                                      /// Botón de edición (solo admin o autor)
                                        IconButton(
                                          onPressed: () async {
                                            final navigator = Navigator.of(context);//Warning de eliminación de nota."¿Estás seguro?"
                                            final bool confirm = await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.delete_note,
                                                  ),
                                                  content: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.warning_delete_note,
                                                  ),
                                                  actions: [
                                                    /// Confirmar eliminación
                                                    TextButton( //Sí
                                                      onPressed: () {
                                                        removeNote(
                                                          groupUID,
                                                          widget.noteID,
                                                        );
                                                        Navigator.pop(context, true);
                                                      },
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.remove,
                                                      ),
                                                    ),
                                                    /// Cancelar
                                                    TextButton( //No
                                                      onPressed: () =>
                                                          Navigator.pop(context, false),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.cancel,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            if(confirm){
                                              navigator.pop();
                                            }
                                          },
                                          icon: const Icon(Icons.delete, color: AppColors.notesPrimary, size: 30,),
                                        ),

                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  /// Título de la nota
                                  Text(noteInfo["title"], style: const TextStyle(color: AppColors.notesPrimary, fontSize: 25, fontWeight: FontWeight.bold)),
                                  /// Contenido de la nota
                                  Text(noteInfo["body"], style: const TextStyle(fontFamily: 'Astroph', color: Colors.black, fontSize: 18)),

                                  const SizedBox(height: 10),

                                  /// Fecha de última actualización
                                  Text(
                                    "${loc.last_update} ${DateFormat("HH:mm dd/MM/yyyy", "es_ES").format(lastUpdate)}",
                                    style: const TextStyle(color: Colors.black38, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
