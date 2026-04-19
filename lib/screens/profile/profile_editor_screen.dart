import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/components/avatar_picker.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/user_provider.dart';
import 'package:pandilla/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

class ProfileEditorScreen extends StatefulWidget {
  ProfileEditorScreen({super.key});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {

  String? userUID = FirebaseAuth.instance.currentUser?.uid;
  Map _userInfo = {};
  TextEditingController _nameController = TextEditingController();
  TextEditingController _jobController = TextEditingController();
  TextEditingController _colorsController = TextEditingController();
  TextEditingController _animalsController = TextEditingController();
  TextEditingController _hobbiesController = TextEditingController();
  TextEditingController _moreController = TextEditingController();
  String birthdate = "";
  String _selectedAvatar = "panda.png";
  final List<String> _avatarList = ["panda", "bear", "polar", "black_cat", "siames_cat", "dog", "poodle", "bunny", "duck", "elephant", "fox", "koala", "lion", "tiger", "monkey", "penguin", "pig", "raccoon",];


  TextStyle titleStyle = TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  loadProfile() async {
    _userInfo = await getUser(userUID!);
    _nameController.text = _userInfo["name"];
    _jobController.text = _userInfo["job"];
    _colorsController.text = _userInfo["fav_colors"];
    _animalsController.text = _userInfo["fav_animal"];
    _hobbiesController.text = _userInfo["hobbies"];
    _moreController.text = _userInfo["description"];
    DateTime date = _userInfo["bithdate"].toDate();
    birthdate = DateFormat("dd/MM/yyyy", "es_ES").format(date);
    _selectedAvatar = _userInfo["avatar"];
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
        title: Text("Mi perfil"),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton(onPressed: ()=>saveInfo(), child: Text("Guardar"))
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              AvatarPicker(
                  selectedAvatar: _selectedAvatar,
                  avatarList: _avatarList,
                  onSelectedAvatar: (avatar){
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  }),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    Card.filled(
                      color: AppColors.primary,
                      child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text("Nombre"),
                          subtitle: TextField(
                            controller: _nameController,
                          )),
                    ),
                    Card.filled(
                      color: AppColors.calendar_secondary,
                      child: ListTile(
                        leading: Icon(Icons.work),
                        title: Text("Ocupación"),
                        subtitle: TextField(
                          controller: _jobController,
                        ),
                      ),
                    ),
                    Card.filled(
                      color: AppColors.notes_primary,
                      child: ListTile(
                        leading: Icon(Icons.palette),
                        title: Text("Colores favoritos"),
                        subtitle: TextField(
                          controller: _colorsController,
                        ),
                      ),
                    ),
                    Card.filled(
                      color: AppColors.secondary,
                      child: ListTile(
                        leading: Icon(Icons.pets),
                        title: Text("Animales favoritos"),
                        subtitle: TextField(
                          controller: _animalsController,
                        ),
                      ),
                    ),
                    Card.filled(
                      color: AppColors.calendar_primary,
                      child: ListTile(
                        leading: Icon(Icons.sports_basketball),
                        title: Text("Pasatiempos"),
                        subtitle: TextField(
                          controller: _hobbiesController,
                          minLines: 2,
                          maxLines: 10,
                          decoration: InputDecoration(
                              border: OutlineInputBorder()
                          ),
                        ),
                      ),
                    ),
                    Card.filled(
                      color: AppColors.notes_secondary,
                      child: ListTile(
                        leading: Icon(Icons.star),
                        title: Text("Más cosas sobre mí"),
                        subtitle: TextField(
                          controller: _moreController,
                          minLines: 3,
                          maxLines: 10,
                          decoration: InputDecoration(
                            border: OutlineInputBorder()
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
  
  saveInfo() async {
    bool saved = await saveProfile(
        _nameController.text,
        _colorsController.text,
        _jobController.text,
        _hobbiesController.text,
        _moreController.text,
        _selectedAvatar,
        _animalsController.text
    );
    if(saved){
      context.read<UserProvider>().setUser(userUID!, _nameController.text, _selectedAvatar, _userInfo["email"]);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(userProfileUID: userUID!)));
    }else{
      print("HA OCURRIDO UN ERROR EN LA BD");
    }
  }
}
