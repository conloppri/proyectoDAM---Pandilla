
import 'package:flutter/material.dart';
import 'package:pandilla/components/color_picker.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

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
            Text(AppLocalizations.of(context)!.new_note),
            TextField(
              maxLength: 15,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.notes_primary),
                ),
                label: Text(AppLocalizations.of(context)!.title),
              ),
              onChanged: (value) => _title = value,
            ),
            const SizedBox(height: 20),
            TextField(
              minLines: 10,
              maxLines: 20,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.notes_primary),
                ),
                border: const OutlineInputBorder(),
                label: Text(AppLocalizations.of(context)!.body_note),
              ),
              onChanged: (value)=>_description = value,
            ),
            Text(AppLocalizations.of(context)!.note_color),
            ColorPicker(onColorSelected: (color)=>_selectedColor = color, selectedColor: _selectedColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.discard,
                    style: TextStyle(
                      color: AppColors.notes_primary,
                      fontSize: 30,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if(_title == "" || _description == ""){
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.all_fields_required)));
                    }else {
                      String? groupUID = context
                          .read<GroupProvider>()
                          .groupUID;

                      createNote(groupUID, _title, _description, _selectedColor);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.save,
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
