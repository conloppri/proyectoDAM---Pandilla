import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/core/providers/user_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
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
    String? userUID = context.watch<UserProvider>().uid;
    String? userName = context.watch<UserProvider>().name;
    String? userAvatar = context.watch<UserProvider>().avatar;
    String? userEmail = context.watch<UserProvider>().email;
    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (int index) async {
        Navigator.pop(context);
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(userProfileUID: userUID!)));
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
                "assets/images/$userAvatar",
              )
            ),
            Text(userName!),
            Text(userEmail!)
          ],
        )),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home),
          label: Text("Home"),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.person),
          label: Text(AppLocalizations.of(context)!.profile),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings),
          label: Text(AppLocalizations.of(context)!.settings),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.logout),
          label: Text(AppLocalizations.of(context)!.logout),
        ),
      ],
    );
  }
}
