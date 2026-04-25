//Básicos
import 'package:flutter/material.dart';
//Componentes personalizados
import '../../components/list_component.dart';
//Estilos y colores
import '../../core/app_colors.dart';
//Servicios y providers
import 'package:provider/provider.dart';
import '../../core/providers/group_provider.dart';
import '../../l10n/app_localizations.dart';
//Firebase
import '../../core/services/firebase_service.dart';

/// Subpantalla que muestra la lista de listas dentro de un grupo.
///
/// Permite:
/// - Ordenar las listas por nombre (ABC) o por fecha de última actualización
/// - Mostrar las listas en forma de listado
class ListsSubscreen extends StatefulWidget {
  const ListsSubscreen({super.key});

  @override
  State<ListsSubscreen> createState() => _ListsSubscreenState();
}

/// Estado de la subpantalla de listas.
///
/// Gestiona:
/// - El criterio de ordenación de las listas
class _ListsSubscreenState extends State<ListsSubscreen> {
  /// Criterio de ordenación actual.
  /// Puede ser:
  /// - "ABC" → orden alfabético
  /// - "lastUpdate" → orden por fecha de actualización
  String sortedBy = "ABC";

  /// Construye la interfaz de la subpantalla de listas.
  @override
  Widget build(BuildContext context) {
    /// Identificador del grupo actual obtenido desde el provider.
    String? groupUID = context.watch<GroupProvider>().groupUID;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Fila superior con opciones de ordenación
          Row(
            children: [
              Text(AppLocalizations.of(context)!.sort_by, style: TextStyle(color: AppColors.lists_primary, fontSize: 15),),
              IconButton(onPressed: (){
                setState(() {
                  sortedBy=="ABC"
                      ?sortedBy="lastUpdate"
                      :sortedBy="ABC";
                });
              },
                  icon: Icon(sortedBy == "ABC" ? Icons.sort_by_alpha : Icons.access_time, size: 30,),
                color: AppColors.lists_primary,
              ),
            ],
          ),
          Divider(color: AppColors.lists_primary),
          Expanded(
            /// Lista de listas obtenidas desde Firestore en tiempo real
            child: StreamBuilder(
                stream: getLists(groupUID!),
                builder: (context, snapshot) {
                  //Estado del stream
                  if(snapshot.connectionState == ConnectionState.waiting) { //Esperando
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasError) { //Error
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if(!snapshot.hasData||snapshot.data!.isEmpty) { //Sin datos
                    return Center(child: Text(AppLocalizations.of(context)!.no_lists));
                  }

                  //cargamos datos
                  List<ListComponent> data = snapshot.data!;
                  //Sistema de ordenación
                  if(sortedBy =="ABC"){
                    data.sort((a,b)=>a.title.compareTo(b.title));
                  }else{
                    data.sort((a,b)=>b.lastUpdate.compareTo(a.lastUpdate));
                  }
                  /// Renderizado de la lista
                  return ListView(children: snapshot.data!);
                }
            ),
          ),
        ],
      ),
    );
  }
}