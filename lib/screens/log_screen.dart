//Básicos
import 'package:flutter/material.dart';
import 'package:pandilla/components/date_picker_widget.dart';
import 'package:pandilla/core/app_styles.dart';
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

/// Estado de la pantalla de login/registro [LogScreen]
///
/// Controla qué formulario está activo (login o signup).
class _LogScreenState extends State<LogScreen> {
  /// Indica la acción actual: "login" o "signin".
  String _activeAction = "login";

  /// Construye la interfaz de autenticación.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 75),
          child: Column(
            children: [
              /// Logo de la aplicación
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset("assets/icon.png", fit: BoxFit.contain),
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
                        Text(loc.no_account_yet),
                        GestureDetector(
                          child: Text(
                            loc.signup,
                            style: AppStyles.underlinedLogIn,
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
                        Text(loc.with_account),
                        GestureDetector(
                          child: Text(
                            loc.login,
                            style: AppStyles.underlinedLogIn
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

/// Estado del formulario de login [LogIn]
class _LogInState extends State<LogIn> {
  /// Email introducido por el usuario.
  String _logEmail = "";

  /// Contraseña introducida por el usuario.
  String _logPsw = "";

  /// Construye el formulario de inicio de sesión.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        ///Titulo: INICIO SESION
        Text(
          loc.login,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),

        const SizedBox(height: 15),

        /// Campo email
        TextField(
          decoration: InputDecoration(
            fillColor: AppColors.profileLowerSecondary,
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: loc.email,
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
            fillColor: AppColors.profileLowerSecondary,
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: loc.password,
          ),
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _logPsw = value;
            });
          },
        ),
        ///Recuperación de contraseña
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextButton(onPressed: (){
            showDialog(context: context, builder: (context){
              TextEditingController emailController = TextEditingController();
              return AlertDialog( //Diálogo para introducir correo para recuperar contraseña
                title: Text(loc.reset_psw),
                content: Column(
                  children: [
                    Text(loc.email_to_reset_psw),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: loc.email
                      ),
                    )
                  ],
                ),
                actions: [
                  ///Botón cancelar
                  TextButton(onPressed: ()=>Navigator.pop(context), child: Text(loc.cancel)),
                  ///Botón restablecer
                  TextButton(onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try{
                      //Intentamos enviar correo de reseteo de contraseña
                      await resetPassword(emailController.text);

                      //Comunica al usuario que se envió el correo, en caso de que el correo existiera en la base de datos
                      messenger.showSnackBar(SnackBar(content: Text(loc.reset_email_ready)));

                      navigator.pop();

                    }on FirebaseAuthException catch(e){ //email no válido
                      debugPrint("Error al restablecer contraseña: $e");
                      messenger.showSnackBar(SnackBar(content: Text(loc.error_invalid_email)));
                    } catch(e){ //Otros errores
                      messenger.showSnackBar(SnackBar(content: Text(loc.error_try_again)));
                    }
                  }, child: Text(loc.reset))
                ],
              );
            });
          }, child: Text(loc.forgot_psw, style: const TextStyle(decoration: TextDecoration.underline),)),
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
            loc.submit,
            style: AppStyles.buttonTextStyle,
          ),
        ),
      ],
    );
  }

  /// Autentica al usuario en Firebase Authentication.
  ///
  /// Retorna `true` si el login es correcto, `false` en caso contrario.
  ///
  /// Parámetros:
  /// - [logEmail] Email de inicio de sesión.
  /// - [logPsw] Contraseña para iniciar sesión
  ///
  /// Lanza:
  /// - [FirebaseAuthException] en caso de credenciales incorrectos
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

  /// Envía un correo para restablecer la contraseña del usuario.
  ///
  /// Utiliza Firebase Authentication para generar un enlace de
  /// restablecimiento de contraseña y enviarlo al email proporcionado.
  ///
  /// Si ocurre un error durante el proceso (por ejemplo, email inválido
  /// o usuario no registrado), se captura la excepción de Firebase,
  /// se registra en consola y se vuelve a lanzar.
  ///
  /// Parámetros:
  /// - [email]: Dirección de correo electrónico del usuario.
  ///
  /// Lanza:
  /// - [FirebaseAuthException]: si Firebase devuelve un error al enviar
  ///   el correo de restablecimiento.
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint("Error al restablecer contraseña: ${e.message}");
      rethrow;
    }
  }
}

