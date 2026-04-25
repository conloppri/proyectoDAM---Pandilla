/// Modelo que representa un evento dentro del calendario del grupo.
///
/// Contiene toda la información necesaria para mostrar, editar y gestionar
/// eventos dentro de la aplicación, incluyendo datos de recurrencia y autor.
class Event {
  /// Identificador único del evento
  final String id;

  /// Título del evento
  final String title;

  /// Fecha del evento
  final DateTime date;

  /// Descripción del evento
  final String description;

  /// Ubicación del evento
  final String location;

  /// Nombre del autor que creó el evento
  final String authorName;

  /// ID del autor del evento
  final String authorID;

  /// Tipo de recurrencia del evento
  final String recurrence;

  Event({
    required this.recurrence,
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.location,
    required this.authorName,
    required this.authorID,
  });
}
