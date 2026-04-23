import 'package:flutter/material.dart';
import 'package:pandilla/components/date_picker_widget.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';

class EventCreatorScreen extends StatefulWidget {
  const EventCreatorScreen({super.key});

  @override
  State<EventCreatorScreen> createState() => _EventCreatorScreenState();
}

class _EventCreatorScreenState extends State<EventCreatorScreen> {
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
        padding: const EdgeInsets.all(15),
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.new_event, style: AppStyles.title,),
            Container(
              decoration: BoxDecoration(
                color: AppColors.calendar_primary,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  spacing: 15,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendar_secondary,
                        labelStyle: TextStyle(color: AppColors.calendar_primary),
                        labelText: AppLocalizations.of(context)!.title,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(15)
                        )
                      ),
                      onChanged: (value) => _title = value,
                    ),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendar_secondary,
                        labelStyle: TextStyle(color: AppColors.calendar_primary),
                        labelText: AppLocalizations.of(context)!.description,
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15)
                        ),
                      ),
                      onChanged: (value) => _description = value,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DatePickerWidget(
                selectedDate: DateTime.now(),
                labelStyle: TextStyle(fontSize: 20),
                buttonColor: AppColors.calendar_primary,
                label: AppLocalizations.of(context)!.event_date,
                firstDate: DateTime(1900),
                lastDate: DateTime(DateTime.now().year + 50),
                onDateSelected: (date) => _date = date,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.calendar_primary,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  spacing: 15,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendar_secondary,
                        labelStyle: TextStyle(color: AppColors.calendar_primary),
                        labelText: AppLocalizations.of(context)!.location,
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15)
                        ),
                      ),
                      onChanged: (value) => _location = value,
                    ),
                    Row(
                      spacing: 15,
                      children: [
                        Text("${AppLocalizations.of(context)!.recurrence}: ", style: TextStyle(fontSize: 20),),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.calendar_secondary),
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
                          child: Text(recurrenceButton[_recSelected], style: TextStyle(fontSize: 15, color: AppColors.calendar_primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.discard,
                      style: TextStyle(color: AppColors.calendar_secondary, fontSize: 20),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      saveEvent(
                        groupUID!,
                        groupName,
                        _title,
                        _description,
                        _date,
                        _location,
                        _recurrence[_recSelected],
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: TextStyle(color: AppColors.calendar_secondary, fontSize: 20),
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
