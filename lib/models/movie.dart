import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String userId;
  String title;
  int year;
  String genre;
  String? posterUrl;
  bool watched;
  final DateTime createdAt;

  Movie({
    required this.id,
    required this.userId,
    required this.title,
    required this.year,
    required this.genre,
    this.posterUrl,
    this.watched = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get titleLower => title.toLowerCase();

  factory Movie.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      year: (data['year'] as num).toInt(),
      genre: data['genre'] as String,
      posterUrl: data['posterUrl'] as String?,
      watched: data['watched'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'titleLower': title.toLowerCase(),
    'year': year,
    'genre': genre,
    'posterUrl': posterUrl,
    'watched': watched,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
