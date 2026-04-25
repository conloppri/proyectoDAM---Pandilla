//Básicos
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
//Componentes personalizados
import '../../core/event.dart';
//Estilos y colores
import '../../core/app_colors.dart';
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pandilla/core/services/firebase_service.dart';
//Servicios y providers
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
//Pantallas
import 'package:pandilla/screens/calendar/event_editor_screen.dart';

/// Subpantalla de calendario del grupo.
///
/// Permite visualizar los eventos del grupo en formato calendario,
/// así como consultar eventos por día o por semana.
///
/// Incluye:
/// - Vista mensual y semanal
/// - Marcadores de eventos en el calendario
/// - Listado de eventos según selección
/// - Opciones de edición y eliminación según permisos
class CalendarSubscreen extends StatefulWidget {
  const CalendarSubscreen({super.key});

  @override
  State<CalendarSubscreen> createState() => _CalendarSubscreenState();
}

/// Estado de la subpantalla de calendario.
///
/// Gestiona:
/// - Día enfocado actualmente
/// - Día seleccionado
/// - Formato del calendario (mes o semana)
/// - Filtrado y visualización de eventos
class _CalendarSubscreenState extends State<CalendarSubscreen> {
  /// Día actualmente enfocado en el calendario.
  DateTime _focusedDay = DateTime.now();

  /// Día seleccionado por el usuario.
  DateTime? _selectedDay = DateTime.now();

  /// Formato actual del calendario (mes o semana).
  CalendarFormat _format = CalendarFormat.month;

