import 'package:table_calendar/table_calendar.dart';

import '../event.dart';

class EventService {
  /// Obtiene los eventos correspondientes a un día concreto.
  ///
  /// Tiene en cuenta la recurrencia del evento:
  /// - Único
  /// - Semanal
  /// - Mensual
  /// - Anual
  static List<Event> getEventsForDay(DateTime day, List<Event> events) {
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