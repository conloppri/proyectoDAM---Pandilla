//Básicos
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
//Componentes personalizdos
import 'package:pandilla/components/left_drawer.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Estilos y colores
import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
//Servicios localización
import '../../l10n/app_localizations.dart';

/// Pantalla de perfil de usuario.
///
/// Muestra la información pública del usuario seleccionado.
/// Si el usuario visualizado es el propietario del perfil,
/// se habilita la opción de edición.
class ProfileScreen extends StatefulWidget {
  /// UID del usuario cuyo perfil se va a mostrar (puede ser propio o de otro usuario)
  final String userProfileUID;

  const ProfileScreen({super.key, required this.userProfileUID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// Estado de la pantalla de perfil [ProfileScreen]
///
/// Gestiona la carga de datos del usuario y la lógica de propietario.
class _ProfileScreenState extends State<ProfileScreen> {
  /// Información del usuario obtenida desde Firestore.
  Map<String, dynamic> _userInfo = {};

  /// Indica si el usuario autenticado es el propietario del perfil.
  bool isOwner = false;

  /// Carga los datos del perfil desde la base de datos.
  ///
  /// También determina si el perfil pertenece al usuario actual.
  loadProfile() async {
    _userInfo = await getUser(widget.userProfileUID);
    String? ownerUID = FirebaseAuth.instance.currentUser?.uid;
    ownerUID==widget.userProfileUID?isOwner = true:isOwner=false;
    setState(() {});
  }
  /// Inicializa la carga del perfil.
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// Construye la interfaz del perfil a partir de
  /// la información precargada.
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final double iconSize = MediaQuery.of(context).size.width*0.06;
    return Stack(
      children: [
        Positioned.fill(child: Image.asset("assets/images/profile_background.png", fit: BoxFit.cover)),
        Scaffold(
          appBar: AppBar(
            title: Text(loc.profile, style: AppStyles.appBarTitle),
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            actions: [
              /// Botón de edición visible solo para el propietario
              if(isOwner) IconButton(onPressed: ()=>Navigator.pushReplacementNamed(context, '/profileEditor'), icon: const Icon(Icons.edit))
            ],
          ),
          drawer: const LeftDrawer(),
          /// Estado de carga o contenido del perfil
          body: _userInfo.isEmpty?const CircularProgressIndicator()
              :SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        /// Avatar del usuario
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.15,
                            backgroundImage: AssetImage(
                              "assets/images/${_userInfo["avatar"]}",
                            ),
                          ),
                        ),
                        /// Información en formato de grid modular
                        StaggeredGrid.count(
                          crossAxisCount: 4,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          children: [
                            /// Nombre de usuario
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 1.5,
                              child: Card.filled(
                                color: AppColors.primary,
                                child: Center(
                                  child: ListTile(
                                    title: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.person, color: Colors.white, size: iconSize),
                                        Text(loc.user, style: AppStyles.profileTitles),
                                      ],
                                    ),
                                    subtitle: Text(_userInfo["name"], style: AppStyles.profileSub,),
                                  )
                                ),
                              ),
                            ),
                            /// Ocupación
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 1.5,
                              child: Card.filled(
                                color: AppColors.pinkNote,
                                child: Center(
                                  child: ListTile(
                                    title: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.work, color: Colors.white, size: iconSize),
                                        Text(loc.job, style: AppStyles.profileTitles),
                                      ],
                                    ),
                                    subtitle: Text(_userInfo["job"], style: AppStyles.profileSub),
                                  ),
                                ),
                              ),
                            ),
                            /// Fecha de nacimiento
                            StaggeredGridTile.count(
                              crossAxisCellCount: 4,
                              mainAxisCellCount: 1.5,
                              child: Card.filled(
                                color: AppColors.infoPrimary,
                                child: Center(
                                  child: ListTile(
                                    title: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.cake, color: Colors.white, size: iconSize),
                                        Text(loc.birthdate, style: AppStyles.profileTitles),
                                      ],
                                    ),
                                    subtitle: Text("${birthdateToString()} (${getAge()} ${loc.years})", style: AppStyles.profileSub),
                                  ),
                                ),
                              ),
                            ),
                            /// Colores favoritos
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 1.5,
                              child: Card.filled(
                                color: AppColors.notesPrimary,
                                child: Center(
                                  child: ListTile(
                                    title: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.palette, color: Colors.white, size: iconSize),
                                        Expanded(child: Text(loc.fav_colors, style: AppStyles.profileTitles)),
                                      ],
                                    ),
                                    subtitle: Text(_userInfo["fav_colors"], style: AppStyles.profileSub),
                                  ),
                                ),
                              ),
                            ),
                            /// Animal favorito
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 1.5,
                              child: Card.filled(
                                color: AppColors.secondary,
                                child: Center(
                                  child: ListTile(
                                    title: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.pets, color: Colors.white, size: iconSize),
                                        Expanded(child: Text(loc.fav_animal, style: AppStyles.profileTitles)),
                                      ],
                                    ),
                                    subtitle: Text(_userInfo["fav_animal"], style: AppStyles.profileSub),
                                  ),
                                ),
                              ),
                            ),
                            /// Hobbies
                            StaggeredGridTile.fit(
                              crossAxisCellCount: 4,
                              child: Card.filled(
                                color: AppColors.calendarPrimary,
                                child: Center(
                                  child: ListTile(
                                    title: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.sports_basketball, color: Colors.white, size: iconSize),
                                        Text(loc.hobbies, style: AppStyles.profileTitles),
                                      ],
                                    ),
                                    subtitle: Text(_userInfo["hobbies"], style: AppStyles.profileSub),
                                  ),
                                ),
                              ),
                            ),
                            /// Descripción adicional
                            StaggeredGridTile.fit(
                              crossAxisCellCount: 4,
                              child: Card.filled(
                                color: AppColors.listsPrimary,
                                child: Center(
                                  child: ListTile(
                                    title: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.star, color: Colors.white, size: iconSize),
                                        Text(loc.more_info, style: AppStyles.profileTitles),
                                      ],
                                    ),
                                    subtitle: Text(_userInfo["description"], style: AppStyles.profileSub),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }

  /// Convierte la fecha de nacimiento a formato legible.
  String birthdateToString(){
    DateTime date = _userInfo["bithdate"].toDate();
    return DateFormat("dd/MM/yyyy", "es_ES").format(date);
  }

  /// Calcula la edad del usuario.
  int getAge(){
    DateTime date = _userInfo["bithdate"].toDate();
    int thisYear = DateTime.now().year;
    int age = thisYear - date.year;
    //Comprueba si ya lo ha cumplido esta año o aún no
    if(DateTime.now().isBefore(DateTime(thisYear, date.month, date.day))){
      age = age - 1 ;
    }
    return age;
  }
}
