import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
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
}
