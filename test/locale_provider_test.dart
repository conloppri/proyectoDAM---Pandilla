import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/core/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadLocale sets system locale if no saved value', ()async{
    //Iniciamos mock de SharedPreferences con valores simulados para test. En este caso, no queremos que haya ningún valor preestablecido.
    SharedPreferences.setMockInitialValues({});
    final LocaleProvider provider = LocaleProvider();

    await provider.loadLocale(); //Cargamos locale sin haber guardado ningún dato, debe cargar desde sistema

    expect(provider.locale, isNotNull);
  });
}