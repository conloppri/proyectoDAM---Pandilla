import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/avatar_picker.dart';
import 'package:pandilla/components/left_drawer.dart';
import 'package:pandilla/core/user_provider.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/app_styles.dart';
import '../core/firebase_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _groupName = "";
  String _groupDescription = "";
  String _code = "";
  List<String> _avatarList = [
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
    String? _userUID = FirebaseAuth.instance.currentUser?.uid;
    Map _userInfo = await getUser(_userUID!);
    context.read<UserProvider>().setUser(
      _userUID,
      _userInfo["name"],
      _userInfo["avatar"],
      _userInfo["email"],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
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
      drawer: LeftDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text("Próximos eventos:", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Row(
                  children: [
                    Image.asset("assets/images/main.png", height: MediaQuery.of(context).size.height * 0.15 ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      margin: EdgeInsetsGeometry.symmetric(
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
                            if (snapshot.connectionState == ConnectionState.waiting)
                              return Center(child: CircularProgressIndicator());
                            if (snapshot.hasError)
                              return Center(child: Text("Error: ${snapshot.error}"));
                            if (!snapshot.hasData || snapshot.data!.isEmpty)
                              return Text("No tienes eventos próximos");
                            List<Map<String, dynamic>> events = snapshot.data!;
                            return ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (BuildContext context, int index) {
                                DateFormat dateFormat = DateFormat("dd - MMM", "es_ES");
                                DateTime dateEvent = events[index]["date"];
                                return Text("${dateFormat.format(dateEvent)} : ${events[index]["title"]}");
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 40),
              Text(
                "Mis grupos",
                style: TextStyle(color: AppColors.primary, fontSize: 20),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: getGroups(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    if (snapshot.hasError)
                      return Center(child: Text("Error: ${snapshot.error}"));
                    if (!snapshot.hasData || snapshot.data!.isEmpty)
                      return Text("Aún no perteneces a ningún grupo");
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
                                  title: Text("Crear nuevo grupo"),
                                  content: Column(
                                    children: [
                                      AvatarPicker(
                                        selectedAvatar: _selectedAvatar,
                                        onSelectedAvatar: (avatar) {
                                          _selectedAvatar = avatar;
                                          setState(() {});
                                        },
                                        avatarList: _avatarList,
                                      ),
                                      TextField(
                                        onChanged: (value) =>
                                            _groupName = value,
                                        decoration: InputDecoration(
                                          labelText: "Nombre del grupo",
                                        ),
                                      ),
                                      TextField(
                                        minLines: 3,
                                        maxLines: 10,
                                        onChanged: (value) =>
                                            _groupDescription = value,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Descripción",
                                        ),
                                      ),
                                    ],
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
                                      child: Text("Guardar"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancelar"),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 25, color: Colors.white),
                            Text(
                              " Crear",
                              style: TextStyle(
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
                              title: Text("Unirse a grupo"),
                              content: TextField(
                                decoration: InputDecoration(
                                  labelText: "Código",
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
                                  child: Text("Unirse"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancelar"),
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
                            Icon(Icons.link, size: 25, color: Colors.white),
                            Text(
                              " Unirse",
                              style: TextStyle(
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
              //ElevatedButton(onPressed: ()=>getGroups(), child: Text("Prueba"))
            ],
          ),
        ),
      ),
    );
  }
}
