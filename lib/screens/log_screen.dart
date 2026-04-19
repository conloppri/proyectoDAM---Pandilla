
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/components/date_picker_widget.dart';
import 'package:pandilla/screens/main_screen.dart';

import 'package:pandilla/screens/profile/profile_editor_screen.dart';


import '../core/app_colors.dart';
import '../core/firebase_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String _activeAction = "login";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 75),
        child: Column(
          children: [
            Container(
              height: 200,
              width: 200,
              child: Image.asset("assets/images/logo.png", fit: BoxFit.contain),
            ),
            _activeAction == "login"
                ? LogIn()
                : SignIn(), //Para cambiar entre registro e inicio de sesión
            SizedBox(height: 15),
            _activeAction == "login"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("¿Aún no tienes cuenta? "),
                      GestureDetector(
                        child: Text(
                          "Regístrate",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blueAccent,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _activeAction = "signin";
                          });
                        },
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("¿Ta estás registrado? "),
                      GestureDetector(
                        child: Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blueAccent,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _activeAction = "login";
                          });
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String _logEmail = "";
  String _logPsw = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //INICIO SESION
        Text(
          "Iniciar sesión:",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: "Correo electrónico",
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _logEmail = value;
            });
          },
        ),
        SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: "Contraseña",
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _logPsw = value;
            });
          },
        ),
        SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            setState(() async {
              if (await authUser(_logEmail, _logPsw)) {
                String? uid = FirebaseAuth.instance.currentUser?.uid;
                if(uid != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>
                       MainScreen()),
                  );
                }
              }
            });
          },
          child: Text("Enviar", style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Future<bool> authUser(String logEmail, String logPsw) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: logEmail,
        password: logPsw,
      );
      print("AUTENTICADO");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Autenticado")));
      return true;
    } on FirebaseAuthException catch (e) {
      print("ERROR CODE:  ${e.code}");
      print("ERROR MESSAGE: ${e.message}");
      if (e.code == 'invalid-credential') {
        //mismo code para psw y email
        print("No se ha encontrado ningún usuario registrado con ese email.");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Usuario no registrado.")));
      } else if (e.code == 'wrong-password') {
        print("Contraseña incorrecta");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Contraseña incorrecta.")));
      }
      return false;
    }
  }
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _signEmail = "";
  String _signPsw1 = "";
  String _signPsw2 = "";
  String _name = "";
  DateTime _birthDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Regístrate:",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: "Nombre",
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        DatePickerWidget(label: 'Fecha de nacimiento: ', firstDate: DateTime(1900), lastDate: DateTime.now(), onDateSelected: (date)=>_birthDate = date,),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: "Correo electrónico",
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _signEmail = value;
            });
          },
        ),
        SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: "Contraseña",
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _signPsw1 = value;
            });
          },
        ),
        SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: "Repite la contraseña",
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _signPsw2 = value;
            });
          },
        ),
        SizedBox(height: 15),
        ElevatedButton(
          onPressed: () async {
            if (await registerUser(_signEmail, _signPsw1, _signPsw2)) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditorScreen()),
              );
            }
          },
          child: Text("Enviar", style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Future<bool> registerUser(
    String signEmail,
    String signPsw1,
    String signPsw2,
  ) async {
    if (signPsw1 == signPsw2) {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: signEmail,
              password: signPsw1,
            );
        String? _userUID = FirebaseAuth.instance.currentUser?.uid;
        if (_userUID != null) {
          newUser(_name, _birthDate, signEmail);
        }

        return true;
      } on FirebaseAuthException catch (e) {
        print(
          "ERROR CODE:  ${e.code}",
        ); //invalid-email    weak-password    email-already-in-use
        print("ERROR MESSAGE: ${e.message}");

        if (e.code == 'invalid-email') {
          print("El email no es válido");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Email no válido.")));
        } else if (e.code == 'weak-password') {
          print("Contraseña inválida");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Contraseña débil.")));
        } else if (e.code == "email-already-in-use") {
          print("Email ya registrado");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Ese email ya ha sido registrado. Intente iniciar sesión.",
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Las contraseñas no coinciden.")));
    }
    return false;
  }
}
