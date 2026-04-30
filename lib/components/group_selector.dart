//Básicos
import 'package:flutter/material.dart';
//Estilos y colores
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/l10n/app_localizations.dart';
//Firebase
import '../core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Servicios y providers
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:provider/provider.dart';
//Pantallas
import '../screens/group_screen.dart';

/// Widget selector de grupo.
///
/// Representa una tarjeta visual de un grupo al que pertenece el usuario.
/// Permite seleccionar un grupo y navegar a su pantalla principal,
/// cargando previamente la información en [GroupProvider].
class GroupSelector extends StatefulWidget {
  /// ID único del grupo.
  final String groupUID;

  /// Nombre del grupo.
  final String groupName;

  /// Código de acceso del grupo.
  final String code;

  /// Nombre del avatar del grupo (asset).
  final String avatar;
  const GroupSelector({
    super.key,
    required this.groupUID,
    required this.groupName,
    required this.code,
    required this.avatar,
  });

  @override
  State<GroupSelector> createState() => _GroupSelectorState();
}

/// Estado del widget [GroupSelector].
///
/// Gestiona la interacción del usuario al seleccionar un grupo
/// y realiza la navegación a la pantalla principal del grupo.
class _GroupSelectorState extends State<GroupSelector> {

  /// Construye la interfaz del selector de grupo.
  ///
  /// Muestra un contenedor que contiene el avatar del grupo
  /// y el nombre del grupo.
  ///
  /// Al interaccionar con el componente, te dirige a la
  /// pantalla del grupo.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),

      /// Tarjeta seleccionable del grupo
      child: GestureDetector(
        onTap: () async {
          //Iniciamos los elementos que precisan de context antes de entrar en zona async(después del await)
          final GroupProvider groupProvider = context.read<GroupProvider>();
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final AppLocalizations loc = AppLocalizations.of(context)!;
          try {
            String? userUID = FirebaseAuth.instance.currentUser?.uid;
            /// Comprueba si el usuario es administrador del grupo
            bool admin = await isAdmin(widget.groupUID, userUID!);

            /// Guarda la información del grupo en el provider global
            groupProvider.setGroup(
              widget.groupUID,
              widget.groupName,
              admin,
              widget.code,
            );

            /// Navega a la pantalla del grupo seleccionado
            navigator.push(
              MaterialPageRoute(
                builder: (context) => GroupScreen(
                  groupName: widget.groupName,
                  groupUID: widget.groupUID,
                ),
              ),
            );
          } catch (e) {
            debugPrint("Error al cargar grupo: $e");
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  loc.error_try_again,
                ),
              ),
            );
          }
        },
        /// Contenedor visual del grupo
        child: Container(
          height: 100,
          width: 100,
          decoration: AppStyles.mainScreenBox,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Avatar del grupo
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/images/${widget.avatar}"),
              ),

              /// Nombre del grupo
              Text(
                widget.groupName,
                style: const TextStyle(color: AppColors.primary, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
