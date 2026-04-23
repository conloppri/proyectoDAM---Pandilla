import 'package:flutter/material.dart';
import 'package:pandilla/components/color_picker.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/services/firebase_service.dart';
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
  
  BoxDecoration boxDecoration = BoxDecoration(
      color: AppColors.notes_primary,
      borderRadius: BorderRadius.circular(12)
  );
  
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
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.new_note,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.notes_primary,
              ),
            ),
            Container(
              padding: EdgeInsetsGeometry.all(20),
              decoration: boxDecoration,
              child: TextField(
                maxLength: 15,
                decoration: InputDecoration(
                  filled: true,
                 fillColor: AppColors.notes_secondary,
                 enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.notes_primary),
                   borderRadius: BorderRadius.circular(10)
                  ),
                  labelText: AppLocalizations.of(context)!.title,
                ),
                onChanged: (value) => _title = value,
              ),
            ),

            Container(
              padding: const EdgeInsetsGeometry.all(20),
              decoration: boxDecoration,
              child: TextField(
                maxLength: 300,
                minLines: 8,
                maxLines: 20,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.notes_secondary,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.notes_primary),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  labelText: AppLocalizations.of(context)!.body_note,
                ),
                onChanged: (value) => _description = value,
              ),
            ),
            Container(
              padding: const EdgeInsetsGeometry.all(12),
              decoration: boxDecoration,
              child: Column(
                spacing: 10,
                children: [
                  Text(AppLocalizations.of(context)!.note_color, style: TextStyle(color: Colors.white, fontSize: 15),),
                  ColorPicker(
                    onColorSelected: (color) => _selectedColor = color,
                    selectedColor: _selectedColor,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.discard,
                    style: TextStyle(
                      color: AppColors.notes_secondary,
                      fontSize: 20,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_title == "" || _description == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.all_fields_required,
                          ),
                        ),
                      );
                    } else {
                      String? groupUID = context.read<GroupProvider>().groupUID;

                      createNote(
                        groupUID,
                        _title,
                        _description,
                        _selectedColor,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(
                      color: AppColors.notes_secondary,
                      fontSize: 20,
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
