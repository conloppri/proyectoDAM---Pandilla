import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  String name, email;
  String fav_colors = "";
  String hobbies = "";
  String job = "";
  String description = "";
  Timestamp birthdate;

  User({required this.name, required this.email, required this.birthdate});

  setInfo({fav_colors, hobbies, job, description}){
    this.fav_colors = fav_colors;
    this.hobbies = hobbies;
    this.job = job;
    this.description = description;
  }

  String getName(){
    return this.name;
  }
  String getEmail(){
    return this.email;
  }
  String getBirthdate(){
    DateTime date = this.birthdate.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

}