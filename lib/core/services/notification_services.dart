import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationServices {
  static final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init()async{
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await plugin.initialize(settings: initSettings);

    // IMPORTANTE: Pedir permiso en Android 13+
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> setupTimezone() async {
    tz.initializeTimeZones();
    final TimezoneInfo timeZoneName =  await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
    print("#### --- TimeZone: ${timeZoneName.identifier}");
  }

  static void scheduleEvents(String eventID, String title, String groupName, DateTime date) async{
    final int notifID = eventID.hashCode;
    DateTime notifDate = DateTime(date.year, date.month, date.day, 12).subtract(const Duration(days: 1)); //El día antes, a las 12 del mediodía

    if(notifDate.isAfter(DateTime.now())) {
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
      print(DateTime.now());
      print("Programando notificacion para la fecha: $notifDate");
    }
  }
}