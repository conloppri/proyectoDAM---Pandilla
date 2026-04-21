import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:provider/provider.dart';

import '../core/firebase_service.dart';
import '../screens/group_screen.dart';

class GroupSelector extends StatefulWidget {
  final String groupName;
  final String groupUID;
  final String code;
  final String avatar;
  const GroupSelector({super.key, required this.groupUID, required this.groupName, required this.code, required this.avatar});

  @override
  State<GroupSelector> createState() => _GroupSelectorState();
}

class _GroupSelectorState extends State<GroupSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? _userUID = FirebaseAuth.instance.currentUser?.uid;
          bool _admin = await isAdmin(widget.groupUID, _userUID!);
          context.read<GroupProvider>().setGroup(widget.groupUID, widget.groupName, _admin, widget.code);
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>GroupScreen(groupName: widget.groupName, groupUID: widget.groupUID,))); //linea 24
        },
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/images/${widget.avatar}"),
              ),
              Text(widget.groupName, style: TextStyle(color: Colors.white, fontSize: 20),)
            ],
          ),

        ),
      ),
    );
  }



}
