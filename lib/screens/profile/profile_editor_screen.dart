//Básicos
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Componentes personalizados
import 'package:pandilla/components/avatar_picker.dart';
//Estilos y colores
import 'package:pandilla/core/app_colors.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Providers y servicios
import 'package:pandilla/core/providers/user_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
//Pantallas
import 'package:pandilla/screens/profile/profile_screen.dart';

import '../../core/app_styles.dart';


/// Pantalla de edición del perfil del usuario [ProfileEditorScreen]
///
/// Permite al usuario modificar su información personal como:
/// - Trabajo
/// - Colores favoritos
/// - Animales favorito
/// - Hobbies
/// - Información adicional
/// - Avatar
///
/// Los datos se cargan desde Firestore al inicializar la pantalla
/// y se guardan nuevamente en Firestore.
class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}
///Estado de la pantalla de edicción de perfil
class _ProfileEditorScreenState extends State<ProfileEditorScreen> {

  /// UID del usuario autenticado
  String? userUID = FirebaseAuth.instance.currentUser?.uid;

  /// Información del usuario obtenida desde Firestore
  Map _userInfo = {};

  String userName = "";

  /// Controladores de texto para edición de perfil
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _animalsController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _moreController = TextEditingController();

  /// Fecha de nacimiento formateada para mostrar en UI
  String birthdate = "";

  /// Avatar seleccionado actualmente (por defecto => panda.png)
  String _selectedAvatar = "panda.png";

  /// Lista de avatares disponibles
  final List<String> _avatarList = ["panda", "bear", "polar", "black_cat", "siames_cat", "dog", "poodle", "bunny", "duck", "elephant", "fox", "koala", "lion", "tiger", "monkey", "penguin", "pig", "raccoon",];

  /// Estilo reutilizable para títulos en la pantalla
  TextStyle titleStyle = const TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  ///Variable que controla si la información ha llegado antes de mostrarla
  bool loading = true;

  /// Carga la información del usuario desde Firestore
  ///
  /// Rellena los controladores con los datos actuales del perfil
  /// para permitir su edición.
  loadProfile() async {
    try {
      _userInfo = await getUser(userUID!);
      _jobController.text = _userInfo["job"];
      _colorsController.text = _userInfo["fav_colors"];
      _animalsController.text = _userInfo["fav_animal"];
      _hobbiesController.text = _userInfo["hobbies"];
      _moreController.text = _userInfo["description"];
      DateTime date = _userInfo["bithdate"].toDate();
      birthdate = DateFormat("dd/MM/yyyy", "es_ES").format(date);
      _selectedAvatar = _userInfo["avatar"];
      userName = _userInfo["name"];
      loading = false;
      setState(() {});
    } catch (e) {
      debugPrint("Error cargando información: $e");
    }
  }

  ///Inicializa el estado y carga los datos del perfil
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// Construye la interfaz del perfil
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.my_profile),
        backgroundColor: AppColors.primary,
        actions: [
          /// Botón para guardar cambios del perfil
          TextButton(onPressed: ()=>saveInfo(), child: Text(loc.save))
        ],
      ),
      body: SafeArea(
        child: loading?const Center(child: CircularProgressIndicator())
        :Container(
          padding: const EdgeInsets.all(8.0),
          /// Contenido principal de edición de perfil
          child: Column(
            children: [
              /// Selector de avatar
              AvatarPicker(
                  selectedAvatar: _selectedAvatar,
                  avatarList: _avatarList,
                  onSelectedAvatar: (avatar){
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  }),

              const SizedBox(height: 10),

              /// Lista de campos editables
              Expanded(
                child: ListView(
                  children: [
                    /// Trabajo
                    Card.filled(
                      color: AppColors.pinkNote,
                      child: ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(loc.job),
                        subtitle: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.profileLowerPink,
                              enabledBorder: AppStyles.outlineInputBorderRounded
                          ),
                          controller: _jobController,
                        ),
                      ),
                    ),
                    /// Colores favoritos
                    Card.filled(
                      color: AppColors.notesPrimary,
                      child: ListTile(
                        leading: const Icon(Icons.palette),
                        title: Text(loc.fav_colors),
                        subtitle: TextField(
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.notesSecondary,
                              enabledBorder: AppStyles.outlineInputBorderRounded
                          ),
                          controller: _colorsController,
                        ),
                      ),
                    ),
                    /// Animal favorito
                    Card.filled(
                      color: AppColors.secondary,
                      child: ListTile(
                        leading: const Icon(Icons.pets),
                        title: Text(loc.fav_animal),
                        subtitle: TextField(
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.profileLowerSecondary,
                            enabledBorder: AppStyles.outlineInputBorderRounded
                          ),
                          controller: _animalsController,
                        ),
                      ),
                    ),
                    /// Hobbies
                    Card.filled(
                      color: AppColors.calendarPrimary,
                      child: ListTile(
                        leading: const Icon(Icons.sports_basketball),
                        title: Text(loc.hobbies),
                        subtitle: TextField(
                          controller: _hobbiesController,
                          minLines: 2,
                          maxLines: 10,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.calendarSecondary,
                              enabledBorder: AppStyles.outlineInputBorderRounded
                          ),
                        ),
                      ),
                    ),
                    /// Información adicional
                    Card.filled(
                      color: AppColors.listsPrimary,
                      child: ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(loc.more_info),
                        subtitle: TextField(
                          controller: _moreController,
                          minLines: 3,
                          maxLines: 10,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.listsSecondary,
                                enabledBorder: AppStyles.outlineInputBorderRounded
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
  /// Guarda los cambios del perfil en Firestore
  ///
  /// Si la operación es correcta:
  /// - Actualiza el UserProvider
  /// - Navega al ProfileScreen
  saveInfo() async {
    UserProvider userProvider = context.read<UserProvider>();
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    //Intentamos guardar perfil
      bool saved = false;
      try {
        saved = await saveProfile(
            userName,
            _colorsController.text,
            _jobController.text,
            _hobbiesController.text,
            _moreController.text,
            _selectedAvatar,
            _animalsController.text
        );
      }catch (e) {
        debugPrint("Error al actualizar perfil: $e");
        messenger.showSnackBar(SnackBar(content: Text(loc.error_try_again)));
      }
      if (saved) { //hacemos cambios en el UserProvider
        userProvider.setUser(userUID!,userName, _selectedAvatar,
            _userInfo["email"]);
        navigator.push(MaterialPageRoute( //vamos a la pantalla de visualización de perfil
            builder: (context) => ProfileScreen(userProfileUID: userUID!)));
      }

  }
}
