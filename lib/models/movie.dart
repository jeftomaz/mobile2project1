import 'package:cloud_firestore/cloud_firestore.dart';

/// Os dois estados emocionais de um filme no acervo.
///
/// [wantToWatch] é a fila — "Quero ver", antecipação.
/// [watched] é o diário — "Já vi", memória datada.
enum MovieStatus { wantToWatch, watched }

class Movie {
  final String id;
  final String userId;
  String title;
  int year;
  String genre;
  String? posterUrl;
  MovieStatus status;

  /// Data em que o filme entrou para o diário (marco da timeline).
  /// Só faz sentido quando [status] é [MovieStatus.watched].
  DateTime? watchedAt;

  final DateTime createdAt;

  Movie({
    required this.id,
    required this.userId,
    required this.title,
    required this.year,
    required this.genre,
    this.posterUrl,
    this.status = MovieStatus.wantToWatch,
    this.watchedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Compatibilidade: "assistido" significa estar no diário.
  bool get watched => status == MovieStatus.watched;

  /// Data que ancora o filme na timeline do diário.
  DateTime get diaryDate => watchedAt ?? createdAt;

  String get titleLower => title.toLowerCase();

  factory Movie.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final legacyWatched = data['watched'] as bool? ?? false;
    final statusStr = data['status'] as String?;
    final status = MovieStatus.values.firstWhere(
      (s) => s.name == statusStr,
      // Filmes antigos não têm 'status': deriva do booleano legado.
      orElse: () =>
          legacyWatched ? MovieStatus.watched : MovieStatus.wantToWatch,
    );

    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    var watchedAt = (data['watchedAt'] as Timestamp?)?.toDate();
    // Migração: assistidos antigos não têm watchedAt; usa a data de cadastro
    // como melhor aproximação para não sumirem da timeline.
    if (status == MovieStatus.watched && watchedAt == null) {
      watchedAt = createdAt;
    }

    return Movie(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      year: (data['year'] as num).toInt(),
      genre: data['genre'] as String,
      posterUrl: data['posterUrl'] as String?,
      status: status,
      watchedAt: watchedAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'titleLower': title.toLowerCase(),
    'year': year,
    'genre': genre,
    'posterUrl': posterUrl,
    'status': status.name,
    // 'watched' é mantido por compatibilidade com dados/consultas legadas.
    'watched': status == MovieStatus.watched,
    'watchedAt': watchedAt != null ? Timestamp.fromDate(watchedAt!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
