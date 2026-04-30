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
      //Probamos que no lo crea semanal:
      final result2 = EventService.getEventsForDay(DateTime(2026, 5, 7), [event]);
      //Ni mensual
      final result3 = EventService.getEventsForDay(DateTime(2026, 5, 30), [event]);
      //ni anual
      final result4 =EventService.getEventsForDay(DateTime(2027, 4, 30), [event]);

      expect(result1.length, 1);
      expect(result2, isEmpty);
      expect(result3, isEmpty);
      expect(result4, isEmpty);
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

      //Vemos cuantos eventos nos da por ese evento
      final result1 = EventService.getEventsForDay(DateTime(2026, 4, 30), [event]);
      //Probamos que no lo crea semanal:
      final result2 = EventService.getEventsForDay(DateTime(2026, 5, 7), [event]);
      //Ni mensual
      final result3 = EventService.getEventsForDay(DateTime(2026, 5, 30), [event]);
      //Pero si lo crea anual
      final result4 =EventService.getEventsForDay(DateTime(2027, 4, 30), [event]);

      expect(result1.length, 1); //Evento creado
      expect(result2, isEmpty); //Sin evento semanal
      expect(result3, isEmpty); //Sin evento mensual
      expect(result4.length, 1); //Evento anual
    });

    test('getEventsForDay returns monthly events', (){
      final Event event = Event(
          recurrence: 'monthly',
          id: '1',
          title: 'Evento',
          date: DateTime(2026, 4, 30),
          description: 'Evento de prueba',
          location: '',
          authorName: 'Consuelo',
          authorID: '1');

      //Vemos cuantos eventos nos da por ese evento
      final result1 = EventService.getEventsForDay(DateTime(2026, 4, 30), [event]);
      //Si lo crea mensual
      final result2 = EventService.getEventsForDay(DateTime(2026, 5, 30), [event]);
      //Probamos que no lo crea semanal:
      final result3 = EventService.getEventsForDay(DateTime(2026, 5, 7), [event]);
      //Si nos aparecerá evento anual, porque lo creará durante 12 meses seguidos
      final result4 =EventService.getEventsForDay(DateTime(2027, 4, 30), [event]);

      expect(result1.length, 1); //Evento creado
      expect(result2.length, 1); //Evento mensual
      expect(result3, isEmpty); //Sin evento semanal
      expect(result4.length, 1); //Con evento anual
    });

    test('getEventsForDay returns weekly events', (){
      final Event event = Event(
          recurrence: 'weekly',
          id: '1',
          title: 'Evento',
          date: DateTime(2026, 4, 30),
          description: 'Evento de prueba',
          location: '',
          authorName: 'Consuelo',
          authorID: '1');

      //Vemos cuantos eventos nos da por ese evento
      final result1 = EventService.getEventsForDay(DateTime(2026, 4, 30), [event]);
      //Probamos que lo crea semanal:
      final result2 = EventService.getEventsForDay(DateTime(2026, 5, 7), [event]);
      //Pero no lo crea mensual
      final result3 = EventService.getEventsForDay(DateTime(2026, 5, 30), [event]);
      //ni anual
      final result4 =EventService.getEventsForDay(DateTime(2027, 4, 30), [event]);

      expect(result1.length, 1); //Evento creado
      expect(result2.length, 1); //Evento semanal
      expect(result3, isEmpty); //Sin evento mensual
      expect(result4, isEmpty); //Sin evento anual
    });
  });
}