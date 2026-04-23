import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/screens/notes/note_view_screen.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';

class NoteComponent extends StatefulWidget {
  final String title;
  final String body;
  final String color;
  final String author;
  final DateTime lastUpdate;
  final String noteID;
  final String authorID;
  const NoteComponent({
    super.key,
    required this.title,
    required this.body,
    required this.color,
    required this.author,
    required this.lastUpdate,
    required this.noteID,
    required this.authorID,
  });

  @override
  State<NoteComponent> createState() => _NoteComponentState();
}

class _NoteComponentState extends State<NoteComponent> {
  final Map<String, Color> colors = {
    "pink": AppColors.pink_note,
    "purple": AppColors.purple_note,
    "blue": AppColors.blue_note,
    "green": AppColors.green_note,
    "yellow": AppColors.yellow_note,
  };
  @override
  Widget build(BuildContext context) {
    String? groupUID = context.watch<GroupProvider>().groupUID;
    bool? isAdmin = context.read<GroupProvider>().isAdmin;
    return Card.filled(
      color: colors[widget.color],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text("${AppLocalizations.of(context)!.created_by} ${widget.author}", style: TextStyle(color: Colors.black),),
          ),
          ListTile(
            title: Text(widget.title, style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.black)),
            subtitle: Text(
              widget.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            onTap: () =>Navigator.push(context, MaterialPageRoute(builder: (context)=>NoteViewScreen(noteID: widget.noteID))),
            onLongPress: () {
              String? userUID = FirebaseAuth.instance.currentUser?.uid;
              if(isAdmin! || userUID == widget.authorID){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.delete_note),
                    content: Text(AppLocalizations.of(context)!.warning_delete_note),
                    actions: [
                      TextButton(onPressed: (){
                        removeNote(groupUID!, widget.noteID);
                        Navigator.pop(context);
                      }, child: Text(AppLocalizations.of(context)!.remove)),
                      TextButton(onPressed: ()=>Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel))
                    ],
                  );
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "${DateFormat("HH:mm dd/MM/yyyy").format(widget.lastUpdate)}",
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
