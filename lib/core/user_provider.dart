import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier{
  String? _uid;
  String? _name;
  String? _avatar;
  String? _email;

  String? get uid => _uid;
  String? get name => _name;
  String? get avatar => _avatar;
  String? get email => _email;


  void setUser(String uid, String name, String avatar, String email){
    _uid = uid;
    _name = name;
    _avatar = avatar;
    _email = email;
    notifyListeners();
  }
}