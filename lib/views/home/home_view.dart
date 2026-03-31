import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/movie_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final movieVM = context.watch<MovieViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Filmes'),
        automaticallyImplyLeading: false,
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
                  leading: movie.coverBytes != null
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.memory(
                              movie.coverBytes!,
                              fit: BoxFit.cover,
                            ),
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
