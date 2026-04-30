import 'package:flutter/material.dart';
//Colores
import 'package:pandilla/core/app_colors.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/l10n/app_localizations.dart';
//Providers
import 'package:provider/provider.dart';
import '../core/providers/group_provider.dart';

/// Widget que representa un elemento individual dentro de una lista.
///
/// Muestra un ítem con estado de completado o pendiente.
/// Permite cambiar su estado al tocarlo y eliminarlo mediante un botón.
class ItemComponent extends StatefulWidget {
  /// Texto del ítem.
  final String item;

  /// ID único del ítem.
  final String itemId;

  /// ID de la lista a la que pertenece el ítem.
  final String listID;

  /// Indica si el ítem está completado.
  final bool isCompleted;

  /// Fecha de creación del ítem.
  final DateTime createAt;

  const ItemComponent({
    super.key,
    required this.item,
    required this.itemId,
    required this.isCompleted,
    required this.listID,
    required this.createAt,
  });

  @override
  State<ItemComponent> createState() => _ItemComponentState();
}

/// Estado del widget [ItemComponent].
///
/// Gestiona la interacción del usuario con el ítem,
/// como marcarlo como completado o eliminarlo.
class _ItemComponentState extends State<ItemComponent> {

  /// Construye la interfaz elemento de una lista..
  ///
  /// El elemento es un ListTile con ícono de check
  /// que varía según si está completo o no. Cuando
  /// está marcado, el nombre del item esta tachado.
  @override
  Widget build(BuildContext context) {
    String? groupUID = context.read<GroupProvider>().groupUID;
    return ListTile(
      title: Row(
        children: [
          /// Icono de estado (completado o pendiente)
          Icon(
            widget.isCompleted
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank,
            color: AppColors.listsPrimary,
          ),
          const SizedBox(width: 10,),
          /// Texto del ítem (tachado si está completado)
          Text(
            widget.item,
            style: TextStyle(
              fontFamily: "Astroph",
              decoration: widget.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          const Spacer(),

          /// Botón para eliminar el ítem
          IconButton(
            onPressed: () {
              try {
                removeItem(groupUID!, widget.listID, widget.itemId);
              } catch (e) {
                debugPrint("Error eliminando el item: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.error_try_again,
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),

      /// Cambia el estado del ítem al tocarlo
      onTap: () {
        try {
          changeItemStatus(
            groupUID!,
            widget.listID,
            widget.itemId,
            !widget.isCompleted,
          );
        }  catch (e) {
          debugPrint("Error cambiando el estado el item: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.error_try_again,
              ),
            ),
          );
        }
      }
    );
  }
}
