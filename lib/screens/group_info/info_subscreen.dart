import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
import '../profile/profile_screen.dart';

class InfoSubscreen extends StatefulWidget {
  final String groupUID;
  const InfoSubscreen({super.key, required this.groupUID});

  @override
  State<InfoSubscreen> createState() => _InfoSubscreenState();
}

class _InfoSubscreenState extends State<InfoSubscreen> {
  Future<List<Map<String, dynamic>>>? _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = getMembersList(widget.groupUID);
  }

  @override
  Widget build(BuildContext context) {
    bool? _isAdmin = context.watch<GroupProvider>().isAdmin;
    String? _userUID = FirebaseAuth.instance.currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Card.filled(
            color: AppColors.members_primary,
            child: Container(
              padding: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.maxFinite,
              child: FutureBuilder(
                future: getGroupInfo(widget.groupUID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text("Error: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return Text(AppLocalizations.of(context)!.no_info);
                  Map<String, dynamic> info = snapshot.data!;
                  DateTime createAt = info["createAt"].toDate();
                  String _code = info["code"];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/images/${info["avatar"]}"),
                      ),
                      Text(info["description"], style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text(
                        "${AppLocalizations.of(context)!.created_at} ${DateFormat("dd MMM yyyy", "es_ES").format(createAt)} ${AppLocalizations.of(context)!.by} ${info["authorName"]}",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: _code),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.code_copied)),
                              );
                            },
                            label: Text(_code),
                            icon: Icon(Icons.copy),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              int numAdmins = await getAdminsLength(
                                widget.groupUID,
                              );
                              if (_isAdmin! && numAdmins < 2) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Error"),
                                      content: Text(
                                          AppLocalizations.of(context)!.warning_no_more_admins
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(AppLocalizations.of(context)!.accept),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.leave_group),
                                      content: Text(
                                        AppLocalizations.of(context)!.warning_leave_group,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            String? userUID = FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid;
                                            kickMember(
                                              widget.groupUID,
                                              userUID!,
                                            );
                                          },
                                          child: Text(AppLocalizations.of(context)!.confirm),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(AppLocalizations.of(context)!.cancel),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            label: Text(AppLocalizations.of(context)!.leave_group),
                            icon: Icon(Icons.logout),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Text(AppLocalizations.of(context)!.group_members, style: AppStyles.title),
          Expanded(
            child: FutureBuilder(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text("Error: ${snapshot.error}"));
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Text(AppLocalizations.of(context)!.no_member);
                List<Map<String, dynamic>> data = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card.filled(
                            color: AppColors.members_secondary,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    userProfileUID: data[index]["uid"],
                                  ),
                                ),
                              ),
                              onLongPress: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                        "assets/images/${data[index]["avatar"]}",
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      data[index]["name"],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                      ),
                                    ),
                                    if(data[index]["admin"])Icon(Icons.star, color: AppColors.lists_primary,),
                                    Spacer(),
                                    if (_isAdmin! && !data[index]["admin"])
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  AppLocalizations.of(context)!.make_admin,
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(context)!.make_admin_dialog,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(AppLocalizations.of(context)!.cancel),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await addAdmin(widget.groupUID, data[index]["uid"]);
                                                      setState(() {
                                                        _futureData =
                                                            getMembersList(
                                                              widget.groupUID,
                                                            );
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(AppLocalizations.of(context)!.promote),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.keyboard_double_arrow_up,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                      ),
                                    if (_isAdmin &&
                                        _userUID != data[index]["uid"])
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  AppLocalizations.of(context)!.remove_member,
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(context)!.warning_remove_member,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(AppLocalizations.of(context)!.cancel),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await kickMember(
                                                        widget.groupUID,
                                                        data[index]["uid"],
                                                      );
                                                      setState(() {
                                                        _futureData =
                                                            getMembersList(
                                                              widget.groupUID,
                                                            );
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(AppLocalizations.of(context)!.remove),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
