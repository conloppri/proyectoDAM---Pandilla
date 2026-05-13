//Básicos
import 'dart:math';
//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Componentes personalizados
import 'package:pandilla/features/home/widget/group_selector.dart';
import 'package:pandilla/features/lists/widget/item_component.dart';
import 'package:pandilla/features/lists/widget/list_component.dart';
import 'package:pandilla/features/notes/widget/note_component.dart';
import '../event.dart';
//Providers y servicios
import 'package:pandilla/core/services/navigator_key.dart';
import 'package:pandilla/core/services/notification_services.dart';
import 'package:pandilla/l10n/app_localizations.dart';

///Instancia de Firestore utilizada para todas las operaciones de base de datos.
FirebaseFirestore db = FirebaseFirestore.instance;

///Servicio encargado de gestionar notificaciones de la aplicación.
NotificationServices notifServices = NotificationServices();

///UID del usuario actual (puede ser nulo si no está autenticado).
String? userUID = "";

///Crea un nuevo usuario en la base de datos en la colección "users"
///
///Se usa el UID del usuario autenticado y se inicializan los campos básicos
/// del perfil con valores por defecto
///
/// - [name] nombre del usuario.
/// - [birthdate] fecha de nacimiento.
/// - [email] correo electrónico.
newUser(String name, DateTime birthdate, String email) async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid; //Usuario actual
  await db.collection("users").doc(userUID).set({
    "name": name,
    "bithdate": birthdate,
    "email": email,
    "joinAt": Timestamp.now(),
    'avatar': "panda.png",
    'fav_colors': "",
    'fav_animal': "",
    'job': "",
    'hobbies': "",
    'description': "",
  });
}

/// Guarda o actualiza el perfil del usuario.
///
/// Retorna 'true' si la operación fue correcta, 'false' en caso de error.
///
/// - [name] nombre.
/// - [colors] colores favoritos.
/// - [job] trabajo.
/// - [hobbies] aficiones.
/// - [description] descripción personal.
/// - [avatar] avatar seleccionado.
/// - [animal] animal favorito.
Future<bool> saveProfile(
  String name,
  String colors,
  String job,
  String hobbies,
  String description,
  String avatar,
  String animal,
) async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid; //Usuario actual
  try {
    await db.collection("users").doc(userUID).update({
      'name': name,
      'avatar': avatar,
      'fav_colors': colors,
      'fav_animal': animal,
      'job': job,
      'hobbies': hobbies,
      'description': description,
    });
    return true;
  } on Exception catch (e) {
    print("ERROR: Error al guardar en BD: $e");
    return false;
  }
}

/// Obtiene el nombre del usuario actual desde Firestore.
Future<String> getUserName() async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot doc = await db.collection("users").doc(userUID).get();
  return doc["name"];
}

/// Obtiene todos los datos de un usuario a partir de su UID.
///
/// [uid] UID del usuario.
Future<Map<String, dynamic>> getUser(String uid) async {
  DocumentSnapshot doc = await db.collection("users").doc(uid).get();
  return doc.data() as Map<String, dynamic>;
}

/// Comprueba si un usuario es administrador de un grupo.
///
/// [groupUID] UID del grupo.
/// [userUID] UID del usuario.
Future<bool> isAdmin(String groupUID, String userUID) async {
  DocumentSnapshot doc = await db.collection("groups").doc(groupUID).get();
  List admins = doc["admins"];
  return admins.contains(userUID);
}

/// Obtiene la fecha de nacimiento del usuario actual.
Future<DateTime> getBirthday() async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot doc = await db.collection("users").doc(userUID).get();
  return doc["bithdate"].toDate();
}

//----------------------PANTALLA PRINCIPAL---------------------------------

/// Devuelve un stream con los grupos a los que pertenece el usuario actual.
Stream<List<GroupSelector>> getGroups() {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  return db
      .collection("groups")
      .where("members", arrayContains: uid)
      .snapshots()
      .map((snapshot) {
        List<GroupSelector> list = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data();
          list.add(
            GroupSelector(
              groupUID: doc.id,
              groupName: data["name"],
              code: data["code"],
              avatar: data["avatar"],
            ),
          );
        }
        return list;
      });
}

