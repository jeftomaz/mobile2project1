class Validators {
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(email);

  /// Normaliza um nome de usuário: remove o `@` inicial e baixa a caixa.
  static String normalizeUsername(String username) =>
      username.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();

  /// Valida o @handle. Retorna null se válido, ou uma mensagem de erro.
  /// Aceita 3–20 caracteres entre letras, números, ponto e underscore.
  static String? username(String username) {
    final handle = normalizeUsername(username);
    if (handle.isEmpty) return 'Informe um nome de usuário.';
    if (handle.length < 3) {
      return 'O nome de usuário deve ter ao menos 3 caracteres.';
    }
    if (handle.length > 20) {
      return 'O nome de usuário deve ter no máximo 20 caracteres.';
    }
    if (!RegExp(r'^[a-z0-9._]+$').hasMatch(handle)) {
      return 'Use apenas letras, números, ponto ou underscore.';
    }
    return null;
  }

  /// Returns null if password is valid, otherwise an error message.
  static String? password(String password) {
    if (password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'A senha deve conter ao menos uma letra maiúscula.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'A senha deve conter ao menos uma letra minúscula.';
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'A senha deve conter ao menos um caractere especial.';
    }
    return null;
  }
}
