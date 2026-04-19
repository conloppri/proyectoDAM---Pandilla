import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/group_provider.dart';
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
    return StreamBuilder(
      stream: getEventsStream(_groupUID!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final events = snapshot.data!;
        return Column(
          children: [
            TableCalendar<Event>(
              focusedDay: _focusedDay,
              firstDay: DateTime(1950, 1, 1),
              lastDay: DateTime(2050, 12, 31),
              startingDayOfWeek: StartingDayOfWeek.monday,
              locale: 'es_ES',
              availableCalendarFormats: const {
                CalendarFormat.month: "Mes",
                CalendarFormat.week: "Semana",
              },
              onFormatChanged: (format) {
                setState(() {
                  _format = format;
                });
              },
              calendarFormat: _format,
              eventLoader: (day) => _getEventsForDay(day, events),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(fontSize: 20),
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: AppColors.calendar_primary,
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
                selectedTextStyle: TextStyle(fontSize: 20, color: Colors.white),
                todayDecoration: BoxDecoration(color: Colors.white),
                todayTextStyle: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20,
                ),
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
            Text(
              _format == CalendarFormat.month
                  ? DateFormat('dd/MM/yyyy', 'es_ES').format(_focusedDay)
                  : "Eventos de la semana: ",
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

  List<Card> _getDayEventList(List<Event> events) {
    String? groupUID = context.watch<GroupProvider>().groupUID;
    bool? isAdmin = context.read<GroupProvider>().isAdmin;
    List<Card> eventList = [];
    for (Event event in events) {
      eventList.add(
        Card.filled(
          color: AppColors.calendar_secondary,
          child: GestureDetector(
            onLongPress: () {
              String? userUID = FirebaseAuth.instance.currentUser?.uid;
              if(isAdmin! || userUID == event.authorID){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: Text("Eliminar nota"),
                    content: Text("¿Estás seguro que quieres eliminar esta nota? Una vez eliminada no podrá recuperarse."),
                    actions: [
                      TextButton(onPressed: (){
                        removeNote(groupUID!, event.id);
                        Navigator.pop(context);
                      }, child: Text("Eliminar")),
                      TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancelar"))
                    ],
                  );
                });
              }
            },
            child: Column(
              children: [
                Text("Creada por ${event.authorName}"),
                Text(
                  event.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                event.description.isNotEmpty
                    ? Text(event.description)
                    : Text("Sin descripción"),
                event.location.isNotEmpty
                    ? Row(children: [Icon(Icons.pin_drop), Text(event.location)])
                    : Text("Sin localización"),
              ],
            ),
          ),
        ),
      );
    }
    return eventList;
  }

  List<ListTile> _getEventsForWeek(DateTime day, List<Event> events) {
    List<Event> weekEvents = events.where((event) {
      final eventDate = event.date;
      int weekday = day.weekday;
      int _firstDay =
          day.day - weekday + 1; //Tomamos el primer día de la semana
      int _lastDay = day.day + (7 - weekday); //Tomamos el último

      if (event.recurrence == "unique" &&
          eventDate.month == day.month &&
          eventDate.year == day.year) {
        //Comprobamos si esta entre ambos
        return eventDate.day >= _firstDay && eventDate.day <= _lastDay;
      }

      if (event.recurrence == "yearly" && eventDate.month == day.month) {
        return eventDate.day >= _firstDay && eventDate.day <= _lastDay;
      }
      return false;
    }).toList();
    List<ListTile> eventList = [];
    String? groupUID = context.watch<GroupProvider>().groupUID;
    bool? isAdmin = context.read<GroupProvider>().isAdmin;
    for (Event event in weekEvents) {
      eventList.add(
        ListTile(
          onLongPress: () {
            String? userUID = FirebaseAuth.instance.currentUser?.uid;
            if(isAdmin! || userUID == event.authorID){
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: Text("Eliminar nota"),
                  content: Text("¿Estás seguro que quieres eliminar esta nota? Una vez eliminada no podrá recuperarse."),
                  actions: [
                    TextButton(onPressed: (){
                      removeNote(groupUID!, event.id);
                      Navigator.pop(context);
                    }, child: Text("Eliminar")),
                    TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancelar"))
                  ],
                );
              });
            }
          },
          tileColor: AppColors.calendar_secondary,
          title: Text(
            "${DateFormat('dd/MM', 'es_ES').format(event.date)} - ${event.title}",
          ),
          subtitle: Text("Creado por ${event.authorName}"),
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