/// Crea un nuevo grupo en Firestore.
///
/// También genera un evento automático de cumpleaños para el usuario.
///
/// - [name] nombre del grupo.
/// - [description] descripción.
/// - [avatar] imagen.
/// - [authorName] nombre del creador.
createGroup(
  String name,
  String description,
  String avatar,
  String authorName,
) async {
  //Usuario actual
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  //Generamos el código para unirse al grupo
  String groupCode = await generateCode();
  //Creamos el documento para el grupo y obtenemos su referencia
  DocumentReference docRef = db.collection("groups").doc();

  //Guardamos la información del grupo
  await docRef.set({
    "code": groupCode,
    "name": name,
    "avatar": avatar,
    "description": description,
    "createAt": DateTime.now(),
    "author": uid,
    "members": [uid],
    "admins": [uid],
    "authorName": authorName,
  });
  //Obtenemos nombre de usuario y cumpleaños del usuario actual
  String userName = await getUserName();
  DateTime userBirthday = await getBirthday();
  //Guardamos su compleaños como evento del grupo
  saveBirthday(docRef, userName, userBirthday, uid!);
}

/// Crea un evento de cumpleaños automático en un grupo.
///
/// - [docRef] referencia al documento en que el se va a registrar el cumpleaños.
/// - [userName] nombre del usuario.
/// - [birthday] fecha de cumpleaños del usuario.
/// - [userUID] UID del usuario.
saveBirthday(
  DocumentReference docRef,
  String userName,
  DateTime birthday,
  String userUID,
) {
  docRef.collection("events").doc().set({
    "title":
        "${AppLocalizations.of(navigatorKey.currentContext!)!.birthday_event} $userName",
    "year": birthday.year,
    "month": birthday.month,
    "day": birthday.day,
    "recurrence": "yearly",
    "description":
        "${AppLocalizations.of(navigatorKey.currentContext!)!.happy_birthday} $userName!",
    "location": "",
    "authorID": userUID,
    "authorName": "sistema",
  });
}

/// Genera un código único de grupo de 6 caracteres para usarlo como código de grupo.
Future<String> generateCode() async {
  //Caracteres permitidos para generar el código automático
  const String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  String newcode = "";
  //Variable de control
  bool exist = false;
  do {
    //Generamos un código de 6 caracteres aleatorios entre los del String chars
    newcode = "";
    for (int i = 0; i < 6; i++) {
      newcode += chars[Random().nextInt(chars.length)];
    }
    //Comprobamos si ese código pertenece a otro grupo
    QuerySnapshot snapshot = await db
        .collection("groups")
        .where("code", isEqualTo: newcode)
        .limit(1)
        .get();
    exist = snapshot.docs.isNotEmpty;
  } while (exist);
  //Si no pertenece a otro grupo, termina el bucle y devuelve el código.
  return newcode;
}

/// Permite a un usuario unirse a un grupo mediante código.
///
/// - [code] código de unión del grupo.
Future<bool> joinGroup(String code) async {
  String? uid = FirebaseAuth.instance.currentUser?.uid; //Usuario actual
  //Buscamos si el código pertenece a algún grupo
  QuerySnapshot snapshot = await db
      .collection("groups")
      .where("code", isEqualTo: code)
      .limit(1)
      .get();
  if (snapshot.docs.isEmpty) {
    return false; //Si el código no coincide, devolvemos 'false';
  }
  QueryDocumentSnapshot doc = snapshot.docs.first;
  //Si el código coincide, añadimos al usuario al grupo
  doc.reference.update({
    "members": FieldValue.arrayUnion([uid]),
  });
  //Guardamos el cumpleaños del nuevo miembro en el calendario del grupo
  String userName = await getUserName();
  DateTime userBirthday = await getBirthday();
  saveBirthday(doc.reference, userName, userBirthday, uid!);
  return true; //devolvemos 'true'
}

