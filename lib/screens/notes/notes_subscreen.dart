import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class NotesSubscreen extends StatefulWidget {
  const NotesSubscreen({super.key});

  @override
  State<NotesSubscreen> createState() => _NotesSubscreenState();
}

class _NotesSubscreenState extends State<NotesSubscreen> {

  int _view = 1; // 1 = lista ; -1 = grid
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
                  color: AppColors.appbar_pink,
                ),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.view,
                      style: TextStyle(color: AppColors.appbar_pink, fontSize: 20),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _view = _view * (-1);
                        });
                      },
                      icon: Icon(_view == 1 ? Icons.list : Icons.grid_view_sharp),
                      color: AppColors.appbar_pink,
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: AppColors.appbar_pink),
            Expanded(
              child: StreamBuilder(
                stream: getNotes(_groupUID!),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting)return Center(child: CircularProgressIndicator());
                  if(snapshot.hasError)return Center(child: Text("Error: ${snapshot.error}"));
                  if(!snapshot.hasData||snapshot.data!.isEmpty)return Text(AppLocalizations.of(context)!.no_notes);
                  return _view == 1
                      ? ListView(children: snapshot.data!)
                      : GridView.count(crossAxisCount: 2, children: snapshot.data!);
                }
              ),
            ),
          ],
        ),
      );
  }
}

