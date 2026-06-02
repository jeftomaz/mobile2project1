import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';
import '../../core/validators.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _passwordHint;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Image.asset('assets/images/framy_logo.png', height: 100),
            const SizedBox(height: 28),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() => _passwordHint = Validators.password(value));
              },
            ),
            if (_passwordHint != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _passwordHint!,
                        style: const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              obscureText: _obscureConfirm,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 28),
            authVM.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _handleRegister(context, authVM),
                    child: const Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }

  void _handleRegister(BuildContext context, AuthViewModel vm) async {
    final movieVM = context.read<MovieViewModel>();
    final genreVM = context.read<GenreViewModel>();

    try {
      await vm.register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      final uid = vm.currentUser?.uid;
      if (uid == null) {
        throw Exception('Usuário autenticado não encontrado após o cadastro.');
      }

      movieVM.setCurrentUser(uid);
      genreVM.setCurrentUser(uid);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }
}
