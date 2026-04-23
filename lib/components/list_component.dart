import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/screens/lists/listview_screen.dart';
import 'package:provider/provider.dart';

import '../core/providers/group_provider.dart';
import '../l10n/app_localizations.dart';

class ListComponent extends StatefulWidget {
  final String groupUID;
  final String title;
  final String author;
  final DateTime lastUpdate;
  final String listID;
  final String authorID;
  ListComponent({
    super.key,
    required this.title,
    required this.author,
    required this.lastUpdate,
    required this.listID,
    required this.authorID,
    required this.groupUID,
  });

  @override
  State<ListComponent> createState() => _ListComponentState();
}

class _ListComponentState extends State<ListComponent> {
  int numItems = 0;

  loadNumItems() async {
    numItems  = await getNumItems(widget.groupUID, widget.listID);
    setState((){});
    print(numItems);
  }

  @override
  void initState() {
    super.initState();
    loadNumItems();
  }

  @override
  Widget build(BuildContext context) {
    bool? _isAdmin = context.read<GroupProvider>().isAdmin;
    return Card.filled(
      color: AppColors.lists_secondary,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.lists_primary, width: 2),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${AppLocalizations.of(context)!.created_by} ${widget.author}"),
            Padding(
              padding: EdgeInsets.all(10),
              child: ListTile(
                title: Text(widget.title),
                subtitle: Text(
                  "${numItems} ${AppLocalizations.of(context)!.items}",
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ListviewScreen(title: widget.title, uid: widget.listID),
                    ),
                  );
                  loadNumItems();
                },
                onLongPress: () {
                  String? userUID = FirebaseAuth.instance.currentUser?.uid;
                  if (_isAdmin! || userUID == widget.authorID) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.delete_list),
                          content: Text(
                            AppLocalizations.of(context)!.warning_delete_list,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                removeList(widget.groupUID, widget.listID);
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.remove),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Text(
              "${AppLocalizations.of(context)!.last_update} ${widget.lastUpdate.hour}:${widget.lastUpdate.minute} ${widget.lastUpdate.day}/${widget.lastUpdate.month}/${widget.lastUpdate.year}",
            ),
          ],
        ),
      ),
    );
  }
}
