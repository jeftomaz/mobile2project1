import 'package:cloud_firestore/cloud_firestore.dart';

class Genre {
  final String id;
  final String userId;
  String name;
  int color;
  int usageCount;
  final DateTime createdAt;

  Genre({
    required this.id,
    required this.userId,
    required this.name,
    this.color = 0xFF607D8B,
    this.usageCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Genre.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Genre(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      color: (data['color'] as num?)?.toInt() ?? 0xFF607D8B,
      usageCount: (data['usageCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'color': color,
    'usageCount': usageCount,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
