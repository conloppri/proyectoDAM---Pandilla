import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/color_picker.dart';
import 'package:pandilla/screens/notes/note_view_screen.dart';
import 'package:provider/provider.dart';

import '../../components/paper_background.dart';
import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
import '../../core/firebase_service.dart';
import '../../core/providers/group_provider.dart';
import '../../l10n/app_localizations.dart';

class NoteEditorScreen extends StatefulWidget {
  final String noteID;
  final String groupUID;
  const NoteEditorScreen({
    super.key,
    required this.noteID,
    required this.groupUID,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final Map<String, Color> colors = {
    "pink": AppColors.pink_note,
    "purple": AppColors.purple_note,
    "blue": AppColors.blue_note,
    "green": AppColors.green_note,
    "yellow": AppColors.yellow_note,
  };

  String _selectedColor = "";

  Map noteInfo = {};

  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();
  String _lastUpdate = "";

  final textStyle = TextStyle(
      fontSize: 18,
      height: 1.5
  );

  loadNote() async {
    noteInfo = await getNote(widget.groupUID, widget.noteID);
    DateTime date = noteInfo["createAt"].toDate();
    _lastUpdate = DateFormat("HH:mm dd/MM/yyyy", "es_ES").format(date);
    _titleController.text = noteInfo["title"];
    _bodyController.text = noteInfo["body"];
    _selectedColor = noteInfo["color"];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadNote();
  }

  @override
  Widget build(BuildContext context) {
    String? _groupUID = context.watch<GroupProvider>().groupUID;
    String? _groupName = context.watch<GroupProvider>().groupName;
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName!, style: AppStyles.title),
        backgroundColor: AppColors.notes_primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              updateNote(
                _groupUID!,
                widget.noteID,
                _titleController.text,
                _bodyController.text,
                _selectedColor,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteViewScreen(noteID: widget.noteID),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Card.filled(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.notes_primary, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              color: colors[_selectedColor],
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
                        child: Text(
                          "${AppLocalizations.of(context)!.created_by} ${noteInfo["authorName"]}",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(filled: false,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.notes_secondary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.notes_primary)
                        )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _bodyController,
                        style: TextStyle(color: Colors.black),
                        minLines: 5,
                        maxLines: 10,
                        decoration: InputDecoration(
                          filled: false,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.notes_secondary),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.notes_primary),
                            borderRadius: BorderRadius.circular(20)
                          )
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(AppLocalizations.of(context)!.note_color, style: TextStyle(color: Colors.black, fontSize: 15),),
                      ),
                      ColorPicker(
                        onColorSelected: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        selectedColor: _selectedColor,
                      ),
                      const Spacer(),
                      Text(
                        "${AppLocalizations.of(context)!.last_update} $_lastUpdate}",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
