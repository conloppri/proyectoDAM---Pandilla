import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:provider/provider.dart';

import '../core/providers/group_provider.dart';

class ItemComponent extends StatefulWidget {
  final String item;
  final String itemId;
  final String listID;
  final bool isCompleted;
  final DateTime createAt;
  const ItemComponent({super.key, required this.item, required this.itemId, required this.isCompleted, required this.listID, required this.createAt});

  @override
  State<ItemComponent> createState() => _ItemComponentState();
}

class _ItemComponentState extends State<ItemComponent> {
  @override
  Widget build(BuildContext context) {
    String? _groupUID = context.read<GroupProvider>().groupUID;
    return ListTile(
      title: Row(
        children: [
          Icon(widget.isCompleted?Icons.check_box_outlined:Icons.check_box_outline_blank, color: AppColors.lists_primary,),
          Text(widget.item, style: TextStyle(decoration: widget.isCompleted?TextDecoration.lineThrough:TextDecoration.none),),
          Spacer(),
          IconButton(onPressed: ()=>removeItem(_groupUID!, widget.listID, widget.itemId), icon: Icon(Icons.close, color: Colors.red,))
        ],
      ),
      onTap: ()=>changeItemStatus(_groupUID!, widget.listID, widget.itemId, !widget.isCompleted),
      onLongPress: (){},
    );
  }
}
