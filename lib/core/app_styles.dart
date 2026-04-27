import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static const TextStyle blackBoldStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

  static const TextStyle blackFont = TextStyle(color: Colors.black);

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle settingTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonTextStyle = TextStyle(fontSize: 20);

  static const TextStyle underlinedLogIn = TextStyle(
    decoration: TextDecoration.underline,
    color: Colors.blueAccent,
  );

  static final BoxDecoration mainScreenBox = BoxDecoration(
      color: AppColors.secondary,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.primary)
  );

  static const TextStyle tutorialTextStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 20,
  );

  static final BoxDecoration tutorialBox = BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(20),
  );

  static const TextStyle profileTitles = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle profileSub = TextStyle(color: Colors.white);

  static const TextStyle notesToolBar = TextStyle(
    color: AppColors.notesPrimary,
    fontSize: 20,
  );

  static const TextStyle notesCreatedByStyle =TextStyle(
    color: Colors.black,
    fontSize: 15,
  );
  static const TextStyle notesAuthorStyle =TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static final OutlineInputBorder noteEditorOutlineInput =  OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.notesPrimary),
      borderRadius: BorderRadius.circular(12),
  );

  static final OutlineInputBorder outlineInputBorderRounded =
      OutlineInputBorder(borderRadius: BorderRadius.circular(12));

  static const InputDecoration profileTextFieldStyle = InputDecoration(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  );

  static const TextStyle infoTextFields = TextStyle(color: AppColors.infoPrimary);
  static const TextStyle eventTextFields = TextStyle(color: AppColors.calendarPrimary);

  static const TextStyle eventButtonsStyle = TextStyle(color: AppColors.calendarPrimary, fontSize: 20);

  static const TextStyle calendarTitle = TextStyle(
    color: AppColors.calendarPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
