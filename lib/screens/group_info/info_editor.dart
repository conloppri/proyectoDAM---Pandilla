import 'package:flutter/material.dart';
import 'package:pandilla/components/avatar_picker.dart';
import 'package:pandilla/core/app_colors.dart';

import 'package:pandilla/core/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/screens/group_screen.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

class InfoEditor extends StatefulWidget {
  final String groupUID;
  final String groupName;
  const InfoEditor({
    super.key,
    required this.groupUID,
    required this.groupName,
  });

  @override
  State<InfoEditor> createState() => _InfoEditorState();
}

class _InfoEditorState extends State<InfoEditor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
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

  Map<String, dynamic> info = {};

  loadInfo() async {
    info = await getGroupInfo(widget.groupUID);
    _nameController.text = info["name"];
    _descController.text = info["description"];
    _code = info["code"];
    _selectedAvatar = info["avatar"];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.edit_group_info),
        backgroundColor: AppColors.members_primary,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AvatarPicker(
                selectedAvatar: _selectedAvatar,
                onSelectedAvatar: (avatar) {
                  _selectedAvatar = avatar;
                  setState(() {});
                },
                avatarList: _avatarList,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Card.filled(
                  color: AppColors.members_primary,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      spacing: 10,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.group_name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.members_secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: _descController,
                          minLines: 5,
                          maxLines: 10,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.members_secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Card.filled(
                  color: AppColors.members_secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${AppLocalizations.of(context)!.code}: $_code"),
                        TextButton(
                          onPressed: () async {
                            _code = await generateCode();
                            setState(() {});
                          },
                          child: Text(AppLocalizations.of(context)!.regenerate_code),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.members_primary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(AppLocalizations.of(context)!.discard, style: TextStyle(color: Colors.white, fontSize: 20),),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      editGroup(
                        widget.groupUID,
                        _nameController.text,
                        _descController.text,
                        _code,
                        _selectedAvatar,
                      );
                      context.read<GroupProvider>().setGroup(
                        widget.groupUID,
                        _nameController.text,
                        true,
                        _code,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupScreen(
                            groupUID: widget.groupUID,
                            groupName: _nameController.text,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.members_primary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(AppLocalizations.of(context)!.save, style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
