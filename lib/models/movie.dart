class Movie {
  final String id;
  final String title;
  final int year;
  final String genre;
  final String? coverPath; // caminho local da imagem
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
