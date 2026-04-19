class Event{
  final String id;
  final String title;
  final DateTime date;
  final String description;
  final String location;
  final String authorName;
  final String authorID;
  final String recurrence;

  Event(
      {required this.recurrence, required this.id, required this.title, required this.date, required this.description, required this.location, required this.authorName, required this.authorID});

}