import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _introController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _introController,
    curve: Curves.easeIn,
  );
  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1.0)
      .animate(CurvedAnimation(parent: _introController, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  void _restoreSession() async {
    final user = await context.read<AuthViewModel>().authStateChanges.first;
    if (!mounted || user == null) return;
    context.read<MovieViewModel>().setCurrentUser(user.uid);
    context.read<GenreViewModel>().setCurrentUser(user.uid);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _introController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // Grain cinematográfico sobre o fundo
          const Positioned.fill(
            child: CustomPaint(painter: _GrainPainter()),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Image.asset(
                        'assets/images/framy_logo.png',
                        height: 220,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              authVM.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleLogin(context, authVM),
                        child: const Text('Entrar'),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Cadastrar Usuário'),
              ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('Esqueceu a senha?'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(BuildContext context, AuthViewModel vm) async {
    try {
      await vm.login(_emailController.text, _passwordController.text);

      final uid = vm.currentUser?.uid;
      if (uid != null && context.mounted) {
        context.read<MovieViewModel>().setCurrentUser(uid);
        context.read<GenreViewModel>().setCurrentUser(uid);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }
}

/// Desenha pontos aleatórios com opacidade muito baixa sobre o fundo,
/// imitando o grain/ruído de película. Estático (seed fixa, sem repaint).
class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF0D0D0D), BlendMode.srcOver);
    final random = Random(42);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03);
    final count = (size.width * size.height / 900).round();
    for (var i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
