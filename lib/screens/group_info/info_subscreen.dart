//Básicos
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Providers y services
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
//Estilos y colores
import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
//Pantallas
import '../profile/profile_screen.dart';

/// Subpantalla que muestra la información general del grupo y su lista de miembros.
///
/// Permite:
/// - Ver la información del grupo (descripción, código, creador, fecha de creación)
/// - Copiar el código del grupo
/// - Abandonar el grupo
/// - Visualizar la lista de miembros
/// - Gestionar miembros (si el usuario es administrador)
class InfoSubscreen extends StatefulWidget {
  /// UID del grupo del que se mostrará la información.
  final String groupUID;
  const InfoSubscreen({super.key, required this.groupUID});

  @override
  State<InfoSubscreen> createState() => _InfoSubscreenState();
}

/// Estado de la subpantalla de información del grupo.
///
/// Gestiona:
/// - Carga de datos del grupo
/// - Carga de miembros
/// - Acciones de administración (promover, expulsar, abandonar grupo)
class _InfoSubscreenState extends State<InfoSubscreen> {
  /// Future que contiene la lista de miembros del grupo.
  Future<List<Map<String, dynamic>>>? _futureData;

  /// Inicializa la carga de datos del grupo.
  ///
  /// Se ejecuta una única vez al crear el widget.
  @override
  void initState() {
    super.initState();
    _futureData = getMembersList(widget.groupUID);
  }

