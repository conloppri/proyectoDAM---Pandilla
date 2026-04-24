import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/paper_background.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:pandilla/screens/notes/note_editor_screen.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';

class NoteViewScreen extends StatefulWidget {
  final String noteID;
  const NoteViewScreen({super.key, required this.noteID});

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  final Map<String, Color> colors = {
    "pink": AppColors.pink_note,
    "purple": AppColors.purple_note,
    "blue": AppColors.blue_note,
    "green": AppColors.green_note,
    "yellow": AppColors.yellow_note,
  };
  final textStyle = TextStyle(fontSize: 18, height: 1.5);

  @override
  Widget build(BuildContext context) {
    String? groupUID = context.watch<GroupProvider>().groupUID;
    String? groupName = context.watch<GroupProvider>().groupName;
    bool? isAdmin = context.watch<GroupProvider>().isAdmin;
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName!, style: AppStyles.title),
        backgroundColor: AppColors.notes_primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getNote(groupUID!, widget.noteID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(child: Text("Error: ${snapshot.error}"));
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return Text(AppLocalizations.of(context)!.no_notes);
            Map<String, dynamic> noteInfo = snapshot.data!;
            DateTime _lastUpdate = noteInfo["lastUpdate"].toDate();
            String authorID = noteInfo["authorUID"];
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Card.filled(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.notes_primary, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: colors[noteInfo["color"]],
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: PaperBackground(
                          lineColor: Colors.black,
                          lineSpacing: textStyle.fontSize! * textStyle.height!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.created_by} ",
                                ),
                                Text(
                                  noteInfo["authorName"],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                if (isAdmin! || userUID == authorID)
                                  IconButton(
                                    onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NoteEditorScreen(
                                          noteID: widget.noteID,
                                          groupUID: groupUID,
                                        ),
                                      ),
                                    ),
                                    icon: Icon(Icons.edit, color: AppColors.notes_primary, size: 30,),
                                  ),
                                if (isAdmin || userUID == authorID)
                                  IconButton(
                                    onPressed: () async {
                                      final bool confirm = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.delete_note,
                                            ),
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.warning_delete_note,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  removeNote(
                                                    groupUID,
                                                    widget.noteID,
                                                  );
                                                  Navigator.pop(context, true);
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.remove,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.cancel,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if(confirm){
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: Icon(Icons.delete, color: AppColors.notes_primary, size: 30,),
                                  ),

                              ],
                            ),
                            SizedBox(height: 10),
                            Text(noteInfo["title"], style: AppStyles.title),
                            Text(noteInfo["body"], style: textStyle),
                            Spacer(),
                            Text(
                              "${AppLocalizations.of(context)!.last_update}: ${DateFormat("HH:mm dd/MM/yyyy", "es_ES").format(_lastUpdate)}",
                            ),
                          ],
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
    );
  }
}