//----------------------------------NOTAS-----------------------------
/// Crea una nueva nota dentro de un grupo.
///
/// - [groupUID] UID del grupo en el que guardar la nota.
/// - [title] título de la nota.
/// - [body] cuerpo de la nota.
/// - [color] color elegido para el fondo de la nota
void createNote(
  String? groupUID,
  String title,
  String body,
  String color,
) async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid; //Usuario actual
  String authorName =
      await getUserName(); //Obtenemos su nombre para guardarlo de autor
  //Creamos la nota en la base de datos
  await db.collection("groups").doc(groupUID).collection("notes").doc().set({
    "title": title,
    "body": body,
    "color": color,
    "authorUID": userUID,
    "authorName": authorName,
    "createAt": DateTime.now(),
    "lastUpdate": DateTime.now(),
  });
}

/// Obtiene todas las notas del grupo y las guarda en un Stream.
///
/// - [groupUID] UID del grupo del que se quiere obtener las notas.
Stream<List<NoteComponent>> getNotes(String groupUID) {
  return db
      .collection("groups")
      .doc(groupUID)
      .collection("notes")
      .orderBy("createAt", descending: true)
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return NoteComponent(
            color: data["color"],
            title: data["title"],
            body: data["body"],
            author: data["authorName"],
            lastUpdate: data["lastUpdate"].toDate(),
            noteID: doc.id,
            authorID: data["authorUID"],
          );
        }).toList();
      });
}

///Obtiene la información sobre una nota específica.
///
/// - [groupUID] UID del grupo al que pertenece la nota.
/// - [noteID] ID de la nota.
Future<Map<String, dynamic>> getNote(String groupUID, String noteID) async {
  Map<String, dynamic>? noteData =
      {}; //Inicializamos el mapa que contendrá la información
  DocumentSnapshot doc = await db
      .collection("groups")
      .doc(groupUID)
      .collection("notes")
      .doc(noteID)
      .get();
  noteData = doc.data() as Map<String, dynamic>?;
  return noteData!; //devolvemos el mapa, confirmamos que no es nulo
}

///Actualiza la nota editada en la base de datos.
///
/// - [groupUID] UID del grupo al que pertenece la nota.
/// - [noteID] ID de la nota.
/// - [newTitle] nuevo título de la nota.
/// - [newBody] nuevo cuerpo de la nota.
/// - [newColor] nuevo color de la nota.
updateNote(
  String groupUID,
  String noteID,
  String newTitle,
  String newBody,
  String newColor,
) {
  db.collection("groups").doc(groupUID).collection("notes").doc(noteID).update({
    "title": newTitle,
    "body": newBody,
    "color": newColor,
    "lastUpdate": DateTime.now(), //Actulizamos con la fecha actual
  });
}

///Elimina una nota de la base de datos
///
/// - [groupUID] UID del grupo al que pertenece la nota.
/// - [noteID] ID de la nota.
removeNote(String groupUID, String noteID) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("notes")
      .doc(noteID)
      .delete();
}

//LISTAS

///Crea una nueva lista en la base de datos
///
/// - [groupUID] UID del grupo en el que quiere guardar la lista.
/// - [title] título de la lista.
Future<String> newList(String groupUID, String title) async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid; //Usuario actual
  String authorName = await getUserName(); //Nombre del usuario para autorName
  DocumentReference docRef = db.collection("groups").doc(groupUID).collection("lists").doc();
  docRef.set({
    "title": title,
    "authorUID": userUID,
    "authorName": authorName,
    "createAt": DateTime.now(),
    "last_update": DateTime.now(),
  });
  return docRef.id;
}

