import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../specific/genre_manager_dialog.dart';

/// Encerra a sessão limpando os streams e volta para o login.
Future<void> appLogout(BuildContext context) async {
  final authVM = context.read<AuthViewModel>();
  final movieVM = context.read<MovieViewModel>();
  final genreVM = context.read<GenreViewModel>();

  try {
    await authVM.logout();
    movieVM.clearCurrentUser();
    genreVM.clearCurrentUser();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Erro ao sair da conta.')));
  }
}

void showGenreManager(BuildContext context) {
  showDialog(context: context, builder: (_) => const GenreManagerDialog());
}

/// Confirma e executa a remoção de um filme. Retorna `true` se o filme foi
/// removido, para que a tela de origem possa reagir (ex.: fechar o detalhe).
Future<bool> confirmDeleteMovie(BuildContext context, Movie movie) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Remover filme'),
      content: Text('Deseja remover "${movie.title}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remover', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return false;

  try {
    await context.read<MovieViewModel>().deleteMovie(movie.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Filme removido.')));
    }
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao remover filme.')));
    }
    return false;
  }
}

/// Menu de transbordo compartilhado entre os mundos (gêneros, sobre, sair).
class AppOverflowMenu extends StatelessWidget {
  /// Quando `false`, omite a opção de gerenciar gêneros (telas onde ela não
  /// faz sentido).
  final bool showGenres;

  const AppOverflowMenu({super.key, this.showGenres = true});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'genres':
            showGenreManager(context);
          case 'about':
            Navigator.pushNamed(context, '/about');
          case 'logout':
            appLogout(context);
        }
      },
      itemBuilder: (context) => [
        if (showGenres)
          const PopupMenuItem(
            value: 'genres',
            child: ListTile(
              leading: Icon(Icons.category_outlined),
              title: Text('Gerenciar Gêneros'),
            ),
          ),
        const PopupMenuItem(
          value: 'about',
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sobre'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(leading: Icon(Icons.logout), title: Text('Sair')),
        ),
      ],
    );
  }
}
