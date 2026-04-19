import 'package:flutter/material.dart';
import 'package:pandilla/components/date_picker_widget.dart';
import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/group_provider.dart';
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
  final List _recurrenceButton = [
    "Una vez",
    "Semanalmente",
    "Mensualmente",
    "Anualmente",
  ];
  int _recSelected = 0;
  @override
  Widget build(BuildContext context) {
    String? _groupUID = context.watch<GroupProvider>().groupUID;
    String? _groupName = context.watch<GroupProvider>().groupName;
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName!),
        backgroundColor: AppColors.calendar_primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("AÑADIR EVENTO"),
            TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.calendar_primary),
                ),
                labelText: "Título del evento",
              ),
              onChanged: (value) => _title = value,
            ),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Descripción del evento",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.calendar_primary),
                ),
              ),
              onChanged: (value) => _description = value,
            ),
            DatePickerWidget(
              label: 'Fecha del evento: ',
              firstDate: DateTime(1900),
              lastDate: DateTime(DateTime.now().year + 50),
              onDateSelected: (date) => _date = date,
            ),
            TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Location (opcional)",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.calendar_primary),
                ),
              ),
              onChanged: (value) => _location = value,
            ),
            Row(
              children: [
                Text("Repetir: "),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("¿Cuándo repetir el evento?"),
                        content: Container(
                          width: double.maxFinite,
                          constraints: BoxConstraints(maxHeight: 300),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                title: Text(_recurrenceButton[0]),
                                onTap: () {
                                  setState(() {
                                    _recSelected = 0;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(_recurrenceButton[1]),
                                onTap: () {
                                  setState(() {
                                    _recSelected = 1;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(_recurrenceButton[2]),
                                onTap: () {
                                  setState(() {
                                    _recSelected = 2;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(_recurrenceButton[3]),
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
                  child: Text(_recurrenceButton[_recSelected]),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "<< Descartar",
                    style: TextStyle(color: AppColors.primary, fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      saveEvent(
                        _groupUID!,
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
                    "Guardar >>",
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
