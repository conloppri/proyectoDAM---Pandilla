
import 'package:flutter/material.dart';
import 'package:pandilla/components/color_picker.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/group_provider.dart';
import 'package:provider/provider.dart';

class NoteCreatorScreen extends StatefulWidget {
  final String groupUID;
  final String groupName;
  NoteCreatorScreen({
    super.key,
    required this.groupUID,
    required this.groupName,
  });

  @override
  State<NoteCreatorScreen> createState() => _NoteCreatorScreenState();
}

class _NoteCreatorScreenState extends State<NoteCreatorScreen> {
  String _title = "";
  String _description = "";
  String _selectedColor = "pink";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: AppColors.notes_primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("AÑADIR NUEVA NOTA"),
            TextField(
              maxLength: 15,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.notes_primary),
                ),
                label: Text("Título"),
              ),
              onChanged: (value) => _title = value,
            ),
            SizedBox(height: 20),
            TextField(
              minLines: 10,
              maxLines: 20,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.notes_primary),
                ),
                border: OutlineInputBorder(),
                label: Text("Escribe tu nota..."),
              ),
              onChanged: (value)=>_description = value,
            ),
            Text("Elige el color para tu nota"),
            ColorPicker(onColorSelected: (color)=>_selectedColor = color, selectedColor: _selectedColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "<< Descartar",
                    style: TextStyle(
                      color: AppColors.notes_primary,
                      fontSize: 30,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if(_title == "" || _description == ""){
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Todos los campos son obligatorios.")));
                    }else {
                      String? _groupUID = context
                          .read<GroupProvider>()
                          .groupUID;

                      createNote(_groupUID, _title, _description, _selectedColor);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Guardar >>",
                    style: TextStyle(
                      color: AppColors.notes_primary,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