///Obtiene el listado de listas del grupo en un Stream
///
/// Cada vez que cambia la colección en Firestore, se reconstruye
/// la lista de listas.
///
/// - [groupUID] UID del grupo del que queremos obtener las listas.
Stream<List<ListComponent>> getLists(String groupUID) {
  return db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .orderBy("createAt", descending: true)
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return ListComponent(
            title: data["title"],
            author: data["authorName"],
            listID: doc.id,
            lastUpdate: data["last_update"].toDate(),
            authorID: data["authorUID"],
            groupUID: groupUID,
          );
        }).toList();
      });
}

///Modificación de la fecha de la última actualización de la lista.
///
/// [listID] ID de la lista actualizada.
/// [groupUID] UID del grupo al que pertenece la lista
newListUpdate(String listID, String groupUID) {
  db.collection("groups").doc(groupUID).collection("lists").doc(listID).update({
    "last_update": DateTime.now(),
  });
}

///Añadir elementos a una lista.
///
/// - [groupUID] UID del grupo al que pertenece la lista.
/// - [listID] ID de la lista.
/// - [item] elemento a añadir a la lista.
addItem(String groupUID, String listID, String item) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .doc()
      .set({"text": item, "isCompleted": false, "createAt": Timestamp.now()});
  newListUpdate(
    listID,
    groupUID,
  ); //Actualizamos la fecha de última actualización
}

///Cambia el estado de un elemento de la lista entre completado y no completado
///
/// - [groupUID] UID del grupo al que pertenece la lista.
/// - [listID] ID de la lista a la que pertenece el item.
/// - [itemID] ID del item a modificar.
/// - [isCompleted] estado del item
changeItemStatus(String groupUID, String listID, String itemID, bool isCompleted,) {
  db.collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .doc(itemID)
      .update({"isCompleted": isCompleted});
  newListUpdate(
    listID,
    groupUID,
  ); //Actualizamos la fecha de última actualización
}

///Obtiene los elementos de una lista y los devuelve en un Stream
///
/// Nos devuelve un Stream de ItemComponents, directamente para mostrar
///
/// - [groupUID] UID del grupo al que pertenece la lista.
/// - [listID] ID de la lista.
Stream<List<ItemComponent>> getItems(String groupUID, String listID) {
  return db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return ItemComponent(
            item: data["text"],
            itemId: doc.id,
            isCompleted: data["isCompleted"],
            listID: listID,
            createAt: data["createAt"].toDate(),
          );
        }).toList();
      });
}

///Obtiene el número de elementos de la lista.
///
/// - [groupUID] UID del grupo al que pertenece la lista.
/// - [listID] ID de la lista.
Future<int> getNumItems(String groupUID, String listID) async {
  AggregateQuerySnapshot snapshot = await db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .count()
      .get();
  return snapshot.count!;
}

///Elimina elementos de la lista.
///
/// - [groupUID] UID del grupo al que pertenece la lista.
/// - [listID] ID de la lista.
/// - [itemID] ID del elemento a eliminar
removeItem(String groupUID, String listID, String itemID) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .doc(itemID)
      .delete();
  newListUpdate(
    listID,
    groupUID,
  ); //Actualizamos la fecha de última actualización
}

///Elimina una lista de la base de datos
///
/// La eliminación se realiza de manera escalonada, primero los Items y después la lista.
///
/// - [groupUID] UID del grupo al que pertenece la lista.
/// - [listID] ID de la lista.
removeList(String groupUID, String listID) async {

  DocumentReference docRef = db.collection("groups").doc(groupUID).collection("lists").doc(listID);

  QuerySnapshot items = await docRef.collection("items").get();

  for(var item in items.docs){
    await item.reference.delete();
  }
  await docRef.delete();
}

//------------------CALENDARIO----------------------

