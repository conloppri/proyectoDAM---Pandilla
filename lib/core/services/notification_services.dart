import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio encargado de gestionar notificaciones locales.
///
/// Utiliza `flutter_local_notifications` para programar, cancelar
/// y controlar notificaciones relacionadas con eventos del grupo.
class NotificationServices {
  /// Instancia global del plugin de notificaciones.
  static final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  /// Inicializa el sistema de notificaciones.
  ///
  /// Configura:
  /// - Ajustes de Android
  /// - Permisos en Android 13+
  static Future<void> init()async{
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('icon');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await plugin.initialize(settings: initSettings);

    /// Solicitud de permisos en Android 13+
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Configura la zona horaria local del dispositivo.
  ///
  /// Necesario para programar notificaciones en la hora correcta.
  static Future<void> setupTimezone() async {
    tz.initializeTimeZones();
    final TimezoneInfo timeZoneName =  await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  }

  /// Activa o desactiva las notificaciones de la app.
  ///
  /// - Guarda el estado en almacenamiento local
  /// - Si se desactivan, cancela todas las notificaciones
  /// - Si se activan, vuelve a programar los eventos
  ///
  /// - [value] Notificaciones activadas/desactivadas
  static setNotificationState(bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("notifications_state", value);
      if(!value){
        await plugin.cancelAll();
      }else{
        await scheduleAllEvents();
      }
    } catch (e) {
      debugPrint("Error al guardar estado de notificaciones: $e");
    }
  }

  /// Programa una notificación para un evento concreto.
  ///
  /// La notificación se lanza el día anterior al evento a las 12:00.
  ///
  /// - [eventID] Identificador del evento.
  /// - [title] Título del evento.
  /// - [groupName] Nombre del grupo al que pertenece el evento.
  /// - [date] Fecha del evento.
  static void scheduleEvents(String eventID, String title, String groupName, DateTime date) async{
    try{
      /// ID único de la notificación basado en el evento
      final int notifID = eventID.hashCode;

      /// Fecha programada (día anterior a las 12:00)
      DateTime notifDate = DateTime(date.year, date.month, date.day, 12)
          .subtract(const Duration(days: 1));

      if (notifDate.isAfter(DateTime.now()) &&
          notifDate.isBefore(DateTime.now().add(const Duration(days: 365)))) {
        //1º Borramos las programaciones anteriores
        await plugin.cancel(id: notifID);

        //2º Volvemos a programar, para actualizar con los nuevos cambios y eventos
        await plugin.zonedSchedule(
          id: notifID,
          title: "📅 Evento mañana - $groupName",
          body: title,
          scheduledDate: tz.TZDateTime.from(notifDate, tz.local),
          notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                  'group_events', "Group Events", importance: Importance.max,
                  priority: Priority.high)
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }catch(e){
      debugPrint("Error programando notificaciones: $e");
    }
  }
}