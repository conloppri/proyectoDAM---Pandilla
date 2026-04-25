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

/// Estado de la pantalla de perfil.
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

  /// Construye la interfaz del perfil.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile, style: AppStyles.title),
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    /// Avatar del usuario
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          "assets/images/${_userInfo["avatar"]}",
                        ),
                      ),
                    ),
                    /// Información en formato de grid
                    StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      children: [
                        /// Nombre de usuario
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.primary,
                            child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.person, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.username),
                                subtitle: Text(_userInfo["name"], style: AppStyles.profileSub,),
                              ),
                            ),
                          ),
                        ),
                        /// Ocupación
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.calendar_secondary,
                            child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.work, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.job),
                                subtitle: Text(_userInfo["job"]),
                              ),
                            ),
                          ),
                        ),
                        /// Fecha de nacimiento
                        StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.lists_secondary,
                            child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.cake, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.birthdate),
                                subtitle: Text("${birthdateToString()} (${getAge()} ${AppLocalizations.of(context)!.years})"),
                              ),
                            ),
                          ),
                        ),
                        /// Colores favoritos
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount:2,
                          child: Card.filled(
                            color: AppColors.notes_primary,
                            child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.palette, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.fav_colors),
                                subtitle: Text(_userInfo["fav_colors"], style: AppStyles.profileSub),
                              ),
                            ),
                          ),
                        ),
                        /// Animal favorito
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 2,
                          child: Card.filled(
                            color: AppColors.secondary,
                            child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.pets, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.fav_animal),
                                subtitle: Text(_userInfo["fav_animal"], style: AppStyles.profileSub),
                              ),
                            ),
                          ),
                        ),
                        /// Hobbies
                        StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 1,
                          child: Card.filled(
                            color: AppColors.calendar_primary,
                            child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.sports_basketball, color: Colors.white),
                                title: Text(AppLocalizations.of(context)!.hobbies),
                                subtitle: Text(_userInfo["hobbies"], style: AppStyles.profileSub),
                              ),
                            ),
                          ),
                        ),
                        /// Descripción adicional
                        StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 2,
                          child: Card.filled(
                            color: AppColors.notes_secondary,
                            child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.star, color: Colors.white,),
                                title: Text(AppLocalizations.of(context)!.more_info),
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
    if(DateTime.now().isAfter(DateTime(date.day, date.month, thisYear))){
      age = age - 1 ;
    }
    return age;
  }
}
