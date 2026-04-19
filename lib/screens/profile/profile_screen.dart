import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/left_drawer.dart';
import 'package:pandilla/core/firebase_service.dart';

import '../../core/app_colors.dart';
import '../../core/app_styles.dart';

class ProfileScreen extends StatefulWidget {
  final String userProfileUID;
  ProfileScreen({super.key, required this.userProfileUID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userInfo = {};
  bool isOwner = false;
  loadProfile() async {
    _userInfo = await getUser(widget.userProfileUID);
    String? _ownerUID = FirebaseAuth.instance.currentUser?.uid;
    _ownerUID==widget.userProfileUID?isOwner = true:isOwner=false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil", style: AppStyles.title),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        actions: [
          if(isOwner) IconButton(onPressed: ()=>Navigator.pushReplacementNamed(context, '/profileEditor'), icon: Icon(Icons.edit))
        ],
      ),
      drawer: LeftDrawer(),
      body: _userInfo.isEmpty?CircularProgressIndicator()
          :SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          "assets/images/${_userInfo["avatar"]}",
                        ),
                      ),
                    ),
                    StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.primary,
                            child: Center(
                              child: ListTile(
                                leading: Icon(Icons.person, color: Colors.white),
                                title: Text("Nombre"),
                                subtitle: Text(_userInfo["name"], style: AppStyles.profileSub,),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.calendar_secondary,
                            child: Center(
                              child: ListTile(
                                leading: Icon(Icons.work, color: Colors.white),
                                title: Text("Ocupación"),
                                subtitle: Text(_userInfo["job"]),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.lists_secondary,
                            child: Center(
                              child: ListTile(
                                leading: Icon(Icons.cake, color: Colors.white),
                                title: Text("Fecha de nacimiento"),
                                subtitle: Text("${birthdateToString()} (${getAge()} años)"),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount:2,
                          child: Card.filled(
                            color: AppColors.notes_primary,
                            child: Center(
                              child: ListTile(
                                leading: Icon(Icons.palette, color: Colors.white),
                                title: Text("Colores favoritos"),
                                subtitle: Text(_userInfo["fav_colors"], style: AppStyles.profileSub),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 2,
                          child: Card.filled(
                            color: AppColors.secondary,
                            child: Center(
                              child: ListTile(
                                leading: Icon(Icons.pets, color: Colors.white),
                                title: Text("Animales favoritos"),
                                subtitle: Text(_userInfo["fav_animal"], style: AppStyles.profileSub),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.calendar_primary,
                            child: Center(
                              child: ListTile(
                                leading: Icon(Icons.sports_basketball, color: Colors.white),
                                title: Text("Pasatiempos"),
                                subtitle: Text(_userInfo["hobbies"], style: AppStyles.profileSub),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 2,
                          child: Card.filled(
                            color: AppColors.notes_secondary,
                            child: Center(
                              child: ListTile(
                                leading: Icon(Icons.star, color: Colors.white,),
                                title: Text("Más cosas sobre mí"),
                                subtitle: Text(_userInfo["description"], style: AppStyles.profileSub),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
  String birthdateToString(){
    DateTime date = _userInfo["bithdate"].toDate();
    return DateFormat("dd/MM/yyyy", "es_ES").format(date);
  }

  int getAge(){
    DateTime date = _userInfo["bithdate"].toDate();
    int thisYear = DateTime.now().year;
    int age = thisYear - date.year;
    if(DateTime.now().isAfter(DateTime(date.day, date.month, thisYear))){
      age = age - 1 ;
    }
    return age;
  }
}
