import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/avatar_picker.dart';
import 'package:pandilla/components/left_drawer.dart';
import 'package:pandilla/core/providers/user_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/app_styles.dart';
import '../core/services/firebase_service.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _groupName = "";
  String _groupDescription = "";
  String _code = "";
  final List<String> _avatarList = [
    "reading",
    "cooking",
    "videogames",
    "football",
    "party",
    "playing",
    "pool",
    "working",
  ];
  String _selectedAvatar = "reading.png";




  Future<void> loadUser() async {
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    Map userInfo = await getUser(userUID!);
    context.read<UserProvider>().setUser(
      userUID,
      userInfo["name"],
      userInfo["avatar"],
      userInfo["email"],
    );
  }

  @override
  void initState() {
    super.initState();
    loadUser();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pandilla", style: AppStyles.title),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.next_events, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Row(
                  children: [
                    Image.asset("assets/images/main.png", height: MediaQuery.of(context).size.height * 0.15 ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      margin: const EdgeInsetsGeometry.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder(
                          future: getNextEvents(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text("Error: ${snapshot.error}"));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text(AppLocalizations.of(context)!.no_next_events);
                            }
                            List<Map<String, dynamic>> events = snapshot.data!;
                            return ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (BuildContext context, int index) {
                                DateFormat dateFormat = DateFormat("dd - MMM", "es_ES");
                                DateTime dateEvent = events[index]["date"];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("${dateFormat.format(dateEvent)}: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text(events[index]["title"])
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 40),
              Text(
                AppLocalizations.of(context)!.my_groups,
                style: TextStyle(color: AppColors.primary, fontSize: 20),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: getGroups(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text(AppLocalizations.of(context)!.no_groups);
                    }
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      children: snapshot.data!,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.new_group),
                                  content: Container(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Column(
                                      children: [
                                        AvatarPicker(
                                          selectedAvatar: _selectedAvatar,
                                          onSelectedAvatar: (avatar) {
                                            setStateDialog((){
                                              _selectedAvatar = avatar;
                                            });
                                          },
                                          avatarList: _avatarList,
                                        ),
                                        TextField(
                                          maxLength: 20,
                                          onChanged: (value) =>
                                              _groupName = value,
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(context)!.group_name,
                                          ),
                                        ),
                                        TextField(
                                          minLines: 3,
                                          maxLines: 10,
                                          maxLength: 200,
                                          onChanged: (value) =>
                                              _groupDescription = value,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: AppLocalizations.of(context)!.description,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        createGroup(
                                          _groupName,
                                          _groupDescription,
                                          _selectedAvatar,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Text(AppLocalizations.of(context)!.create),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(AppLocalizations.of(context)!.cancel),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Padding(
                        padding: const EdgeInsetsGeometry.all(10),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 25, color: Colors.white),
                            Text(
                              AppLocalizations.of(context)!.create,
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!.join_group),
                              content: TextField(
                                maxLength: 6,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.code,
                                ),
                                onChanged: (value) => _code = value,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    bool joined = await joinGroup(
                                      _code.toUpperCase(),
                                    );
                                    if (joined) {
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      print("NO EXISTE");
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.join),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link, size: 25, color: Colors.white),
                            Text(
                              AppLocalizations.of(context)!.join,
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
