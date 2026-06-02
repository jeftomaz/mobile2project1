import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieRepository {
  final _col = FirebaseFirestore.instance.collection('filmes');

  Stream<List<Movie>> watchMovies(String uid) {
    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Movie.fromDoc).toList());
  }

  Future<void> addMovie(Movie movie) => _col.doc(movie.id).set(movie.toMap());

  Future<void> updateMovie(Movie movie) =>
      _col.doc(movie.id).update(movie.toMap());

  Future<void> toggleWatched(String id, bool currentValue) =>
      _col.doc(id).update({'watched': !currentValue});

  Future<void> deleteMovie(String id) => _col.doc(id).delete();

  Stream<List<Movie>> searchMovies(String uid, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: uid)
        .where('titleLower', isGreaterThanOrEqualTo: q)
        .where('titleLower', isLessThan: q + String.fromCharCode(0xF8FF))
        .snapshots()
        .map((snap) => snap.docs.map(Movie.fromDoc).toList());
  }
}
