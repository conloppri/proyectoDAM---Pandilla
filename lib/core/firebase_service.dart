
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:pandilla/components/group_selector.dart';
import 'package:pandilla/components/item_component.dart';
import 'package:pandilla/components/list_component.dart';
import 'package:pandilla/components/note_component.dart';

import 'event.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

String? userUID = "";

Future<List> getUsers() async {
  List usersList = [];
  QuerySnapshot querySnapshot = await db
      .collection("users")
      .where("name", isEqualTo: "Cheli")
      .get();

  for (var doc in querySnapshot.docs) {
    usersList.add(doc.data());
  }
  return usersList;
}

newUser(String name, DateTime birthdate, String email) async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  await db.collection("users").doc(_userUID).set({
    "name": name,
    "bithdate": birthdate,
    "email": email,
    "joinAt": Timestamp.now(),
    'avatar': "panda.png",
    'fav_colors': "Vacío",
    'fav_animal': "Vacío",
    'job': "Vacío",
    'hobbies': "Vacío",
    'description': "Vacío",
  });
}

Future<bool> saveProfile(
  String name,
  String colors,
  String job,
  String hobbies,
  String description,
  String avatar,
  String animal,
) async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  try {
    await db.collection("users").doc(_userUID).update({
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
    print("ERROR: Error al guardar en BD");
    return false;
  }
}

Future<String> getUserName() async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot doc = await db.collection("users").doc(_userUID).get();
  return doc["name"];
}

Future<Map<String, dynamic>> getUser(String uid) async {
  DocumentSnapshot doc = await db.collection("users").doc(uid).get();
  return doc.data() as Map<String, dynamic>;
}

Future<bool> isAdmin(String groupUID, String userUID) async {
  DocumentSnapshot doc = await db.collection("groups").doc(groupUID).get();
  List _admins = doc["admins"];
  return _admins.contains(userUID);
}

Future<Timestamp> getBirthday() async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot doc = await db.collection("users").doc(_userUID).get();
  return doc["bithdate"];
}

//PANTALLA PRINCIPAL

Stream<List<GroupSelector>> getGroups() {
  String? _uid = FirebaseAuth.instance.currentUser?.uid;
  return db
      .collection("groups")
      .where("verified_members", arrayContains: _uid)
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

createGroup(String name, String description, String avatar) async {
  String? _uid = FirebaseAuth.instance.currentUser?.uid;
  String groupCode = await generateCode();
  DocumentReference docRef = db.collection("groups").doc();

  await docRef.set({
    "code": groupCode,
    "name": name,
    "avatar": avatar,
    "description": description,
    "createAt": DateTime.now(),
    "author": _uid,
    "verified_members": [_uid],
    "admins": [_uid],
  });
  String _userName = await getUserName();
  Timestamp _userBirthdate = await getBirthday();
  docRef.collection("events").doc().set({
    "title": "Cumpleaños de ${_userName}",
    "date": _userBirthdate,
    "recurrence": "yearly",
    "decription": "¡Felicidades ${_userName}!",
    "location": "",
    "authorID": _uid,
    "authorName": "sistema",
  });
}

Future<String> generateCode() async {
  final String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  String _newcode = "";
  bool exist = false;
  do {
    _newcode = "";
    for (int i = 0; i < 6; i++) {
      _newcode += chars[Random().nextInt(chars.length)];
    }
    QuerySnapshot snapshot = await db
        .collection("groups")
        .where("code", isEqualTo: _newcode)
        .limit(1)
        .get();
    exist = snapshot.docs.isNotEmpty;
  } while (exist);
  return _newcode;
}

Future<bool> joinGroup(String code) async {
  String? _uid = FirebaseAuth.instance.currentUser?.uid;
  QuerySnapshot snapshot = await db
      .collection("groups")
      .where("code", isEqualTo: code)
      .limit(1)
      .get();
  QueryDocumentSnapshot doc = snapshot.docs.first;
  if (doc.exists) {
    doc.reference.update({
      "verified_members": FieldValue.arrayUnion([_uid]),
    });
    String _userName = await getUserName();
    Timestamp _userBirthdate = await getBirthday();
    doc.reference.collection("events").doc().set({
      "title": "Cumpleaños de ${_userName}",
      "date": _userBirthdate,
      "recurrence": "yearly",
      "decription": "¡Felicidades ${_userName}",
      "location": "",
      "authorID": _uid,
      "authorName": "sistema",
    });
    return true;
  }
  return false;
}

//NOTAS

void createNote(
  String? groupUID,
  String title,
  String body,
  String color,
) async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  String _authorName = await getUserName();
  await db.collection("groups").doc(groupUID).collection("notes").doc().set({
    "title": title,
    "body": body,
    "color": color,
    "authorUID": _userUID,
    "authorName": _authorName,
    "createAt": DateTime.now(),
    "lastUpdate": DateTime.now(),
  });
  print("CREADA");
}

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

Future<Map<String, dynamic>> getNote(String groupUID, String noteID) async {
  Map<String, dynamic>? noteData = {};
  DocumentSnapshot doc = await db
      .collection("groups")
      .doc(groupUID)
      .collection("notes")
      .doc(noteID)
      .get();
  noteData = doc.data() as Map<String, dynamic>?;
  return noteData!;
}

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
    "lastUpdate": DateTime.now(),
  });
}

removeNote(String groupUID, String noteID) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("notes")
      .doc(noteID)
      .delete();
}

//LISTAS

Future<void> newList(String groupUID, String title) async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  String _authorName = await getUserName();
  db.collection("groups").doc(groupUID).collection("lists").doc().set({
    "title": title,
    "authorUID": _userUID,
    "authorName": _authorName,
    "createAt": DateTime.now(),
    "last_update": DateTime.now(),
  });
}

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

