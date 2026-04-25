//Básicos
import 'package:flutter/material.dart';
import 'package:pandilla/components/date_picker_widget.dart';
import 'package:pandilla/l10n/app_localizations.dart';
//Pantallas
import 'package:pandilla/screens/profile/profile_editor_screen.dart';

//Estilos y colores
import '../core/app_colors.dart';
//Firebase
import '../core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Pantalla de autenticación.
///
/// Permite alternar entre:
/// - Inicio de sesión
/// - Registro de usuario
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

/// Estado de la pantalla de login/registro.
///
/// Controla qué formulario está activo (login o signup).
class _LogScreenState extends State<LogScreen> {
  /// Indica la acción actual: "login" o "signin".
  String _activeAction = "login";

  /// Construye la interfaz de autenticación.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 75),
        child: Column(
          children: [
            /// Logo de la aplicación
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset("assets/images/logo.png", fit: BoxFit.contain),
            ),
            /// Alternancia entre login y registro
            _activeAction == "login"
                ? const LogIn()
                : const SignIn(),

            const SizedBox(height: 15),

            /// Texto inferior para cambiar entre formularios
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

/// Formulario de inicio de sesión.
class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

/// Estado del formulario de login.
class _LogInState extends State<LogIn> {
  /// Email introducido por el usuario.
  String _logEmail = "";

  /// Contraseña introducida por el usuario.
  String _logPsw = "";

  /// Construye el formulario de inicio de sesión.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///Titulo: INICIO SESION
        Text(
          AppLocalizations.of(context)!.login,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),

        const SizedBox(height: 15),

        /// Campo email
        TextField(
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: AppLocalizations.of(context)!.email,
          ),
          onChanged: (value) {
            setState(() {
              _logEmail = value;
            });
          },
        ),

        const SizedBox(height: 15),

        /// Campo contraseña
        TextField(
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
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
        /// Botón de inicio de sesión
        ElevatedButton(
          onPressed: () async {
              final navigator = Navigator.of(context); //Uso del context antes del metodo asíncrono
              if (await authUser(_logEmail, _logPsw)) { //Intenta el inicio de sesión y en caso de positvo, envía al mainScreen
                String? uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  navigator.pushReplacementNamed("/home",);
                }
              }
          },
          child: Text(
            AppLocalizations.of(context)!.submit,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  /// Autentica al usuario en Firebase Authentication.
  ///
  /// Retorna `true` si el login es correcto, `false` en caso contrario.
  Future<bool> authUser(String logEmail, String logPsw) async {
    final messenger = ScaffoldMessenger.of(context);
    final loc = AppLocalizations.of(context)!;
    try { //intenta iniciar sesión:
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: logEmail,
        password: logPsw,
      );
      return true;
    } on FirebaseAuthException catch (e) { //Capturamos error
      if (e.code == 'invalid-credential') { //Credencial incorrecta
        messenger.showSnackBar(
          SnackBar(
            content: Text(loc.error_user_not_found),
          ),
        );
      } else if (e.code == 'wrong-password') { //contraseña incorrecta
        messenger.showSnackBar(
          SnackBar(
            content: Text(loc.error_incorrect_psw),
          ),
        );
      }
      return false;
    }
  }
}

/// Formulario de registro de usuario.
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

/// Estado del formulario de registro.
class _SignInState extends State<SignIn> {
  /// Email del nuevo usuario.
  String _signEmail = "";

  /// Contraseña introducida.
  String _signPsw1 = "";

  /// Repetición de contraseña.
  String _signPsw2 = "";

  /// Nombre del usuario.
  String _name = "";

  /// Fecha de nacimiento seleccionada.
  DateTime _birthDate = DateTime.now();

  /// Construye el formulario de registro.
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      children: [
        /// Título: REGISTRARSE
        Text(
          AppLocalizations.of(context)!.signup,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),

        /// Nombre de usuario
        TextField(
          maxLength: 20,
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
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
        /// Fecha de nacimiento
        DatePickerWidget(
          buttonColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 16),
          selectedDate: DateTime.now(),
          label: '${AppLocalizations.of(context)!.birthdate}: ',
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onDateSelected: (date) => _birthDate = date,
        ),
        ///Email
        TextField(
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
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

        /// Contraseña
        TextField(
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
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
        ///Tooltip con indicaciones pra contraseña
        Tooltip(
          message: AppLocalizations.of(context)!.psw_indications,
          child: const Icon(Icons.help_outline),
        ),

        /// Repetir contraseña
        TextField(
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
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

        /// Botón de registro
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            if(_name.length<4){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_username_too_short)));
            }else {
              if (await registerUser(_signEmail, _signPsw1, _signPsw2)) { //Intentamos registrar. En caso positivo => Editar Perfil
                navigator.pushReplacement(MaterialPageRoute(
                    builder: (context) => ProfileEditorScreen()),);
              }
            }
          },
          child: Text(
            AppLocalizations.of(context)!.submit,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
  /// Registra un nuevo usuario en Firebase Authentication.
  ///
  /// También crea el documento inicial del usuario en Firestore.
  Future<bool> registerUser(String signEmail, String signPsw1, String signPsw2,) async {
    final messenger = ScaffoldMessenger.of(context);
    final loc = AppLocalizations.of(context)!;

    //Si las dos contraseñas coinciden
    if (signPsw1 == signPsw2) {
      try {
        //Intenta crear usuario en FirebaseAuth
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signEmail,
          password: signPsw1,
        );
        String? userUID = FirebaseAuth.instance.currentUser?.uid;
        if (userUID != null) { //Y creamos el usuario en Firestore
          newUser(_name, _birthDate, signEmail);
        }
        return true;
      } on FirebaseAuthException catch (e) { //Capturamos errores
        if (e.code == 'invalid-email') { //Email no válido
          messenger.showSnackBar(
            SnackBar(
              content: Text(loc.error_invalid_email),
            ),
          );
        } else if (e.code == 'weak-password') { //Contraseña débil
          messenger.showSnackBar(
            SnackBar(
              content: Text(loc.error_week_psw),
            ),
          );
        } else if (e.code == "email-already-in-use") { //Email ya registrado
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                loc.error_email_registered,
              ),
            ),
          );
        }
      }
    } else { //contraseñas no coinciden
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.error_psw_not_match),
        ),
      );
    }
    return false;
  }
}
