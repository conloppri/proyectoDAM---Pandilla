import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/core/event.dart';
import 'package:pandilla/core/services/event_service.dart';


void main(){
  group('Events Tests', (){
    test('getEventsForDay returns unique event on same day', (){
      final Event event = Event(
          recurrence: 'unique',
          id: '1',
          title: 'Evento',
          date: DateTime(2026, 4, 30),
          description: 'Evento de prueba',
          location: '',
          authorName: 'Consuelo',
          authorID: '1');

      //Vemos cuantos eventos nos da por ese evento
      final result1 = EventService.getEventsForDay(DateTime(2026, 4, 30), [event]);
      //Vemos que no crea ningun evento en la lista
      final result2 = EventService.getEventsForDay(DateTime(2026, 4, 20), [event]);

      expect(result1.length, 1);
      expect(result2, isEmpty);
    });

    test('getEventsForDay returns yearly event', (){
      final Event event = Event(
          recurrence: 'yearly',
          id: '1',
          title: 'Evento',
          date: DateTime(2026, 4, 30),
          description: 'Evento de prueba',
          location: '',
          authorName: 'Consuelo',
          authorID: '1');

      //Vamos a probar que crea el evento para ese día
      final result1 = EventService.getEventsForDay(DateTime(2026, 4, 30), [event]);
      //Y para el año siguiente
      final result2 = EventService.getEventsForDay(DateTime(2027, 4, 30), [event]);

      expect(result1.length, 1);
      expect(result2.length, 1);
    });
  });
}