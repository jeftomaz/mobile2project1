import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String movieId;
  int rating;
  String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    this.comment = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Review.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] as String,
      movieId: data['movieId'] as String,
      rating: (data['rating'] as num).toInt(),
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'movieId': movieId,
    'rating': rating,
    'comment': comment,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
