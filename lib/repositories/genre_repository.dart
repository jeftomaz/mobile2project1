import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/genre.dart';

class GenreRepository {
  final _col = FirebaseFirestore.instance.collection('generos');

  Stream<List<Genre>> watchGenres(String uid) {
    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(Genre.fromDoc).toList());
  }

  Future<void> addGenre(Genre genre) => _col.add(genre.toMap());

  Future<void> updateGenre(Genre genre) =>
      _col.doc(genre.id).update(genre.toMap());

  Future<void> deleteGenre(String id) => _col.doc(id).delete();
}