  /// Construye la interfaz de la subpantalla de información del grupo.
  @override
  Widget build(BuildContext context) {
    /// Indica si el usuario actual es administrador del grupo.
    bool? isAdmin = context.watch<GroupProvider>().isAdmin;
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          /// Card con información general del grupo
          Card.filled(
            color: AppColors.members_primary,
            child: Container(
              padding: const EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.maxFinite,
              /// FutureBuilder para cargar datos del grupo
              child: FutureBuilder(
                future: getGroupInfo(widget.groupUID),
                builder: (context, snapshot) {
                  //Control de estado de carga de datos
                  if (snapshot.connectionState == ConnectionState.waiting) { //Cargando
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) { //Error
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) { //sin datos
                    return Text(AppLocalizations.of(context)!.no_info);
                  }
                  //cargamos los datos
                  Map<String, dynamic> info = snapshot.data!;
                  DateTime createAt = info["createAt"].toDate();
                  String code = info["code"];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// Avatar del grupo
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/images/${info["avatar"]}"),
                      ),
                      /// Descripción del grupo
                      Text(info["description"], style: const TextStyle(color: Colors.white, fontSize: 18)),
                      /// Información de creación del grupo (autor + fecha)
                      Text(
                        "${AppLocalizations.of(context)!.created_at} ${DateFormat("dd MMM yyyy", "es_ES").format(createAt)} ${AppLocalizations.of(context)!.by} ${info["authorName"]}",
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      /// Botones de acciones del grupo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Botón para copiar el código del grupo
                          ElevatedButton.icon(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final loc = AppLocalizations.of(context)!;
                              await Clipboard.setData( //Copiamos el código para poder compartirlo más fácil
                                ClipboardData(text: code),
                              );
                              messenger.showSnackBar(
                                SnackBar(content: Text(loc.code_copied)), //le indicamos al usuario que el código se ha copiado
                              );
                            },
                            label: Text(code),
                            icon: const Icon(Icons.copy),
                          ),
                          /// Botón para abandonar el grupo
                          ElevatedButton.icon(
                            onPressed: () async {
                              int numAdmins = await getAdminsLength(
                                widget.groupUID,
                              );
                              /// Evita que el último administrador abandone el grupo
                              if (isAdmin! && numAdmins < 2) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog( //Warning: es el último admin, debe nombrar a otro antes de abandonar el grupo
                                      title: const Text("Error"),
                                      content: Text(
                                          AppLocalizations.of(context)!.warning_no_more_admins
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(AppLocalizations.of(context)!.accept),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else { //Si no hay problemas para abandonar el grupo => Pregunta si está seguro
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.leave_group),
                                      content: Text(
                                        AppLocalizations.of(context)!.warning_leave_group,
                                      ),
                                      actions: [
                                        TextButton( //Sí
                                          onPressed: () {
                                            String? userUID = FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid;
                                            kickMember( //es expulsado del grupo
                                              widget.groupUID,
                                              userUID!,
                                            );
                                          },
                                          child: Text(AppLocalizations.of(context)!.confirm),
                                        ),
                                        TextButton( //No
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(AppLocalizations.of(context)!.cancel),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            label: Text(AppLocalizations.of(context)!.leave_group),
                            icon: const Icon(Icons.logout),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          /// Título de la sección de miembros
          Text(AppLocalizations.of(context)!.group_members, style: AppStyles.title),
          /// Lista de miembros del grupo
          Expanded(
            child: FutureBuilder(
              future: _futureData,
              builder: (context, snapshot) {
                //Estado de carga
                if (snapshot.connectionState == ConnectionState.waiting) { //Cargando
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) { //error
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) { //Sin datos
                  return Text(AppLocalizations.of(context)!.no_member);
                }
                //Carga de datos
                List<Map<String, dynamic>> data = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      ///Renderizado de lista de miembros
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card.filled(
                            color: AppColors.members_secondary,
                            child: GestureDetector( //si pulsa sobre un elemento de la lista, lo envía al perfil del usuario seleccinado
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    userProfileUID: data[index]["uid"],
                                  ),
                                ),
                              ),
                              onLongPress: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    /// Avatar del miembro
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                        "assets/images/${data[index]["avatar"]}",
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    /// Nombre del miembro
                                    Text(
                                      data[index]["name"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                      ),
                                    ),
                                    /// Icono de administrador
                                    if(data[index]["admin"])Icon(Icons.star, color: AppColors.lists_primary,),

                                    const Spacer(),
                                    /// Botón para promocionar a admin (solo visible para admins)
                                    if (isAdmin! && !data[index]["admin"])
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog( //Dialogo para preguntar si está seguro
                                                title: Text(
                                                  AppLocalizations.of(context)!.make_admin,
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(context)!.make_admin_dialog,
                                                ),
                                                actions: [
                                                  //cancelar
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(AppLocalizations.of(context)!.cancel),
                                                  ),
                                                  TextButton(
                                                    //Aceptar
                                                    onPressed: () async {
                                                      final navigator= Navigator.of(context);
                                                      await addAdmin(widget.groupUID, data[index]["uid"]); //añade a la lista de miembros
                                                      setState(() { //vuelve a cargar la lista de miembros actualizada
                                                        _futureData =
                                                            getMembersList(
                                                              widget.groupUID,
                                                            );
                                                      });
                                                      navigator.pop();
                                                    },
                                                    child: Text(AppLocalizations.of(context)!.promote),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Icon(
                                          Icons.keyboard_double_arrow_up,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                      ),
                                    /// Botón para expulsar miembro(solo visible para admins)
                                    if (isAdmin &&
                                        userUID != data[index]["uid"])
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog( //Warning: ¿Estás seguro?
                                                title: Text(
                                                  AppLocalizations.of(context)!.remove_member,
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(context)!.warning_remove_member,
                                                ),
                                                actions: [
                                                  TextButton( //Cancelar
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(AppLocalizations.of(context)!.cancel),
                                                  ),
                                                  TextButton( //Expulsar
                                                    onPressed: () async {
                                                      final navigator = Navigator.of(context);
                                                      await kickMember( //expulsa miembro
                                                        widget.groupUID,
                                                        data[index]["uid"],
                                                      );
                                                      setState(() { //vuelve a cargar lista de mimembros
                                                        _futureData =
                                                            getMembersList(
                                                              widget.groupUID,
                                                            );
                                                      });
                                                      navigator.pop();
                                                    },
                                                    child: Text(AppLocalizations.of(context)!.remove),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 30,
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
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
