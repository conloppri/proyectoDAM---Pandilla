import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/core/providers/user_provider.dart';

void main(){
  test('UserProvider sets user correctly', (){
    final UserProvider provider = UserProvider();

    provider.setUser("1", "Consuelo", "panda.png", "conlopprieto@gmail.com");
    expect(provider.uid, "1");
    expect(provider.name, "Consuelo");
    expect(provider.avatar, "panda.png");
    expect(provider.email, "conlopprieto@gmail.com");
  });
}