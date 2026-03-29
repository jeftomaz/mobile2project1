import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no ViewModel
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100), // RF001 - Logotipo
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'), // RF001
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'), // RF001
              obscureText: true,
            ),
            const SizedBox(height: 20),
            authVM.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _handleLogin(context, authVM),
                    child: const Text('Entrar'), // RF001
                  ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Cadastrar Usuário'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: const Text('Esqueceu a senha?'),
            ),
          ],
        ),
      ),
    );
  }

  // Lógica de interação View -> ViewModel
  void _handleLogin(BuildContext context, AuthViewModel vm) async {
    try {
      await vm.login(_emailController.text, _passwordController.text);
      // RF001 - Se sucesso, direciona para a tela principal
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // RF006 - Exibe erro em SnackBar ou Dialog
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
