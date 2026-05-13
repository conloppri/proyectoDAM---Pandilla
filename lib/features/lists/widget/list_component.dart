//Básicos
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Componentes personalizados

//Estilos y colores
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
//Servicios y providers
import 'package:provider/provider.dart';
import '../../../core/providers/group_provider.dart';
import '../../../l10n/app_localizations.dart';
//Pantallas
import 'package:pandilla/features/lists/screens/listview_screen.dart';

/// Widget que representa una lista dentro del listado de listas en grupos.
///
/// Muestra información básica de la lista, como título, autor,
/// número de elementos y última actualización.
/// Permite acceder a los detalles de la lista y eliminarla
/// si el usuario tiene permisos.
class ListComponent extends StatefulWidget {
  /// ID del grupo al que pertenece la lista.
  final String groupUID;

  /// Título de la lista.
  final String title;

  /// Nombre del autor de la lista.
  final String author;

  /// Fecha de la última actualización.
  final DateTime lastUpdate;

  /// ID de la lista.
  final String listID;

  /// ID del usuario autor de la lista.
  final String authorID;

  const ListComponent({
    super.key,
    required this.title,
    required this.author,
    required this.lastUpdate,
    required this.listID,
    required this.authorID,
    required this.groupUID,
  });

  @override
  State<ListComponent> createState() => _ListComponentState();
}

/// Estado del widget [ListComponent].
///
/// Gestiona la carga del número de elementos de la lista
/// y la interacción del usuario con la misma.
class _ListComponentState extends State<ListComponent> {
  /// Número de elementos actuales en la lista.
  int numItems = 0;

  /// Carga el número de elementos desde la base de datos.
  loadNumItems() async {
    try {
      numItems  = await getNumItems(widget.groupUID, widget.listID);
      setState((){});
    } catch (e) {
      debugPrint("Error cargando el número de items: $e");
    }
  }

  /// Mwtodo de inicialización del estado del widget.
  ///
  /// Carga el número de elementos de la lista desde
  /// la base de datos al iniciar el widget.
  @override
  void initState() {
    super.initState();
    loadNumItems();
  }

  /// Construye la interfaz visual del [ListComponent].
  ///
  /// Muestra una tarjeta con información de la lista, incluyendo:
  /// - Autor de la lista
  /// - Título
  /// - Número de elementos
  /// - Fecha de última actualización
  ///
  /// También permite:
  /// - Navegar al detalle de la lista al pulsar.
  /// - Eliminar la lista si el usuario es administrador o creador.
  @override
  Widget build(BuildContext context) {
    //Servicios de localización
    final AppLocalizations loc = AppLocalizations.of(context)!;

    //Carga de datos desde provider
    bool? isAdmin = context.read<GroupProvider>().isAdmin;

    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    ///Contenedor del componente
    return Card.filled(
      elevation: 5,
      color: AppColors.listsSecondary,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.listsPrimary, width: 2),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              ///Línea para indicar el autor de la lista
              children: [
                Text("${loc.created_by} ",style:AppStyles.blackFont),
                Text(widget.author, style: AppStyles.blackBoldStyle),

                const Spacer(),

                /// Botón de eliminación de la lista (solo admin o autor).
                if (isAdmin!||userUID == widget.authorID)IconButton(onPressed: (){
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog( //warning de eliminación
                        title: Text(loc.delete_list),
                        content: Text(
                          loc.warning_delete_list,
                        ),
                        actions: [
                          TextButton( ///Cancelar
                            onPressed: () => Navigator.pop(context),
                            child: Text(loc.cancel),
                          ),
                          ///Eliminar
                          TextButton(
                            onPressed: () {
                              try {
                                removeList(widget.groupUID, widget.listID);
                                Navigator.pop(context);
                              } catch (e) {
                                debugPrint("Error eliminando lista: $e");
                              }
                            },
                            child: Text(loc.remove),
                          ),
                        ],
                      );
                    },
                  );
                }, icon: const Icon(Icons.delete, color: AppColors.listsPrimary,))
              ],
            ),
            /// Información principal de la lista.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                ///Título
                title: Text(widget.title, style: const TextStyle(color: AppColors.listsPrimary, fontWeight: FontWeight.bold, fontSize: 20),),
                ///Número de elementos de la lista
                subtitle: Text(
                  "$numItems ${loc.items}", style: const TextStyle(color: Colors.black, fontSize: 15)
                ),
                /// Navega al detalle de la lista y refresca al volver.
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ListviewScreen(title: widget.title, uid: widget.listID),
                    ),
                  );
                  setState(() {
                    loadNumItems(); // Recargamos el num de items al regresar
                  });

                },
              ),
            ),
            /// Fecha de última actualización.
            Text(
              "${loc.last_update} ${DateFormat("HH:mm dd/MM/yyyy", "es_ES").format(widget.lastUpdate)}",
              style: const TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
