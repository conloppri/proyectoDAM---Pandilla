import 'package:flutter/material.dart';
import 'package:pandilla/core/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLang = "Español";
  bool darkMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajustes"),
      backgroundColor: AppColors.primary,),
      body: SafeArea(
          child: Expanded(
            child: ListView(
              padding: EdgeInsetsGeometry.all(20),
              children: [
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Idioma", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        Text(_selectedLang)
                      ],
                    ),
                  ),
                  onTap: (){
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        title: Text("Idioma"),
                        content: Container(
                          height: MediaQuery.of(context).size.height*0.8,
                          width: double.maxFinite,
                          child: ListView(
                            children: [
                              ListTile(
                              title: Text("Español"),
                              onTap: (){
                                _selectedLang = "Español";
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                              ListTile(
                                title: Text("Inglés"),
                                onTap: (){
                                  _selectedLang = "Inglés";
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
                Divider(),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Modo oscuro", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Switch(value: darkMode,
                          onChanged: (value){
                            setState(() {
                              darkMode = value;
                            });
                      })
                    ],
                  ),
                ),
                Divider(),
            
              ],
            ),
          )),
    );
  }
}
