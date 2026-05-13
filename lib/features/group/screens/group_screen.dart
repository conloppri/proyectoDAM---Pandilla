//Básicos
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pandilla/features/lists/screens/listview_screen.dart';
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
import 'package:pandilla/features/calendar/screens/event_creator_screen.dart';
import 'package:pandilla/features/group/screens/info_editor.dart';
import 'package:pandilla/features/notes/screens/note_creator_screen.dart';
import 'package:pandilla/features/calendar/screens/calendar_subscreen.dart';
import 'package:pandilla/features/lists/screens/lists_subscreen.dart';
import 'package:pandilla/features/group/screens/info_subscreen.dart';
import 'package:pandilla/features/notes/screens/notes_subscreen.dart';
//Providers y servicios
import 'package:pandilla/core/services/navigator_key.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';

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

/// Estado de la pantalla del grupo [GroupScreen]
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
    if(tutorialCompleted==null || !tutorialCompleted!){
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
  ///
  /// La subpantalla a mostrar se selecciona mediante
  /// la barra de navegación baja, cuyo index selecciona
  /// la pantalla de la lista.
  ///
  /// Tiene un FloatingActionButton para añadir elementos al grupo,
  /// común a todas las subpantallas.
  ///
  /// Tiene menú en la AppBar para gestionar el grupo, solo para
  /// administradores.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    //Controlamos si el usuario activo es administrador del grupo
    bool? isAdmin = context.watch<GroupProvider>().isAdmin;

    /// Subpantallas del grupo según pestaña seleccionada.
    List selectedSubscreen = [
      const CalendarSubscreen(),
      const NotesSubscreen(),
      const ListsSubscreen(),
      InfoSubscreen(groupUID: widget.groupUID),
    ];

    return Stack(
      children: [
        //background de pantalla
        Positioned.fill(child: Image.asset("assets/images/app_background.png", fit: BoxFit.cover)),
        Scaffold(
          appBar: AppBar(
            title: Text(widget.groupName, style: AppStyles.appBarTitle),
            backgroundColor: primaryColors[_selectedIndexBottom],
            foregroundColor: Colors.white,
            actions: [
              /// Menú de opciones de gestión del grupo, solo para administradores
              if (isAdmin!)
              PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: "edit",
                      child: Text(loc.edit_group_info),
                    ), //Editar grupo => Solo admins
                    PopupMenuItem(
                      value: "delete",
                      child: Text(
                        loc.delete_group,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ), //Elimiar grupo => Solo admins
                ],
                //Control de elección del popMenu
                onSelected: (value) {
                  if (value == "delete") {
                    //eliminar grupo
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          //Advertencia de si está seguro de eliminar
                          title: Text(loc.delete_group),
                          content: Text(
                            loc.warning_group_removal,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(loc.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteGroup(widget.groupUID);
                                Navigator.pushReplacementNamed(context, "/home");
                                Navigator.pushReplacementNamed(context, "/home");
                              },
                              child: Text(
                                loc.remove,
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
                label: loc.calendar,
              ),
              BottomNavigationBarItem(
                //NOTAS
                key: notesKey,
                icon: const Icon(Icons.note, size: 40),
                label: loc.notes,
              ),
              BottomNavigationBarItem(
                //LISTAS
                key: listsKey,
                icon: const Icon(Icons.list, size: 40),
                label: loc.lists,
              ),
              BottomNavigationBarItem(
                //INFO DEL GRUPO
                key: infoKey,
                icon: const Icon(Icons.group, size: 40),
                label: loc.group_info,
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
                label: loc.add_event,
                backgroundColor: AppColors.calendarPrimary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventCreatorScreen(initialDate: DateTime.now(),),
                    ),
                  );
                },
              ),

              ///SpeedDial para añadir notas
              SpeedDialChild(
                child: const Icon(Icons.note_add),
                label: loc.add_note,
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
                label: loc.add_list,
                backgroundColor: AppColors.listsPrimary,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      ///Formulario creación listas
                      return AlertDialog(
                        //Diálogo de creación de lista (Solo nombre)
                        title: Text(loc.new_list),

                        ///Título de la lista
                        content: TextField(
                          maxLength: 20,
                          maxLines: 1,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.listsPrimary,
                              ),
                            ),
                            border: const UnderlineInputBorder(),
                            labelText: loc.title,
                          ),
                          onChanged: (value) => _listTitle = value,
                        ),
                        actions: [
                          ///Botón "Descartar"
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(loc.discard),
                          ),

                          ///Botón "Guardar"
                          TextButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              if (_listTitle == "") {
                                //Comprobamos que no esté vacío el nombre
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.error_title_required,
                                    ),
                                  ),
                                );
                              } else {
                                //Intentamos crear la lista
                                try {
                                  String listID = await newList(widget.groupUID, _listTitle); //Si la crea, guardamos su id de referencia
                                  navigator.pop(); //Cerramos el dialogo
                                  final result = await navigator.push(MaterialPageRoute(builder: (context)=>ListviewScreen(title: _listTitle, uid: listID)));//pasamos ala vista de la lista
                                  if(result == true){
                                    setState(() {

                                    });
                                  }
                                } catch (e) {
                                  debugPrint("Error al guardar la lista: $e");
                                  messenger.showSnackBar(SnackBar(content: Text(loc.error_try_again)));
                                }
                              }
                            },
                            child: Text(loc.save),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Detecta si el usuario ha sido expulsado del grupo.
  ///
  /// Si ya no pertenece:
  /// - Redirige a home
  /// - Muestra aviso informativo
  void _handleKick() {
    final GroupProvider provider = context.read<GroupProvider>();
    final AppLocalizations loc = AppLocalizations.of(context)!;
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
                loc.notif_group_removal_title,
              ),
              content: Text(
                loc.notif_group_removal_content,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(navigatorKey.currentContext!),
                  child: Text(loc.accept),
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
    final AppLocalizations loc = AppLocalizations.of(context)!;
    int counter = 0;
    TutorialCoachMark(
      alignSkip: Alignment.topRight,
      textSkip: loc.skip,
      textStyleSkip: const TextStyle(color: AppColors.primary, fontSize: 20),
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
              child: Container(
                padding: const EdgeInsetsGeometry.all(12),
                decoration: AppStyles.tutorialBox,
                child: Text(
                  loc.tutorial_calendar,
                  style: AppStyles.tutorialTextStyle,
                ),
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
              child: Container(
                padding: const EdgeInsetsGeometry.all(12),
                decoration: AppStyles.tutorialBox,
                child: Text(
                  loc.tutorial_notes,
                  style: AppStyles.tutorialTextStyle,
                ),
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
              child: Container(
                padding: const EdgeInsetsGeometry.all(12),
                decoration: AppStyles.tutorialBox,
                child: Text(
                  loc.tutorial_lists,
                  style: AppStyles.tutorialTextStyle,
                ),
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
              child: Container(
                padding: const EdgeInsetsGeometry.all(12),
                decoration: AppStyles.tutorialBox,
                child: Text(
                  loc.tutorial_info,
                  style: AppStyles.tutorialTextStyle,
                ),
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
                decoration: AppStyles.tutorialBox,
                child: Text(
                  loc.tutorial_last,
                  style: AppStyles.tutorialTextStyle,
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
