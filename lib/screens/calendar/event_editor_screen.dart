import 'package:flutter/material.dart';
import 'package:pandilla/components/date_picker_widget.dart';
import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';

class EventEditorScreen extends StatefulWidget {
  const EventEditorScreen({super.key});

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  String _title = "";
  DateTime _date = DateTime.now();
  String _description = "";
  String _location = "";
  final List _recurrence = ["unique", "weekly", "monthly", "yearly"];

  int _recSelected = 0;
  @override
  Widget build(BuildContext context) {
    final List recurrenceButton = [
      AppLocalizations.of(context)!.one_time,
      AppLocalizations.of(context)!.weekly,
      AppLocalizations.of(context)!.monthly,
      AppLocalizations.of(context)!.yearly,
    ];
    String? groupUID = context.watch<GroupProvider>().groupUID;
    String? groupName = context.watch<GroupProvider>().groupName;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName!),
        backgroundColor: AppColors.calendar_primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(AppLocalizations.of(context)!.new_event),
            TextField(
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.calendar_primary),
                ),
                labelText: AppLocalizations.of(context)!.title,
              ),
              onChanged: (value) => _title = value,
            ),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.description,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.calendar_primary),
                ),
              ),
              onChanged: (value) => _description = value,
            ),
            DatePickerWidget(
              label: AppLocalizations.of(context)!.event_date,
              firstDate: DateTime(1900),
              lastDate: DateTime(DateTime.now().year + 50),
              onDateSelected: (date) => _date = date,
            ),
            TextField(
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: AppLocalizations.of(context)!.location,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.calendar_primary),
                ),
              ),
              onChanged: (value) => _location = value,
            ),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.recurrence),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.recurrence_dialog_title),
                        content: Container(
                          width: double.maxFinite,
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                title: Text(recurrenceButton[0]),
                                onTap: () {
                                  setState(() {
                                    _recSelected = 0;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(recurrenceButton[1]),
                                onTap: () {
                                  setState(() {
                                    _recSelected = 1;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(recurrenceButton[2]),
                                onTap: () {
                                  setState(() {
                                    _recSelected = 2;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(recurrenceButton[3]),
                                onTap: () {
                                  setState(() {
                                    _recSelected = 3;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(recurrenceButton[_recSelected]),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.discard,
                    style: TextStyle(color: AppColors.primary, fontSize: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      saveEvent(
                        groupUID!,
                        _title,
                        _description,
                        _date,
                        _location,
                        _recurrence[_recSelected],
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(color: AppColors.primary, fontSize: 20),
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
