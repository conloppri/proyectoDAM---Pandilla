import 'package:flutter/material.dart';

/// Provider encargado de gestionar la información del usuario.
///
/// Almacena los datos básicos del usuario autenticado y permite
/// que la UI reaccione a cambios en su información.
class UserProvider extends ChangeNotifier{
  /// Identificador único del usuario.
  String? _uid;

  /// Nombre del usuario.
  String? _name;

  /// Avatar del usuario.
  String? _avatar;

  /// Email del usuario.
  String? _email;

  /// Getter del UID del usuario.
  String? get uid => _uid;

  /// Getter del nombre del usuario.
  String? get name => _name;

  /// Getter del avatar del usuario.
  String? get avatar => _avatar;

  /// Getter del email del usuario.
  String? get email => _email;

  /// Establece la información del usuario en el provider.
  ///
  /// Se utiliza normalmente tras el login o al cargar los datos desde Firestore.
  ///
  /// - [uid] Identificador único del usuario
  /// - [name] Nombre del usuario.
  /// - [avatar] Avatar del usuario.
  /// - [email] Email del usuario.
  void setUser(String uid, String name, String avatar, String email){
    _uid = uid;
    _name = name;
    _avatar = avatar;
    _email = email;
    notifyListeners();
  }
}