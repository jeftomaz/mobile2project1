import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/validators.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel(this._repo);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _repo.currentUser;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Preencha todos os campos.');
    }
    if (!Validators.isValidEmail(email)) {
      throw Exception('E-mail inválido.');
    }

    _setLoading(true);
    try {
      await _repo.login(email, password);
      await _loadProfile();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } finally {
      _setLoading(false);
    }
  }

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
    if (!Validators.isValidEmail(email)) {
      throw Exception('E-mail inválido.');
    }
    if (password != confirmPassword) {
      throw Exception('As senhas não conferem.');
    }
    final pwError = Validators.password(password);
    if (pwError != null) throw Exception(pwError);

    _setLoading(true);
    try {
      await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      await _loadProfile();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> recoverPassword(String email) async {
    if (email.isEmpty) throw Exception('Informe seu e-mail.');
    if (!Validators.isValidEmail(email)) throw Exception('E-mail inválido.');

    _setLoading(true);
    try {
      await _repo.recoverPassword(email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _profile = null;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final uid = _repo.currentUser?.uid;
    if (uid == null) return;
    _profile = await _repo.getUserProfile(uid);
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