newListUpdate(String listID, String groupUID) {
  db.collection("groups").doc(groupUID).collection("lists").doc(listID).update({
    "last_update": DateTime.now(),
  });
}

addItem(String groupUID, String listID, String item) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .doc()
      .set({"text": item, "isCompleted": false});
  newListUpdate(listID, groupUID);
}

changeItemStatus(
  String groupUID,
  String listID,
  String itemID,
  bool isCompleted,
) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .doc(itemID)
      .update({"isCompleted": isCompleted});
  newListUpdate(listID, groupUID);
}

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
          );
        }).toList();
      });
}

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

removeItem(String groupUID, String listID, String itemID) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .collection("items")
      .doc(itemID)
      .delete();
  newListUpdate(listID, groupUID);
}

removeList(String groupUID, String listID) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("lists")
      .doc(listID)
      .delete();
}

//CALENDARIO

saveEvent(
  String groupUID,
  String title,
  String description,
  DateTime date,
  String location,
  String recurrence,
) async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  String _authorName = await getUserName();
  db.collection("groups").doc(groupUID).collection("events").doc().set({
    "title": title,
    "date": date,
    "recurrence": recurrence,
    "decription": description,
    "location": location,
    "authorID": _userUID,
    "authorName": _authorName,
  });
}

Stream<List<Event>> getEventsStream(String groupUID) {
  return db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Event(
            id: doc.id,
            title: data["title"],
            date: data["date"].toDate(),
            description: data["decription"],
            location: data["location"],
            authorName: data["authorName"],
            authorID: data["authorID"],
            recurrence: data["recurrence"],
          );
        }).toList();
      });
}

removeEvent(String groupUID, String eventID) {
  db
      .collection("groups")
      .doc(groupUID)
      .collection("events")
      .doc(eventID)
      .delete();
}

//INFO DEL GRUPO

Future<Map<String, dynamic>> getGroupInfo(String groupUID) async {
  DocumentSnapshot doc = await db.collection("groups").doc(groupUID).get();
  return doc.data() as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> getMembersList(String groupUID) async {
  List<Map<String, dynamic>> result = [];
  List verified_list = [];

  await db.collection("groups").doc(groupUID).get().then((doc) {
    var data = doc.data();
    verified_list = data!["verified_members"];
  });

  await db
      .collection("users")
      .where(FieldPath.documentId, whereIn: verified_list)
      .get()
      .then((snapshot) async {
        for (var doc in snapshot.docs) {
          bool _admin = await isAdmin(groupUID, doc.id);
          result.add({
            "uid": doc.id,
            "name": doc["name"],
            "avatar": doc["avatar"],
            "admin": _admin,
          });
        }
      });
  return result;
}

Future<int> getAdminsLenght(String groupUID) {
  return db.collection("groups").doc(groupUID).get().then((snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    List adminList = data["admins"];
    return adminList.length;
  });
}

kickMember(String groupUID, String memberID) async {
  List verified_list = [];
  List admins_list = [];
  await db.collection("groups").doc(groupUID).get().then((doc) {
    var data = doc.data();
    verified_list = data!["verified_members"];
    admins_list = data["admins"];
  });
  verified_list.remove(memberID);
  db.collection("groups").doc(groupUID).update({
    "verified_members": verified_list,
  });
  if (admins_list.contains(memberID)) {
    admins_list.remove(memberID);
    db.collection("groups").doc(groupUID).update({"admins": admins_list});
  }
}

addAdmin(String groupUID, String userUID) async {
  List admins_list = [];
  await db.collection("groups").doc(groupUID).get().then((doc) {
    var data = doc.data()!;
    admins_list = data["admins"];
  });
  admins_list.add(userUID);
  db.collection("groups").doc(groupUID).update({"admins": admins_list});
}

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

deleteGroup(String groupUID) {
  //BORRAR EVENTOS

  DocumentReference groupRef = db.collection("groups").doc(groupUID);
  groupRef.collection("events").get().then((events) async {
    for (var doc in events.docs) {
      await doc.reference.delete();
    }
  });

  //BORRAR NOTAS
  groupRef.collection("notes").get().then((notes) async {
    for (var doc in notes.docs) {
      await doc.reference.delete();
    }
  });

  //BORRAR LISTAS Y ELEMENTOS DE LISTAS
  groupRef.collection("lists").get().then((lists) async {
    for (var list in lists.docs) {
      list.reference.collection("items").get().then((items) async {
        for (var item in items.docs) {
          await item.reference.delete();
        }
      });
      list.reference.delete();
    }
  });

  //BORRAR GRUPO
  groupRef.delete();
}

Future<List<Map<String,dynamic>>> getNextEvents() async {
  String? _userUID = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String,dynamic>> eventsList = [];
  DateTime limitDate = DateTime.now().add(Duration(days: 7));
  List<String> groupsID = await db
      .collection("groups")
      .where("verified_members", arrayContains: _userUID)
      .get()
      .then((snapshot) {
        List<String> list = [];
        for (var doc in snapshot.docs) {
          list.add(doc.id);
        }
        return list;
      });
  for (String group in groupsID) {
    await db
        .collection("groups")
        .doc(group)
        .collection("events")
        .where("date", isGreaterThan: Timestamp.now())
        .where("date", isLessThan: limitDate)
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            Map<String, dynamic> event = doc.data();
            DateTime date = event["date"].toDate();
            eventsList.add({"date" : date, "title" : event["title"]});
          }
        });
  }
  print("## TIENES ${eventsList.length} EVENTOS PROXIMOS");
  eventsList.sort((a,b)=>a["date"].compareTo(b["date"]));
  return eventsList;
}
