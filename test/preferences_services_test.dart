import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/core/services/preferences_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PreferencesServices stores language key exists', () async {
    //Iniciamos mock con valores simulados para test.
    SharedPreferences.setMockInitialValues({
      "language" : "en"
    });

    await PreferencesServices.setLanguage('es');

    final String? result = await PreferencesServices.getLanguage();

    expect(result, 'es');
  });
}