/// Guarda un evento dentro de un grupo en la base de datos.
///
/// Además de almacenar la información del evento, también programa
/// una notificación asociada.
///
/// [groupUID] identificador del grupo.
/// [groupName] nombre del grupo (usado para notificaciones).
/// [title] título del evento.
/// [description] descripción del evento.
/// [date] fecha del evento.
/// [location] ubicación del evento.
/// [recurrence] tipo de repetición del evento.
saveEvent(
  String groupUID,
  String groupName,
  String title,
  String description,
  DateTime date,
  String location,
  String recurrence,
) async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid; //Usuario actual
  String authorName = await getUserName(); //Nombre del usuario para autorName
  final DocumentReference docRef = await db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .add({
        "title": title,
        "day": date.day,
        "month": date.month,
        "year": date.year,
        "recurrence": recurrence,
        "description": description,
        "location": location,
        "authorID": userUID,
        "authorName": authorName,
      });
  NotificationServices.scheduleEvents(
    docRef.id,
    title,
    groupName,
    date,
  ); //Programamos notificaciones
}

/// Devuelve un stream con todos los eventos de un grupo.
///
/// Cada vez que cambia la colección en Firestore, se reconstruye
/// la lista de eventos.
///
/// Además, programa notificaciones para cada evento obtenido.
///
/// [groupUID] identificador del grupo.
/// [groupName] nombre del grupo.
Stream<List<Event>> getEventsStream(String groupUID, String groupName) {
  return db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          DateTime date = DateTime(data["year"], data["month"], data["day"]);
          NotificationServices.scheduleEvents(
            doc.id,
            data["title"],
            groupName,
            date,
          ); //Programamos eventos mientras se van cargando.
          return Event(
            id: doc.id,
            title: data["title"],
            date: date,
            description: data["description"],
            location: data["location"],
            authorName: data["authorName"],
            authorID: data["authorID"],
            recurrence: data["recurrence"],
          );
        }).toList();
      });
}

/// Programa todas las notificaciones de eventos de los grupos del usuario.
///
/// Primero cancela todas las notificaciones existentes y posteriormente
/// recorre todos los grupos del usuario para volver a programarlas.
///
/// No recibe parámetros y utiliza el usuario actualmente autenticado.
scheduleAllEvents() async {
  //1º Cancela todos los eventos
  NotificationServices.plugin.cancelAll();

  String? userUID = FirebaseAuth.instance.currentUser?.uid;

  // 2º Obtiene lista de grupos
  final groupsSnap = await db
      .collection("groups")
      .where("members", arrayContains: userUID)
      .get();
  for (var groupDoc in groupsSnap.docs) {
    final groupData = groupDoc.data();
    //3º Obtiene los eventos de los grupos y los reprograma
    final eventSnap = await db
        .collection("groups")
        .doc(groupDoc.id)
        .collection("events")
        .get();
    for (var eventDoc in eventSnap.docs) {
      final eventData = eventDoc.data();
      NotificationServices.scheduleEvents(
        eventDoc.id,
        eventData["title"],
        groupData["name"]!,
        DateTime(eventData["year"], eventData["month"], eventData["day"]),
      );
    }
  }
}

/// Obtiene la información de un evento específico.
///
/// Recupera el documento de Firestore correspondiente a un evento dentro de un grupo
/// y lo devuelve como un `Map<String, dynamic>`.
///
/// - [groupUID] identificador del grupo.
/// - [eventID] identificador del evento.
Future<Map<String, dynamic>> getEventInfo(
  String groupUID,
  String eventID,
) async {
  DocumentSnapshot doc = await db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .doc(eventID)
      .get();
  return doc.data() as Map<String, dynamic>;
}

/// Edita un evento existente dentro de un grupo.
///
/// Actualiza los datos del evento en Firestore y vuelve a programar la notificación.
///
/// - [groupUID] identificador del grupo.
/// - [groupName] nombre del grupo (usado en notificaciones).
/// - [eventID] identificador del evento.
/// - [title] título del evento.
/// - [description] descripción.
/// - [location] ubicación.
/// - [recurrence] tipo de repetición.
/// - [date] nueva fecha del evento.
editEvent(
  String groupUID,
  String groupName,
  String eventID,
  String title,
  String description,
  String location,
  String recurrence,
  DateTime date,
) async {
  await db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .doc(eventID)
      .update({
        "title": title,
        "day": date.day,
        "month": date.month,
        "year": date.year,
        "recurrence": recurrence,
        "description": description,
        "location": location,
      });
  NotificationServices.scheduleEvents(
    eventID,
    title,
    groupName,
    date,
  ); //Cancela la notificación anterior y programamos con la info nueva
}

