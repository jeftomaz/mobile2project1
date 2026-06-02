import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewRepository {
  final _col = FirebaseFirestore.instance.collection('avaliacoes');

  Stream<List<Review>> watchReviews(String uid, String movieId) {
    return _col
        .where('userId', isEqualTo: uid)
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Review.fromDoc).toList());
  }

  Future<void> addReview(Review review) => _col.add(review.toMap());

  Future<void> updateReview(Review review) =>
      _col.doc(review.id).update(review.toMap());

  Future<void> deleteReview(String id) => _col.doc(id).delete();
}
