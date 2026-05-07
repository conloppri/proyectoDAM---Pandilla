//Básicos
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
//Componentes personalizados
import 'package:pandilla/components/avatar_picker.dart';
import 'package:pandilla/components/left_drawer.dart';
//Providers
import 'package:provider/provider.dart';
import 'package:pandilla/core/providers/user_provider.dart';
//Localizaciones
import 'package:pandilla/l10n/app_localizations.dart';
//SharePreferences
import 'package:shared_preferences/shared_preferences.dart';
//Estilos y colores
import '../../../core/app_colors.dart';
import '../../../core/app_styles.dart';
//Firebase
import '../../../core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Pantalla principal de la aplicación.
///
/// Muestra:
/// - Próximos eventos del usuario
/// - Lista de grupos a los que pertenece
/// - Opciones para crear o unirse a grupos
///
/// También gestiona la carga de datos del usuario y el tutorial inicial.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
/// Estado de la pantalla principal [MainScreen]
///
/// Gestiona:
/// - Datos temporales para creación/unión de grupos
/// - Carga del usuario
/// - Programación de eventos
/// - Tutorial interactivo
class _MainScreenState extends State<MainScreen> {
  /// Nombre del grupo a crear.
  String _groupName = "";

  /// Descripción del grupo.
  String _groupDescription = "";

  /// Código introducido para unirse a un grupo.
  String _code = "";

  /// Lista de avatares disponibles para grupos.
  final List<String> _avatarList = [
    "reading",
    "cooking",
    "videogames",
    "football",
    "party",
    "playing",
    "pool",
    "working",
  ];

  /// Avatar seleccionado actualmente (reading.png por defecto)
  String _selectedAvatar = "reading.png";


  //Global Keys para tutorial

  /// Referencia al widget de próximos eventos.
  GlobalKey nextEvents = GlobalKey();

  /// Referencia al botón de crear grupo.
  GlobalKey createButton = GlobalKey();

  /// Referencia al botón de unirse a grupo.
  GlobalKey joinButton = GlobalKey();

  /// Referencia a la lista de grupos.
  GlobalKey groupList = GlobalKey();

  //Variable para para comprobar si el usuario ya ha realizado la guía interactiva
  bool? tutorialCompleted;

