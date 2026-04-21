
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandilla/components/date_picker_widget.dart';
import 'package:pandilla/l10n/app_localizations.dart';
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
            const SizedBox(height: 15),
            _activeAction == "login"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.no_account_yet),
                      GestureDetector(
                        child: Text(
                          AppLocalizations.of(context)!.signup,
                          style: const TextStyle(
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
                      Text(AppLocalizations.of(context)!.with_account),
                      GestureDetector(
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style: const TextStyle(
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
          AppLocalizations.of(context)!.login,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
        const SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: AppLocalizations.of(context)!.email,
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _logEmail = value;
            });
          },
        ),
        const SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: AppLocalizations.of(context)!.password,
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
        const SizedBox(height: 15),
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
          child: Text(AppLocalizations.of(context)!.submit, style: TextStyle(fontSize: 20)),
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
      return true;
    } on FirebaseAuthException catch (e) {
      print("ERROR CODE:  ${e.code}");
      print("ERROR MESSAGE: ${e.message}");
      if (e.code == 'invalid-credential') {
        //mismo code para psw y email
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_user_not_found)));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_incorrect_psw)));
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
          AppLocalizations.of(context)!.signup,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
        const SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: AppLocalizations.of(context)!.username,
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        DatePickerWidget(label: '${AppLocalizations.of(context)!.birthdate}: ', firstDate: DateTime(1900), lastDate: DateTime.now(), onDateSelected: (date)=>_birthDate = date,),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: AppLocalizations.of(context)!.email,
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _signEmail = value;
            });
          },
        ),
        const SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: AppLocalizations.of(context)!.password,
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
        const SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: AppLocalizations.of(context)!.repeat,
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
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () async {
            if (await registerUser(_signEmail, _signPsw1, _signPsw2)) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditorScreen()),
              );
            }
          },
          child: Text(AppLocalizations.of(context)!.submit, style: TextStyle(fontSize: 20)),
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
        String? userUID = FirebaseAuth.instance.currentUser?.uid;
        if (userUID != null) {
          newUser(_name, _birthDate, signEmail);
        }

        return true;
      } on FirebaseAuthException catch (e) {
        print(
          "ERROR CODE:  ${e.code}",
        ); //invalid-email    weak-password    email-already-in-use
        print("ERROR MESSAGE: ${e.message}");

        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_invalid_email)));
        } else if (e.code == 'weak-password') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_week_psw)));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.error_email_registered,
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_psw_not_match)));
    }
    return false;
  }
}
