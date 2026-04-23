import 'package:flutter/material.dart';
import 'package:pandilla/components/item_component.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/providers/group_provider.dart';

class ListviewScreen extends StatefulWidget {
  final String title;
  final String uid;
  const ListviewScreen({super.key, required this.title, required this.uid});

  @override
  State<ListviewScreen> createState() => _ListviewScreenState();
}

class _ListviewScreenState extends State<ListviewScreen> {
  final TextEditingController _controller = TextEditingController();
  String _newItem = "";
  @override
  Widget build(BuildContext context) {
    String? _groupName = context.read<GroupProvider>().groupName;
    String? _groupUID = context.read<GroupProvider>().groupUID;
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName!),
        backgroundColor: AppColors.lists_primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(widget.title, style: AppStyles.title,),
              Expanded(
                child: StreamBuilder(
                  stream: getItems(_groupUID!, widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    if (snapshot.hasError)
                      return Center(child: Text("Error: ${snapshot.error}"));
                    if (!snapshot.hasData || snapshot.data!.isEmpty)
                      return Text(AppLocalizations.of(context)!.no_lists);
                    List<ItemComponent> items = snapshot.data!;
                    return ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (context, int index){
                        return items[index];
                      },
                      separatorBuilder: (context, int index) {
                        return Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 0.1,
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLength: 30,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lists_primary),
                        ),
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.new_item,
                      ),
                      onChanged: (value) => _newItem = value,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(bottom: 25),
                    child: FloatingActionButton(
                      backgroundColor: AppColors.lists_secondary,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        if (_newItem == "") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.warning_empty_item),
                            ),
                          );
                        } else {
                          addItem(_groupUID, widget.uid, _newItem);
                          setState(() {
                            _controller.clear();
                          });
                        }
                      },
                      child: Icon(Icons.add, size: 30,),
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
