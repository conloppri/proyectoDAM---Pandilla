import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/list_component.dart';
import '../../core/app_colors.dart';
import '../../core/services/firebase_service.dart';
import '../../core/providers/group_provider.dart';
import '../../l10n/app_localizations.dart';

class ListsSubscreen extends StatefulWidget {
  const ListsSubscreen({super.key});

  @override
  State<ListsSubscreen> createState() => _ListsSubscreenState();
}

class _ListsSubscreenState extends State<ListsSubscreen> {
  String sortedBy = "ABC";
  @override
  Widget build(BuildContext context) {
    String? _groupUID = context.watch<GroupProvider>().groupUID;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.sort_by, style: TextStyle(color: AppColors.lists_primary, fontSize: 15),),
              IconButton(onPressed: (){
                setState(() {
                  sortedBy=="ABC"
                      ?sortedBy="lastUpdate"
                      :sortedBy="ABC";
                });
              },
                  icon: Icon(sortedBy == "ABC" ? Icons.sort_by_alpha : Icons.access_time, size: 30,),
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
                  if(!snapshot.hasData||snapshot.data!.isEmpty)return Center(child: Text(AppLocalizations.of(context)!.no_lists));
                  List<ListComponent> data = snapshot.data!;
                  if(sortedBy =="ABC"){
                    data.sort((a,b)=>a.title.compareTo(b.title));
                  }else{
                    data.sort((a,b)=>b.lastUpdate.compareTo(a.lastUpdate));
                  }
                  return ListView(children: snapshot.data!);
                }
            ),
          ),
        ],
      ),
    );
  }
}