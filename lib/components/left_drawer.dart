import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/core/user_provider.dart';
import 'package:pandilla/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  @override
  Widget build(BuildContext context) {
    String? _userUID = context.watch<UserProvider>().uid;
    String? _userName = context.watch<UserProvider>().name;
    String? _userAvatar = context.watch<UserProvider>().avatar;
    String? _userEmail = context.watch<UserProvider>().email;
    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (int index) async {
        Navigator.pop(context);
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(userProfileUID: _userUID!)));
        } else if (index == 2) {
          Navigator.pushNamed(context, '/settings');
        } else {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: AppColors.secondary
          ),
            child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                "assets/images/$_userAvatar",
              )
            ),
            Text(_userName!),
            Text(_userEmail!)
          ],
        )),
        NavigationDrawerDestination(
          icon: Icon(Icons.home),
          label: Text("Home"),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.person),
          label: Text("Perfil"),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.settings),
          label: Text("Ajustes"),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.logout),
          label: Text("Cerrar sesión"),
        ),
      ],
    );
  }
}
