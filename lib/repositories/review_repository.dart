import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewRepository {
  final _col = FirebaseFirestore.instance.collection('avaliacoes');

  Stream<List<Review>> watchReviews(String uid, String movieId) {
    return _col
        .where('userId', isEqualTo: uid)
        .where('movieId', isEqualTo: movieId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(Review.fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<bool> hasReview(String uid, String movieId) async {
    final snap = await _col
        .where('userId', isEqualTo: uid)
        .where('movieId', isEqualTo: movieId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> addReview(Review review) => _col.add(review.toMap());

  Future<void> updateReview(Review review) =>
      _col.doc(review.id).update(review.toMap());

  Future<void> deleteReview(String id) => _col.doc(id).delete();
}
