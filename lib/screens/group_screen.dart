
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pandilla/components/left_drawer.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/core/services/navigator_key.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/screens/calendar/event_creator_screen.dart';
import 'package:pandilla/screens/group_info/info_editor.dart';
import 'package:pandilla/screens/notes/note_creator_screen.dart';
import 'package:pandilla/screens/calendar/calendar_subscreen.dart';
import 'package:pandilla/screens/lists/lists_subscreen.dart';
import 'package:pandilla/screens/group_info/info_subscreen.dart';
import 'package:pandilla/screens/notes/notes_subscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../core/providers/group_provider.dart';
import '../l10n/app_localizations.dart';

class GroupScreen extends StatefulWidget {
  final String groupName;
  final String groupUID;
  const GroupScreen({super.key, required this.groupUID, required this.groupName});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  int _selectedIndexBottom = 0;
  String _listTitle = "";
  List primaryColors = [
    AppColors.calendar_primary,
    AppColors.notes_primary,
    AppColors.lists_primary,
    AppColors.members_primary,
  ];
  List secondaryColors = [
    AppColors.calendar_secondary,
    AppColors.notes_secondary,
    AppColors.lists_secondary,
    AppColors.members_secondary,
  ];
  late final GroupProvider provider;

  //GLOBAL KEYS
  GlobalKey calendarKey = GlobalKey();
  GlobalKey notesKey = GlobalKey();
  GlobalKey listsKey = GlobalKey();
  GlobalKey infoKey = GlobalKey();
  GlobalKey lastKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    final String? userUID = FirebaseAuth.instance.currentUser?.uid;
    provider = context.read<GroupProvider>();
    provider.startListening(userUID!);

    provider.addListener(_handleKick);

