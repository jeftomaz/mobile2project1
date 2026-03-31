import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/forgot_password_view.dart';
import 'viewmodels/movie_viewmodel.dart';
import 'views/home/home_view.dart';
import 'views/specific/add_movie_view.dart';
import 'views/about/about_view.dart';
import 'views/specific/movie_stats_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MovieViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
        '/register': (context) => const RegisterView(),
        '/forgot-password': (context) => const ForgotPasswordView(),
        '/movie/add': (context) => const AddMovieView(),
        '/about': (context) => const AboutView(),
      },
    );
  }
}
