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

  Stream<User?> get authStateChanges => _repo.authStateChanges;

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
    } catch (_) {
      throw Exception('Erro ao entrar. Verifique sua conexão e tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      throw Exception('Preencha todos os campos obrigatórios.');
    }
    if (!Validators.isValidEmail(email)) {
      throw Exception('E-mail inválido.');
    }
    final usernameError = Validators.username(username);
    if (usernameError != null) throw Exception(usernameError);
    if (password != confirmPassword) {
      throw Exception('As senhas não conferem.');
    }
    final pwError = Validators.password(password);
    if (pwError != null) throw Exception(pwError);

    final handle = Validators.normalizeUsername(username);

    // Checagem de unicidade fora do try principal para preservar a mensagem
    // específica (o catch genérico abaixo só trata falhas inesperadas).
    if (await _isUsernameTaken(handle)) {
      throw Exception('Este nome de usuário já está em uso.');
    }

    _setLoading(true);
    try {
      await _repo.register(
        name: name,
        username: handle,
        email: email,
        phone: phone,
        password: password,
      );
      await _loadProfile();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (_) {
      throw Exception('Erro ao criar conta. Verifique sua conexão e tente novamente.');
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
    } catch (_) {
      throw Exception('Erro ao enviar e-mail. Verifique sua conexão e tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _profile = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String username,
    required String phone,
  }) async {
    final uid = _repo.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    if (name.trim().isEmpty) throw Exception('O nome não pode estar vazio.');
    final usernameError = Validators.username(username);
    if (usernameError != null) throw Exception(usernameError);

    final handle = Validators.normalizeUsername(username);

    // Só checa unicidade se o @handle mudou em relação ao perfil atual.
    if (handle != _profile?.username && await _isUsernameTaken(handle)) {
      throw Exception('Este nome de usuário já está em uso.');
    }

    _setLoading(true);
    try {
      await _repo.updateProfile(
        uid,
        name: name.trim(),
        username: handle,
        phone: phone.trim(),
      );
      await _loadProfile();
    } catch (_) {
      throw Exception('Erro ao atualizar perfil. Tente novamente.');
    } finally {
      _setLoading(false);
    }
  }

  /// Consulta a coleção `usuarios` por um @handle. Em falha de rede, assume
  /// "não está em uso" para não travar o fluxo (a unicidade é best-effort).
  Future<bool> _isUsernameTaken(String handle) async {
    try {
      return await _repo.isUsernameTaken(handle);
    } catch (_) {
      return false;
    }
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
