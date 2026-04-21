import 'package:flutter/material.dart';
import 'package:pandilla/l10n/app_localizations.dart';

class AvatarPicker extends StatefulWidget {
  final String selectedAvatar;
  final List<String> avatarList;
  final Function(String) onSelectedAvatar;
  const AvatarPicker({super.key, required this.selectedAvatar, required this.onSelectedAvatar, required this.avatarList});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(
            "assets/images/${widget.selectedAvatar}",
          ),
        ),
        ElevatedButton(onPressed: () {
          pickAvatar();
        }, child: Text(AppLocalizations.of(context)!.pick_another_avatar)),
      ],
    );
  }

  pickAvatar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.pick_avatar),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.maxFinite,
            child: GridView.builder(
              itemCount: widget.avatarList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onSelectedAvatar("${widget.avatarList[index]}.png");
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(
                      "assets/images/${widget.avatarList[index]}.png",
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
