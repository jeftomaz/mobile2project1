import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(email);

  // login
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Preencha todos os campos.');
    }
    if (!_isValidEmail(email)) {
      throw Exception('E-mail inválido.');
    }

    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  // cadastro
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      throw Exception('Preencha todos os campos obrigatórios.');
    }
    if (!_isValidEmail(email)) {
      throw Exception('E-mail inválido.');
    }
    if (password != confirmPassword) {
      throw Exception('As senhas não conferem.');
    }

    _setLoading(true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  // recuperação de Senha
  Future<void> recoverPassword(String email) async {
    if (email.isEmpty) {
      throw Exception('Informe seu e-mail.');
    }
    if (!_isValidEmail(email)) {
      throw Exception('E-mail inválido.');
    }

    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-credential' => 'E-mail ou senha incorretos.',
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
      'invalid-email' => 'E-mail inválido.',
      'too-many-requests' => 'Muitas tentativas. Tente mais tarde.',
      _ => 'Erro inesperado. Tente novamente.',
    };
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
