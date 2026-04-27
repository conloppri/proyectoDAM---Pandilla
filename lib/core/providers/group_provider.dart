import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Provider que gestiona el estado del grupo activo.
///
/// Se encarga de almacenar la información del grupo seleccionado por el usuario
/// y de notificar a la UI cuando cambia.
///
/// También controla la pertenencia del usuario al grupo mediante un listener
/// en Firestore (por ejemplo, si es expulsado o el grupo se elimina).
class GroupProvider extends ChangeNotifier {
  /// Identificador único del grupo activo.
  String? _groupUID;

  /// Nombre del grupo activo.
  String? _groupName;

  /// Indica si el usuario actual es administrador del grupo.
  bool? _admin;

  /// Código de acceso del grupo.
  String? _code;

  /// Indica si el usuario sigue siendo miembro del grupo.
  bool _isMember = true;

  /// Stream para escuchar cambios en la membresía del grupo. (Control de pertenencia por expulsión o eliminación de grupo)
  StreamSubscription? _membershipSub;

  /// Getter del UID del grupo.
  String? get groupUID => _groupUID;

  /// Getter del nombre del grupo.
  String? get groupName => _groupName;

  /// Getter del código del grupo.
  String? get code => _code;

  /// Getter del estado de administrador.
  bool? get isAdmin => _admin;

  /// Getter del estado de pertenencia al grupo.
  bool get isMember => _isMember;

  /// Establece el grupo activo en el provider.
  ///
  /// Se usa cuando el usuario entra o crea un grupo.
  /// Resetea el estado de pertenencia.
  /// - [uid] Identificador único del grupo activo.
  /// - [name] Nombre del grupo activo.
  /// - [admin] Indica si el usuario actual es administrador del grupo.
  /// - [code] Código de acceso del grupo.
  void setGroup(String uid, String name, bool admin, String code) {
    _groupUID = uid;
    _groupName = name;
    _admin = admin;
    _code = code;
    _isMember = true;
    notifyListeners();
  }

  /// Limpia la información del grupo activo.
  ///
  /// Se usa al salir del grupo o cambiar de contexto.
  void clearGroup() {
    _groupUID = null;
    _groupName = null;
    _admin = null;
    _code = null;
    notifyListeners();
  }

  /// Inicia la escucha en Firestore para detectar cambios en la membresía.
  ///
  /// Se comprueba:
  /// - Si el grupo ha sido eliminado
  /// - Si el usuario ha sido expulsado del grupo
  ///
  ///  - [userUID] Identificador del usuario que inicia la escucha
  void startListening(String userUID) {
    /// Cancela cualquier listener previo
    _membershipSub?.cancel();

    ///Inicia la escucha
    _membershipSub = FirebaseFirestore.instance
        .collection('groups')
        .doc(_groupUID)
        .snapshots()
        .listen((snapshot) {
          try {
            /// Si el grupo ya no existe, se considera eliminado
            if (!snapshot.exists) {
              //Si el grupo no existe, es que ha sido eliminado. Notificamos al usuario
              _handleKick();
              return;
            }

            final data = snapshot.data();
            final List members = data?['members'] ?? [];

            /// Si el usuario ya no está en la lista de miembros
            if (!members.contains(userUID)) {
              ///El usuario ha sido expulsado del grupo
              _handleKick();
            }
          } catch (e) {
            debugPrint("Error escuchando la subscripción: $e");
          }
        });
  }

  /// Marca al usuario como expulsado o eliminado del grupo.
  void _handleKick() {
    _isMember = false;
    notifyListeners();
  }

  /// Detiene la escucha de cambios en Firestore.
  void stopListening() {
    _membershipSub?.cancel();
    _membershipSub = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
