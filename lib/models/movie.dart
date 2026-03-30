class Movie {
  final String id;
  String title;
  int year;
  String genre;
  String? coverPath; // TODO: Image.file não funciona no Flutter Web.
  bool watched;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    this.coverPath,
    this.watched = false,
  });
}
