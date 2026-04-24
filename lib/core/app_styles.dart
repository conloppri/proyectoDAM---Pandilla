import 'package:flutter/material.dart';

class AppStyles{

  static final TextStyle title = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  static const TextStyle profileSub = TextStyle(color: Colors.white);
  static const InputDecoration profileTextFieldStyle = InputDecoration(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white)
    ),

  );

  static TextStyle tutorialStyle = const TextStyle(
    color: Colors.white,
    fontSize: 20
  );

}