/// Formulario de registro de usuario.
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

/// Estado del formulario de registro [SignIn]
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
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      spacing: 15,
      children: [
        /// Título: REGISTRARSE
        Text(
          loc.signup,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),

        /// Nombre de usuario
        TextField(
          maxLength: 20,
          decoration: InputDecoration(
            fillColor: AppColors.profileLowerSecondary,
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: loc.username,
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
          label: '${loc.birthdate}: ',
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          onDateSelected: (date) => _birthDate = date,
        ),
        ///Email
        TextField(
          decoration: InputDecoration(
            fillColor: AppColors.profileLowerSecondary,
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: loc.email,
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
            fillColor: AppColors.profileLowerSecondary,
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: loc.password,
          ),
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _signPsw1 = value;
            });
          },
        ),
        /// Repetir contraseña
        TextField(
          decoration: InputDecoration(
            fillColor: AppColors.profileLowerSecondary,
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: loc.repeat,
          ),
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _signPsw2 = value;
            });
          },
        ),
        ///Tooltip con indicaciones pra contraseña
        Tooltip(
          message: loc.psw_indications,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, color: AppColors.primary,),
              Text(loc.hold),
            ],
          ),
        ),
        /// Botón de registro
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            if(_name.length<4){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.error_username_too_short)));
            }else {
              if (await registerUser(_signEmail, _signPsw1, _signPsw2)) { //Intentamos registrar. En caso positivo => Editar Perfil
                navigator.pushReplacement(MaterialPageRoute(
                    builder: (context) => const ProfileEditorScreen()),);
              }
            }
          },
          child: Text(
            loc.submit,
            style: AppStyles.buttonTextStyle
          ),
        ),
      ],
    );
  }
  /// Registra un nuevo usuario en Firebase Authentication.
  ///
  /// También crea el documento inicial del usuario en Firestore.
  ///
  /// Parámetros:
  /// - [signEmail] Email para registro
  /// - [signPsw1] Contraseña para crear cuenta
  /// - [signPsw2] Repetición de contraseña para verificar
  ///
  /// Lanza:
  /// - [FirebaseAuthException] Si las credenciales son incorrectas, el usuario
  /// ya esta registrado o la contraseña es muy débil.
  Future<bool> registerUser(String signEmail, String signPsw1, String signPsw2) async {
    final messenger = ScaffoldMessenger.of(context);
    final loc = AppLocalizations.of(context)!;

    //Si las dos contraseñas coinciden
    if (signPsw1 == signPsw2) {
      if(validatePsw(signPsw1)) { //validamos que la contraseña cumpla los requisitos mínimos
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
          } else if (e.code ==
              'PASSWORD_DOES_NOT_MEET_REQUIREMENTS') { //Contraseña débil
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
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.error_week_psw),
          ),
        );
      }
    } else { //contraseñas no coinciden
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.error_psw_not_match),
        ),
      );
    }
    return false;
  }
  /// Valida si una contraseña cumple con los requisitos de seguridad.
  ///
  /// La contraseña debe cumplir las siguientes condiciones:
  /// - Al menos 8 caracteres de longitud.
  /// - Al menos una letra minúscula.
  /// - Al menos una letra mayúscula.
  /// - Al menos un número.
  /// - Al menos un carácter especial permitido (@$!%*?&.,-_).
  ///
  /// Parámetros:
  /// - [psw]: Contraseña a validar.
  ///
  /// Retorna:
  /// - `true` si la contraseña cumple el patrón de seguridad.
  /// - `false` si no cumple los requisitos.
  bool validatePsw(String psw){
    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&.,-_])[A-Za-z\d@$!%*?&.,-_]{8,}$';
    final RegExp regex = RegExp(pattern);
    return regex.hasMatch(psw);
  }
}
