import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/paper_background.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:pandilla/screens/notes/note_editor_screen.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';

class NoteViewScreen extends StatefulWidget {
  final String noteID;
  NoteViewScreen({super.key, required this.noteID});

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
  final textStyle = TextStyle(
    fontSize: 18,
      height: 1.5
  );

  @override
  Widget build(BuildContext context) {
    String? _groupUID = context.watch<GroupProvider>().groupUID;
    String? _groupName = context.watch<GroupProvider>().groupName;
    bool? _isAdmin = context.watch<GroupProvider>().isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName!, style: AppStyles.title),
        backgroundColor: AppColors.notes_primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isAdmin!) IconButton(onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NoteEditorScreen(noteID: widget.noteID, groupUID: _groupUID!,))), icon: Icon(Icons.edit)),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getNote(_groupUID!, widget.noteID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(child: Text("Error: ${snapshot.error}"));
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return Text(AppLocalizations.of(context)!.no_notes);
            Map<String, dynamic> noteInfo = snapshot.data!;
            DateTime _lastUpdate = noteInfo["createAt"].toDate();
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Card.filled(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: AppColors.notes_primary,
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  color: colors[noteInfo["color"]],
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: PaperBackground(
                            lineColor: Colors.black,
                            lineSpacing: textStyle.fontSize! * textStyle.height!,
                          )),
                      Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("${AppLocalizations.of(context)!.created_by} ${noteInfo["authorName"]}"),
                          ),
                          SizedBox(height: 10),
                          Text(noteInfo["title"], style: AppStyles.title),
                          Text(noteInfo["body"], style: textStyle,),
                          Spacer(),
                          Text(
                            "${AppLocalizations.of(context)!.last_update}: ${DateFormat("HH:mm dd/MM/yyyy", "es_ES").format(_lastUpdate)}",
                          ),
                        ],
                      ),
                    )],
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
