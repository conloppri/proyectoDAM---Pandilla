//Básico
import 'package:flutter/material.dart';
//Componentes personalizados
import 'package:pandilla/components/avatar_picker.dart';
//Estilos y colores
import 'package:pandilla/core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
//Servicios y providers
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
//Pantallas
import 'package:pandilla/features/group/screens/group_screen.dart';

/// Pantalla de edición de la información de un grupo.
///
/// Permite modificar:
/// - Nombre del grupo
/// - Descripción
/// - Avatar
/// - Código de invitación
///
/// También actualiza los datos en Firestore y en el `GroupProvider`.
class InfoEditor extends StatefulWidget {
  /// ID del grupo a editar.
  final String groupUID;

  /// Nombre actual del grupo.
  final String groupName;

  const InfoEditor({
    super.key,
    required this.groupUID,
    required this.groupName,
  });

  @override
  State<InfoEditor> createState() => _InfoEditorState();
}

/// Estado de la pantalla de edición de grupo.
///
/// Gestiona:
/// - Carga de datos del grupo
/// - Controladores de formularios
/// - Selección de avatar
/// - Regeneración de código
class _InfoEditorState extends State<InfoEditor> {
  /// Controlador del campo nombre.
  final TextEditingController _nameController = TextEditingController();

  /// Controlador del campo descripción.
  final TextEditingController _descController = TextEditingController();

  /// Código de invitación del grupo.
  String _code = "";

  /// Lista de avatares disponibles.
  final List<String> _avatarList = [
    "reading",
    "cooking",
    "videogames",
    "football",
    "party",
    "playing",
    "pool",
    "working",
  ];

  /// Avatar seleccionado actualmente. (reading.png por defecto)
  String _selectedAvatar = "reading.png";

  /// Información completa del grupo.
  Map<String, dynamic> info = {};

  ///Variable que controla si la información ha llegado antes de mostrarla
  bool loading = true;

  /// Carga la información del grupo desde Firestore
  /// y la asigna a los controladores y variables locales.
  loadInfo() async {
    try {
      info = await getGroupInfo(widget.groupUID);
      _nameController.text = info["name"];
      _descController.text = info["description"];
      _code = info["code"];
      _selectedAvatar = info["avatar"];
      loading = false;
      setState(() {});
    } catch (e) {
      debugPrint("Error cargando información: $e");
    }
  }

  /// Inicialización del estado.
  ///
  /// Se ejecuta al crear la pantalla:
  /// - Llama a `loadInfo()` para obtener los datos actuales del grupo.
  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  /// Construye la interfaz de edición del grupo.
  ///
  /// Incluye:
  /// - Selector de avatar
  /// - Campos de nombre y descripción
  /// - Código de invitación con opción de regenerar
  /// - Botones de guardar y descartar
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Stack(
      children: [
        //Background de pantalla
        Positioned.fill(child: Image.asset("assets/images/app_background.png", fit: BoxFit.cover)),
        Scaffold(
          appBar: AppBar(
            title: Text(loc.edit_group_info),
            backgroundColor: AppColors.infoPrimary,
          ),
          body: SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Selector de avatar del grupo
                          AvatarPicker(
                            selectedAvatar: _selectedAvatar,
                            onSelectedAvatar: (avatar) {
                              _selectedAvatar = avatar;
                              setState(() {});
                            },
                            avatarList: _avatarList,
                          ),

                          /// Tarjeta con campos de nombre y descripción
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Card.filled(
                              color: AppColors.infoPrimary,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    /// Título del campo nombre
                                    Text(
                                      loc.group_name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    /// Campo de edición del nombre
                                    TextField(
                                      controller: _nameController,
                                      maxLength: 15,
                                      style: AppStyles.infoTextFields,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.infoSecondary,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),

                                    /// Título del campo descripción
                                    Text(
                                      loc.description,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    /// Campo de edición de la descripción
                                    TextField(
                                      controller: _descController,
                                      maxLength: 100,
                                      minLines: 5,
                                      maxLines: 10,
                                      style: AppStyles.infoTextFields,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.infoSecondary,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// Tarjeta con el código de invitación
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Card.filled(
                              color: AppColors.infoSecondary,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// Muestra el código actual
                                    Text(
                                      "${loc.code}: $_code",
                                      style: AppStyles.infoTextFields,
                                    ),

                                    /// Botón para regenerar el código => Si no se guarda los cambios, el código regenerado tampoco se guarda
                                    TextButton(
                                      onPressed: () async {
                                        _code = await generateCode();
                                        setState(() {});
                                      },
                                      child: Text(
                                        loc.regenerate_code,
                                        style: AppStyles.infoTextFields,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// Botones de acción: descartar / guardar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              /// Botón para cancelar cambios
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.infoPrimary,
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.4,
                                    MediaQuery.of(context).size.height * 0.05,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    loc.discard,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),

                              /// Botón para guardar cambios
                              ElevatedButton(
                                onPressed: () {
                                  if (_nameController.text == "") {
                                    //Comprueba que haya introducido el nombre
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loc.error_title_required),
                                      ),
                                    );
                                  } else {
                                    try {
                                      editGroup(
                                        //Actualiza la información del grupo en la base de datos
                                        widget.groupUID,
                                        _nameController.text,
                                        _descController.text,
                                        _code,
                                        _selectedAvatar,
                                      );
                                      context.read<GroupProvider>().setGroup(
                                        //Actualiza el provider
                                        widget.groupUID,
                                        _nameController.text,
                                        true, //solo el admin puede actualizar, por lo tanto, aquí siempre será true
                                        _code,
                                      );
                                    } catch (e) { //recogemos error
                                      debugPrint("Error al actualizar grupo: $e");
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.error_try_again),
                                        ),
                                      );
                                    }
                                    Navigator.pushReplacement(
                                      //regreso a la pantalla del grupo
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupScreen(
                                          groupUID: widget.groupUID,
                                          groupName: _nameController.text,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.infoPrimary,
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.4,
                                    MediaQuery.of(context).size.height * 0.05,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    loc.save,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
}