/// Elimina un evento de un grupo.
///
/// - [groupUID] identificador del grupo.
/// - [eventID] identificador del evento.
removeEvent(String groupUID, String eventID) async {
  await db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .doc(eventID)
      .delete();
}

//------------------INFO DEL GRUPO---------------------

/// Obtiene la información general de un grupo.
///
/// Recupera el documento del grupo desde Firestore y lo devuelve
/// como un `Map<String, dynamic>`.
///
/// - [groupUID] UID del grupo.
Future<Map<String, dynamic>> getGroupInfo(String groupUID) async {
  DocumentSnapshot doc = await db.collection("groups").doc(groupUID).get();
  return doc.data() as Map<String, dynamic>;
}

/// Obtiene la lista de miembros de un grupo con información básica.
///
/// Recupera los usuarios pertenecientes al grupo y construye una lista
/// con sus datos principales, incluyendo si son administradores.
///
/// - [groupUID] UID del grupo.
Future<List<Map<String, dynamic>>> getMembersList(String groupUID) async {
  List<Map<String, dynamic>> result = [];
  List membersList = [];

  //1º Obtiene los UID de todos los miembros del grupo
  await db.collection("groups").doc(groupUID).get().then((doc) {
    var data = doc.data();
    membersList = data!["members"];
  });
  //2º Recorre la colección de usuarios y obtiene la información necesaria de los UID que están en la lista de miembros
  await db
      .collection("users")
      .where(FieldPath.documentId, whereIn: membersList)
      .get()
      .then((snapshot) async {
        for (var doc in snapshot.docs) {
          bool admin = await isAdmin(groupUID, doc.id);
          result.add({
            "uid": doc.id,
            "name": doc["name"],
            "avatar": doc["avatar"],
            "admin": admin,
          });
        }
      });
  return result;
}

/// Devuelve el número total de administradores de un grupo.
///
/// - [groupUID] UID del grupo.
Future<int> getAdminsLength(String groupUID) {
  return db.collection("groups").doc(groupUID).get().then((snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    List adminList = data["admins"];
    return adminList.length;
  });
}

/// Elimina a un miembro de un grupo.
///
/// Realiza las siguientes acciones:
/// - Elimina el usuario de la lista de miembros.
/// - Si el usuario es administrador, también lo elimina de esa lista.
/// - Elimina los eventos creados por ese usuario dentro del grupo.
///
/// - [groupUID] UID del grupo.
/// - [memberID] UID del miembro a expulsar.
kickMember(String groupUID, String memberID) async {
  List membersList = [];
  List adminsList = [];

  //Eliminamos al miembro del grupo
  await db.collection("groups").doc(groupUID).get().then((doc) {
    var data = doc.data();
    membersList = data!["members"];
    adminsList = data["admins"];
  });
  membersList.remove(memberID);
  db.collection("groups").doc(groupUID).update({"members": membersList});

  //Comprobamos si está en la lista de admins, y se elimina de esa lista si está
  if (adminsList.contains(memberID)) {
    adminsList.remove(memberID);
    db.collection("groups").doc(groupUID).update({"admins": adminsList});
  }
  final snapshot = await db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .where("authorID", isEqualTo: memberID)
      .get();

  //Eliminamos los eventos creados por ese miembro. Las notas y listas se quedarán guardadas, será decisión del admin borrarlas.
  WriteBatch batch = db.batch();
  int counter = 0;
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
    counter++;

    /*Solo puede hacer hasta 500 operaciones, por lo tanto hacemos commit y comenzamos a borrar. Solo en caso de seguridad, lo más
   *probable es que un miembro no haya creado 500 eventos.
   */

    if (counter == 450) {
      await batch.commit();
      batch = db.batch();
      counter = 0;
    }
  }
  if (counter > 0) {
    await batch.commit();
  }
}

