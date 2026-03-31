import 'dart:typed_data';

class Movie {
  final String id;
  String title;
  int year;
  String genre;
  Uint8List? coverBytes;
  bool watched;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    this.coverBytes,
    this.watched = false,
  });
}
