import 'package:flutter/material.dart';
import 'package:pandilla/l10n/app_localizations.dart';

/// Widget que permite seleccionar un avatar desde una lista de imágenes.
///
/// Muestra el avatar actual y abre un diálogo con una cuadrícula de opciones
/// para permitir al usuario cambiarlo.
class AvatarPicker extends StatefulWidget {
  /// Avatar actualmente seleccionado (nombre del archivo)
  final String selectedAvatar;

  /// Lista de avatares disponibles (sin extensión .png)
  final List<String> avatarList;

  /// Callback que se ejecuta al seleccionar un nuevo avatar
  final Function(String) onSelectedAvatar;
  const AvatarPicker({super.key, required this.selectedAvatar, required this.onSelectedAvatar, required this.avatarList});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}
/// Estado del widget [AvatarPicker].
///
/// Gestiona la lógica de selección del avatar del usuario.
/// Muestra el avatar actual seleccionado y permite abrir un diálogo
/// para elegir otro avatar desde una lista.
class _AvatarPickerState extends State<AvatarPicker> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /// Avatar actualmente seleccionado, mostrado en grande
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(
            "assets/images/${widget.selectedAvatar}",
          ),
        ),
        /// Botón que abre el selector de avatares
        ElevatedButton(onPressed: () {
          pickAvatar();
        }, child: Text(AppLocalizations.of(context)!.pick_another_avatar)),
      ],
    );
  }

  /// Abre un diálogo con una cuadrícula de avatares disponibles.
  ///
  /// Permite al usuario seleccionar un avatar diferente del listado
  /// proporcionado en [widget.avatarList]. Al seleccionar uno,
  /// se ejecuta el callback [widget.onSelectedAvatar].
  pickAvatar() {
    showDialog(
      context: context,
      builder: (context) {
        ///Diálogo de selección de avatar
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.pick_avatar),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.maxFinite,
            //constructor del gridview con la lista de avatares
            child: GridView.builder(
              itemCount: widget.avatarList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onSelectedAvatar("${widget.avatarList[index]}.png");
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(
                      "assets/images/${widget.avatarList[index]}.png",
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
