import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/core/providers/group_provider.dart';

void main(){
  group('GroupProvider tests',(){
    test('setGroup asigna correctamente los valores', (){
      final GroupProvider provider = GroupProvider();

      provider.setGroup("ABC123", "Test Group", true, "123456");

      expect(provider.groupUID, "ABC123");
      expect(provider.groupName, "Test Group");
      expect(provider.isAdmin, true);
      expect(provider.code, "123456");
    });

    test('clearGroup limpia los datos', (){
      final GroupProvider provider = GroupProvider();
      provider.setGroup("ABC123", "Test Group", true, "123456");
      provider.clearGroup();

      expect(provider.groupUID, null);
      expect(provider.groupName, null);
      expect(provider.isAdmin, null);
      expect(provider.code, null);

    });
  });
}