  /// Carga la información del usuario desde Firestore
  /// y la guarda en el `UserProvider`.
  ///
  /// También lanza el tutorial, si procede
  Future<void> loadInfo() async {
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    UserProvider userProvider = context.read<UserProvider>();
    Map userInfo = await getUser(userUID!);
    userProvider.setUser(
      userUID,
      userInfo["name"],
      userInfo["avatar"],
      userInfo["email"],
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    tutorialCompleted = prefs.getBool("main_tutorial");
    setState(() {});

    //Comprobación previa tutorial
    if(tutorialCompleted == null || !tutorialCompleted!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTutorial(); //Guía interactiva
      });
    }
  }

  /// Metodo de inicialización del estado.
  ///
  /// - Carga los datos del usuario
  /// - Reprograma los eventos cada vez que el usuario entra a la app
  @override
  void initState() {
    super.initState();
    loadInfo(); //Carga de datos
    scheduleAllEvents(); //Reprogramación de eventos
  }

  /// Construye la interfaz principal de la pantalla.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Positioned.fill(child: Image.asset("assets/images/profile_background.png", fit: BoxFit.cover)),
        Scaffold(
          appBar: AppBar(
            title: const Text("Pandilla", style: AppStyles.appBarTitle),
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
          ),
          ///Drawer lateral personalizado
          drawer: const LeftDrawer(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  /// Sección de próximos eventos
                  Text(loc.next_events, style: AppStyles.title),
                  /// Contenedor de eventos próximos
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: Row(
                      key: nextEvents,
                      children: [
                        Image.asset("assets/images/main.png", height: MediaQuery.of(context).size.height * 0.15 ),
                        /// Lista de eventos próximos
                        Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          height: MediaQuery.of(context).size.height * 0.25,
                          margin: const EdgeInsetsGeometry.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          decoration: AppStyles.mainScreenBox,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder(
                              future: getNextEvents(),
                              builder: (context, snapshot) {

                                //Control del estado del Builder
                                if (snapshot.connectionState == ConnectionState.waiting) { //Mientras carga los datos
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) { //Si hay error
                                  return Center(child: Text("Error: ${snapshot.error}"));
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) { //Si el future no devuelve datos
                                  return Center(child: Text(loc.no_next_events, style: const TextStyle(color: AppColors.primary, fontSize: 15),));
                                }
                                //Carga de datos
                                List<Map<String, dynamic>> events = snapshot.data!;
                                return Center(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: events.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      DateFormat dateFormat = DateFormat("dd-MMM", "es_ES");
                                      DateTime dateEvent = events[index]["date"];
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("${dateFormat.format(dateEvent)}: ", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize:15),),
                                          Expanded(
                                            child: Text(events[index]["title"],
                                              overflow: TextOverflow.ellipsis, //Si no cabe en el container, lo indicará con "..."
                                              style: const TextStyle(fontSize: 15)
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 40),

                  /// Título de la sección de grupos
                  Text(
                    loc.my_groups,
                    style: const TextStyle(color: AppColors.primary, fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  /// Lista de grupos del usuario
                  Expanded(
                    child: StreamBuilder(
                      key: groupList,
                      stream: getGroups(),
                      builder: (context, snapshot) {
                        //Control del Stream
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text(loc.no_groups);
                        }
                        //Muestra la info en un grid de 2 columnas
                        return ListView(
                          children: snapshot.data!,
                        );
                      },
                    ),
                  ),

                  /// Botones de acciones (crear / unirse)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /// Botón para crear grupo
                        ElevatedButton(
                          key:createButton ,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      title: Text(loc.new_group),
                                      /// Formulario de creación de grupo
                                      content: ListView(
                                        children: [
                                          ///Widget para selección de avatar
                                          AvatarPicker(
                                            selectedAvatar: _selectedAvatar,
                                            onSelectedAvatar: (avatar) {
                                              setStateDialog((){
                                                _selectedAvatar = avatar;
                                              });
                                            },
                                            avatarList: _avatarList,
                                          ),
                                          /// Campo nombre
                                          TextField(
                                            maxLength: 20,
                                            onChanged: (value) =>
                                                _groupName = value,
                                            decoration: InputDecoration(
                                              labelText: loc.group_name,
                                            ),
                                          ),
                                          /// Campo descripción
                                          TextField(
                                            minLines: 3,
                                            maxLines: 5,
                                            maxLength: 100,
                                            onChanged: (value) =>
                                                _groupDescription = value,
                                            decoration: InputDecoration(
                                              labelText: loc.description,
                                              border: const OutlineInputBorder()
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        /// Confirmar creación
                                        TextButton(
                                          onPressed: () {
                                            if(_groupName!= "") {
                                              String? userName = context
                                                  .read<UserProvider>()
                                                  .name; //Tomamos el nombre para guardar autor
                                              try {
                                                createGroup(
                                                    _groupName,
                                                    _groupDescription,
                                                    _selectedAvatar,
                                                    userName!
                                                );
                                              }catch (e) {
                                                debugPrint("Error al crear grupo: $e");
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.error_try_again)));
                                              }
                                              Navigator.pop(context);
                                            }else{
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(loc.error_group_name))
                                              );
                                            }
                                          },
                                          child: Text(loc.create),
                                        ),
                                        /// Cancelar
                                        TextButton(
                                          onPressed: () => Navigator.pop(context), //Cierra el diálogo
                                          child: Text(loc.cancel),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                              minimumSize: Size(MediaQuery.of(context).size.width *0.4, MediaQuery.of(context).size.height *0.05)
                          ),
                          child: Padding(
                            padding: const EdgeInsetsGeometry.all(10),
                            child: Row(
                              children: [
                                const Icon(Icons.add, size: 25, color: Colors.white),
                                Text(
                                  loc.create,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        /// Botón para unirse a grupo
                        ElevatedButton(
                          key: joinButton,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(loc.join_group),
                                  content: TextField(
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      labelText: loc.code,
                                    ),
                                    onChanged: (value) => _code = value,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        //Elementos que necesitan context, los iniciamos antes del await para evitar problemas de sincronización
                                        final messenger = ScaffoldMessenger.of(context);
                                        final navigator = Navigator.of(context);
                                        try {
                                          bool joined = await joinGroup(_code.toUpperCase()); //Compruba código y trata de unirse

                                          if (joined) {
                                            //si lo ha conseguido, cierra el diálogo y aparece el grupo en la lista
                                            setState(() {});
                                            navigator.pop();
                                          } else { //Si no, le notifica al usuario
                                            messenger.showSnackBar(
                                                SnackBar(content: Text(loc.error_invalid_code))
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint("Error al intentar unirse a grupo: $e");
                                          messenger.showSnackBar(SnackBar(content: Text(loc.error_try_again)));
                                        }
                                      },
                                      child: Text(loc.join),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(loc.cancel),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: Size(MediaQuery.of(context).size.width *0.4, MediaQuery.of(context).size.height *0.05)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link, size: 25, color: Colors.white),
                                Text(
                                  loc.join,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Muestra el tutorial interactivo de la pantalla principal.
  ///
  /// Solo se muestra una vez, guardando su estado en `SharedPreferences`.
  Future<void> showTutorial() async {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    TutorialCoachMark(
        alignSkip: Alignment.topRight,
        textSkip: loc.skip,
        textStyleSkip: const TextStyle(color: AppColors.primary, fontSize: 20),
        targets: [
      /// Paso: eventos próximos
      TargetFocus(
          identify: "nextEvents",
          keyTarget: nextEvents,
          contents: [
            TargetContent(
                align: ContentAlign.custom,
                customPosition: CustomTargetContentPosition(bottom: MediaQuery
                    .of(context)
                    .size
                    .height * 0.35),
                child: Container(
                  padding: const EdgeInsetsGeometry.all(12),
                  decoration: AppStyles.tutorialBox,
                  child: Text(
                      loc.tutorial_next_events,
                      style: AppStyles.tutorialTextStyle),
                )
            )
          ]
      ),
      /// Paso: crear grupo
      TargetFocus(
          identify: "createButton",
          keyTarget: createButton,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsetsGeometry.all(12),
                    decoration: AppStyles.tutorialBox,
                    child: Text(loc.tutorial_create,
                        style: AppStyles.tutorialTextStyle),
                  ),
                )
            )
          ]
      ),
      /// Paso: unirse a grupo
      TargetFocus(
          identify: "joinButton",
          keyTarget: joinButton,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsetsGeometry.all(12),
                    decoration: AppStyles.tutorialBox,
                    child: Text(loc.tutorial_join,
                        style: AppStyles.tutorialTextStyle),
                  ),
                )
            )
          ]
      ),
      /// Paso: lista de grupos
      TargetFocus(
          identify: "groupList",
          keyTarget: groupList,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsetsGeometry.all(12),
                    decoration: AppStyles.tutorialBox,
                    child: Text(
                        loc.tutorial_listGroups,
                        style: AppStyles.tutorialTextStyle),
                  ),
                )
            )
          ]
      ),
    ]
    ).show(context: context);

    //Marca el tutorial como visto
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("main_tutorial", true);
  }

}
