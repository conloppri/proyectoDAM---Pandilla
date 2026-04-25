//Básicos
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
//Componentes personalizados
import 'package:pandilla/components/left_drawer.dart';
//Estilos y colores
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pandilla/core/services/firebase_service.dart';
//Pantallas y subpantallas
import 'package:pandilla/screens/calendar/event_creator_screen.dart';
import 'package:pandilla/screens/group_info/info_editor.dart';
import 'package:pandilla/screens/notes/note_creator_screen.dart';
import 'package:pandilla/screens/calendar/calendar_subscreen.dart';
import 'package:pandilla/screens/lists/lists_subscreen.dart';
import 'package:pandilla/screens/group_info/info_subscreen.dart';
import 'package:pandilla/screens/notes/notes_subscreen.dart';
//Providers y servicios
import 'package:pandilla/core/services/navigator_key.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// Pantalla principal de un grupo.
///
/// Permite navegar entre las distintas secciones del grupo:
/// calendario, notas, listas e información del grupo.
/// También incluye acciones rápidas (crear eventos, notas y listas)
/// y gestión de miembros/admin.
class GroupScreen extends StatefulWidget {
  /// Identificador único del grupo.
  final String groupName;

  /// Nombre del grupo.
  final String groupUID;

  const GroupScreen({
    super.key,
    required this.groupUID,
    required this.groupName,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

/// Estado de la pantalla del grupo.
///
/// Controla:
/// - Navegación inferior entre subscreens
/// - Tutorial interactivo
/// - Acciones rápidas del FAB
/// - Detección de expulsión del grupo
class _GroupScreenState extends State<GroupScreen> {
  /// Índice actual del BottomNavigationBar.
  int _selectedIndexBottom = 0;

  /// Título de lista temporal al crear listas.
  String _listTitle = "";

  /// Colores principales por sección.
  List primaryColors = [
    AppColors.calendarPrimary,
    AppColors.notesPrimary,
    AppColors.listsPrimary,
    AppColors.infoPrimary,
  ];

  /// Colores secundarios por sección.
  List secondaryColors = [
    AppColors.calendarSecondary,
    AppColors.notesSecondary,
    AppColors.listsSecondary,
    AppColors.infoSecondary,
  ];

  /// Provider del grupo (estado global del grupo).
  late final GroupProvider provider;

  ///Control de guía interactiva
  bool? tutorialCompleted;

  //GLOBAL KEYS - tutorial
  GlobalKey calendarKey = GlobalKey();
  GlobalKey notesKey = GlobalKey();
  GlobalKey listsKey = GlobalKey();
  GlobalKey infoKey = GlobalKey();
  GlobalKey lastKey = GlobalKey();

  /// Inicialización del estado.
  ///
  /// - Inicia escucha del provider del grupo
  /// - Registra listener para expulsión
  @override
  void initState() {
    super.initState();
    final String? userUID = FirebaseAuth.instance.currentUser?.uid;

    provider = context.read<GroupProvider>();

    provider.startListening(userUID!);

    provider.addListener(_handleKick);

    loadPrefs();
  }

  ///Carga las preferencias respecto al tutorial
  ///y lo lanza si procede
  loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tutorialCompleted = prefs.getBool("group_tutorial");
    setState(() {});
    if(!tutorialCompleted!){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTutorial();
      });
    }
  }

  /// Libera recursos del listener del provider.
  @override
  void dispose() {
    provider.removeListener(_handleKick);
    super.dispose();
  }

