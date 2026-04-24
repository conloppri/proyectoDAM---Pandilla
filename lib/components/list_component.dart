import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            Row(
              children: [
                Text("${AppLocalizations.of(context)!.created_by} ",style: TextStyle(color: Colors.black)),
                Text(widget.author, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                const Spacer(),
                if (_isAdmin!||userUID == widget.authorID)IconButton(onPressed: (){
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
                }, icon: Icon(Icons.delete, color: AppColors.lists_primary,))
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ListTile(
                title: Text(widget.title, style: TextStyle(color: AppColors.lists_primary, fontWeight: FontWeight.bold, fontSize: 20),),
                subtitle: Text(
                  "${numItems} ${AppLocalizations.of(context)!.items}", style: TextStyle(color: Colors.black, fontSize: 15)
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
              ),
            ),
            Text(
              "${AppLocalizations.of(context)!.last_update} ${DateFormat("HH:mm dd/MM/yyyy", "es_ES").format(widget.lastUpdate)}",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
