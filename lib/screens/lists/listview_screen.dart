//básicos
import 'package:flutter/material.dart';
//Componentes personalizdos
import 'package:pandilla/components/item_component.dart';
//Colores y estilos
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
//Servicios y providers
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/providers/group_provider.dart';

/// Pantalla que muestra el contenido de una lista concreta.
///
/// Permite:
/// - Visualizar los elementos de una lista
/// - Añadir nuevos elementos a la lista
/// - Ordenar los elementos por fecha de creación
class ListviewScreen extends StatefulWidget {
  /// Título de la lista.
  final String title;
  /// Identificador único de la lista.
  final String uid;

  const ListviewScreen({super.key, required this.title, required this.uid});

  @override
  State<ListviewScreen> createState() => _ListviewScreenState();
}

/// Estado de la pantalla de lista.
///
/// Gestiona:
/// - Entrada de nuevos elementos
/// - Control del texto del input
class _ListviewScreenState extends State<ListviewScreen> {
  /// Controlador del campo de texto para añadir nuevos elementos.
  final TextEditingController _controller = TextEditingController();

  /// Construye la interfaz de la pantalla de lista.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    ///Datos del grupo desde provider
    String? groupName = context.read<GroupProvider>().groupName;
    String? groupUID = context.read<GroupProvider>().groupUID;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName!),
        backgroundColor: AppColors.listsPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// Título de la list
              Text(widget.title, style: AppStyles.title,),
              Expanded(
                /// Lista de elementos en tiempo real desde Firestore
                child: StreamBuilder(
                  stream: getItems(groupUID!, widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {//Esperando
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}")); //Error
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) { //Sin datos
                      return Text(loc.no_lists);
                    }
                    //Carga de datos
                    List<ItemComponent> items = snapshot.data!;
                    //Ordenamos los elementos de la lista por orden de creación
                    items.sort((a,b)=>a.createAt.compareTo(b.createAt));
                    /// Renderizado de la lista con separadores
                    return ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (context, int index){
                        return items[index];
                      },
                      separatorBuilder: (context, int index) {
                        return const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 0.1,
                        );
                      },
                    );
                  },
                ),
              ),
              /// Fila inferior para añadir nuevos elementos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Campo de texto para nuevo elemento
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLength: 30,
                      decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.listsPrimary),
                        ),
                        border: const OutlineInputBorder(),
                        labelText: loc.new_item,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),
                  /// Botón para añadir elemento
                  Padding(
                    padding: const EdgeInsetsGeometry.only(bottom: 25),
                    child: FloatingActionButton(
                      backgroundColor: AppColors.listsSecondary,
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        if (_controller.text == "") { //Comprueba que el campo no este vacío
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(loc.warning_empty_item),
                            ),
                          );
                        } else { //Añade el elementos a la lista desde Firestore
                          try {
                            await addItem(groupUID, widget.uid, _controller.text);
                          } catch (e) {
                            debugPrint("Error al añadir elemento a lista: $e");
                            messenger.showSnackBar(SnackBar(content: Text(loc.error_try_again)));
                          }
                          setState(() {
                            _controller.clear(); //Limpia el campo para añadir nuevos elementos
                          });
                        }
                      },
                      child: const Icon(Icons.add, size: 30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
