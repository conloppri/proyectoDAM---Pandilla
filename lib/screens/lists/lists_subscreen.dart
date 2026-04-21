import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/firebase_service.dart';
import '../../core/providers/group_provider.dart';
import '../../l10n/app_localizations.dart';

class ListsSubscreen extends StatefulWidget {
  const ListsSubscreen({super.key});

  @override
  State<ListsSubscreen> createState() => _ListsSubscreenState();
}

class _ListsSubscreenState extends State<ListsSubscreen> {
  @override
  Widget build(BuildContext context) {
    String? _groupUID = context.watch<GroupProvider>().groupUID;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.sort_outlined, size: 30),
                color: AppColors.lists_primary,
              ),
            ],
          ),
          Divider(color: AppColors.lists_primary),
          Expanded(
            child: StreamBuilder(
                stream: getLists(_groupUID!),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting)return Center(child: CircularProgressIndicator());
                  if(snapshot.hasError)return Center(child: Text("Error: ${snapshot.error}"));
                  if(!snapshot.hasData||snapshot.data!.isEmpty)return Text(AppLocalizations.of(context)!.no_lists);
                  return ListView(children: snapshot.data!);
                }
            ),
          ),
        ],
      ),
    );
  }
}