  /// Construye la interfaz de la subpantalla Calendario.
  ///
  /// Incluye:
  /// - Calendario con formato intercambiable "Mes"/"Semana"
  /// - Lista de eventos según día seleccionado
  /// - Lista de eventos semanales
  @override
  Widget build(BuildContext context) {
    /// Identificador del grupo actual.
    String? groupUID = context.watch<GroupProvider>().groupUID;

    /// Nombre del grupo actual.
    String? groupName = context.watch<GroupProvider>().groupName;

    /// Stream de eventos del grupo.
    return StreamBuilder(
      stream: getEventsStream(groupUID!, groupName!),
      builder: (context, snapshot) {

        ///Control de estados del Stream
        if (snapshot.connectionState == ConnectionState.waiting) {//Cargando
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) { //Con error
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if(!snapshot.hasData){
          return const Center(child: CircularProgressIndicator());
        }
        ///Carga de eventos
        final events = snapshot.data!;
        return Column(
          children: [

            /// Calendario principal
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.calendarPrimary,
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: TableCalendar<Event>(
                  /// Día enfocado
                  focusedDay: _focusedDay,
                  /// Rango permitido
                  firstDay: DateTime(1950, 1, 1),
                  lastDay: DateTime(2050, 12, 31),
                  /// Inicio de semana en lunes
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  /// Formatos disponibles
                  availableCalendarFormats: {
                    CalendarFormat.month: AppLocalizations.of(context)!.month,
                    CalendarFormat.week: AppLocalizations.of(context)!.week,
                  },
                  /// Cambio de formato (mes/semana)
                  onFormatChanged: (format) {
                    setState(() {
                      _format = format;
                    });
                  },
                  /// Cambio de página del calendario
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  /// Formato actual
                  calendarFormat: _format,
                  /// Idioma del calendario
                  locale: Localizations.localeOf(context).toString(),
                  /// Eventos por día (para marcadores)
                  eventLoader: (day) => _getEventsForDay(day, events),
                  /// Estilo de días de la semana
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppColors.calendarSecondary),
                    weekendStyle: TextStyle(color: AppColors.calendarPrimary)
                  ),
                  /// Estilo general del calendario
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(fontSize: 20),
                    markersMaxCount: 3,
                    markerDecoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(
                      color: AppColors.calendarPrimary,
                      fontSize: 20,
                    ),
                    selectedDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.calendarSecondary,
                    ),
                    selectedTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
                    todayTextStyle: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.calendarPrimary,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                  /// Selección de día
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = selectedDay;
                    });
                  },
                  /// Indica el día seleccionado
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                ),
              ),
            ),
            Text(
              /// Título según formato
              _format == CalendarFormat.month
                  ? DateFormat('dd/MM/yyyy').format(_focusedDay)
                  : AppLocalizations.of(context)!.week_events,
              style: const TextStyle(
                color: AppColors.calendarPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            /// Lista de eventos
            Expanded(
              child: ListView(
                shrinkWrap: true,
                /// Eventos según vista seleccionada
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
  /// Genera la lista de widgets para los eventos de un día concreto.
  ///
  /// Incluye:
  /// - Información del evento
  /// - Opciones de edición/eliminación si el usuario tiene permisos
  /// - Mensaje si no hay eventos
  List<Widget> _getDayEventList(List<Event> events) {
    /// Identificador del grupo
    String? groupUID = context.watch<GroupProvider>().groupUID;

    /// Indica si el usuario es administrador
    bool? isAdmin = context.read<GroupProvider>().isAdmin;

    /// UID del usuario actual
    String? userUID = FirebaseAuth.instance.currentUser?.uid;

    ///Lista de eventos listos para mostrar
    List<Widget> eventList = [];
    for (Event event in events) {
      eventList.add(
        Card.filled(
          color: AppColors.calendarSecondary,
          child: Padding(
            padding: const EdgeInsetsGeometry.only(top: 0, bottom: 12, left: 12, right: 12),
            child: Column(
              spacing: 5,
              children: [
                /// Cabecera del evento (autor y acciones)
                Row(
                  children: [
                    Text("   ${AppLocalizations.of(context)!.created_by} ",style: const TextStyle(color: Colors.black)),
                    Text(event.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                    const Spacer(),
                    /// Botón editar(Solo visible si eres el autor del evento o administrador del grupo)
                    if(isAdmin!||userUID == event.authorID)IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>EventEditorScreen(groupUID: groupUID!, eventID: event.id))), icon: const Icon(Icons.edit, color: AppColors.calendarPrimary,)),
                    /// Botón eliminar(Solo visible si eres el autor del evento o administrador del grupo)
                    if(isAdmin||userUID == event.authorID)IconButton(onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog( //Confirmación de eliminación
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
                    }, icon: const Icon(Icons.delete ,color: AppColors.calendarPrimary))
                  ],
                ),
                /// Título del evento
                Text(
                  event.title,
                  style: const TextStyle(color: AppColors.calendarPrimary, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                /// Descripción (Comprueba si está vacío para indicar al usuario)
                event.description.isNotEmpty
                    ? Text(event.description,style: const TextStyle(color: Colors.black),)
                    : Text(AppLocalizations.of(context)!.no_description,style: const TextStyle(color: Colors.black)),
                /// Ubicación (Comprueba si está vacío para indicar al usuario)
                event.location.isNotEmpty
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.pin_drop, color: Colors.red,), Text(event.location,style: const TextStyle(color: Colors.black))])
                    : Text(AppLocalizations.of(context)!.no_location,style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),
      );
    }
    /// Si no hay eventos
    if(eventList.isEmpty){
      eventList.add(Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(AppLocalizations.of(context)!.no_event_this_day),
      )));
    }
    return eventList;
  }

  /// Obtiene los eventos de una semana concreta.
  ///
  /// Filtra los eventos según:
  /// - Fecha
  /// - Tipo de recurrencia
  ///
  /// Devuelve una lista de widgets con los eventos ordenados.
  List<Widget> _getEventsForWeek(DateTime day, List<Event> events) {
    /// Filtrado de eventos de la semana
    List<Event> weekEvents = events.where((event) {
      final eventDate = event.date;
      int weekday = day.weekday;
      int firstDay =
          day.day - weekday + 1; //Tomamos el primer día de la semana
      int lastDay = day.day + (7 - weekday); //Tomamos el último

      if (event.recurrence == "unique" && //Evento único
          eventDate.month == day.month &&
          eventDate.year == day.year) {
        //Comprobamos si esta entre ambos
        return eventDate.day >= firstDay && eventDate.day <= lastDay;
      }

      if (event.recurrence == "yearly" && eventDate.month == day.month) { //anual
        return eventDate.day >= firstDay && eventDate.day <= lastDay;
      }
      return false;
    }).toList();
    /// Orden por fecha
    weekEvents.sort((a,b)=>a.date.compareTo(b.date));

    List<Widget> eventList = [];

    ///Info del grupo
    String? groupUID = context.watch<GroupProvider>().groupUID;
    bool? isAdmin = context.read<GroupProvider>().isAdmin;

    ///Creamos el componente que mostrará cada evento
    for (Event event in weekEvents) {
      eventList.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            tileColor: AppColors.calendarSecondary,
            /// Título con fecha
            title: Text(
              "${DateFormat('dd/MM').format(event.date)} - ${event.title}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            /// Información adicional
            subtitle: Row(
              children: [
                Text("${AppLocalizations.of(context)!.created_by} ${event.authorName}", style: const TextStyle(color: Colors.black)),
                const Spacer(),
                /// Botón editar(Solo visible si eres el autor del evento o administrador del grupo)
                if(isAdmin!||userUID == event.authorID)IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>EventEditorScreen(groupUID: groupUID!, eventID: event.id))), icon: const Icon(Icons.edit, color: AppColors.calendarPrimary,)),
                /// Botón eliminar(Solo visible si eres el autor del evento o administrador del grupo)
                if(isAdmin||userUID == event.authorID)IconButton(onPressed: (){
                  showDialog(context: context, builder: (context){
                    return AlertDialog( //Confirmación de eliminación
                      title: Text(AppLocalizations.of(context)!.delete_event),
                      content: Text(AppLocalizations.of(context)!.warning_delete_event),
                      actions: [
                        ///Botón Eliminar
                        TextButton(onPressed: (){
                          removeNote(groupUID!, event.id);
                          Navigator.pop(context);
                        }, child: Text(AppLocalizations.of(context)!.remove)),
                        ///Botón cancelar
                        TextButton(onPressed: ()=>Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel))
                      ],
                    );
                  });
                }, icon: const Icon(Icons.delete ,color: AppColors.calendarPrimary))
              ],
            ),
          ),
        ),
      );
    }
    return eventList;
  }

  /// Obtiene los eventos correspondientes a un día concreto.
  ///
  /// Tiene en cuenta la recurrencia del evento:
  /// - Único
  /// - Semanal
  /// - Mensual
  /// - Anual
  List<Event> _getEventsForDay(DateTime day, List<Event> events) {
    return events.where((event) {
      final eventDate = event.date;

      ///Evento puntual
      if (event.recurrence == "unique") return isSameDay(eventDate, day);
      ///Evento semanal
      if (event.recurrence == "weekly") {
        return eventDate.weekday == day.weekday &&
            (isSameDay(eventDate, day) || eventDate.isBefore(day));
      }
      ///Evento mensual
      if (event.recurrence == "monthly") {
        return eventDate.day == day.day &&
            (isSameDay(eventDate, day) || eventDate.isBefore(day));
      }
      ///Evento anual
      if (event.recurrence == "yearly") {
        return eventDate.day == day.day &&
            eventDate.month == day.month &&
            (isSameDay(eventDate, day) || eventDate.isBefore(day));
      }

      return false;
    }).toList();
  }
}
