import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_view.dart';

void main() {
  runApp(
    // O MultiProvider injeta o ViewModel no topo da árvore de widgets.
    // Isso permite que qualquer tela acesse os dados de autenticação
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile 2 Project',
      debugShowCheckedModeBanner: false,
      // Define o tema visual seguindo o Material Design
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // RF001: A tela inicial deve ser a de Login
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(),
        '/home': (context) =>
            const Scaffold(body: Center(child: Text('Tela Principal'))),
        // Serão adicionadas as rotas de cadastro e recuperação conforme forem criadas
      },
    );
  }
}
