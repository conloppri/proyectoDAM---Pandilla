import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandilla/components/avatar_picker.dart';
import 'package:pandilla/l10n/app_localizations.dart';

void main(){
  testWidgets('AvatarPicker integration test', (WidgetTester tester) async {
    String? selectedAvatar;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AvatarPicker(
              selectedAvatar: 'panda.png',
              onSelectedAvatar: (avatar)=>selectedAvatar=avatar,
              avatarList: const ['panda', 'koala']),
        ),
      )
    );

    await tester.pumpAndSettle();

    //Comprobamos que existe el botón para seleccioanr avatar:
    expect(find.byType(ElevatedButton), findsOneWidget);

    //Pulsar el botón
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    //Comprobamos que aparece el diálogo
    expect(find.byType(AlertDialog), findsOneWidget);

    //Pulsamos sobre un avatar dentro del diálogo de selección
    await tester.tap(
      find.descendant( //Tenemos que buscar el AlertDialog para poder usar sus elementos
        of: find.byType(AlertDialog),
        matching: find.byType(GestureDetector),
      ).first,
    );
    await tester.pumpAndSettle();

    //Verificamos que cambió el avatar seleccionado (previamente null)
    expect(selectedAvatar, isNotNull);
  });
}