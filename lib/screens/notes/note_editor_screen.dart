import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/color_picker.dart';
import 'package:pandilla/screens/notes/note_view_screen.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
import '../../core/firebase_service.dart';
import '../../core/group_provider.dart';

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
    // TODO: implement initState
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
            child: Text("Guardar"),
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("Creada por ${noteInfo["authorName"]}"),
                    ),
                    SizedBox(height: 10),
                    TextField(controller: _titleController),
                    TextField(
                      controller: _bodyController,
                      minLines: 5,
                      maxLines: 10,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                    ColorPicker(
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      selectedColor: _selectedColor,
                    ),
                    Spacer(),
                    Text("última actualización: $_lastUpdate}"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