/// Añade un usuario como administrador dentro de un grupo.
///
/// - [groupUID] UID del grupo.
/// - [userUID] UID del usuario a promover.
addAdmin(String groupUID, String userUID) async {
  List adminsList = [];
  await db.collection("groups").doc(groupUID).get().then((doc) {
    var data = doc.data()!;
    adminsList = data["admins"];
  });
  adminsList.add(userUID);
  db.collection("groups").doc(groupUID).update({"admins": adminsList});
}

/// Edita la información básica de un grupo.
///
/// Actualiza los campos principales del grupo en Firestore.
///
/// - [groupUID] UID del grupo.
/// - [name] nuevo nombre del grupo.
/// - [description] nueva descripción.
/// - [code] código de acceso del grupo.
/// - [avatar] imagen del grupo.
editGroup(
  String groupUID,
  String name,
  String description,
  String code,
  String avatar,
) {
  db.collection("groups").doc(groupUID).update({
    "name": name,
    "description": description,
    "code": code,
    "avatar": avatar,
  });
}

/// Elimina completamente un grupo y todos sus datos asociados.
///
/// Se eliminan de forma secuencial:
/// - Eventos del grupo
/// - Notas del grupo
/// - Listas y sus elementos
/// - Finalmente el documento del grupo
///
/// - [groupUID] UID del grupo a eliminar.
deleteGroup(String groupUID) async {
  DocumentReference groupRef = db.collection("groups").doc(groupUID);
  //1º BORRAR EVENTOS
  final events = await groupRef.collection("events").get();
  for (var doc in events.docs) {
    await doc.reference.delete();
  }

  //2º BORRAR NOTAS
  final notes = await groupRef.collection("notes").get();
  for (var doc in notes.docs) {
    await doc.reference.delete();
  }

  //3º BORRAR LISTAS Y ELEMENTOS DE LISTAS
  final lists = await groupRef.collection("lists").get();
  for (var list in lists.docs) {
    final items = await list.reference.collection("items").get();
    for (var item in items.docs) {
      await item.reference.delete();
    }
    await list.reference.delete();
  }

  //4º BORRAR GRUPO
  await groupRef.delete();
}

/// Obtiene los eventos próximos de los grupos del usuario.
///
/// Busca todos los eventos de los grupos a los que pertenece el usuario
/// y filtra aquellos que ocurren en los próximos 7 días.
///
/// El resultado se ordena por fecha ascendente.
Future<List<Map<String, dynamic>>> getNextEvents() async {
  String? userUID = FirebaseAuth.instance.currentUser?.uid;
  //Inicializamos la lista que recogerá los próximos eventos
  List<Map<String, dynamic>> eventsList = [];

  //Establecemos la ficha límite de los eventos a recoger (en los próximos 7 días)

  //Obtenemos todos los grupos a los que pertenece el usuario
  List<String> groupsID = await db
      .collection("groups")
      .where("members", arrayContains: userUID)
      .get()
      .then((snapshot) {
        List<String> list = [];
        for (var doc in snapshot.docs) {
          list.add(doc.id);
        }
        return list;
      });
  //Por cada grupo, revisamos los eventos
  for (String group in groupsID) {
    await db.collection("groups").doc(group).collection("events").get().then((
      snapshot,
    ) {
      for (var doc in snapshot.docs) {
        Map<String, dynamic> event = doc.data();
        DateTime date = DateTime(event["year"], event["month"], event["day"]);
        //Recogemos los eventos que se encuentren dentro del intervalo de tiempo
        if (date.isAfter(DateTime.now()) &&
            date.isBefore(DateTime.now().add(const Duration(days: 7)))) {
          eventsList.add({"date": date, "title": event["title"]});
        }
      }
    });
  }
  eventsList.sort(
    (a, b) => a["date"].compareTo(b["date"]),
  ); //Ordenamos por fecha
  return eventsList;
}
