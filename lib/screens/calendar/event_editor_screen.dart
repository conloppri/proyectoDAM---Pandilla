//Básicos
import 'package:flutter/material.dart';
//Componentes personalizados
import '../../components/date_picker_widget.dart';
//Estilos y colores
import '../../core/app_colors.dart';
import '../../core/app_styles.dart';
//Firebase
import '../../core/services/firebase_service.dart';
//Servicios y providers
import 'package:provider/provider.dart';
import '../../core/providers/group_provider.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla para editar un evento existente.
///
/// Permite:
/// - Modificar título, descripción y localización
/// - Cambiar la fecha del evento
/// - Seleccionar la recurrencia (único, semanal, mensual, anual)
class EventEditorScreen extends StatefulWidget {
  /// UID del grupo al que pertenece el evento.
  final String groupUID;

  /// ID del evento a editar.
  final String eventID;

  const EventEditorScreen({super.key, required this.groupUID, required this.eventID});

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

/// Estado de la pantalla de edición de eventos.
///
/// Gestiona:
/// - Carga de datos del evento
/// - Control de inputs del formulario
/// - Actualización del evento en la base de datos
class _EventEditorScreenState extends State<EventEditorScreen> {
  /// Controlador del campo título.
  final TextEditingController _titleController = TextEditingController();

  /// Controlador del campo descripción.
  final TextEditingController _descController = TextEditingController();

  /// Controlador del campo localización.
  final TextEditingController _locController = TextEditingController();

  /// Fecha seleccionada para el evento.
  DateTime _date = DateTime.now();

  /// Lista de tipos de recurrencia disponibles.
  final List _recurrence = ["unique", "weekly", "monthly", "yearly"];

  /// Índice de la recurrencia seleccionada.
  int _recSelected = 0;


  ///Variable que controla si la información ha llegado antes de mostrarla
  bool loading = true;

  /// Carga la información del evento desde Firestore.
  ///
  /// Rellena los campos del formulario con los datos actuales.
  loadEventInfo() async {
    try {
      final data =await getEventInfo(widget.groupUID, widget.eventID);
      setState(() {
        _titleController.text = data["title"];
        _descController.text = data["description"];
        _locController.text = data["location"];
        _date = DateTime(data["year"], data["month"], data["day"]);
        _recSelected = _recurrence.indexOf(data["recurrence"]);
        loading = false;
      });
    } catch (e) {
      debugPrint("Error cargando información del evento: $e");
    }
  }

  /// Metodo de inicialización.
  ///
  /// Carga los datos del evento al iniciar la pantalla.
  @override
  void initState() {
    super.initState();
    loadEventInfo();
  }

  /// Construye la interfaz de edición del evento.
  @override
  Widget build(BuildContext context) {
    /// Textos traducidos para los tipos de recurrencia.
    final List recurrenceButton = [
      AppLocalizations.of(context)!.one_time,
      AppLocalizations.of(context)!.weekly,
      AppLocalizations.of(context)!.monthly,
      AppLocalizations.of(context)!.yearly,
    ];

    ///Datos del grupo recogidos desde provider
    String? groupUID = context.watch<GroupProvider>().groupUID;
    String? groupName = context.watch<GroupProvider>().groupName;

    final AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName!),
        backgroundColor: AppColors.calendarPrimary,
      ),
      body: loading?const Center(child: CircularProgressIndicator())
          :Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// Título de la pantalla
            Text(loc.edit_event, style: AppStyles.appBarTitle),

            /// Contenedor de título del evento y descripción
            Container(
              decoration: BoxDecoration(
                  color: AppColors.calendarPrimary,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  spacing: 15,
                  children: [
                    /// Campo título
                    TextField(
                      controller: _titleController,
                      style: AppStyles.eventTextFields,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.calendarSecondary,
                          labelStyle: const TextStyle(color: Colors.black),
                          labelText: loc.title,
                          enabledBorder: AppStyles.outlineInputBorderRounded
                      ),
                    ),
                    /// Campo descripción
                    TextField(
                      controller: _descController,
                      style: AppStyles.eventTextFields,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendarSecondary,
                        labelStyle: const TextStyle(color: Colors.black),
                        labelText: loc.description,
                        enabledBorder: AppStyles.outlineInputBorderRounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              /// Selector de fecha del evento
              child: DatePickerWidget(
                selectedDate: _date,
                labelStyle: const TextStyle(fontSize: 20),
                buttonColor: AppColors.calendarPrimary,
                label: loc.event_date,
                firstDate: DateTime(1900),
                lastDate: DateTime(DateTime.now().year + 50),
                onDateSelected: (date) => _date = date,
              ),
            ),
            /// Contenedor de localización y recurrencia
            Container(
              decoration: BoxDecoration(
                  color: AppColors.calendarPrimary,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  spacing: 15,
                  children: [
                    /// Campo localización
                    TextField(
                      controller: _locController,
                      style: AppStyles.eventTextFields,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendarSecondary,
                        labelStyle: const TextStyle(color: Colors.black),
                        labelText: loc.location,
                        enabledBorder: AppStyles.outlineInputBorderRounded,
                      ),
                    ),
                    /// Selector de recurrencia
                    Row(
                      spacing: 15,
                      children: [
                        Text("${loc.recurrence}: ", style: AppStyles.buttonTextStyle),
                        /// Botón que abre diálogo de selección
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.calendarSecondary),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog( //Diálogo de selección de recurrencia con lista
                                title: Text(loc.recurrence_dialog_title),
                                content: Container(
                                  width: double.maxFinite,
                                  constraints: const BoxConstraints(maxHeight: 300),
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      ListTile(
                                        title: Text(recurrenceButton[0]),
                                        onTap: () {
                                          setState(() {
                                            _recSelected = 0;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text(recurrenceButton[1]),
                                        onTap: () {
                                          setState(() {
                                            _recSelected = 1;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text(recurrenceButton[2]),
                                        onTap: () {
                                          setState(() {
                                            _recSelected = 2;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text(recurrenceButton[3]),
                                        onTap: () {
                                          setState(() {
                                            _recSelected = 3;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(recurrenceButton[_recSelected], style: const TextStyle(fontSize: 15, color: AppColors.calendarPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            /// Botones de acción (guardar / descartar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///Botón cancelar
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      loc.discard,
                      style: AppStyles.buttonTextStyle,
                    ),
                  ),
                ),
                ///Botón guardar
                ElevatedButton(
                  onPressed: () {
                    if(_titleController.text==""){ //Comprobamos que haya introducido un título
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.error_title_required)));
                    }else {
                      try {
                        setState(() {
                          editEvent(
                              groupUID!,
                              groupName,
                              widget.eventID,
                              _titleController.text,
                              _descController.text,
                              _locController.text,
                              _recurrence[_recSelected],
                              _date);
                        });
                      } catch (e) {
                        debugPrint("Error al editar evento: $e");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.error_try_again)));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      loc.save,
                      style: AppStyles.buttonTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
