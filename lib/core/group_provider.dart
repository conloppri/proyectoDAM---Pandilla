import 'package:flutter/material.dart';

class GroupProvider extends ChangeNotifier{
  String? _groupUID;
  String? _groupName;
  bool? _admin;
  String? _code;

  String? get groupUID => _groupUID;
  String? get groupName => _groupName;
  String? get code => _code;
  bool? get isAdmin => _admin;

  void setGroup(String uid, String name, bool admin, String code){
    _groupUID = uid;
    _groupName = name;
    _admin = admin;
    _code = code;
    notifyListeners();
  }

  void clearGroup(){
    _groupUID = null;
    _groupName = null;
    _admin = null;
    notifyListeners();
  }
}