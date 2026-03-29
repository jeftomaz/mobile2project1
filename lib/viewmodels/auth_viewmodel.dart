import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // RF001 - Login
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Preencha todos os campos.");
    }
    if (!email.contains('@')) {
      throw Exception("E-mail inválido.");
    }

    _setLoading(true);
    // Simulação de delay para autenticação
    await Future.delayed(const Duration(seconds: 2));
    _setLoading(false);
    return true;
  }

  // RF002 - Cadastro
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception("Campos obrigatórios não preenchidos.");
    }
    if (password != confirmPassword) {
      throw Exception("As senhas não conferem.");
    }

    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    _setLoading(false);
  }

  // RF003 - Recuperação de Senha [cite: 45]
  Future<void> recoverPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception("Informe um e-mail válido.");
    }

    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notifica a View para mostrar/esconder o loading
  }
}
