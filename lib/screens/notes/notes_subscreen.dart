//Básicos
import 'package:flutter/material.dart';
//COmponentes personalizados
import 'package:pandilla/components/note_component.dart';
//Estilos y colores
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
//Servicios y providers
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Subpantalla de notas dentro de un grupo.
///
/// Permite:
/// - Visualizar las notas del grupo en formato lista o grid
/// - Ordenar las notas por título o por última actualización
/// - Cambiar la vista entre lista y cuadrícula
class NotesSubscreen extends StatefulWidget {
  const NotesSubscreen({super.key});

  @override
  State<NotesSubscreen> createState() => _NotesSubscreenState();
}

/// Estado de la subpantalla de notas.
///
/// Gestiona:
/// - Tipo de ordenación de las notas
/// - Tipo de visualización (lista o grid)
/// - Carga en tiempo real de notas desde Firestore
class _NotesSubscreenState extends State<NotesSubscreen> {
  /// Tipo de ordenación actual.
  /// - "ABC": orden alfabético por título
  /// - "lastUpdate": orden por fecha de última modificación
  String sortedBy = "ABC";

  /// Tipo de vista:
  /// - 1: vista en lista
  /// - -1: vista en cuadrícula
  int _view = 1;

  /// Construye la interfaz de la subpantalla de notas.
  ///
  /// Muestra controles de ordenación, cambio de vista
  /// y la lista de notas en tiempo real.
  @override
  Widget build(BuildContext context) {
    String? groupUID = context.watch<GroupProvider>().groupUID;
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            /// Barra superior de controles (ordenación y vista)
            Row(
              children: [
                ///Control de ordenación
                Text(AppLocalizations.of(context)!.sort_by, style: AppStyles.notesToolBar),
                IconButton(onPressed: (){
                  setState(() {
                    sortedBy=="ABC"
                        ?sortedBy="lastUpdate"
                        :sortedBy="ABC";
                  });
                },
                  icon: Icon(sortedBy == "ABC" ? Icons.sort_by_alpha : Icons.access_time, size: 30,),
                  color: AppColors.notesPrimary,
                ),
                const Spacer(),
                Row(
                  children: [
                    /// Control de vista (lista/grid)
                    Text(
                      AppLocalizations.of(context)!.view,
                      style: AppStyles.notesToolBar
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _view = _view * (-1);
                        });
                      },
                      icon: Icon(_view == 1 ? Icons.list : Icons.grid_view_sharp, size: 30,),
                      color: AppColors.notesPrimary,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: AppColors.notesPrimary),
            Expanded(
              /// Lista o grid de notas en tiempo real
              child: StreamBuilder(
                stream: getNotes(groupUID!),
                builder: (context, snapshot) {
                  //Control del estado del stream
                  if(snapshot.connectionState == ConnectionState.waiting) { //Esperando
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasError) { //Error
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if(!snapshot.hasData||snapshot.data!.isEmpty) { //Sin datos
                    return Center(child: Text(AppLocalizations.of(context)!.no_notes));
                  }

                  //Cargamos los datos
                  List<NoteComponent> data = snapshot.data!;
                  if(sortedBy =="ABC"){ //ordenamos según elección
                    data.sort((a,b)=>a.title.compareTo(b.title));
                  }else{
                    data.sort((a,b)=>b.lastUpdate.compareTo(a.lastUpdate));
                  }
                  /// Renderizado según tipo de vista
                  return _view == 1
                      ? ListView(children: data)
                      : GridView.count(crossAxisCount: 2, children: data);
                }
              ),
            ),
          ],
        ),
      );
  }
}

