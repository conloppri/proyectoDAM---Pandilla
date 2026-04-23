import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/left_drawer.dart';
import 'package:pandilla/core/services/firebase_service.dart';

import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final String userProfileUID;
  const ProfileScreen({super.key, required this.userProfileUID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userInfo = {};
  bool isOwner = false;
  loadProfile() async {
    _userInfo = await getUser(widget.userProfileUID);
    String? ownerUID = FirebaseAuth.instance.currentUser?.uid;
    ownerUID==widget.userProfileUID?isOwner = true:isOwner=false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile, style: AppStyles.title),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        actions: [
          if(isOwner) IconButton(onPressed: ()=>Navigator.pushReplacementNamed(context, '/profileEditor'), icon: const Icon(Icons.edit))
        ],
      ),
      drawer: const LeftDrawer(),
      body: _userInfo.isEmpty?const CircularProgressIndicator()
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
                                leading: const Icon(Icons.person, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.username),
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
                                leading: const Icon(Icons.work, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.job),
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
                                leading: const Icon(Icons.cake, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.birthdate),
                                subtitle: Text("${birthdateToString()} (${getAge()} ${AppLocalizations.of(context)!.years})"),
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
                                leading: const Icon(Icons.palette, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.fav_colors),
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
                                leading: const Icon(Icons.pets, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.fav_animal),
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
                                leading: const Icon(Icons.sports_basketball, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.hobbies),
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
                                leading: const Icon(Icons.star, color: Colors.white,),
                                title: Text(AppLocalizations.of(context)!.more_info),
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
