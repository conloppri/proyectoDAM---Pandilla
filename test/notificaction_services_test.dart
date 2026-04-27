import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/core/services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('NotificationServices disables notifications and cancel all', () async {
    //Iniciamos mock con valores simulados para test.
    SharedPreferences.setMockInitialValues({
      "notifications_state" : true
    });
    await NotificationServices.setNotificationState(false);

    final SharedPreferences prefs =await SharedPreferences.getInstance();
    final bool? value = prefs.getBool("notifications_state");

    expect(value, false);
  });
}