import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Verifica se um @handle (já normalizado) está em uso por outro usuário.
  Future<bool> isUsernameTaken(String username) async {
    final snap = await _db
        .collection('usuarios')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<User> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name.trim());

    final profile = UserProfile(
      uid: user.uid,
      name: name.trim(),
      username: username,
      email: email.trim(),
      phone: phone.trim(),
    );
    await _db.collection('usuarios').doc(user.uid).set(profile.toMap());

    return user;
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  Future<void> recoverPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.exists ? UserProfile.fromDoc(doc) : null;
  }

  Future<void> updateProfile(
    String uid, {
    required String name,
    required String username,
    required String phone,
  }) async {
    await _db.collection('usuarios').doc(uid).update({
      'name': name,
      'username': username,
      'phone': phone,
    });
    await _auth.currentUser?.updateDisplayName(name);
  }
}