  /// Construye la interfaz del grupo.
  @override
  Widget build(BuildContext context) {
    //Controlamos si el usuario activo es administrador del grupo
    bool? isAdmin = context.watch<GroupProvider>().isAdmin;

    /// Subpantallas del grupo según pestaña seleccionada.
    List selectedSubscreen = [
      const CalendarSubscreen(),
      const NotesSubscreen(),
      const ListsSubscreen(),
      InfoSubscreen(groupUID: widget.groupUID),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: AppStyles.title),
        backgroundColor: primaryColors[_selectedIndexBottom],
        foregroundColor: Colors.white,
        actions: [
          /// Menú de opciones del grupo
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              if (isAdmin!)
                PopupMenuItem(
                  value: "edit",
                  child: Text(AppLocalizations.of(context)!.edit_group_info),
                ), //Editar grupo => Solo admins
              if (isAdmin)
                PopupMenuItem(
                  value: "delete",
                  child: Text(
                    AppLocalizations.of(context)!.delete_group,
                    style: const TextStyle(color: Colors.red),
                  ),
                ), //Elimiar grupo => Solo admins
              PopupMenuItem(
                value: "info",
                child: Text(AppLocalizations.of(context)!.about),
              ), //Info sobre la app
            ],
            //Control de elección del popMenu
            onSelected: (value) {
              if (value == "info") {
                //info
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.about),
                      content: Text(
                        "App desarrollada por Consuelo López Prieto para Proyecto Intermodular de DAM 2025/2026.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                      ],
                    );
                  },
                );
              }
              if (value == "delete") {
                //eliminar grupo
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      //Advertencia de si está seguro de eliminar
                      title: Text(AppLocalizations.of(context)!.delete_group),
                      content: Text(
                        AppLocalizations.of(context)!.warning_group_removal,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteGroup(widget.groupUID);
                            Navigator.pushReplacementNamed(context, "/home");
                            Navigator.pushReplacementNamed(context, "/home");
                          },
                          child: Text(
                            AppLocalizations.of(context)!.remove,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
              if (value == "edit") {
                //editar => Pantalla de edicción de grupo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoEditor(
                      groupUID: widget.groupUID,
                      groupName: widget.groupName,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      ///Drawer lateral personalizado
      drawer: const LeftDrawer(),

      ///Barra inferior de navegación entre secciones
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndexBottom,
        selectedItemColor: primaryColors[_selectedIndexBottom],
        unselectedItemColor: secondaryColors[_selectedIndexBottom],
        items: [
          BottomNavigationBarItem(
            //CALENDARIO
            key: calendarKey,
            icon: const Icon(Icons.calendar_month_outlined, size: 40),
            label: AppLocalizations.of(context)!.calendar,
          ),
          BottomNavigationBarItem(
            //NOTAS
            key: notesKey,
            icon: const Icon(Icons.note, size: 40),
            label: AppLocalizations.of(context)!.notes,
          ),
          BottomNavigationBarItem(
            //LISTAS
            key: listsKey,
            icon: const Icon(Icons.list, size: 40),
            label: AppLocalizations.of(context)!.lists,
          ),
          BottomNavigationBarItem(
            //INFO DEL GRUPO
            key: infoKey,
            icon: const Icon(Icons.group, size: 40),
            label: AppLocalizations.of(context)!.group_info,
          ),
        ],
        //Control de selección de sección
        onTap: (index) {
          setState(() {
            _selectedIndexBottom = index;
          });
        },
      ),

      ///Subpantalla activa
      body: SafeArea(
        key: lastKey,
        ///Animación de transición entre subpantallas
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(1, 0),
              end: const Offset(0, 0),
            ).animate(animation);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          child: selectedSubscreen[_selectedIndexBottom],
        ),
      ),

      /// Botón flotante con speedDial para añadir elementos al grupo (eventos, notas y listas)
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          ///SpeedDial para añadir eventos
          SpeedDialChild(
            child: const Icon(Icons.event),
            label: AppLocalizations.of(context)!.add_event,
            backgroundColor: AppColors.calendarPrimary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventCreatorScreen(),
                ),
              );
            },
          ),

          ///SpeedDial para añadir notas
          SpeedDialChild(
            child: const Icon(Icons.note_add),
            label: AppLocalizations.of(context)!.add_note,
            backgroundColor: AppColors.notesPrimary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteCreatorScreen(
                    groupUID: widget.groupUID,
                    groupName: widget.groupName,
                  ),
                ),
              );
            },
          ),

          ///SpeedDial para añadir listas
          SpeedDialChild(
            child: const Icon(Icons.list_alt),
            label: AppLocalizations.of(context)!.add_list,
            backgroundColor: AppColors.listsPrimary,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  ///Formulario creación listas
                  return AlertDialog(
                    //Diálogo de creación de lista (Solo nombre)
                    title: Text(AppLocalizations.of(context)!.new_list),

                    ///Título de la lista
                    content: TextField(
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.listsPrimary,
                          ),
                        ),
                        border: const UnderlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.title,
                      ),
                      onChanged: (value) => _listTitle = value,
                    ),
                    actions: [
                      ///Botón "Descartar"
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.discard),
                      ),

                      ///Botón "Guardar"
                      TextButton(
                        onPressed: () {
                          if (_listTitle == "") {
                            //Comprobamos que no esté vacío el nombre
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.error_title_required,
                                ),
                              ),
                            );
                          } else {
                            //Creamos la lista
                            newList(widget.groupUID, _listTitle);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Detecta si el usuario ha sido expulsado del grupo.
  ///
  /// Si ya no pertenece:
  /// - Redirige a home
  /// - Muestra aviso informativo
  void _handleKick() {
    final GroupProvider provider = context.read<GroupProvider>();
    if (!provider.isMember) {
      //Si ha sido expulsado, lo devolvemos al MainScreen
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        "/home",
        (route) => false,
      );

      Future.microtask(() {
        //Mostramos aviso al usuario de que ha sido expulsado o el grupo ha sido eliminado
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (_) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.notif_group_removal_title,
              ),
              content: Text(
                AppLocalizations.of(context)!.notif_group_removal_content,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(navigatorKey.currentContext!),
                  child: Text(AppLocalizations.of(context)!.accept),
                ),
              ],
            );
          },
        );
      });
    }
  }

  /// Muestra la guía interactiva del grupo (solo primera vez).
  Future<void> showTutorial() async {
    int counter = 0;
    TutorialCoachMark(
      alignSkip: Alignment.topRight,
      textSkip: AppLocalizations.of(context)!.skip,
      textStyleSkip: TextStyle(color: AppColors.primary, fontSize: 20),
      onClickTarget: (target) {
        setState(() {
          //Control de las subpantallas conforme pase el tutorial
          if (counter < 3) {
            counter++;
            _selectedIndexBottom = counter;
          } else if (counter == 3) {
            _selectedIndexBottom = 0;
            counter++;
          }
        });
      },
      targets: [
        ///Paso 1: Calendario
        TargetFocus(
          identify: "calendar",
          keyTarget: calendarKey,
          enableTargetTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Text(
                AppLocalizations.of(context)!.tutorial_calendar,
                style: AppStyles.tutorialStyle,
              ),
            ),
          ],
        ),

        ///Paso 2: Notas
        TargetFocus(
          identify: "notes",
          keyTarget: notesKey,
          enableTargetTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Text(
                AppLocalizations.of(context)!.tutorial_notes,
                style: AppStyles.tutorialStyle,
              ),
            ),
          ],
        ),

        ///Paso 3: Listas
        TargetFocus(
          identify: "lists",
          keyTarget: listsKey,
          enableTargetTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Text(
                AppLocalizations.of(context)!.tutorial_lists,
                style: AppStyles.tutorialStyle,
              ),
            ),
          ],
        ),

        ///Paso 4: Info del grupo
        TargetFocus(
          identify: "info",
          keyTarget: infoKey,
          enableTargetTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Text(
                AppLocalizations.of(context)!.tutorial_info,
                style: AppStyles.tutorialStyle,
              ),
            ),
          ],
        ),

        ///Paso 5: Fin de la guía
        TargetFocus(
          identify: "lastKey",
          keyTarget: lastKey,
          enableTargetTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: MediaQuery.of(context).size.height * 0.35,
              ),
              child: Container(
                padding: const EdgeInsetsGeometry.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.tutorial_last,
                  style: TextStyle(color: AppColors.primary, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ],
    ).show(context: context);
    //Guardamos el tutorial como completado para el usuario
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("group_tutorial", true);
  }
}
