import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/core/services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('NotificationServices disables notifications and cancel all', () async {

    //Inicializamos los valores iniciales que tendrá SharedPreferences (mock)
    SharedPreferences.setMockInitialValues({
      "notifications_state" : true
    });

    await NotificationServices.setNotificationState(false);

    final SharedPreferences prefs =await SharedPreferences.getInstance();
    final bool? value = prefs.getBool("notifications_state");
    //El test pasará porque sí guarda en SharedPreferences. Dará error por problemas de inicialización de plugin, que se hace en tiempo de ejecución de la app.
    expect(value, false);
  });
}