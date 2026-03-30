import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/movie_viewmodel.dart';
import 'dart:io';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final movieVM = context.watch<MovieViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Filmes'),
        automaticallyImplyLeading: false, // remove botão de voltar
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Em desenvolvimento.')),
            ),
          ),
        ],
      ),
      body: movieVM.movies.isEmpty
          ? const Center(child: Text('Nenhum filme adicionado ainda.'))
          : ListView.builder(
              itemCount: movieVM.movies.length,
              itemBuilder: (context, index) {
                final movie = movieVM.movies[index];
                return ListTile(
                  // TODO: Image.file não funciona no Flutter Web.
                  // Ao definir plataforma alvo, substituir por Image.memory (web) ou manter Image.file (mobile).
                  leading: movie.coverPath != null
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.file(
                            File(movie.coverPath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.movie, size: 50),
                  title: Text(movie.title),
                  subtitle: Text('${movie.genre} • ${movie.year}'),
                  trailing: IconButton(
                    icon: Icon(
                      movie.watched
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: movie.watched ? Colors.green : null,
                    ),
                    onPressed: () => movieVM.toggleWatched(movie.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/movie/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
