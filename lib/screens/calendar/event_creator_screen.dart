//Básicos
import 'package:flutter/material.dart';
//Componentes personalizados
import 'package:pandilla/components/date_picker_widget.dart';
//Estilos y colores
import '../../core/app_colors.dart';
import 'package:pandilla/core/app_styles.dart';
//Firebase
import 'package:pandilla/core/services/firebase_service.dart';
//Servicios y providers
import 'package:pandilla/core/providers/group_provider.dart';
import 'package:pandilla/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Pantalla para la creación de nuevos eventos dentro de un grupo.
///
/// Permite introducir:
/// - Título del evento
/// - Descripción
/// - Fecha
/// - Ubicación
/// - Tipo de recurrencia
///
/// Al guardar, crea el evento en la base de datos.
class EventCreatorScreen extends StatefulWidget {
  const EventCreatorScreen({super.key});

  @override
  State<EventCreatorScreen> createState() => _EventCreatorScreenState();
}

/// Estado de la pantalla de creación de eventos.
///
/// Gestiona:
/// - Datos introducidos por el usuario
/// - Selección de fecha
/// - Selección de recurrencia
class _EventCreatorScreenState extends State<EventCreatorScreen> {
  /// Título del evento.
  String _title = "";

  /// Fecha seleccionada para el evento (día actual por defecto).
  DateTime _date = DateTime.now();

  /// Descripción del evento.
  String _description = "";

  /// Ubicación del evento.
  String _location = "";

  /// Lista de tipos de recurrencia disponibles.
  final List _recurrence = ["unique", "weekly", "monthly", "yearly"];

  /// Índice de la recurrencia seleccionada.
  int _recSelected = 0;

  /// Construye la interfaz de creación de evento.
  ///
  /// Incluye:
  /// - Formulario de datos
  /// - Selector de fecha
  /// - Selector de recurrencia
  /// - Botones de guardar y cancelar
  @override
  Widget build(BuildContext context) {
    /// Textos traducidos para la recurrencia
    final List recurrenceButton = [
      AppLocalizations.of(context)!.one_time,
      AppLocalizations.of(context)!.weekly,
      AppLocalizations.of(context)!.monthly,
      AppLocalizations.of(context)!.yearly,
    ];
    /// Datos del grupo actual desde el provider
    String? groupUID = context.watch<GroupProvider>().groupUID;
    String? groupName = context.watch<GroupProvider>().groupName;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName!),
        backgroundColor: AppColors.calendarPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            /// Título de la pantalla
            Text(AppLocalizations.of(context)!.new_event, style: AppStyles.title,),

            /// Contenedor con campos de título y descripción
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

                    /// Campo de título
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendarSecondary,
                        labelStyle: const TextStyle(color: AppColors.calendarPrimary),
                        labelText: AppLocalizations.of(context)!.title,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(15)
                        )
                      ),
                      onChanged: (value) => _title = value,
                    ),

                    /// Campo de descripción
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendarSecondary,
                        labelStyle: const TextStyle(color: AppColors.calendarPrimary),
                        labelText: AppLocalizations.of(context)!.description,
                        enabledBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15)
                        ),
                      ),
                      onChanged: (value) => _description = value,
                    ),
                  ],
                ),
              ),
            ),

            /// Selector de fecha del evento
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DatePickerWidget(
                selectedDate: DateTime.now(),
                labelStyle: const TextStyle(fontSize: 20),
                buttonColor: AppColors.calendarPrimary,
                label: AppLocalizations.of(context)!.event_date,
                firstDate: DateTime(1900),
                lastDate: DateTime(DateTime.now().year + 50),
                onDateSelected: (date) {
                  setState(() {
                    _date = date;
                  });
                },
              ),
            ),

            /// Contenedor con ubicación y recurrencia
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

                    /// Campo de ubicación
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calendarSecondary,
                        labelStyle: const TextStyle(color: AppColors.calendarPrimary),
                        labelText: AppLocalizations.of(context)!.location,
                        enabledBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15)
                        ),
                      ),
                      onChanged: (value) => _location = value,
                    ),

                    /// Selector de recurrencia
                    Row(
                      spacing: 15,
                      children: [
                        Text("${AppLocalizations.of(context)!.recurrence}: ", style: const TextStyle(fontSize: 20),),

                        /// Botón que abre el diálogo de selección
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.calendarSecondary),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.recurrence_dialog_title),
                                content: Container(
                                  width: double.maxFinite,
                                  constraints: const BoxConstraints(maxHeight: 300),
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      /// Opción: evento único
                                      ListTile(
                                        title: Text(recurrenceButton[0]),
                                        onTap: () {
                                          setState(() {
                                            _recSelected = 0;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      /// Opción: semanal
                                      ListTile(
                                        title: Text(recurrenceButton[1]),
                                        onTap: () {
                                          setState(() {
                                            _recSelected = 1;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      /// Opción: mensual
                                      ListTile(
                                        title: Text(recurrenceButton[2]),
                                        onTap: () {
                                          setState(() {
                                            _recSelected = 2;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      /// Opción: anual
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
                          /// Muestra la opción seleccionada actualmente
                          child: Text(recurrenceButton[_recSelected], style: const TextStyle(fontSize: 15, color: AppColors.calendarPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            /// Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// Botón para cancelar la creación
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.discard,
                      style: const TextStyle(color: AppColors.calendarSecondary, fontSize: 20),
                    ),
                  ),
                ),
                /// Botón para guardar el evento
                ElevatedButton(
                  onPressed: () {
                    if(_title==""){ //Comprobamos que no haya dejado el título en blanco
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_title_required)));
                    }else { //Si está correcto, guarda el evento en la base de datos
                      try {
                        setState(() {
                          saveEvent(
                            groupUID!,
                            groupName,
                            _title,
                            _description,
                            _date,
                            _location,
                            _recurrence[_recSelected],
                          );
                        });
                      } catch (e) {
                        debugPrint("Error guardando evento: $e");
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: const TextStyle(color: AppColors.calendarSecondary, fontSize: 20),
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
