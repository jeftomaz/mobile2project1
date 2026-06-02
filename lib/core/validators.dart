class Validators {
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(email);

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
