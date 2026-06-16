import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String phone;
  final DateTime createdAt;
  final String? photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    DateTime? createdAt,
    this.photoUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] as String,
      username: data['username'] as String? ?? '',
      email: data['email'] as String,
      phone: data['phone'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'createdAt': Timestamp.fromDate(createdAt),
    if (photoUrl != null) 'photoUrl': photoUrl,
  };
}
