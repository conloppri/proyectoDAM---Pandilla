import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/date_picker_widget.dart';
import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
import '../../core/providers/group_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../l10n/app_localizations.dart';

class EventEditorScreen extends StatefulWidget {
  final String groupUID;
  final String eventID;
  const EventEditorScreen({super.key, required this.groupUID, required this.eventID});

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  DateTime _date = DateTime.now();
  final List _recurrence = ["unique", "weekly", "monthly", "yearly"];
  int _recSelected = 0;

  loadEventInfo() async {
    final data =await getEventInfo(widget.groupUID, widget.eventID);
    setState(() {
      _titleController.text = data["title"];
      _descController.text = data["description"];
      _locController.text = data["location"];
      _date = DateTime(data["year"], data["month"], data["day"]);
      _recSelected = _recurrence.indexOf(data["recurrence"]);
    });
  }

  @override
  void initState() {
    super.initState();
    loadEventInfo();
  }
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
            Text(AppLocalizations.of(context)!.edit_event, style: AppStyles.title,),
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
                      controller: _titleController,
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
                    ),
                    TextField(
                      controller: _descController,
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
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DatePickerWidget(
                selectedDate: _date,
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
                      controller: _locController,
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
                      editEvent(groupUID!, groupName, widget.eventID, _titleController.text, _descController.text, _locController.text, _recurrence[_recSelected], _date);
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