    WidgetsBinding.instance.addPostFrameCallback((_){
      showTutorial();
    });
  }
  @override
  void dispose() {
    provider.removeListener(_handleKick);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    bool? isAdmin = context.watch<GroupProvider>().isAdmin;
    List selectedSubscreen = [
      const CalendarSubscreen(),
      const NotesSubscreen(),
      const ListsSubscreen(),
      InfoSubscreen(groupUID: widget.groupUID,),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: AppStyles.title,),
        backgroundColor: primaryColors[_selectedIndexBottom],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context)=>[
            if(isAdmin!) PopupMenuItem(value: "edit", child: Text(AppLocalizations.of(context)!.edit_group_info)),
            if(isAdmin) PopupMenuItem(value: "delete",child: Text(AppLocalizations.of(context)!.delete_group, style: const TextStyle(color: Colors.red),),),
             PopupMenuItem(value: "info", child: Text(AppLocalizations.of(context)!.about))
          ],
          onSelected: (value){
            if(value=="info"){
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.about),
                  content: Text("App desarrollada por Consuelo López Prieto para Proyecto Intermodular de DAM 2025/2026."),
                  actions: [
                    TextButton(onPressed: ()=> Navigator.pop(context), child: Text(AppLocalizations.of(context)!.close))
                  ],
                );
              });
            }
            if(value == "delete"){
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.delete_group),
                  content: Text(AppLocalizations.of(context)!.warning_group_removal),
                  actions: [
                    TextButton(onPressed: ()=> Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
                    TextButton(onPressed: (){
                      deleteGroup(widget.groupUID);
                      Navigator.pushReplacementNamed(context, "/home");
                      Navigator.pushReplacementNamed(context, "/home");
                    }, child: Text(AppLocalizations.of(context)!.remove, style: TextStyle(color: Colors.redAccent),)),
                  ],
                );
              });
            }
            if(value == "edit"){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>InfoEditor(groupUID: widget.groupUID, groupName: widget.groupName)) );
            }
          },)
        ],
      ),
      drawer: const LeftDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndexBottom,
        selectedItemColor: primaryColors[_selectedIndexBottom],
        unselectedItemColor: secondaryColors[_selectedIndexBottom],
        items:  [
          BottomNavigationBarItem(
            key: calendarKey,
            icon: Icon(Icons.calendar_month_outlined, size: 40),
            label: AppLocalizations.of(context)!.calendar,
          ),
          BottomNavigationBarItem(
            key: notesKey,
            icon: Icon(Icons.note, size: 40),
            label: AppLocalizations.of(context)!.notes,
          ),
          BottomNavigationBarItem(
            key: listsKey,
            icon: Icon(Icons.list, size: 40),
            label: AppLocalizations.of(context)!.lists,
          ),
          BottomNavigationBarItem(
            key: infoKey,
            icon: Icon(Icons.group, size: 40),
            label: AppLocalizations.of(context)!.group_info,
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndexBottom = index;
          });
        },
      ),
      body: SafeArea(
        key: lastKey,
          child: selectedSubscreen[_selectedIndexBottom]
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.event),
            label: AppLocalizations.of(context)!.add_event,
            backgroundColor: AppColors.calendar_primary,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> EventCreatorScreen()));

            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.note_add),
            label: AppLocalizations.of(context)!.add_note,
            backgroundColor: AppColors.notes_primary,
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
          SpeedDialChild(
            child: const Icon(Icons.list_alt),
            label:AppLocalizations.of(context)!.add_list,
            backgroundColor: AppColors.lists_primary,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.new_list),
                    content: TextField(
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.lists_primary,
                          ),
                        ),
                        border: const UnderlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.title,
                      ),
                      onChanged: (value) => _listTitle = value,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.discard),
                      ),
                      TextButton(
                        onPressed: (){
                          if (_listTitle == "")
                            {ScaffoldMessenger.of(
                            context,
                            ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.all_fields_required)));}
                          else {
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

  void _handleKick(){
    final GroupProvider provider = context.read<GroupProvider>();
    if(!provider.isMember){
      navigatorKey.currentState?.pushNamedAndRemoveUntil("/home", (route)=>false);

      Future.microtask((){
        showDialog(context: navigatorKey.currentContext!,
            builder: (_){
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.notif_group_removal_title),
            content: Text(AppLocalizations.of(context)!.notif_group_removal_content),
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(navigatorKey.currentContext!), child: Text(AppLocalizations.of(context)!.accept))
            ],
          );
            });
      });
    }
  }

  Future<void> showTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? completed = prefs.getBool("group_tutorial");
    if(completed == null || !completed) {
      int counter = 0;
      TutorialCoachMark(
          alignSkip: Alignment.topRight,
          textSkip: AppLocalizations.of(context)!.skip,
          textStyleSkip: TextStyle(color: AppColors.primary, fontSize: 20),
          onClickTarget: (target) {
            setState(() {
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
            TargetFocus(
                identify: "calendar",
                keyTarget: calendarKey,
                enableTargetTab: true,
                contents: [
                  TargetContent(
                      align: ContentAlign.custom,
                      customPosition: CustomTargetContentPosition(
                          top: MediaQuery
                              .of(context)
                              .size
                              .height * 0.5),
                      child: Text(
                        AppLocalizations.of(context)!.tutorial_calendar,
                        style: AppStyles.tutorialStyle,)
                  )
                ]
            ),
            TargetFocus(
                identify: "notes",
                keyTarget: notesKey,
                enableTargetTab: true,
                contents: [
                  TargetContent(
                      align: ContentAlign.custom,
                      customPosition: CustomTargetContentPosition(
                          top: MediaQuery
                              .of(context)
                              .size
                              .height * 0.5),
                      child: Text(AppLocalizations.of(context)!.tutorial_notes,
                        style: AppStyles.tutorialStyle,)
                  )
                ]
            ),
            TargetFocus(
                identify: "lists",
                keyTarget: listsKey,
                enableTargetTab: true,
                contents: [
                  TargetContent(
                      align: ContentAlign.custom,
                      customPosition: CustomTargetContentPosition(
                          top: MediaQuery
                              .of(context)
                              .size
                              .height * 0.5),
                      child: Text(AppLocalizations.of(context)!.tutorial_lists,
                        style: AppStyles.tutorialStyle,)
                  )
                ]
            ),
            TargetFocus(
                identify: "info",
                keyTarget: infoKey,
                enableTargetTab: true,
                contents: [
                  TargetContent(
                      align: ContentAlign.custom,
                      customPosition: CustomTargetContentPosition(
                          top: MediaQuery
                              .of(context)
                              .size
                              .height * 0.5),
                      child: Text(AppLocalizations.of(context)!.tutorial_info,
                        style: AppStyles.tutorialStyle,)
                  )
                ]
            ),
            TargetFocus(
                identify: "lastKey",
                keyTarget: lastKey,
                enableTargetTab: true,
                contents: [
                  TargetContent(
                      align: ContentAlign.custom,
                      customPosition: CustomTargetContentPosition(
                          top: MediaQuery
                              .of(context)
                              .size
                              .height * 0.35),
                      child: Container(
                          padding: const EdgeInsetsGeometry.all(12),
                          decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                              AppLocalizations.of(context)!.tutorial_last,
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 20)))
                  )
                ]
            ),
          ]
      ).show(context: context);
      prefs.setBool("group_tutorial", true);
    }
  }
}
