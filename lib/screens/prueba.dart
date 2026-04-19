import 'package:flutter/material.dart';
import 'package:pandilla/core/firebase_service.dart';

class Prueba extends StatefulWidget {
  const Prueba({super.key});

  @override
  State<Prueba> createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUsers(),
        builder: (context, snapshot){
          return ListView.builder(itemCount: snapshot.data?.length,
          itemBuilder: (context, index){
            if(snapshot.hasData){
              return Text(snapshot.data?[index]['name']);
            }
            return CircularProgressIndicator();
          },);
        });
  }
}
