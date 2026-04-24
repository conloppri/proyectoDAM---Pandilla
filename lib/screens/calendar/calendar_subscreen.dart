import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:pandilla/screens/calendar/event_editor_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_colors.dart';
import '../../core/event.dart';

class CalendarSubscreen extends StatefulWidget {
  const CalendarSubscreen({super.key});

  @override
  State<CalendarSubscreen> createState() => _CalendarSubscreenState();
}

class _CalendarSubscreenState extends State<CalendarSubscreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  @override
  Widget build(BuildContext context) {
    String? _groupUID = context.watch<GroupProvider>().groupUID;
    String? _groupName = context.watch<GroupProvider>().groupName;
    return StreamBuilder(
      stream: getEventsStream(_groupUID!, _groupName!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final events = snapshot.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.calendar_primary,
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: TableCalendar<Event>(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(1950, 1, 1),
                  lastDay: DateTime(2050, 12, 31),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableCalendarFormats: {
                    CalendarFormat.month: AppLocalizations.of(context)!.month,
                    CalendarFormat.week: AppLocalizations.of(context)!.week,
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _format = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: _format,
                  locale: Localizations.localeOf(context).toString(),
                  eventLoader: (day) => _getEventsForDay(day, events),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppColors.calendar_secondary),
                    weekendStyle: TextStyle(color: AppColors.calendar_primary)
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(fontSize: 20),
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(
                      color: AppColors.calendar_primary,
                      fontSize: 20,
                    ),
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.calendar_secondary,
                    ),
                    selectedTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
                    todayTextStyle: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.calendar_primary,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = selectedDay;
                    });
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                ),
              ),
            ),
            Text(
              _format == CalendarFormat.month
                  ? DateFormat('dd/MM/yyyy').format(_focusedDay)
                  : AppLocalizations.of(context)!.week_events,
              style: TextStyle(
                color: AppColors.calendar_primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,

                children: _format == CalendarFormat.month
                    ? _getDayEventList(_getEventsForDay(_selectedDay!, events))
                    : _getEventsForWeek(_selectedDay!, events),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getDayEventList(List<Event> events) {
    String? groupUID = context.watch<GroupProvider>().groupUID;
    bool? isAdmin = context.read<GroupProvider>().isAdmin;
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    List<Widget> eventList = [];
    for (Event event in events) {
      eventList.add(
        Card.filled(
          color: AppColors.calendar_secondary,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 0, bottom: 12, left: 12, right: 12),
            child: Column(
              spacing: 5,
              children: [
                Row(
                  children: [
                    Text("   ${AppLocalizations.of(context)!.created_by} ",style: TextStyle(color: Colors.black)),
                    Text(event.authorName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                    const Spacer(),
                    if(isAdmin!||userUID == event.authorID)IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>EventEditorScreen(groupUID: groupUID!, eventID: event.id))), icon: Icon(Icons.edit, color: AppColors.calendar_primary,)),
                    if(isAdmin||userUID == event.authorID)IconButton(onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.delete_event),
                          content: Text(AppLocalizations.of(context)!.warning_delete_event),
                          actions: [
                            TextButton(onPressed: (){
                              removeNote(groupUID!, event.id);
                              Navigator.pop(context);
                            }, child: Text(AppLocalizations.of(context)!.remove)),
                            TextButton(onPressed: ()=>Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel))
                          ],
                        );
                      });
                    }, icon: Icon(Icons.delete ,color: AppColors.calendar_primary))
                  ],
                ),
                Text(
                  event.title,
                  style: TextStyle(color: AppColors.calendar_primary, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                event.description.isNotEmpty
                    ? Text(event.description,style: TextStyle(color: Colors.black),)
                    : Text(AppLocalizations.of(context)!.no_description,style: TextStyle(color: Colors.black)),
                event.location.isNotEmpty
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.pin_drop, color: Colors.red,), Text(event.location,style: TextStyle(color: Colors.black))])
                    : Text(AppLocalizations.of(context)!.no_location,style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),
      );
    }
    if(eventList.isEmpty){
      eventList.add(Center(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(AppLocalizations.of(context)!.no_event_this_day),
      )));
    }
    return eventList;
  }

  List<Widget> _getEventsForWeek(DateTime day, List<Event> events) {
    List<Event> weekEvents = events.where((event) {
      final eventDate = event.date;
      int weekday = day.weekday;
      int firstDay =
          day.day - weekday + 1; //Tomamos el primer día de la semana
      int lastDay = day.day + (7 - weekday); //Tomamos el último

      if (event.recurrence == "unique" &&
          eventDate.month == day.month &&
          eventDate.year == day.year) {
        //Comprobamos si esta entre ambos
        return eventDate.day >= firstDay && eventDate.day <= lastDay;
      }

      if (event.recurrence == "yearly" && eventDate.month == day.month) {
        return eventDate.day >= firstDay && eventDate.day <= lastDay;
      }
      return false;
    }).toList();
    List<Widget> eventList = [];
    String? groupUID = context.watch<GroupProvider>().groupUID;
    bool? isAdmin = context.read<GroupProvider>().isAdmin;
    weekEvents.sort((a,b)=>a.date.compareTo(b.date));
    for (Event event in weekEvents) {
      eventList.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onLongPress: () {
              String? userUID = FirebaseAuth.instance.currentUser?.uid;
              if(isAdmin! || userUID == event.authorID){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.delete_event,),
                    content: Text(AppLocalizations.of(context)!.warning_delete_event),
                    actions: [
                      TextButton(onPressed: (){
                        removeEvent(groupUID!, event.id);
                        Navigator.pop(context);
                      }, child: Text(AppLocalizations.of(context)!.remove)),
                      TextButton(onPressed: ()=>Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel))
                    ],
                  );
                });
              }
            },
            tileColor: AppColors.calendar_secondary,
            title: Text(
              "${DateFormat('dd/MM').format(event.date)} - ${event.title}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Text("${AppLocalizations.of(context)!.created_by} ${event.authorName}", style: TextStyle(color: Colors.black)),
                const Spacer(),
                if(isAdmin!||userUID == event.authorID)IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>EventEditorScreen(groupUID: groupUID!, eventID: event.id))), icon: Icon(Icons.edit, color: AppColors.calendar_primary,)),
                if(isAdmin||userUID == event.authorID)IconButton(onPressed: (){
                  showDialog(context: context, builder: (context){
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.delete_event),
                      content: Text(AppLocalizations.of(context)!.warning_delete_event),
                      actions: [
                        TextButton(onPressed: (){
                          removeNote(groupUID!, event.id);
                          Navigator.pop(context);
                        }, child: Text(AppLocalizations.of(context)!.remove)),
                        TextButton(onPressed: ()=>Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel))
                      ],
                    );
                  });
                }, icon: Icon(Icons.delete ,color: AppColors.calendar_primary))
              ],
            ),
          ),
        ),
      );
    }
    return eventList;
  }

  List<Event> _getEventsForDay(DateTime day, List<Event> events) {
    return events.where((event) {
      final eventDate = event.date;

      //Evento puntual
      if (event.recurrence == "unique") return isSameDay(eventDate, day);
      //Evento semanal
      if (event.recurrence == "weekly") {
        return eventDate.weekday == day.weekday &&
            (isSameDay(eventDate, day) || eventDate.isBefore(day));
      }
      //Evento mensual
      if (event.recurrence == "monthly") {
        return eventDate.day == day.day &&
            (isSameDay(eventDate, day) || eventDate.isBefore(day));
      }
      //Evento anual
      if (event.recurrence == "yearly") {
        return eventDate.day == day.day &&
            eventDate.month == day.month &&
            (isSameDay(eventDate, day) || eventDate.isBefore(day));
      }

      return false;
    }).toList();
  }
}
