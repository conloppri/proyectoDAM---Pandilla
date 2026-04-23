import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  //Control de pertenencia por expulsión o eliminación de grupo
  StreamSubscription? _membershipSub;
  bool _isMember = true;
  bool get isMember => _isMember;

  void setGroup(String uid, String name, bool admin, String code){
    _groupUID = uid;
    _groupName = name;
    _admin = admin;
    _code = code;
    _isMember = true;
    notifyListeners();
  }

  void clearGroup(){
    _groupUID = null;
    _groupName = null;
    _admin = null;
    notifyListeners();
  }

  void startListening(String userUID){
    _membershipSub?.cancel();

    _membershipSub = FirebaseFirestore.instance.collection('groups').doc(_groupUID).snapshots().listen((snapshot){
      if(!snapshot.exists){
        //Si el grupo no existe, es que ha sido eliminado. Notificamos al usuario
        _handleKick();
        return;
      }

      final data = snapshot.data();
      final List members = data?['members'] ?? [];

      if(!members.contains(userUID)){
        //El usuario ha sido expulsado del grupo
        _handleKick();
      }
    });
  }

  void _handleKick(){
    _isMember = false;
    notifyListeners();
  }

  void stopListening(){
    _membershipSub?.cancel();
    _membershipSub = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}